# Landing Asset Contract

## Status: Completed

## Context

`ride_up` includes a static landing page alongside the legacy Android sample.
The Android contract checker already validated the landing page's Google Play
package link, but it did not verify local stylesheet, favicon, or screenshot
references. Those local assets should stay checked in and should not point
outside the repository.

## Objectives

- Keep the default verification path dependency-free.
- Validate local `src` and `href` references in `index.html`.
- Ignore expected remote CDN, GitHub, and Play Store links.
- Reject local references that escape the repository root.

## Work Completed

- Added landing-page asset helpers to `scripts/check-android-contract.rb`.
- Validated local landing-page asset references after stripping query strings.
- Updated README, SECURITY, VISION, and CHANGES notes for the local asset
  contract.
- Added this completed plan under `docs/plans/`.

## Verification

- `ruby scripts/check-android-contract.rb`
- `make check`
- `make verify`
- `git diff --check`
