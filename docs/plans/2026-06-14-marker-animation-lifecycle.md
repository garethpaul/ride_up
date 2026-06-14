# Bound Marker Animations To The Activity Lifecycle

Status: Completed

## Context

Each simulated car starts a new `ValueAnimator` from the prior animator's end
callback. The activity does not stop those recursive chains on pause or
destroy, so off-screen map mutations can retain the activity indefinitely.

## Objectives

- Track simulated car markers and active animators explicitly.
- Stop and clear active animators when the activity pauses or is destroyed.
- Resume one animation chain per existing marker when the activity resumes.
- Prevent completion callbacks from restarting chains while animations are
  inactive.
- Add pure-Java and static mutation-sensitive lifecycle contracts.

## Scope Boundaries

- Do not change permissions, exported components, dependencies, map provider
  configuration, telemetry policy, or ride-request behavior.
- Do not add credentials, generated Android outputs, or background services.

## Verification Results

- `ruby scripts/test-ride-up-guards.rb` passed the focused pure-Java guard
  and marker lifecycle contracts.
- Repository-root `make check` passed with 9 manifest tests and 30
  assertions, both pure-Java contract programs, and the Android static
  contract gate.
- External-directory `make -C /tmp -f "$PWD/Makefile" check` passed the same
  complete location-independent gate.
- Android Gradle dependency, lint, test, and build tasks were skipped because
  no Android SDK is configured in this environment; the pure-Java and static
  gates remained mandatory.
- Eight lifecycle-state, pause-stop, destroy-stop, resume, marker-tracking,
  completion-restart, behavior, and completed-plan mutations were rejected.
- Final exact-diff, generated-artifact, and credential-pattern audits found
  only the intended source, test, contract, runner, and plan changes.
