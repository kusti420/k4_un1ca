package com.android.settings.core;
public abstract class TogglePreferenceController extends BasePreferenceController {
    public TogglePreferenceController(android.content.Context c, String key) { super(c, key); }
    public abstract boolean isChecked();
    public abstract boolean setChecked(boolean b);
    public android.content.Intent getLaunchIntent() { throw new RuntimeException(); }
    public String getStatusText() { throw new RuntimeException(); }
    public com.samsung.android.settings.cube.ControlValue getValue() { throw new RuntimeException(); }
    public com.samsung.android.settings.cube.Controllable.ControllableType needUserInteraction(Object o) { throw new RuntimeException(); }
    public boolean runDefaultAction() { throw new RuntimeException(); }
    public com.samsung.android.settings.cube.ControlResult setValue(com.samsung.android.settings.cube.ControlValue v) { throw new RuntimeException(); }
}
