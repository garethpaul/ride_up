# Current-Place Request Generation

## Status: Completed

## Problem

The current-place callback used only the activity animation flag. A cached
callback could arrive before the first resume or after a pause, be discarded,
and never be requested again. Retrying without request identity would allow an
older callback to clear or publish over newer resumed work.

## Decision

Use a small SDK-free controller that starts requests only while active and
without a selected pickup, assigns monotonically increasing generations,
invalidates the active generation on pause, and accepts completion only for the
current active generation. Failed and paused requests remain retryable; a
resolved current place is not repeatedly requested.

## Scope

- `CurrentPlaceRequestController.java` and its SDK-free/Android tests
- `MainActivity.java` active-resume, permission-result, callback, and pause wiring
- Static Android and delayed-marker lifecycle contracts
- README, security, vision, agent guidance, and changelog

No provider credentials, precise locations, live PlacePicker calls, or real
dispatch behavior are included in verification.

## Verification

- Failing-first Java compilation proved the controller boundary was absent.
- Focused Java 7 behavior covered inactive, pickup-selected, duplicate,
  invalidated, stale, paused, resolved, failed, and stale-failure paths.
- Containerized portable `make check` validates Java, Ruby, manifest, layout,
  Make authority, and mutation contracts without an Android SDK.
- The portable gate passed 77 Make authority cases, five SDK-free Java behavior
  suites, 16 pickup-map static plus seven executable mutations, 19 lifecycle
  mutations, and 15 layout mutations.
- Four isolated controller mutations were rejected across pause invalidation,
  stale completion, resolved suppression, and stale failure ownership.
- Pull request #14 implementation head
  `2ca59dc6110a2012a02d9ab71ddf6565459e9b9a` passed both hosted `check`
  jobs, all four CodeQL language analyses, and the CodeQL aggregate gate.
- Required Codex review was attempted against `origin/master`; the helper
  stopped before analysis because OpenAI WebSocket and HTTPS transports both
  returned HTTP 401. Local, remote, and pull-request heads were identical, and
  an immutable manual fallback review found no actionable defects.
