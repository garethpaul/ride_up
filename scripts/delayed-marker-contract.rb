# frozen_string_literal: true

module DelayedMarkerContract
  module_function

  def failures(source)
    success_start = source.index('public void success(Venue venue, boolean confident)')
    success_end = success_start && source.index('@Override', success_start + 1)
    return ['MainActivity must retain the current-place success callback'] unless success_start && success_end

    success = source[success_start...success_end]
    success_guard = "if (!markerAnimationLifecycle.canAnimate()) {\n                    return;\n                }"
    state_update = 'pickupMapState.updateCurrentPlace('
    request_map = 'requestMapReady();'
    publish_location = 'publishMapLocation();'
    unless success.include?(success_guard) &&
           success.include?(state_update) &&
           success.include?(request_map) &&
           success.include?(publish_location) &&
           success.index(success_guard) < success.index(state_update) &&
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
    pickup_guard = /if \(pickupMapState\.hasPickup\(\)\) \{\s*return;\s*\}/
    delayed_start = map_ready.index('handler.postDelayed(new Runnable()')
    schedule_call = map_ready.index('scheduleCarPopulation();')
    guard_start = map_ready.index(guard)
    pickup_guard_start = map_ready.index(pickup_guard)
    unless guard_start &&
           map_ready.include?(map_assignment) &&
           map_ready.include?(publish_location) &&
           map_ready.include?(enable_location) &&
           pickup_guard_start.nil? &&
           delayed_start.nil? &&
           schedule_call.nil? &&
           guard_start < map_ready.index(map_assignment) &&
           map_ready.index(map_assignment) < map_ready.index(publish_location) &&
           guard_start < map_ready.index(enable_location)
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
