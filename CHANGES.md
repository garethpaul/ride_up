# Changes

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
