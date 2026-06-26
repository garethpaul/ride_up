#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'tmpdir'
require_relative 'java-contract-runner'
require_relative 'pickup-map-contract'

root = Pathname.new(__dir__).parent.expand_path
main_path = root.join('app/src/main/java/com/foursquare/rideup/MainActivity.java')
state_path = root.join('app/src/main/java/com/foursquare/rideup/PickupMapState.java')
controller_path = root.join(
  'app/src/main/java/com/foursquare/rideup/PickupMapPublicationController.java'
)
state_test_path = root.join(
  'scripts/java/com/foursquare/rideup/PickupMapStateContractTest.java'
)
controller_test_path = root.join(
  'scripts/java/com/foursquare/rideup/PickupMapPublicationControllerContractTest.java'
)
javac = JavaContractRunner.tool('JAVAC', 'javac')
java = JavaContractRunner.tool('JAVA', 'java')
main_activity = main_path.read
state_source = state_path.read
controller_source = controller_path.read
state_test = state_test_path.read
controller_test = controller_test_path.read

baseline_failures = PickupMapContract.failures(
  main_activity, state_source, controller_source
)
abort baseline_failures.join("\n") unless baseline_failures.empty?

test_classes = %w[
  com.foursquare.rideup.PickupMapStateContractTest
  com.foursquare.rideup.PickupMapPublicationControllerContractTest
]

Dir.mktmpdir('ride-up-pickup-baseline') do |directory|
  output = Pathname.new(directory).join('classes')
  JavaContractRunner.compile!(
    javac, [state_path, controller_path, state_test_path, controller_test_path], output,
    context: 'pickup map baseline'
  )
  test_classes.each do |test_class|
    JavaContractRunner.run_test!(
      java, output, test_class, context: 'pickup map baseline'
    )
  end
end

static_mutations = {
  'discarded picker state' => [
    main_activity.sub(/\s*pickupMapState\.selectPickup\(.*?;/m, ''),
    state_source,
    controller_source
  ],
  'comment-only production controller call' => [
    main_activity.sub(
      /pickupMapPublicationController\.publishIfPending\(.*?\);/m,
      "/* pickupMapPublicationController.publishIfPending(\n" \
      "        mapboxMap != null, markerAnimationLifecycle.canAnimate(), publisher); */"
    ),
    state_source,
    controller_source
  ],
  'dead production controller call' => [
    main_activity.sub(
      "    private void publishMapLocation() {\n",
      "    private void publishMapLocation() {\n        return;\n"
    ),
    state_source,
    controller_source
  ],
  'missing map-ready publication' => [
    main_activity.sub(
      "                MainActivity.this.mapboxMap = mapboxMap;\n" \
      "                publishMapLocation();\n",
      "                MainActivity.this.mapboxMap = mapboxMap;\n"
    ),
    state_source,
    controller_source
  ],
  'missing resume publication' => [
    main_activity.sub(
      "        requestMapReady();\n        publishMapLocation();\n" \
      "        for (MarkerView marker : new ArrayList<>(carMarkers)) {\n",
      "        requestMapReady();\n" \
      "        for (MarkerView marker : new ArrayList<>(carMarkers)) {\n"
    ),
    state_source,
    controller_source
  ],
  'missing resume map readiness request' => [
    main_activity.sub(
      "        requestMapReady();\n        publishMapLocation();\n",
      "        publishMapLocation();\n"
    ),
    state_source,
    controller_source
  ],
  'different marker coordinates' => [
    main_activity.sub('.position(location)', '.position(new LatLng(0, 0))'),
    state_source,
    controller_source
  ],
  'pickup falls through to car scheduling' => [
    main_activity.sub(
      /(\.title\("Pick Up Location"\)\);)\s*return;/m, '\\1'
    ),
    state_source,
    controller_source
  ],
  'missing current-place stale guard' => [
    main_activity,
    state_source.sub(/\s*if \(hasPickup\) \{\s*return;\s*\}/m, ''),
    controller_source
  ],
  'missing current revision' => [
    main_activity,
    state_source.sub('pendingRevision = ++revision;', ''),
    controller_source
  ],
  'missing pickup revision' => [
    main_activity,
    state_source.sub('pendingRevision = ++revision;', '').sub('pendingRevision = ++revision;', ''),
    controller_source
  ],
  'missing pickup observation' => [
    main_activity,
    state_source.sub(/\s*boolean hasPickup\(\) \{.*?\n\s*\}/m, ''),
    controller_source
  ],
  'missing consumed revision check' => [
    main_activity,
    state_source.sub(' || pendingRevision == publishedRevision', ''),
    controller_source
  ],
  'missing publication consumption' => [
    main_activity,
    state_source.sub(/^\s*publishedRevision = pendingRevision;\n/, ''),
    controller_source
  ],
  'controller always returns' => [
    main_activity,
    state_source,
    controller_source.sub(
      "    boolean publishIfPending(boolean mapReady, boolean active, Publisher publisher) {\n",
      "    boolean publishIfPending(boolean mapReady, boolean active, Publisher publisher) {\n" \
      "        return false;\n"
    )
  ],
  'controller omits side effects' => [
    main_activity,
    state_source,
    controller_source.sub(/^\s*publisher\.publish\(publication\);\n/, '')
  ]
}

static_mutations.each do |description, sources|
  mutated_main, mutated_state, mutated_controller = sources
  if mutated_main == main_activity &&
     mutated_state == state_source &&
     mutated_controller == controller_source
    abort "#{description} mutation did not change the source"
  end
  if PickupMapContract.failures(
    mutated_main, mutated_state, mutated_controller
  ).empty?
    abort "#{description} mutation was accepted"
  end
end

def reject_executable_mutation!(
  javac, java, state_source, controller_source, state_test, controller_test,
  test_classes, expected_assertion, description
)
  Dir.mktmpdir('ride-up-pickup-mutation') do |directory|
    package = Pathname.new(directory).join('com/foursquare/rideup')
    FileUtils.mkdir_p(package)
    package.join('PickupMapState.java').write(state_source)
    package.join('PickupMapPublicationController.java').write(controller_source)
    package.join('PickupMapStateContractTest.java').write(state_test)
    package.join('PickupMapPublicationControllerContractTest.java').write(controller_test)
    output = Pathname.new(directory).join('classes')
    JavaContractRunner.reject_mutant!(
      javac, java, package.children, output, test_classes, expected_assertion,
      context: "#{description} executable mutation"
    )
  end
end

executable_mutations = {
  'always-replay state' => [
    state_source.sub(' || pendingRevision == publishedRevision', ''), controller_source,
    'repeated resume must not republish consumed current place'
  ],
  'never-consumed state' => [
    state_source.sub(/^\s*publishedRevision = pendingRevision;\n/, ''), controller_source,
    'repeated resume must not republish consumed current place'
  ],
  'late-current replay' => [
    state_source.sub(/\s*if \(hasPickup\) \{\s*return;\s*\}/m, ''), controller_source,
    'late current place must not republish an explicit pickup'
  ],
  'pickup revision omitted' => [
    state_source.sub(/(void selectPickup.*?)(\s*pendingRevision = \+\+revision;)/m, '\\1'),
    controller_source, 'pickup publication must exist'
  ],
  'controller always false' => [
    state_source,
    controller_source.sub(
      /PickupMapState\.Publication publication = state\.publication\(mapReady, active\);.*?return true;/m,
      'return false;'
    ),
    'first resume must publish current place'
  ],
  'controller skips publisher' => [
    state_source, controller_source.sub(/^\s*publisher\.publish\(publication\);\n/, ''),
    'resume side effects must run once'
  ],
  'controller publishes twice' => [
    state_source,
    controller_source.sub(
      /^\s*publisher\.publish\(publication\);\n/,
      "        publisher.publish(publication);\n        publisher.publish(publication);\n"
    ),
    'resume side effects must run once'
  ]
}

executable_mutations.each do |description, sources|
  mutated_state, mutated_controller, expected_assertion = sources
  if mutated_state == state_source && mutated_controller == controller_source
    abort "#{description} executable mutation did not change the source"
  end
  reject_executable_mutation!(
    javac, java, mutated_state, mutated_controller, state_test, controller_test,
    test_classes, expected_assertion, description
  )
end

puts "Pickup map contract passed " \
     "(#{static_mutations.length} static and " \
     "#{executable_mutations.length} executable mutations rejected)."
