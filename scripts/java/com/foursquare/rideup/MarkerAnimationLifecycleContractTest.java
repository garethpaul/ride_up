package com.foursquare.rideup;

public final class MarkerAnimationLifecycleContractTest {
    private MarkerAnimationLifecycleContractTest() {
    }

    public static void main(String[] args) {
        MarkerAnimationLifecycle lifecycle = new MarkerAnimationLifecycle();

        expect(!lifecycle.canAnimate(), "animations should start inactive");
        lifecycle.resume();
        expect(lifecycle.canAnimate(), "resume should activate animations");
        expect(lifecycle.shouldRestart(false), "completed animations should restart while active");
        expect(!lifecycle.shouldRestart(true), "canceled animations should not restart");
        lifecycle.pause();
        expect(!lifecycle.canAnimate(), "pause should deactivate animations");
        expect(!lifecycle.shouldRestart(false), "completed animations should not restart while paused");

        System.out.println("Marker animation lifecycle tests passed.");
    }

    private static void expect(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
