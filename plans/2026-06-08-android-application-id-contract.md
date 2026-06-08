# Android Application ID Contract

## Status

Completed

## Context

The Android manifest and Java sources use `com.foursquare.rideup`, and the
landing page links to the same package ID in Google Play. The Gradle
`applicationId` still uses the stale sample value `com.example.gpj.mrjitters`,
which makes build metadata disagree with the rest of the project.

## Objectives

- Align `app/build.gradle` with the manifest package ID.
- Extend the static Android contract check to validate manifest package,
  Gradle `applicationId`, and landing-page Play link agreement.
- Keep credential handling and legacy Gradle behavior unchanged.

## Verification

- `make lint`
- `make verify`
- `git diff --check`
