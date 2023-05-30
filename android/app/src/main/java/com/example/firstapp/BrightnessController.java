package com.example.firstapp;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.view.Window;
import android.view.WindowManager;

import java.lang.invoke.MethodHandle;

public class BrightnessController {
    private static final String CHANNEL = "com.example.firstapp/brightness_channel";

    private Context context;

    public BrightnessController(Context context) {
        this.context = context;
    }

    public void setBrightness(int brightness) {
        WindowManager.LayoutParams layoutParams = getWindowLayoutParams();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
            layoutParams.screenBrightness = brightness / 255f;
        }
        getWindow().setAttributes(layoutParams);
    }

    private WindowManager.LayoutParams getWindowLayoutParams() {
        WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams();
        layoutParams.copyFrom(getWindow().getAttributes());
        return layoutParams;
    }

    private Window getWindow() {
        return ((Activity) context).getWindow();
    }



//    private void setupMethodChannel() {
//        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                .setMethodCallHandler((call, result) -> {
//                    if (call.method.equals("setBrightness")) {
//                        int brightness = call.argument("brightness");
//                        setBrightness(brightness);
//                        result.success(null);
//                    } else {
//                        result.notImplemented();
//                    }
//                });
//    }
//
//    private void setBrightness(int brightness) {
//        BrightnessController brightnessController = new BrightnessController(this);
//        brightnessController.setBrightness(brightness);
//    }
}

