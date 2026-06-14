# Make Root Override Protection

## Status: Completed

## Context

The Makefile derives the repository root from its own path and uses that root
for every script and Gradle invocation. GNU Make command-line variables have
higher precedence than ordinary assignments, though, so `make ROOT=/tmp check`
can redirect those recipes away from the checkout and bypass the intended
location-independent gate.

## Requirements

- **R1:** Derive `ROOT` from the loaded Makefile and prevent command-line or
  environment overrides.
- **R2:** Keep `RUBY`, `ANDROID_HOME`, and `ANDROID_SDK_ROOT` configurable.
- **R3:** Add a static contract that rejects a weakened root declaration.
- **R4:** Prove root and external-directory execution, including a hostile
  `ROOT` argument, without weakening Android validation.
- **R5:** Preserve production Android code, manifests, dependencies, Gradle
  configuration, workflows, and credential handling.

## Implementation Units

### U1. Root Declaration

Give the repository-derived `ROOT` declaration override precedence while
leaving toolchain variables configurable.

### U2. Static Contract

Require the exact protected declaration in the Android contract checker so a
future ordinary assignment or caller-controlled root fails closed.

### U3. Verification

Run focused static checks, root and external-directory Make aliases, hostile
root mutations, integrity screening, and exact-head hosted validation.

## Scope Boundaries

- Do not change application runtime behavior or Android resources.
- Do not change SDK, Gradle, AGP, or dependency versions.
- Do not add credentials or generated Android outputs.

## Work Completed

- Protected the Makefile-derived repository root from caller overrides.
- Added an exact static contract for the protected declaration.
- Verified all public Make aliases from the checkout and an external working
  directory, including a hostile `ROOT=/tmp` argument.

## Verification Results

- `ruby scripts/check-android-contract.rb` passed.
- `dependency`, `lint`, `test`, `build`, `verify`, and `check` passed from the
  repository root and an external directory; the local environment had no
  exported Android SDK, so Gradle-backed portions used their explicit skip
  path while the Ruby and pure-Java gates ran.
- `make check` passed from the repository root.
- `make ROOT=/tmp check` passed while still executing repository-owned gates;
  the manifest contract ran 9 tests and 30 assertions and the executable guard
  harness passed.
- Six root-declaration, static-contract, plan-status, and evidence mutations
  were rejected.
- Ruby syntax, `git diff --check`, secret screening, generated-artifact
  screening, and protected-file comparison passed before shipping.
