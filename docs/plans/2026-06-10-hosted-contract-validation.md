# Hosted Android Contract Validation

Status: Completed

## Context

The Android application is tied to Android Gradle Plugin 2.2.2, Gradle 2.14.1,
SDK 23, Java 8, and dependencies from retired or archival repositories. The
existing Travis configuration described an Android build environment that is no
longer an honest or maintainable hosted gate. The repository already has a
dependency-free Ruby checker for security, manifest, permission, resource, and
landing-page contracts. Pure permission and activity-result decisions can also
execute as Java without loading the obsolete Android stack.

## Objectives

- Run the maintained source and behavior contracts on every push and pull request.
- Install no project or Ruby dependencies in hosted validation.
- Pin a maintained JDK for dependency-free Java guard behavior tests.
- Pin third-party actions and grant read-only repository permissions.
- Remove the obsolete Travis configuration rather than imply a legacy Android
  build remains continuously supported.
- Make `make check` independent of the caller's current directory.

## Work Completed

- Added `.github/workflows/check.yml` on a fixed Ubuntu 24.04 runner.
- Pinned checkout and Corretto setup to immutable commits, limited permissions
  to read access, and disabled persisted checkout credentials.
- Added executable Java guard behavior tests without project dependency setup.
- Removed `.travis.yml` and documented why hosted validation is structural.
- Made the Makefile resolve the Ruby checker relative to itself.
- Extended the checker to fail closed when hosted validation controls drift.

## Verification

- `make check`
- `make -f /path/to/repository/Makefile check` from outside the repository
- `ruby -c scripts/check-android-contract.rb`
- `ruby scripts/test-ride-up-guards.rb`
- `git diff --check`
