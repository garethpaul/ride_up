#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'android-manifest-contract'

class AndroidManifestContractTest < Minitest::Test
  VALID_MANIFEST = <<~XML
    <manifest xmlns:android="http://schemas.android.com/apk/res/android">
      <application>
        <service
          android:name="com.mapbox.mapboxsdk.telemetry.TelemetryService"
          android:exported="false" />
      </application>
    </manifest>
  XML

  def test_accepts_one_explicitly_non_exported_telemetry_service
    assert_empty AndroidManifestContract.telemetry_service_failures(VALID_MANIFEST)
  end

  def test_rejects_missing_telemetry_service
    failures = AndroidManifestContract.telemetry_service_failures(
      VALID_MANIFEST.sub(/\s*<service.*?<\/application>/m, "\n  </application>")
    )

    assert_includes failures, 'must declare exactly one Mapbox TelemetryService'
  end

  def test_rejects_implicit_export_policy
    failures = AndroidManifestContract.telemetry_service_failures(
      VALID_MANIFEST.sub(/\s+android:exported="false"/, '')
    )

    assert_includes failures, 'Mapbox TelemetryService must declare android:exported="false"'
  end

  def test_rejects_exported_telemetry_service
    failures = AndroidManifestContract.telemetry_service_failures(
      VALID_MANIFEST.sub('android:exported="false"', 'android:exported="true"')
    )

    assert_includes failures, 'Mapbox TelemetryService must declare android:exported="false"'
  end

  def test_rejects_duplicate_telemetry_service
    service = VALID_MANIFEST[/\s*<service.*?\/>/m]
    failures = AndroidManifestContract.telemetry_service_failures(
      VALID_MANIFEST.sub(service, service + service)
    )

    assert_includes failures, 'must declare exactly one Mapbox TelemetryService'
  end

  def test_rejects_malformed_or_conflicting_xml
    failures = AndroidManifestContract.telemetry_service_failures(
      VALID_MANIFEST.sub('/>', 'android:exported="true" />')
    )

    assert_match(/must be valid XML/, failures.first)
  end

  def test_wires_manifest_contract_into_repository_gates
    checker = File.read(File.expand_path('check-android-contract.rb', __dir__))
    makefile = File.read(File.expand_path('../Makefile', __dir__))

    assert_includes checker, 'AndroidManifestContract.telemetry_service_failures'
    assert_includes makefile, 'scripts/test-android-manifest-contract.rb'
  end
end
