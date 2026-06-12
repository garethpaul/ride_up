# Location Permission Identity

## Status: Completed

## Context

`MainActivity` requested coarse and fine location permissions, but its callback
guard previously validated only that every returned grant value was approved.
It did not prove that the callback named exactly the permissions that were
requested or that the name/result arrays aligned.

## Priority

Location-backed work should start only after an exact, internally consistent
permission callback. Treating unrelated, duplicate, missing, or length-mismatched
permission names as location approval weakens that boundary.

## Requirements

- R1. Define one private expected location-permission array used by both the
  request and callback guard.
- R2. Require non-null, non-empty permission, result, and expected arrays with
  identical lengths.
- R3. Accept each expected permission exactly once, regardless of callback
  order.
- R4. Reject unknown, duplicate, missing, null, or partially denied entries.
- R5. Preserve superclass forwarding for unrelated request codes.
- R6. Cover behavior in JUnit and the dependency-free Java 8 harness.
- R7. Protect the helper, callback wiring, tests, and completed plan in the
  structural checker.

## Scope Boundaries

- Do not change Android permission declarations or request codes.
- Do not modernize the archived Android SDK or support libraries here.
- Do not claim emulator or device behavior beyond the hosted SDK build.

## Verification Plan

- `ruby scripts/test-ride-up-guards.rb`
- `ruby scripts/check-android-contract.rb`
- `make test`
- `make check`
- focused hostile permission-identity mutations
- `git diff --check`

## Work Completed

- Added one private coarse/fine location-permission array shared by the Android
  request and callback guard.
- Added a dependency-free Java 8 helper that accepts the exact expected granted
  set in any order and rejects null, empty, missing, unknown, duplicate,
  misaligned, or denied entries.
- Expanded JUnit and SDK-free behavior coverage for the permission identity
  boundary while preserving superclass forwarding for unrelated request codes.
- Strengthened the structural checker around the canonical array, complete
  helper-call argument sequence, helper invariants, tests, and this completed
  plan.

## Verification

- `ruby scripts/test-ride-up-guards.rb` passed.
- `make test` passed the SDK-free Java 8 harness; Gradle tests were skipped
  because no Android SDK is configured in this checkout.
- `ruby scripts/check-android-contract.rb` passed after completion evidence was
  recorded.
- `make check` passed the complete locally available gate; SDK-backed Gradle
  lint, tests, and assembly were skipped because no Android SDK is configured.
- 12 focused hostile permission-identity mutations were rejected, covering the
  canonical declaration, request array, callback arguments, name/result
  alignment, duplicate expected and returned names, unknown names, denied
  results, JUnit and SDK-free tests, and completed-plan status.
- `git diff --check` passed.
