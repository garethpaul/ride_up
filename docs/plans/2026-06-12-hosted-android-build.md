# Hosted Android Build

## Status: Implementation Complete; Hosted Verification Pending

## Context

The source and pure-Java contracts pass, but the opt-in Android gate cannot
resolve Android Gradle Plugin 2.2.2 from its retired repositories. API 23 and
build-tools 23.0.2 are still installable, but the plugin artifact is not
published at Maven Central, Google Maven, or JCenter.

Disposable-clone probes established a viable compatibility floor:

- AGP 3.0.1 with Gradle 4.1 resolves dependencies and compiles source/tests,
  but desugaring cannot read Gson 2.8.9's Java 9 module descriptor.
- AGP 3.2.1 with Gradle 4.6 compiles and tests the app, but debug dexing still
  crashes on Gson 2.8.9's Java 9 module descriptor.
- AGP 3.3.2 with Gradle 4.10.2 and build-tools 28.0.3 completes debug assembly
  and both unit-test variants while preserving compile/target SDK 23.
- AGP 3.3.2 lint requires narrow `LintError` handling for Gson's module
  descriptor and `ExpiredTargetSdkVersion` handling until the separate AndroidX
  and target-SDK modernization plan is executed.
- Compilation requires the ignored local `Constants.java`; the checked-in
  `.example` placeholders are sufficient for non-runtime CI builds.

## Goal

Restore repeatable local and hosted Android compilation without adding secrets,
downgrading security overrides, or changing RideUp runtime behavior.

## Changes

- Upgrade only the build bridge to AGP 3.3.2, Gradle 4.10.2, and build-tools
  28.0.3 while keeping compile/target SDK 23 and Java 8.
- Replace obsolete dependency configurations with `implementation` and
  `testImplementation` without changing resolved versions.
- Add a guarded Gradle runner that copies the non-secret credential example
  only when local `Constants.java` is absent and removes the generated copy on
  every exit.
- Scope lint suppression to the Gson module-descriptor tooling bug and deferred
  target-SDK migration; keep all other lint findings visible.
- Install API 23/build-tools 28.0.3 and run the complete gate in GitHub Actions.
- Extend contracts, documentation, and ownership to protect the bridge.

## Verification

- Run source and pure-Java guards without an Android SDK.
- Run SDK-backed Gradle tests, lint, and debug assembly locally.
- Repeat the complete gate from a fresh external clone.
- Reject focused toolchain, credential-fixture, lint, workflow, documentation,
  and plan-evidence mutations.
- Pass exact-head hosted verification before completion.

## Verification Evidence

- SDK-free `make check` passed, including the Android contracts and executable
  pure-Java guard behavior tests.
- SDK-backed `make check` passed with Android API 23 and build-tools 28.0.3,
  including lint, debug and release unit-test variants, dexing, and debug APK
  assembly.
- The complete SDK-backed gate passed from a fresh external clone with the
  staged patch applied.
- The credential runner removed its generated placeholder after successful and
  failed Gradle commands and preserved a pre-existing local credential file.
- All 28 focused toolchain, dependency, workflow, runner, lint, ownership,
  documentation, and plan mutations were rejected.
- Initial push run `27403373400` and pull-request run `27403374077` failed
  before project verification because current `sdkmanager` requires Java 17
  while the workflow had already selected Java 8. SDK installation now runs on
  the hosted default JDK before Corretto 8 is selected for Gradle.
- Exact-head hosted verification remains pending.

## Boundaries

- Do not commit real Mapbox or Foursquare credentials.
- Do not downgrade Gson 2.8.9 or other existing security overrides.
- Do not change app permissions, lifecycle, PlacePicker, map, or ride behavior.
- Do not migrate AndroidX, compile SDK, target SDK, or application APIs here.
