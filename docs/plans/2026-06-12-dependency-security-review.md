# Legacy Android Dependency Security Review

Status: Completed

## Context

The SDK 23 application uses dependencies from 2015 and 2016. A full dependency
upgrade cannot be validated without the dedicated Android modernization pass,
but known advisories and safe compatibility overrides still need to be recorded.

## Review

- OSV reported no match for JUnit 4.13.2, AppCompat 23.2.0, PlacePicker 0.6.1,
  Glide 3.7.0, or Mapbox Android SDK 4.2.0-beta.5 as direct coordinates.
- PlacePicker 0.6.1 declares Gson 2.5, which is affected by CVE-2022-25647.
  The application now overrides it with binary-compatible Gson 2.8.9.
- The original application declared OkHttp 3.4.2, while Mapbox
  4.2.0-beta.5, Retrofit, and the logging interceptor requested OkHttp 3.3/3.4
  artifacts affected by CVE-2021-0341.
- The follow-up OkHttp security migration raises the app floor to API 21 and
  forces both `okhttp` and `logging-interceptor` to OkHttp 4.9.2. Debug and release
  resolution checks, lint, tests, dexing, and APK assembly validate the binary-
  compatible override while preserving the legacy Mapbox API.

## Verification

- OSV query batch for direct and reviewed transitive Maven coordinates
- Maven Central POM review for PlacePicker 0.6.1 and Mapbox 4.2.0-beta.5
- `make check`

## Remaining Risk

The known OkHttp 3.x CVE is removed from resolved app configurations, but the
legacy Mapbox beta, PlacePicker, SDK 23 target, and other archived dependencies
still require a broader modernization and emulator/device testing before this
sample should be treated as production-ready network software.
