# Security Policy

## Supported Versions

The supported security scope for `ride_up` is the current default branch, `master`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: A ride sharing clone.

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/ride_up` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- This repository appears to be an Android mobile application or sample. The active security scope is the code and documentation on the default branch.
- Review found external API integrations or credential-adjacent configuration; changes in those areas should receive security-focused review before merge.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found mobile permission or privacy-sensitive data handling; changes in those areas should receive security-focused review before merge.
- Review found file, document, data, or media parsing flows; changes in those areas should receive security-focused review before merge.
- Launcher activity exported state should stay explicit in the manifest so
  platform compatibility and entry-point exposure are reviewed together.
- Mapbox telemetry is an internal service and should remain explicitly
  non-exported; manifest changes must not create an external service entry
  point.
- Android permissions are an exact top-level allowlist; changes must not add
  unnamed, nested, duplicate, or unreviewed capabilities.
- Landing-page local asset references should resolve inside the repository;
  parent-directory escapes or missing local files should be treated as
  suspicious.
- The Android modernization plan should be treated as security-sensitive
  compatibility work because SDK, AndroidX, mapping, and permission behavior can
  change together.
- Dependency manifests detected: build.gradle, gradle.properties. Dependency updates should preserve lockfiles when present and avoid introducing packages without a clear maintenance reason.
- Hosted validation installs no project dependencies, grants only read access
  to repository contents, and pins third-party actions by commit.
- Android activity-result request codes are treated as provenance checks;
  unrelated callbacks must not be parsed as PlacePicker venue data.
- Location permission callbacks must identify the exact requested coarse/fine
  permission set once and align each name with a granted result before any
  location-backed lookup starts.
- Hosted guard behavior validation executes permission and request-code
  decisions without loading project dependencies or local credentials.
- Current-place, map-ready, and delayed marker callbacks reject inactive
  activity lifecycle state before registering or mutating map work.

## Mobile Privacy Notes

If this project requests device permissions such as location, camera, microphone, contacts, Bluetooth, health data, or local storage access, reports should describe the permission involved and whether sensitive data can be accessed, persisted, or transmitted unexpectedly. Please avoid testing against real third-party user data or accounts you do not control.

Follow `SETUP.md` for local Mapbox/Foursquare credential handling and the
legacy SDK verification boundary. Never commit the ignored `Constants.java`.

## Dependency and Supply Chain Security

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

- The Gradle wrapper pins the 4.10.2 all-distribution to the publisher-provided
  SHA-256 `b7aedd369a26b177147bcb715f8b1fc4fe32b0a6ade0d7fd8ee5ed0c6f731f2c`.
  The checked-in wrapper scripts and JAR match the Gradle 4.10.2 tagged wrapper
  artifacts. The wrapper JAR has SHA-256
  `f477f0a7223dd6c43391aeb91ffbb15de8f251f1782e847c2270fb7b55c24585`.
  These checks do not establish provenance for application dependencies.

- Gson 2.8.9 overrides PlacePicker's Gson 2.5 dependency to address
  CVE-2022-25647.
- The app now forces OkHttp and its logging interceptor to OkHttp 4.9.2, which
  removes the resolved OkHttp 3.x versions affected by CVE-2021-0341. The
  migration raises the minimum Android version to API 21 and verifies both
  debug and release runtime graphs and APKs. The remaining legacy Mapbox beta
  and Android SDK 23 stack still require broader modernization and device
  testing before production use.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
