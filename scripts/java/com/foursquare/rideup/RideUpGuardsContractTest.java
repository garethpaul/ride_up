package com.foursquare.rideup;

public final class RideUpGuardsContractTest {
    private RideUpGuardsContractTest() {
    }

    public static void main(String[] args) {
        String coarseLocation = "coarse";
        String fineLocation = "fine";
        String[] expectedLocationPermissions = {coarseLocation, fineLocation};

        expect(
                RideUpGuards.isExpectedActivityResult(9001, 1, 9001, 1),
                "matching activity result should be accepted");
        expect(
                !RideUpGuards.isExpectedActivityResult(7, 1, 9001, 1),
                "unrelated request code should be rejected");
        expect(
                !RideUpGuards.isExpectedActivityResult(9001, 0, 9001, 1),
                "unexpected result code should be rejected");
        expect(
                RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {coarseLocation, fineLocation},
                        new int[] {0, 0},
                        expectedLocationPermissions,
                        0),
                "expected granted permissions should be accepted");
        expect(
                RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {fineLocation, coarseLocation},
                        new int[] {0, 0},
                        expectedLocationPermissions,
                        0),
                "expected granted permissions should be order independent");
        expect(
                !RideUpGuards.areExpectedPermissionsGranted(
                        null, new int[] {0, 0}, expectedLocationPermissions, 0),
                "null permission names should be rejected");
        expect(
                !RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {coarseLocation, fineLocation}, null,
                        expectedLocationPermissions, 0),
                "null permission results should be rejected");
        expect(
                !RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {coarseLocation, fineLocation}, new int[] {0, 0}, null, 0),
                "null expected permissions should be rejected");
        expect(
                !RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {}, new int[] {}, expectedLocationPermissions, 0),
                "empty permission callbacks should be rejected");
        expect(
                !RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {coarseLocation}, new int[] {0},
                        expectedLocationPermissions, 0),
                "missing expected permissions should be rejected");
        expect(
                !RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {coarseLocation, fineLocation}, new int[] {0},
                        expectedLocationPermissions, 0),
                "misaligned permission results should be rejected");
        expect(
                !RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {coarseLocation, "camera"}, new int[] {0, 0},
                        expectedLocationPermissions, 0),
                "unknown permissions should be rejected");
        expect(
                !RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {coarseLocation, coarseLocation}, new int[] {0, 0},
                        expectedLocationPermissions, 0),
                "duplicate permissions should be rejected");
        expect(
                !RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {coarseLocation, null}, new int[] {0, 0},
                        expectedLocationPermissions, 0),
                "null permission entries should be rejected");
        expect(
                !RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {coarseLocation, fineLocation}, new int[] {0, -1},
                        expectedLocationPermissions, 0),
                "partial permission grants should be rejected");
        expect(
                !RideUpGuards.areExpectedPermissionsGranted(
                        new String[] {coarseLocation, fineLocation}, new int[] {0, 0},
                        new String[] {coarseLocation, coarseLocation}, 0),
                "duplicate expected permissions should be rejected");

        System.out.println("RideUp guard behavior tests passed.");
    }

    private static void expect(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
