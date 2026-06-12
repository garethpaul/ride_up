# OkHttp 4.9.2 Security Migration

Status: Completed

## Context

Before this migration, the application and Mapbox 4.2.0-beta.5 resolved OkHttp
3.4.2, while Mapbox Java Services and its logging interceptor requested other
OkHttp 3.3/3.4 versions. That line is affected by CVE-2021-0341. OkHttp 4.9.2
contains the hostname-verification fix and is binary-compatible with libraries
built for OkHttp 3.x.

## Priority

This was the repository's remaining documented vulnerable network dependency.
The fixed OkHttp 4.x line requires Java 8 and Android API 21+, so the migration
must raise the application minimum from API 19 to 21 and prove that the legacy
Mapbox/Retrofit bytecode still resolves, dexes, lints, tests, and packages.

## Objectives

- Raise `minSdkVersion` from 19 to the OkHttp 4.x floor of 21.
- Align `okhttp` and `logging-interceptor` on version 4.9.2.
- Require the resolved debug and release graphs to contain no OkHttp 3.x or
  mismatched logging-interceptor artifact.
- Preserve compile/target SDK 23, Mapbox 4.2.0-beta.5, PlacePicker 0.6.1, AGP
  3.3.2, Gradle 4.10.2, and Java 8 in this focused security pass.
- Run unit tests, lint, dexing, and debug/release APK assembly with Android API
  23 and build-tools 28.0.3.
- Protect the dependency, API floor, resolution checks, documentation, and
  completed plan in the repository contract.

## Work Completed

- Raised `minSdkVersion` to 21 and aligned the direct OkHttp and logging
  interceptor dependencies on 4.9.2.
- Forced transitive `com.squareup.okhttp3` requests from Mapbox and Retrofit to
  the same fixed versions.
- Added `verifyOkHttpResolution`, which fails unless both debug and release
  runtime classpaths resolve exactly `logging-interceptor:4.9.2` and
  `okhttp:4.9.2`.
- Added dependency resolution and debug/release APK assembly to the normal
  `make check` gate, with static contracts protecting the migration.
- Updated the security, maintenance, vision, change, and dependency-review
  documentation to distinguish this fix from the remaining legacy SDK risk.

## Verification

- Debug and release `dependencyInsight` checks passed and showed all Mapbox,
  Retrofit, and logging-interceptor requests resolving to forced OkHttp 4.9.2.
- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk scripts/run-android-gradle.sh testDebugUnitTest lintDebug lintRelease assembleDebug assembleRelease`
  passed with Gradle 4.10.2, Android API 23, and build-tools 28.0.3.
- Debug and release lint, unit-test compilation/execution, D8 dexing, and APK
  packaging all completed successfully. D8 emitted non-fatal warnings for
  optional Conscrypt/Android 10 TLS classes and newer Java APIs referenced by
  dependencies; those warnings remain a modernization risk on the SDK 23
  toolchain rather than a packaging failure.
- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make check`
  passed the resolved graph checks, static contracts, executable guard tests,
  debug and release unit-test variants, lint, and both APK variants.
- Focused hostile mutations restoring direct OkHttp 3.4.2 or `minSdkVersion 19`
  were rejected by the contract checker with the expected vulnerable-version
  and Android API 21 minimum failures.
- `git diff --check` passed.

## Compatibility Basis

- OkHttp's official upgrade guide states that OkHttp 4.x jars are usable by
  applications and libraries built for OkHttp 3.x.
- OkHttp's official security documentation lists 4.x support on Android 5.0+
  (API 21+) and Java 8+.
- OkHttp's 4.x changelog records the CVE-2021-0341 fix in 4.9.2.
