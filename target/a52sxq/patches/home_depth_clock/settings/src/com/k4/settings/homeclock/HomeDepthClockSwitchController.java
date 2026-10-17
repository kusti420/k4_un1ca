/*
 * Settings > UN1CA > UI settings > "Home screen depth clock" (a52sxq home_depth_clock patch).
 * Writes persist.sys.k4.home_depth_clock and asks the wallpaper engine to rebuild itself (HomeDepthClock in
 * SpriteWallpaper). Generated into ../smali by ../build.sh; settings.sh checks every SecSettings member it uses.
 */
package com.k4.settings.homeclock;

import android.content.Context;
import android.content.Intent;
import android.os.SemSystemProperties;
import android.util.Log;

import com.android.settings.core.TogglePreferenceController;

public class HomeDepthClockSwitchController extends TogglePreferenceController {
    static final String TAG = "K4HomeClockSettings";
    static final String PROP = "persist.sys.k4.home_depth_clock";
    static final String WALLPAPER_PACKAGE = "com.samsung.android.wallpaper.live";
    static final String ACTION_RELOAD = "com.k4.homeclock.action.RELOAD";

    public HomeDepthClockSwitchController(Context context, String key) {
        super(context, key);
    }

    /** Tell the layered wallpaper engine to rebuild with the new settings (in-process, no restart). */
    static void reload(Context context) {
        try {
            context.sendBroadcast(new Intent(ACTION_RELOAD).setPackage(WALLPAPER_PACKAGE)
                    .addFlags(Intent.FLAG_RECEIVER_FOREGROUND));
        } catch (RuntimeException e) {
            Log.w(TAG, "reload broadcast failed", e);
        }
    }

    static void set(String prop, String value) {
        try {
            SemSystemProperties.set(prop, value);
        } catch (RuntimeException e) {
            Log.w(TAG, "Failed to set " + prop, e);
        }
    }

    @Override
    public int getAvailabilityStatus() {
        try {
            mContext.getPackageManager().getPackageInfo(WALLPAPER_PACKAGE, 0);
            return 0; // AVAILABLE
        } catch (Exception e) {
            return 3; // UNSUPPORTED_ON_DEVICE
        }
    }

    @Override
    public boolean isChecked() {
        String v = SemSystemProperties.get(PROP);
        return "1".equals(v) || "true".equalsIgnoreCase(v);
    }

    @Override
    public boolean setChecked(boolean checked) {
        set(PROP, checked ? "1" : "0");
        reload(mContext);
        return true;
    }

    @Override
    public boolean isControllable() {
        return false;
    }

    @Override
    public int getSliceHighlightMenuRes() {
        return 0;
    }
}
