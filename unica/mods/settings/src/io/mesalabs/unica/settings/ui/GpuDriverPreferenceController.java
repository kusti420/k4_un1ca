package io.mesalabs.unica.settings.ui;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Color;
import android.os.SemSystemProperties;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.preference.DropDownPreference;
import androidx.preference.Preference;
import androidx.preference.PreferenceScreen;

import com.android.settings.core.BasePreferenceController;
import com.android.settingslib.widget.BannerMessagePreference;

import java.io.File;
import java.util.List;

import io.mesalabs.unica.utils.Utils;

/**
 * Settings > K4_UN1CA > UI > GPU driver (unica_ui_settings.xml: k4_gpu_driver_active, k4_gpu_driver,
 * k4_gpu_driver_restart, k4_gpu_driver_add, k4_gpu_driver_remove).
 *
 * Only shown when the target ships a selector (ro.k4.gpu_drivers = "<stock> <alternative>...", ro.k4.gpu_default, e.g.
 * target/a52sxq/patches/adreno_driver, whose /system/etc/init/k4_gpu_driver.rc does the switch at early-boot and whose
 * k4-gpu-driver handles user drivers at post-fs-data). State and entries: GpuDriverModel. "Add driver…" and
 * "Remove a driver…" open GpuDriverActivity.
 * A change only takes effect after a restart (the GPU microcode is loaded once per boot), so the page shows the active
 * driver, the selected one, and a banner with a restart button whenever they differ; after a boot that never completed
 * with the selected driver, a banner says it was undone; a selected user driver that was missing or damaged, or a
 * driver that could not be installed, also gets a banner. A driver module mounted by the root manager is active
 * whatever is selected, so the other entries cannot be selected while it is (toast).
 */
public class GpuDriverPreferenceController extends BasePreferenceController
        implements Preference.OnPreferenceChangeListener {
    private static final String KEY_ACTIVE = "k4_gpu_driver_active";
    private static final String KEY_BANNER = "k4_gpu_driver_restart";
    private static final String KEY_ADD = "k4_gpu_driver_add";
    private static final String KEY_REMOVE = "k4_gpu_driver_remove";
    private static final int COLOR_PENDING = Color.rgb(0xF5, 0x7C, 0x00);

    /** SemSystemProperties for GpuDriverModel. */
    static final class SystemProps implements GpuDriverModel.Props {
        @Override
        public String get(String key) {
            return SemSystemProperties.get(key, "");
        }

        @Override
        public void set(String key, String value) {
            SemSystemProperties.set(key, value);
        }
    }

    private final GpuDriverModel mModel = new GpuDriverModel(new SystemProps(), new File("/data/k4gpu"));
    private DropDownPreference mPref;
    private Preference mActive;
    private Preference mAdd;
    private Preference mRemove;
    private BannerMessagePreference mBanner;
    private AlertDialog mRebootDialog;
    private int mBannerKind;

    public GpuDriverPreferenceController(Context context, String key) {
        super(context, key);
    }

    @Override
    public int getAvailabilityStatus() {
        return mModel.available() ? 0 /* AVAILABLE */ : 3 /* UNSUPPORTED_ON_DEVICE */;
    }

    @Override
    public void displayPreference(PreferenceScreen screen) {
        super.displayPreference(screen);
        mPref = (DropDownPreference) screen.findPreference(getPreferenceKey());
        mActive = screen.findPreference(KEY_ACTIVE);
        mAdd = screen.findPreference(KEY_ADD);
        mRemove = screen.findPreference(KEY_REMOVE);
        mBanner = (BannerMessagePreference) screen.findPreference(KEY_BANNER);
        if (mPref != null) mPref.setOnPreferenceChangeListener(this);
        if (mBanner != null) {
            mBanner.setNegativeButtonVisible(false);
            mBanner.setPositiveButtonOnClickListener(v -> onBannerButton());
        }
        boolean available = getAvailabilityStatus() == 0;
        if (mActive != null) mActive.setVisible(available);
        if (mAdd != null) mAdd.setVisible(available);
        if (mRemove != null) mRemove.setVisible(false);
        if (mBanner != null) mBanner.setVisible(false);
        refresh();
    }

    @Override
    public void updateState(Preference preference) {
        super.updateState(preference);
        refresh();
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        String value = String.valueOf(newValue);
        mModel.reload();
        if (!mModel.select(value)) {
            if (!mModel.external().isEmpty()) Toast.makeText(mContext, lockedMessage(), Toast.LENGTH_LONG).show();
            refresh();
            return false;
        }
        refresh();
        return true;
    }

    private void onBannerButton() {
        switch (mBannerKind) {
            case 2:  // "change undone" notice acknowledged
                SemSystemProperties.set(GpuDriverModel.PROP_FAILED, "");
                SemSystemProperties.set(GpuDriverModel.PROP_TRIAL, "ok");
                break;
            case 3:  // missing / not installed notice acknowledged (until the next boot reports something new)
                SemSystemProperties.set(GpuDriverModel.PROP_MISSING, "");
                SemSystemProperties.set(GpuDriverModel.PROP_REJECTED, "");
                break;
            default:
                if (mRebootDialog == null) mRebootDialog = Utils.createRebootDialog(mContext);
                mRebootDialog.show();
                return;
        }
        refresh();
    }

    private void refresh() {
        if (mPref == null || getAvailabilityStatus() != 0) return;
        mModel.reload();
        List<GpuDriverModel.Entry> entries = mModel.entries();
        CharSequence[] labels = new CharSequence[entries.size()];
        CharSequence[] values = new CharSequence[entries.size()];
        for (int i = 0; i < labels.length; i++) {
            values[i] = entries.get(i).id;
            labels[i] = label(mContext, mModel, entries.get(i).id);
        }
        mPref.mEntryValues = values;
        mPref.setEntries(labels);

        String selected = mModel.selected();
        String active = mModel.active();
        String failed = mModel.failed();
        String ext = mModel.external();
        boolean pending = !selected.equals(active);

        mPref.setValue(selected);
        if (pending) {
            mPref.setSummary(string("k4_gpu_driver_selected_pending", label(selected)));
            mPref.seslSetSummaryColor(COLOR_PENDING);
        } else if (!ext.isEmpty()) {
            mPref.setSummary(string("k4_gpu_driver_external_summary", label(selected), root()));
        } else {
            mPref.setSummary(string("k4_gpu_driver_selected_active", label(selected)));
        }
        if (mActive != null) mActive.setSummary(label(active));
        if (mRemove != null) mRemove.setVisible(mModel.hasUserEntries());

        if (mBanner == null) return;
        String missing = mModel.missing();
        String rejected = mModel.rejected();
        if (pending) {
            mBannerKind = 1;
            mBanner.setTitle(string("k4_gpu_driver_restart_title"));
            mBanner.setSummary(string("k4_gpu_driver_restart_summary", label(selected), label(active)));
            mBanner.setAttentionLevel(BannerMessagePreference.AttentionLevel.HIGH);
            mBanner.setPositiveButtonText(string("k4_gpu_driver_restart_button"));
        } else if (!failed.isEmpty()) {
            mBannerKind = 2;
            mBanner.setTitle(string("k4_gpu_driver_failed_title"));
            mBanner.setSummary(string("k4_gpu_driver_failed_summary", label(failed), label(active)));
            mBanner.setAttentionLevel(BannerMessagePreference.AttentionLevel.MEDIUM);
            mBanner.setPositiveButtonText(string("k4_gpu_driver_failed_button"));
        } else if (!missing.isEmpty() || !rejected.isEmpty()) {
            mBannerKind = 3;
            if (!missing.isEmpty()) {
                mBanner.setTitle(string("k4_gpu_driver_missing_title"));
                mBanner.setSummary(string("k4_gpu_driver_missing_summary", label(missing), label(active))
                        + (rejected.isEmpty() ? "" : "\n" + rejected));
            } else {
                mBanner.setTitle(string("k4_gpu_driver_rejected_title"));
                mBanner.setSummary(rejected);
            }
            mBanner.setAttentionLevel(BannerMessagePreference.AttentionLevel.MEDIUM);
            mBanner.setPositiveButtonText(string("k4_gpu_driver_failed_button"));
        } else {
            mBannerKind = 0;
            mBanner.setVisible(false);
            return;
        }
        mBanner.setPositiveButtonVisible(true);
        mBanner.setVisible(true);
    }

    private String label(String id) {
        return label(mContext, mModel, id);
    }

    /**
     * Built-in: the k4_gpu_driver_entries/values arrays (fallback "V@0<id>"); the stock entry shows the version of a
     * driver flashed into /vendor instead; user drivers: the label k4-gpu-driver wrote; unknown slots: "module <id>".
     */
    static String label(Context context, GpuDriverModel model, String id) {
        GpuDriverModel.Entry e = model.anyEntry(id);
        if (e != null && e.label != null) return e.label;
        if (id.equals(model.stockDriver()) && !model.vendorVersion().isEmpty()) {
            return string(context, "k4_gpu_driver_label_vendor", model.vendorVersion());
        }
        if (id.startsWith("m_")) return string(context, "k4_gpu_driver_label_module", model.moduleOf(id));
        if (id.startsWith("u_")) return string(context, "k4_gpu_driver_label_added");
        try {
            Resources res = context.getResources();
            String[] values = res.getStringArray(Utils.getResourceId("array", "k4_gpu_driver_values"));
            String[] entries = res.getStringArray(Utils.getResourceId("array", "k4_gpu_driver_entries"));
            for (int i = 0; i < values.length && i < entries.length; i++) {
                if (values[i].equals(id)) return entries[i];
            }
        } catch (Resources.NotFoundException ignored) {
        }
        return "V@0" + id.replace('_', '.');
    }

    private String root() {
        return mModel.root().isEmpty() ? string("k4_gpu_driver_root_unknown") : mModel.root();
    }

    private String lockedMessage() {
        String ext = mModel.external();
        return string("k4_gpu_driver_locked", label(ext), root(), mModel.moduleOf(ext));
    }

    private String string(String name, Object... args) {
        return string(mContext, name, args);
    }

    private static String string(Context context, String name, Object... args) {
        return context.getString(Utils.getResourceId("string", name), args);
    }

    // SecSettings is built with interface default methods desugared, so on device BasePreferenceController's
    // Controllable/Sliceable methods are abstract and every subclass carries its own copy (One UI's controllers all
    // have these as bridge methods). Missing them = AbstractMethodError when the Settings command/search indexer
    // (ActionDataConverter.buildActionData) calls isControllable(), which kills Settings. Values match the stock
    // defaults.
    public Class<?> getBackgroundWorkerClass() { return null; }
    public android.content.IntentFilter getIntentFilter() { return null; }
    public android.content.Intent getLaunchIntent() { return null; }
    public int getSliceHighlightMenuRes() { return 0; }
    public String getStatusText() { return null; }
    public com.samsung.android.settings.cube.ControlValue getValue() { return null; }
    public boolean hasAsyncUpdate() { return false; }
    public void ignoreUserInteraction() {}
    public boolean isControllable() { return false; }
    public boolean isPublicSlice() { return false; }
    public boolean isSliceable() { return false; }
    public com.samsung.android.settings.cube.Controllable.ControllableType needUserInteraction(Object value) {
        return com.samsung.android.settings.cube.Controllable.ControllableType.NO_INTERACTION;
    }
    public boolean runDefaultAction() { return false; }
    public com.samsung.android.settings.cube.ControlResult setValue(com.samsung.android.settings.cube.ControlValue value) {
        return null;
    }
    public boolean useDynamicSliceSummary() { return false; }
}
