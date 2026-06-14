package com.foursquare.rideup;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class MarkerAnimationLifecycleTest {
    @Test
    public void animationsAreInactiveUntilResumeAndStopOnPause() {
        MarkerAnimationLifecycle lifecycle = new MarkerAnimationLifecycle();

        assertFalse(lifecycle.canAnimate());
        lifecycle.resume();
        assertTrue(lifecycle.canAnimate());
        lifecycle.pause();
        assertFalse(lifecycle.canAnimate());
    }

    @Test
    public void canceledAnimationsNeverRestart() {
        MarkerAnimationLifecycle lifecycle = new MarkerAnimationLifecycle();

        lifecycle.resume();
        assertTrue(lifecycle.shouldRestart(false));
        assertFalse(lifecycle.shouldRestart(true));
        lifecycle.pause();
        assertFalse(lifecycle.shouldRestart(false));
    }
}
