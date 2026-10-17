package com.k4.homeclock;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.util.Log;


/**
 * Plain big clock, drawn between the background layers and the cut-out subject.
 * Placement (auto): the digits' lower third sits behind the top of the subject (so the subject visibly covers part of
 * the clock), clamped to 10 %..45 % of the screen height.
 * Tunables (read when the wallpaper is laid out: engine start, rotation, or a reload from Settings):
 *   persist.sys.k4.home_depth_clock_y      centre of the digits in % of the screen height; empty/"auto" = auto
 *   persist.sys.k4.home_depth_clock_color  empty/"white" = white (default), "accent" = theme (Monet) accent, light or
 *                                          dark by the wallpaper brightness under the clock, or #RRGGBB / #AARRGGBB
 * A gated clock ({@code owner} set: the shared home+lock instance) is drawn only while the keyguard is gone and the
 * display is ON; it follows the background's screen on/off zoom so it stays glued to the wallpaper.
 */
final class ClockNode extends DepthClock {
    private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.SUBPIXEL_TEXT_FLAG);
    private final float centerX;
    private final float baseline;
    private final boolean lightBackground;
    private final boolean accent;
    private final Integer fixedColor;

    ClockNode(Context context, int w, int h, float subjectTop, Bitmap background, i3.c scaleRef, h3.a gatedOwner) {
        super(context, "K4DepthClockNode", scaleRef, gatedOwner);
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

        String cp = HomeDepthClock.prop(HomeDepthClock.PROP + "_color");
        Integer c = Color.WHITE;
        boolean useAccent = false;
        if ("accent".equalsIgnoreCase(cp)) {
            useAccent = true;
        } else if (cp.startsWith("#")) {
            try {
                c = Color.parseColor(cp);
            } catch (IllegalArgumentException ignored) {
            }
        }
        accent = useAccent;
        fixedColor = c;
        lightBackground = useAccent && background != null && luminance(background, (int) (centerX - target / 2),
                (int) (baseline - digitH), (int) (centerX + target / 2), (int) baseline) > 0.6f;
        Log.i(HomeDepthClock.TAG, "layout: textSize=" + paint.getTextSize() + ", digitH=" + digitH + ", baseline="
                + baseline + " (subjectTop=" + subjectTop + "), color=" + (accent ? "accent" : Integer.toHexString(c))
                + (owner != null ? ", gated" : ""));
    }

    @Override
    public void a(Canvas canvas) {
        if (!showing()) {
            lastDrawn = "";
            return;
        }
        String t = text();
        int color = accent
                ? a.getColor(lightBackground ? android.R.color.system_accent1_800 : android.R.color.system_accent1_50)
                : fixedColor;
        paint.setColor(color);
        float s = zoom();
        int save = canvas.save();
        if (s != 1f) {
            canvas.scale(s, s, canvas.getWidth() / 2f, canvas.getHeight() / 2f);
        }
        canvas.drawText(t, centerX, baseline, paint);
        canvas.restoreToCount(save);
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
            return Float.NaN; // "auto"
        }
    }
}
