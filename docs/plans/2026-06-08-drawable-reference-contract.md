# Drawable Reference Contract

## Status: Completed

## Context

`ride_up` is usually checked with a static gate because the Android Gradle
stack depends on old SDK and plugin artifacts. That gate covered credentials,
package identity, permissions, repository URLs, app backup, and completed
plans, but it did not catch Java code that references missing Android drawable
resources. `MainActivity` used a missing `R.drawable.category_none` placeholder
for PlacePicker images.

## Objectives

- Keep default verification dependency-free.
- Replace the missing image placeholder with a checked-in drawable.
- Fail the static gate when Java `R.drawable.*` references do not resolve to
  files under `app/src/main/res/drawable`.
- Preserve the existing credential, manifest, package ID, and docs-plan checks.

## Work Completed

- Replaced the missing PlacePicker placeholder with `R.drawable.ic_circle`.
- Extended `scripts/check-android-contract.rb` to validate Java drawable
  references against checked-in drawable resources.
- Updated README, VISION, and CHANGES notes for the new guardrail.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make check`
- `make verify`
- `git diff --check`
