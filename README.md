# ride_up

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/ride_up` is an Android application or sample. A ride sharing clone.

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The project language mix found during review was: Java (3), JavaScript (1).

## Repository Contents

- `README.md` - project overview and local usage notes
- `build.gradle` - Android or Gradle build configuration
- `app` - source or example code
- `gradle` - source or example code
- `gradlew` - Android or Gradle build configuration
- `javascripts` - source or example code
- `SECURITY.md` - security reporting and disclosure guidance
- `stylesheets` - source or example code
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: app, gradle, javascripts, stylesheets
- Dependency and build manifests: build.gradle, gradlew
- Entry points or build surfaces: Gradle build files
- Test-looking files: app/src/androidTest/java/com/foursquare/rideup/ExampleInstrumentedTest.java, app/src/test/java/com/foursquare/rideup/ExampleUnitTest.java

## Getting Started

### Prerequisites

- Git
- Android Studio or a compatible Android SDK
- Gradle or the checked-in Gradle wrapper when present

### Setup

```bash
git clone https://github.com/garethpaul/ride_up.git
cd ride_up
cp app/src/main/java/com/foursquare/rideup/Constants.java.example app/src/main/java/com/foursquare/rideup/Constants.java
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

Fill the copied `Constants.java` with local Mapbox and Foursquare credentials.
The real file is ignored by git; keep the checked-in `.example` file free of
secrets.

## Running or Using the Project

- Use Android Studio to open the project or run `./gradlew assembleDebug` when the Android SDK is configured.

## Testing and Verification

- `./gradlew test` or Android Studio's test runner when the SDK is configured
- `make verify` runs the static Android credential, manifest, application ID,
  and landing-page package-link contract check.
  Set `RUN_LEGACY_GRADLE=1` to also run the legacy Gradle wrapper on a machine
  with SDK 23 and the required archived Android Gradle plugin dependencies.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- Detected references to Foursquare, Mapbox. Keep API keys, OAuth credentials, tokens, and account-specific values in local configuration only.

## Security and Privacy Notes

- Review changes touching external API calls or credential-adjacent configuration; examples from the scan include app/build.gradle, app/src/androidTest/java/com/foursquare/rideup/ExampleInstrumentedTest.java, app/src/main/AndroidManifest.xml, app/src/main/java/com/foursquare/rideup/MainActivity.java, and 3 more.
- Review changes touching network requests, sockets, or service endpoints; examples from the scan include app/build.gradle, app/src/androidTest/java/com/foursquare/rideup/ExampleInstrumentedTest.java, app/src/main/AndroidManifest.xml, app/src/main/res/drawable/ic_directions_run_black_24dp.xml, and 6 more.
- Review changes touching mobile permissions or privacy-sensitive device data; examples from the scan include app/src/main/AndroidManifest.xml, app/src/main/java/com/foursquare/rideup/MainActivity.java, app/src/main/res/layout/activity_main.xml, gradlew, and 1 more.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include .travis.yml, app/src/main/AndroidManifest.xml, app/src/main/res/layout/action_bar_custom.xml, app/src/main/res/layout/activity_main.xml, and 5 more.

## Maintenance Notes

- This looks like a legacy Android project or sample. Expect Android SDK, Gradle, and support-library versions to matter.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
