# Guard Delayed Marker Population With Activity Lifecycle

Status: Completed

## Context

`MainActivity` waits 500 milliseconds after Mapbox becomes ready before adding
ten simulated car markers. The current-place callback, map-ready callback, and
delayed runnable currently mutate or register map work even after `onPause` or
`onDestroy`, while only the subsequent marker animations are lifecycle-gated.

## Objectives

- Reject delayed marker population while the activity lifecycle is inactive.
- Reject stale current-place callbacks before storing coordinates or registering
  map callbacks.
- Reject stale map-ready callbacks before assigning or mutating the Mapbox map.
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

1. Guard the current-place callback with `markerAnimationLifecycle.canAnimate()`.
2. Guard the map-ready callback with `markerAnimationLifecycle.canAnimate()`.
3. Guard the delayed runnable with `markerAnimationLifecycle.canAnimate()`.
4. Extend the Android contract checker to require all three lifecycle guards
   before coordinate storage, map callback registration, map assignment, camera
   movement, location enabling, or the ten-marker loop.
5. Add focused mutations that remove or move each guard after map mutation.
6. Synchronize repository guidance and record completed verification.

## Verification

- Run the focused static mutation contract.
- Run repository-root and external-directory `make check`.
- Record the Android SDK limitation without weakening portable checks.
- Audit the exact diff, generated artifacts, credential patterns, conflict
  markers, binary changes, file modes, and large files.

## Verification Completed

- The focused delayed-marker contract passed and eight delayed-marker mutations were rejected.
- Repository-root and external-directory `make check` passed every portable
  contract; Android SDK-dependent dependency, lint, test, and build tasks were
  skipped because no SDK is configured on this Linux host.
- Ruby syntax, exact-diff, generated-artifact and credential-pattern audits passed.
