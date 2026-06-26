# Legacy Android Setup

This repository preserves an Android SDK 23 sample. Treat the checked-in
versions as a compatibility contract, not as a recommendation for a new app.

## Toolchain

The SDK-backed gate uses Android API 23 and build-tools 28.0.3 with platform
tools. The build bridge is Android Gradle Plugin 3.3.2 and Gradle 4.10.2. Use
JDK 8 for the legacy Gradle build; newer JDKs may still run the SDK-free Java
contracts but are not the canonical Android build environment.

Install the SDK packages with Android Studio's SDK Manager or `sdkmanager`, then
point ANDROID_HOME or ANDROID_SDK_ROOT at the same Android SDK directory. Keep
machine-local SDK paths out of the repository.

## Local Credentials

Create the ignored local constants file from the reviewed template:

```bash
cp app/src/main/java/com/foursquare/rideup/Constants.java.example \
  app/src/main/java/com/foursquare/rideup/Constants.java
```

Replace only these placeholders with credentials from your own developer
accounts:

- `MAPBOX_ACCESS_TOKEN`
- `FOURSQUARE_CLIENT_KEY`
- `FOURSQUARE_CLIENT_SECRET`

The Foursquare client secret is sensitive. Restrict provider credentials where
the provider supports it, do not paste them into logs or screenshots, and never
commit Constants.java. The checked-in example must remain placeholders only.
The hosted build may create a temporary non-secret constants file to compile;
those placeholders are not valid runtime credentials.

## Verification

Without an Android SDK, `make check` runs the rooted Make authority checks,
static Android/manifest contracts, Ruby mutations, and executable pure-Java
state/permission contracts while reporting SDK-backed Gradle steps as skipped.

With the SDK variables configured, `make check` also verifies the resolved
OkHttp graph, Gradle tests, lint, and debug/release APK assembly. A successful
build does not prove Mapbox tiles, Foursquare PlacePicker, permission UI,
location behavior, or marker animation. Record those separately on an emulator
or physical device using non-sensitive test accounts and non-private locations.

## Known Boundary

The app keeps `minSdkVersion 21`, `compileSdkVersion 23`, and
`targetSdkVersion 23`, plus legacy Mapbox 4.2.0-beta.5 and PlacePicker 0.6.1.
Modern Android Studio, JDK, emulator, and provider behavior may differ. Follow
the Android modernization plan for any dependency, AndroidX, wrapper, SDK, or
runtime migration instead of silently changing this baseline during setup.
