# Changes

## 2026-06-26 - P1 - Generation-bind current-place requests

### Summary

Prevented current-place callbacks from before a pause from being lost
permanently or clearing a newer resumed request.

### Work completed

- Added a Java 7-compatible request controller with monotonically increasing
  generations, one active request, retryable failure, and resolved-state
  suppression.
- Moved initial current-place lookup from `onCreate()` to active `onResume()`
  behind granted location permission.
- Invalidated the active generation before pause and rejected stale, paused,
  and post-pickup callbacks before storing coordinates.
- Added SDK-free and Android unit contracts plus static lifecycle mutations.

### Validation

- RED: the controller contract could not compile before the production class
  existed, demonstrating the missing generation boundary.
- GREEN: the focused Java 7 controller test passed.
- Containerized portable `make check` passed 77 Make authority cases, Android
  and manifest contracts, five SDK-free Java behavior suites, 16 pickup-map
  static plus seven executable mutations, 19 lifecycle mutations, and 15
  layout mutations.
- Four isolated controller mutations were rejected across invalidation, stale
  completion, resolved suppression, and stale failure ownership.
- Implementation head `2ca59dc6110a2012a02d9ab71ddf6565459e9b9a`
  passed both hosted `check` jobs, all four CodeQL language analyses, and the
  CodeQL aggregate gate on pull request #14.
- Required Codex review was attempted against `origin/master` and stopped
  before analysis because both WebSocket and HTTPS transports returned OpenAI
  HTTP 401. Immutable local, remote, and pull-request heads matched, and the
  manual fallback review found no actionable defects.

## 2026-06-26 06:18 - P2 - Document legacy Android setup

### Summary

Closed the SDK and provider-credential setup roadmap item with one exact,
contract-enforced legacy environment guide.

### Work completed

- Documented API 23/build-tools 28.0.3, AGP 3.3.2/Gradle 4.10.2, and JDK 8.
- Documented local SDK variables and the three ignored Mapbox/Foursquare values.
- Separated SDK-free checks, SDK-backed builds, temporary hosted placeholders,
  and emulator/device runtime evidence.
- Linked the guide from README/security docs and removed the completed priority.

### Threads

- Started: legacy Android setup guide.
- Continued: continuous open-source maintenance loop.
- Stopped: none.

### Files changed

- `SETUP.md` — toolchain, credentials, gates, and runtime boundaries.
- `README.md`, `SECURITY.md`, `VISION.md` — links and roadmap state.
- `scripts/check-android-contract.rb` — durable setup contract.
- `docs/plans/2026-06-25-legacy-android-setup-guide.md` — completed plan.
- `CHANGES.md` — this cycle record.

### Validation

- Red Ruby contract — failed for every missing guide requirement before docs.
- Containerized SDK-free `make check` — passed 77 Make authority cases, static
  Android/manifest contracts, executable Java guards, and 53 existing mutations.
- Thirteen isolated setup-guide mutations — all rejected across toolchain,
  credential, verification, link, runtime-evidence, and roadmap promises.
- SDK-backed and hosted Android results pending.

### Bugs / findings

- P2: Setup facts were scattered and did not distinguish compile placeholders
  from valid provider runtime credentials.
- P2: Generic Android Studio guidance omitted the canonical JDK 8 and exact SDK
  package boundary required by the legacy Gradle bridge.

### Blockers

- This host has no Ruby or Android SDK; Ruby runs in the reviewed container and
  SDK-backed behavior requires hosted verification.

### Next action

- Run containerized portable checks and hostile guide mutations, then require
  exact-head Android and CodeQL gates before review and merge.

## 2026-06-25

- Preserved explicit pickup selections until the map and activity are ready,
  re-requested map readiness after paused callbacks, and prevented late
  current-place callbacks, repeated resumes, or delayed car population from
  replacing or obscuring the selected pickup without bypassing location
  permission checks.
- Kept the SDK-free Java contract suite compatible with JDK installations on
  `PATH`, while continuing to honor `JAVA_HOME`, `JAVAC`, and `JAVA` overrides.

## 2026-06-21

- Made every Make quality gate safe for spaced and shell-sensitive checkout
  paths and rejected caller-controlled root, Ruby, derived-SDK, shell, preload,
  and Makefile-list authority without changing Android behavior or toolchains.
- Added a deferred final-file-set guard so a later `-f` Makefile cannot replace
  a public verification target after the repository Makefile is parsed.

## 2026-06-17

- Removed invalid and redundant layout attributes and enforced accessible,
  scale-independent text sizing for the pickup label and alert dialog.
- Moved visible ride-selection copy into string resources and added accessible
  descriptions for the pickup search image and action-bar logo.

## 2026-06-16

- Guarded stale current-place callbacks, map-ready callbacks, and delayed marker
  population against paused or destroyed activity state.

## 2026-06-13

- Required exactly one top-level declaration of each reviewed Android network
  and location permission and rejected missing, duplicate, unnamed, nested, or
  unexpected manifest permissions.
- Declared Mapbox telemetry explicitly non-exported and added structured XML
  contract tests for missing, implicit, exported, duplicate, and malformed
  service declarations.

## 2026-06-12

- Pinned the Gradle 4.10.2 all-distribution to the publisher-provided SHA-256
  `b7aedd369a26b177147bcb715f8b1fc4fe32b0a6ade0d7fd8ee5ed0c6f731f2c`
  and replaced the checked-in Gradle 2.10 wrapper scripts and JAR with Gradle
  4.10.2 tagged wrapper artifacts. The wrapper JAR is
  `f477f0a7223dd6c43391aeb91ffbb15de8f251f1782e847c2270fb7b55c24585`.
- Restored local and hosted Android compilation with AGP 3.3.2, Gradle 4.10.2,
  build-tools 28.0.3, scoped legacy lint handling, and temporary non-secret
  credential placeholders that are removed after every Gradle invocation.
- Added executable Java guard behavior tests for PlacePicker request routing
  and complete location permission grants without requiring an Android SDK.
- Required location permission callbacks to return the exact requested
  coarse/fine permission set once with aligned granted results.
- Pinned hosted Corretto setup, disabled persisted checkout credentials, and
  upgraded the future Gradle test dependency to JUnit 4.13.2.
- Overrode PlacePicker's vulnerable Gson 2.5 dependency with Gson 2.8.9 and
  recorded the legacy Mapbox/OkHttp CVE-2021-0341 risk.
- Raised the minimum Android version to API 21, forced OkHttp and its logging
  interceptor to OkHttp 4.9.2, verified exact debug/release resolution, and
  added both APK variants to the normal build gate.

## 2026-06-10

- Added an Android modernization plan that records the SDK 23 baseline and the
  wrapper, SDK, AndroidX, and emulator smoke-test path for a dedicated revival
  pass.
- Required matching PlacePicker request and result codes before consuming
  venue data, with superclass forwarding for unrelated activity results.
- Guarded MapView lifecycle forwarding when the map view has not been
  initialized.
- Replaced the obsolete Travis Android configuration with dependency-free
  GitHub Actions contract validation.
- Made `make check` independent of the caller's current directory.
- Added fail-closed workflow pinning and hosted validation plan checks.

## 2026-06-09

- Declared the launcher activity exported state explicitly and added static
  validation for that manifest contract.
- Removed tracked IntelliJ `.idea` metadata and added static checker coverage
  for local IDE ignore rules.
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
