# Guard Delayed Marker Population With Activity Lifecycle

Status: Completed

## Context

`MainActivity` waits 500 milliseconds after Mapbox becomes ready before adding
ten simulated car markers. The delayed runnable currently mutates the map even
after `onPause` or `onDestroy`, while only the subsequent marker animations are
lifecycle-gated.

## Objectives

- Reject delayed marker population while the activity lifecycle is inactive.
- Perform the lifecycle check before the runnable enters the marker-addition
  loop.
- Reuse the existing `MarkerAnimationLifecycle` state without adding another
  timer, handler, or activity flag.
- Add a mutation-sensitive static contract for the guard and its ordering.

## Scope Boundaries

- Do not change marker count, delay duration, map coordinates, permissions,
  dependencies, telemetry, credentials, or ride-request behavior.
- Do not add background services or generated Android outputs.

## Implementation

1. Guard the delayed runnable with `markerAnimationLifecycle.canAnimate()`.
2. Extend the Android contract checker to require the delayed guard before the
   ten-marker loop.
3. Add focused mutations that remove or move the guard after map mutation.
4. Synchronize repository guidance and record completed verification.

## Verification

- Run the focused static mutation contract.
- Run repository-root and external-directory `make check`.
- Record the Android SDK limitation without weakening portable checks.
- Audit the exact diff, generated artifacts, credential patterns, conflict
  markers, binary changes, file modes, and large files.

## Verification Completed

- The focused delayed-marker contract passed and four delayed-marker mutations were rejected.
- Repository-root and external-directory `make check` passed every portable
  contract; Android SDK-dependent dependency, lint, test, and build tasks were
  skipped because no SDK is configured on this Linux host.
- Ruby syntax, exact-diff, generated-artifact and credential-pattern audits passed.
