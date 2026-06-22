package com.foursquare.rideup;

final class PickupMapPublicationController {
    interface Publisher {
        void publish(PickupMapState.Publication publication);
    }

    private final PickupMapState state;

    PickupMapPublicationController(PickupMapState state) {
        this.state = state;
    }

    boolean publishIfPending(boolean mapReady, boolean active, Publisher publisher) {
        PickupMapState.Publication publication = state.publication(mapReady, active);
        if (publication == null) {
            return false;
        }

        publisher.publish(publication);
        return true;
    }
}
