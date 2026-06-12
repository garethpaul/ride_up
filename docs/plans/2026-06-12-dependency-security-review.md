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
- The application declares OkHttp 3.4.2, and Mapbox 4.2.0-beta.5 declares
  OkHttp 3.4.1. Both are affected by CVE-2021-0341. OSV identifies OkHttp 4.9.2
  as the fixed line, but that upgrade changes the Android compatibility floor
  and must be validated with the Mapbox and SDK modernization work.

## Verification

- OSV query batch for direct and reviewed transitive Maven coordinates
- Maven Central POM review for PlacePicker 0.6.1 and Mapbox 4.2.0-beta.5
- `make check`

## Remaining Risk

Do not treat this legacy sample as production-ready network software until the
Mapbox/OkHttp stack is upgraded and exercised on an emulator or device.
