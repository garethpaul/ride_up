# Changes

## 2026-06-12

- Restored local and hosted Android compilation with AGP 3.3.2, Gradle 4.10.2,
  build-tools 28.0.3, scoped legacy lint handling, and temporary non-secret
  credential placeholders that are removed after every Gradle invocation.
- Added executable Java guard behavior tests for PlacePicker request routing
  and complete location permission grants without requiring an Android SDK.
- Required location permission callbacks to return the exact requested
  coarse/fine permission set once with aligned granted results.
- Pinned hosted Corretto setup, disabled persisted checkout credentials, and
  upgraded the future Gradle test dependency to JUnit 4.13.2.
- Overrode PlacePicker's vulnerable Gson 2.5 dependency with Gson 2.8.9 and
  recorded the unresolved legacy Mapbox/OkHttp CVE-2021-0341 risk.

## 2026-06-10

- Added an Android modernization plan that records the SDK 23 baseline and the
  wrapper, SDK, AndroidX, and emulator smoke-test path for a dedicated revival
  pass.
- Required matching PlacePicker request and result codes before consuming
  venue data, with superclass forwarding for unrelated activity results.
- Guarded MapView lifecycle forwarding when the map view has not been
  initialized.
- Replaced the obsolete Travis Android configuration with dependency-free
  GitHub Actions contract validation.
- Made `make check` independent of the caller's current directory.
- Added fail-closed workflow pinning and hosted validation plan checks.

## 2026-06-09

- Declared the launcher activity exported state explicitly and added static
  validation for that manifest contract.
- Removed tracked IntelliJ `.idea` metadata and added static checker coverage
  for local IDE ignore rules.
- Forwarded non-location permission callbacks to the superclass and added
  static validation so unrelated permission results are not swallowed.
- Guarded PlacePicker and current-place venue locations before reading
  coordinates, with static validation for both paths.
- Required every requested location permission to be granted before the
  permission callback starts the current-place lookup.
- Deferred startup current-place lookup until location permission is already
  granted and added static validation for that flow.
- Guarded PlacePicker result handling against null result data, missing venue
  payloads, and map updates before Mapbox is ready.
- Added static validation for landing-page local asset references so checked-in
  stylesheets, favicon, and screenshots cannot drift or escape the repository.

## 2026-06-08

- Replaced a missing PlacePicker image placeholder drawable reference and
  added static drawable reference validation.
- Disabled Android app backup and added static validation for the manifest
  backup policy.
- Added a static Android contract check for the local credential template,
  ignored `Constants.java`, HTTPS repository URLs, and required permissions.
- Added `Constants.java.example` with non-secret placeholders for Mapbox and
  Foursquare credentials.
- Documented the local credential setup and `make verify`/`make check` commands.
- Added Google Maven and switched the Sonatype repository URL to HTTPS in the
  legacy Gradle configuration.
- Aligned the Gradle `applicationId` with the manifest package and landing-page
  Play link, and added static validation for that contract.
- Added canonical `docs/plans` coverage and made the Android contract checker
  require completed plans.
