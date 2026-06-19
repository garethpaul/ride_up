# Gradle Distribution Checksum

## Status: Completed

## Context

The maintained build bridge uses the checked-in Gradle wrapper with Gradle
4.10.2, but `gradle-wrapper.properties` identified only the distribution URL
and the checked-in wrapper scripts and JAR were still the Gradle 2.10 bootstrap.
Gradle 4.10.2 supports `distributionSha256Sum`, so the wrapper can verify the
downloaded archive before executing it once the wrapper files themselves are
brought to the matching tagged artifacts.

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
- R4. Make the dependency-free checker reject changed wrapper script or JAR
  checksums.
- R5. Document the verified wrapper boundary and digest source.
- R6. Preserve Android versions, dependencies, application source, and runtime
  behavior.
- R7. Record completed local and hosted verification before this plan is marked
  completed.

## Scope Boundaries

- Do not upgrade Gradle, AGP, the Android SDK baseline, or app dependencies.
- Do not claim that the wrapper checks establish provenance for application
  dependencies.

## Verification Plan

- Fetch the publisher checksum from
  `https://services.gradle.org/distributions/gradle-4.10.2-all.zip.sha256` and
  compare it with the committed property.
- Compare `gradlew`, LF-normalized `gradlew.bat`, and
  `gradle/wrapper/gradle-wrapper.jar` with the Gradle 4.10.2 tagged wrapper
  artifact SHA-256 values.
- Run `ruby scripts/check-android-contract.rb` and `make check`.
- Reject focused mutations that remove, duplicate, or alter the distribution
  URL, distribution checksum, or wrapper JAR checksum.
- Run `git diff --check` and screen the intended diff for credential material.
- Require the canonical hosted push, pull-request, and CodeQL checks to succeed
  on the exact final head.

## Work Completed

- Added the publisher-provided digest as the wrapper's
  `distributionSha256Sum` while preserving the Gradle 4.10.2 all-distribution
  URL.
- Replaced the checked-in Gradle 2.10 wrapper scripts and JAR with the Gradle
  4.10.2 tagged wrapper artifacts.
- Strengthened the dependency-free checker to require exactly one canonical
  URL, checksum property, and wrapper file checksums, rejecting missing,
  duplicated, or changed values.
- Documented the verified distribution and wrapper-JAR boundary plus the
  separate dependency provenance boundary in README, SECURITY, and CHANGES.

## Verification

- The official Gradle checksum endpoint returned
  `b7aedd369a26b177147bcb715f8b1fc4fe32b0a6ade0d7fd8ee5ed0c6f731f2c`,
  matching the committed property.
- The checked-in wrapper files match the Gradle 4.10.2 tagged artifacts:
  `gradlew` SHA-256
  `cf139290d3b7334cc99b58ecb6adc549c59ecb8f1f4162b122ad4590ead7585e`,
  LF-normalized `gradlew.bat` SHA-256
  `e2be4de6240d7090ebcec955ab713f9aa05fb0252e57d374ef7e7795e6306bdf`,
  and `gradle-wrapper.jar` SHA-256
  `f477f0a7223dd6c43391aeb91ffbb15de8f251f1782e847c2270fb7b55c24585`.
- `ruby scripts/check-android-contract.rb` passed.
- SDK-backed `make check` passed scoped lint, the dependency-free behavior
  harness, both Gradle unit-test variants, dexing, and debug APK assembly with
  Android API 23 and build-tools 28.0.3.
- Six focused hostile wrapper mutations were rejected for missing, duplicated,
  and changed distribution URL and checksum properties.
- Ruby syntax validation and `git diff --check` passed.
- Implementation head `1f7ab6c5d88be67737b65170e449447f9facaf93`
  passed push Check run `27436088453`, pull-request Check run `27436089863`,
  and CodeQL run `27436088207` for Actions, Java/Kotlin,
  JavaScript/TypeScript, and Ruby.
- Pull request #2 was open, clean, and mergeable at that implementation head
  with all seven hosted checks successful.
