# frozen_string_literal: true

require 'rexml/document'

module LayoutLintContract
  module_function

  TEST_COMMAND = '$(RUBY) "$$ROOT/scripts/test-layout-lint-contract.rb"'

  def failures(activity_xml:, alert_xml:, makefile_source:)
    activity = parse(activity_xml, 'activity_main.xml')
    alert = parse(alert_xml, 'alert_custom.xml')
    parse_failures = [activity, alert].grep(String)
    return parse_failures unless parse_failures.empty?

    failures = []
    pickup_label = exactly_one_with_id(failures, activity, 'textView2')
    confirm_button = exactly_one_with_id(failures, activity, 'confirmBtn')

    validate_pickup_label(failures, pickup_label) if pickup_label
    validate_confirm_button(failures, confirm_button) if confirm_button
    validate_alert_text_size(failures, alert)

    unless makefile_source.include?(TEST_COMMAND)
      failures << 'Makefile must run the layout lint contract'
    end

    failures
  end

  def parse(source, label)
    REXML::Document.new(source)
  rescue REXML::ParseException => error
    "#{label} must remain valid XML: #{error.message.lines.first.strip}"
  end

  def exactly_one_with_id(failures, document, id)
    matches = []
    document.root.each_recursive do |element|
      matches << element if android_attribute(element, 'id') == "@+id/#{id}"
    end
    failures << "@id/#{id} must exist exactly once" unless matches.length == 1
    matches.first if matches.length == 1
  end

  def validate_pickup_label(failures, element)
    text_size = android_attribute(element, 'textSize')
    match = text_size&.match(/\A(\d+(?:\.\d+)?)sp\z/)
    unless match && match[1].to_f >= 12
      failures << '@id/textView2 android:textSize must be at least 12sp'
    end
  end

  def validate_confirm_button(failures, element)
    failures << '@id/confirmBtn must not declare android:layout_weight' if android_attribute(element, 'layout_weight')

    %w[layout_alignParentLeft layout_alignParentRight].each do |attribute|
      failures << "@id/confirmBtn must not declare android:#{attribute}" if android_attribute(element, attribute)
    end

    %w[layout_alignParentStart layout_alignParentEnd].each do |attribute|
      unless android_attribute(element, attribute) == 'true'
        failures << "@id/confirmBtn android:#{attribute} must remain true"
      end
    end
  end

  def validate_alert_text_size(failures, document)
    styles = document.root.get_elements('style').select do |style|
      style.attributes['name'] == 'AlertDialogCustom'
    end
    if styles.length != 1
      failures << 'AlertDialogCustom style must exist exactly once'
      return
    end

    text_sizes = styles.first.get_elements('item').select do |item|
      item.attributes['name'] == 'android:textSize'
    end
    unless text_sizes.length == 1 && text_sizes.first.text.to_s.strip == '22sp'
      failures << 'AlertDialogCustom android:textSize must remain 22sp'
    end
  end

  def android_attribute(element, name)
    attribute = element.attributes.to_a.find do |candidate|
      candidate.prefix == 'android' && candidate.name == name
    end
    attribute&.value
  end
end
