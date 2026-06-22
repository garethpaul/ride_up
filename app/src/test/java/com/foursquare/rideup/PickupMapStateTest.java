package com.foursquare.rideup;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

public class PickupMapStateTest {
    @Test
    public void pickupBeforeMapReadyWinsOverCurrentPlace() {
        PickupMapState state = new PickupMapState();
        state.updateCurrentPlace(37.1, -122.1);
        state.selectPickup(37.2, -122.2);

        assertNull(state.publication(false, true));
        assertPickup(state.publication(true, true), 37.2, -122.2);
    }

    @Test
    public void pickupAfterMapReadyReplacesCurrentPlace() {
        PickupMapState state = new PickupMapState();
        state.updateCurrentPlace(37.1, -122.1);

        PickupMapState.Publication current = state.publication(true, true);
        assertFalse(current.isPickup());

        state.selectPickup(37.2, -122.2);
        assertPickup(state.publication(true, true), 37.2, -122.2);
    }

    @Test
    public void lateCurrentPlaceCannotReplacePickup() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);
        state.updateCurrentPlace(37.9, -122.9);

        assertPickup(state.publication(true, true), 37.2, -122.2);
    }

    @Test
    public void inactivePublicationIsDeferred() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);

        assertNull(state.publication(true, false));
        assertPickup(state.publication(true, true), 37.2, -122.2);
    }

    @Test
    public void successfulPublicationIsConsumedOnce() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);

        assertPickup(state.publication(true, true), 37.2, -122.2);
        assertNull(state.publication(true, true));
    }

    @Test
    public void deferredPublicationStaysPendingUntilActiveAndReady() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);

        assertNull(state.publication(false, false));
        assertNull(state.publication(true, false));
        assertNull(state.publication(false, true));
        assertPickup(state.publication(true, true), 37.2, -122.2);
        assertNull(state.publication(true, true));
    }

    @Test
    public void latestSelectionPublishesOncePerRevision() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);
        assertPickup(state.publication(true, true), 37.2, -122.2);

        state.selectPickup(37.3, -122.3);
        state.selectPickup(37.4, -122.4);
        assertPickup(state.publication(true, true), 37.4, -122.4);
        assertNull(state.publication(true, true));
    }

    @Test
    public void lateCurrentPlaceDoesNotDirtyPublishedPickup() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);
        assertPickup(state.publication(true, true), 37.2, -122.2);

        state.updateCurrentPlace(37.9, -122.9);
        assertNull(state.publication(true, true));
    }

    private static void assertPickup(
            PickupMapState.Publication publication, double latitude, double longitude) {
        assertTrue(publication.isPickup());
        assertEquals(latitude, publication.getLatitude(), 0);
        assertEquals(longitude, publication.getLongitude(), 0);
    }
}
