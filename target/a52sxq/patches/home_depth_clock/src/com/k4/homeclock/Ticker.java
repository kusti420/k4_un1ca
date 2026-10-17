package com.k4.homeclock;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import java.lang.ref.WeakReference;

/**
 * Minute updates for one home engine. Registered only while the home wallpaper is visible; ACTION_TIME_TICK is a
 * non-wakeup broadcast, so nothing here wakes the CPU or draws per frame. A redraw happens only when the text the
 * clock would show differs from what is on screen (minute tick, time/zone/12-24 h/locale change, or the home screen
 * coming back after the minute changed).
 */
final class Ticker extends BroadcastReceiver {
    private final HomeClockPresenter presenter;
    private WeakReference<f3.a> engine = new WeakReference<>(null);
    private Context registeredOn;

    Ticker(HomeClockPresenter presenter) {
        this.presenter = presenter;
    }

    void setVisible(f3.a e, boolean visible) {
        engine = new WeakReference<>(e);
        if (visible) {
            if (registeredOn == null) {
                Context ctx = presenter.a.getApplicationContext();
                IntentFilter f = new IntentFilter(Intent.ACTION_TIME_TICK);
                f.addAction(Intent.ACTION_TIME_CHANGED); // also sent for a 12/24 h switch
                f.addAction(Intent.ACTION_TIMEZONE_CHANGED);
                f.addAction(Intent.ACTION_LOCALE_CHANGED);
                ctx.registerReceiver(this, f, Context.RECEIVER_NOT_EXPORTED);
                registeredOn = ctx;
            }
            redrawIfStale("visible");
        } else if (registeredOn != null) {
            try {
                registeredOn.unregisterReceiver(this);
            } catch (IllegalArgumentException ignored) {
            }
            registeredOn = null;
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            redrawIfStale(intent.getAction());
        } catch (Throwable t) {
            Log.e(HomeDepthClock.TAG, "tick", t);
        }
    }

    private void redrawIfStale(String why) {
        f3.a e = engine.get();
        ClockNode clock = presenter.clock;
        if (e == null || clock == null) {
            return;
        }
        String now = clock.text();
        if (now.equals(clock.lastDrawn)) {
            return;
        }
        Log.d(HomeDepthClock.TAG, "redraw (" + why + "): " + clock.lastDrawn + " -> " + now);
        e.b(e.getSurfaceHolder());
    }
}
