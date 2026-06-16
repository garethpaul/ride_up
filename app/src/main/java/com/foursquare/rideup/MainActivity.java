package com.foursquare.rideup;




import android.Manifest;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.animation.TypeEvaluator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Handler;
import android.support.annotation.DrawableRes;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.view.ContextThemeWrapper;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.foursquare.api.types.Venue;
import com.foursquare.placepicker.PlacePicker;
import com.foursquare.placepicker.PlacePickerSdk;
import com.mapbox.mapboxsdk.MapboxAccountManager;
import com.mapbox.mapboxsdk.annotations.Icon;
import com.mapbox.mapboxsdk.annotations.IconFactory;
import com.mapbox.mapboxsdk.annotations.Marker;
import com.mapbox.mapboxsdk.annotations.MarkerView;
import com.mapbox.mapboxsdk.annotations.MarkerViewOptions;
import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.camera.CameraUpdateFactory;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.location.LocationServices;
import com.mapbox.mapboxsdk.maps.MapView;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.mapboxsdk.maps.OnMapReadyCallback;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;



public class MainActivity extends AppCompatActivity {
    private static final String TAG = MainActivity.class.getSimpleName();

    private TextView pickupLocation;

    private MapView mapView;
    private MapboxMap mapboxMap;
    private float lat;
    private float lng;
    private LocationServices locationServices;
    private static final int PERMISSIONS_LOCATION = 0;
    private static final int PLACE_PICKER_REQUEST = 9001;
    private static final String[] LOCATION_PERMISSIONS = new String[]{
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_FINE_LOCATION
    };
    private final MarkerAnimationLifecycle markerAnimationLifecycle =
            new MarkerAnimationLifecycle();
    private final List<MarkerView> carMarkers = new ArrayList<>();
    private final List<ValueAnimator> carAnimators = new ArrayList<>();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getSupportActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
        getSupportActionBar().setCustomView(R.layout.action_bar_custom);
        getSupportActionBar().setBackgroundDrawable(new ColorDrawable(Color.parseColor("#FAFAFA")));

        MapboxAccountManager.start(this, Constants.MAPBOX_ACCESS_TOKEN);
        setContentView(R.layout.activity_main);

        // Setup Permissions
        locationServices = LocationServices.getLocationServices(MainActivity.this);
        boolean hasLocationPermission = locationServices.areLocationPermissionsGranted();
        if (!hasLocationPermission) {
            ActivityCompat.requestPermissions(this, LOCATION_PERMISSIONS, PERMISSIONS_LOCATION);
        }

        // Request a ride
        Button confirmBtn = (Button) findViewById(R.id.confirmBtn);
        confirmBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.v(TAG, "onclick of request ride");
                requestRide();
            }
        });


        pickupLocation = (TextView) findViewById(R.id.pickUpTextView);
        pickupLocation.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                pickPlace();
            }
        });

        PlacePickerSdk.with(new PlacePickerSdk.Builder(this)
                .consumer(Constants.FOURSQUARE_CLIENT_KEY,
                          Constants.FOURSQUARE_CLIENT_SECRET)
                .imageLoader(new PlacePickerSdk.ImageLoader() {
                    @Override
                    public void loadImage(Context context, ImageView v, String url) {
                        Glide.with(context)
                                .load(url)
                                .placeholder(R.drawable.ic_circle)
                                .dontAnimate()
                                .into(v);
                    }
                })
                .build());



        mapView = (MapView) findViewById(R.id.mapView);
        mapView.onCreate(savedInstanceState);

        if (hasLocationPermission) {
            getClosestPlace();
        }
    }

    private void requestRide() {
        AlertDialog.Builder builder = new AlertDialog.Builder(new ContextThemeWrapper(this, R.style.AlertDialogCustom));

        builder.setMessage(R.string.driver_error)
                .setTitle("Error");
        AlertDialog dialog = builder.create();
        dialog.show();
    }

    private void pickPlace() {
        Intent intent = new Intent(this, PlacePicker.class);
        String TAG = PlacePicker.class.getSimpleName();
        intent.putExtra(TAG + ".EXTRA_HEADER_BACKGROUND_RESOURCE", R.color.colorPrimary);
        startActivityForResult(intent, PLACE_PICKER_REQUEST);
    }

    private void getClosestPlace() {
        PlacePickerSdk.get().getCurrentPlace(new PlacePickerSdk.CurrentPlaceResult() {
            @Override
            public void success(Venue venue, boolean confident) {
                if (venue == null) {
                    return;
                }

                if (venue.getLocation() == null) {
                    return;
                }

                lat = venue.getLocation().getLat();
                lng = venue.getLocation().getLng();


                mapView.getMapAsync(new OnMapReadyCallback() {

                    @Override
                    public void onMapReady(@NonNull final MapboxMap mapboxMap) {
                        MainActivity.this.mapboxMap = mapboxMap;
                        mapboxMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lat, lng), 15));
                        mapboxMap.setMyLocationEnabled(true);
                        final Handler handler = new Handler();
                        handler.postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                if (!markerAnimationLifecycle.canAnimate()) {
                                    return;
                                }
                                for (int i = 0; i < 10; i++) {
                                    addRandomCar();
                                }
                            }
                        }, 500);

                    } // End onMapReady
                });
            }
            @Override
            public void fail() {
            }
        });
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (!RideUpGuards.isExpectedActivityResult(
                requestCode,
                resultCode,
                PLACE_PICKER_REQUEST,
                PlacePicker.PLACE_PICKED_RESULT_CODE)) {
            super.onActivityResult(requestCode, resultCode, data);
            return;
        }

        if (data == null) {
            return;
        }

        Venue place = data.getParcelableExtra(PlacePicker.EXTRA_PLACE);
        if (place == null) {
            return;
        }

        if (place.getLocation() == null) {
            return;
        }

        pickupLocation.setText(place.getName());
        if (mapboxMap != null) {
            clearCarMarkers();
            mapboxMap.clear();
            mapboxMap.addMarker(new MarkerViewOptions()
                    .position(new LatLng(place.getLocation().getLat(), place.getLocation().getLng()))
                    .title("Pick Up Location"));
        }
    }


    @Override
    protected void onDestroy() {
        stopMarkerAnimations();
        if (mapView != null) {
            mapView.onDestroy();
        }
        super.onDestroy();
    }

    @Override
    protected void onResume() {
        super.onResume();
        markerAnimationLifecycle.resume();
        if (mapView != null) {
            mapView.onResume();
        }
        for (MarkerView marker : new ArrayList<>(carMarkers)) {
            randomlyMoveMarker(marker);
        }
    }

    @Override
    protected void onPause() {
        stopMarkerAnimations();
        super.onPause();
        if (mapView != null) {
            mapView.onPause();
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        if (mapView != null) {
            mapView.onSaveInstanceState(outState);
        }
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        if (mapView != null) {
            mapView.onLowMemory();
        }
    }


    protected void addRandomCar() {
        Log.v(TAG, "addingRandomCar");
        MarkerView car = createCarMarker(getLatLngInBounds(), R.drawable.ic_car_top);
        carMarkers.add(car);
        randomlyMoveMarker(car);
    }

    private void randomlyMoveMarker(final MarkerView marker) {
        if (!markerAnimationLifecycle.canAnimate()) {
            return;
        }

        Log.v(TAG, "randomlyMoveMarker");
        final ValueAnimator animator = animateMoveMarker(marker, getLatLngInBounds());
        carAnimators.add(animator);

        animator.addListener(new AnimatorListenerAdapter() {
            private boolean canceled;

            @Override
            public void onAnimationCancel(Animator animation) {
                canceled = true;
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                carAnimators.remove(animator);
                if (markerAnimationLifecycle.shouldRestart(canceled)) {
                    randomlyMoveMarker(marker);
                }
            }
        });
        animator.start();
    }

    private ValueAnimator animateMoveMarker(final MarkerView marker, LatLng to) {
        marker.setRotation((float) getBearing(marker.getPosition(), to));

        final ValueAnimator markerAnimator = ObjectAnimator.ofObject(
                marker, "position", new LatLngEvaluator(), marker.getPosition(), to);
        markerAnimator.setDuration((long) (20 * marker.getPosition().distanceTo(to)));
        markerAnimator.setInterpolator(new AccelerateDecelerateInterpolator());

        return markerAnimator;
    }

    private void stopMarkerAnimations() {
        markerAnimationLifecycle.pause();
        cancelMarkerAnimators();
    }

    private void cancelMarkerAnimators() {
        List<ValueAnimator> animators = new ArrayList<>(carAnimators);
        carAnimators.clear();
        for (ValueAnimator animator : animators) {
            animator.cancel();
        }
    }

    private void clearCarMarkers() {
        cancelMarkerAnimators();
        carMarkers.clear();
    }

    private MarkerView createCarMarker(LatLng start, @DrawableRes int carResource) {
        Icon icon = IconFactory.getInstance(MainActivity.this)
                .fromResource(carResource);

        Log.v(TAG, start.toString());
        //View Markers
        return mapboxMap.addMarker(new MarkerViewOptions()
                .position(start)
                .icon(icon));

    }


    private LatLng getLatLngInBounds() {
        LatLngBounds bounds = mapboxMap.getProjection().getVisibleRegion().latLngBounds;
        Random generator = new Random();
        double randomLat = bounds.getLatSouth() + generator.nextDouble()
                * (bounds.getLatNorth() - bounds.getLatSouth());
        double randomLon = bounds.getLonWest() + generator.nextDouble()
                * (bounds.getLonEast() - bounds.getLonWest());
        return new LatLng(randomLat, randomLon);
    }

    /**
     * Evaluator for LatLng pairs
     */
    private static class LatLngEvaluator implements TypeEvaluator<LatLng> {

        private LatLng latLng = new LatLng();

        @Override
        public LatLng evaluate(float fraction, LatLng startValue, LatLng endValue) {
            latLng.setLatitude(startValue.getLatitude()
                    + ((endValue.getLatitude() - startValue.getLatitude()) * fraction));
            latLng.setLongitude(startValue.getLongitude()
                    + ((endValue.getLongitude() - startValue.getLongitude()) * fraction));
            return latLng;
        }
    }

    private double getBearing(LatLng from, LatLng to) {
        double degrees2radians = Math.PI / 180;
        double radians2degrees = 180 / Math.PI;

        double lon1 = degrees2radians * from.getLongitude();
        double lon2 = degrees2radians * to.getLongitude();
        double lat1 = degrees2radians * from.getLatitude();
        double lat2 = degrees2radians * to.getLatitude();
        double a = Math.sin(lon2 - lon1) * Math.cos(lat2);
        double b = Math.cos(lat1) * Math.sin(lat2)
                - Math.sin(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1);

        return radians2degrees * Math.atan2(a, b);
    }

    @Override
    public void onRequestPermissionsResult(
            int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == PERMISSIONS_LOCATION) {
            if (RideUpGuards.areExpectedPermissionsGranted(
                    permissions,
                    grantResults,
                    LOCATION_PERMISSIONS,
                    PackageManager.PERMISSION_GRANTED)) {
                getClosestPlace();
            }
        } else {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

}
