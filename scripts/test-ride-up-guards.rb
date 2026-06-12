#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'pathname'
require 'tmpdir'

root = Pathname.new(__dir__).parent.expand_path
sources = [
  root.join('app/src/main/java/com/foursquare/rideup/RideUpGuards.java'),
  root.join('scripts/java/com/foursquare/rideup/RideUpGuardsContractTest.java')
]

Dir.mktmpdir('ride-up-guards') do |output|
  compile_output, compile_status = Open3.capture2e(
    'javac', '-source', '8', '-target', '8', '-d', output, *sources.map(&:to_s)
  )
  abort compile_output unless compile_status.success?

  test_output, test_status = Open3.capture2e(
    'java', '-cp', output, 'com.foursquare.rideup.RideUpGuardsContractTest'
  )
  abort test_output unless test_status.success?

  print test_output
end
