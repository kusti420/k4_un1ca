package com.k4.homeclock;

import android.content.Context;
import android.os.SemSystemProperties;
import android.util.Log;

import com.samsung.android.wallpaper.live.unified.engines.layered.source.b;

import java.util.ArrayList;
import java.util.Map;
import java.util.WeakHashMap;

/**
 * Home-screen depth clock for Samsung's layered wallpaper (SpriteWallpaper, LayeredWallpaperService), patches/home_depth_clock.
 *
 * Hooks (each one returns at once unless the engine shows the home screen and the switch is on):
 *  - c3.a.a (WallpaperEngineFactory.createEngine), right after the stock FlattenLayeredPresenter (h3.d) is built:
 *    {@link #presenter} swaps in {@link HomeClockPresenter} for the home-only instance (which & 3 == 1).
 *  - h3.a.e (AbstractLayeredPresenter.updateSurfaceSize), right after the layer list is built: {@link #afterBuild}
 *    adds a gated {@link ClockNode} to the BgCachableLayeredPresenter (h3.b) of a home+lock shared wallpaper
 *    (which & 3 == 3). That presenter keeps its separate layers for the lock screen's own screen on/off animation, so it
 *    is not replaced; the clock is drawn only while the keyguard is gone and the display is ON.
 *  - f3.a (LayeredEngine) onCreate / onVisibilityChanged / onDestroy: {@link EngineState} (reload receiver, minute ticker).
 *
 * Switch: persist.sys.k4.home_depth_clock (1 = on). Settings writes it and sends {@link #ACTION_RELOAD}; the engine
 * then rebuilds its own sub engine in-process (switchable.d.stopSelf -> UnifiedEngine.onSubEngineDestroyRequested ->
 * the factory again), so the wallpaper process never dies (WallpaperManagerService reverts to the default wallpaper
 * when a wallpaper process dies twice within 10 s).
 */
public final class HomeDepthClock {
    static final String TAG = "K4HomeClock";
    static final String PROP = "persist.sys.k4.home_depth_clock";
    public static final String ACTION_RELOAD = "com.k4.homeclock.action.RELOAD";
    /** Only senders holding this permission (Settings, shell) are heard. */
    static final String RELOAD_PERMISSION = "android.permission.WRITE_SECURE_SETTINGS";

    private static final Map<f3.a, EngineState> ENGINES = new WeakHashMap<>();
    private static final Map<h3.a, ClockNode> CLOCKS = new WeakHashMap<>();

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

    /**
     * The shared home+lock path is opt-in until it has been checked on a phone with a shared layered wallpaper (lock
     * screen / AOD / screen-off transitions must never show the clock): persist.sys.k4.home_depth_clock_shared=1.
     */
    static boolean sharedEnabled() {
        return "1".equals(prop(PROP + "_shared"));
    }

    /** The instance draws the home screen (FLAG_SYSTEM), alone (1) or shared with the lock screen (3). */
    static boolean homeCapable(int which) {
        return (which & 1) != 0;
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

    /** h3.a.e hook, after the presenter built its layer list. Only the shared home+lock instance's h3.b is touched. */
    public static void afterBuild(h3.a p) {
        try {
            if (p.getClass() != h3.b.class || (p.c & 3) != 3 || !enabled() || !sharedEnabled()) {
                return;
            }
            g0.a data = p.e;
            if (data == null) {
                return;
            }
            ArrayList<Object> list = p.f.c;
            int at = data.d == null ? -1 : list.indexOf(data.d);
            if (at < 0) {
                at = list.size();
            }
            i3.c subject = data.d instanceof i3.c ? (i3.c) data.d : null;
            i3.c background = data.c instanceof i3.c ? (i3.c) data.c : null;
            ClockNode clock = new ClockNode(p.a, p.g, p.h, HomeClockPresenter.subjectTop(subject), null, background, p);
            list.add(at, clock);
            synchronized (CLOCKS) {
                CLOCKS.put(p, clock);
            }
            KeyguardWatch.ensure(p.a);
            Log.i(TAG, "shared home+lock wallpaper (which=" + p.c + "): gated clock at layer " + at + "/" + list.size());
        } catch (Throwable t) {
            Log.e(TAG, "afterBuild", t);
        }
    }

    static void setClock(h3.a p, ClockNode clock) {
        synchronized (CLOCKS) {
            if (clock == null) {
                CLOCKS.remove(p);
            } else {
                CLOCKS.put(p, clock);
            }
        }
    }

    static ClockNode clockOf(f3.a engine) {
        synchronized (CLOCKS) {
            return engine.g == null ? null : CLOCKS.get(engine.g);
        }
    }

    static f3.a engineOf(h3.a p) {
        synchronized (ENGINES) {
            for (f3.a e : ENGINES.keySet()) {
                if (e != null && e.g == p) {
                    return e;
                }
            }
        }
        return null;
    }

    static EngineState[] states() {
        synchronized (ENGINES) {
            return ENGINES.values().toArray(new EngineState[0]);
        }
    }

    public static void onCreate(f3.a engine) {
        try {
            if (!homeCapable(engine.getWhich())) {
                return;
            }
            EngineState st = new EngineState(engine);
            synchronized (ENGINES) {
                ENGINES.put(engine, st);
            }
            st.start();
        } catch (Throwable t) {
            Log.e(TAG, "onCreate", t);
        }
    }

    public static void onVisibility(f3.a engine, boolean visible) {
        try {
            EngineState st;
            synchronized (ENGINES) {
                st = ENGINES.get(engine);
            }
            if (st != null) {
                st.setVisible(visible);
            }
        } catch (Throwable t) {
            Log.e(TAG, "onVisibility", t);
        }
    }

    public static void onDestroy(f3.a engine) {
        try {
            EngineState st;
            synchronized (ENGINES) {
                st = ENGINES.remove(engine);
            }
            if (st != null) {
                st.stop();
            }
        } catch (Throwable t) {
            Log.e(TAG, "onDestroy", t);
        }
    }
}
