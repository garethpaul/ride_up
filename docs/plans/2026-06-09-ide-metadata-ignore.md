# IDE Metadata Ignore

## Status: Completed

## Context

The legacy Android sample tracked IntelliJ `.idea` project metadata. Those
files capture local editor state and Android Studio import details that should
not be part of the portable RideUp source snapshot.

## Objectives

- Remove checked-in `.idea` metadata.
- Ignore the full `.idea/` directory for future local IDE state.
- Preserve Android source, wrapper files, landing-page assets, and sample
  configuration templates.
- Extend the SDK-free static contract checker so IDE metadata does not return.

## Work Completed

- Removed tracked `.idea` files.
- Replaced narrow IntelliJ ignore entries with a `.idea/` directory rule.
- Extended `scripts/check-android-contract.rb` to reject present tracked IDE
  metadata.
- Updated README, VISION, and CHANGES.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make check`
- `git diff --check`

## Legacy Gradle Notes

This environment used the default SDK-free static verification path. `make
check` still supports `RUN_LEGACY_GRADLE=1` on a machine with SDK 23 and the
required archived Android Gradle plugin dependencies.

## Follow-Up Candidates

- Document a known-good Android Studio import path during setup
  documentation.
- Keep Gradle and dependency modernization separate from local IDE metadata.
