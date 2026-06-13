# Telemetry Service Export Policy

## Status: Completed

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

## Work Completed

- Declared the existing Mapbox telemetry service explicitly non-exported.
- Added a structured XML contract for exact service identity and export state.
- Added seven dependency-free tests covering the valid declaration and all
  planned malformed, missing, implicit, exported, and duplicate cases.
- Wired the focused suite into the normal test and full verification paths.
- Updated README, security, vision, and change documentation.

## Verification

- `ruby scripts/check-android-contract.rb`
- Focused telemetry-service manifest mutations
- SDK-backed `make check`
- Debug and release merged-manifest inspection
- `git diff --check`

The focused manifest suite passed 7 tests and 16 assertions. SDK-backed
`make check` passed contracts, lint, unit tests, dependency resolution, dexing,
and debug/release APK assembly. Both merged manifests retained exactly one
Mapbox telemetry service with `android:exported="false"`.

## Scope Boundary

This change only makes the existing internal service boundary explicit. It
does not disable Mapbox telemetry, change network endpoints, or alter runtime
credentials.
