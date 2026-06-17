# Add Accessible and Localizable Layout Resources

Status: Completed

## Context

The full Android SDK gate reports six `HardcodedText` warnings in
`app/src/main/res/layout/activity_main.xml` and two `ContentDescription`
warnings across the main pickup search image and the custom action-bar logo.
These visible controls and images should expose resource-backed text so they
can be localized and identified by assistive technology.

## Objectives

- Move every user-visible label reported by Android lint into named string
  resources.
- Give the pickup search image and branded action-bar logo meaningful,
  resource-backed content descriptions.
- Add mutation-sensitive, dependency-free contracts that reject hardcoded
  visible labels, missing descriptions, or unused required resources.
- Preserve the existing layout, control identifiers, ride behavior, and
  archived Android toolchain.

## Scope Boundaries

- Do not change layout geometry, colors, typography, button behavior, map
  behavior, permissions, dependencies, or Android SDK levels.
- Do not suppress lint findings or mark informative images as decorative.
- Do not attempt to resolve unrelated legacy lint warnings in this change.
- Do not commit generated Gradle, lint-report, APK, or local SDK artifacts.

## Implementation Units

### 1. Resource-backed visible text and image descriptions

Update `app/src/main/res/values/strings.xml`,
`app/src/main/res/layout/activity_main.xml`, and
`app/src/main/res/layout/action_bar_custom.xml` so all six reported labels and
both informative image descriptions reference these named string resources
without changing the displayed English copy:

- `pickup_location_label`: `PICKUP LOCATION`
- `current_location_label`: `Current Location`
- `ride_x_label`: `Ride X`
- `ride_lux_label`: `RIDE LUX`
- `ride_big_label`: `RIDE BIG`
- `confirm_pickup_label`: `Confirm Pickup`
- `pickup_search_description`: `Search pickup location`
- `ride_up_logo_description`: `RideUp logo`

### 2. Mutation-sensitive layout resource contract

Add a focused Ruby contract and test under `scripts/` that parse the XML
resources, require the expected layout references, verify each referenced
resource is defined exactly once and is nonblank, and reject the original
hardcoded or missing-description states. The contract must require all eight
resource names above, require `@string/pickup_search_description` on
`@id/imageView`, require `@string/ride_up_logo_description` on `@id/icon`, and
require each of the six visible controls to reference its corresponding label.
Register the test in `Makefile` and the existing Android contract gate.

### 3. Maintenance record

Record the accessibility and localization improvement in `CHANGES.md`, then
mark this plan completed with the actual verification results.

## Verification

- Run Ruby syntax checks and the focused layout-resource contract tests.
- Run `make check` from the repository and an external directory without an
  SDK to verify the portable entrypoint.
- Run `ANDROID_HOME=/home/gjones/android-sdk
  ANDROID_SDK_ROOT=/home/gjones/android-sdk make check` to cover exact
  dependency resolution, Android lint, unit tests, and debug/release builds.
- Confirm Android lint no longer reports `HardcodedText` or
  `ContentDescription` findings while preserving unrelated warning visibility.
- Run hostile mutations for hardcoded text, missing descriptions, missing
  definitions, blank resources, and unregistered focused tests.
- Audit the exact diff, generated artifacts, likely credentials, conflict
  markers, binary changes, file modes, and large files before committing.

## Assumptions

- The logo and pickup search glyph communicate useful identity or action and
  should remain available to accessibility services rather than being marked
  decorative.
- Existing English copy remains unchanged; this work enables localization but
  does not add translated resource sets.

## Verification Completed

- Ruby syntax checks and the focused layout-resource contract passed; seven hostile layout-resource mutations were rejected across hardcoded copy,
  missing descriptions, missing or blank definitions, incorrect references,
  and removed Makefile registration.
- Exact debug and release dependency resolution retained OkHttp and its logging
  interceptor at `4.9.2`.
- Android lint reported zero `HardcodedText` and zero `ContentDescription` findings. Fifteen unrelated legacy warnings remain visible and were not
  suppressed or expanded into this change.
- Android debug/release unit tests and `assembleDebug assembleRelease` passed
  with `/home/gjones/android-sdk`.
- The repository and external-directory portable gates passed, followed by the
  complete SDK-backed `make check` gate.
- The exact-diff, generated-artifact, and credential-pattern audits passed;
  generated Gradle outputs remained ignored and were not committed.
