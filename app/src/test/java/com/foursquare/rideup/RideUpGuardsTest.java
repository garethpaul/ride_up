package com.foursquare.rideup;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class RideUpGuardsTest {
    private static final String COARSE_LOCATION = "coarse";
    private static final String FINE_LOCATION = "fine";
    private static final String[] EXPECTED_LOCATION_PERMISSIONS = {
            COARSE_LOCATION, FINE_LOCATION
    };

    @Test
    public void activityResultRequiresMatchingRequestAndResultCodes() {
        assertTrue(RideUpGuards.isExpectedActivityResult(9001, 1, 9001, 1));
        assertFalse(RideUpGuards.isExpectedActivityResult(7, 1, 9001, 1));
        assertFalse(RideUpGuards.isExpectedActivityResult(9001, 0, 9001, 1));
    }

    @Test
    public void permissionsAcceptTheExpectedGrantedSetInAnyOrder() {
        assertTrue(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {COARSE_LOCATION, FINE_LOCATION},
                new int[] {0, 0},
                EXPECTED_LOCATION_PERMISSIONS,
                0));
        assertTrue(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {FINE_LOCATION, COARSE_LOCATION},
                new int[] {0, 0},
                EXPECTED_LOCATION_PERMISSIONS,
                0));
    }

    @Test
    public void permissionsRejectMissingOrMisalignedCallbackData() {
        assertFalse(RideUpGuards.areExpectedPermissionsGranted(
                null, new int[] {0, 0}, EXPECTED_LOCATION_PERMISSIONS, 0));
        assertFalse(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {COARSE_LOCATION, FINE_LOCATION}, null,
                EXPECTED_LOCATION_PERMISSIONS, 0));
        assertFalse(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {COARSE_LOCATION, FINE_LOCATION}, new int[] {0, 0}, null, 0));
        assertFalse(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {}, new int[] {}, EXPECTED_LOCATION_PERMISSIONS, 0));
        assertFalse(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {COARSE_LOCATION}, new int[] {0}, EXPECTED_LOCATION_PERMISSIONS, 0));
        assertFalse(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {COARSE_LOCATION, FINE_LOCATION}, new int[] {0},
                EXPECTED_LOCATION_PERMISSIONS, 0));
    }

    @Test
    public void permissionsRejectUnknownDuplicateNullOrDeniedEntries() {
        assertFalse(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {COARSE_LOCATION, "camera"}, new int[] {0, 0},
                EXPECTED_LOCATION_PERMISSIONS, 0));
        assertFalse(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {COARSE_LOCATION, COARSE_LOCATION}, new int[] {0, 0},
                EXPECTED_LOCATION_PERMISSIONS, 0));
        assertFalse(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {COARSE_LOCATION, null}, new int[] {0, 0},
                EXPECTED_LOCATION_PERMISSIONS, 0));
        assertFalse(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {COARSE_LOCATION, FINE_LOCATION}, new int[] {0, -1},
                EXPECTED_LOCATION_PERMISSIONS, 0));
        assertFalse(RideUpGuards.areExpectedPermissionsGranted(
                new String[] {COARSE_LOCATION, FINE_LOCATION}, new int[] {0, 0},
                new String[] {COARSE_LOCATION, COARSE_LOCATION}, 0));
    }
}
