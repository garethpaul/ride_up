# PlacePicker Result Guards

## Status: Completed

## Context

`MainActivity.onActivityResult` handles the Foursquare PlacePicker result and
immediately reads the result `Intent`, venue payload, and `mapboxMap`. Android
activity results can arrive with missing data, and the map can still be
initializing. The sample should ignore incomplete results instead of crashing or
mutating a map before it is ready.

## Objectives

- Preserve the existing pickup-location update for valid PlacePicker results.
- Ignore PlacePicker callbacks with null `Intent` data or missing venue data.
- Guard marker updates until Mapbox is initialized.
- Add deterministic static validation for those result-handling guards.

## Work Completed

- Added null checks for the PlacePicker result `Intent` and `Venue` payload.
- Wrapped map clearing and pickup marker creation in a `mapboxMap != null`
  guard.
- Extended `scripts/check-android-contract.rb` to require these result guards.
- Updated README, VISION, and CHANGES notes for the PlacePicker result guard.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Gradle Notes

This environment did not run the archived Android Gradle build by default.
`make check` still supports `RUN_LEGACY_GRADLE=1` on a machine with the matching
SDK 23-era dependencies.
