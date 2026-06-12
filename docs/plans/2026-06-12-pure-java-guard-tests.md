# Pure Java RideUp Guard Tests

Status: Completed

## Context

The Android SDK 23 build remains intentionally legacy, but permission and
PlacePicker routing decisions do not require Android APIs. Static source checks
alone could not prove those decisions behaved correctly.

## Work Completed

- Extracted permission and activity-result decisions into a Java 8 helper used
  by `MainActivity`.
- Added JUnit coverage for an eventual SDK-backed Gradle build.
- Added a dependency-free Java harness that compiles and executes the helper
  without an Android SDK.
- Wired the behavior harness into `make test` and hosted validation.
- Pinned hosted JDK setup and disabled persisted checkout credentials.

## Verification

- `ruby scripts/test-ride-up-guards.rb`
- `make check`
