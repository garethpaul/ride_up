# Bound Marker Animations To The Activity Lifecycle

Status: In Progress

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

## Verification

- focused pure-Java marker lifecycle contract tests
- full repository and external-directory `make check`
- Android Gradle tests/build when the configured SDK is available
- hostile mutations covering pause/destroy stop, resume, completion restart,
  marker tracking, documentation, and completed-plan evidence
- exact diff, generated-artifact, and credential-pattern audits
