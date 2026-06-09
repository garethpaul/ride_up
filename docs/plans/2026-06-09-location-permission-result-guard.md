# Location Permission Result Guard

## Status: Completed

## Context

`MainActivity` requests both coarse and fine location permissions before
starting the current-place lookup. The permission callback only inspected the
first result, so a partial grant could still start location-backed behavior.

## Objectives

- Require every requested location permission result to be granted before
  calling `getClosestPlace()`.
- Treat empty permission results as denied.
- Add deterministic static validation so the callback cannot regress to a
  first-result-only check.

## Work Completed

- Added `allLocationPermissionsGranted(int[])` with empty-result and per-result
  denial checks.
- Updated `onRequestPermissionsResult` to call the helper before fetching the
  closest place.
- Extended `scripts/check-android-contract.rb` to reject first-result-only
  permission checks.
- Updated README, VISION, and CHANGES notes for the permission-result guard.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Gradle Notes

This environment did not run the archived Android Gradle build by default.
`make check` still supports `RUN_LEGACY_GRADLE=1` on a machine with the matching
SDK 23-era dependencies.
