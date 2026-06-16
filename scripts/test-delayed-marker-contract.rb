#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative 'delayed-marker-contract'

root = Pathname.new(__dir__).parent.expand_path
baseline = root.join('app/src/main/java/com/foursquare/rideup/MainActivity.java').read
guard = "                                if (!markerAnimationLifecycle.canAnimate()) {\n                                    return;\n                                }\n"
loop_start = "                                for (int i = 0; i < 10; i++) {\n"

baseline_failures = DelayedMarkerContract.failures(baseline)
abort baseline_failures.join("\n") unless baseline_failures.empty?

mutations = {
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
