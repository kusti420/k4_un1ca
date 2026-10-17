package com.android.settings.core;
public abstract class BasePreferenceController {
    protected final android.content.Context mContext = null;
    public BasePreferenceController(android.content.Context c, String key) { }
    public abstract int getAvailabilityStatus();
    public String getPreferenceKey() { throw new RuntimeException(); }
    public void displayPreference(androidx.preference.PreferenceScreen s) { throw new RuntimeException(); }
    public void updateState(androidx.preference.Preference p) { throw new RuntimeException(); }
    public CharSequence getSummary() { throw new RuntimeException(); }
    public boolean handlePreferenceTreeClick(androidx.preference.Preference p) { throw new RuntimeException(); }
    public abstract android.content.Intent getLaunchIntent();
    public abstract int getSliceHighlightMenuRes();
    public abstract String getStatusText();
    public abstract com.samsung.android.settings.cube.ControlValue getValue();
    public abstract boolean isControllable();
    public abstract com.samsung.android.settings.cube.Controllable.ControllableType needUserInteraction(Object o);
    public abstract boolean runDefaultAction();
    public abstract com.samsung.android.settings.cube.ControlResult setValue(com.samsung.android.settings.cube.ControlValue v);
}
