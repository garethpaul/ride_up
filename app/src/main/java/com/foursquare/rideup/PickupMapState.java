package com.foursquare.rideup;

final class PickupMapState {
    private boolean hasCurrentPlace;
    private double currentLatitude;
    private double currentLongitude;
    private boolean hasPickup;
    private double pickupLatitude;
    private double pickupLongitude;
    private long revision;
    private long pendingRevision;
    private long publishedRevision;

    void updateCurrentPlace(double latitude, double longitude) {
        if (hasPickup) {
            return;
        }

        hasCurrentPlace = true;
        currentLatitude = latitude;
        currentLongitude = longitude;
        pendingRevision = ++revision;
    }

    void selectPickup(double latitude, double longitude) {
        hasPickup = true;
        pickupLatitude = latitude;
        pickupLongitude = longitude;
        pendingRevision = ++revision;
    }

    Publication publication(boolean mapReady, boolean active) {
        if (!mapReady || !active || pendingRevision == publishedRevision) {
            return null;
        }

        Publication publication;
        if (hasPickup) {
            publication = new Publication(pickupLatitude, pickupLongitude, true);
        } else if (hasCurrentPlace) {
            publication = new Publication(currentLatitude, currentLongitude, false);
        } else {
            return null;
        }

        publishedRevision = pendingRevision;
        return publication;
    }

    static final class Publication {
        private final double latitude;
        private final double longitude;
        private final boolean pickup;

        Publication(double latitude, double longitude, boolean pickup) {
            this.latitude = latitude;
            this.longitude = longitude;
            this.pickup = pickup;
        }

        double getLatitude() {
            return latitude;
        }

        double getLongitude() {
            return longitude;
        }

        boolean isPickup() {
            return pickup;
        }
    }
}
