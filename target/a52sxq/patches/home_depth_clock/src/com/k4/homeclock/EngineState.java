package com.k4.homeclock;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.lang.ref.WeakReference;

/**
 * Per home-capable LayeredEngine (which & 1). Two receivers:
 *  - reload ({@link HomeDepthClock#ACTION_RELOAD}, sender must hold WRITE_SECURE_SETTINGS): registered for the
 *    engine's lifetime so the Settings switch can turn the clock on; it does nothing but rebuild the sub engine, and
 *    only when the clock is on now or was on before.
 *  - minute ticker (TIME_TICK, TIME_SET, TIMEZONE_CHANGED, LOCALE_CHANGED): registered only while the engine has a
 *    clock and is visible. ACTION_TIME_TICK is not a wakeup broadcast, so nothing here wakes the CPU or draws per
 *    frame; a redraw happens only when what the clock should show differs from what is on screen. The same tick asks
 *    again for weather the clock should show but has not got yet (AodHost.retryWeather, at most once a minute).
 */
final class EngineState {
    private final WeakReference<f3.a> engine;
    private final Context context;
    private final Handler main = new Handler(Looper.getMainLooper());
    private boolean visible;
    private boolean tickerOn;
    private boolean reloadOn;

    private final Runnable reload = new Runnable() {
        @Override
        public void run() {
            f3.a e = engine.get();
            if (e == null) {
                return;
            }
            boolean want = HomeDepthClock.enabled() && ((e.getWhich() & 3) == 1 || HomeDepthClock.sharedEnabled());
            boolean have = HomeDepthClock.clockOf(e) != null || e.g instanceof HomeClockPresenter;
            if (!want && !have) {
                return;
            }
            Log.i(HomeDepthClock.TAG, "reload (which=" + e.getWhich() + ", clock " + have + " -> " + want + "): rebuilding the engine");
            e.stopSelf();
        }
    };

    /** A queued reload waits for a new wallpaper the sender is applying (see {@link #newEngine}). */
    private boolean reloadAwaitsWallpaper;

    private final BroadcastReceiver reloadReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context c, Intent intent) {
            main.removeCallbacks(reload);
            // The Wallpaper & style editor saves the clock before it applies the new wallpaper, which then creates a
            // new engine that reads the clock settings itself: rebuilding this one first would only draw the old
            // layers once more. Its reload therefore waits; a new home engine (or this one's destruction) drops it,
            // and it runs only if no new wallpaper arrives in time (an apply that failed). Others: coalesce toggles.
            reloadAwaitsWallpaper = intent.getBooleanExtra(HomeDepthClock.EXTRA_WALLPAPER_PENDING, false);
            main.postDelayed(reload, reloadAwaitsWallpaper ? WALLPAPER_WAIT_MS : 300);
        }
    };
    private static final long WALLPAPER_WAIT_MS = 6000;

    private final BroadcastReceiver tickReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context c, Intent intent) {
            redrawIfStale(intent.getAction(), false);
            retryWeather(intent.getAction());
        }
    };

    EngineState(f3.a e) {
        engine = new WeakReference<>(e);
        context = e.getAppContext().getApplicationContext();
    }

    void start() {
        IntentFilter f = new IntentFilter(HomeDepthClock.ACTION_RELOAD);
        context.registerReceiver(reloadReceiver, f, HomeDepthClock.RELOAD_PERMISSION, null, Context.RECEIVER_EXPORTED);
        reloadOn = true;
    }

    /** Another home engine was created (a new wallpaper): a reload waiting for it is not needed any more. */
    void newEngine() {
        if (reloadAwaitsWallpaper && main.hasCallbacks(reload)) {
            main.removeCallbacks(reload);
            Log.i(HomeDepthClock.TAG, "new wallpaper engine: queued reload of the old one dropped");
        }
        reloadAwaitsWallpaper = false;
    }

    void stop() {
        main.removeCallbacks(reload);
        setVisible(false);
        if (reloadOn) {
            unregister(reloadReceiver);
            reloadOn = false;
        }
    }

    void setVisible(boolean v) {
        visible = v;
        f3.a e = engine.get();
        boolean want = v && e != null && HomeDepthClock.clockOf(e) != null;
        if (want && !tickerOn) {
            IntentFilter f = new IntentFilter(Intent.ACTION_TIME_TICK);
            f.addAction(Intent.ACTION_TIME_CHANGED); // also sent for a 12/24 h switch
            f.addAction(Intent.ACTION_TIMEZONE_CHANGED);
            f.addAction(Intent.ACTION_LOCALE_CHANGED);
            context.registerReceiver(tickReceiver, f, Context.RECEIVER_NOT_EXPORTED);
            tickerOn = true;
        } else if (!want && tickerOn) {
            unregister(tickReceiver);
            tickerOn = false;
        }
        if (want) {
            redrawIfStale("visible", false);
            retryWeather("visible");
        }
    }

    /** A visible clock's weather is still missing: ask again (rate-limited in AodHost, no wakeups of its own). */
    private void retryWeather(String why) {
        try {
            f3.a e = engine.get();
            DepthClock clock = e == null || !visible ? null : HomeDepthClock.clockOf(e);
            if (clock != null) {
                clock.retryWeather(why);
            }
        } catch (Throwable t) {
            Log.e(HomeDepthClock.TAG, "weather retry", t);
        }
    }

    void redrawIfStale(String why) {
        redrawIfStale(why, false);
    }

    /** anyVisibility: also draw while hidden (keyguard changes, so the next frame shown is already right). */
    void redrawIfStale(String why, boolean anyVisibility) {
        try {
            f3.a e = engine.get();
            DepthClock clock = e == null ? null : HomeDepthClock.clockOf(e);
            if (clock == null || !(visible || anyVisibility)) {
                return;
            }
            String now = clock.expected();
            if (now.equals(clock.lastDrawn)) {
                return;
            }
            Log.d(HomeDepthClock.TAG, "redraw (" + why + "): '" + clock.lastDrawn + "' -> '" + now + "'");
            e.b(e.getSurfaceHolder());
        } catch (Throwable t) {
            Log.e(HomeDepthClock.TAG, "redraw", t);
        }
    }

    private void unregister(BroadcastReceiver r) {
        try {
            context.unregisterReceiver(r);
        } catch (IllegalArgumentException ignored) {
        }
    }
}
