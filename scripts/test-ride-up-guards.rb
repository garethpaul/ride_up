#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'pathname'
require 'tmpdir'

root = Pathname.new(__dir__).parent.expand_path
sources = [
  root.join('app/src/main/java/com/foursquare/rideup/RideUpGuards.java'),
  root.join('app/src/main/java/com/foursquare/rideup/MarkerAnimationLifecycle.java'),
  root.join('app/src/main/java/com/foursquare/rideup/PickupMapState.java'),
  root.join('app/src/main/java/com/foursquare/rideup/PickupMapPublicationController.java'),
  root.join('app/src/main/java/com/foursquare/rideup/CurrentPlaceRequestController.java'),
  root.join('scripts/java/com/foursquare/rideup/RideUpGuardsContractTest.java'),
  root.join('scripts/java/com/foursquare/rideup/MarkerAnimationLifecycleContractTest.java'),
  root.join('scripts/java/com/foursquare/rideup/PickupMapStateContractTest.java'),
  root.join('scripts/java/com/foursquare/rideup/PickupMapPublicationControllerContractTest.java'),
  root.join('scripts/java/com/foursquare/rideup/CurrentPlaceRequestControllerContractTest.java')
]

Dir.mktmpdir('ride-up-guards') do |output|
  compile_output, compile_status = Open3.capture2e(
    'javac', '-source', '7', '-target', '7', '-d', output, *sources.map(&:to_s)
  )
  abort compile_output unless compile_status.success?

  test_output, test_status = Open3.capture2e(
    'java', '-cp', output, 'com.foursquare.rideup.RideUpGuardsContractTest'
  )
  abort test_output unless test_status.success?

  print test_output

  lifecycle_output, lifecycle_status = Open3.capture2e(
    'java', '-cp', output, 'com.foursquare.rideup.MarkerAnimationLifecycleContractTest'
  )
  abort lifecycle_output unless lifecycle_status.success?

  print lifecycle_output

  state_output, state_status = Open3.capture2e(
    'java', '-cp', output, 'com.foursquare.rideup.PickupMapStateContractTest'
  )
  abort state_output unless state_status.success?

  print state_output

  controller_output, controller_status = Open3.capture2e(
    'java', '-cp', output,
    'com.foursquare.rideup.PickupMapPublicationControllerContractTest'
  )
  abort controller_output unless controller_status.success?

  print controller_output

  request_output, request_status = Open3.capture2e(
    'java', '-cp', output,
    'com.foursquare.rideup.CurrentPlaceRequestControllerContractTest'
  )
  abort request_output unless request_status.success?

  print request_output
end
