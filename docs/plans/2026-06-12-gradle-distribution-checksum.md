# Gradle Distribution Checksum

## Status: Completed

## Context

The maintained build bridge uses the checked-in Gradle wrapper with Gradle
4.10.2, but `gradle-wrapper.properties` identifies only the distribution URL.
Gradle 4.10.2 supports `distributionSha256Sum`, so the wrapper can verify the
downloaded archive before executing it.

## Priority

The Android build already depends on an immutable compatibility version. Adding
the publisher-provided digest closes the remaining direct wrapper download
integrity gap without forcing an unrelated legacy Android toolchain upgrade.

## Requirements

- R1. Keep the exact Gradle 4.10.2 all-distribution URL required by AGP 3.3.2.
- R2. Add the official SHA-256 digest published by the Gradle distribution
  service.
- R3. Make the dependency-free checker reject a missing, duplicated, or changed
  URL or digest property.
- R4. Document the verified wrapper boundary and digest source.
- R5. Preserve the wrapper JAR, Android versions, dependencies, application
  source, and runtime behavior.
- R6. Record completed local and hosted verification before this plan is marked
  completed.

## Scope Boundaries

- Do not upgrade Gradle, AGP, the Android SDK baseline, or app dependencies.
- Do not replace or regenerate `gradle-wrapper.jar`.
- Do not claim that the checksum establishes provenance for the checked-in
  wrapper JAR or any application dependency.

## Verification Plan

- Fetch the publisher checksum from
  `https://services.gradle.org/distributions/gradle-4.10.2-all.zip.sha256` and
  compare it with the committed property.
- Run `ruby scripts/check-android-contract.rb` and `make check`.
- Reject focused mutations that remove, duplicate, or alter the distribution
  URL or checksum.
- Run `git diff --check` and screen the intended diff for credential material.
- Require the canonical hosted push, pull-request, and CodeQL checks to succeed
  on the exact final head.

## Work Completed

- Added the publisher-provided digest as the wrapper's
  `distributionSha256Sum` while preserving the Gradle 4.10.2 all-distribution
  URL.
- Strengthened the dependency-free checker to require exactly one canonical
  URL and checksum property, rejecting missing, duplicated, or changed values.
- Documented the verified distribution boundary and the separate wrapper-JAR
  and dependency provenance boundary in README, SECURITY, and CHANGES.

## Verification

- The official Gradle checksum endpoint returned
  `b7aedd369a26b177147bcb715f8b1fc4fe32b0a6ade0d7fd8ee5ed0c6f731f2c`,
  matching the committed property.
- `ruby scripts/check-android-contract.rb` passed.
- SDK-backed `make check` passed scoped lint, the dependency-free behavior
  harness, both Gradle unit-test variants, dexing, and debug APK assembly with
  Android API 23 and build-tools 28.0.3.
- Six focused hostile wrapper mutations were rejected for missing, duplicated,
  and changed distribution URL and checksum properties.
- Ruby syntax validation and `git diff --check` passed.
- Hosted verification for the implementation head is pending and will be
  replaced with exact run identifiers before delivery is considered final.
