# Safe Make Authority

## Status: Completed

## Context

The Make root used `lastword`, so checkout paths containing spaces were split.
Caller-controlled `MAKEFILE_LIST`, `MAKEFILES`, `ROOT`, `RUBY`, `ANDROID_SDK`,
`SHELL`, and `.SHELLFLAGS` could also redirect or influence repository gates.

## Scope Boundaries

- Do not change Android app behavior, resources, manifests, dependencies,
  Gradle, AGP, SDK versions, signing, or credential handling.
- Keep `ANDROID_HOME` and `ANDROID_SDK_ROOT` configurable as supported Android
  toolchain locations while deriving `ANDROID_SDK` inside the Makefile.
- Preserve truthful non-SDK skips and exact hosted SDK-backed verification.

## Work Completed

- Canonicalize the checked-in Makefile through quoted POSIX tools without
  splitting spaces or interpreting shell-sensitive checkout names.
- Freeze Ruby and shell authority, export canonical root and derived SDK values
  as data, and reject direct `ANDROID_SDK` replacement.
- Reject both `MAKEFILE_LIST` replacement channels, `MAKEFILES` preloads, and
  ambiguous multiple-`-f` invocations before a quality command runs.
- Add an executable dependency-free root suite to `make verify` and `make check`.

## Verification Completed

- Ruby 2.7.0 passed portable `make check` from the repository root and an
  unrelated directory; SDK-backed validation passed in GitHub Actions.
- All 77 executed target, root, shell, Ruby, and derived-SDK authority cases
  passed from a path containing spaces, quotes, brackets, an apostrophe, and backticks.
- Both `MAKEFILE_LIST` override channels, a `MAKEFILES` preload, and an
  ambiguous multiple-Makefile invocation failed closed.
- Android contracts, manifest tests, pure-Java guards, delayed-marker and layout
  contracts, Ruby/shell syntax, `git diff --check`, and strict Git object validation passed.
