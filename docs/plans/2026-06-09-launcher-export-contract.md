# Launcher Export Contract

## Status: Completed

## Context

`MainActivity` is the Android launcher activity for the RideUp sample. It had a
launcher intent filter but did not declare `android:exported`, leaving the entry
point implicit in the manifest.

## Objectives

- Keep the launcher activity available from the Android launcher.
- Make the exported state explicit in `app/src/main/AndroidManifest.xml`.
- Extend the SDK-free static checker so the manifest contract does not drift.
- Document the compatibility and review expectation in repository docs.

## Work Completed

- Added `android:exported="true"` to the `.MainActivity` launcher declaration.
- Extended `scripts/check-android-contract.rb` to require the explicit launcher
  export contract and this completed plan.
- Updated README, VISION, CHANGES, and SECURITY notes.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make lint`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Gradle Notes

This environment uses the default SDK-free static verification path. `make
check` still supports `RUN_LEGACY_GRADLE=1` on a machine with SDK 23 and the
required archived Android Gradle plugin dependencies.
