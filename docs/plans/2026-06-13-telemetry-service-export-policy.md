# Telemetry Service Export Policy

## Status: In Progress

## Context

The app declares Mapbox's `TelemetryService` without an explicit
`android:exported` value. A service without an intent filter is implicitly
non-exported on this legacy target, but the security boundary depends on
platform default behavior and is not protected by the repository contract.

## Priority

Telemetry runs alongside location and network behavior. The service is an
internal SDK component and should not expose an external Android entry point.
Making that policy explicit improves reviewability and prevents a future
intent-filter or manifest-merge change from silently broadening access.

## Objectives

- Declare Mapbox `TelemetryService` with `android:exported="false"`.
- Require exactly one canonical telemetry service declaration.
- Reject missing, true, duplicate, or conflicting export declarations.
- Preserve the explicitly exported launcher activity and all existing SDK,
  dependency, permission, and packaging behavior.
- Verify the merged debug and release manifests through the SDK-backed gate.

## Planned Verification

- `ruby scripts/check-android-contract.rb`
- Focused telemetry-service manifest mutations
- SDK-backed `make check`
- Debug and release merged-manifest inspection
- `git diff --check`

## Scope Boundary

This change only makes the existing internal service boundary explicit. It
does not disable Mapbox telemetry, change network endpoints, or alter runtime
credentials.
