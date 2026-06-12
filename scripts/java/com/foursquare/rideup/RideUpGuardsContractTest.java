package com.foursquare.rideup;

public final class RideUpGuardsContractTest {
    private RideUpGuardsContractTest() {
    }

    public static void main(String[] args) {
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
                !RideUpGuards.allPermissionsGranted(null, 0),
                "null permission results should be rejected");
        expect(
                !RideUpGuards.allPermissionsGranted(new int[] {}, 0),
                "empty permission results should be rejected");
        expect(
                !RideUpGuards.allPermissionsGranted(new int[] {0, -1}, 0),
                "partial permission grants should be rejected");
        expect(
                RideUpGuards.allPermissionsGranted(new int[] {0, 0}, 0),
                "complete permission grants should be accepted");

        System.out.println("RideUp guard behavior tests passed.");
    }

    private static void expect(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
