#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'open3'

ROOT = Pathname.new(__dir__).parent.expand_path
DOCS_PLANS = ROOT.join('docs/plans')
CANONICAL_PLAN = DOCS_PLANS.join('2026-06-08-ride-up-baseline.md')
IDE_METADATA_PLAN = DOCS_PLANS.join('2026-06-09-ide-metadata-ignore.md')
LAUNCHER_EXPORT_PLAN = DOCS_PLANS.join('2026-06-09-launcher-export-contract.md')
MODERNIZATION_PLAN = DOCS_PLANS.join('2026-06-10-android-modernization-plan.md')
HOSTED_VALIDATION_PLAN = DOCS_PLANS.join('2026-06-10-hosted-contract-validation.md')
GUARD_TEST_PLAN = DOCS_PLANS.join('2026-06-12-pure-java-guard-tests.md')
DEPENDENCY_REVIEW_PLAN = DOCS_PLANS.join('2026-06-12-dependency-security-review.md')
HOSTED_VALIDATION_WORKFLOW = ROOT.join('.github/workflows/check.yml')
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

if ROOT.join('.travis.yml').exist?
  failures << '.travis.yml is obsolete and must not replace the hosted contract workflow'
end

if HOSTED_VALIDATION_WORKFLOW.file?
  workflow = HOSTED_VALIDATION_WORKFLOW.read
  [
    'runs-on: ubuntu-24.04',
    'timeout-minutes: 5',
    'cancel-in-progress: true',
    'permissions:',
    'contents: read',
    'uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10',
    'persist-credentials: false',
    'uses: actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654',
    'distribution: corretto',
    "java-version: '17'",
    'run: make check'
  ].each do |fragment|
    failures << "#{rel(HOSTED_VALIDATION_WORKFLOW)} must include #{fragment.inspect}" unless workflow.include?(fragment)
  end

  actions = workflow.scan(/^\s*(?:-\s*)?uses:\s*([^@\s]+)@([^\s#]+)/)
  expected_actions = [
    ['actions/checkout', 'df4cb1c069e1874edd31b4311f1884172cec0e10'],
    ['actions/setup-java', 'be666c2fcd27ec809703dec50e508c2fdc7f6654']
  ]
  failures << "#{rel(HOSTED_VALIDATION_WORKFLOW)} must use only approved actions" unless actions == expected_actions

  unless workflow.scan(/^permissions:$/).length == 1 &&
         !workflow.match?(/^\s+[A-Za-z0-9_-]+:\s*write\s*$/)
    failures << "#{rel(HOSTED_VALIDATION_WORKFLOW)} must keep exactly one read-only permissions block"
  end

  unless workflow.scan(/persist-credentials:\s*false/).length == 1
    failures << "#{rel(HOSTED_VALIDATION_WORKFLOW)} must disable persisted checkout credentials exactly once"
  end

  %w[push: pull_request: workflow_dispatch:].each do |trigger|
    failures << "#{rel(HOSTED_VALIDATION_WORKFLOW)} must include #{trigger}" unless workflow.match?(/^  #{Regexp.escape(trigger)}$/)
  end

  if workflow.include?('pull_request_target:')
    failures << "#{rel(HOSTED_VALIDATION_WORKFLOW)} must not run untrusted pull requests with target-branch privileges"
  end

  actions.each do |action, revision|
    unless revision.match?(/\A[a-f0-9]{40}\z/)
      failures << "#{rel(HOSTED_VALIDATION_WORKFLOW)} action #{action} must be pinned to a full commit SHA"
    end
  end

  if workflow.match?(/\b(?:gradle|npm|bundle|gem)\s+(?:install|build|test)\b/) ||
     workflow.match?(/\.\/gradlew\s+(?:build|test|assemble)/)
    failures << "#{rel(HOSTED_VALIDATION_WORKFLOW)} must keep hosted validation dependency-free"
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
  unless plan.include?('Status: Completed') && plan.include?('make check')
    failures << "#{rel(plan_path)} must record completed status and make check verification"
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
  end

  permission_result = java_method_source(source, 'public void onRequestPermissionsResult(')
  if permission_result.nil?
    failures << "#{main_activity} onRequestPermissionsResult could not be validated"
  else
    unless permission_result.include?('RideUpGuards.allPermissionsGranted(') &&
           permission_result.include?('PackageManager.PERMISSION_GRANTED')
      failures << "#{main_activity} must require every requested location permission grant before fetching the closest place"
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
  unless helper.include?('grantResults == null || grantResults.length == 0') &&
         helper.include?('for (int result : grantResults)') &&
         helper.include?('result != grantedValue')
    failures << "#{guard_helper} must reject null, empty, and partially denied permission results"
  end
  unless helper.include?('requestCode == expectedRequestCode') &&
         helper.include?('resultCode == expectedResultCode')
    failures << "#{guard_helper} must require matching request and result codes"
  end
else
  failures << "#{guard_helper} is missing"
end

{
  guard_unit_test => %w[activityResultRequiresMatchingRequestAndResultCodes permissionsRequireEveryResultToBeGranted],
  guard_contract_test => ['matching activity result should be accepted', 'partial permission grants should be rejected'],
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
  read(build_gradle).scan(/maven\s*\{\s*url\s+["'](http:\/\/[^"']+)["']/).flatten.each do |url|
    failures << "#{build_gradle} uses insecure repository URL #{url}"
  end
else
  failures << "#{build_gradle} is missing"
end

manifest_package = nil
if file?(manifest)
  manifest_source = read(manifest)
  manifest_package = manifest_source[/<manifest\b[^>]*\bpackage="([^"]+)"/, 1]
  failures << "#{manifest} must declare a package name" if manifest_package.nil? || manifest_package.empty?
  failures << "#{manifest} must disable Android backups for credential and location safety" unless manifest_source.include?('android:allowBackup="false"')
  unless manifest_source.match?(/<activity\b[^>]*android:name="\.MainActivity"[^>]*android:exported="true"/m)
    failures << "#{manifest} must explicitly export the launcher MainActivity"
  end
  %w[
    android.permission.ACCESS_COARSE_LOCATION
    android.permission.ACCESS_FINE_LOCATION
    android.permission.INTERNET
  ].each do |permission|
    failures << "#{manifest} must declare #{permission}" unless manifest_source.include?(permission)
  end
else
  failures << "#{manifest} is missing"
end

if file?(app_build_gradle)
  app_gradle_source = read(app_build_gradle)
  application_id = app_gradle_source[/applicationId\s+"([^"]+)"/, 1]
  failures << "#{app_build_gradle} must declare applicationId" if application_id.nil? || application_id.empty?
  unless app_gradle_source.include?('compileSdkVersion 23') &&
         app_gradle_source.include?('targetSdkVersion 23')
    failures << "#{app_build_gradle} must keep the current SDK 23 baseline visible until the modernization plan is executed"
  end
  unless app_gradle_source.include?("testCompile 'junit:junit:4.13.2'")
    failures << "#{app_build_gradle} must use the maintained JUnit 4.13.2 test dependency"
  end
  unless app_gradle_source.include?("compile 'com.google.code.gson:gson:2.8.9'")
    failures << "#{app_build_gradle} must override PlacePicker's vulnerable Gson 2.5 dependency"
  end

  if manifest_package && application_id && application_id != manifest_package
    failures << "#{app_build_gradle} applicationId #{application_id} must match manifest package #{manifest_package}"
  end
else
  failures << "#{app_build_gradle} is missing"
end

makefile = read('Makefile')
unless makefile.include?('$(RUBY) "$(ROOT)/scripts/test-ride-up-guards.rb"')
  failures << 'Makefile test target must run the pure Java guard behavior harness from ROOT'
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

if failures.empty?
  puts 'Android contract checks passed'
else
  warn "Android contract checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
