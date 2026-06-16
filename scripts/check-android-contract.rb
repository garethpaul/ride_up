#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'open3'
require_relative 'android-manifest-contract'
require_relative 'delayed-marker-contract'

ROOT = Pathname.new(__dir__).parent.expand_path
DOCS_PLANS = ROOT.join('docs/plans')
CANONICAL_PLAN = DOCS_PLANS.join('2026-06-08-ride-up-baseline.md')
IDE_METADATA_PLAN = DOCS_PLANS.join('2026-06-09-ide-metadata-ignore.md')
LAUNCHER_EXPORT_PLAN = DOCS_PLANS.join('2026-06-09-launcher-export-contract.md')
MODERNIZATION_PLAN = DOCS_PLANS.join('2026-06-10-android-modernization-plan.md')
HOSTED_VALIDATION_PLAN = DOCS_PLANS.join('2026-06-10-hosted-contract-validation.md')
GUARD_TEST_PLAN = DOCS_PLANS.join('2026-06-12-pure-java-guard-tests.md')
DEPENDENCY_REVIEW_PLAN = DOCS_PLANS.join('2026-06-12-dependency-security-review.md')
HOSTED_BUILD_PLAN = DOCS_PLANS.join('2026-06-12-hosted-android-build.md')
PERMISSION_IDENTITY_PLAN = DOCS_PLANS.join('2026-06-12-location-permission-identity.md')
GRADLE_CHECKSUM_PLAN = DOCS_PLANS.join('2026-06-12-gradle-distribution-checksum.md')
MAKE_ROOT_PLAN = DOCS_PLANS.join('2026-06-14-make-root-override-protection.md')
MARKER_ANIMATION_PLAN = DOCS_PLANS.join('2026-06-14-marker-animation-lifecycle.md')
DELAYED_MARKER_PLAN = DOCS_PLANS.join('2026-06-16-delayed-marker-population-lifecycle.md')
HOSTED_VALIDATION_WORKFLOW = ROOT.join('.github/workflows/check.yml')
CODEOWNERS = ROOT.join('.github/CODEOWNERS')
GRADLE_RUNNER = ROOT.join('scripts/run-android-gradle.sh')
LINT_CONFIG = ROOT.join('app/lint.xml')
WRAPPER_PROPERTIES = ROOT.join('gradle/wrapper/gradle-wrapper.properties')
failures = []

def read(path)
  ROOT.join(path).read
end

def file?(path)
  ROOT.join(path).file?
end

def rel(path)
  Pathname.new(path).relative_path_from(ROOT).to_s
end

def local_landing_asset?(reference)
  !reference.match?(%r{\A(?:https?:)?//}) &&
    !reference.start_with?('#') &&
    !reference.start_with?('mailto:')
end

def normalize_landing_asset(reference)
  reference.split(/[?#]/, 2).first.sub(%r{\A/}, '')
end

def java_method_source(source, signature)
  start_index = source.index(signature)
  return nil unless start_index

  brace_index = source.index('{', start_index)
  return nil unless brace_index

  depth = 0
  index = brace_index
  while index < source.length
    character = source[index, 1]
    depth += 1 if character == '{'
    depth -= 1 if character == '}'
    return source[start_index..index] if depth.zero?

    index += 1
  end

  nil
end

if CANONICAL_PLAN.file?
  # The canonical plan documents the current credential and package checks.
else
  failures << "#{rel(CANONICAL_PLAN)} is missing"
end

failures << "#{rel(IDE_METADATA_PLAN)} is missing" unless IDE_METADATA_PLAN.file?
failures << "#{rel(LAUNCHER_EXPORT_PLAN)} is missing" unless LAUNCHER_EXPORT_PLAN.file?
failures << "#{rel(MODERNIZATION_PLAN)} is missing" unless MODERNIZATION_PLAN.file?
failures << "#{rel(HOSTED_VALIDATION_PLAN)} is missing" unless HOSTED_VALIDATION_PLAN.file?
failures << "#{rel(GUARD_TEST_PLAN)} is missing" unless GUARD_TEST_PLAN.file?
failures << "#{rel(DEPENDENCY_REVIEW_PLAN)} is missing" unless DEPENDENCY_REVIEW_PLAN.file?
failures << "#{rel(HOSTED_BUILD_PLAN)} is missing" unless HOSTED_BUILD_PLAN.file?
failures << "#{rel(PERMISSION_IDENTITY_PLAN)} is missing" unless PERMISSION_IDENTITY_PLAN.file?
failures << "#{rel(GRADLE_CHECKSUM_PLAN)} is missing" unless GRADLE_CHECKSUM_PLAN.file?
failures << "#{rel(MARKER_ANIMATION_PLAN)} is missing" unless MARKER_ANIMATION_PLAN.file?

if ROOT.join('.travis.yml').exist?
  failures << '.travis.yml is obsolete and must not replace the hosted contract workflow'
end

if HOSTED_VALIDATION_WORKFLOW.file?
  expected_workflow = <<~'YAML'
    name: Check

    on:
      push:
      pull_request:
      workflow_dispatch:

    permissions:
      contents: read

    env:
      FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true

    concurrency:
      group: check-${{ github.workflow }}-${{ github.ref }}
      cancel-in-progress: true

    jobs:
      check:
        runs-on: ubuntu-24.04
        timeout-minutes: 15
        steps:
          - name: Check out repository
            uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
            with:
              persist-credentials: false

          - name: Install Android SDK packages
            run: '"${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-23" "build-tools;28.0.3"'

          - name: Set up Java
            uses: actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 # v5.2.0
            with:
              distribution: corretto
              java-version: '8'

          - name: Run full verification
            run: make check
  YAML
  unless HOSTED_VALIDATION_WORKFLOW.read == expected_workflow
    failures << "#{rel(HOSTED_VALIDATION_WORKFLOW)} must match the exact complete Android verification workflow"
  end
else
  failures << "#{rel(HOSTED_VALIDATION_WORKFLOW)} is missing"
end

docs_plans = Dir.glob(DOCS_PLANS.join('*.md')).sort
if docs_plans.empty?
  failures << 'docs/plans must contain at least one completed plan'
end

docs_plans.each do |plan_path|
  plan = File.read(plan_path)
  next if Pathname.new(plan_path) == HOSTED_BUILD_PLAN

  unless plan.include?('Status: Completed') && plan.include?('make check')
    failures << "#{rel(plan_path)} must record completed status and make check verification"
  end
end

if HOSTED_BUILD_PLAN.file?
  hosted_build_plan = HOSTED_BUILD_PLAN.read
  unless hosted_build_plan.include?('## Status: Completed')
    failures << "#{rel(HOSTED_BUILD_PLAN)} must record completed status"
  end
  [
    'AGP 3.3.2 with Gradle 4.10.2 and build-tools 28.0.3',
    'Run SDK-backed Gradle tests, lint, and debug assembly locally.',
    'Repeat the complete gate from a fresh external clone.',
    'SDK-backed `make check` passed with Android API 23 and build-tools 28.0.3',
    'All 28 focused toolchain, dependency, workflow, runner, lint, ownership,',
    'c1826e4f8cf0de0ae596d55a26621e901556efe0',
    'canonical push run `27403417451` and pull-request run `27403418502`',
    'Pass exact-head hosted verification before completion.'
  ].each do |evidence|
    unless hosted_build_plan.include?(evidence)
      failures << "#{rel(HOSTED_BUILD_PLAN)} must record #{evidence.inspect}"
    end
  end
end

main_activity = 'app/src/main/java/com/foursquare/rideup/MainActivity.java'
guard_helper = 'app/src/main/java/com/foursquare/rideup/RideUpGuards.java'
guard_unit_test = 'app/src/test/java/com/foursquare/rideup/RideUpGuardsTest.java'
guard_contract_test = 'scripts/java/com/foursquare/rideup/RideUpGuardsContractTest.java'
guard_test_runner = 'scripts/test-ride-up-guards.rb'
constants_example = 'app/src/main/java/com/foursquare/rideup/Constants.java.example'
gitignore = '.gitignore'
build_gradle = 'build.gradle'
app_build_gradle = 'app/build.gradle'
manifest = 'app/src/main/AndroidManifest.xml'
landing_page = 'index.html'
drawable_root = 'app/src/main/res/drawable'

if file?(main_activity)
  source = read(main_activity)
  %w[MAPBOX_ACCESS_TOKEN FOURSQUARE_CLIENT_KEY FOURSQUARE_CLIENT_SECRET].each do |constant|
    failures << "#{main_activity} does not reference Constants.#{constant}" unless source.include?("Constants.#{constant}")
  end

  unless source.include?('if (data == null)')
    failures << "#{main_activity} must ignore PlacePicker results with null Intent data"
  end

  unless source.include?('if (place == null)')
    failures << "#{main_activity} must ignore PlacePicker results without a Venue payload"
  end

  unless source.include?('if (place.getLocation() == null)')
    failures << "#{main_activity} must ignore PlacePicker results without a Venue location"
  end

  unless source.include?('if (mapboxMap != null)')
    failures << "#{main_activity} must guard map updates until Mapbox is ready"
  end

  unless source.match?(/private static final int PLACE_PICKER_REQUEST\s*=\s*\d+;/) &&
         source.include?('startActivityForResult(intent, PLACE_PICKER_REQUEST);')
    failures << "#{main_activity} must launch PlacePicker with a named request-code constant"
  end

  unless source.scan(/private static final String\[\] LOCATION_PERMISSIONS/).length == 1 &&
         source.match?(/private static final String\[\] LOCATION_PERMISSIONS\s*=\s*new String\[\]\s*\{\s*Manifest\.permission\.ACCESS_COARSE_LOCATION,\s*Manifest\.permission\.ACCESS_FINE_LOCATION\s*\};/m)
    failures << "#{main_activity} must define the exact expected location permission set once"
  end

  activity_result = java_method_source(source, 'protected void onActivityResult(')
  if activity_result.nil?
    failures << "#{main_activity} onActivityResult could not be validated"
  else
    unless activity_result.include?('RideUpGuards.isExpectedActivityResult(') &&
           activity_result.include?('PLACE_PICKER_REQUEST') &&
           activity_result.include?('PlacePicker.PLACE_PICKED_RESULT_CODE')
      failures << "#{main_activity} must require matching PlacePicker request and result codes before reading result data"
    end

    unless activity_result.include?('super.onActivityResult(requestCode, resultCode, data);')
      failures << "#{main_activity} must forward unrelated activity results to the superclass"
    end
  end

  unless source.include?('if (venue == null)') && source.include?('if (venue.getLocation() == null)')
    failures << "#{main_activity} must ignore current-place results without a Venue location"
  end

  on_create = java_method_source(source, 'protected void onCreate(Bundle savedInstanceState)')
  if on_create.nil?
    failures << "#{main_activity} onCreate could not be validated"
  else
    unless on_create.include?('boolean hasLocationPermission = locationServices.areLocationPermissionsGranted();')
      failures << "#{main_activity} must cache the startup location permission state"
    end

    unless on_create.match?(/if\s*\(\s*hasLocationPermission\s*\)\s*\{\s*getClosestPlace\(\);\s*\}/m)
      failures << "#{main_activity} must only fetch the closest place during startup when location permission is already granted"
    end

    if on_create.scan('getClosestPlace();').length > 1
      failures << "#{main_activity} onCreate must not fetch the closest place outside the startup permission guard"
    end


    unless on_create.include?('ActivityCompat.requestPermissions(this, LOCATION_PERMISSIONS, PERMISSIONS_LOCATION);')
      failures << "#{main_activity} must request the canonical location permission set"
    end
  end

  permission_result = java_method_source(source, 'public void onRequestPermissionsResult(')
  if permission_result.nil?
    failures << "#{main_activity} onRequestPermissionsResult could not be validated"
  else
    unless permission_result.match?(/RideUpGuards\.areExpectedPermissionsGranted\(\s*permissions,\s*grantResults,\s*LOCATION_PERMISSIONS,\s*PackageManager\.PERMISSION_GRANTED\s*\)/m)
      failures << "#{main_activity} must require the exact requested location permission set before fetching the closest place"
    end

    if permission_result.include?('grantResults[0] == PackageManager.PERMISSION_GRANTED')
      failures << "#{main_activity} must not check only the first location permission result"
    end

    unless permission_result.include?('super.onRequestPermissionsResult(requestCode, permissions, grantResults);')
      failures << "#{main_activity} must forward non-location permission results to the superclass"
    end
  end

  {
    'protected void onDestroy()' => 'mapView.onDestroy();',
    'protected void onResume()' => 'mapView.onResume();',
    'protected void onPause()' => 'mapView.onPause();',
    'protected void onSaveInstanceState(Bundle outState)' => 'mapView.onSaveInstanceState(outState);',
    'public void onLowMemory()' => 'mapView.onLowMemory();'
  }.each do |signature, map_view_call|
    lifecycle_section = java_method_source(source, signature)
    if lifecycle_section.nil?
      failures << "#{main_activity} #{signature} could not be validated"
      next
    end

    unless lifecycle_section.include?('if (mapView != null)') && lifecycle_section.include?(map_view_call)
      failures << "#{main_activity} #{signature} must guard #{map_view_call} behind a non-null mapView check"
    end
  end
else
  failures << "#{main_activity} is missing"
end

if file?(guard_helper)
  helper = read(guard_helper)
  unless helper.include?('static boolean areExpectedPermissionsGranted(') &&
         helper.include?('permissions == null || grantResults == null || expectedPermissions == null') &&
         helper.include?('permissions.length == 0 || permissions.length != grantResults.length') &&
         helper.include?('permissions.length != expectedPermissions.length') &&
         helper.include?('expectedPermission == null || expectedPermission.length() == 0') &&
         helper.include?('expectedPermission.equals(expectedPermissions[previousIndex])') &&
         helper.include?('boolean[] matchedPermissions = new boolean[expectedPermissions.length]') &&
         helper.include?('permission == null || grantResults[resultIndex] != grantedValue') &&
         helper.include?('permission.equals(expectedPermissions[expectedIndex])') &&
         helper.include?('matchedIndex < 0 || matchedPermissions[matchedIndex]')
    failures << "#{guard_helper} must reject missing, duplicate, unknown, misaligned, null, or denied permission entries"
  end
  unless helper.include?('requestCode == expectedRequestCode') &&
         helper.include?('resultCode == expectedResultCode')
    failures << "#{guard_helper} must require matching request and result codes"
  end
else
  failures << "#{guard_helper} is missing"
end

marker_lifecycle = 'app/src/main/java/com/foursquare/rideup/MarkerAnimationLifecycle.java'
marker_lifecycle_test = 'app/src/test/java/com/foursquare/rideup/MarkerAnimationLifecycleTest.java'
marker_contract_test = 'scripts/java/com/foursquare/rideup/MarkerAnimationLifecycleContractTest.java'

if file?(marker_lifecycle)
  lifecycle_source = read(marker_lifecycle)
  unless lifecycle_source.include?('private boolean active;') &&
         lifecycle_source.include?('void resume()') &&
         lifecycle_source.include?('void pause()') &&
         lifecycle_source.include?('return active && !canceled;')
    failures << "#{marker_lifecycle} must gate animation and canceled-completion restarts"
  end
else
  failures << "#{marker_lifecycle} is missing"
end

if file?(main_activity)
  activity_source = read(main_activity)
  DelayedMarkerContract.failures(activity_source).each do |failure|
    failures << "#{main_activity} #{failure}"
  end
  on_resume = java_method_source(activity_source, 'protected void onResume()')
  on_pause = java_method_source(activity_source, 'protected void onPause()')
  on_destroy = java_method_source(activity_source, 'protected void onDestroy()')
  move_marker = java_method_source(activity_source, 'private void randomlyMoveMarker(')
  build_animator = java_method_source(activity_source, 'private ValueAnimator animateMoveMarker(')
  unless activity_source.include?('private final List<MarkerView> carMarkers = new ArrayList<>();') &&
         activity_source.include?('private final List<ValueAnimator> carAnimators = new ArrayList<>();') &&
         activity_source.include?('carMarkers.add(car);')
    failures << "#{main_activity} must track simulated markers and their active animators"
  end
  unless on_resume&.include?('markerAnimationLifecycle.resume();') &&
         on_resume&.include?('for (MarkerView marker : new ArrayList<>(carMarkers))') &&
         on_pause&.include?('stopMarkerAnimations();') &&
         on_destroy&.include?('stopMarkerAnimations();')
    failures << "#{main_activity} must stop animations on pause/destroy and resume existing markers"
  end
  unless move_marker&.include?('if (!markerAnimationLifecycle.canAnimate())') &&
         move_marker&.include?('public void onAnimationCancel(Animator animation)') &&
         move_marker&.include?('if (markerAnimationLifecycle.shouldRestart(canceled))') &&
         move_marker&.include?('animator.start();') &&
         !build_animator&.include?('markerAnimator.start();')
    failures << "#{main_activity} must suppress canceled or inactive completion restarts"
  end
else
  failures << "#{main_activity} is missing"
end

if DELAYED_MARKER_PLAN.file?
  delayed_marker_plan = DELAYED_MARKER_PLAN.read
  unless delayed_marker_plan.include?('Status: Completed') &&
         delayed_marker_plan.include?('four delayed-marker mutations were rejected') &&
         delayed_marker_plan.include?('Repository-root and external-directory `make check` passed') &&
         delayed_marker_plan.include?('generated-artifact and credential-pattern audits passed')
    failures << "#{rel(DELAYED_MARKER_PLAN)} must record completed delayed-marker verification"
  end
else
  failures << "#{rel(DELAYED_MARKER_PLAN)} is missing"
end

{
  marker_lifecycle_test => %w[
    animationsAreInactiveUntilResumeAndStopOnPause
    canceledAnimationsNeverRestart
  ],
  marker_contract_test => [
    'animations should start inactive',
    'resume should activate animations',
    'canceled animations should not restart',
    'completed animations should not restart while paused'
  ]
}.each do |test_path, expectations|
  unless file?(test_path)
    failures << "#{test_path} is missing"
    next
  end

  test_source = read(test_path)
  expectations.each do |expectation|
    failures << "#{test_path} must cover #{expectation}" unless test_source.include?(expectation)
  end
end

{
  guard_unit_test => %w[
    activityResultRequiresMatchingRequestAndResultCodes
    permissionsAcceptTheExpectedGrantedSetInAnyOrder
    permissionsRejectMissingOrMisalignedCallbackData
    permissionsRejectUnknownDuplicateNullOrDeniedEntries
  ],
  guard_contract_test => [
    'matching activity result should be accepted',
    'expected granted permissions should be order independent',
    'null permission results should be rejected',
    'null expected permissions should be rejected',
    'missing expected permissions should be rejected',
    'misaligned permission results should be rejected',
    'unknown permissions should be rejected',
    'duplicate permissions should be rejected',
    'partial permission grants should be rejected'
  ],
  guard_test_runner => ['javac', 'java', 'Dir.mktmpdir']
}.each do |path, fragments|
  unless file?(path)
    failures << "#{path} is missing"
    next
  end

  content = read(path)
  fragments.each do |fragment|
    failures << "#{path} must include #{fragment.inspect}" unless content.include?(fragment)
  end
end

if file?(constants_example)
  example = read(constants_example)
  failures << "#{constants_example} must define class Constants" unless example.match?(/\bclass\s+Constants\b/)
  %w[MAPBOX_ACCESS_TOKEN FOURSQUARE_CLIENT_KEY FOURSQUARE_CLIENT_SECRET].each do |constant|
    unless example.match?(/\b#{constant}\b\s*=\s*"[^"]+"/)
      failures << "#{constants_example} must define #{constant}"
      next
    end
    value = example[/\b#{constant}\b\s*=\s*"([^"]+)"/, 1]
    failures << "#{constants_example} must keep #{constant} as a placeholder" unless value.start_with?('replace-with-')
  end
else
  failures << "#{constants_example} is missing; add a non-secret template for local credentials"
end

if file?(gitignore)
  ignored = read(gitignore).lines.map(&:strip)
  failures << "#{gitignore} must keep local Constants.java ignored" unless ignored.include?('Constants.java')
  failures << "#{gitignore} must keep local .idea metadata ignored" unless ignored.include?('.idea/')
  failures << "#{gitignore} must keep local IntelliJ module files ignored" unless ignored.include?('*.iml')
else
  failures << "#{gitignore} is missing"
end

tracked_output, tracked_error, tracked_status = Open3.capture3(
  'git', '-C', ROOT.to_s, 'ls-files', '.idea', '*.iml'
)
if tracked_status.success?
  tracked_ide_metadata = tracked_output.split("\n").select { |path| ROOT.join(path).file? }
  unless tracked_ide_metadata.empty?
    failures << "IDE metadata must not be tracked: #{tracked_ide_metadata.join(', ')}"
  end
else
  failures << "git metadata inspection failed: #{tracked_error.strip}"
end

if file?(build_gradle)
  root_gradle_source = read(build_gradle)
  root_gradle_source.scan(/maven\s*\{\s*url\s+["'](http:\/\/[^"']+)["']/).flatten.each do |url|
    failures << "#{build_gradle} uses insecure repository URL #{url}"
  end
  unless root_gradle_source.include?("classpath 'com.android.tools.build:gradle:3.3.2'")
    failures << "#{build_gradle} must use the published AGP 3.3.2 compatibility bridge"
  end
else
  failures << "#{build_gradle} is missing"
end

if WRAPPER_PROPERTIES.file?
  wrapper_lines = WRAPPER_PROPERTIES.read.lines.map(&:strip)
  distribution_urls = wrapper_lines.grep(/\AdistributionUrl=/)
  distribution_checksums = wrapper_lines.grep(/\AdistributionSha256Sum=/)
  expected_distribution_url = 'distributionUrl=https\://services.gradle.org/distributions/gradle-4.10.2-all.zip'
  expected_distribution_checksum = 'distributionSha256Sum=b7aedd369a26b177147bcb715f8b1fc4fe32b0a6ade0d7fd8ee5ed0c6f731f2c'

  unless distribution_urls == [expected_distribution_url]
    failures << "#{rel(WRAPPER_PROPERTIES)} must declare exactly the AGP-compatible Gradle 4.10.2 distribution URL"
  end
  unless distribution_checksums == [expected_distribution_checksum]
    failures << "#{rel(WRAPPER_PROPERTIES)} must declare exactly the official Gradle 4.10.2 all-distribution SHA-256"
  end
else
  failures << "#{rel(WRAPPER_PROPERTIES)} is missing"
end

manifest_package = nil
if file?(manifest)
  manifest_source = read(manifest)
  AndroidManifestContract.telemetry_service_failures(manifest_source).each do |failure|
    failures << "#{manifest} #{failure}"
  end
  AndroidManifestContract.permission_failures(manifest_source).each do |failure|
    failures << "#{manifest} #{failure}"
  end
  manifest_package = manifest_source[/<manifest\b[^>]*\bpackage="([^"]+)"/, 1]
  failures << "#{manifest} must declare a package name" if manifest_package.nil? || manifest_package.empty?
  failures << "#{manifest} must disable Android backups for credential and location safety" unless manifest_source.include?('android:allowBackup="false"')
  unless manifest_source.match?(/<activity\b[^>]*android:name="\.MainActivity"[^>]*android:exported="true"/m)
    failures << "#{manifest} must explicitly export the launcher MainActivity"
  end
else
  failures << "#{manifest} is missing"
end

if file?(app_build_gradle)
  app_gradle_source = read(app_build_gradle)
  application_id = app_gradle_source[/applicationId\s+"([^"]+)"/, 1]
  failures << "#{app_build_gradle} must declare applicationId" if application_id.nil? || application_id.empty?
  unless app_gradle_source.include?('compileSdkVersion 23') &&
         app_gradle_source.include?('targetSdkVersion 23') &&
         app_gradle_source.include?('buildToolsVersion "28.0.3"')
    failures << "#{app_build_gradle} must keep the current SDK 23 baseline visible until the modernization plan is executed"
  end
  unless app_gradle_source.include?('minSdkVersion 21')
    failures << "#{app_build_gradle} must keep the OkHttp 4.x Android API 21 minimum"
  end
  [
    "implementation 'com.squareup.okhttp3:okhttp:4.9.2'",
    "implementation 'com.squareup.okhttp3:logging-interceptor:4.9.2'",
    "resolutionStrategy.force 'com.squareup.okhttp3:okhttp:4.9.2'",
    "resolutionStrategy.force 'com.squareup.okhttp3:logging-interceptor:4.9.2'",
    'task verifyOkHttpResolution',
    "['debugRuntimeClasspath', 'releaseRuntimeClasspath']",
    "'logging-interceptor:4.9.2'",
    "'okhttp:4.9.2'"
  ].each do |contract|
    unless app_gradle_source.include?(contract)
      failures << "#{app_build_gradle} must preserve OkHttp security contract #{contract.inspect}"
    end
  end
  if app_gradle_source.match?(/com\.squareup\.okhttp3:(?:okhttp|logging-interceptor):3\./)
    failures << "#{app_build_gradle} must not restore vulnerable OkHttp 3.x declarations"
  end
  unless app_gradle_source.include?("testImplementation 'junit:junit:4.13.2'")
    failures << "#{app_build_gradle} must use the maintained JUnit 4.13.2 test dependency"
  end
  unless app_gradle_source.include?("implementation 'com.google.code.gson:gson:2.8.9'")
    failures << "#{app_build_gradle} must override PlacePicker's vulnerable Gson 2.5 dependency"
  end
  if app_gradle_source.match?(/^\s*(?:compile|testCompile)\b/)
    failures << "#{app_build_gradle} must not restore obsolete dependency configurations"
  end

  if manifest_package && application_id && application_id != manifest_package
    failures << "#{app_build_gradle} applicationId #{application_id} must match manifest package #{manifest_package}"
  end
else
  failures << "#{app_build_gradle} is missing"
end

makefile = read('Makefile')
root_declaration = 'override ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))'
unless makefile.lines.first&.chomp == root_declaration &&
       makefile.scan(/^override ROOT :=/).length == 1 &&
       makefile.scan(/^ROOT\s*[:?+]?=/).empty?
  failures << 'Makefile must define exactly one protected repository-derived ROOT declaration first'
end
unless makefile.include?('$(RUBY) "$(ROOT)/scripts/test-ride-up-guards.rb"')
  failures << 'Makefile test target must run the pure Java guard behavior harness from ROOT'
end
[
  'ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))',
  "test:\n",
  'scripts/run-android-gradle.sh lint',
  'scripts/run-android-gradle.sh test',
  'scripts/run-android-gradle.sh assembleDebug'
].each do |fragment|
  failures << "Makefile must include #{fragment.inspect}" unless makefile.include?(fragment)
end

if GRADLE_RUNNER.file?
  runner = GRADLE_RUNNER.read
  [
    'CONSTANTS="$ROOT/app/src/main/java/com/foursquare/rideup/Constants.java"',
    'EXAMPLE="$CONSTANTS.example"',
    'trap cleanup 0',
    "trap 'exit 129' HUP",
    "trap 'exit 130' INT",
    "trap 'exit 143' TERM",
    'cp "$EXAMPLE" "$CONSTANTS"',
    'rm -f "$CONSTANTS"',
    './gradlew --no-daemon "$@"'
  ].each do |fragment|
    failures << "#{rel(GRADLE_RUNNER)} must include #{fragment.inspect}" unless runner.include?(fragment)
  end
  failures << "#{rel(GRADLE_RUNNER)} must be executable" unless GRADLE_RUNNER.executable?
else
  failures << "#{rel(GRADLE_RUNNER)} is missing"
end

if LINT_CONFIG.file?
  lint = LINT_CONFIG.read
  %w[LintError ExpiredTargetSdkVersion].each do |issue|
    failures << "#{rel(LINT_CONFIG)} must document #{issue}" unless lint.include?(%Q(id="#{issue}"))
  end
  failures << "#{rel(LINT_CONFIG)} must keep exactly two scoped suppressions" unless lint.scan(/<issue\s+id=/).length == 2
  unless lint.include?('regexp="Unexpected failure during lint analysis of module-info\\.class"')
    failures << "#{rel(LINT_CONFIG)} must scope LintError to the known Gson module descriptor failure"
  end
  unless lint.include?('<issue id="ExpiredTargetSdkVersion" severity="ignore" />')
    failures << "#{rel(LINT_CONFIG)} must scope the deferred target SDK finding by issue ID"
  end
else
  failures << "#{rel(LINT_CONFIG)} is missing"
end

expected_codeowners = <<~OWNERS
  /.github/CODEOWNERS @garethpaul
  /.github/workflows/ @garethpaul
  /Makefile @garethpaul
  /scripts/ @garethpaul
  /build.gradle @garethpaul
  /app/build.gradle @garethpaul
  /app/lint.xml @garethpaul
  /gradle/wrapper/gradle-wrapper.properties @garethpaul
  /app/src/main/ @garethpaul
OWNERS
unless CODEOWNERS.file? && CODEOWNERS.read == expected_codeowners
  failures << "#{rel(CODEOWNERS)} must protect the hosted build, credential, and app boundaries"
end

if file?(landing_page)
  landing_source = read(landing_page)
  if manifest_package && !landing_source.include?("id=#{manifest_package}")
    failures << "#{landing_page} Google Play link must reference #{manifest_package}"
  end

  landing_source.scan(/\b(?:src|href)=["']([^"']+)["']/).flatten.each do |reference|
    next unless local_landing_asset?(reference)

    normalized = normalize_landing_asset(reference)
    next if normalized.empty?

    asset_path = ROOT.join(normalized).cleanpath
    unless asset_path.to_s.start_with?("#{ROOT}/")
      failures << "#{landing_page} local asset #{reference} must stay inside the repository"
      next
    end

    failures << "#{landing_page} references missing local asset #{reference}" unless asset_path.file?
  end
else
  failures << "#{landing_page} is missing"
end

if Dir.exist?(ROOT.join(drawable_root))
  drawable_names = Dir.glob(ROOT.join(drawable_root, '*'))
                      .select { |path| File.file?(path) }
                      .map { |path| File.basename(path, '.*') }
                      .uniq

  Dir.glob(ROOT.join('app/src/main/java/**/*.java')).sort.each do |java_path|
    source = File.read(java_path)
    source.scan(/\bR\.drawable\.([A-Za-z_][A-Za-z0-9_]*)\b/).flatten.uniq.each do |drawable|
      next if drawable_names.include?(drawable)

      failures << "#{rel(java_path)} references missing drawable #{drawable}"
    end
  end
else
  failures << "#{drawable_root} is missing"
end

readme = read('README.md')
vision = read('VISION.md')
security = read('SECURITY.md')
changes = read('CHANGES.md')
unless [readme, vision, security, changes].all? { |text| text.include?('Android modernization plan') }
  failures << 'docs must mention the Android modernization plan'
end

unless [readme, vision, security, changes].all? { |text| text.include?('guard behavior') }
  failures << 'docs must mention executable guard behavior validation'
end

[
  'Android Gradle Plugin 3.3.2 and Gradle 4.10.2',
  'Android API 23 and build-tools 28.0.3',
  'temporary non-secret',
  '`app/lint.xml` suppresses only'
].each do |fragment|
  failures << "README.md must document #{fragment.inspect}" unless readme.include?(fragment)
end

unless changes.include?('AGP 3.3.2, Gradle 4.10.2') &&
       changes.include?('temporary non-secret')
  failures << 'CHANGES.md must record the hosted Android build bridge'
end

unless [readme, security, changes].all? { |text| text.include?('b7aedd369a26b177147bcb715f8b1fc4fe32b0a6ade0d7fd8ee5ed0c6f731f2c') }
  failures << 'README.md, SECURITY.md, and CHANGES.md must record the verified Gradle 4.10.2 distribution checksum'
end

modernization_plan = MODERNIZATION_PLAN.file? ? MODERNIZATION_PLAN.read : ''
unless modernization_plan.include?('Status: Completed') &&
       modernization_plan.include?('make check') &&
       modernization_plan.include?('compileSdkVersion 23') &&
       modernization_plan.include?('targetSdkVersion 23') &&
       modernization_plan.include?('AndroidX')
  failures << "#{rel(MODERNIZATION_PLAN)} must record the SDK 23 baseline, AndroidX migration path, and make check verification"
end

dependency_review = DEPENDENCY_REVIEW_PLAN.file? ? DEPENDENCY_REVIEW_PLAN.read : ''
unless dependency_review.include?('CVE-2021-0341') &&
       dependency_review.include?('CVE-2022-25647') &&
       dependency_review.include?('Gson 2.8.9') &&
       dependency_review.include?('OkHttp 4.9.2')
  failures << "#{rel(DEPENDENCY_REVIEW_PLAN)} must record fixed and unresolved dependency advisories"
end

makefile_source = ROOT.join('Makefile').read
unless makefile_source.include?('scripts/run-android-gradle.sh verifyOkHttpResolution') &&
       makefile_source.include?('scripts/run-android-gradle.sh assembleDebug assembleRelease') &&
       makefile_source.match?(/^verify: dependency lint test build$/)
  failures << 'Makefile must verify resolved OkHttp and assemble debug/release APKs in the Android gates'
end


permission_identity_plan = PERMISSION_IDENTITY_PLAN.file? ? PERMISSION_IDENTITY_PLAN.read : ''
unless permission_identity_plan.include?('Status: Completed') &&
       permission_identity_plan.include?('ruby scripts/test-ride-up-guards.rb') &&
       permission_identity_plan.include?('ruby scripts/check-android-contract.rb') &&
       permission_identity_plan.include?('make check') &&
       permission_identity_plan.include?('hostile permission-identity mutations')
  failures << "#{rel(PERMISSION_IDENTITY_PLAN)} must record completed status and actual permission-identity verification"
end

gradle_checksum_plan = GRADLE_CHECKSUM_PLAN.file? ? GRADLE_CHECKSUM_PLAN.read : ''
unless gradle_checksum_plan.include?('Status: Completed') &&
       gradle_checksum_plan.include?('distributionSha256Sum') &&
       gradle_checksum_plan.include?('ruby scripts/check-android-contract.rb') &&
       gradle_checksum_plan.include?('make check') &&
       gradle_checksum_plan.include?('hostile wrapper mutations') &&
       gradle_checksum_plan.include?('27436088453') &&
       gradle_checksum_plan.include?('27436089863') &&
       gradle_checksum_plan.include?('27436088207') &&
       !gradle_checksum_plan.match?(/pending/i)
  failures << "#{rel(GRADLE_CHECKSUM_PLAN)} must record completed status and actual wrapper-checksum verification"
end

make_root_plan = MAKE_ROOT_PLAN.file? ? MAKE_ROOT_PLAN.read : ''
unless make_root_plan.include?('Status: Completed') &&
       make_root_plan.include?('make ROOT=/tmp check') &&
       make_root_plan.include?('Six root-declaration, static-contract, plan-status, and evidence mutations') &&
       make_root_plan.include?('secret screening') &&
       make_root_plan.include?('generated-artifact')
  failures << "#{rel(MAKE_ROOT_PLAN)} must record completed status and actual root-override verification"
end

if failures.empty?
  puts 'Android contract checks passed'
else
  warn "Android contract checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
