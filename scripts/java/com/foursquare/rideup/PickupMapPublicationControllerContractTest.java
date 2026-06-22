package com.foursquare.rideup;

public final class PickupMapPublicationControllerContractTest {
    private PickupMapPublicationControllerContractTest() {
    }

    public static void main(String[] args) {
        repeatedResumePublishesSideEffectsOnce();
        repeatedMapReadyPublishesSideEffectsOnce();
        deferredResumePublishesWhenActiveAndReady();
        newerSelectionPublishesNewSideEffectsOnce();
        staleCurrentPlaceDoesNotPublishAfterPickup();

        System.out.println("Pickup map publication controller tests passed.");
    }

    private static void repeatedResumePublishesSideEffectsOnce() {
        PickupMapState state = new PickupMapState();
        PickupMapPublicationController controller =
                new PickupMapPublicationController(state);
        RecordingPublisher publisher = new RecordingPublisher();
        state.updateCurrentPlace(37.1, -122.1);

        expect(controller.publishIfPending(true, true, publisher),
                "first resume must publish current place");
        expect(!controller.publishIfPending(true, true, publisher),
                "repeated resume must not republish current place");
        expect(publisher.count == 1, "resume side effects must run once");
    }

    private static void repeatedMapReadyPublishesSideEffectsOnce() {
        PickupMapState state = new PickupMapState();
        PickupMapPublicationController controller =
                new PickupMapPublicationController(state);
        RecordingPublisher publisher = new RecordingPublisher();
        state.selectPickup(37.2, -122.2);

        expect(controller.publishIfPending(true, true, publisher),
                "first map-ready callback must publish pickup");
        expect(!controller.publishIfPending(true, true, publisher),
                "repeated map-ready callback must not republish pickup");
        expect(publisher.count == 1, "map-ready side effects must run once");
    }

    private static void deferredResumePublishesWhenActiveAndReady() {
        PickupMapState state = new PickupMapState();
        PickupMapPublicationController controller =
                new PickupMapPublicationController(state);
        RecordingPublisher publisher = new RecordingPublisher();
        state.selectPickup(37.2, -122.2);

        expect(!controller.publishIfPending(false, false, publisher),
                "inactive unready publication must defer");
        expect(!controller.publishIfPending(true, false, publisher),
                "inactive publication must defer");
        expect(controller.publishIfPending(true, true, publisher),
                "active ready resume must publish deferred pickup");
        expect(publisher.count == 1, "deferred side effects must run once");
    }

    private static void newerSelectionPublishesNewSideEffectsOnce() {
        PickupMapState state = new PickupMapState();
        PickupMapPublicationController controller =
                new PickupMapPublicationController(state);
        RecordingPublisher publisher = new RecordingPublisher();
        state.selectPickup(37.2, -122.2);
        expect(controller.publishIfPending(true, true, publisher),
                "first pickup must publish");

        state.selectPickup(37.3, -122.3);
        state.selectPickup(37.4, -122.4);
        expect(controller.publishIfPending(true, true, publisher),
                "latest pickup revision must publish");
        expect(!controller.publishIfPending(true, true, publisher),
                "latest pickup revision must be consumed");
        expect(publisher.count == 2, "two pickup revisions must publish twice");
        expect(publisher.latitude == 37.4, "latest pickup latitude must publish");
        expect(publisher.longitude == -122.4, "latest pickup longitude must publish");
    }

    private static void staleCurrentPlaceDoesNotPublishAfterPickup() {
        PickupMapState state = new PickupMapState();
        PickupMapPublicationController controller =
                new PickupMapPublicationController(state);
        RecordingPublisher publisher = new RecordingPublisher();
        state.selectPickup(37.2, -122.2);
        expect(controller.publishIfPending(true, true, publisher),
                "pickup must publish");

        state.updateCurrentPlace(37.9, -122.9);
        expect(!controller.publishIfPending(true, true, publisher),
                "late current place must not publish after pickup");
        expect(publisher.count == 1, "late current place must not run side effects");
    }

    private static final class RecordingPublisher
            implements PickupMapPublicationController.Publisher {
        private int count;
        private double latitude;
        private double longitude;

        @Override
        public void publish(PickupMapState.Publication publication) {
            count++;
            latitude = publication.getLatitude();
            longitude = publication.getLongitude();
        }
    }

    private static void expect(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
