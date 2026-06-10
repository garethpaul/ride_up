## RideUp Vision

RideUp is a legacy Android ride-sharing sample that combines Foursquare
PlacePicker, Mapbox maps, location permissions, and animated car markers around
a pickup-location flow.

The repository is useful as an integration prototype for place selection,
mapping, mock ride markers, and a companion project landing page.

The goal is to preserve the sample while making API keys, permissions, and
legacy Android dependencies explicit.

The current focus is:

Priority:

- Preserve the Foursquare PlacePicker and Mapbox integration path
- Keep API keys in a local `Constants.java` file outside source control
- Keep local IDE metadata out of the portable sample
- Make location permission behavior visible
- Maintain `make check` for Android credential and application ID contracts
- Keep Gradle package metadata aligned with the manifest and landing page
- Keep completed maintenance plans under `docs/plans`
- Keep Android backup disabled for local credential and location-adjacent data
- Keep launcher activity exported state explicit in the manifest
- Keep Java resource references aligned with checked-in Android drawables
- Keep landing-page local asset references aligned with checked-in files
- Keep PlacePicker result handling guarded before reading venues or map state
- Keep PlacePicker activity results scoped to the request that launched them
- Keep startup current-place lookup behind granted location permission
- Keep permission-result handling gated on every requested location grant
- Keep unrelated permission-result callbacks forwarded to the superclass
- Keep PlacePicker and current-place coordinates guarded behind venue locations
- Keep MapView lifecycle forwarding guarded for missing view instances
- Treat support libraries and Gradle versions as legacy
- Keep dependency-free Android source contracts enforced in hosted validation

Next priorities:

- Add setup notes for Android SDK, Mapbox, and Foursquare credentials
- Add a safe placeholder or mock mode for ride markers
- Document which landing-page assets are part of the sample
- Modernize dependencies in a separate compatibility pass

Contribution rules:

- One PR = one focused map, place picker, permission, dependency, or docs change.
- Do not commit API keys or precise user location data.
- Include emulator or device notes for runtime changes.
- Keep mock ride behavior distinct from real dispatch behavior.

## Security And Responsible Use

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

The app requests location and uses third-party mapping/place APIs. Changes
should keep permissions explicit, avoid storing precise location history, and
never imply real ride dispatch without an implemented backend.

## What We Will Not Merge (For Now)

- Checked-in Mapbox or Foursquare credentials
- Silent location upload or tracking
- Real dispatch/payment behavior without a full product contract
- Dependency upgrades mixed with feature rewrites

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
