# ride_up

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Device Preview

<!-- DEVICE-PREVIEW-IMAGE -->
![Device preview](docs/device-preview.svg)

## Overview

`garethpaul/ride_up` is an Android application or sample. A ride sharing clone.

This README is based on the checked-in source, manifests, scripts, and repository metadata. The Android application and its tests are Java; the legacy landing page also contains JavaScript.

## Repository Contents

- `README.md` - project overview and local usage notes
- `CHANGES.md` - maintenance history for Android contract checks
- `Makefile` - local verification entry points
- `build.gradle` - Android or Gradle build configuration
- `app` - source or example code
- `docs/plans` - completed maintenance plans for the current baseline
- `gradle` - source or example code
- `gradlew` - Android or Gradle build configuration
- `SETUP.md` - exact legacy SDK, credential, and verification boundaries
- `javascripts` - source or example code
- `plans` - historical implementation notes
- `scripts` - static Android contract validators
- `SECURITY.md` - security reporting and disclosure guidance
- `stylesheets` - source or example code
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: app, gradle, javascripts, stylesheets
- Dependency and build manifests: build.gradle, gradlew
- Entry points or build surfaces: Gradle build files
- Test files: `app/src/test/java/com/foursquare/rideup/RideUpGuardsTest.java`,
  `app/src/androidTest/java/com/foursquare/rideup/ExampleInstrumentedTest.java`,
  and the dependency-free harness under `scripts/java`

## Getting Started

### Prerequisites

- Git
- Android Studio or a compatible Android SDK
- Gradle or the checked-in Gradle wrapper when present
- Ruby and a JDK with `javac`/`java` for dependency-free contract and guard tests

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

Follow [`SETUP.md`](SETUP.md) for the exact Android API 23/build-tools 28.0.3,
AGP 3.3.2/Gradle 4.10.2, JDK 8, SDK-variable, credential, and runtime-evidence
boundaries.

## Running or Using the Project

- Use Android Studio to open the project or run `./gradlew assembleDebug` when the Android SDK is configured.

## Testing and Verification

- Make verification derives one canonical checked-in root, freezes Ruby and
  shell authority, and rejects direct derived-SDK, preload, or ambiguous
  Makefile overrides before or after the repository Makefile. See
  `docs/plans/2026-06-21-safe-make-authority.md`.
- `./gradlew test` or Android Studio's test runner when the SDK is configured
- `make test` runs both the static contracts and executable Java guard behavior
  tests without requiring an Android SDK.
- `make check` runs the static Android credential, manifest, launcher export,
  application ID, landing-page package-link, and local landing asset contract
  check.
  With an Android SDK configured, the same command also verifies the resolved
  OkHttp graph, runs Gradle lint and both unit-test variants, and assembles debug
  and release APKs. A temporary non-secret
  `Constants.java` is generated from the checked-in example only when local
  credentials are absent and is removed on every exit.
- The Android modernization plan records the current `compileSdkVersion 23` and
  `targetSdkVersion 23` baseline plus the wrapper, SDK, AndroidX, and emulator
  smoke-test sequence needed for a future revival pass.
- GitHub Actions installs Android API 23 and build-tools 28.0.3, selects
  Corretto 8, and runs the complete `make check` gate on Ubuntu 24.04.
- The compatibility bridge uses Android Gradle Plugin 3.3.2 and Gradle 4.10.2
  while preserving compile/target SDK 23 and all application dependency
  versions.
- The wrapper verifies the Gradle 4.10.2 all-distribution with the publisher's
  SHA-256 `b7aedd369a26b177147bcb715f8b1fc4fe32b0a6ade0d7fd8ee5ed0c6f731f2c`.
- The checked-in Gradle wrapper scripts and JAR match the Gradle 4.10.2 tagged
  wrapper artifacts. The wrapper JAR has SHA-256
  `f477f0a7223dd6c43391aeb91ffbb15de8f251f1782e847c2270fb7b55c24585`.
- `app/lint.xml` suppresses only the old lint engine's Gson module-descriptor
  failure and the separately tracked target-SDK expiration. Other findings
  remain visible in the lint report.
- The static checker requires completed canonical plans and truthful status for
  the active hosted-build plan under `docs/plans`.
- The Android manifest disables app backup so local credentials and
  location-adjacent state are not included in device backups.
- The static checker verifies the launcher activity explicitly declares its
  exported state.
- The Mapbox telemetry service is explicitly non-exported, and the structured
  manifest contract rejects missing, implicit, exported, or duplicate entries.
- The same structured manifest contract requires exactly one declaration of
  the four reviewed network and location permissions and rejects unnamed,
  nested, duplicate, missing, or unexpected permissions.
- The static checker verifies Java `R.drawable.*` references resolve to
  checked-in drawable resources.
- The static checker verifies landing-page local stylesheets, favicon, and
  screenshot assets resolve inside the repository.
- The static checker also verifies PlacePicker result handling guards null
  result data, missing venue and venue-location payloads, and map updates
  before Mapbox is ready. It also requires matching request and result codes
  before the callback consumes picker data.
- The static checker verifies current-place lookup starts only after an active
  resume and granted location permission.
- The static checker verifies the permission callback names the exact requested
  coarse/fine location set once, aligns names with results, and receives every
  grant before starting the current-place lookup.
- The static checker verifies non-location permission callbacks are forwarded
  to the superclass instead of being swallowed.
- The static checker verifies current-place callbacks ignore missing venue or
  venue-location payloads before reading coordinates.
- The static checker verifies MapView lifecycle callbacks guard missing map
  instances before forwarding lifecycle events.
- Current-place requests use lifecycle generations so callbacks from before a
  pause cannot publish coordinates or clear a newer resumed request. Paused
  callbacks remain retryable on the next active resume.
- Map-ready and delayed marker callbacks check activity lifecycle state before
  registering or mutating map work that may already be off-screen or destroyed.
- The guard behavior harness executes reordered, missing, unknown, duplicate,
  null, misaligned, partial, and complete permission callbacks plus matching
  and unrelated PlacePicker callback codes.
- The static checker verifies local IDE metadata stays ignored and untracked.

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
- PlacePicker's transitive Gson 2.5 is overridden with Gson 2.8.9 to address
  CVE-2022-25647.
- OkHttp and its logging interceptor are forced to OkHttp 4.9.2 to remove the
  resolved OkHttp 3.x versions affected by CVE-2021-0341. This raises the app's
  minimum Android version to API 21; the legacy Mapbox beta and SDK 23 stack
  still require broader modernization and emulator/device testing.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `docs/plans/2026-06-08-ride-up-baseline.md` for the canonical Android
  contract validation baseline.
- See `docs/plans/2026-06-08-android-backup-policy.md` for the app-backup
  privacy guard baseline.
- See `docs/plans/2026-06-08-drawable-reference-contract.md` for the Android
  drawable resource guard.
- See `docs/plans/2026-06-09-landing-asset-contract.md` for the landing-page
  local asset guard.
- See `docs/plans/2026-06-09-placepicker-result-guards.md` for the PlacePicker
  result-handling guard.
- See `docs/plans/2026-06-09-location-permission-startup-guard.md` for the
  startup location permission guard.
- See `docs/plans/2026-06-09-location-permission-result-guard.md` for the
  location permission callback guard.
- See `docs/plans/2026-06-09-permission-result-super-forwarding.md` for the
  non-location permission callback forwarding guard.
- See `docs/plans/2026-06-09-venue-location-guard.md` for the PlacePicker and
  current-place venue-location guard.
- See `docs/plans/2026-06-09-ide-metadata-ignore.md` for local IDE metadata
  ignore coverage.
- See `docs/plans/2026-06-09-launcher-export-contract.md` for the launcher
  activity exported-state contract.
- See `docs/plans/2026-06-13-telemetry-service-export-policy.md` for the
  internal Mapbox telemetry service boundary.
- See `docs/plans/2026-06-13-manifest-permission-allowlist.md` for the exact
  top-level Android permission boundary.
- See `docs/plans/2026-06-10-android-modernization-plan.md` for the Android
  modernization plan.
- See `docs/plans/2026-06-10-hosted-contract-validation.md` for the hosted
  structural validation boundary.
- See `docs/plans/2026-06-10-mapview-lifecycle-guard.md` for the MapView
  lifecycle forwarding guard.
- See `docs/plans/2026-06-10-placepicker-request-code-guard.md` for the
  PlacePicker activity-result routing guard.
- See `docs/plans/2026-06-12-pure-java-guard-tests.md` for executable guard
  behavior validation without an Android SDK.
- See `docs/plans/2026-06-12-dependency-security-review.md` for the OSV and
  Maven POM dependency review and applied Gson and OkHttp overrides.
- See `docs/plans/2026-06-12-okhttp-492-security-migration.md` for the resolved
  graph, API-floor, test, lint, dex, and APK verification evidence.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
