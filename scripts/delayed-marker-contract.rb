# frozen_string_literal: true

module DelayedMarkerContract
  module_function

  def failures(source)
    resume_start = source.index('protected void onResume()')
    resume_end = resume_start && source.index('@Override', resume_start + 1)
    return ['MainActivity must retain the resume callback'] unless resume_start && resume_end

    resume = source[resume_start...resume_end]
    resume_active = 'markerAnimationLifecycle.resume();'
    permission_check = 'locationServices.areLocationPermissionsGranted()'
    current_place_request = 'requestCurrentPlaceIfNeeded();'
    unless resume.include?(resume_active) &&
           resume.include?(permission_check) &&
           resume.include?(current_place_request) &&
           resume.index(resume_active) < resume.index(permission_check) &&
           resume.index(permission_check) < resume.index(current_place_request)
      return ['Resume must request current place only after activity and permission are active']
    end

    pause_start = source.index('protected void onPause()')
    pause_end = pause_start && source.index('@Override', pause_start + 1)
    return ['MainActivity must retain the pause callback'] unless pause_start && pause_end

    pause = source[pause_start...pause_end]
    invalidate_request = 'currentPlaceRequestController.invalidate();'
    stop_animations = 'stopMarkerAnimations();'
    unless pause.include?(invalidate_request) &&
           pause.include?(stop_animations) &&
           pause.index(invalidate_request) < pause.index(stop_animations)
      return ['Pause must invalidate current-place work before stopping marker work']
    end

    success_start = source.index('public void success(Venue venue, boolean confident)')
    success_end = success_start && source.index('@Override', success_start + 1)
    return ['MainActivity must retain the current-place success callback'] unless success_start && success_end

    success = source[success_start...success_end]
    success_guard = /if \(!currentPlaceRequestController\.complete\(\s*requestGeneration,\s*markerAnimationLifecycle\.canAnimate\(\),\s*pickupMapState\.hasPickup\(\)\)\) \{\s*return;\s*\}/m
    state_update = 'pickupMapState.updateCurrentPlace('
    request_map = 'requestMapReady();'
    publish_location = 'publishMapLocation();'
    success_guard_start = success.index(success_guard)
    unless success_guard_start &&
           success.include?(state_update) &&
           success.include?(request_map) &&
           success.include?(publish_location) &&
           success_guard_start < success.index(state_update) &&
           success.index(state_update) < success.index(request_map) &&
           success.index(request_map) < success.index(publish_location)
      return ['Current-place callback must retain state and request active map publication']
    end

    map_ready_start = source.index('public void onMapReady(@NonNull final MapboxMap mapboxMap)')
    map_ready_end = map_ready_start && source.index('} // End onMapReady', map_ready_start)
    return ['MainActivity must retain the map-ready callback'] unless map_ready_start && map_ready_end

    map_ready = source[map_ready_start..map_ready_end]
    guard = /if \(!markerAnimationLifecycle\.canAnimate\(\)\) \{\s*return;\s*\}/
    map_assignment = 'MainActivity.this.mapboxMap = mapboxMap;'
    publish_location = 'publishMapLocation();'
    enable_location = 'mapboxMap.setMyLocationEnabled(true);'
    permission_guard = /if \(locationServices\.areLocationPermissionsGranted\(\)\) \{\s*mapboxMap\.setMyLocationEnabled\(true\);\s*\}/
    pickup_guard = /if \(pickupMapState\.hasPickup\(\)\) \{\s*return;\s*\}/
    delayed_start = map_ready.index('handler.postDelayed(new Runnable()')
    schedule_call = map_ready.index('scheduleCarPopulation();')
    guard_start = map_ready.index(guard)
    pickup_guard_start = map_ready.index(pickup_guard)
    permission_guard_start = map_ready.index(permission_guard)
    unless guard_start &&
           map_ready.include?(map_assignment) &&
           map_ready.include?(publish_location) &&
           map_ready.include?(enable_location) &&
           permission_guard_start &&
           pickup_guard_start.nil? &&
           delayed_start.nil? &&
           schedule_call.nil? &&
           guard_start < map_ready.index(map_assignment) &&
           map_ready.index(map_assignment) < map_ready.index(publish_location) &&
           guard_start < permission_guard_start
      return ['Map-ready callback must reject inactive lifecycle state before map mutation']
    end

    apply_start = source.index('private void applyMapPublication(')
    schedule_start = apply_start && source.index('private void scheduleCarPopulation()', apply_start)
    return ['MainActivity must retain publication-driven car scheduling'] unless
      apply_start && schedule_start

    apply = source[apply_start...schedule_start]
    pickup_return = /if \(publication\.isPickup\(\)\) \{.*?return;\s*\}/m
    schedule_call = 'scheduleCarPopulation();'
    unless apply.match?(pickup_return) &&
           apply.include?(schedule_call) &&
           apply.index(pickup_return) < apply.index(schedule_call)
      return ['Car population must follow a positioned current-place publication only']
    end

    delayed_start = source.index('handler.postDelayed(new Runnable()', schedule_start)
    delayed_end = delayed_start && source.index('}, 500);', delayed_start)
    return ['MainActivity must retain the delayed marker runnable'] unless delayed_start && delayed_end

    runnable = source[delayed_start..delayed_end]
    guard = /if \(!markerAnimationLifecycle\.canAnimate\(\) \|\| pickupMapState\.hasPickup\(\)\) \{\s*return;\s*\}/
    loop_start = 'for (int i = 0; i < 10; i++)'
    marker_add = 'addRandomCar();'

    guard_start = runnable.index(guard)
    unless guard_start &&
           runnable.include?(loop_start) &&
           runnable.include?(marker_add) &&
           guard_start < runnable.index(loop_start) &&
           runnable.index(loop_start) < runnable.index(marker_add)
      return ['Delayed marker population must reject inactive lifecycle state before map mutation']
    end

    []
  end
end
