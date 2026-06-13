# Manifest Permission Allowlist

## Status: Completed

## Context

RideUp currently declares exactly four Android permissions, but the repository
checker only searches for three names as text. It does not require
`ACCESS_NETWORK_STATE`, reject duplicate declarations, or fail when an
unreviewed permission is added.

## Requirements

- **R1:** Parse top-level `uses-permission` elements as XML.
- **R2:** Require exactly one declaration each for `ACCESS_NETWORK_STATE`,
  `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`, and `INTERNET`.
- **R3:** Reject missing, duplicate, unnamed, nested, and unexpected permission
  declarations.
- **R4:** Preserve the existing launcher, backup, telemetry-service, SDK,
  dependency, build, and application behavior boundaries.
- **R5:** Add mutation-sensitive tests and truthful local/hosted evidence.

## Implementation Units

### U1. Structured Permission Contract

Extend `scripts/android-manifest-contract.rb` with an exact permission allowlist
derived from top-level manifest declarations.

### U2. Contract Tests And Wiring

Extend `scripts/test-android-manifest-contract.rb` for valid, missing,
duplicate, unnamed, nested, unexpected, and malformed manifests, and route the
repository checker through the structured contract.

### U3. Documentation And Verification

Synchronize repository documentation, run focused Ruby tests, SDK-backed
`make check`, hostile mutations, and integrity scans, then record exact hosted
evidence without weakening the legacy Android build bridge.

## Scope Boundaries

- Do not add, remove, or reorder production permissions in this slice.
- Do not change runtime permission prompts or location-result handling.
- Do not modernize the target SDK, Gradle, AGP, or Android dependencies.

## Verification

- `ruby scripts/test-android-manifest-contract.rb`
- SDK-backed `make check`
- missing, duplicate, unnamed, nested, unexpected, wiring, documentation,
  completed-status, and evidence mutations
- Ruby syntax, workflow YAML, Android XML, protected-file, secret, artifact,
  and `git diff --check` gates

## Work Completed

- Added an exact four-permission allowlist to the structured REXML manifest
  contract.
- Replaced substring presence checks with top-level declaration validation that
  rejects missing, duplicate, unnamed, nested, and unexpected permissions.
- Added focused contract tests and synchronized repository documentation.

## Verification Results

- `ruby scripts/test-android-manifest-contract.rb` passed 9 tests and 30
  assertions.
- SDK-backed `make check` passed exact OkHttp resolution, structured contracts,
  lint, executable guard tests, both unit-test variants, dexing, and
  debug/release APK assembly.
- Five actual-manifest mutations covering missing, duplicate, unnamed, nested,
  and unexpected permissions were rejected.
- Ruby syntax, `git diff --check`, credential screening, generated-artifact
  screening, and protected-file comparison passed before the shipping commit.
