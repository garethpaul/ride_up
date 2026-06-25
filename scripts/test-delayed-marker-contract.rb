#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative 'delayed-marker-contract'

root = Pathname.new(__dir__).parent.expand_path
baseline = root.join('app/src/main/java/com/foursquare/rideup/MainActivity.java').read
current_place_guard = "                if (!markerAnimationLifecycle.canAnimate()) {\n                    return;\n                }\n\n"
state_update = "                pickupMapState.updateCurrentPlace(\n"
request_map = "                requestMapReady();\n"
publish_location = "                publishMapLocation();\n"
map_ready_guard = "                if (!markerAnimationLifecycle.canAnimate()) {\n                    return;\n                }\n"
map_ready_assignment = "                MainActivity.this.mapboxMap = mapboxMap;\n"
map_ready_publication = "                publishMapLocation();\n"
permission_guard = "                if (locationServices.areLocationPermissionsGranted()) {\n                    mapboxMap.setMyLocationEnabled(true);\n                }\n"
pickup_return = "            mapboxMap.addMarker(new MarkerViewOptions()\n                    .position(location)\n                    .title(\"Pick Up Location\"));\n            return;\n"
schedule_call = "        scheduleCarPopulation();\n"
guard = "                if (!markerAnimationLifecycle.canAnimate() || pickupMapState.hasPickup()) {\n                    return;\n                }\n"
loop_start = "                for (int i = 0; i < 10; i++) {\n"

baseline_failures = DelayedMarkerContract.failures(baseline)
abort baseline_failures.join("\n") unless baseline_failures.empty?

mutations = {
  'missing current-place lifecycle guard' => baseline.sub(current_place_guard, ''),
  'current-place guard after state update' => baseline.sub(
    current_place_guard + state_update,
    state_update + current_place_guard
  ),
  'missing current-place map request' => baseline.sub(request_map, ''),
  'missing current-place publication' => baseline.sub(publish_location, ''),
  'missing map-ready lifecycle guard' => baseline.sub(
    map_ready_guard + map_ready_assignment, map_ready_assignment
  ),
  'map-ready guard after map assignment' => baseline.sub(
    map_ready_guard + map_ready_assignment,
    map_ready_assignment + map_ready_guard
  ),
  'map-ready publication before map assignment' => baseline.sub(
    map_ready_assignment + map_ready_publication,
    map_ready_publication + map_ready_assignment
  ),
  'map-ready schedules before location publication' => baseline.sub(
    permission_guard, permission_guard + "                scheduleCarPopulation();\n"
  ),
  'location layer enabled without permission guard' => baseline.sub(
    permission_guard, "                mapboxMap.setMyLocationEnabled(true);\n"
  ),
  'pickup publication falls through to car scheduling' => baseline.sub(
    pickup_return, pickup_return.sub("            return;\n", '')
  ),
  'missing current-place car scheduling' => baseline.sub(schedule_call, ''),
  'missing lifecycle guard' => baseline.sub(guard, ''),
  'inverted lifecycle guard' => baseline.sub(
    'if (!markerAnimationLifecycle.canAnimate())',
    'if (markerAnimationLifecycle.canAnimate())'
  ),
  'guard after marker loop' => baseline.sub(guard + loop_start, loop_start + guard),
  'guard after marker addition' => baseline.sub(
    guard + loop_start + "                    addRandomCar();\n",
    loop_start + "                    addRandomCar();\n" + guard
  )
}

mutations.each do |description, source|
  abort "#{description} mutation did not change the source" if source == baseline
  abort "#{description} mutation was accepted" if DelayedMarkerContract.failures(source).empty?
end

puts "Delayed marker population contract passed (#{mutations.length} mutations rejected)."
