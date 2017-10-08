# RideUp

A ride sharing sample utilizing Foursquare PlacePicker SDK.

<img src="/screenshots/ride_up_screenshot.gif?raw=true" width="300px">

## Getting Started

1. Setup new Java Class - Constants.java

```
public class Constants {
    public static final String MAPBOX_ACCESS_TOKEN = "";
    public static final String FOURSQUARE_CLIENT_KEY = "";
    public static final String FOURSQUARE_CLIENT_SECRET = "";
}
```

2. Libraries via Gradle

```
compile 'com.squareup.okhttp3:okhttp:3.9.0'
compile 'com.android.support:appcompat-v7:26.1.0'
compile 'com.foursquare:placepicker:0.7.0'
compile 'com.github.bumptech.glide:glide:3.8.0'
dependencies {
    compile ('com.mapbox.mapboxsdk:mapbox-android-sdk:5.1.4@aar') {
        transitive=true
    }
}
```
