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
 *    onCreate also appends {@link PostDim} to the engine's root node list, after its DarkModeNode, for a
 *    HomeClockPresenter: the clock is drawn above the dark mode wallpaper dim, like the editor's and the lock screen's;
 *    and it reads the current dim (f3.a.d, updateDarkModeFilter) at once, so a clock engine created while the home
 *    screen shows is dimmed from its first frame.
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
    /** RELOAD extra (boolean): the sender is about to apply a new wallpaper, whose new engine reads the settings itself. */
    public static final String EXTRA_WALLPAPER_PENDING = "com.k4.homeclock.extra.WALLPAPER_PENDING";
    /** Only senders holding this permission (Settings, shell) are heard. */
    static final String RELOAD_PERMISSION = "android.permission.WRITE_SECURE_SETTINGS";

    private static final Map<f3.a, EngineState> ENGINES = new WeakHashMap<>();
    private static final Map<h3.a, DepthClock> CLOCKS = new WeakHashMap<>();

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
            DepthClock clock = makeClock(p.a, p.g, p.h, HomeClockPresenter.subjectTop(subject), null, background, p);
            list.add(at, clock);
            setClock(p, clock);
            KeyguardWatch.ensure(p.a);
            Log.i(TAG, "shared home+lock wallpaper (which=" + p.c + "): gated clock at layer " + at + "/" + list.size());
        } catch (Throwable t) {
            Log.e(TAG, "afterBuild", t);
        }
    }

    /**
     * The clock layer for a presenter build: Samsung's AOD lock-screen clock styled and placed as saved by the
     * Wallpaper & style editor ({@link HomeClockItem}), or the plain {@link ClockNode} when nothing is saved or the AOD
     * clock cannot be created (logged).
     */
    static DepthClock makeClock(Context context, int w, int h, float subjectTop, android.graphics.Bitmap background,
            i3.c scaleRef, h3.a gatedOwner) {
        ClockNode plain = new ClockNode(context, w, h, subjectTop, background, scaleRef, gatedOwner);
        HomeClockItem item = HomeClockItem.read(context);
        if (item == null) {
            Log.i(TAG, "no saved home clock item: plain clock");
            return plain;
        }
        try {
            return AodClockNode.create(context, w, h, item, background, plain, scaleRef, gatedOwner);
        } catch (Throwable t) {
            Throwable cause = t instanceof java.lang.reflect.InvocationTargetException && t.getCause() != null ? t.getCause() : t;
            Log.e(TAG, "AOD clock unavailable, plain clock (" + item + ")", cause);
            return plain;
        }
    }

    static void setClock(h3.a p, DepthClock clock) {
        DepthClock old;
        synchronized (CLOCKS) {
            old = clock == null ? CLOCKS.remove(p) : CLOCKS.put(p, clock);
        }
        if (old != null && old != clock) {
            try {
                old.release();
            } catch (Throwable t) {
                Log.w(TAG, "release", t);
            }
        }
    }

    static DepthClock clockOf(f3.a engine) {
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

    private static final Map<f3.a, Boolean> POST_DIM = new WeakHashMap<>();

    /**
     * Appended to the engine's root list after its DarkModeNode (f3.a.j), so what it draws is not darkened by the dark
     * mode wallpaper dim: a HomeClockPresenter's clock and subject (HomeClockPresenter.drawAbove), the subject dimmed
     * with the alpha DarkModeNode itself uses right now.
     */
    static final class PostDim extends i3.j {
        private final java.lang.ref.WeakReference<f3.a> engine;

        PostDim(f3.a e) {
            super(e.getAppContext(), "K4ClockAboveDim");
            engine = new java.lang.ref.WeakReference<>(e);
        }

        @Override
        public void a(android.graphics.Canvas canvas) {
            f3.a e = engine.get();
            if (e != null && e.g instanceof HomeClockPresenter) {
                ((HomeClockPresenter) e.g).drawAbove(canvas, dimOf(e));
            }
        }
    }

    /** DarkModeNode's current dim: it draws black at alpha(d) over everything while c is set (0 = no dim). */
    static float dimOf(f3.a e) {
        i3.e dark = e.j;
        return dark != null && dark.c && dark.d != 0 ? android.graphics.Color.alpha(dark.d) / 255f : 0f;
    }

    /** True when the engine showing {@code p} has a {@link PostDim} node, which then draws p's clock and subject. */
    static boolean postDimInstalled(h3.a p) {
        synchronized (POST_DIM) {
            for (f3.a e : POST_DIM.keySet()) {
                if (e != null && e.g == p) {
                    return true;
                }
            }
        }
        return false;
    }

    /** Redraw every visible home clock whose shown picture is stale (weather update); hidden ones redraw when shown. */
    static void redrawStale(String why) {
        for (EngineState st : states()) {
            st.redrawIfStale(why);
        }
    }

    public static void onCreate(f3.a engine) {
        try {
            if (!homeCapable(engine.getWhich())) {
                return;
            }
            for (EngineState other : states()) {
                other.newEngine();
            }
            if (engine.g instanceof HomeClockPresenter) {
                try {
                    // The engine sets its dark mode dim (DarkModeNode, and so PostDim's subject dim) only on a
                    // configuration change or when it turns invisible. A clock engine is often created while the home
                    // screen is showing (a reload from the editor or Settings): set it now, before the first frame,
                    // instead of drawing undimmed until the home screen is hidden once.
                    engine.d();
                } catch (Throwable t) {
                    Log.w(TAG, "dark mode dim", t);
                }
                try {
                    if (engine.h != null && engine.h.c != null && engine.j != null && engine.h.c.contains(engine.j)) {
                        engine.h.c.add(new PostDim(engine));
                        synchronized (POST_DIM) {
                            POST_DIM.put(engine, Boolean.TRUE);
                        }
                    } else {
                        Log.w(TAG, "no DarkModeNode in the engine's node list: clock drawn under the dark mode dim");
                    }
                } catch (Throwable t) {
                    Log.w(TAG, "post-dim node", t);
                }
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
            synchronized (POST_DIM) {
                POST_DIM.remove(engine);
            }
            if (st != null) {
                st.stop();
            }
        } catch (Throwable t) {
            Log.e(TAG, "onDestroy", t);
        }
    }
}
