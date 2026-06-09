# Changes

## 2026-06-09

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
