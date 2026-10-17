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
 *    frame; a redraw happens only when what the clock should show differs from what is on screen.
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

    private final BroadcastReceiver reloadReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context c, Intent intent) {
            main.removeCallbacks(reload);
            main.postDelayed(reload, 300); // coalesce quick toggles
        }
    };

    private final BroadcastReceiver tickReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context c, Intent intent) {
            redrawIfStale(intent.getAction(), false);
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
        }
    }

    void redrawIfStale(String why) {
        redrawIfStale(why, false);
    }

    /** anyVisibility: also draw while hidden (keyguard changes, so the next frame shown is already right). */
    void redrawIfStale(String why, boolean anyVisibility) {
        try {
            f3.a e = engine.get();
            ClockNode clock = e == null ? null : HomeDepthClock.clockOf(e);
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
