# Android Backup Policy

## Status: Completed

## Context

`ride_up` keeps Mapbox and Foursquare credentials in a local ignored
`Constants.java` file and requests location permissions for the Mapbox and
PlacePicker flow. The manifest still allowed Android app backup, which is not a
safe default for a sample with local credentials and location-adjacent state.

## Objectives

- Disable Android app backup in the manifest.
- Extend the static Android contract checker to keep backup disabled.
- Preserve the existing credential template, application ID, and docs-plan
  checks.
- Keep legacy Gradle execution opt-in behind `RUN_LEGACY_GRADLE=1`.

## Work Completed

- Set `android:allowBackup="false"` in `app/src/main/AndroidManifest.xml`.
- Added manifest backup-policy validation to
  `scripts/check-android-contract.rb`.
- Updated README, VISION, and CHANGES.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Document emulator/runtime expectations for Mapbox and Foursquare credentials.
- Run the legacy Gradle build on a machine with SDK 23 and archived plugin
  dependencies available.
