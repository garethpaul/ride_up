# Android Credential Contract

## Problem

The app requires Mapbox and Foursquare credentials through a local
`Constants.java`, but the repository did not include a safe template showing
which values are required. The legacy Gradle wrapper also depends on old Android
build artifacts that are not reliably available from current public repositories.

## TDD Evidence

1. Confirmed `./gradlew test` and `./gradlew assembleDebug` fail while resolving
   `com.android.tools.build:gradle:2.2.2` from the old public repository setup.
2. Added `scripts/check-android-contract.rb` and ran it before adding the
   template; it failed because `Constants.java.example` was missing.
3. Added the non-secret credential template and reran the verification gate.

## Verification

- `make lint`
- `make test`
- `make build`
- `make verify`
- `git diff --check`

The default `make test` and `make build` targets do not invoke the legacy Gradle
wrapper unless `RUN_LEGACY_GRADLE=1` is set, because this environment cannot
resolve the archived Android Gradle plugin and does not have the exact SDK 23
platform/build-tools combination.
