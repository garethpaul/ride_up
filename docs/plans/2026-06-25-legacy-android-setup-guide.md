# Legacy Android Setup Guide

## Status: Completed

## Context

The README provided a credential-template copy command but did not consolidate
the exact Android SDK, build-tools, Gradle, JDK, environment-variable,
credential, verification, and runtime-evidence boundaries.

## Work Completed

- Documented Android API 23, build-tools 28.0.3, AGP 3.3.2, Gradle 4.10.2, and
  the canonical JDK 8 SDK-backed environment.
- Documented `ANDROID_HOME`/`ANDROID_SDK_ROOT` ownership and the three local
  Mapbox/Foursquare constants.
- Distinguished SDK-free contracts, SDK-backed Gradle gates, temporary hosted
  placeholders, and emulator/device runtime evidence.
- Removed the completed setup-guide roadmap item and added durable contracts.

## Scope Boundary

- No source, manifest, dependency, wrapper, workflow, SDK, credential, or
  runtime behavior changes.
- No real credentials, precise locations, live provider calls, emulator run, or
  physical-device run.

## Verification

- The Ruby contract failed first for the missing guide, plan, links, facts, and
  stale roadmap item.
- Containerized SDK-free `make check` passed 77 Make authority cases, the static
  Android/manifest contracts, executable Java guards, and 53 existing mutations.
- Thirteen isolated hostile guide mutations rejected every toolchain,
  credential, verification, link, runtime-evidence, and roadmap promise.
- Exact-head hosted Android SDK and CodeQL gates remain required before merge.
