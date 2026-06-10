# MapView Lifecycle Guard

## Status: Completed

## Context

`MainActivity` forwards Android lifecycle callbacks to the Mapbox `MapView`.
The sample initializes `mapView` during `onCreate`, but legacy Android flows or
partial initialization failures can still call lifecycle methods before that
field is populated. Those callbacks should be safe no-ops when the view is
missing.

## Objectives

- Guard every `mapView` lifecycle forward behind a non-null check.
- Preserve the existing lifecycle ordering around superclass calls.
- Extend the SDK-free static checker so the guard cannot drift.
- Avoid dependency or Gradle modernization in this focused pass.

## Work Completed

- Added `mapView != null` guards around `onDestroy`, `onResume`, `onPause`,
  `onSaveInstanceState`, and `onLowMemory` forwarding.
- Extended `scripts/check-android-contract.rb` to validate those lifecycle
  guards.
- Updated README, VISION, CHANGES, and this completed plan.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make lint`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Gradle Notes

This environment used the default SDK-free static verification path. `make
check` still supports `RUN_LEGACY_GRADLE=1` on a machine with SDK 23 and the
required archived Android Gradle plugin dependencies.
