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
    boolean blur;
    /** x.locatedAt: Start / Center / End (how the clock sits in its rect if the widths differ). */
    String gravityX = "Start";
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
            return parse(json, rect);
        } catch (Throwable t) {
            Log.w(HomeDepthClock.TAG, "clock item: unreadable, using the plain clock (" + t + ")");
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
        return it;
    }

    @Override
    public String toString() {
        return "clockType=" + clockType + ", font=" + fontIndex + "/" + fontWeight + "/" + fontRounded
                + (fontPath.isEmpty() ? "" : "/" + fontPath) + ", color=" + colorType + "(" + presetIndex + ", "
                + (color == null ? "-" : Integer.toHexString(color)) + (hasShadow ? ", shadow" : "") + "), dateFirst="
                + showDateFirst + ", blur=" + blur + ", x=" + gravityX + ", rect=" + rect.toShortString() + " x" + scale;
    }
}
