#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative 'delayed-marker-contract'

root = Pathname.new(__dir__).parent.expand_path
baseline = root.join('app/src/main/java/com/foursquare/rideup/MainActivity.java').read
current_place_guard = "                if (!markerAnimationLifecycle.canAnimate()) {\n                    return;\n                }\n\n"
state_update = "                pickupMapState.updateCurrentPlace(\n"
map_ready_guard = "                        if (!markerAnimationLifecycle.canAnimate()) {\n                            return;\n                        }\n"
map_ready_assignment = "                        MainActivity.this.mapboxMap = mapboxMap;\n"
map_ready_publication = "                        publishMapLocation();\n"
guard = "                                if (!markerAnimationLifecycle.canAnimate()) {\n                                    return;\n                                }\n"
loop_start = "                                for (int i = 0; i < 10; i++) {\n"

baseline_failures = DelayedMarkerContract.failures(baseline)
abort baseline_failures.join("\n") unless baseline_failures.empty?

mutations = {
  'missing current-place lifecycle guard' => baseline.sub(current_place_guard, ''),
  'current-place guard after state update' => baseline.sub(
    current_place_guard + state_update,
    state_update + current_place_guard
  ),
  'missing map-ready lifecycle guard' => baseline.sub(map_ready_guard, ''),
  'map-ready guard after map assignment' => baseline.sub(
    map_ready_guard + map_ready_assignment,
    map_ready_assignment + map_ready_guard
  ),
  'map-ready publication before map assignment' => baseline.sub(
    map_ready_assignment + map_ready_publication,
    map_ready_publication + map_ready_assignment
  ),
  'missing lifecycle guard' => baseline.sub(guard, ''),
  'inverted lifecycle guard' => baseline.sub(
    'if (!markerAnimationLifecycle.canAnimate())',
    'if (markerAnimationLifecycle.canAnimate())'
  ),
  'guard after marker loop' => baseline.sub(guard + loop_start, loop_start + guard),
  'guard after marker addition' => baseline.sub(
    guard + loop_start + "                                    addRandomCar();\n",
    loop_start + "                                    addRandomCar();\n" + guard
  )
}

mutations.each do |description, source|
  abort "#{description} mutation did not change the source" if source == baseline
  abort "#{description} mutation was accepted" if DelayedMarkerContract.failures(source).empty?
end

puts "Delayed marker population contract passed (#{mutations.length} mutations rejected)."
