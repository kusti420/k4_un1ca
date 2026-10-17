package com.k4.homeclock;

import android.content.Context;
import android.graphics.Rect;
import android.provider.Settings;
import android.util.Log;

import org.json.JSONObject;

/**
 * The home clock as saved by the Wallpaper & style editor (DressRoom, Home "Set as wallpaper" -> Done):
 *   Settings.System k4_home_clock_item       the clock as Samsung AOD SDK ClockItem JSON (ClockItemImpl, gson)
 *   Settings.System k4_home_clock_item_rect  "left,top,right,bottom,scale" of the clock on the real screen (pixels)
 * Read once per presenter build (the editor sends RELOAD after saving, which rebuilds the engine). Either key missing or
 * unreadable -> null, and the plain ClockNode is used as before.
 */
final class HomeClockItem {
    static final String KEY = "k4_home_clock_item";

    int clockType;
    /** Font: presetFontIndex (null = keep the clock's own font), path ("" for preset fonts), weight, rounded corners. */
    Integer fontIndex;
    String fontPath = "";
    Integer fontWeight;
    /** Stretch clock per-digit heights, null when the clock is not stretched. */
    java.util.List<Float> fontHeights;
    /** The editor's ClockData.fontColorType: 0 = white text, 1 = black; null when not saved (older config). */
    Integer fontColorType;
    Integer fontRounded;
    /** Colour: the simple name of the ClockItem colour impl (ClockPresetColorImpl, StaticColorImpl, Adaptive*). */
    String colorType = "";
    int presetIndex;
    Integer color;
    boolean hasShadow;
    int shadowColor;
    float shadowRadius;
    float shadowDx;
    float shadowDy;
    boolean showDateFirst = true;
    /** isShowWeather: weather icon + temperature on the date line (which then uses the short date). */
    boolean showWeather = true;
    boolean blur;
    /** x.locatedAt: Start / Center / End (how the clock sits in its rect if the widths differ). */
    String gravityX = "Start";
    /** The editor's clock gravity (k4_home_clock_bundle "gravity", e.g. Gravity.END), null when not saved. */
    Integer gravity;
    final Rect rect = new Rect();
    float scale = 1f;
    String raw = "";

    private HomeClockItem() {}

    static HomeClockItem read(Context context) {
        String json;
        String rect;
        try {
            json = Settings.System.getString(context.getContentResolver(), KEY);
            rect = Settings.System.getString(context.getContentResolver(), KEY + "_rect");
        } catch (Throwable t) {
            Log.w(HomeDepthClock.TAG, "clock item: settings not readable", t);
            return null;
        }
        if (json == null || json.trim().isEmpty() || rect == null || rect.trim().isEmpty()) {
            return null;
        }
        try {
            HomeClockItem it = parse(json, rect);
            it.gravity = bundleGravity(context);
            return it;
        } catch (Throwable t) {
            Log.w(HomeDepthClock.TAG, "clock item: unreadable, using the plain clock (" + t + ")");
            return null;
        }
    }

    /**
     * The clock gravity the editor gave its own preview (ClockView.setClockGravity), from the WallpaperClockBundle it
     * saves as Settings.System k4_home_clock_bundle; null if missing.
     */
    static Integer bundleGravity(Context context) {
        try {
            String b = Settings.System.getString(context.getContentResolver(), "k4_home_clock_bundle");
            if (b == null || b.trim().isEmpty()) {
                return null;
            }
            JSONObject o = new JSONObject(b);
            return o.has("gravity") && !o.isNull("gravity") ? Integer.valueOf(o.getInt("gravity")) : null;
        } catch (Throwable t) {
            Log.w(HomeDepthClock.TAG, "clock bundle: no gravity (" + t + ")");
            return null;
        }
    }

    static HomeClockItem parse(String json, String rect) throws Exception {
        HomeClockItem it = new HomeClockItem();
        it.raw = json;
        JSONObject o = new JSONObject(json);
        if (!o.optBoolean("isEnabled", true)) {
            throw new IllegalArgumentException("clock item disabled");
        }
        it.clockType = o.getInt("clockType");
        JSONObject font = o.optJSONObject("font");
        if (font != null) {
            if (font.has("presetFontIndex") && !font.isNull("presetFontIndex")) {
                it.fontIndex = font.getInt("presetFontIndex");
            }
            it.fontPath = font.optString("fontPath", "");
            if (font.has("fontWeight") && !font.isNull("fontWeight")) {
                it.fontWeight = font.getInt("fontWeight");
            }
            if (font.has("fontRoundedCorners") && !font.isNull("fontRoundedCorners")) {
                it.fontRounded = font.getInt("fontRoundedCorners");
            }
            // stretch clock: per-digit heights (ClockFontData's 5th argument, as KeyguardClockProvider passes them)
            org.json.JSONArray hs = font.optJSONArray("fontHeights");
            if (hs != null && hs.length() > 0) {
                it.fontHeights = new java.util.ArrayList<>();
                for (int i = 0; i < hs.length(); i++) {
                    it.fontHeights.add((float) hs.getDouble(i));
                }
            }
        }
        JSONObject color = o.optJSONObject("color");
        if (color != null) {
            String type = color.optString("_type_", "");
            it.colorType = type.substring(type.lastIndexOf('.') + 1);
            it.presetIndex = color.optInt("presetIndex", 0);
            if (color.has("color")) {
                it.color = color.getInt("color");
            }
            if (color.has("shadowColor")) {
                it.hasShadow = true;
                it.shadowColor = color.getInt("shadowColor");
                it.shadowRadius = (float) color.optDouble("shadowRadius", 0);
                it.shadowDx = (float) color.optDouble("shadowDx", 0);
                it.shadowDy = (float) color.optDouble("shadowDy", 0);
            }
        }
        it.showDateFirst = o.optBoolean("isShowDateFirst", true);
        it.showWeather = o.optBoolean("isShowWeather", true);
        it.blur = o.optBoolean("isBlurEffectEnabled", false);
        JSONObject x = o.optJSONObject("x");
        if (x != null) {
            it.gravityX = x.optString("locatedAt", "Start");
        }
        String[] p = rect.trim().split(",");
        if (p.length < 4) {
            throw new IllegalArgumentException("rect: " + rect);
        }
        it.rect.set(Math.round(Float.parseFloat(p[0])), Math.round(Float.parseFloat(p[1])),
                Math.round(Float.parseFloat(p[2])), Math.round(Float.parseFloat(p[3])));
        if (it.rect.isEmpty()) {
            throw new IllegalArgumentException("rect empty: " + rect);
        }
        if (p.length > 4) {
            float s = Float.parseFloat(p[4]);
            it.scale = s > 0.05f && s < 20f ? s : 1f;
        }
        if (p.length > 5 && !p[5].isEmpty()) {
            it.fontColorType = Integer.parseInt(p[5].trim()); // the editor's colour analysis of the clock area
        }
        return it;
    }

    @Override
    public String toString() {
        return "clockType=" + clockType + ", font=" + fontIndex + "/" + fontWeight + "/" + fontRounded
                + (fontPath.isEmpty() ? "" : "/" + fontPath) + ", color=" + colorType + "(" + presetIndex + ", "
                + (color == null ? "-" : Integer.toHexString(color)) + (hasShadow ? ", shadow" : "") + "), dateFirst="
                + showDateFirst + ", weather=" + showWeather + ", blur=" + blur + ", x=" + gravityX
                + (gravity == null ? "" : "/0x" + Integer.toHexString(gravity)) + ", rect=" + rect.toShortString() + " x" + scale;
    }
}
