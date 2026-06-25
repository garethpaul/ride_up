package com.foursquare.rideup;

public final class PickupMapStateContractTest {
    private PickupMapStateContractTest() {
    }

    public static void main(String[] args) {
        pickupBeforeMapReadyWins();
        pickupAfterMapReadyReplacesCurrentPlace();
        lateCurrentPlaceCannotReplacePickup();
        inactiveOrUnreadyStateCannotPublish();
        latestPickupControlsCameraAndMarkerCoordinates();
        repeatedResumeDoesNotRepublishConsumedState();
        repeatedMapReadyDoesNotRepublishConsumedState();
        deferredPublicationRemainsPendingUntilActiveAndReady();
        multipleSelectionsPublishEachLatestRevisionOnce();
        staleCurrentPlaceDoesNotDirtyPublishedPickup();
        pickupSelectionRemainsObservableAfterPublication();

        System.out.println("Pickup map state tests passed.");
    }

    private static void pickupBeforeMapReadyWins() {
        PickupMapState state = new PickupMapState();
        state.updateCurrentPlace(37.1, -122.1);
        state.selectPickup(37.2, -122.2);

        expect(state.publication(false, true) == null, "unready map must not publish");
        expectPickup(state.publication(true, true), 37.2, -122.2);
    }

    private static void pickupAfterMapReadyReplacesCurrentPlace() {
        PickupMapState state = new PickupMapState();
        state.updateCurrentPlace(37.1, -122.1);

        expectCurrentPlace(state.publication(true, true), 37.1, -122.1);

        state.selectPickup(37.2, -122.2);
        expectPickup(state.publication(true, true), 37.2, -122.2);
    }

    private static void lateCurrentPlaceCannotReplacePickup() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);
        state.updateCurrentPlace(37.9, -122.9);

        expectPickup(state.publication(true, true), 37.2, -122.2);
    }

    private static void inactiveOrUnreadyStateCannotPublish() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);

        expect(state.publication(true, false) == null, "inactive activity must not publish");
        expect(state.publication(false, false) == null, "inactive unready map must not publish");
        expectPickup(state.publication(true, true), 37.2, -122.2);
    }

    private static void latestPickupControlsCameraAndMarkerCoordinates() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);
        state.selectPickup(37.3, -122.3);

        PickupMapState.Publication publication = state.publication(true, true);
        expectPickup(publication, 37.3, -122.3);
    }

    private static void repeatedResumeDoesNotRepublishConsumedState() {
        PickupMapState state = new PickupMapState();
        state.updateCurrentPlace(37.1, -122.1);

        expectCurrentPlace(state.publication(true, true), 37.1, -122.1);
        expect(state.publication(true, true) == null,
                "repeated resume must not republish consumed current place");
    }

    private static void repeatedMapReadyDoesNotRepublishConsumedState() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);

        expectPickup(state.publication(true, true), 37.2, -122.2);
        expect(state.publication(true, true) == null,
                "repeated map-ready callback must not republish consumed pickup");
    }

    private static void deferredPublicationRemainsPendingUntilActiveAndReady() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);

        expect(state.publication(false, false) == null,
                "inactive unready publication must remain pending");
        expect(state.publication(true, false) == null,
                "inactive publication must remain pending");
        expect(state.publication(false, true) == null,
                "unready publication must remain pending");
        expectPickup(state.publication(true, true), 37.2, -122.2);
        expect(state.publication(true, true) == null,
                "successful deferred publication must be consumed once");
    }

    private static void multipleSelectionsPublishEachLatestRevisionOnce() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);
        expectPickup(state.publication(true, true), 37.2, -122.2);

        state.selectPickup(37.3, -122.3);
        state.selectPickup(37.4, -122.4);
        expectPickup(state.publication(true, true), 37.4, -122.4);
        expect(state.publication(true, true) == null,
                "latest pickup revision must publish only once");
    }

    private static void staleCurrentPlaceDoesNotDirtyPublishedPickup() {
        PickupMapState state = new PickupMapState();
        state.selectPickup(37.2, -122.2);
        expectPickup(state.publication(true, true), 37.2, -122.2);

        state.updateCurrentPlace(37.9, -122.9);
        expect(state.publication(true, true) == null,
                "late current place must not republish an explicit pickup");
    }

    private static void pickupSelectionRemainsObservableAfterPublication() {
        PickupMapState state = new PickupMapState();
        expect(!state.hasPickup(), "new state must not report a pickup");

        state.selectPickup(37.2, -122.2);
        expect(state.hasPickup(), "selected pickup must be observable");
        expectPickup(state.publication(true, true), 37.2, -122.2);
        expect(state.hasPickup(), "published pickup must remain observable");
    }

    private static void expectPickup(
            PickupMapState.Publication publication, double latitude, double longitude) {
        expect(publication != null, "pickup publication must exist");
        expect(publication.isPickup(), "publication must represent an explicit pickup");
        expect(publication.getLatitude() == latitude, "pickup latitude must match");
        expect(publication.getLongitude() == longitude, "pickup longitude must match");
    }

    private static void expectCurrentPlace(
            PickupMapState.Publication publication, double latitude, double longitude) {
        expect(publication != null, "current-place publication must exist");
        expect(!publication.isPickup(), "publication must represent current place");
        expect(publication.getLatitude() == latitude, "current-place latitude must match");
        expect(publication.getLongitude() == longitude, "current-place longitude must match");
    }

    private static void expect(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
