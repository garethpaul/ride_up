#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rexml/document'
require 'rexml/xpath'

module AndroidManifestContract
  TELEMETRY_SERVICE = 'com.mapbox.mapboxsdk.telemetry.TelemetryService'

  module_function

  def telemetry_service_failures(source)
    document = REXML::Document.new(source)
    services = REXML::XPath.match(document, '/manifest/application/service').select do |service|
      service.attributes['android:name'] == TELEMETRY_SERVICE
    end

    return ['must declare exactly one Mapbox TelemetryService'] unless services.length == 1
    return [] if services.first.attributes['android:exported'] == 'false'

    ['Mapbox TelemetryService must declare android:exported="false"']
  rescue REXML::ParseException => error
    ["must be valid XML: #{error.message.lines.first.strip}"]
  end
end
