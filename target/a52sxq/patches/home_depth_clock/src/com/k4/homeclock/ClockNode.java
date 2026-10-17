package com.k4.homeclock;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.text.format.DateFormat;
import android.util.Log;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * Plain big clock, drawn between the background layers and the cut-out subject.
 * Placement: the digits' lower third sits behind the top of the subject (so the subject visibly covers part of the
 * clock), clamped to 10 %..45 % of the screen height. Colour: the theme (Monet) accent, light or dark depending on the
 * wallpaper brightness under the clock.
 * Tunables (read when the wallpaper is laid out, i.e. on engine start/rotation):
 *   persist.sys.k4.home_depth_clock_y      centre of the digits in % of the screen height (overrides the placement)
 *   persist.sys.k4.home_depth_clock_color  #RRGGBB / #AARRGGBB (overrides the theme colour)
 */
final class ClockNode extends i3.j {
    private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.SUBPIXEL_TEXT_FLAG);
    private final float centerX;
    private final float baseline;
    private final boolean lightBackground;
    private final Integer fixedColor;
    volatile String lastDrawn = "";

    ClockNode(Context context, int w, int h, float subjectTop, Bitmap background) {
        super(context, "K4DepthClockNode");
        paint.setTypeface(Typeface.create(Typeface.DEFAULT, 500, false));
        paint.setTextAlign(Paint.Align.CENTER);
        paint.setFontFeatureSettings("tnum");
        paint.setTextSize(100f);
        float target = (w <= h ? 0.84f : 0.42f) * w;
        paint.setTextSize(100f * target / paint.measureText("00:00"));
        Rect digits = new Rect();
        paint.getTextBounds("0123456789", 0, 10, digits);
        float digitH = -digits.top;

        float y = parse(HomeDepthClock.prop(HomeDepthClock.PROP + "_y"));
        if (!Float.isNaN(y)) {
            baseline = Math.min(h, Math.max(digitH, h * y / 100f + digitH / 2f));
        } else {
            float base = subjectTop >= 0 ? subjectTop + 0.35f * digitH : 0.30f * h + digitH / 2f;
            float min = 0.10f * h + digitH;
            float max = Math.max(min, 0.45f * h);
            baseline = Math.min(max, Math.max(min, base));
        }
        centerX = w / 2f;

        lightBackground = luminance(background, (int) (centerX - target / 2), (int) (baseline - digitH),
                (int) (centerX + target / 2), (int) baseline) > 0.6f;
        Integer c = null;
        String cp = HomeDepthClock.prop(HomeDepthClock.PROP + "_color");
        if (!cp.isEmpty()) {
            try {
                c = Color.parseColor(cp);
            } catch (IllegalArgumentException ignored) {
            }
        }
        fixedColor = c;
        Log.i(HomeDepthClock.TAG, "layout: textSize=" + paint.getTextSize() + ", digitH=" + digitH + ", baseline="
                + baseline + " (subjectTop=" + subjectTop + "), lightBg=" + lightBackground);
    }

    String text() {
        boolean is24 = DateFormat.is24HourFormat(a);
        return new SimpleDateFormat(is24 ? "HH:mm" : "h:mm", Locale.getDefault()).format(new Date());
    }

    @Override
    public void a(Canvas canvas) {
        String t = text();
        int color;
        if (fixedColor != null) {
            color = fixedColor;
        } else {
            color = a.getColor(lightBackground ? android.R.color.system_accent1_800 : android.R.color.system_accent1_50);
        }
        paint.setColor(color);
        canvas.drawText(t, centerX, baseline, paint);
        lastDrawn = t;
    }

    private static float parse(String s) {
        if (s.isEmpty()) {
            return Float.NaN;
        }
        try {
            float v = Float.parseFloat(s);
            return v >= 0 && v <= 100 ? v : Float.NaN;
        } catch (NumberFormatException e) {
            return Float.NaN;
        }
    }

    /** Mean relative luminance (0..1) of the wallpaper under the clock, sampled on a 24x8 grid. */
    private static float luminance(Bitmap bm, int l, int t, int r, int b) {
        l = Math.max(0, l);
        t = Math.max(0, t);
        r = Math.min(bm.getWidth() - 1, r);
        b = Math.min(bm.getHeight() - 1, b);
        if (r <= l || b <= t) {
            return 0f;
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
}
