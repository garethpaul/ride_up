package com.foursquare.rideup;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class RideUpGuardsTest {
    @Test
    public void activityResultRequiresMatchingRequestAndResultCodes() {
        assertTrue(RideUpGuards.isExpectedActivityResult(9001, 1, 9001, 1));
        assertFalse(RideUpGuards.isExpectedActivityResult(7, 1, 9001, 1));
        assertFalse(RideUpGuards.isExpectedActivityResult(9001, 0, 9001, 1));
    }

    @Test
    public void permissionsRequireEveryResultToBeGranted() {
        assertFalse(RideUpGuards.allPermissionsGranted(null, 0));
        assertFalse(RideUpGuards.allPermissionsGranted(new int[] {}, 0));
        assertFalse(RideUpGuards.allPermissionsGranted(new int[] {0, -1}, 0));
        assertTrue(RideUpGuards.allPermissionsGranted(new int[] {0, 0}, 0));
    }
}
