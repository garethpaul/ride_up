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

    static boolean areExpectedPermissionsGranted(
            String[] permissions,
            int[] grantResults,
            String[] expectedPermissions,
            int grantedValue) {
        if (permissions == null || grantResults == null || expectedPermissions == null ||
                permissions.length == 0 || permissions.length != grantResults.length ||
                permissions.length != expectedPermissions.length) {
            return false;
        }

        for (int expectedIndex = 0; expectedIndex < expectedPermissions.length; expectedIndex++) {
            String expectedPermission = expectedPermissions[expectedIndex];
            if (expectedPermission == null || expectedPermission.length() == 0) {
                return false;
            }

            for (int previousIndex = 0; previousIndex < expectedIndex; previousIndex++) {
                if (expectedPermission.equals(expectedPermissions[previousIndex])) {
                    return false;
                }
            }
        }

        boolean[] matchedPermissions = new boolean[expectedPermissions.length];
        for (int resultIndex = 0; resultIndex < permissions.length; resultIndex++) {
            String permission = permissions[resultIndex];
            if (permission == null || grantResults[resultIndex] != grantedValue) {
                return false;
            }

            int matchedIndex = -1;
            for (int expectedIndex = 0; expectedIndex < expectedPermissions.length; expectedIndex++) {
                if (permission.equals(expectedPermissions[expectedIndex])) {
                    matchedIndex = expectedIndex;
                    break;
                }
            }

            if (matchedIndex < 0 || matchedPermissions[matchedIndex]) {
                return false;
            }
            matchedPermissions[matchedIndex] = true;
        }

        return true;
    }
}
