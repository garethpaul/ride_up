# PlacePicker Request-Code Guard

## Status: Completed

## Context

`MainActivity.onActivityResult` accepted any callback carrying the PlacePicker
result code. Without checking the request code used to launch the picker, an
unrelated activity result could be interpreted as a venue selection.

## Objectives

- Use one named request-code constant for launching and receiving PlacePicker.
- Read venue data only when both request and result codes match.
- Forward unrelated activity results to the superclass.

## Work Completed

- Added `PLACE_PICKER_REQUEST` and used it in `startActivityForResult`.
- Added a fail-closed request/result guard before reading callback data.
- Extended the Android contract checker and maintenance documentation.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Gradle Notes

The archived Android Gradle build remains opt-in through
`RUN_LEGACY_GRADLE=1` on a machine with the matching SDK 23-era toolchain.
