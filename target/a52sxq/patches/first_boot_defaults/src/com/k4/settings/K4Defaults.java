package com.k4.settings;

import android.content.Context;
import android.os.SystemProperties;
import android.provider.Settings;
import android.util.Slog;

/**
 * Called first in ActivityManagerService.finishBooting() (patches/first_boot_defaults). Applies the ROM's changed
 * defaults ONCE per device (marker persist.sys.k4.defaults_v1), so a user who changes them back keeps their choice.
 * v1: Accessibility > Visibility enhancements > "Reduce transparency and blur" on (Settings.Global
 * accessibility_reduce_transparency=1). Measured on the A52s (9.3.36, ABBA): launcher janky frames 4.9% -> 3.6%,
 * 90th percentile frame 10.5 -> 8 ms, GPU load about a quarter lower; the shade/recents about the same.
 */
public final class K4Defaults {
    private static final String TAG = "K4Defaults";
    private static final String MARKER = "persist.sys.k4.defaults_v1";

    private K4Defaults() {}

    public static void apply(Context context) {
        try {
            if (context == null || SystemProperties.getInt(MARKER, 0) >= 1) return;
            Settings.Global.putInt(context.getContentResolver(), "accessibility_reduce_transparency", 1);
            SystemProperties.set(MARKER, "1");
            Slog.i(TAG, "defaults v1 applied: Reduce transparency and blur on");
        } catch (Throwable t) {
            Slog.w(TAG, "defaults not applied", t);
        }
    }
}
