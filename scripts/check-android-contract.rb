#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

ROOT = Pathname.new(__dir__).parent.expand_path
DOCS_PLANS = ROOT.join('docs/plans')
CANONICAL_PLAN = DOCS_PLANS.join('2026-06-08-ride-up-baseline.md')
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
    unless permission_result.include?('allLocationPermissionsGranted(grantResults)')
      failures << "#{main_activity} must require every requested location permission grant before fetching the closest place"
    end

    if permission_result.include?('grantResults[0] == PackageManager.PERMISSION_GRANTED')
      failures << "#{main_activity} must not check only the first location permission result"
    end

    unless permission_result.include?('super.onRequestPermissionsResult(requestCode, permissions, grantResults);')
      failures << "#{main_activity} must forward non-location permission results to the superclass"
    end
  end

  unless source.include?('private boolean allLocationPermissionsGranted(int[] grantResults)') &&
         source.include?('if (grantResults.length == 0)') &&
         source.include?('for (int result : grantResults)') &&
         source.include?('result != PackageManager.PERMISSION_GRANTED')
    failures << "#{main_activity} must define allLocationPermissionsGranted(int[]) with empty-result and per-result denial checks"
  end
else
  failures << "#{main_activity} is missing"
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
else
  failures << "#{gitignore} is missing"
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

  if manifest_package && application_id && application_id != manifest_package
    failures << "#{app_build_gradle} applicationId #{application_id} must match manifest package #{manifest_package}"
  end
else
  failures << "#{app_build_gradle} is missing"
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

if failures.empty?
  puts 'Android contract checks passed'
else
  warn "Android contract checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
