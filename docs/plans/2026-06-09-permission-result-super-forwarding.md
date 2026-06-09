# Permission Result Super Forwarding

## Status: Completed

## Context

`MainActivity` handles the app's location permission request code directly.
Other permission callbacks were silently ignored instead of being forwarded to
the superclass, which can interfere with framework or support-library handling
if new permission request paths are added later.

## Objectives

- Preserve the existing guarded location-permission flow.
- Forward non-location permission callbacks to the superclass.
- Add deterministic static validation so unrelated permission results are not
  swallowed.
- Avoid dependency or Android SDK modernization in this focused pass.

## Work Completed

- Added an `else` branch in `onRequestPermissionsResult` that calls
  `super.onRequestPermissionsResult(requestCode, permissions, grantResults)`.
- Extended `scripts/check-android-contract.rb` to require superclass forwarding
  for non-location permission results.
- Updated README, VISION, and CHANGES notes for the permission callback guard.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make lint`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Gradle Notes

This environment did not run the archived Android Gradle build by default.
`make check` still supports `RUN_LEGACY_GRADLE=1` on a machine with the matching
SDK 23-era dependencies.
