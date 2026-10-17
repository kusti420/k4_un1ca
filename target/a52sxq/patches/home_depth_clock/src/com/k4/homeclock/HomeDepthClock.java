package com.k4.homeclock;

import android.content.Context;
import android.os.SemSystemProperties;
import android.util.Log;

import com.samsung.android.wallpaper.live.unified.engines.layered.source.b;

/**
 * Home-screen depth clock for Samsung's layered wallpaper (SpriteWallpaper, LayeredWallpaperService), patches/home_depth_clock.
 *
 * Hooks (all three are no-ops while persist.sys.k4.home_depth_clock is unset/0, so the engine stays stock):
 *  - c3.a.a (WallpaperEngineFactory.createEngine), right after the stock FlattenLayeredPresenter (h3.d) is built:
 *    {@link #presenter} swaps in {@link HomeClockPresenter} for the home-only instance (which & 3 == 1).
 *  - f3.a.onVisibilityChanged (LayeredEngine): {@link #onVisibility} starts/stops the minute ticker.
 *  - f3.a.onDestroy: {@link #onDestroy} stops it for good.
 */
public final class HomeDepthClock {
    static final String TAG = "K4HomeClock";
    static final String PROP = "persist.sys.k4.home_depth_clock";

    private HomeDepthClock() {}

    static String prop(String key) {
        try {
            String v = SemSystemProperties.get(key);
            return v == null ? "" : v.trim();
        } catch (Throwable t) {
            return "";
        }
    }

    public static boolean enabled() {
        String v = prop(PROP);
        return "1".equals(v) || "true".equalsIgnoreCase(v);
    }

    /** Factory hook: returns {@code stock} unless this is the home-only instance and the switch is on. */
    public static h3.a presenter(h3.a stock, Context context, int which, b source) {
        if ((which & 3) != 1 || !enabled()) {
            return stock;
        }
        try {
            Log.i(TAG, "home layered wallpaper (which=" + which + "): depth clock presenter");
            return new HomeClockPresenter(context, which, source);
        } catch (Throwable t) {
            Log.e(TAG, "presenter: falling back to stock", t);
            return stock;
        }
    }

    public static void onVisibility(f3.a engine, boolean visible) {
        try {
            if (engine.g instanceof HomeClockPresenter) {
                ((HomeClockPresenter) engine.g).ticker.setVisible(engine, visible);
            }
        } catch (Throwable t) {
            Log.e(TAG, "onVisibility", t);
        }
    }

    public static void onDestroy(f3.a engine) {
        try {
            if (engine.g instanceof HomeClockPresenter) {
                ((HomeClockPresenter) engine.g).ticker.setVisible(engine, false);
            }
        } catch (Throwable t) {
            Log.e(TAG, "onDestroy", t);
        }
    }
}
