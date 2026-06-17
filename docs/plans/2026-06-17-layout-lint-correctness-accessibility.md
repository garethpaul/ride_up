# Resolve Layout Correctness and Text Accessibility Warnings

Status: Completed

## Context

The SDK-backed Android lint gate is green but still reports four directly
source-fixable layout warning classes: one invalid `layout_weight` on a
`RelativeLayout` child, one pickup label below the `12sp` readability floor,
one dialog text size expressed in density pixels, and two redundant physical
left/right alignment attributes. These findings are independent of the
larger SDK, dependency, bitmap-density, and application-indexing migrations.

## Goal

Remove the `ObsoleteLayoutParam`, `SmallSp`, `SpUsage`, and `RtlHardcoded`
findings through narrow XML corrections, with mutation-sensitive contracts
that preserve the corrected layout semantics without suppressing lint.

## Requirements

1. Remove the invalid `android:layout_weight` from the confirm button while
   preserving its full-width start/end alignment, identifier, copy, and click
   behavior.
2. Raise the pickup-location label to at least `12sp` without changing its
   text resource, style, color, or alignment.
3. Express the custom alert dialog text size in `sp`, preserving the existing
   numeric size and color.
4. Remove redundant physical left/right parent alignment from the confirm
   button while retaining logical start/end alignment for RTL-aware layout.
5. Add a structured XML contract that rejects reintroducing each warning,
   validates the required corrected values, and is registered in the normal
   Makefile and Android contract gates.
6. Keep all unrelated lint findings visible; do not add lint suppressions or
   expand this change into button styling, drawable density, unused-resource,
   app-indexing, SDK, or dependency work.

## Implementation Units

### Layout XML

- Update `app/src/main/res/layout/activity_main.xml` to use a readable pickup
  label size, remove the invalid weight, and retain only logical horizontal
  parent alignment on the confirm button.
- Update `app/src/main/res/values/alert_custom.xml` so dialog text uses scale-
  independent pixels.

### Mutation-Sensitive Contract

- Add `scripts/layout-lint-contract.rb` to parse the activity layout and alert
  style as XML and report violations for the four targeted warning classes.
- Add `scripts/test-layout-lint-contract.rb` with hostile mutations for the
  invalid weight, undersized text, density-pixel text, physical alignment,
  missing logical alignment, and removed test registration.
- Register the focused test in `Makefile` and `scripts/check-android-contract.rb`.

### Maintenance Record

- Record the lint cleanup in `CHANGES.md`.
- Mark this plan completed only after focused, portable, and SDK-backed gates
  pass and the exact lint report proves all four targeted warning classes are
  absent.

## Verification

- Run Ruby syntax checks and the focused layout-lint contract test.
- Run `make check` from the repository and from an external directory with
  Android SDK variables unset.
- Run the full SDK-backed `make check` with `/home/gjones/android-sdk`.
- Parse the final lint XML and require zero `ObsoleteLayoutParam`, `SmallSp`,
  `SpUsage`, and `RtlHardcoded` issues. Require the remaining report to retain
  exactly ten unrelated findings: three `ButtonStyle`, three `IconLocation`,
  three `UnusedResources`, and one `GoogleAppIndexingWarning`.
- Run hostile mutations for every corrected attribute/value and test-gate
  registration.
- Audit the exact diff, generated artifacts, likely credentials, conflict
  markers, file modes, large files, and upstream relationship before commit.

## Risks And Boundaries

- Raising the pickup label from `10sp` to `12sp` may modestly change text
  metrics; the existing fixed header height and SDK-backed resource/build gate
  must remain valid.
- Removing the confirm button's invalid weight and redundant physical
  alignment should not alter geometry because logical start/end constraints
  already define full-width placement.
- This change does not claim runtime rendering on an emulator or device; the
  hosted and local Android build gates remain structural and compilation
  evidence.

## Assumptions

- The existing English copy and control hierarchy are intentional and remain
  unchanged.
- Logical start/end alignment is supported by the declared minimum SDK and is
  already used throughout the layout.

## Work Completed

- Removed the confirm button's invalid weight and redundant physical
  left/right alignment while preserving logical start/end constraints.
- Raised the pickup-location label from `10sp` to `12sp` and changed the alert
  dialog text size from `22dp` to `22sp`.
- Added a structured XML layout-lint contract, registered it in both normal
  verification paths, and recorded the change in the changelog.

## Verification Completed

- Ruby syntax checks and the focused contract passed; eight hostile layout-lint mutations were rejected across invalid weight, undersized or density-pixel text, physical alignment, missing logical alignment, and removed Makefile registration.
- The SDK-backed `make check` passed dependency resolution, Android lint,
  debug/release unit tests, and debug/release APK assembly with
  `/home/gjones/android-sdk`.
- Android lint reported zero `ObsoleteLayoutParam`, `SmallSp`, `SpUsage`, and `RtlHardcoded` findings; exactly ten unrelated lint findings remained visible across `ButtonStyle`, `IconLocation`, `UnusedResources`, and `GoogleAppIndexingWarning`.
- The repository and external-directory portable gates passed with Android SDK
  variables unset.
- Exact-diff, generated-artifact, credential-pattern, conflict-marker, file-
  mode, large-file, and upstream-relationship audits passed before shipment.
