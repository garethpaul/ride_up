package com.foursquare.rideup;

final class CurrentPlaceRequestController {
    private long generation;
    private long activeRequest;
    private boolean resolved;

    long beginIfNeeded(boolean active, boolean hasPickup) {
        if (!active || hasPickup || resolved || activeRequest != 0) {
            return 0;
        }

        activeRequest = ++generation;
        return activeRequest;
    }

    void invalidate() {
        activeRequest = 0;
    }

    boolean complete(long request, boolean active, boolean hasPickup) {
        if (request == 0 || request != activeRequest) {
            return false;
        }

        activeRequest = 0;
        if (!active || hasPickup) {
            return false;
        }

        resolved = true;
        return true;
    }

    void fail(long request) {
        if (request == activeRequest) {
            activeRequest = 0;
        }
    }
}
