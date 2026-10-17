/*
 * Settings > UN1CA > UI settings > "Clock position" / "Clock colour" under "Home screen depth clock" (a52sxq
 * home_depth_clock patch). A SecPreference row that opens a single-choice dialog (the same widgets as the hfr
 * patch's "Adaptive smoothness delay": SecDropDownPreference fails to resolve its item text attribute under this
 * theme). The row key picks the property; labels and values are resources settings.sh generates:
 *   k4_home_depth_clock_position -> persist.sys.k4.home_depth_clock_y      (k4_home_depth_clock_position_entries/_values)
 *   k4_home_depth_clock_color    -> persist.sys.k4.home_depth_clock_color  (k4_home_depth_clock_color_entries/_values)
 * The first value is the default. Greyed out by android:dependency while the switch is off.
 * Both only steer the plain text clock: once the Wallpaper & style editor saved a clock (Settings.System
 * k4_home_clock_item, Samsung's own clock drawn with the saved font, colour, place and size) they are hidden, and the
 * third row this class serves takes their place:
 *   k4_home_depth_clock_style    -> "Clock style: Edit in Wallpaper and style", opens Wallpaper & style
 */
package com.k4.settings.homeclock;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.SemSystemProperties;
import android.provider.Settings;
import android.text.TextUtils;

import androidx.appcompat.app.AlertDialog;
import androidx.preference.Preference;
import androidx.preference.PreferenceScreen;

import com.android.settings.core.BasePreferenceController;
import com.samsung.android.settings.cube.ControlResult;
import com.samsung.android.settings.cube.ControlValue;
import com.samsung.android.settings.cube.Controllable;

public class HomeDepthClockChoiceController extends BasePreferenceController
        implements DialogInterface.OnClickListener {
    private Preference mPreference;
    private AlertDialog mDialog;

    public HomeDepthClockChoiceController(Context context, String key) {
        super(context, key);
    }

    static final String KEY_ITEM = "k4_home_clock_item";
    static final String WALLPAPER_SETTING = "com.samsung.intent.action.WALLPAPER_SETTING";

    /** "position", "color" or "style", from the row key. */
    private String kind() {
        String key = getPreferenceKey();
        return key != null && key.endsWith("_color") ? "color" : key != null && key.endsWith("_style") ? "style" : "position";
    }

    /** The Wallpaper & style editor saved a home clock (its own style, place and size are used, not these rows). */
    private boolean editorClock() {
        try {
            return !TextUtils.isEmpty(Settings.System.getString(mContext.getContentResolver(), KEY_ITEM));
        } catch (RuntimeException e) {
            return false;
        }
    }

    private int string(String name) {
        return mContext.getResources().getIdentifier(name, "string", mContext.getPackageName());
    }

    private String prop() {
        return HomeDepthClockSwitchController.PROP + ("color".equals(kind()) ? "_color" : "_y");
    }

    private String[] array(String suffix) {
        int id = mContext.getResources().getIdentifier("k4_home_depth_clock_" + kind() + suffix, "array",
                mContext.getPackageName());
        String[] a = id != 0 ? mContext.getResources().getStringArray(id) : null;
        return a != null ? a : new String[0];
    }

    private int currentIndex(String[] values) {
        String v = SemSystemProperties.get(prop());
        if (TextUtils.isEmpty(v)) {
            return 0;
        }
        for (int i = 0; i < values.length; i++) {
            if (values[i].equalsIgnoreCase(v)) {
                return i;
            }
        }
        return -1; // set by hand (e.g. a #RRGGBB colour or another percentage)
    }

    @Override
    public int getAvailabilityStatus() {
        if ("style".equals(kind())) {
            return editorClock() ? 0 : 2; // AVAILABLE : CONDITIONALLY_UNAVAILABLE
        }
        if (array("_values").length == 0) {
            return 3; // UNSUPPORTED_ON_DEVICE
        }
        return editorClock() ? 2 : 0;
    }

    @Override
    public void displayPreference(PreferenceScreen screen) {
        super.displayPreference(screen);
        mPreference = screen.findPreference(getPreferenceKey());
    }

    @Override
    public CharSequence getSummary() {
        if ("style".equals(kind())) {
            int id = string("k4_home_depth_clock_style_summary");
            return id != 0 ? mContext.getString(id) : null;
        }
        String[] values = array("_values");
        String[] entries = array("_entries");
        int i = currentIndex(values);
        if (i >= 0 && i < entries.length) {
            return entries[i];
        }
        return SemSystemProperties.get(prop());
    }

    @Override
    public boolean handlePreferenceTreeClick(Preference preference) {
        if (preference == null || !TextUtils.equals(preference.getKey(), getPreferenceKey())) {
            return false;
        }
        if ("style".equals(kind())) {
            try {
                mContext.startActivity(new Intent(WALLPAPER_SETTING).setPackage("com.samsung.android.app.dressroom")
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
            } catch (RuntimeException e) {
                android.util.Log.w(HomeDepthClockSwitchController.TAG, "Wallpaper and style", e);
            }
            return true;
        }
        String[] entries = array("_entries");
        if (entries.length == 0) {
            return true;
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
        int title = mContext.getResources().getIdentifier("k4_home_depth_clock_" + kind() + "_title", "string",
                mContext.getPackageName());
        if (title != 0) {
            builder.setTitle(title);
        }
        builder.setSingleChoiceItems(entries, currentIndex(array("_values")), this);
        builder.setNegativeButton(android.R.string.cancel, null);
        mDialog = builder.create();
        mDialog.show();
        return true;
    }

    @Override
    public void onClick(DialogInterface dialog, int which) {
        String[] values = array("_values");
        if (which >= 0 && which < values.length) {
            HomeDepthClockSwitchController.set(prop(), values[which]);
            HomeDepthClockSwitchController.reload(mContext);
        }
        if (dialog != null) {
            dialog.dismiss();
        }
        mDialog = null;
        if (mPreference != null) {
            updateState(mPreference);
        }
    }

    // BasePreferenceController / Sliceable leave these abstract in this (R8-processed) SecSettings.

    @Override
    public Intent getLaunchIntent() {
        return null;
    }

    @Override
    public int getSliceHighlightMenuRes() {
        return 0;
    }

    @Override
    public String getStatusText() {
        return null;
    }

    @Override
    public ControlValue getValue() {
        return null;
    }

    @Override
    public boolean isControllable() {
        return false;
    }

    @Override
    public Controllable.ControllableType needUserInteraction(Object value) {
        return Controllable.ControllableType.NO_INTERACTION;
    }

    @Override
    public boolean runDefaultAction() {
        return false;
    }

    @Override
    public ControlResult setValue(ControlValue value) {
        return null;
    }
}
