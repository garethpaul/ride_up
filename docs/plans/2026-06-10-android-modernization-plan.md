# Android Modernization Plan

Status: Completed

## Context

The sample is still pinned to the historical Android baseline:

- `compileSdkVersion 23`
- `targetSdkVersion 23`
- legacy Android Gradle plugin dependencies
- support libraries and Google Play services from the original era

That baseline is intentionally preserved for now because moving it safely
requires a dedicated compatibility pass rather than a small static-check change.

## Revival Path

- Pin a reproducible wrapper, JDK, Android Gradle plugin, and SDK installation.
- Raise compile and target SDK versions in one compatibility branch.
- Replace support libraries with AndroidX equivalents.
- Revalidate Mapbox and Foursquare SDK behavior after the dependency move.
- Run emulator smoke tests for launcher, permissions, PlacePicker selection,
  current-place lookup, and map marker rendering.

## Verification

- `make check`
