package com.k4.homeclock;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.text.format.DateFormat;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * A clock layer between the background and the cut-out subject: {@link AodClockNode} (Samsung's own AOD lock-screen
 * clock) or {@link ClockNode} (plain text, the fallback). Holds what both share: the gating of the shared home+lock
 * instance, the background zoom reference and what was drawn last (EngineState's once-a-minute staleness check).
 */
abstract class DepthClock extends i3.j {
    /** Background node whose screen on/off zoom the clock follows (shared home+lock instance), or null. */
    final i3.c scaleRef;
    /** Set for the shared home+lock instance: draw only while the keyguard is gone and the display is ON. */
    final h3.a owner;
    volatile String lastDrawn = "";

    DepthClock(Context context, String name, i3.c scaleRef, h3.a gatedOwner) {
        super(context, name);
        this.scaleRef = scaleRef;
        this.owner = gatedOwner;
    }

    /** The minute (and whatever else changes the picture) a draw now would show. */
    String text() {
        boolean is24 = DateFormat.is24HourFormat(a);
        return new SimpleDateFormat(is24 ? "HH:mm" : "h:mm", Locale.getDefault()).format(new Date());
    }

    /** True unless this is the shared instance and the lock screen / AOD / screen-off is what it shows. */
    boolean showing() {
        if (owner == null) {
            return true;
        }
        if (KeyguardWatch.locked) {
            return false;
        }
        f3.a e = HomeDepthClock.engineOf(owner);
        if (e == null) {
            return false;
        }
        Object state = e.getDisplayState();
        return state instanceof Enum && "ON".equals(((Enum<?>) state).name());
    }

    /** What a draw now would put on screen ("" = nothing). */
    String expected() {
        return showing() ? text() : "";
    }

    /** The presenter is gone (or rebuilt): drop what this clock holds outside its own fields. */
    void release() {
    }

    /** Background zoom of the shared instance (1 = none). */
    float zoom() {
        float s = scaleRef != null ? scaleRef.e : 1f;
        return s > 0f ? s : 1f;
    }

    /** Mean relative luminance (0..1) of the wallpaper under l,t,r,b, sampled on a 24x8 grid; -1 if unknown. */
    static float luminance(Bitmap bm, int l, int t, int r, int b) {
        if (bm == null || bm.isRecycled() || bm.getConfig() == Bitmap.Config.HARDWARE) {
            return -1f;
        }
        l = Math.max(0, l);
        t = Math.max(0, t);
        r = Math.min(bm.getWidth() - 1, r);
        b = Math.min(bm.getHeight() - 1, b);
        if (r <= l || b <= t) {
            return -1f;
        }
        float sum = 0;
        int n = 0;
        for (int iy = 0; iy < 8; iy++) {
            int y = t + (b - t) * iy / 7;
            for (int ix = 0; ix < 24; ix++) {
                int p = bm.getPixel(l + (r - l) * ix / 23, y);
                sum += (0.2126f * Color.red(p) + 0.7152f * Color.green(p) + 0.0722f * Color.blue(p)) / 255f;
                n++;
            }
        }
        return sum / n;
    }

    /** Mean colour of the wallpaper under l,t,r,b (opaque), or 0 if unknown. */
    static int meanColor(Bitmap bm, int l, int t, int r, int b) {
        if (bm == null || bm.isRecycled() || bm.getConfig() == Bitmap.Config.HARDWARE) {
            return 0;
        }
        l = Math.max(0, l);
        t = Math.max(0, t);
        r = Math.min(bm.getWidth() - 1, r);
        b = Math.min(bm.getHeight() - 1, b);
        if (r <= l || b <= t) {
            return 0;
        }
        long rs = 0, gs = 0, bs = 0;
        int n = 0;
        for (int iy = 0; iy < 8; iy++) {
            int y = t + (b - t) * iy / 7;
            for (int ix = 0; ix < 24; ix++) {
                int p = bm.getPixel(l + (r - l) * ix / 23, y);
                rs += Color.red(p);
                gs += Color.green(p);
                bs += Color.blue(p);
                n++;
            }
        }
        return Color.rgb((int) (rs / n), (int) (gs / n), (int) (bs / n));
    }
}
