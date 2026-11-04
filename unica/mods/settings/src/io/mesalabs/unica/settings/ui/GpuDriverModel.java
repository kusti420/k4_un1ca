package io.mesalabs.unica.settings.ui;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * The GPU driver selector's state (no Android dependencies, host-tested by src/test): the entries, the selection and
 * removal. Built-in drivers come from ro.k4.gpu_drivers ("<stock> <id>...": the stock driver, what /vendor holds and
 * the failsafe falls back to, first) and ro.k4.gpu_default (the one a phone with no selection gets, selected by the
 * boot-time part with a trial boot; absent = the stock driver), user drivers from what the boot-time part
 * (target/a52sxq/patches/adreno_driver/k4-gpu-driver) found this boot (/data/k4gpu/drivers, valid once
 * sys.k4.gpu_scan=1) and from drivers Settings staged for the next boot (/data/k4gpu/incoming/u_*).
 * Requests to the boot-time part are files in /data/k4gpu/incoming: &lt;slot&gt;.remove (delete an added driver),
 * &lt;slot&gt;.hide (hide a module's driver).
 */
final class GpuDriverModel {
    static final String PROP_DRIVERS = "ro.k4.gpu_drivers";
    static final String PROP_DEFAULT = "ro.k4.gpu_default";
    static final String PROP_SELECTED = "persist.sys.k4.gpu_driver";
    static final String PROP_TRIAL = "persist.sys.k4.gpu_trial";
    static final String PROP_FAILED = "persist.sys.k4.gpu_failed";
    static final String PROP_PREV = "persist.sys.k4.gpu_prev";
    static final String PROP_ACTIVE = "sys.k4.gpu_active";
    static final String PROP_SCAN = "sys.k4.gpu_scan";
    static final String PROP_EXTERNAL = "sys.k4.gpu_external";
    static final String PROP_ROOT = "sys.k4.gpu_root";
    static final String PROP_VENDOR = "sys.k4.gpu_vendor";
    static final String PROP_MISSING = "sys.k4.gpu_missing";
    static final String PROP_REJECTED = "sys.k4.gpu_rejected";

    static final int BUILTIN = 0;
    static final int MODULE = 1;
    static final int ADDED = 2;
    static final int STAGED = 3;

    interface Props {
        String get(String key);

        void set(String key, String value);
    }

    static final class Entry {
        final String id;
        final int kind;
        final String label;
        final boolean external;
        /** the module id for a module's driver (from the drivers list), else "" */
        final String module;

        Entry(String id, int kind, String label, boolean external, String module) {
            this.id = id;
            this.kind = kind;
            this.label = label;
            this.external = external;
            this.module = module == null ? "" : module;
        }
    }

    private final Props mProps;
    private final File mBase;
    private final File mIncoming;
    private List<Entry> mEntries;

    GpuDriverModel(Props props, File base) {
        mProps = props;
        mBase = base;
        mIncoming = new File(base, "incoming");
    }

    File incoming() {
        return mIncoming;
    }

    void reload() {
        mEntries = null;
    }

    String[] builtins() {
        String s = prop(PROP_DRIVERS).trim();
        return s.isEmpty() ? new String[0] : s.split("\\s+");
    }

    boolean available() {
        return builtins().length > 1;
    }

    /** The stock driver (listed first): what /vendor holds, never on trial, what every fallback goes to. */
    String stockDriver() {
        String[] d = builtins();
        return d.length > 0 ? d[0] : "";
    }

    /** The driver a phone with no selection gets (ro.k4.gpu_default when it is a built-in, else the stock one). */
    String defaultDriver() {
        String d = prop(PROP_DEFAULT);
        for (String b : builtins()) if (b.equals(d)) return d;
        return stockDriver();
    }

    /** Built-ins (label null: the caller has the resources), then module and added drivers, then staged ones. */
    List<Entry> entries() {
        if (mEntries != null) return mEntries;
        List<Entry> list = new ArrayList<>();
        for (String id : builtins()) list.add(new Entry(id, BUILTIN, null, false, null));
        for (Entry e : listed()) {
            if (find(list, e.id) != null) continue;
            if (!e.external && (marker(e.id, ".remove").exists() || marker(e.id, ".hide").exists())) continue;
            list.add(e);
        }
        String[] staged = mIncoming.list();
        if (staged != null) {
            Arrays.sort(staged);
            for (String s : staged) {
                File d = new File(mIncoming, s);
                if (!s.startsWith("u_") || !new File(d, "ready").isFile() || find(list, s) != null) continue;
                String version = info(new File(d, "info"), "version");
                String name = info(new File(d, "info"), "name");
                list.add(new Entry(s, STAGED, addedLabel(version, name), false, null));
            }
        }
        mEntries = list;
        return list;
    }

    Entry entry(String id) {
        return find(entries(), id);
    }

    /** The drivers k4-gpu-driver listed this boot (only once sys.k4.gpu_scan=1), including ones Settings has since
     *  asked to hide or remove: slot, kind, flags, label[, module id]. */
    private List<Entry> listed() {
        List<Entry> out = new ArrayList<>();
        if (!"1".equals(prop(PROP_SCAN))) return out;
        for (String line : readLines(new File(mBase, "drivers"))) {
            String[] f = line.split("\t", 5);
            if (f.length < 4 || !isSlot(f[0]) || find(out, f[0]) != null) continue;
            out.add(new Entry(f[0], "module".equals(f[1]) ? MODULE : ADDED, f[3], "external".equals(f[2]),
                    f.length > 4 ? f[4].trim() : ""));
        }
        return out;
    }

    /** Like entry(), but also finds a listed driver that is being hidden or removed (it stays in use until the
     *  restart, so its label is still the right one to show). */
    Entry anyEntry(String id) {
        Entry e = entry(id);
        return e != null ? e : find(listed(), id);
    }

    /** The module id behind a module's slot: from the drivers list, else derived from the slot name. */
    String moduleOf(String slot) {
        Entry e = anyEntry(slot);
        return e != null && !e.module.isEmpty() ? e.module : moduleId(slot);
    }

    boolean isKnown(String id) {
        return entry(id) != null;
    }

    /** The stored selection; an unknown one (or none, which k4-gpu-driver never leaves behind: it stores the default
     *  at post-fs-data) shows the stock driver, which is what the next boot resolves it to. */
    String selected() {
        String s = prop(PROP_SELECTED);
        return isKnown(s) ? s : stockDriver();
    }

    /** What this boot uses (the stock driver when nothing says otherwise); a user driver stays the active one while
     *  it is being removed (until the restart). */
    String active() {
        String s = prop(PROP_ACTIVE);
        return isKnown(s) || isSlot(s) ? s : stockDriver();
    }

    /** The driver whose trial boot never completed (the boot after it went back to the default). */
    String failed() {
        String s = prop(PROP_FAILED);
        return isKnown(s) || isSlot(s) ? s : "";
    }

    String missing() {
        return prop(PROP_MISSING);
    }

    String rejected() {
        return prop(PROP_REJECTED);
    }

    /** A module's driver mounted by the root manager: it is active whatever is selected. */
    String external() {
        String s = prop(PROP_EXTERNAL);
        Entry e = entry(s);
        return e != null && e.external ? s : "";
    }

    String root() {
        String r = prop(PROP_ROOT);
        return r.isEmpty() || "none".equals(r) ? "" : r;
    }

    /** The driver flashed into /vendor when it is not the stock one, else "". */
    String vendorVersion() {
        return prop(PROP_VENDOR);
    }

    boolean hasUserEntries() {
        for (Entry e : entries()) if (e.kind != BUILTIN) return true;
        return false;
    }

    /**
     * Selects a driver for the next boot, with a trial boot unless it is already active or it is the stock driver -
     * the stock driver is what the failsafe falls back to, so it is never on trial (the default is: it is a built-in
     * set like any other here). False if refused.
     */
    boolean select(String id) {
        if (!isKnown(id)) return false;
        String ext = external();
        if (!ext.isEmpty() && !ext.equals(id)) return false;
        mProps.set(PROP_SELECTED, id);
        mProps.set(PROP_TRIAL, id.equals(active()) || id.equals(stockDriver()) ? "ok" : "pending");
        mProps.set(PROP_FAILED, "");
        return true;
    }

    /**
     * Removes a user entry: a staged driver is deleted now, an added one at the next boot (its files may be in use),
     * a module's driver is hidden (its files belong to the module). A selected entry hands the selection back to the
     * previous choice or the default.
     */
    boolean remove(String id) {
        Entry e = entry(id);
        if (e == null || e.kind == BUILTIN || e.external) return false;
        boolean done;
        if (e.kind == STAGED) {
            done = deleteTree(new File(mIncoming, id));
        } else {
            done = touch(marker(id, e.kind == MODULE ? ".hide" : ".remove"));
        }
        if (!done) return false;
        boolean wasSelected = id.equals(prop(PROP_SELECTED));
        mEntries = null;
        if (wasSelected) {
            String prev = prop(PROP_PREV);
            select(!prev.equals(id) && isKnown(prev) ? prev : defaultDriver());
        }
        return true;
    }

    /** An added driver with the same version and name (the user picked the same zip twice), or null. */
    Entry duplicateOf(String version, String name) {
        String label = addedLabel(version, name);
        for (Entry e : entries()) {
            if ((e.kind == ADDED || e.kind == STAGED) && label.equals(e.label)) return e;
        }
        return null;
    }

    /** The label k4-gpu-driver gives an added driver (drivers file), also used for staged ones. */
    static String addedLabel(String version, String name) {
        return version + " (added: " + name + ")";
    }

    static boolean isSlot(String s) {
        return (s.startsWith("m_") || s.startsWith("u_")) && s.length() > 2 && s.matches("[A-Za-z0-9._+-]+");
    }

    /**
     * "m_some_driver_0249090c" -> "some_driver": k4-gpu-driver names a module's slot m_&lt;id, at most 30 chars&gt;_&lt;8 hex
     * of the full id&gt;; this is only the fallback when the drivers list does not name the module (moduleOf).
     */
    static String moduleId(String slot) {
        if (!slot.startsWith("m_")) return slot;
        String s = slot.substring(2);
        return s.matches(".+_[0-9a-f]{8}") ? s.substring(0, s.length() - 9) : s;
    }

    private File marker(String slot, String suffix) {
        return new File(mIncoming, slot + suffix);
    }

    private String prop(String key) {
        String v = mProps.get(key);
        return v == null ? "" : v.trim();
    }

    private static Entry find(List<Entry> list, String id) {
        if (id == null || id.isEmpty()) return null;
        for (Entry e : list) if (e.id.equals(id)) return e;
        return null;
    }

    static String info(File f, String key) {
        for (String line : readLines(f)) {
            if (line.startsWith(key + "=")) return line.substring(key.length() + 1);
        }
        return "";
    }

    static List<String> readLines(File f) {
        List<String> out = new ArrayList<>();
        if (!f.isFile()) return out;
        try (BufferedReader r = new BufferedReader(new InputStreamReader(new FileInputStream(f), StandardCharsets.UTF_8))) {
            String line;
            while ((line = r.readLine()) != null && out.size() < 256) out.add(line);
        } catch (IOException ignored) {
        }
        return out;
    }

    static boolean touch(File f) {
        try {
            new FileOutputStream(f).close();
            return true;
        } catch (IOException e) {
            return false;
        }
    }

    static boolean deleteTree(File f) {
        File[] children = f.isDirectory() ? f.listFiles() : null;
        if (children != null) for (File c : children) deleteTree(c);
        return f.delete() || !f.exists();
    }
}
