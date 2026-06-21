# frozen_string_literal: true

require 'rexml/document'

module LayoutResourceContract
  module_function

  EXPECTED_TEXT = {
    'textView2' => 'pickup_location_label',
    'pickUpTextView' => 'current_location_label',
    'ridexBtn' => 'ride_x_label',
    'rideluxBtn' => 'ride_lux_label',
    'ridebigBtn' => 'ride_big_label',
    'confirmBtn' => 'confirm_pickup_label'
  }.freeze

  EXPECTED_DESCRIPTIONS = {
    'imageView' => 'pickup_search_description',
    'icon' => 'ride_up_logo_description'
  }.freeze

  EXPECTED_VALUES = {
    'pickup_location_label' => 'PICKUP LOCATION',
    'current_location_label' => 'Current Location',
    'ride_x_label' => 'Ride X',
    'ride_lux_label' => 'RIDE LUX',
    'ride_big_label' => 'RIDE BIG',
    'confirm_pickup_label' => 'Confirm Pickup',
    'pickup_search_description' => 'Search pickup location',
    'ride_up_logo_description' => 'RideUp logo'
  }.freeze

  TEST_COMMAND = '$(RUBY) "$$ROOT/scripts/test-layout-resource-contract.rb"'

  def failures(strings_xml:, activity_xml:, action_bar_xml:, makefile_source:)
    documents = {
      'activity_main.xml' => parse(activity_xml, 'activity_main.xml'),
      'action_bar_custom.xml' => parse(action_bar_xml, 'action_bar_custom.xml')
    }
    strings = parse(strings_xml, 'strings.xml')
    parse_failures = documents.values.grep(String) + [strings].grep(String)
    return parse_failures unless parse_failures.empty?

    failures = []
    definitions = string_definitions(strings)

    EXPECTED_VALUES.each do |name, value|
      matches = definitions.fetch(name, [])
      failures << "@string/#{name} must be defined exactly once" unless matches.length == 1
      failures << "@string/#{name} must preserve #{value.inspect}" unless matches == [value]
    end

    EXPECTED_TEXT.each do |id, resource|
      require_attribute(failures, documents, id, 'text', "@string/#{resource}")
    end
    EXPECTED_DESCRIPTIONS.each do |id, resource|
      require_attribute(failures, documents, id, 'contentDescription', "@string/#{resource}")
    end

    failures << 'Makefile must run the layout resource contract' unless makefile_source.include?(TEST_COMMAND)
    failures
  end

  def parse(source, label)
    REXML::Document.new(source)
  rescue REXML::ParseException => error
    "#{label} must remain valid XML: #{error.message.lines.first.strip}"
  end

  def string_definitions(document)
    definitions = Hash.new { |hash, key| hash[key] = [] }
    document.root.elements.each('string') do |element|
      definitions[element.attributes['name']] << element.text.to_s.strip
    end
    definitions
  end

  def require_attribute(failures, documents, id, attribute_name, expected_value)
    matches = documents.values.flat_map { |document| elements_with_id(document, id) }
    if matches.length != 1
      failures << "@id/#{id} must exist exactly once"
      return
    end

    actual = android_attribute(matches.first, attribute_name)
    failures << "@id/#{id} android:#{attribute_name} must reference #{expected_value}" unless actual == expected_value
  end

  def elements_with_id(document, id)
    matches = []
    document.root.each_recursive do |element|
      matches << element if android_attribute(element, 'id') == "@+id/#{id}"
    end
    matches
  end

  def android_attribute(element, name)
    attribute = element.attributes.to_a.find do |candidate|
      candidate.prefix == 'android' && candidate.name == name
    end
    attribute&.value
  end
end
