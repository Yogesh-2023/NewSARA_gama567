package com.gama56723.app;

import android.os.Bundle;
import android.util.Log;
import io.flutter.embedding.android.FlutterFragmentActivity;

public class MainActivity extends FlutterFragmentActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d("MainActivityCheck", "FlutterFragmentActivity loaded successfully");
    }
}
