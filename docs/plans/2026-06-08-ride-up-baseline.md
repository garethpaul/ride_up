# Ride Up Baseline

## Status: Completed

## Context

`ride_up` is a legacy Android sample that combines Foursquare PlacePicker,
Mapbox maps, location permissions, mock ride markers, and a static project
landing page. Its Android Gradle stack is old enough that the default
repository gate needs to stay useful without resolving archived SDK and plugin
dependencies.

## Objectives

- Keep API credentials out of source control while preserving a local template.
- Validate the manifest package, Gradle `applicationId`, and landing page Play
  link as one package identity contract.
- Keep location and network permission expectations explicit.
- Preserve legacy Gradle execution behind the opt-in `RUN_LEGACY_GRADLE=1`
  switch.
- Maintain completed maintenance plans under `docs/plans`.

## Work Completed

- Confirmed `make check` runs the static Android credential and package
  contract checker by default.
- Added canonical `docs/plans` coverage for the current maintenance baseline.
- Extended the checker to require completed `docs/plans` entries with
  `make check` verification.
- Updated README, VISION, and CHANGES to make the baseline discoverable.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Run `RUN_LEGACY_GRADLE=1 make verify` on a machine with SDK 23 and archived
  Android Gradle plugin dependencies available.
- Add emulator notes if runtime Mapbox or Foursquare behavior is refreshed.
