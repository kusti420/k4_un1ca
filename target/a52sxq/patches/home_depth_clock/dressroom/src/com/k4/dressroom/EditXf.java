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
 * <li>MaskImageView.onDraw, in place of its ImageView.onDraw call ({@link #draw}; inside Samsung's mask clip): with T != identity the picture is drawn through T over a fill made by
 * Samsung's own ExpandableDrawable (fj.j, the edge-colour extension the editor already shows when the picture is dragged
 * off an edge, and the "expand" colours of a saved layered wallpaper).</li>
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
    static final String EXPANDABLE = "fj.j"; // com.samsung.android.sesl.extendImage.ExpandableDrawable

    private static WeakReference<View> sView = new WeakReference<>(null);
    static volatile float s = 1f, deg = 0f, tx = 0f, ty = 0f;
    private static boolean sRotating;
    private static int sCount;
    private static float sRotStart, sRotBase, sFx, sFy;
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
            if (n != sCount || act != MotionEvent.ACTION_MOVE) {
                // pointer set changed: re-base the focus and the angle, nothing moves
                sFx = fx;
                sFy = fy;
                sCount = n;
                if (n >= 2) {
                    sRotStart = angle(e, skip);
                    sRotBase = deg;
                }
            } else {
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

    /** Samsung's alignment snap haptic (lock editor: view.performHapticFeedback(semGetVibrationIndex(1))). */
    static void haptic(View v) {
        try {
            if (sSemIndex == null) {
                sSemIndex = HapticFeedbackConstants.class.getMethod("semGetVibrationIndex", int.class);
            }
            int idx = (Integer) sSemIndex.invoke(null, 1);
            boolean ok = v.performHapticFeedback(idx);
            Log.i(TAG, "level: haptic semGetVibrationIndex(1)=" + idx + " -> " + ok);
        } catch (Throwable t) {
            Log.w(TAG, "level: haptic", t);
            v.performHapticFeedback(HapticFeedbackConstants.CLOCK_TICK);
        }
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

    static boolean isExpandable(Drawable d) {
        return d != null && EXPANDABLE.equals(d.getClass().getName());
    }

    /** Drawable bounds -> view coordinates (what ImageView.onDraw applies). */
    static Matrix imageMatrix(ImageView iv) {
        Matrix m = new Matrix(iv.getImageMatrix());
        m.postTranslate(iv.getPaddingLeft(), iv.getPaddingTop());
        return m;
    }

    private static Bitmap sFillFor;
    private static Drawable sFill;

    /** Our own ExpandableDrawable over a copy of the picture (used for the saved picture, off the UI thread). */
    static synchronized Drawable ownFill(Context ctx, Bitmap b) {
        if (b == null) {
            return null;
        }
        if (sFillFor == b && sFill != null) {
            return sFill;
        }
        try {
            Bitmap sw = b.getConfig() == Bitmap.Config.HARDWARE ? b.copy(Bitmap.Config.ARGB_8888, false) : b;
            BitmapDrawable bd = new BitmapDrawable(ctx.getResources(), sw);
            bd.setBounds(0, 0, sw.getWidth(), sw.getHeight());
            Class<?> j = Class.forName(EXPANDABLE, true, EditXf.class.getClassLoader());
            sFill = (Drawable) j.getConstructor(Drawable.class).newInstance(bd);
            sFillFor = b;
        } catch (Throwable t) {
            Log.w(TAG, "expand fill", t);
            sFill = null;
        }
        return sFill;
    }

    static Bitmap bitmapOf(Drawable d) {
        return d instanceof BitmapDrawable ? ((BitmapDrawable) d).getBitmap() : null;
    }

    /**
     * The picture through T: first the fill (Samsung's edge-colour extension of the picture, all around the picture as it
     * would sit without rotation; with a rotation it is drawn from a smaller rect that the rotated picture covers, so
     * only the extension shows in its corners), then the picture itself, then (editor only) Samsung's other layers.
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
        float d = shownDeg();

        // picture rect in view coordinates, zoomed out / moved but not rotated
        RectF u = new RectF(b);
        img.mapRect(u);
        Matrix noRot = new Matrix();
        float cx = v.getWidth() / 2f, cy = v.getHeight() / 2f;
        noRot.setTranslate(-cx, -cy);
        noRot.postScale(s, s);
        noRot.postTranslate(cx + tx, cy + ty);
        noRot.mapRect(u);
        if (d != 0f) {
            double r = Math.toRadians(Math.abs(d));
            float co = (float) Math.cos(r), si = (float) Math.sin(r), w = u.width(), h = u.height();
            float k = Math.min(w / (w * co + h * si), h / (w * si + h * co));
            float dx = w * (1f - k) / 2f, dy = h * (1f - k) / 2f;
            u.inset(dx, dy);
        }
        Rect ur = new Rect();
        u.round(ur);

        Bitmap pic = bitmapOf(base);
        Drawable fill = null;
        if (!own) {
            if (isExpandable(outer)) {
                fill = outer;
            } else if (outer instanceof LayerDrawable && ((LayerDrawable) outer).getNumberOfLayers() > 0
                    && isExpandable(((LayerDrawable) outer).getDrawable(0))) {
                fill = ((LayerDrawable) outer).getDrawable(0);
            }
        }
        if (fill == null) {
            fill = ownFill(v.getContext(), pic);
        }
        c.drawColor(Color.BLACK);
        if (fill != null) {
            Rect old = new Rect(fill.getBounds());
            int save = c.save();
            fill.setBounds(ur);
            fill.draw(c);
            c.restoreToCount(save);
            fill.setBounds(old);
        }

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
     * Horizontal and vertical lines through the picture's middle, drawn with the lock editor's align assist line
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
            float cx = left + (v.getWidth() / 2f + tx) * sc, cy = top + (v.getHeight() / 2f + ty) * sc;
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
