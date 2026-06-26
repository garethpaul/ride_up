package com.foursquare.rideup;

public final class CurrentPlaceRequestControllerContractTest {
    private CurrentPlaceRequestControllerContractTest() {
    }

    public static void main(String[] args) {
        CurrentPlaceRequestController controller = new CurrentPlaceRequestController();

        expect(controller.beginIfNeeded(false, false) == 0,
                "inactive lifecycle must not start current-place work");
        expect(controller.beginIfNeeded(true, true) == 0,
                "selected pickup must suppress current-place work");

        long firstRequest = controller.beginIfNeeded(true, false);
        expect(firstRequest > 0, "active lifecycle must start current-place work");
        expect(controller.beginIfNeeded(true, false) == 0,
                "an in-flight request must not be duplicated");

        controller.invalidate();
        long resumedRequest = controller.beginIfNeeded(true, false);
        expect(resumedRequest > firstRequest,
                "resume after invalidation must create a newer generation");
        expect(!controller.complete(firstRequest, true, false),
                "stale current-place callbacks must be rejected");
        expect(controller.beginIfNeeded(true, false) == 0,
                "stale completion must not clear the current request");
        expect(controller.complete(resumedRequest, true, false),
                "current active callback must be accepted");
        expect(controller.beginIfNeeded(true, false) == 0,
                "resolved current place must not be requested again");

        CurrentPlaceRequestController paused = new CurrentPlaceRequestController();
        long pausedRequest = paused.beginIfNeeded(true, false);
        expect(!paused.complete(pausedRequest, false, false),
                "paused callback must be rejected");
        expect(paused.beginIfNeeded(true, false) > pausedRequest,
                "rejected paused callback must remain retryable");

        CurrentPlaceRequestController failed = new CurrentPlaceRequestController();
        long failedRequest = failed.beginIfNeeded(true, false);
        failed.fail(failedRequest);
        long retryRequest = failed.beginIfNeeded(true, false);
        expect(retryRequest > failedRequest, "provider failure must remain retryable");
        failed.fail(failedRequest);
        expect(failed.beginIfNeeded(true, false) == 0,
                "stale failure must not clear a newer request");

        System.out.println("Current-place request controller tests passed.");
    }

    private static void expect(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
