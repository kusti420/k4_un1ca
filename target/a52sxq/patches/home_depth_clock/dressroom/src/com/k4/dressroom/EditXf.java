package com.k4.dressroom;

import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.util.Log;
import android.util.Size;
import android.view.HapticFeedbackConstants;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageView;

import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;

/**
 * Zoom-out and a little rotation in the Home "Set as wallpaper" editor (DressRoom 3.0.10.38), on top of Samsung's own
 * pan/zoom. Samsung's CropImageView moves and zooms the picture by its drawable bounds and never lets it get smaller
 * than the screen; that stays exactly as it is. This adds one extra transform T for the Home editor, about the middle of
 * the view: a scale s (1 down to {@link #MIN_S}), a rotation (at most {@link #MAX_DEG} either way) and, while zoomed out,
 * a translation, so the smaller picture can be placed anywhere.
 * <ul>
 * <li>CropImageView.onTouchEvent start ({@link #touch}): two fingers turning rotate the picture (after a small slop, so a
 * plain pinch never turns it), snapping to level within {@link #SNAP_DEG} with Samsung's alignment haptic
 * (semGetVibrationIndex(1), what the lock editor plays when an item snaps to its align assist line); while zoomed out
 * the fingers move the picture. Samsung gets the event mapped back through T, so its own drag/pinch keeps working
 * under the fingers. With T = identity the event is passed on untouched (stock behaviour).</li>
 * <li>CropImageView.N(scaleFactor) ({@link #scale}): pinching in past Samsung's minimum zooms out (s &lt; 1); pinching
 * out first undoes the zoom-out, then Samsung zooms in as before.</li>
 * <li>MaskImageView.onDraw, in place of its ImageView.onDraw call ({@link #draw}; inside Samsung's mask clip): with
 * T != identity the picture is drawn through T over a fill ({@link #fill}): by default a solid colour, the picture's
 * dominant border colour (the subject skipped), so the uncovered area continues the picture's own background; or, picked
 * in a Color | Blur switch styled and placed like Samsung's preview switch (shown only while zoomed out or tilted), the
 * picture itself heavily blurred, covering the screen and dimmed.</li>
 * <li>SaveImageMaker (d7.z) f / h / o / i ({@link #bakeBackground}, {@link #bakeObject}, {@link #thumbnail},
 * {@link #beforeXml}): the layered wallpaper Samsung saves is crop rects of the original picture, which cannot carry
 * a rotation or a zoom-out. With T != identity the background becomes the editor's picture rendered at screen size
 * (fill, rotation, zoom-out baked in) with full-screen crop rects, the subject (masked.jpg) is Samsung's segmentation
 * result rendered through the same transform, and the expand offsets are cleared; the rest of the save (and the home
 * engine) stays stock.</li>
 * </ul>
 * While two fingers rotate, a level guide (Samsung's align assist line drawable and guide box colour, lit up when level)
 * and an angle badge are drawn on the window overlay; they fade out on release.
 */
public final class EditXf {
    static final String TAG = HomeClock.TAG;
    static final float MAX_DEG = 45f;
    static final float SNAP_DEG = 2f;
    static final float ROT_SLOP_DEG = 6f;
    static final float MIN_S = 0.5f;
    static final String CROP = "com.samsung.android.app.dressroom.presentation.preview.widget.CropImageView";

    private static WeakReference<View> sView = new WeakReference<>(null);
    static volatile float s = 1f, deg = 0f, tx = 0f, ty = 0f;
    private static boolean sRotating;
    private static int sCount;
    private static float sRotStart, sRotBase, sFx, sFy, sSpanPrev, sSpanNow;
    private static MotionEvent sCopy;
    private static Guide sGuide;

    private EditXf() {}

    /** A new editor: no transform. */
    static void reset() {
        s = 1f;
        deg = 0f;
        tx = 0f;
        ty = 0f;
        sRotating = false;
        sCount = 0;
        sView = new WeakReference<>(null);
        sGuide = null;
        sBaked = new WeakReference<>(null);
        sBakedBg = null;
        sFill = FILL_COLOR;
        sSwitch = new WeakReference<>(null);
        sKeepStretch = null;
    }

    /** The angle shown and saved: level within {@link #SNAP_DEG}. */
    static float shownDeg() {
        float d = deg;
        return Math.abs(d) < SNAP_DEG ? 0f : d;
    }

    static boolean identity() {
        return s >= 1f && shownDeg() == 0f && tx == 0f && ty == 0f;
    }

    static boolean mine(View v) {
        return HomeClock.active && v != null && sView.get() == v;
    }

    /** T in view coordinates of the crop view. */
    static Matrix matrix(View v) {
        Matrix m = new Matrix();
        float cx = v.getWidth() / 2f, cy = v.getHeight() / 2f;
        m.setTranslate(-cx, -cy);
        m.postScale(s, s);
        m.postRotate(shownDeg());
        m.postTranslate(cx + tx, cy + ty);
        return m;
    }

    /** SubjectView: draw through T too (no-op unless the Home editor's picture is zoomed out or rotated). */
    static void apply(View crop, Canvas c) {
        if (mine(crop) && !identity()) {
            c.concat(matrix(crop));
        }
    }

    /** SubjectView change detection. */
    static void state(float[] a, int at) {
        a[at] = s;
        a[at + 1] = shownDeg();
        a[at + 2] = tx;
        a[at + 3] = ty;
    }

    // ---- touch ----

    static boolean bool(Object o, String name) {
        try {
            return (Boolean) HomeClock.field(o, name);
        } catch (Throwable t) {
            return false;
        }
    }

    /** Samsung would handle this touch (CropImageView.onTouchEvent: enabled, crop enabled (C), no overlay (E), not two-finger-only mode (D)). */
    static boolean handles(View v) {
        return v.isEnabled() && bool(v, "C") && !bool(v, "E") && !bool(v, "D");
    }

    static float angle(MotionEvent e, int skip) {
        int a = -1, b = -1;
        for (int i = 0; i < e.getPointerCount() && b < 0; i++) {
            if (i == skip) {
                continue;
            }
            if (a < 0) {
                a = i;
            } else {
                b = i;
            }
        }
        if (b < 0) {
            return 0f;
        }
        return (float) Math.toDegrees(Math.atan2(e.getY(b) - e.getY(a), e.getX(b) - e.getX(a)));
    }

    /** Distance between the first two fingers still down (view coordinates, untransformed), or 0. */
    static float span(MotionEvent e, int skip) {
        int a = -1, b = -1;
        for (int i = 0; i < e.getPointerCount() && b < 0; i++) {
            if (i == skip) {
                continue;
            }
            if (a < 0) {
                a = i;
            } else {
                b = i;
            }
        }
        return b < 0 ? 0f : (float) Math.hypot(e.getX(b) - e.getX(a), e.getY(b) - e.getY(a));
    }

    /**
     * How much the fingers really spread since the last event (1 = no change, NaN = not in a two-finger move).
     * Samsung's ScaleGestureDetector sees the event mapped back through T, so its factor also contains the change of
     * s itself (fingers that stay put look farther apart in picture space once the picture shrank): fed back into s that
     * made s alternate between two values every event, and a pure two-finger twist could end at the 0.5 limit.
     */
    static float rawFactor() {
        return sCount >= 2 && sSpanPrev > 1f && sSpanNow > 1f ? sSpanNow / sSpanPrev : Float.NaN;
    }

    static float norm(float d) {
        while (d > 180f) {
            d -= 360f;
        }
        while (d < -180f) {
            d += 360f;
        }
        return d;
    }

    /** CropImageView.onTouchEvent start: returns the event Samsung's code should see. */
    public static MotionEvent touch(View v, MotionEvent e) {
        if (!HomeClock.active || v == null || e == null || !CROP.equals(v.getClass().getName())) {
            return e;
        }
        try {
            if (!handles(v)) {
                return e;
            }
            noStretch(v);
            if (sView.get() != v) {
                if (sView.get() != null && !identity()) {
                    return e; // another crop view owns the transform
                }
                sView = new WeakReference<>(v);
            }
            int act = e.getActionMasked();
            int skip = act == MotionEvent.ACTION_POINTER_UP || act == MotionEvent.ACTION_UP ? e.getActionIndex() : -1;
            float fx = 0f, fy = 0f;
            int n = 0;
            for (int i = 0; i < e.getPointerCount(); i++) {
                if (i != skip) {
                    fx += e.getX(i);
                    fy += e.getY(i);
                    n++;
                }
            }
            if (n > 0) {
                fx /= n;
                fy /= n;
            }
            boolean changed = false;
            if (act == MotionEvent.ACTION_DOWN) {
                sRotating = false;
                sCount = 0;
            }
            float span = span(e, skip);
            if (n != sCount || act != MotionEvent.ACTION_MOVE) {
                // pointer set changed: re-base the focus, the angle and the finger distance, nothing moves
                sFx = fx;
                sFy = fy;
                sCount = n;
                sSpanPrev = span;
                sSpanNow = span;
                if (n >= 2) {
                    sRotStart = angle(e, skip);
                    sRotBase = deg;
                }
            } else {
                sSpanPrev = sSpanNow;
                sSpanNow = span;
                if (s < 1f && (fx != sFx || fy != sFy)) {
                    tx += fx - sFx;
                    ty += fy - sFy;
                    clampT(v);
                    changed = true;
                }
                sFx = fx;
                sFy = fy;
                if (n >= 2) {
                    float a = angle(e, -1);
                    if (!sRotating && Math.abs(norm(a - sRotStart)) > ROT_SLOP_DEG) {
                        sRotating = true;
                        sRotStart = a;
                        sRotBase = deg;
                        guide(v, true);
                    }
                    if (sRotating) {
                        float before = shownDeg();
                        deg = Math.max(-MAX_DEG, Math.min(MAX_DEG, sRotBase + norm(a - sRotStart)));
                        float after = shownDeg();
                        if (after != before) {
                            changed = true;
                            if (after == 0f || (before != 0f && Math.signum(after) != Math.signum(before))) {
                                haptic(v); // level (snapped, or turned through level)
                            }
                        }
                    }
                }
            }
            boolean end = act == MotionEvent.ACTION_UP || act == MotionEvent.ACTION_CANCEL;
            if (end || (act == MotionEvent.ACTION_POINTER_UP && n < 2)) {
                if (sRotating) {
                    sRotating = false;
                    guide(v, false);
                }
                if (Math.abs(deg) < SNAP_DEG && deg != 0f) {
                    deg = 0f; // saved exactly level
                }
                if (end && s < 1f && s > 0.97f) {
                    s = 1f;
                    tx = 0f;
                    ty = 0f;
                    changed = true;
                }
                if (end) {
                    showSwitchLater(v);
                    Log.i(TAG, String.format(java.util.Locale.US, "home picture: scale %.3f, %.1f deg, offset %.0f,%.0f", s, shownDeg(), tx, ty));
                }
            }
            if (changed) {
                redraw(v);
            }
            if (sGuide != null) {
                sGuide.invalidateSelf();
            }
            if (identity()) {
                return e;
            }
            Matrix inv = new Matrix();
            matrix(v).invert(inv);
            MotionEvent c = MotionEvent.obtain(e);
            c.transform(inv);
            if (sCopy != null) {
                sCopy.recycle();
            }
            sCopy = c;
            return c;
        } catch (Throwable t) {
            Log.e(TAG, "touch", t);
            return e;
        }
    }

    private static Field sEdge;
    private static Boolean sKeepStretch;

    /**
     * No overscroll stretch in the Home editor. CropImageView pulls its EdgeEffects (field R, v9.i; null-checked
     * everywhere) when the picture cannot follow the fingers (at an edge, at the minimum zoom, or zoomed out with the
     * offset at its limit); the stretch distorts the CropImageView's own RenderNode only, so the picture moved while the
     * cut-out subject drawn over it (HomeClock.SubjectView, another view) stayed: a second, offset copy of the subject
     * during the gesture.
     */
    static void noStretch(View v) {
        try {
            if (sKeepStretch == null) {
                sKeepStretch = HomeClock.debug().contains("stretch"); // debug: the old behaviour, for comparison
            }
            if (sKeepStretch) {
                return;
            }
            if (sEdge == null) {
                for (Class<?> k = v.getClass(); k != null && sEdge == null; k = k.getSuperclass()) {
                    try {
                        sEdge = k.getDeclaredField("R");
                    } catch (NoSuchFieldException ignored) {
                    }
                }
                if (sEdge == null) {
                    return;
                }
                sEdge.setAccessible(true);
            }
            if (sEdge.get(v) != null) {
                sEdge.set(v, null);
                Log.i(TAG, "overscroll stretch off in the Home editor");
            }
        } catch (Throwable t) {
            Log.w(TAG, "overscroll", t);
        }
    }

    /** The zoomed-out picture's middle stays on the screen. */
    static void clampT(View v) {
        float mx = v.getWidth() / 2f, my = v.getHeight() / 2f;
        tx = Math.max(-mx, Math.min(mx, tx));
        ty = Math.max(-my, Math.min(my, ty));
    }

    static void redraw(View v) {
        v.invalidate();
        View sv = HomeClock.sSubjectView.get();
        if (sv != null) {
            sv.invalidate();
        }
    }

    static Method sSemIndex;
    static int sTick = -1;

    /**
     * The level tick. Samsung's alignment snap (lock editor: performHapticFeedback(semGetVibrationIndex(1))) needs a
     * haptic engine; on a DC coin motor (Galaxy A52s: no prebaked effects, VibratorInfo supportedEffects = []) the
     * framework maps every haptic constant except LONG_PRESS to nothing (HapticFeedbackVibrationProvider:
     * SUPPORT_HAPTIC_FEEDBACK_ON_DC_MOTOR), so the snap would be silent there. Without the tick effect the one feedback
     * such a motor plays is used: LONG_PRESS (the short touch pulse One UI gives every tap on these phones, at the
     * user's touch intensity, off when touch feedback is off).
     */
    static int tickConstant(View v) {
        if (sTick != -1) {
            return sTick;
        }
        int idx = HapticFeedbackConstants.CLOCK_TICK;
        try {
            if (sSemIndex == null) {
                sSemIndex = HapticFeedbackConstants.class.getMethod("semGetVibrationIndex", int.class);
            }
            idx = (Integer) sSemIndex.invoke(null, 1);
        } catch (Throwable t) {
            Log.w(TAG, "level: no semGetVibrationIndex", t);
        }
        try {
            android.os.Vibrator vib = v.getContext().getSystemService(android.os.Vibrator.class);
            if (vib != null && vib.areAllEffectsSupported(android.os.VibrationEffect.EFFECT_TICK)
                    != android.os.Vibrator.VIBRATION_EFFECT_SUPPORT_YES) {
                idx = HapticFeedbackConstants.LONG_PRESS;
            }
        } catch (Throwable t) {
            Log.w(TAG, "level: vibrator info", t);
        }
        sTick = idx;
        return idx;
    }

    static void haptic(View v) {
        int idx = tickConstant(v);
        boolean ok = v.performHapticFeedback(idx);
        Log.i(TAG, "level: haptic constant " + idx + " -> " + ok);
    }

    // ---- pinch ----

    static Object call(Object o, String name) throws Exception {
        Method m = o.getClass().getMethod(name);
        return m.invoke(o);
    }

    /** Samsung's picture is at its minimum zoom (CropImageView.B clamps the width at originScaled.width * x). */
    static boolean atMin(View v) {
        try {
            RectF b = (RectF) call(v, "getDrawableBounds");
            RectF o = (RectF) call(v, "getDrawableOriginScaledBounds");
            float x = (Float) HomeClock.field(v, "x");
            return b != null && o != null && b.width() <= o.width() * x + 2f;
        } catch (Throwable t) {
            return false;
        }
    }

    /** CropImageView.N(scaleFactor) start: the factor Samsung's zoom gets. */
    public static float scale(View v, float f) {
        if (!mine(v) || f == 1f || Float.isNaN(f)) {
            return f;
        }
        try {
            // with T active, the fingers' own spread (see rawFactor); stock (T = identity) keeps Samsung's factor
            float raw = rawFactor();
            if (!identity() && !Float.isNaN(raw)) {
                f = raw;
                if (f == 1f) {
                    return 1f;
                }
            }
            if (f < 1f) {
                if (s < 1f || atMin(v)) {
                    s = Math.max(MIN_S, s * f);
                    redraw(v);
                    return 1f;
                }
            } else if (s < 1f) {
                float ns = Math.min(1f, s * f);
                float r = ns >= 1f ? 0f : (1f - ns) / (1f - s); // the offset shrinks away as the picture grows back
                tx *= r;
                ty *= r;
                s = ns;
                redraw(v);
                return 1f;
            }
        } catch (Throwable t) {
            Log.e(TAG, "scale", t);
        }
        return f;
    }

    // ---- drawing ----

    /** CropImageView.onDraw start: true when the picture was drawn here (zoomed out or rotated). */
    public static boolean draw(View v, Canvas c) {
        if (!mine(v) || identity()) {
            return false;
        }
        try {
            paint(v, c, false, true);
            return true;
        } catch (Throwable t) {
            Log.e(TAG, "draw", t);
            return false;
        }
    }

    static Drawable outer(View v) {
        try {
            return (Drawable) call(v, "getDrawableInner");
        } catch (Throwable t) {
            return ((ImageView) v).getDrawable();
        }
    }

    /** Drawable bounds -> view coordinates (what ImageView.onDraw applies). */
    static Matrix imageMatrix(ImageView iv) {
        Matrix m = new Matrix(iv.getImageMatrix());
        m.postTranslate(iv.getPaddingLeft(), iv.getPaddingTop());
        return m;
    }

    static Bitmap bitmapOf(Drawable d) {
        return d instanceof BitmapDrawable ? ((BitmapDrawable) d).getBitmap() : null;
    }

    // ---- fill for the area the zoomed-out / tilted picture no longer covers ----

    static final int FILL_COLOR = 0, FILL_BLUR = 1;
    static volatile int sFill = FILL_COLOR;
    private static Bitmap sColorFor, sColorMask, sBlurFor, sBlur;
    private static int sColor = Color.BLACK;

    static Bitmap software(Bitmap b) {
        return b != null && b.getConfig() == Bitmap.Config.HARDWARE ? b.copy(Bitmap.Config.ARGB_8888, false) : b;
    }

    static Bitmap subjectMask() {
        HomeClock.SubjectView sv = HomeClock.sSubjectView.get();
        return sv != null && sv.subject != null ? sv.subject.getBitmap() : null;
    }

    /**
     * The picture's dominant border colour: the most common colour (12-bit bins, then the mean of that bin) of a ring
     * along the picture's edges, transparent pixels taken as they show (over black), pixels of the cut-out subject
     * skipped. Cached per picture and subject mask.
     */
    static synchronized int borderColor(Bitmap pic) {
        Bitmap mask = subjectMask();
        if (pic == null) {
            return Color.BLACK;
        }
        if (pic == sColorFor && mask == sColorMask) {
            return sColor;
        }
        try {
            Bitmap b = software(pic);
            Bitmap m = software(mask);
            int w = b.getWidth(), h = b.getHeight();
            int ring = Math.max(2, Math.round(Math.min(w, h) * 0.03f));
            int[] count = new int[4096];
            long[] sr = new long[4096], sg = new long[4096], sb = new long[4096];
            int[] row = new int[w], mrow = m != null ? new int[m.getWidth()] : null;
            for (int y = 0; y < h; y++) {
                boolean full = y < ring || y >= h - ring;
                b.getPixels(row, 0, w, 0, y, w, 1);
                int my = m != null ? Math.min(m.getHeight() - 1, y * m.getHeight() / h) : 0;
                if (m != null) {
                    m.getPixels(mrow, 0, m.getWidth(), 0, my, m.getWidth(), 1);
                }
                for (int x = 0; x < w; x++) {
                    if (!full && x >= ring && x < w - ring) {
                        x = w - ring - 1;
                        continue;
                    }
                    if (m != null && Color.alpha(mrow[Math.min(m.getWidth() - 1, x * m.getWidth() / w)]) > 0) {
                        continue;
                    }
                    int p = row[x], al = Color.alpha(p);
                    int r = Color.red(p) * al / 255, g = Color.green(p) * al / 255, bl = Color.blue(p) * al / 255;
                    int k = (r >> 4) << 8 | (g >> 4) << 4 | (bl >> 4);
                    count[k]++;
                    sr[k] += r;
                    sg[k] += g;
                    sb[k] += bl;
                }
            }
            int best = 0;
            for (int k = 1; k < 4096; k++) {
                if (count[k] > count[best]) {
                    best = k;
                }
            }
            int n = Math.max(1, count[best]);
            sColor = count[best] == 0 ? Color.BLACK : Color.rgb((int) (sr[best] / n), (int) (sg[best] / n), (int) (sb[best] / n));
            sColorFor = pic;
            sColorMask = mask;
            Log.i(TAG, String.format("fill colour #%06x (%d of the border ring's pixels%s)", sColor & 0xffffff, count[best],
                    m != null ? ", subject skipped" : ""));
        } catch (Throwable t) {
            Log.w(TAG, "border colour", t);
            sColor = Color.BLACK;
        }
        return sColor;
    }

    /** The picture (as shown, over black) small and heavily blurred: drawn scaled up to cover the screen. */
    static synchronized Bitmap blurred(Bitmap pic) {
        if (pic == null) {
            return null;
        }
        if (pic == sBlurFor && sBlur != null) {
            return sBlur;
        }
        try {
            Bitmap b = software(pic);
            int w = 72, h = Math.max(1, Math.round(72f * b.getHeight() / b.getWidth()));
            Bitmap small = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
            Canvas c = new Canvas(small);
            c.drawColor(Color.BLACK);
            Paint p = new Paint(Paint.FILTER_BITMAP_FLAG);
            c.drawBitmap(b, null, new Rect(0, 0, w, h), p);
            int[] px = new int[w * h];
            small.getPixels(px, 0, w, 0, 0, w, h);
            for (int pass = 0; pass < 3; pass++) {
                boxBlur(px, w, h, 4);
            }
            small.setPixels(px, 0, w, 0, 0, w, h);
            sBlur = small;
            sBlurFor = pic;
        } catch (Throwable t) {
            Log.w(TAG, "blur", t);
            sBlur = null;
        }
        return sBlur;
    }

    /** One horizontal + one vertical box blur pass (radius r, edges clamped). */
    static void boxBlur(int[] px, int w, int h, int r) {
        int[] tmp = new int[px.length];
        for (int pass = 0; pass < 2; pass++) {
            boolean horiz = pass == 0;
            int len = horiz ? w : h, lines = horiz ? h : w;
            int[] src = horiz ? px : tmp, dst = horiz ? tmp : px;
            for (int l = 0; l < lines; l++) {
                for (int i = 0; i < len; i++) {
                    int rs = 0, gs = 0, bs = 0, n = 0;
                    for (int k = -r; k <= r; k++) {
                        int j = Math.max(0, Math.min(len - 1, i + k));
                        int p = src[horiz ? l * w + j : j * w + l];
                        rs += (p >> 16) & 0xff;
                        gs += (p >> 8) & 0xff;
                        bs += p & 0xff;
                        n++;
                    }
                    dst[horiz ? l * w + i : i * w + l] = 0xff000000 | (rs / n) << 16 | (gs / n) << 8 | (bs / n);
                }
            }
        }
    }

    /** The fill under the picture: the border colour, or the blurred picture covering the view, dimmed. */
    static void fill(View v, Canvas c, Bitmap pic) {
        c.drawColor(Color.BLACK);
        if (sFill == FILL_BLUR) {
            Bitmap bl = blurred(pic);
            if (bl != null) {
                float vw = v.getWidth(), vh = v.getHeight();
                float sc = Math.max(vw / bl.getWidth(), vh / bl.getHeight());
                float dw = bl.getWidth() * sc, dh = bl.getHeight() * sc;
                RectF dst = new RectF((vw - dw) / 2f, (vh - dh) / 2f, (vw + dw) / 2f, (vh + dh) / 2f);
                c.drawBitmap(bl, null, dst, new Paint(Paint.FILTER_BITMAP_FLAG));
                c.drawColor(0x66000000); // dimmed, so the sharp picture stands out
                return;
            }
        }
        c.drawColor(borderColor(pic));
    }

    /**
     * The picture through T over the fill ({@link #fill}), then (editor only) Samsung's other layers.
     * own: draw copies (save path, off the UI thread) instead of the view's own drawables.
     */
    static void paint(View v, Canvas c, boolean own, boolean layers) {
        ImageView iv = (ImageView) v;
        Drawable outer = outer(v);
        Drawable base = iv.getDrawable(); // CropImageView.getDrawable(): the picture inside the ExpandableDrawable
        if (base == outer && outer instanceof LayerDrawable && ((LayerDrawable) outer).getNumberOfLayers() > 0) {
            base = ((LayerDrawable) outer).getDrawable(0);
        }
        if (outer == null || base == null) {
            return;
        }
        Rect b = new Rect(outer.getBounds());
        Matrix img = imageMatrix(iv);
        Matrix t = matrix(v);
        Bitmap pic = bitmapOf(base);
        fill(v, c, pic);

        Drawable pd = base;
        if (own) {
            Bitmap sw = pic != null && pic.getConfig() == Bitmap.Config.HARDWARE ? pic.copy(Bitmap.Config.ARGB_8888, false) : pic;
            pd = sw != null ? new BitmapDrawable(v.getResources(), sw) : null;
        }
        int save = c.save();
        c.concat(t);
        c.concat(img);
        ColorFilter cf = iv.getColorFilter();
        if (cf != null) {
            Paint p = new Paint();
            p.setColorFilter(cf);
            RectF lb = new RectF(b);
            c.saveLayer(lb, p);
        }
        if (pd != null) {
            if (pd instanceof BitmapDrawable) {
                ((BitmapDrawable) pd).setFilterBitmap(true);
            }
            pd.setBounds(b);
            pd.draw(c);
        }
        if (layers && !own && outer instanceof LayerDrawable) {
            LayerDrawable ld = (LayerDrawable) outer;
            for (int i = 1; i < ld.getNumberOfLayers(); i++) {
                Drawable l = ld.getDrawable(i);
                if (l != null && l.getAlpha() > 0) {
                    l.draw(c);
                }
            }
        }
        c.restoreToCount(save);
    }

    // ---- save (SaveImageMaker, d7.z) ----

    private static WeakReference<Object> sBaked = new WeakReference<>(null);
    private static Bitmap sBakedBg;
    private static final ThreadLocal<Boolean> sObjBaked = new ThreadLocal<>();

    static void set(Object o, String name, Object value) throws Exception {
        Field f = null;
        for (Class<?> k = o.getClass(); k != null && f == null; k = k.getSuperclass()) {
            try {
                f = k.getDeclaredField(name);
            } catch (NoSuchFieldException ignored) {
            }
        }
        if (f == null) {
            throw new NoSuchFieldException(name);
        }
        f.setAccessible(true);
        f.set(o, value);
    }

    static Size screen(Object maker) throws Exception {
        return (Size) HomeClock.field(maker, "f");
    }

    /**
     * SaveImageMaker.f(portRect, landRect, squareRect, mime) start (makeBackgroundImage): with a zoomed-out or rotated
     * Home picture, the background becomes the editor's picture rendered at screen size, and the crop rects cover it.
     */
    public static void bakeBackground(Object maker, RectF port, RectF land, RectF square) {
        sBaked = new WeakReference<>(null);
        if (!HomeClock.active || identity() || maker == null || port == null || land == null || square == null) {
            return;
        }
        try {
            View v = sView.get();
            if (v == null || v.getWidth() == 0 || v.getHeight() == 0) {
                Log.w(TAG, "home save: no editor view, picture saved without zoom-out/rotation");
                return;
            }
            Size size = screen(maker);
            int w = size.getWidth(), h = size.getHeight();
            Bitmap bg = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
            Canvas c = new Canvas(bg);
            c.scale(w / (float) v.getWidth(), h / (float) v.getHeight());
            paint(v, c, true, false);
            set(maker, "h", bg);
            set(maker, "o", 0f);
            set(maker, "p", 0f);
            port.set(0f, 0f, w, h);
            float lh = w * (float) w / h; // landscape crop (h x w screen) out of the portrait picture
            land.set(0f, (h - lh) / 2f, w, (h + lh) / 2f);
            square.set(0f, (h - w) / 2f, w, (h + w) / 2f);
            sBakedBg = bg;
            sBaked = new WeakReference<>(maker);
            Log.i(TAG, String.format(java.util.Locale.US, "home save: background rendered %dx%d (scale %.3f, %.1f deg, offset %.0f,%.0f)",
                    w, h, s, shownDeg(), tx, ty));
        } catch (Throwable t) {
            Log.e(TAG, "bakeBackground", t);
        }
    }

    /**
     * SaveImageMaker.h(objectBitmap, objectBounds, scale, tag) start (makeObjectImageAndBounds): the subject Samsung's
     * segmentation found (the cut-out the editor shows above the clock) through the same transform, at screen size.
     */
    public static Bitmap bakeObject(Object maker, Bitmap obj, Rect bounds, float scale) {
        sObjBaked.set(Boolean.FALSE);
        if (maker == null || sBaked.get() != maker || bounds == null) {
            return obj;
        }
        try {
            View v = sView.get();
            HomeClock.SubjectView sv = HomeClock.sSubjectView.get();
            if (v == null || sv == null || sv.subject == null || sv.crop != v) {
                Log.w(TAG, "home save: no subject for the rendered picture");
                return obj;
            }
            Size size = screen(maker);
            int w = size.getWidth(), h = size.getHeight();
            ImageView iv = (ImageView) v;
            Drawable outer = outer(v);
            Bitmap sb = sv.subject.getBitmap();
            if (outer == null || sb == null) {
                return obj;
            }
            if (sb.getConfig() == Bitmap.Config.HARDWARE) {
                sb = sb.copy(Bitmap.Config.ARGB_8888, false);
            }
            Bitmap out = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
            Canvas c = new Canvas(out);
            c.scale(w / (float) v.getWidth(), h / (float) v.getHeight());
            c.concat(matrix(v));
            c.concat(imageMatrix(iv));
            BitmapDrawable d = new BitmapDrawable(v.getResources(), sb);
            d.setFilterBitmap(true);
            d.setBounds(outer.getBounds());
            d.draw(c);
            bounds.set(0, 0, w, h);
            sObjBaked.set(Boolean.TRUE);
            Log.i(TAG, "home save: subject rendered " + w + "x" + h);
            return out;
        } catch (Throwable t) {
            Log.e(TAG, "bakeObject", t);
            return obj;
        }
    }

    /** SaveImageMaker.h: the subject rendered above is at full scale. */
    public static float objectScale(float scale) {
        return Boolean.TRUE.equals(sObjBaked.get()) ? 1f : scale;
    }

    /** SaveImageMaker.o(bitmap) start (thumbnail.jpg): the rendered picture. */
    public static Bitmap thumbnail(Object maker, Bitmap b) {
        Bitmap bg = sBakedBg;
        return maker != null && sBaked.get() == maker && bg != null ? bg : b;
    }

    /** SaveImageMaker.i(ordering, expandInfo) start (setWallpaper.xml): the rendered picture needs no expand offset. */
    public static void beforeXml(Object maker, ArrayList ordering, Object expand) {
        if (maker == null || sBaked.get() != maker || expand == null) {
            return;
        }
        try {
            Object list = HomeClock.field(expand, "a");
            if (list instanceof ArrayList) {
                for (Object r : (ArrayList) list) {
                    if (r instanceof RectF) {
                        ((RectF) r).setEmpty();
                    }
                }
                Log.i(TAG, "home save: expand offsets cleared");
            }
        } catch (Throwable t) {
            Log.e(TAG, "beforeXml", t);
        }
    }

    // ---- fill switch (Color | Blur), shown while the picture is zoomed out or tilted ----

    private static WeakReference<View> sSwitch = new WeakReference<>(null);
    private static WeakReference<View> sSlot = new WeakReference<>(null);
    private static WeakReference<android.widget.TextView> sColorLabel = new WeakReference<>(null), sBlurLabel = new WeakReference<>(null);

    static void showSwitchLater(final View crop) {
        crop.post(new Runnable() {
            @Override
            public void run() {
                showSwitch(crop, mine(crop) && !identity());
            }
        });
    }

    static void showSwitch(View crop, boolean show) {
        try {
            View sw = sSwitch.get();
            if (sw == null || !sw.isAttachedToWindow()) {
                if (!show) {
                    return;
                }
                sw = makeSwitch(crop);
                if (sw == null) {
                    return;
                }
                sSwitch = new WeakReference<>(sw);
            }
            final View w = sw;
            final View slot = sSlot.get();
            // Samsung hides the slot (preview_switch_title_layout) itself, e.g. while its clock panel is open
            boolean shown = w.getVisibility() == View.VISIBLE && w.getAlpha() > 0f
                    && (slot == null || slot.getVisibility() == View.VISIBLE);
            if (show == shown) {
                return;
            }
            w.animate().cancel();
            if (show) {
                if (slot != null) {
                    slot.setVisibility(View.VISIBLE);
                }
                w.setAlpha(0f);
                w.setVisibility(View.VISIBLE);
                w.animate().alpha(1f).setDuration(400).start();
            } else {
                w.animate().alpha(0f).setDuration(150).withEndAction(new Runnable() {
                    @Override
                    public void run() {
                        w.setVisibility(View.GONE);
                        if (slot != null) {
                            slot.setVisibility(View.GONE);
                        }
                    }
                }).start();
            }
        } catch (Throwable t) {
            Log.e(TAG, "fill switch", t);
        }
    }

    /** Every frame of the Home editor (HomeClock's pre-draw): the switch is back once Samsung re-hid its slot. */
    static void keepSwitch() {
        View crop = sView.get();
        View sw = sSwitch.get();
        View slot = sSlot.get();
        if (crop != null && sw != null && slot != null && mine(crop) && !identity() && sw.isAttachedToWindow()
                && slot.getVisibility() != View.VISIBLE) {
            showSwitch(crop, true);
        }
    }

    static void select(int mode, View crop) {
        sFill = mode;
        android.widget.TextView c = sColorLabel.get(), b = sBlurLabel.get();
        if (c != null && b != null) {
            c.setAlpha(mode == FILL_COLOR ? 1f : 0.45f);
            b.setAlpha(mode == FILL_BLUR ? 1f : 0.45f);
            c.setSelected(mode == FILL_COLOR);
            b.setSelected(mode == FILL_BLUR);
        }
        Log.i(TAG, "fill: " + (mode == FILL_BLUR ? "blur" : "colour"));
        redraw(crop);
    }

    static android.widget.TextView label(Context ctx, int text, String fallback, final int mode, final View crop) {
        android.widget.TextView t = new android.widget.TextView(ctx);
        t.setText(text != 0 ? ctx.getString(text) : fallback);
        int col = HomeClock.id(ctx, "drawable", "preview_selector_text_set");
        try {
            t.setTextColor(ctx.getColorStateList(col));
        } catch (Throwable e) {
            t.setTextColor(0xfffafafa);
        }
        int sz = HomeClock.id(ctx, "dimen", "edit_switch_preview_title_text_size");
        t.setTextSize(android.util.TypedValue.COMPLEX_UNIT_PX, sz != 0 ? ctx.getResources().getDimension(sz) : 12 * ctx.getResources().getDisplayMetrics().density);
        t.setTypeface(android.graphics.Typeface.create(android.graphics.Typeface.create("sec", android.graphics.Typeface.NORMAL), 600, false));
        t.setMaxLines(1);
        t.setGravity(android.view.Gravity.CENTER);
        float dp = ctx.getResources().getDisplayMetrics().density;
        t.setPadding(Math.round(10 * dp), 0, Math.round(10 * dp), 0);
        t.setMinHeight(Math.round(34 * dp));
        t.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View x) {
                select(mode, crop);
            }
        });
        return t;
    }

    /**
     * Samsung's preview switch pill (the Lock/Home switch at the bottom of the preview in the Lock + Home editor:
     * set_wallpaper_btn_bg, preview_selector_text_set text, "sec" 600, edit_switch_preview_* sizes), placed where that
     * switch sits (inside preview_switch_title_layout, which a Home-only editor never shows), with the
     * two fills: Color (tab_color) and Blur (style_item_blur).
     */
    static View makeSwitch(View crop) {
        Context ctx = crop.getContext();
        View root = crop.getRootView();
        int anchorId = HomeClock.id(ctx, "id", "preview_switch_title_layout");
        View anchor = anchorId != 0 ? root.findViewById(anchorId) : null;
        if (anchor == null || !(anchor.getParent() instanceof android.view.ViewGroup)) {
            Log.w(TAG, "fill switch: no preview_switch_title_layout");
            return null;
        }
        android.widget.LinearLayout pill = new android.widget.LinearLayout(ctx);
        pill.setOrientation(android.widget.LinearLayout.HORIZONTAL);
        pill.setGravity(android.view.Gravity.CENTER);
        int bg = HomeClock.id(ctx, "drawable", "set_wallpaper_btn_bg");
        if (bg != 0) {
            pill.setBackground(ctx.getDrawable(bg));
        }
        float dp = ctx.getResources().getDisplayMetrics().density;
        pill.setPadding(Math.round(4 * dp), Math.round(2 * dp), Math.round(4 * dp), Math.round(2 * dp));
        android.widget.TextView c = label(ctx, HomeClock.id(ctx, "string", "tab_color"), "Color", FILL_COLOR, crop);
        android.widget.TextView b = label(ctx, HomeClock.id(ctx, "string", "style_item_blur"), "Blur", FILL_BLUR, crop);
        pill.addView(c);
        pill.addView(b);
        sColorLabel = new WeakReference<>(c);
        sBlurLabel = new WeakReference<>(b);
        // inside Samsung's own switch slot (a FrameLayout constrained to the bottom middle of the preview, gone in a
        // Home-only editor): shown with our pill instead of Samsung's Lock/Home switcher
        android.view.ViewGroup slot = anchor instanceof android.view.ViewGroup ? (android.view.ViewGroup) anchor : null;
        if (slot == null) {
            Log.w(TAG, "fill switch: preview_switch_title_layout is not a ViewGroup");
            return null;
        }
        for (int i = 0; i < slot.getChildCount(); i++) {
            slot.getChildAt(i).setVisibility(View.GONE);
        }
        slot.addView(pill, new android.widget.FrameLayout.LayoutParams(android.view.ViewGroup.LayoutParams.WRAP_CONTENT,
                android.view.ViewGroup.LayoutParams.MATCH_PARENT, android.view.Gravity.CENTER));
        sSlot = new WeakReference<View>(slot);
        pill.setVisibility(View.GONE);
        select(sFill, crop);
        Log.i(TAG, "fill switch added");
        return pill;
    }

    // ---- level guide + angle badge ----

    static void guide(View v, boolean show) {
        try {
            View root = v.getRootView();
            if (root == null) {
                return;
            }
            if (sGuide == null || sGuide.root.get() != root) {
                sGuide = new Guide(v, root);
                root.getOverlay().add(sGuide);
            }
            sGuide.crop = new WeakReference<>(v);
            sGuide.setBounds(0, 0, root.getWidth(), root.getHeight());
            sGuide.fade(show);
        } catch (Throwable t) {
            Log.e(TAG, "guide", t);
        }
    }

    /**
     * Horizontal and vertical lines through the screen's middle (fixed while the picture turns), drawn with the lock editor's align assist line
     * (drawable align_assist_line, colour guide_box_white, align_assist_line_width; guide_box_border_stroke_width and full
     * opacity when level), and the angle in a small badge. Fades in 400 ms / out 150 ms like Samsung's assist line.
     */
    static final class Guide extends Drawable {
        final WeakReference<View> root;
        WeakReference<View> crop;
        float alpha;
        ValueAnimator anim;
        final Drawable line;
        final int color;
        final float thin, thick, dp;
        final Paint text = new Paint(Paint.ANTI_ALIAS_FLAG);
        final Paint pill = new Paint(Paint.ANTI_ALIAS_FLAG);

        Guide(View v, View root) {
            this.root = new WeakReference<>(root);
            this.crop = new WeakReference<>(v);
            Context c = v.getContext();
            dp = c.getResources().getDisplayMetrics().density;
            int lineId = HomeClock.id(c, "drawable", "align_assist_line");
            Drawable l = null;
            try {
                l = lineId != 0 ? c.getDrawable(lineId).mutate() : null;
            } catch (Throwable ignored) {
            }
            line = l;
            int colId = HomeClock.id(c, "color", "guide_box_white");
            color = colId != 0 ? c.getColor(colId) : 0xfffafafa;
            int w1 = HomeClock.id(c, "dimen", "align_assist_line_width");
            int w2 = HomeClock.id(c, "dimen", "guide_box_border_stroke_width");
            thin = w1 != 0 ? c.getResources().getDimension(w1) : dp;
            thick = w2 != 0 ? c.getResources().getDimension(w2) : 2 * dp;
            text.setColor(Color.WHITE);
            text.setTextSize(14 * c.getResources().getDisplayMetrics().scaledDensity);
            text.setTextAlign(Paint.Align.CENTER);
            text.setTypeface(android.graphics.Typeface.create("sec", android.graphics.Typeface.BOLD));
            pill.setColor(0x99000000);
        }

        void fade(boolean show) {
            if (anim != null) {
                anim.cancel();
            }
            anim = ValueAnimator.ofFloat(alpha, show ? 1f : 0f);
            anim.setDuration(show ? 400 : 150);
            anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator a) {
                    alpha = (Float) a.getAnimatedValue();
                    invalidateSelf();
                }
            });
            anim.start();
        }

        void bar(Canvas c, float l, float t, float r, float b, int a) {
            if (line != null) {
                line.setTint(color);
                line.setAlpha(a);
                line.setBounds(Math.round(l), Math.round(t), Math.round(r), Math.round(b));
                line.draw(c);
            } else {
                Paint p = new Paint();
                p.setColor(color);
                p.setAlpha(a);
                c.drawRect(l, t, r, b, p);
            }
        }

        @Override
        public void draw(Canvas c) {
            View v = crop.get();
            if (alpha <= 0f || v == null || !v.isAttachedToWindow()) {
                return;
            }
            int[] loc = new int[2];
            v.getLocationInWindow(loc);
            float sc = HomeClock.scale(v);
            float left = loc[0], top = loc[1], right = left + v.getWidth() * sc, bottom = top + v.getHeight() * sc;
            // fixed to the screen (the preview's middle), not to the picture: level is judged against the screen the
            // way Samsung's align assist lines and the photo editor's straighten grid stay put while the picture turns
            float cx = left + v.getWidth() / 2f * sc, cy = top + v.getHeight() / 2f * sc;
            float d = shownDeg();
            boolean level = d == 0f;
            int a = Math.round(alpha * (level ? 255 : 110));
            float w = level ? thick : thin;
            int save = c.save();
            c.clipRect(left, top, right, bottom);
            bar(c, left, cy - w / 2f, right, cy + w / 2f, a);
            bar(c, cx - w / 2f, top, cx + w / 2f, bottom, a);
            String label = Math.round(d) + "°";
            float tw = text.measureText(label);
            Paint.FontMetrics fm = text.getFontMetrics();
            float ph = (fm.descent - fm.ascent) + 12 * dp, pw = Math.max(tw + 24 * dp, ph * 1.6f);
            float py = cy - 24 * dp - ph;
            pill.setAlpha(Math.round(alpha * 0x99));
            c.drawRoundRect(cx - pw / 2f, py, cx + pw / 2f, py + ph, ph / 2f, ph / 2f, pill);
            text.setAlpha(Math.round(alpha * 255));
            c.drawText(label, cx, py + ph / 2f - (fm.ascent + fm.descent) / 2f, text);
            c.restoreToCount(save);
        }

        @Override
        public void setAlpha(int a) {
        }

        @Override
        public void setColorFilter(ColorFilter cf) {
        }

        @Override
        public int getOpacity() {
            return PixelFormat.TRANSLUCENT;
        }
    }
}
