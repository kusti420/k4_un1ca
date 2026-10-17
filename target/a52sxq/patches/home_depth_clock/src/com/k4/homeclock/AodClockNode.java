package com.k4.homeclock;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Point;
import android.os.Looper;
import android.text.format.DateFormat;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import java.lang.reflect.Method;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

/**
 * Samsung's own lock-screen clock (AOD clockpack ClockView, see {@link AodHost}) drawn between the background and the
 * cut-out subject, styled from the editor's saved ClockItem the way the lock screen styles it (AODService
 * KeyguardClockProvider: getClockView -> setFontType(ClockFontData) -> setClockMaxWidth -> colour by the ClockItem
 * colour type) and placed at the saved on-screen rect and scale.
 *
 * The view is never attached to a window: every draw does forceRefresh(now) (the real time, not a fixed one), measure,
 * layout and View.draw into the wallpaper canvas. EngineState redraws once a minute while visible (text() changes); a
 * locale / time zone / 12-24 h change also changes text(), and the next draw inflates a fresh view.
 *
 * Any failure (here or while drawing) is logged and the plain {@link ClockNode} given at construction takes over.
 */
final class AodClockNode extends DepthClock {
    private final HomeClockItem item;
    private final ClockNode fallback;
    private final int w;
    private final int h;
    private final int fontColorType;
    private final int areaColor;
    private AodHost host;
    private View clock;
    private String builtFor = "";
    private volatile boolean failed;
    private boolean loggedPlacement;

    private AodClockNode(Context context, int w, int h, HomeClockItem item, Bitmap background, ClockNode fallback,
            i3.c scaleRef, h3.a gatedOwner) {
        super(context, "K4AodClockNode", scaleRef, gatedOwner);
        this.item = item;
        this.fallback = fallback;
        this.w = w;
        this.h = h;
        float[] f = screenFactors(context, w, h);
        int l = Math.round(item.rect.left * f[0]);
        int t = Math.round(item.rect.top * f[1]);
        int r = Math.round(item.rect.right * f[0]);
        int b = Math.round(item.rect.bottom * f[1]);
        float lum = luminance(background, l, t, r, b);
        // what SystemUI gives the lock-screen clock: 0 = white text (dark wallpaper), 1 = black (light wallpaper)
        // the editor's own analysis when saved with the item, else a luminance guess
        fontColorType = item.fontColorType != null ? item.fontColorType : (lum > 0.6f ? 1 : 0);
        areaColor = meanColor(background, l, t, r, b);
    }

    /** The AOD clock for this item, or an exception (the caller then uses {@code fallback} itself). */
    static AodClockNode create(Context context, int w, int h, HomeClockItem item, Bitmap background, ClockNode fallback,
            i3.c scaleRef, h3.a gatedOwner) throws Exception {
        AodClockNode n = new AodClockNode(context, w, h, item, background, fallback, scaleRef, gatedOwner);
        try {
            n.host = AodHost.acquire(context);
            n.inflate();
            n.place(true); // measure + layout once now, so a broken view fails here and not on screen
        } catch (Throwable t) {
            n.release();
            if (t instanceof Exception) {
                throw (Exception) t;
            }
            throw new RuntimeException(t);
        }
        return n;
    }

    @Override
    String text() {
        return super.text() + "|" + config();
    }

    @Override
    String expected() {
        return failed ? fallback.expected() : super.expected();
    }

    /** Locale, time zone and 12/24 h: a change means a fresh view. */
    private String config() {
        return Locale.getDefault().toLanguageTag() + "|" + TimeZone.getDefault().getID() + "|"
                + DateFormat.is24HourFormat(a);
    }

    private void inflate() throws Exception {
        String cfg = config();
        View v = host.clockView(item.clockType);
        configure(v);
        clock = v;
        builtFor = cfg;
        Log.i(HomeDepthClock.TAG, "AOD clock view " + v.getClass().getName() + " (" + item + "), fontColorType="
                + fontColorType + ", areaColor=#" + Integer.toHexString(areaColor));
    }

    /** The lock screen's own setup order (KeyguardClockProvider.getClockView / updateClockColor). */
    private void configure(View v) throws Exception {
        Class<?> cv = host.cls(AodHost.CP + "ClockView");
        if (!cv.isInstance(v)) {
            throw new IllegalStateException("not a ClockView: " + v.getClass());
        }
        // off-screen setup like AODService's own: awake (not dozing) colours, no spring animation
        opt(v, "setDozing", new Class<?>[] {boolean.class}, false);
        opt(v, "setDozeAmount", new Class<?>[] {float.class}, 0f);
        opt(v, "setAnimationAllowed", new Class<?>[] {boolean.class}, false);
        opt(v, "setShowWeatherInformation", new Class<?>[] {boolean.class}, false);
        if (item.fontIndex != null) {
            Class<?> fe = host.cls(AodHost.CP + "extension.FontExtension");
            if (fe.isInstance(v)) {
                Class<?> fd = host.cls(AodHost.CP + "ClockFontData");
                Object data = fd.getConstructor(int.class, String.class, Integer.class, Integer.class, List.class)
                        .newInstance(item.fontIndex, item.fontPath,
                                item.fontWeight != null ? item.fontWeight : Integer.valueOf(-1),
                                item.fontRounded != null ? item.fontRounded : Integer.valueOf(-1),
                                stretchable() ? item.fontHeights : null);
                fe.getMethod("setFontType", fd).invoke(v, data);
            } else if (item.fontPath.isEmpty()) {
                call(v, "setFontType", new Class<?>[] {int.class}, item.fontIndex);
            } else {
                call(v, "setFontType", new Class<?>[] {int.class, String.class}, item.fontIndex, item.fontPath);
            }
        }
        float[] f = screenFactors(a, w, h);
        int screenW = Math.round(w / f[0]);
        int margin = Math.max(0, Math.min(item.rect.left, screenW - item.rect.right));
        int maxW = Math.round((screenW - 2 * margin) / item.scale);
        if (maxW > 0) {
            call(v, "setClockMaxWidth", new Class<?>[] {int.class}, maxW);
        }
        opt(v, "setShowDateInfoFirst", new Class<?>[] {boolean.class}, item.showDateFirst);
        if (areaColor != 0) {
            opt(v, "setClockAreaWallpaperColor", new Class<?>[] {int.class}, areaColor);
        }
        opt(v, "setFontColorType", new Class<?>[] {int.class}, fontColorType);
        String c = item.colorType;
        if (c.startsWith("Adaptive")) {
            int adaptive = item.color != null ? item.color
                    : a.getColor(fontColorType == 1 ? android.R.color.system_accent1_800 : android.R.color.system_accent1_100);
            call(v, "setColorThemeAdaptiveColor", new Class<?>[] {int.class}, adaptive);
            if (item.hasShadow) {
                Class<?> ss = host.cls(AodHost.CP + "ShadowStyle");
                Object style = ss.getConstructor().newInstance();
                ss.getField("shadowColor").setInt(style, item.shadowColor);
                ss.getField("shadowRadius").setFloat(style, item.shadowRadius);
                ss.getField("shadowDx").setFloat(style, item.shadowDx);
                ss.getField("shadowDy").setFloat(style, item.shadowDy);
                opt(v, "setShadowStyle", new Class<?>[] {ss}, style);
            }
        } else if (c.equals("StaticColorImpl") && item.color != null) {
            call(v, "setCustomColor", new Class<?>[] {int.class}, item.color);
        } else {
            call(v, "setPaletteIndex", new Class<?>[] {int.class}, c.equals("ClockPresetColorImpl") ? item.presetIndex : 0);
        }
    }

    /** Samsung's canApplyStretchFont: digital clock types 1/2 with a stretch font (0, 800-805, 812, 813). */
    private boolean stretchable() {
        Integer f = item.fontIndex;
        return (item.clockType == 1 || item.clockType == 2) && f != null
                && (f == 0 || (f >= 800 && f <= 805) || f == 812 || f == 813);
    }

    private float left;
    private float top;
    private float scale;

    /** forceRefresh(now), measure, layout and where (surface pixels) the scaled view goes. */
    private void place(boolean log) throws Exception {
        View v = clock;
        opt(v, "stopSpringAnimation", new Class<?>[0]);
        call(v, "forceRefresh", new Class<?>[] {long.class}, System.currentTimeMillis());
        int unspecified = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        v.measure(unspecified, unspecified);
        int mw = v.getMeasuredWidth();
        int mh = v.getMeasuredHeight();
        if (mw <= 0 || mh <= 0) {
            throw new IllegalStateException("AOD clock measured " + mw + "x" + mh);
        }
        v.layout(0, 0, mw, mh);
        float[] f = screenFactors(a, w, h);
        scale = item.scale * f[0];
        float rectW = item.rect.width() * f[0];
        float g = "Center".equalsIgnoreCase(item.gravityX) ? 0.5f : "End".equalsIgnoreCase(item.gravityX) ? 1f : 0f;
        left = item.rect.left * f[0] + (rectW - mw * scale) * g;
        top = item.rect.top * f[1];
        if (log || !loggedPlacement) {
            loggedPlacement = true;
            Log.i(HomeDepthClock.TAG, "AOD clock placed: measured " + mw + "x" + mh + " x" + scale + " at " + left
                    + "," + top + " (saved rect " + item.rect.toShortString() + ", surface " + w + "x" + h + ")");
        }
    }

    @Override
    public void a(Canvas canvas) {
        if (failed) {
            fallback.a(canvas);
            lastDrawn = fallback.lastDrawn;
            return;
        }
        if (!showing()) {
            lastDrawn = "";
            return;
        }
        try {
            if (Looper.myLooper() != Looper.getMainLooper()) {
                Log.w(HomeDepthClock.TAG, "AOD clock drawn off the main thread: " + Thread.currentThread().getName());
            }
            String t = text();
            if (!builtFor.equals(config())) {
                Log.i(HomeDepthClock.TAG, "AOD clock: locale/time zone/12-24 h changed, new view");
                inflate();
            }
            place(false);
            int save = canvas.save();
            float z = zoom();
            if (z != 1f) {
                canvas.scale(z, z, canvas.getWidth() / 2f, canvas.getHeight() / 2f);
            }
            canvas.translate(left, top);
            canvas.scale(scale, scale);
            clock.draw(canvas);
            canvas.restoreToCount(save);
            lastDrawn = t;
        } catch (Throwable e) {
            Throwable cause = e instanceof java.lang.reflect.InvocationTargetException && e.getCause() != null ? e.getCause() : e;
            Log.e(HomeDepthClock.TAG, "AOD clock draw failed, plain clock from now on", cause);
            failed = true;
            release();
            fallback.a(canvas);
            lastDrawn = fallback.lastDrawn;
        }
    }

    @Override
    void release() {
        clock = null;
        AodHost h = host;
        host = null;
        if (h != null) {
            h.release();
        }
    }

    /** Surface pixels per real screen pixel (x, y); the saved rect is in real screen pixels. */
    private static float[] screenFactors(Context c, int w, int h) {
        Point real = new Point();
        try {
            WindowManager wm = c.getSystemService(WindowManager.class);
            android.graphics.Rect b = wm.getMaximumWindowMetrics().getBounds();
            real.set(b.width(), b.height());
        } catch (Throwable t) {
            real.set(w, h);
        }
        if (real.x <= 0 || real.y <= 0) {
            real.set(w, h);
        }
        // the wallpaper may be laid out rotated relative to the reported bounds
        if ((real.x > real.y) != (w > h)) {
            real.set(real.y, real.x);
        }
        return new float[] {(float) w / real.x, (float) h / real.y};
    }

    private static Object call(Object o, String name, Class<?>[] types, Object... args) throws Exception {
        Method m = o.getClass().getMethod(name, types);
        return m.invoke(o, args);
    }

    /** Optional setter: a missing or failing one is logged, not fatal. */
    private static void opt(Object o, String name, Class<?>[] types, Object... args) {
        try {
            call(o, name, types, args);
        } catch (Throwable t) {
            Log.w(HomeDepthClock.TAG, "AOD clock: " + name + " failed: " + t);
        }
    }
}
