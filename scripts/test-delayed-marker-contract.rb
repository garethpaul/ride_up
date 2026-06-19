#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative 'delayed-marker-contract'

root = Pathname.new(__dir__).parent.expand_path
baseline = root.join('app/src/main/java/com/foursquare/rideup/MainActivity.java').read
current_place_guard = "                if (!markerAnimationLifecycle.canAnimate()) {\n                    return;\n                }\n\n"
latitude_assignment = "                lat = venue.getLocation().getLat();\n"
map_ready_guard = "                        if (!markerAnimationLifecycle.canAnimate()) {\n                            return;\n                        }\n"
map_ready_assignment = "                        MainActivity.this.mapboxMap = mapboxMap;\n"
guard = "                                if (!markerAnimationLifecycle.canAnimate()) {\n                                    return;\n                                }\n"
loop_start = "                                for (int i = 0; i < 10; i++) {\n"

baseline_failures = DelayedMarkerContract.failures(baseline)
abort baseline_failures.join("\n") unless baseline_failures.empty?

mutations = {
  'missing current-place lifecycle guard' => baseline.sub(current_place_guard, ''),
  'current-place guard after latitude assignment' => baseline.sub(
    current_place_guard + latitude_assignment,
    latitude_assignment + current_place_guard
  ),
  'missing map-ready lifecycle guard' => baseline.sub(map_ready_guard, ''),
  'map-ready guard after map assignment' => baseline.sub(
    map_ready_guard + map_ready_assignment,
    map_ready_assignment + map_ready_guard
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
  abort "#{description} mutation was accepted" if DelayedMarkerContract.failures(source).empty?
end

puts "Delayed marker population contract passed (#{mutations.length} mutations rejected)."
