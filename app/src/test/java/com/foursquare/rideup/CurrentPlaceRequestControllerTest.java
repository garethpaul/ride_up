package com.foursquare.rideup;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class CurrentPlaceRequestControllerTest {
    @Test
    public void pausedAndStaleCallbacksRemainRetryable() {
        CurrentPlaceRequestController controller = new CurrentPlaceRequestController();
        long firstRequest = controller.beginIfNeeded(true, false);

        controller.invalidate();
        long resumedRequest = controller.beginIfNeeded(true, false);

        assertTrue(resumedRequest > firstRequest);
        assertFalse(controller.complete(firstRequest, true, false));
        assertTrue(controller.complete(resumedRequest, true, false));
        assertTrue(controller.beginIfNeeded(true, false) == 0);
    }

    @Test
    public void inactivePickupAndFailedRequestsDoNotBecomeResolved() {
        CurrentPlaceRequestController controller = new CurrentPlaceRequestController();

        assertTrue(controller.beginIfNeeded(false, false) == 0);
        assertTrue(controller.beginIfNeeded(true, true) == 0);

        long request = controller.beginIfNeeded(true, false);
        assertFalse(controller.complete(request, false, false));
        long retry = controller.beginIfNeeded(true, false);
        controller.fail(retry);
        assertTrue(controller.beginIfNeeded(true, false) > retry);
    }
}
