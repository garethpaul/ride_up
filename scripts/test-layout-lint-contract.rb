#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative 'layout-lint-contract'

root = Pathname.new(__dir__).parent.expand_path
baseline = {
  activity_xml: root.join('app/src/main/res/layout/activity_main.xml').read,
  alert_xml: root.join('app/src/main/res/values/alert_custom.xml').read,
  makefile_source: root.join('Makefile').read
}

def failures(inputs)
  LayoutLintContract.failures(**inputs)
end

def mutate_element(source, id)
  marker = "android:id=\"@+id/#{id}\""
  marker_index = source.index(marker)
  abort "fixture is missing #{marker}" unless marker_index

  element_start = source.rindex('<', marker_index)
  element_end = source.index('/>', marker_index)
  abort "fixture element @id/#{id} is not self-closing" unless element_start && element_end

  element = source[element_start..(element_end + 1)]
  replacement = yield(element)
  source[0...element_start] + replacement + source[(element_end + 2)..]
end

baseline_failures = failures(baseline)
abort baseline_failures.join("\n") unless baseline_failures.empty?

mutations = {
  'invalid confirm-button weight' => baseline.merge(
    activity_xml: mutate_element(baseline[:activity_xml], 'confirmBtn') do |element|
      element.sub(
        'android:layout_width="0dp"',
        "android:layout_weight=\"-1\"\n                android:layout_width=\"0dp\""
      )
    end
  ),
  'undersized pickup label' => baseline.merge(
    activity_xml: baseline[:activity_xml].sub('android:textSize="12sp"', 'android:textSize="11sp"')
  ),
  'density-pixel alert text' => baseline.merge(
    alert_xml: baseline[:alert_xml].sub('>22sp<', '>22dp<')
  ),
  'physical left alignment' => baseline.merge(
    activity_xml: mutate_element(baseline[:activity_xml], 'confirmBtn') do |element|
      element.sub(
        'android:layout_alignParentStart="true"',
        "android:layout_alignParentStart=\"true\"\n                android:layout_alignParentLeft=\"true\""
      )
    end
  ),
  'physical right alignment' => baseline.merge(
    activity_xml: mutate_element(baseline[:activity_xml], 'confirmBtn') do |element|
      element.sub(
        'android:layout_alignParentEnd="true"',
        "android:layout_alignParentEnd=\"true\"\n                android:layout_alignParentRight=\"true\""
      )
    end
  ),
  'missing logical start alignment' => baseline.merge(
    activity_xml: mutate_element(baseline[:activity_xml], 'confirmBtn') do |element|
      element.sub(/\s+android:layout_alignParentStart="true"/, '')
    end
  ),
  'missing logical end alignment' => baseline.merge(
    activity_xml: mutate_element(baseline[:activity_xml], 'confirmBtn') do |element|
      element.sub(/\s+android:layout_alignParentEnd="true"/, '')
    end
  ),
  'unregistered focused test' => baseline.merge(
    makefile_source: baseline[:makefile_source].sub("\t#{LayoutLintContract::TEST_COMMAND}\n", '')
  )
}

mutations.each do |description, inputs|
  abort "#{description} mutation was accepted" if failures(inputs).empty?
end

puts "Layout lint contract passed (#{mutations.length} mutations rejected)."
