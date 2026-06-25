#!/usr/bin/env ruby
# frozen_string_literal: true

module PickupMapContract
  module_function

  def uncomment(source)
    source.gsub(%r{/\*.*?\*/}m, '').gsub(%r{//[^\n]*}, '')
  end

  def method_body(source, signature)
    clean = uncomment(source)
    signature_index = clean.index(signature)
    return unless signature_index

    opening_brace = clean.index('{', signature_index + signature.length)
    return unless opening_brace

    depth = 0
    clean.each_char.with_index do |character, index|
      next if index < opening_brace

      depth += 1 if character == '{'
      depth -= 1 if character == '}'
      return clean[(opening_brace + 1)...index] if depth.zero?
    end

    nil
  end

  def ordered?(body, first, second)
    first_index = body&.index(first)
    second_index = body&.index(second)
    first_index && second_index && first_index < second_index
  end

  def live_call?(body, call)
    return false unless body

    call_index = body.index(call)
    return false unless call_index
    return false if body[0...call_index].match?(/\A\s*return\b[^;]*;/)
    return false if body.match?(/\bif\s*\(\s*false\s*\)/)

    true
  end

  def failures(main_activity, state_source, controller_source)
    failures = []
    main = uncomment(main_activity)
    state = uncomment(state_source)
    controller = uncomment(controller_source)
    picker_body = method_body(main_activity, 'protected void onActivityResult(')
    request_map_body = method_body(main_activity, 'private void requestMapReady()')
    map_ready_body = method_body(main_activity, 'public void onMapReady(')
    resume_body = method_body(main_activity, 'protected void onResume()')
    publish_body = method_body(main_activity, 'private void publishMapLocation()')
    apply_body = method_body(
      main_activity,
      'private void applyMapPublication(PickupMapState.Publication publication)'
    )
    update_body = method_body(state_source, 'void updateCurrentPlace(')
    select_body = method_body(state_source, 'void selectPickup(')
    state_publish_body = method_body(state_source, 'Publication publication(')
    controller_publish_body = method_body(controller_source, 'boolean publishIfPending(')

    failures << 'activity must own pickup map state' unless
      main.include?('private final PickupMapState pickupMapState = new PickupMapState();')
    failures << 'activity must own executable publication controller' unless
      main.include?('private final PickupMapPublicationController pickupMapPublicationController =')
    failures << 'current place must update pickup map state' unless
      main.include?('pickupMapState.updateCurrentPlace(')
    failures << 'picker must save pickup before publication' unless
      ordered?(picker_body, 'pickupMapState.selectPickup(', 'publishMapLocation();')
    failures << 'map readiness must be re-requestable while no map is retained' unless
      request_map_body&.include?('mapView == null || mapboxMap != null') &&
      request_map_body&.include?('mapView.getMapAsync(new OnMapReadyCallback()')
    failures << 'map-ready callback must publish saved state' unless
      ordered?(map_ready_body, 'MainActivity.this.mapboxMap = mapboxMap;', 'publishMapLocation();')
    failures << 'resume must attempt deferred publication' unless
      ordered?(resume_body, 'markerAnimationLifecycle.resume();', 'publishMapLocation();')
    failures << 'resume must re-request map readiness before deferred publication' unless
      ordered?(resume_body, 'requestMapReady();', 'publishMapLocation();')
    failures << 'production publication must execute the controller' unless
      live_call?(publish_body, 'pickupMapPublicationController.publishIfPending(')
    failures << 'production publication must pass readiness and activity' unless
      publish_body&.include?('mapboxMap != null') &&
      publish_body&.include?('markerAnimationLifecycle.canAnimate()')
    failures << 'controller callback must apply the publication' unless
      publish_body&.include?('applyMapPublication(publication);')
    failures << 'camera and marker must share one location value' unless
      apply_body&.include?('LatLng location = new LatLng(') &&
      apply_body&.include?('moveCamera(CameraUpdateFactory.newLatLngZoom(location, 15))') &&
      apply_body&.include?('.position(location)')
    failures << 'pickup publication must clear stale car markers' unless
      apply_body&.match?(/if \(publication\.isPickup\(\)\) \{\s*clearCarMarkers\(\);\s*mapboxMap\.clear\(\);/m)
    failures << 'pickup publication must not schedule car population' unless
      apply_body&.match?(/if \(publication\.isPickup\(\)\) \{.*?return;\s*\}\s*scheduleCarPopulation\(\);/m)

    failures << 'state must track pending and published revisions' unless
      state.include?('private long pendingRevision;') &&
      state.include?('private long publishedRevision;')
    failures << 'current place must reject callbacks after pickup selection' unless
      update_body&.match?(/if \(hasPickup\) \{\s*return;/m)
    failures << 'current place must create a pending revision' unless
      update_body&.include?('pendingRevision = ++revision;')
    failures << 'pickup must create a pending revision' unless
      select_body&.include?('pendingRevision = ++revision;')
    failures << 'state must expose whether a pickup was selected' unless
      state.include?('boolean hasPickup()')
    failures << 'publication must require activity, readiness, and a new revision' unless
      state_publish_body&.match?(/!mapReady \|\| !active \|\| pendingRevision == publishedRevision/)
    failures << 'successful publication must consume the exact pending revision' unless
      ordered?(state_publish_body, 'publishedRevision = pendingRevision;', 'return publication;')

    failures << 'controller must request publication from state' unless
      controller_publish_body&.include?('state.publication(mapReady, active)')
    failures << 'controller must execute publisher side effects' unless
      live_call?(controller_publish_body, 'publisher.publish(publication);')
    failures << 'controller must report successful publication' unless
      ordered?(controller_publish_body, 'publisher.publish(publication);', 'return true;')

    failures
  end
end
