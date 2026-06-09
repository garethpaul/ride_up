# Location Permission Startup Guard

## Status: Completed

## Context

`MainActivity.onCreate` requested runtime location permission when needed, but
still called `getClosestPlace()` before the permission request resolved. The
sample should wait until location access is already granted, or until
`onRequestPermissionsResult` receives a grant, before asking PlacePicker for the
current place.

## Objectives

- Preserve the existing startup map and PlacePicker setup.
- Keep the permission callback responsible for newly granted location access.
- Avoid fetching the closest place during startup when location permission is
  still pending.
- Add deterministic static validation for the startup permission guard.

## Work Completed

- Cached the startup location permission state in `MainActivity.onCreate`.
- Moved the startup `getClosestPlace()` call behind the granted-permission
  guard.
- Extended `scripts/check-android-contract.rb` to validate the guarded startup
  lookup and reject extra startup fetches.
- Updated README, VISION, and CHANGES notes for the permission startup guard.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make check`
- `git diff --check`

## Legacy Gradle Notes

This environment did not run the archived Android Gradle build by default.
`make check` still supports `RUN_LEGACY_GRADLE=1` on a machine with the matching
SDK 23-era dependencies.
