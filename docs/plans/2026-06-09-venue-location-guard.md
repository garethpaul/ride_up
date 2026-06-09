# Venue Location Guard

## Status: Completed

## Context

`MainActivity` already ignored empty PlacePicker result data and missing venue
payloads. It still read `getLocation().getLat()` and `getLocation().getLng()`
from PlacePicker and current-place venues without checking that the venue
location object was present.

## Objectives

- Ignore current-place callbacks that return no venue or no venue location.
- Ignore PlacePicker results that return a venue without location data.
- Preserve the existing marker and camera updates when valid coordinates are
  available.
- Add static validation so venue-coordinate reads stay guarded.

## Work Completed

- Added current-place guards for null `Venue` and null `Venue.getLocation()`.
- Added a PlacePicker result guard for null `place.getLocation()`.
- Extended `scripts/check-android-contract.rb` to require both venue-location
  guards.
- Updated README, VISION, and CHANGES notes for the coordinate guard.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Gradle Notes

This environment did not run the archived Android Gradle build by default.
`make check` still supports `RUN_LEGACY_GRADLE=1` on a machine with the matching
SDK 23-era dependencies.
