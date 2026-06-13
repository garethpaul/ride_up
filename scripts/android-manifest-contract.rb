#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rexml/document'
require 'rexml/xpath'

module AndroidManifestContract
  TELEMETRY_SERVICE = 'com.mapbox.mapboxsdk.telemetry.TelemetryService'
  EXPECTED_PERMISSIONS = %w[
    android.permission.ACCESS_NETWORK_STATE
    android.permission.ACCESS_COARSE_LOCATION
    android.permission.ACCESS_FINE_LOCATION
    android.permission.INTERNET
  ].freeze

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

  def permission_failures(source)
    document = REXML::Document.new(source)
    top_level = REXML::XPath.match(document, '/manifest/uses-permission')
    all_permissions = REXML::XPath.match(document, '//uses-permission')
    names = top_level.map { |permission| permission.attributes['android:name'] }
    failures = []

    failures << 'permissions must be declared only as top-level manifest elements' unless all_permissions == top_level
    failures << 'every uses-permission must declare android:name' if names.any?(&:nil?)

    EXPECTED_PERMISSIONS.each do |permission|
      failures << "must declare exactly one #{permission}" unless names.count(permission) == 1
    end

    unexpected = names.compact.uniq - EXPECTED_PERMISSIONS
    failures << "must not declare unexpected permissions: #{unexpected.sort.join(', ')}" unless unexpected.empty?
    failures
  rescue REXML::ParseException => error
    ["must be valid XML: #{error.message.lines.first.strip}"]
  end
end
