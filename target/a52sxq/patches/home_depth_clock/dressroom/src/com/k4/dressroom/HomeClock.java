package com.k4.dressroom;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.graphics.RectF;
import android.os.SemSystemProperties;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.util.HashSet;
import java.util.Set;

/**
 * Home screen depth clock inside Wallpaper & style's own editor (DressRoom 3.0.10.38), patches/home_depth_clock.
 *
 * The Home editor already builds Samsung's lock-screen item editor (clock guide box, drag, resize buttons, tap → clock
 * panel) and only hides it. For a Home-only editor (EditorData which & 3 == 1, not the cover screen) these hooks:
 *  - ComponentMediator.<init> (p8.a): {@link #begin} decides whether this editor is a Home editor;
 *  - ItemEditorController.<init> (po.y) and BlurItemController.<init> (qo.b): {@link #filter} keeps only the clock item
 *    in their item set, so no lock notification / shortcut / widget items are built;
 *  - ComponentMediator.w (p8.a, after the components are set up): {@link #afterComponents} shows lock_preview (the clock
 *    layer, under the home icons layer) when the clock is on, and hides LockStar's preview container;
 *  - DesignPreviewController.V1 / EffectPreviewController.U1 (e7.h0 / e7.w0): {@link #menuSize} + {@link #addMenu} add
 *    a "Clock" entry to the editor's own WALLPAPER menu array (string clock_item_name, a Frame-style icon) that turns
 *    the clock on and off;
 *  - NotifyObjectFinish (y7.d.c, Samsung's own subject segmentation result): {@link #onObject} puts the cut-out subject
 *    above the clock layer (below the guide boxes), so the preview shows the clock behind the subject;
 *  - LockScreenComponent.Y save skip branch (dc.p, taken for every Home-only apply, so no lock data is written):
 *    {@link #onHomeSave} gets the final ClockData (step 2 stores it for the home engine; for now it is only logged).
 */
public final class HomeClock {
    static final String TAG = "K4HomeClock";
    static final String PROP = "persist.sys.k4.home_depth_clock";
    static final String MENU_TAG = "homeClock";
    private static final String CLOCK_DATA_PROVIDER = "mf.o0"; // getObservableClockData (the clock item's data)

    public static volatile boolean active;
    static boolean on;
    private static WeakReference<p8.a> sMediator = new WeakReference<>(null);
    private static WeakReference<ImageView> sSubject = new WeakReference<>(null);

    private HomeClock() {}

    static boolean propOn() {
        try {
            String v = SemSystemProperties.get(PROP);
            return "1".equals(v) || "true".equalsIgnoreCase(v);
        } catch (Throwable t) {
            return false;
        }
    }

    /** p8.a.<init>, once which (h) and isCover (j) are parsed. */
    public static void begin(p8.a m) {
        try {
            active = (m.h & 3) == 1 && !m.j;
            on = active && propOn();
            sMediator = new WeakReference<>(m);
            Log.i(TAG, "editor which=" + m.h + " cover=" + m.j + " -> home clock " + (active ? (on ? "on" : "off") : "not offered"));
        } catch (Throwable t) {
            active = false;
            Log.e(TAG, "begin", t);
        }
    }

    /** po.y / qo.b constructors: only the clock item in a Home editor. */
    public static Set filter(Set items) {
        if (!active || items == null) {
            return items;
        }
        try {
            Set<Object> out = new HashSet<>();
            for (Object o : items) {
                if (o != null && CLOCK_DATA_PROVIDER.equals(o.getClass().getName())) {
                    out.add(o);
                }
            }
            if (out.isEmpty()) {
                Log.w(TAG, "filter: no clock item in " + items.size() + " items, leaving them");
                return items;
            }
            Log.i(TAG, "filter: " + items.size() + " lock items -> clock only");
            return out;
        } catch (Throwable t) {
            Log.e(TAG, "filter", t);
            return items;
        }
    }

    /** p8.a.w end: components are set up and the Home preview is selected. */
    public static void afterComponents(p8.a m) {
        if (!active) {
            return;
        }
        try {
            applyVisibility(m);
        } catch (Throwable t) {
            Log.e(TAG, "afterComponents", t);
        }
    }

    static int id(Context c, String type, String name) {
        return c.getResources().getIdentifier(name, type, c.getPackageName());
    }

    static void applyVisibility(p8.a m) {
        final View lock = m.g;
        if (lock == null) {
            return;
        }
        lock.setAlpha(1f);
        lock.setVisibility(on ? View.VISIBLE : View.GONE);
        if (sEnforced.get() != lock && lock instanceof ViewGroup) {
            sEnforced = new WeakReference<>(lock);
            final ViewGroup g = (ViewGroup) lock;
            final int star = id(lock.getContext(), "id", "lockstar_preview_container");
            final int clock = id(lock.getContext(), "id", "clock_preview");
            lock.getViewTreeObserver().addOnPreDrawListener(new android.view.ViewTreeObserver.OnPreDrawListener() {
                @Override
                public boolean onPreDraw() {
                    if (!active || g.getParent() == null || sEnforced.get() != g) {
                        g.getViewTreeObserver().removeOnPreDrawListener(this);
                        return true;
                    }
                    clockOnly(g, star, clock);
                    return true;
                }
            });
        }
        ImageView s = sSubject.get();
        if (s != null) {
            s.setVisibility(on ? View.VISIBLE : View.GONE);
        }
    }

    private static WeakReference<View> sEnforced = new WeakReference<>(null);

    static void hide(View v) {
        if (v != null && v.getVisibility() != View.GONE) {
            v.setVisibility(View.GONE);
        }
    }

    /**
     * Only the clock in the Home editor's lock layer: LockStar (lock icon, fingerprint, shortcuts) and every guide box
     * except the clock's stay hidden. The item set is already clock-only; LockStar's guide boxes come from its own
     * plugin, so they are hidden here (GONE views get no touches). The clock's box is the one over the clock view.
     */
    static void clockOnly(ViewGroup lock, int star, int clockId) {
        if (star != 0) {
            hide(lock.findViewById(star));
        }
        View clock = clockId != 0 ? lock.findViewById(clockId) : null;
        if (clock instanceof ViewGroup && ((ViewGroup) clock).getChildCount() > 0) {
            clock = ((ViewGroup) clock).getChildAt(0);
        }
        ViewGroup editor = null;
        for (int i = 0; i < lock.getChildCount(); i++) {
            if (lock.getChildAt(i).getClass().getName().endsWith("ItemEditorContainer")) {
                editor = (ViewGroup) lock.getChildAt(i);
            }
        }
        if (editor == null || clock == null || clock.getWidth() == 0) {
            return;
        }
        int[] p = new int[2];
        clock.getLocationOnScreen(p);
        Rect c = new Rect(p[0], p[1], p[0] + Math.round(clock.getWidth() * scale(clock)), p[1] + Math.round(clock.getHeight() * scale(clock)));
        View best = null;
        long bestArea = 0;
        for (int i = 0; i < editor.getChildCount(); i++) {
            View b = editor.getChildAt(i);
            if (b.getWidth() == 0) {
                continue;
            }
            b.getLocationOnScreen(p);
            Rect r = new Rect(p[0], p[1], p[0] + Math.round(b.getWidth() * scale(b)), p[1] + Math.round(b.getHeight() * scale(b)));
            if (r.intersect(c)) {
                long area = (long) r.width() * r.height();
                if (area > bestArea) {
                    bestArea = area;
                    best = b;
                }
            }
        }
        if (best == null) {
            return;
        }
        for (int i = 0; i < editor.getChildCount(); i++) {
            if (editor.getChildAt(i) != best) {
                hide(editor.getChildAt(i));
            }
        }
    }

    /** Overall scale of a view on screen (the lock item layer is drawn scaled down to the preview). */
    static float scale(View v) {
        float s = 1f;
        for (Object o = v; o instanceof View; o = ((View) o).getParent()) {
            s *= ((View) o).getScaleX();
        }
        return s;
    }

    /** e7.h0.V1(): one more slot in the WALLPAPER menu array of a Home editor (Samsung allocates exactly V1() slots). */
    public static int menuSize(int n) {
        return active && n > 0 ? n + 1 : n;
    }

    /** e7.w0.U1(), before the array is handed to EditorMenuMediator: the Clock entry in the first free slot. */
    public static void addMenu(final o6.e0 controller, k6.m[] items) {
        if (!active || items == null) {
            return;
        }
        try {
            int slot = -1;
            for (int i = 0; i < items.length; i++) {
                if (items[i] == null) {
                    slot = i;
                    break;
                }
            }
            if (slot < 0) {
                Log.w(TAG, "addMenu: no free slot in " + items.length);
                return;
            }
            Activity a = controller.M;
            int text = id(a, "string", "clock_item_name");
            int icon = id(a, "drawable", "preview_selector_icon_clock");
            k6.m item = new k6.m(text != 0 ? text : -1, icon, new Runnable() {
                @Override
                public void run() {
                    toggle(controller);
                }
            }, MENU_TAG);
            item.j = on;
            items[slot] = item;
        } catch (Throwable t) {
            Log.e(TAG, "addMenu", t);
        }
    }

    static void toggle(o6.e0 controller) {
        on = !on;
        Log.i(TAG, "clock " + (on ? "on" : "off"));
        p8.a m = sMediator.get();
        if (m != null) {
            applyVisibility(m);
        }
        if (controller.T0 != null) {
            controller.T0.g(MENU_TAG, on);
        }
    }

    /**
     * y7.d.c start (NotifyObjectFinish): Samsung's segmentation result. d7.j.a (d7.m) .k is the cut-out subject with the
     * size of the wallpaper drawable (Samsung layers it onto the same CropImageView with CropImageView.D(1, ...)), so it
     * is shown with the wallpaper drawable's bounds in the editor (CropImageView.getDrawableBounds(), view coordinates
     * of the wallpaper view, whose origin and size are lock_preview's) and follows them while the user pans/zooms.
     */
    public static void onObject(View crop, Object result, Bitmap fallback) {
        if (!active) {
            return;
        }
        try {
            Bitmap obj = null;
            try {
                obj = (Bitmap) field(field(result, "a"), "k");
            } catch (Throwable ignored) {
            }
            if (obj == null) {
                obj = fallback;
            }
            p8.a m = sMediator.get();
            if (obj == null || crop == null || m == null || !(m.g instanceof ViewGroup)) {
                return;
            }
            final ViewGroup lock = (ViewGroup) m.g;
            final View cropView = crop;
            final Bitmap bmp = obj;
            lock.post(new Runnable() {
                @Override
                public void run() {
                    placeSubject(lock, cropView, bmp);
                }
            });
        } catch (Throwable t) {
            Log.e(TAG, "onObject", t);
        }
    }

    static RectF drawableBounds(View crop) {
        try {
            return (RectF) crop.getClass().getMethod("getDrawableBounds").invoke(crop);
        } catch (Throwable t) {
            return null;
        }
    }

    /** Same size, place and image matrix as the wallpaper CropImageView (an ImageView drawing with its image matrix). */
    static void layoutSubject(ImageView s, View crop) {
        if (!(crop instanceof ImageView) || crop.getWidth() == 0) {
            return;
        }
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) s.getLayoutParams();
        int l = crop.getLeft(), t = crop.getTop(), w = crop.getWidth(), h = crop.getHeight();
        if (lp.leftMargin != l || lp.topMargin != t || lp.width != w || lp.height != h) {
            lp.leftMargin = l;
            lp.topMargin = t;
            lp.width = w;
            lp.height = h;
            s.setLayoutParams(lp);
        }
        android.graphics.Matrix m = ((ImageView) crop).getImageMatrix();
        if (!m.equals(s.getImageMatrix())) {
            s.setImageMatrix(new android.graphics.Matrix(m));
            s.invalidate();
        }
    }

    static void placeSubject(ViewGroup lock, final View crop, Bitmap bmp) {
        ImageView s = sSubject.get();
        if (s == null || s.getParent() != lock) {
            s = new ImageView(lock.getContext());
            s.setScaleType(ImageView.ScaleType.MATRIX);
            s.setClickable(false);
            s.setFocusable(false);
            s.setImportantForAccessibility(View.IMPORTANT_FOR_ACCESSIBILITY_NO);
            // above the clock layer, below the item editor (guide boxes) so it never takes touches meant for them
            int at = lock.getChildCount();
            for (int i = 0; i < lock.getChildCount(); i++) {
                if (lock.getChildAt(i).getClass().getName().endsWith("ItemEditorContainer")) {
                    at = i;
                    break;
                }
            }
            lock.addView(s, at, new FrameLayout.LayoutParams(0, 0));
            sSubject = new WeakReference<>(s);
            final WeakReference<ImageView> ref = sSubject;
            crop.getViewTreeObserver().addOnPreDrawListener(new android.view.ViewTreeObserver.OnPreDrawListener() {
                @Override
                public boolean onPreDraw() {
                    ImageView v = ref.get();
                    if (v == null || v.getParent() == null) {
                        crop.getViewTreeObserver().removeOnPreDrawListener(this);
                    } else {
                        layoutSubject(v, crop); // the wallpaper was panned / zoomed
                    }
                    return true;
                }
            });
        }
        s.setImageBitmap(bmp);
        try { // debug aid: see the clock through the subject (persist.sys.k4.home_depth_clock_debug=1)
            s.setAlpha("1".equals(SemSystemProperties.get(PROP + "_debug")) ? 0.35f : 1f);
        } catch (Throwable ignored) {
        }
        layoutSubject(s, crop);
        s.setVisibility(on ? View.VISIBLE : View.GONE);
        Object d = crop instanceof ImageView ? ((ImageView) crop).getDrawable() : null;
        Log.i(TAG, "subject above clock: " + bmp.getWidth() + "x" + bmp.getHeight() + " over " + drawableBounds(crop)
                + (d != null ? " (wallpaper drawable " + ((android.graphics.drawable.Drawable) d).getIntrinsicWidth() + "x"
                + ((android.graphics.drawable.Drawable) d).getIntrinsicHeight() + ")" : ""));
    }

    /** dc.p.Y, Home-only apply (lock save skipped): the clock item's final ClockData. */
    public static void onHomeSave(Object lockComponent) {
        if (!active) {
            return;
        }
        try {
            Object provider = field(lockComponent, "g0");
            Object repo = field(provider, "a");
            Object data = repo.getClass().getMethod("getData").invoke(repo);
            Log.i(TAG, "home apply: clock " + (on ? "on" : "off") + ", ClockData=" + data);
        } catch (Throwable t) {
            Log.e(TAG, "onHomeSave", t);
        }
    }

    static Object field(Object o, String name) throws Exception {
        Field f = null;
        for (Class<?> c = o.getClass(); c != null && f == null; c = c.getSuperclass()) {
            try {
                f = c.getDeclaredField(name);
            } catch (NoSuchFieldException ignored) {
            }
        }
        if (f == null) {
            throw new NoSuchFieldException(name);
        }
        f.setAccessible(true);
        return f.get(o);
    }
}
