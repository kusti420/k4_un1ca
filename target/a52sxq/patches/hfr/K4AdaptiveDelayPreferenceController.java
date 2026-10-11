/*
 * Settings > Display > "Adaptive smoothness delay" (a52sxq hfr patch): how long after the last touch Adaptive motion
 * smoothness drops from 120 Hz to 60 Hz. Writes the system property system_server's K4AdaptiveTouch reads on every
 * touch, so a new value applies from the next touch. The choices, their labels and the default come from resources
 * the patch generates (k4_adaptive_delay_values / _entries / _default), not from this class.
 *
 * Source of K4AdaptiveDelayPreferenceController.smali next to it. To regenerate: compile against android.jar and
 * stubs of the few SecSettings classes used (same names and signatures as in the decoded apk; customize.sh asserts
 * each of them), then `d8 --release --min-api 34` and `baksmali d --di false -l --sl`. The property name literal is
 * replaced by ADAPTIVE_IDLE_PROP when the patch is applied.
 */
package com.k4.settings.display;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.os.SemSystemProperties;
import android.text.TextUtils;
import android.util.Log;

import androidx.appcompat.app.AlertDialog;
import androidx.preference.Preference;
import androidx.preference.PreferenceScreen;

import com.android.settings.core.BasePreferenceController;
import com.samsung.android.settings.cube.ControlResult;
import com.samsung.android.settings.cube.ControlValue;
import com.samsung.android.settings.cube.Controllable;
import com.samsung.android.settings.display.SecDisplayUtils;

public class K4AdaptiveDelayPreferenceController extends BasePreferenceController
        implements DialogInterface.OnClickListener {
    private static final String TAG = "K4AdaptiveDelay";
    private static final String PROP = "persist.sys.k4.adaptive_idle_ms";

    private Preference mPreference;
    private AlertDialog mDialog;

    public K4AdaptiveDelayPreferenceController(Context context, String key) {
        super(context, key);
    }

    @Override
    public int getAvailabilityStatus() {
        return 0;
    }

    @Override
    public void displayPreference(PreferenceScreen screen) {
        super.displayPreference(screen);
        mPreference = screen.findPreference(getPreferenceKey());
    }

    private int res(String type, String name) {
        return mContext.getResources().getIdentifier(name, type, mContext.getPackageName());
    }

    private String string(String name) {
        int id = res("string", name);
        return id != 0 ? mContext.getString(id) : "";
    }

    private int[] values() {
        int id = res("array", "k4_adaptive_delay_values");
        int[] values = id != 0 ? mContext.getResources().getIntArray(id) : null;
        return values != null ? values : new int[0];
    }

    private String label(int[] values, int index) {
        int id = res("array", "k4_adaptive_delay_entries");
        String[] entries = id != 0 ? mContext.getResources().getStringArray(id) : null;
        if (entries != null && index < entries.length) {
            return entries[index];
        }
        return values[index] + " ms";
    }

    /** Index of the choice closest to ms; values must not be empty. */
    static int nearest(int[] values, int ms) {
        int best = 0;
        for (int i = 1; i < values.length; i++) {
            if (Math.abs(values[i] - ms) < Math.abs(values[best] - ms)) {
                best = i;
            }
        }
        return best;
    }

    private int currentIndex(int[] values) {
        int ms = SemSystemProperties.getInt(PROP, -1);
        if (ms <= 0) {
            int id = res("integer", "k4_adaptive_delay_default");
            ms = id != 0 ? mContext.getResources().getInteger(id) : values[0];
        }
        return nearest(values, ms);
    }

    private boolean isAdaptive() {
        return SecDisplayUtils.getIntRefreshRate(mContext, 0) == 1;
    }

    @Override
    public CharSequence getSummary() {
        if (!isAdaptive()) {
            return string("k4_adaptive_delay_summary_off");
        }
        int[] values = values();
        if (values.length == 0) {
            return "";
        }
        String label = label(values, currentIndex(values));
        int id = res("string", "k4_adaptive_delay_summary");
        return id != 0 ? mContext.getString(id, label) : label;
    }

    @Override
    public void updateState(Preference preference) {
        super.updateState(preference);
        if (preference != null) {
            preference.setEnabled(isAdaptive());
        }
    }

    @Override
    public boolean handlePreferenceTreeClick(Preference preference) {
        if (preference == null || !TextUtils.equals(preference.getKey(), getPreferenceKey())) {
            return false;
        }
        int[] values = values();
        if (values.length == 0 || !isAdaptive()) {
            return true;
        }
        CharSequence[] items = new CharSequence[values.length];
        for (int i = 0; i < values.length; i++) {
            items[i] = label(values, i);
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
        int title = res("string", "k4_adaptive_delay_title");
        if (title != 0) {
            builder.setTitle(title);
        }
        builder.setSingleChoiceItems(items, currentIndex(values), this);
        builder.setNegativeButton(android.R.string.cancel, null);
        mDialog = builder.create();
        mDialog.show();
        return true;
    }

    @Override
    public void onClick(DialogInterface dialog, int which) {
        int[] values = values();
        if (which >= 0 && which < values.length) {
            try {
                SemSystemProperties.set(PROP, Integer.toString(values[which]));
            } catch (RuntimeException e) {
                Log.w(TAG, "Failed to set " + PROP, e);
            }
        }
        if (dialog != null) {
            dialog.dismiss();
        }
        mDialog = null;
        if (mPreference != null) {
            updateState(mPreference);
        }
    }

    // BasePreferenceController / Sliceable leave these abstract in this (R8-processed) SecSettings; every stock
    // controller carries the same "nothing to control, not sliceable" answers.

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
