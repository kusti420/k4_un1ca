/*
 * Settings > UN1CA > UI settings > "Clock position" / "Clock colour" under "Home screen depth clock" (a52sxq
 * home_depth_clock patch). A SecPreference row that opens a single-choice dialog (the same widgets as the hfr
 * patch's "Adaptive smoothness delay": SecDropDownPreference fails to resolve its item text attribute under this
 * theme). The row key picks the property; labels and values are resources settings.sh generates:
 *   k4_home_depth_clock_position -> persist.sys.k4.home_depth_clock_y      (k4_home_depth_clock_position_entries/_values)
 *   k4_home_depth_clock_color    -> persist.sys.k4.home_depth_clock_color  (k4_home_depth_clock_color_entries/_values)
 * The first value is the default. Greyed out by android:dependency while the switch is off.
 */
package com.k4.settings.homeclock;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.SemSystemProperties;
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

    /** "position" or "color", from the row key. */
    private String kind() {
        String key = getPreferenceKey();
        return key != null && key.endsWith("_color") ? "color" : "position";
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
        return array("_values").length > 0 ? 0 : 3;
    }

    @Override
    public void displayPreference(PreferenceScreen screen) {
        super.displayPreference(screen);
        mPreference = screen.findPreference(getPreferenceKey());
    }

    @Override
    public CharSequence getSummary() {
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
