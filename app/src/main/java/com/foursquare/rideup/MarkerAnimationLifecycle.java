package com.foursquare.rideup;

final class MarkerAnimationLifecycle {
    private boolean active;

    void resume() {
        active = true;
    }

    void pause() {
        active = false;
    }

    boolean canAnimate() {
        return active;
    }

    boolean shouldRestart(boolean canceled) {
        return active && !canceled;
    }
}
