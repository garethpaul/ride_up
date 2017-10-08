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
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.DrawableRes;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
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
import com.google.android.gms.location.LocationServices;
import com.mapbox.mapboxsdk.Mapbox;
import com.mapbox.mapboxsdk.annotations.Icon;
import com.mapbox.mapboxsdk.annotations.IconFactory;
import com.mapbox.mapboxsdk.annotations.MarkerView;
import com.mapbox.mapboxsdk.annotations.MarkerViewOptions;
import com.mapbox.mapboxsdk.camera.CameraUpdateFactory;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.maps.MapView;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.mapboxsdk.maps.OnMapReadyCallback;

import java.util.Random;



public class MainActivity extends AppCompatActivity {
    private static final String TAG = MainActivity.class.getSimpleName();

    private TextView pickupLocation;

    private MapView mapView;
    private MapboxMap mapboxMap;
    private float lat;
    private float lng;
    private static final int PERMISSIONS_LOCATION = 0;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getSupportActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
        getSupportActionBar().setCustomView(R.layout.action_bar_custom);
        getSupportActionBar().setBackgroundDrawable(new ColorDrawable(Color.parseColor("#FAFAFA")));

        Mapbox.getInstance(this, Constants.MAPBOX_ACCESS_TOKEN);
        setContentView(R.layout.activity_main);

        // Setup Permissions
        if (ActivityCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                    Manifest.permission.ACCESS_FINE_LOCATION}, PERMISSIONS_LOCATION);
        }

        // Request a ride
        Button confirmBtn = findViewById(R.id.confirmBtn);
        confirmBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.v(TAG, "onclick of request ride");
                requestRide();
            }
        });


        pickupLocation = findViewById(R.id.pickUpTextView);
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
                                .placeholder(R.drawable.category_none)
                                .dontAnimate()
                                .into(v);
                    }
                })
                .build());



        mapView = findViewById(R.id.mapView);
        mapView.onCreate(savedInstanceState);


        getClosestPlace();
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
        startActivityForResult(intent, 9001);
    }

    private void getClosestPlace() {
        PlacePickerSdk.get().getCurrentPlace(new PlacePickerSdk.CurrentPlaceResult() {
            @Override
            public void success(Venue venue, boolean confident) {
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
        if (resultCode == PlacePicker.PLACE_PICKED_RESULT_CODE) {
            Venue place = data.getParcelableExtra(PlacePicker.EXTRA_PLACE);
            pickupLocation.setText(place.getName());
            mapboxMap.clear();
            mapboxMap.addMarker(new MarkerViewOptions()
                    .position(new LatLng(place.getLocation().getLat(), place.getLocation().getLng()))
                    .title("Pick Up Location"));

        } else {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        mapView.onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();
        mapView.onStop();
    }

    @Override
    protected void onDestroy() {
        mapView.onDestroy();
        super.onDestroy();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mapView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        mapView.onPause();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        mapView.onSaveInstanceState(outState);
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        mapView.onLowMemory();
    }


    protected void addRandomCar() {
        Log.v(TAG, "addingRandomCar");
        MarkerView car = createCarMarker(getLatLngInBounds(), R.drawable.ic_car_top);
        randomlyMoveMarker(car);
    }

    private void randomlyMoveMarker(final MarkerView marker) {
        Log.v(TAG, "randomlyMoveMarker");
        ValueAnimator animator = animateMoveMarker(marker, getLatLngInBounds());

        //Add listener to restart animation on end
        animator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                randomlyMoveMarker(marker);
            }
        });
    }

    private ValueAnimator animateMoveMarker(final MarkerView marker, LatLng to) {
        marker.setRotation((float) getBearing(marker.getPosition(), to));

        final ValueAnimator markerAnimator = ObjectAnimator.ofObject(
                marker, "position", new LatLngEvaluator(), marker.getPosition(), to);
        markerAnimator.setDuration((long) (20 * marker.getPosition().distanceTo(to)));
        markerAnimator.setInterpolator(new AccelerateDecelerateInterpolator());

        // Start
        markerAnimator.start();

        return markerAnimator;
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
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                getClosestPlace();
            }
        }
    }

}