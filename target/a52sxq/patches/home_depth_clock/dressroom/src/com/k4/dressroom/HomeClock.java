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

    private HomeClock() {}

    static String debug() {
        try {
            String v = SemSystemProperties.get(PROP + "_debug");
            return v == null ? "" : v;
        } catch (Throwable t) {
            return "";
        }
    }

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
            sBundle = null;
            sBundleRead = false;
            sRestored = false;
            sDepth = true;
            synchronized (sPut) {
                sPut.clear();
            }
            EditXf.reset();
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
        hideLauncher(m);
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
                    EditXf.keepSwitch();
                    p8.a med = sMediator.get();
                    if (med != null) {
                        hideLauncher(med);
                    }
                    return true;
                }
            });
        }
        SubjectView s = sSubjectView.get();
        if (s != null) {
            s.setVisibility(on && sDepth ? View.VISIBLE : View.GONE);
        }
    }

    private static WeakReference<View> sEnforced = new WeakReference<>(null);

    /**
     * The Home editor shows only the wallpaper, the subject and the clock: home_preview (p8.a.f, the launcher's home
     * screenshot with icons, widgets, folders, dock, search bar and page dots, a non-clickable ImageView above
     * lock_preview) stays invisible. INVISIBLE keeps its layout and passes touches on; enforced every frame because
     * Samsung fades it back in when it reloads the screenshot.
     */
    static void hideLauncher(p8.a m) {
        View home = m.f;
        if (active && home != null && home.getVisibility() != View.INVISIBLE) {
            home.animate().cancel();
            home.setVisibility(View.INVISIBLE);
            Log.i(TAG, "launcher preview hidden");
        }
    }

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

    private static WeakReference<k6.m> sItem = new WeakReference<>(null);
    private static int sIcon, sIconOn;

    /**
     * Menu bar (v8.y.a, "scroll the menu"): Samsung scrolls a phone menu with more than 4 entries, 4.5 entries wide.
     * The Home editor's 5 entries (with Clock) are laid out evenly instead, like the 4-entry bar.
     */
    public static boolean menuScrolls() {
        return !active;
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
            sIcon = icon;
            sIconOn = id(a, "drawable", "preview_menu_icon_clock_activated");
            if (on && sIconOn != 0) {
                item.b = sIconOn;
            }
            sItem = new WeakReference<>(item);
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
        // on/off look of the menu entry, like Samsung's effect entries (filled icon while active)
        int icon = on && sIconOn != 0 ? sIconOn : sIcon;
        k6.m item = sItem.get();
        if (item != null && icon != 0) {
            item.b = icon;
        }
        try {
            View entry = controller.M.getWindow().getDecorView().findViewWithTag(MENU_TAG);
            int iconView = id(controller.M, "id", "menu_icon");
            View img = entry != null && iconView != 0 ? entry.findViewById(iconView) : null;
            if (img != null && icon != 0) {
                img.setBackgroundResource(icon);
            }
        } catch (Throwable t) {
            Log.w(TAG, "menu icon", t);
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
            Object res = null;
            try {
                res = field(result, "a");
                obj = (Bitmap) field(res, "k");
            } catch (Throwable ignored) {
            }
            // Samsung saves the cut-out (masked.jpg, the layer the home engine puts in front of the clock) only when
            // ImagePreviewController.b3() says so: d7.m.a(null), true for people and animals, false for an "Unknown"
            // object. The preview shows the subject in front of the clock only when the saved wallpaper will have it.
            boolean depth = true;
            try {
                if (res != null) {
                    java.lang.reflect.Method a = res.getClass().getMethod("a", Boolean.class);
                    depth = (Boolean) a.invoke(res, new Object[] {null});
                }
            } catch (Throwable t) {
                Log.w(TAG, "subject: save check", t);
            }
            sDepth = depth;
            if (!depth) {
                Log.i(TAG, "subject not saved by Samsung for this picture: clock drawn over the whole picture");
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

    /**
     * The cut-out subject, drawn exactly like the wallpaper: CropImageView (an ImageView) draws its drawable with its
     * image matrix and moves/zooms it by changing the drawable's bounds, so the subject (same size as the wallpaper
     * drawable, as Samsung layers it) is drawn with the same matrix and bounds, re-read every frame while the user
     * pans or pinches. Never touchable.
     */
    static final class SubjectView extends View {
        final ImageView crop;
        android.graphics.drawable.BitmapDrawable subject;
        private final float[] last = new float[17];
        private final float[] now = new float[17];

        SubjectView(Context c, ImageView crop) {
            super(c);
            this.crop = crop;
            setClickable(false);
            setFocusable(false);
            setImportantForAccessibility(IMPORTANT_FOR_ACCESSIBILITY_NO);
        }

        @Override
        public boolean onTouchEvent(android.view.MotionEvent e) {
            return false;
        }

        /** True when the wallpaper moved since the last frame drawn. */
        boolean changed() {
            android.graphics.drawable.Drawable d = crop.getDrawable();
            if (d == null) {
                return false;
            }
            crop.getImageMatrix().getValues(now);
            Rect b = d.getBounds();
            now[9] = b.left;
            now[10] = b.top;
            now[11] = b.right;
            now[12] = b.bottom;
            EditXf.state(now, 13); // zoom-out / rotation of the Home editor (EditXf)
            if (java.util.Arrays.equals(now, last)) {
                return false;
            }
            System.arraycopy(now, 0, last, 0, now.length);
            return true;
        }

        @Override
        protected void onDraw(android.graphics.Canvas canvas) {
            android.graphics.drawable.Drawable d = crop.getDrawable();
            if (d == null || subject == null) {
                return;
            }
            int save = canvas.save();
            EditXf.apply(crop, canvas); // follows the Home editor's zoom-out / rotation
            canvas.translate(crop.getPaddingLeft(), crop.getPaddingTop());
            canvas.concat(crop.getImageMatrix());
            subject.setBounds(d.getBounds());
            subject.draw(canvas);
            canvas.restoreToCount(save);
        }
    }

    static WeakReference<SubjectView> sSubjectView = new WeakReference<>(null);
    /** The saved wallpaper will have the cut-out layer (see onObject). */
    static volatile boolean sDepth = true;

    static void placeSubject(ViewGroup lock, final View cropView, Bitmap bmp) {
        if (!(cropView instanceof ImageView)) {
            return;
        }
        final ImageView crop = (ImageView) cropView;
        SubjectView s = sSubjectView.get();
        if (s == null || s.getParent() != lock || s.crop != crop) {
            if (s != null && s.getParent() instanceof ViewGroup) {
                ((ViewGroup) s.getParent()).removeView(s);
            }
            s = new SubjectView(lock.getContext(), crop);
            // above the clock layer, below the item editor (guide boxes)
            int at = lock.getChildCount();
            for (int i = 0; i < lock.getChildCount(); i++) {
                if (lock.getChildAt(i).getClass().getName().endsWith("ItemEditorContainer")) {
                    at = i;
                    break;
                }
            }
            lock.addView(s, at, new FrameLayout.LayoutParams(crop.getWidth(), crop.getHeight()));
            sSubjectView = new WeakReference<>(s);
            final WeakReference<SubjectView> ref = sSubjectView;
            crop.getViewTreeObserver().addOnPreDrawListener(new android.view.ViewTreeObserver.OnPreDrawListener() {
                @Override
                public boolean onPreDraw() {
                    SubjectView v = ref.get();
                    if (v == null || v.getParent() == null) {
                        crop.getViewTreeObserver().removeOnPreDrawListener(this);
                        return true;
                    }
                    FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) v.getLayoutParams();
                    if (lp.leftMargin != crop.getLeft() || lp.topMargin != crop.getTop()
                            || lp.width != crop.getWidth() || lp.height != crop.getHeight()) {
                        lp.leftMargin = crop.getLeft();
                        lp.topMargin = crop.getTop();
                        lp.width = crop.getWidth();
                        lp.height = crop.getHeight();
                        v.setLayoutParams(lp);
                    }
                    if (v.changed()) {
                        v.invalidate(); // follows pan / pinch frame by frame
                    }
                    return true;
                }
            });
        }
        s.subject = new android.graphics.drawable.BitmapDrawable(lock.getResources(), bmp);
        s.subject.setFilterBitmap(true);
        try { // debug aids (persist.sys.k4.home_depth_clock_debug): 1 = see the clock through the subject,
            // "tint" = the subject drawn magenta, so any offset against the picture under it shows as the picture's own
            // subject colour next to the magenta (alignment tests)
            String dbg = debug();
            s.setAlpha("1".equals(dbg) ? 0.35f : 1f);
            if (dbg.contains("tint")) {
                s.subject.setColorFilter(new android.graphics.PorterDuffColorFilter(0xffff00ff, android.graphics.PorterDuff.Mode.SRC_IN));
            }
        } catch (Throwable ignored) {
        }
        s.setVisibility(on && sDepth ? View.VISIBLE : View.GONE);
        s.invalidate();
        android.graphics.drawable.Drawable d = crop.getDrawable();
        Log.i(TAG, "subject above clock: " + bmp.getWidth() + "x" + bmp.getHeight()
                + (d != null ? " (wallpaper drawable " + d.getIntrinsicWidth() + "x" + d.getIntrinsicHeight() + ", bounds " + d.getBounds() + ")" : ""));
    }

    // ---- home clock config: the clock as Samsung's AOD SDK ClockItem JSON (the format the lock clock is stored in) ----
    static final String KEY_ITEM = "k4_home_clock_item";
    static final String ITEM_CLASS = "com.samsung.android.sdk.aodservice.entities.item.LockScreenItem";
    private static WeakReference<Object> sStore = new WeakReference<>(null);

    /** ClockStoreRepositoryImpl.c(String) start: remember the store (its context and its item serializer). */
    public static void storeSeen(Object store) {
        sStore = new WeakReference<>(store);
    }

    /** The lock editor's Gson (ClockStoreRepositoryImpl.c -> LockScreenRemoteItemStoreImpl.b -> .c -> serializer.b). */
    static Object gson(Object store) throws Exception {
        Object itemStore = call(field(store, "c"), "get");
        Object repo = call(field(itemStore, "b"), "get");
        Object serializer = call(field(repo, "c"), "get");
        return field(serializer, "b");
    }

    static Object call(Object o, String name) throws Exception {
        java.lang.reflect.Method m = o.getClass().getMethod(name);
        m.setAccessible(true);
        return m.invoke(o);
    }

    /**
     * ClockStoreRepositoryImpl.c(String) result: in a Home editor the clock item the editor starts from is the saved
     * home clock (Settings.System k4_home_clock_item) instead of the lock clock.
     */
    public static Object seedItem(Object lockItem) {
        if (!active) {
            return lockItem;
        }
        try {
            Object store = sStore.get();
            if (store == null) {
                return lockItem;
            }
            Context c = (Context) field(store, "a");
            String json = android.provider.Settings.System.getString(c.getContentResolver(), KEY_ITEM);
            Object g = gson(store);
            Class<?> base = Class.forName(ITEM_CLASS, false, store.getClass().getClassLoader());
            if ((json == null || json.isEmpty()) && lockItem != null) {
                // no home clock yet: Samsung's default clock (One UI stretch clock font, regular weight, white, default
                // place and size), not the lock screen's own style
                org.json.JSONObject o = new org.json.JSONObject((String) g.getClass()
                        .getMethod("toJson", Object.class, java.lang.reflect.Type.class).invoke(g, lockItem, base));
                org.json.JSONObject font = o.optJSONObject("font");
                if (font != null) {
                    font.put("presetFontIndex", 800); // One UI clock font, a stretch font like Samsung's default
                    font.put("fontWeight", 400);
                }
                org.json.JSONObject color = new org.json.JSONObject();
                color.put("presetIndex", 0);
                color.put("_type_", "com.samsung.android.sdk.aodservice.factory.ClockPresetColorImpl");
                o.put("color", color);
                o.put("isDefaultPosition", true);
                o.put("scaleX", 1.0);
                o.put("scaleY", 1.0);
                json = o.toString();
                Log.i(TAG, "editor starts from the default home clock");
            }
            if (json == null || json.isEmpty()) {
                return lockItem;
            }
            Object item = g.getClass().getMethod("fromJson", String.class, Class.class).invoke(g, json, base);
            if (item != null && (lockItem == null || item.getClass() == lockItem.getClass())) {
                Log.i(TAG, "editor starts from the saved home clock");
                return item;
            }
        } catch (Throwable t) {
            Log.e(TAG, "seedItem", t);
        }
        return lockItem;
    }

    static final String KEY_BUNDLE = "k4_home_clock_bundle";
    static final String BUNDLE_CLASS = "com.samsung.android.lockscreen.editor.item.domain.entity.item.clock.wallpaperbundle.WallpaperClockBundle";
    static final String BUNDLE_CONVERT = "yc.b0"; // WallpaperClockBundleConvertRepositoryImpl: a(ClockData, bundle) / b(ClockData)
    private static Object sBundle;
    private static boolean sBundleRead, sRestored;

    private static final java.util.Map<Object, Set<String>> sPut = new java.util.WeakHashMap<>();

    /**
     * WallpaperClockBundleRepository.get(sceneId) (cd.c.o) result. The lock editor keeps the clock's place (gravity,
     * margins, scale) and its stretch heights per wallpaper in such a bundle, not in the ClockItem (whose x/y stay
     * NO_VALUE). For a picture opened from Gallery the scene id is null, and the repository loaded from the lock screen
     * holds the LOCK clock's bundle under that key, so a Home editor would start from the lock clock's place and then
     * reset its stretch. In a Home editor the bundle saved with the home clock (Settings.System k4_home_clock_bundle)
     * is returned instead, for every repository and id, until Samsung itself stores a bundle for that id in that
     * repository during this editor (bundlePut: the user moved or resized the clock); Samsung applies it itself
     * (ManageLifeCycleClockData / ApplyWallpaperClockBundleData / GetWallpaperClockBundle).
     */
    public static Object bundle(Object repo, String id, Object samsung) {
        if (!active) {
            return samsung;
        }
        try {
            synchronized (sPut) {
                Set<String> put = sPut.get(repo);
                if (put != null && put.contains(String.valueOf(id))) {
                    return samsung;
                }
            }
            if (!sBundleRead) {
                sBundleRead = true;
                Context c = null;
                Object store = sStore.get();
                if (store != null) {
                    c = (Context) field(store, "a");
                } else if (sMediator.get() != null && sMediator.get().g != null) {
                    c = sMediator.get().g.getContext();
                }
                String json = c == null ? null : android.provider.Settings.System.getString(c.getContentResolver(), KEY_BUNDLE);
                if (json != null && !json.isEmpty()) {
                    ClassLoader cl = HomeClock.class.getClassLoader();
                    Object g = Class.forName("com.google.gson.Gson", true, cl).getConstructor().newInstance();
                    sBundle = g.getClass().getMethod("fromJson", String.class, Class.class)
                            .invoke(g, json, Class.forName(BUNDLE_CLASS, true, cl));
                    Log.i(TAG, "editor starts from the saved home clock place: " + sBundle);
                } else if (c == null) {
                    sBundleRead = false; // too early, try again on the next lookup
                }
            }
            if (sBundle != null) {
                sRestored = true;
                return sBundle;
            }
            return samsung;
        } catch (Throwable t) {
            Log.e(TAG, "bundle", t);
            return samsung;
        }
    }

    /** WallpaperClockBundleRepository.put(sceneId, bundle) (cd.c.l): from now on Samsung's own bundle for that id wins. */
    public static void bundlePut(Object repo, String id) {
        if (!active) {
            return;
        }
        synchronized (sPut) {
            Set<String> put = sPut.get(repo);
            if (put == null) {
                put = new HashSet<>();
                sPut.put(repo, put);
            }
            put.add(String.valueOf(id));
        }
    }

    /**
     * EntryInfo.isReeditCase() where a new picture's clock is re-laid out: ManageLifeCycleClockDataUseCase (mf.t1, resets
     * the stretch heights) and ClockPositionSuggestion (qp.e, moves and stretches the clock to suit the detected
     * subject). A Home editor that restored the saved home clock (bundle()) counts as re-editing it: the saved place and
     * heights stay as they were left.
     */
    public static boolean reedit(boolean reedit) {
        return reedit || (active && sRestored);
    }

    /** dc.p.Y, Home-only apply (Samsung skips the lock save): store the clock and the switch, tell the wallpaper. */
    public static void onHomeSave(Object lockComponent) {
        if (!active) {
            return;
        }
        try {
            Object data = call(field(field(lockComponent, "g0"), "a"), "getData");
            Object store = sStore.get();
            Context c = store != null ? (Context) field(store, "a") : null;
            if (data == null || store == null || c == null) {
                Log.w(TAG, "home apply: no clock data/store");
                return;
            }
            java.lang.reflect.Method d = null;
            for (java.lang.reflect.Method m : store.getClass().getMethods()) {
                if (m.getName().equals("d") && m.getParameterTypes().length == 3
                        && m.getParameterTypes()[2] == android.os.Bundle.class) {
                    d = m;
                }
            }
            // the clock position, the way the lock save passes it (mf.f2: ClockMarginData JSON + movable area)
            android.os.Bundle extras = new android.os.Bundle();
            ClassLoader cl = store.getClass().getClassLoader();
            try {
                Class<?> cmd = Class.forName("com.samsung.android.lockscreen.editor.item.domain.entity.item.clock.ClockMarginData", true, cl);
                Object margin = cmd.getConstructor(int.class, float.class, float.class, RectF.class).newInstance(
                        call(data, "getGravity"), call(data, "getHorizontalMarginRatio"), call(data, "getBottomMarginRatio"),
                        call(data, "getMovableAreaRatioRect"));
                Object plainGson = Class.forName("com.google.gson.Gson", true, cl).getConstructor().newInstance();
                extras.putString("clock_position_data", (String) plainGson.getClass().getMethod("toJson", Object.class).invoke(plainGson, margin));
                extras.putParcelable("clock_movable_area", (Rect) call(data, "getMovableArea"));
            } catch (Throwable t) {
                Log.w(TAG, "home apply: clock position", t);
            }
            Object item = d.invoke(store, data, null, extras); // makeLockScreenItem
            // where the clock is on the screen, for the wallpaper engine (real screen pixels)
            try {
                Rect r = (Rect) call(data, "getClockPositionRect");
                Object sc = call(data, "getScale");
                // the editor's text colour type from Samsung's wallpaper colour analysis (ColorType WHITE / BLACK)
                String colorType = "";
                try {
                    Object ct = call(data, "getFontColorType");
                    if (ct instanceof Enum) {
                        colorType = "BLACK".equals(((Enum<?>) ct).name()) ? "1" : "WHITE".equals(((Enum<?>) ct).name()) ? "0" : "";
                    }
                } catch (Throwable ignored) {
                }
                android.provider.Settings.System.putString(c.getContentResolver(), KEY_ITEM + "_rect",
                        r.left + "," + r.top + "," + r.right + "," + r.bottom + "," + sc + "," + colorType);
            } catch (Throwable t) {
                Log.w(TAG, "home apply: clock rect", t);
            }
            // where the clock sits and its stretch heights, the way the lock editor keeps them per wallpaper
            // (WallpaperClockBundle from WallpaperClockBundleConvertRepositoryImpl.b): restored by bundle() next time
            try {
                Object b = null;
                for (java.lang.reflect.Method m : Class.forName(BUNDLE_CONVERT, true, cl).getMethods()) {
                    if (m.getName().equals("b") && java.lang.reflect.Modifier.isStatic(m.getModifiers())
                            && m.getParameterTypes().length == 1 && m.getParameterTypes()[0].isInstance(data)
                            && m.getReturnType().getName().equals(BUNDLE_CLASS)) {
                        b = m.invoke(null, data);
                    }
                }
                if (b != null) {
                    Object plainGson = Class.forName("com.google.gson.Gson", true, cl).getConstructor().newInstance();
                    String bj = (String) plainGson.getClass().getMethod("toJson", Object.class).invoke(plainGson, b);
                    android.provider.Settings.System.putString(c.getContentResolver(), KEY_BUNDLE, bj);
                    Log.i(TAG, "home apply: clock bundle " + bj);
                } else {
                    Log.w(TAG, "home apply: no clock bundle converter");
                }
            } catch (Throwable t) {
                Log.w(TAG, "home apply: clock bundle", t);
            }
            Object g = gson(store);
            Class<?> base = Class.forName(ITEM_CLASS, false, store.getClass().getClassLoader());
            String json = (String) g.getClass().getMethod("toJson", Object.class, java.lang.reflect.Type.class).invoke(g, item, base);
            android.provider.Settings.System.putString(c.getContentResolver(), KEY_ITEM, json);
            android.os.SemSystemProperties.set(PROP, on ? "1" : "0");
            c.sendBroadcast(new android.content.Intent("com.k4.homeclock.action.RELOAD")
                    .setPackage("com.samsung.android.wallpaper.live").addFlags(android.content.Intent.FLAG_RECEIVER_FOREGROUND));
            Log.i(TAG, "home apply: clock " + (on ? "on" : "off") + ", item=" + json);
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
