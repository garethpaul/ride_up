package com.foursquare.rideup;

final class RideUpGuards {
    private RideUpGuards() {
    }

    static boolean isExpectedActivityResult(
            int requestCode,
            int resultCode,
            int expectedRequestCode,
            int expectedResultCode) {
        return requestCode == expectedRequestCode && resultCode == expectedResultCode;
    }

    static boolean allPermissionsGranted(int[] grantResults, int grantedValue) {
        if (grantResults == null || grantResults.length == 0) {
            return false;
        }

        for (int result : grantResults) {
            if (result != grantedValue) {
                return false;
            }
        }

        return true;
    }
}
