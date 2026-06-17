#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative 'layout-resource-contract'

root = Pathname.new(__dir__).parent.expand_path
baseline = {
  strings_xml: root.join('app/src/main/res/values/strings.xml').read,
  activity_xml: root.join('app/src/main/res/layout/activity_main.xml').read,
  action_bar_xml: root.join('app/src/main/res/layout/action_bar_custom.xml').read,
  makefile_source: root.join('Makefile').read
}

def failures(inputs)
  LayoutResourceContract.failures(**inputs)
end

baseline_failures = failures(baseline)
abort baseline_failures.join("\n") unless baseline_failures.empty?

mutations = {
  'hardcoded pickup label' => baseline.merge(
    activity_xml: baseline[:activity_xml].sub('@string/pickup_location_label', 'PICKUP LOCATION')
  ),
  'missing pickup search description' => baseline.merge(
    activity_xml: baseline[:activity_xml].sub(/\s+android:contentDescription="@string\/pickup_search_description"/, '')
  ),
  'missing action-bar logo description' => baseline.merge(
    action_bar_xml: baseline[:action_bar_xml].sub(/\s+android:contentDescription="@string\/ride_up_logo_description"/, '')
  ),
  'missing string definition' => baseline.merge(
    strings_xml: baseline[:strings_xml].sub(/\s*<string name="ride_big_label">.*?<\/string>/, '')
  ),
  'blank string definition' => baseline.merge(
    strings_xml: baseline[:strings_xml].sub(
      '<string name="confirm_pickup_label">Confirm Pickup</string>',
      '<string name="confirm_pickup_label"></string>'
    )
  ),
  'incorrect button resource' => baseline.merge(
    activity_xml: baseline[:activity_xml].sub('@string/ride_lux_label', '@string/ride_x_label')
  ),
  'unregistered focused test' => baseline.merge(
    makefile_source: baseline[:makefile_source].sub("\t#{LayoutResourceContract::TEST_COMMAND}\n", '')
  )
}

mutations.each do |description, inputs|
  abort "#{description} mutation was accepted" if failures(inputs).empty?
end

puts "Layout resource contract passed (#{mutations.length} mutations rejected)."
