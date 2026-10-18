package com.k4.lockscreen;

import android.app.ActivityThread;
import android.app.Application;
import android.content.ContentResolver;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Process;
import android.os.SystemProperties;
import android.os.UserManager;
import android.util.AtomicFile;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * patches/lockstar_bfu_clock (see module.prop): lock screen / AOD clock before the first unlock.
 *
 * AODService's lock screen code runs inside SystemUI. With Good Lock LockStar installed (>= 9.0), every item it loads
 * (clock style, font, colour, stretch heights, position, wallpaper bundle ...) goes through
 * ContentResolver.call(content://com.samsung.systemui.lockstar.provider.LockScreenDataContent, "get", ...), and
 * LockStar answers with the final, merged data. LockStar is not direct-boot aware and its data is CE, so before the
 * first unlock that call throws "Unknown authority" and AODService falls back to its own CE database, which is not
 * readable either: the default bold clock is shown until the user unlocks.
 *
 * framework.jar ContentResolver.call(String, String, String, Bundle) asks {@link #handles} first. Only in the
 * com.android.systemui process and only for LockStar's authority (one String.equals for everyone else):
 *  - user unlocked: the real call runs; the answers to the read-only "get" requests are kept in a JSON file in
 *    SystemUI's device-protected storage (/data/user_de/0/com.android.systemui/files/k4_lockstar_snapshot.json);
 *  - user locked: a stored answer for the identical request is returned instead of the failing call; anything
 *    never stored (or any other method, e.g. "post") takes the stock path.
 * persist.sys.k4.lock_bfu_snapshot: 0 = off (stock), 1 = default, 2 = also replay lock-star-get/lock_star_enabled.
 */
public final class K4LockSnapshot {
    static final String TAG = "K4LockSnap";
    private static final String AUTHORITY = "com.samsung.systemui.lockstar.provider.LockScreenDataContent";
    private static final String PROP = "persist.sys.k4.lock_bfu_snapshot";
    private static final String FILE_NAME = "k4_lockstar_snapshot.json";
    private static final int FORMAT = 1;
    private static final int MAX_ENTRIES = 256;
    private static final long WRITE_DELAY_MS = 1000;

    private static final ThreadLocal<Boolean> sInCall = new ThreadLocal<>();
    /** 0 = not known yet, 1 = SystemUI, -1 = any other process. */
    private static volatile int sProcess;

    private static final Object sLock = new Object();
    /** request key -> serialized answer bundle; null until loaded. Guarded by sLock. */
    private static LinkedHashMap<String, String> sEntries;
    private static boolean sWritePending;
    private static Handler sHandler;

    private K4LockSnapshot() {
    }

    /** Hook entry, called for every ContentResolver.call(String, ...) in every process. */
    public static boolean handles(String authority) {
        if (!AUTHORITY.equals(authority)) {
            return false;
        }
        if (sInCall.get() != null) {
            return false;
        }
        int p = sProcess;
        if (p == 0) {
            Application app = ActivityThread.currentApplication();
            if (app == null) {
                return false;
            }
            p = "com.android.systemui".equals(app.getPackageName()) ? 1 : -1;
            sProcess = p;
        }
        return p == 1 && mode() != 0;
    }

    /** Hook body, only reached when {@link #handles} returned true. Throws exactly what the stock call throws. */
    public static Bundle call(ContentResolver cr, String authority, String method, String arg, Bundle extras) {
        String key = key(mode(), method, arg, extras);
        if (key == null) {
            return real(cr, authority, method, arg, extras);
        }
        Application app = ActivityThread.currentApplication();
        if (app == null) {
            return real(cr, authority, method, arg, extras);
        }
        if (!unlocked(app)) {
            Bundle stored = lookup(app, key);
            if (stored != null) {
                Log.i(TAG, "locked: stored answer for " + key.replace('\n', ' '));
                return stored;
            }
            Log.i(TAG, "locked: nothing stored for " + key.replace('\n', ' '));
            return real(cr, authority, method, arg, extras);
        }
        Bundle result = real(cr, authority, method, arg, extras);
        try {
            record(app, key, result);
        } catch (Throwable t) {
            Log.w(TAG, "record failed", t);
        }
        return result;
    }

    private static int mode() {
        try {
            return SystemProperties.getInt(PROP, 1);
        } catch (Throwable t) {
            return 1;
        }
    }

    private static Bundle real(ContentResolver cr, String authority, String method, String arg, Bundle extras) {
        sInCall.set(Boolean.TRUE);
        try {
            return cr.call(authority, method, arg, extras);
        } finally {
            sInCall.remove();
        }
    }

    private static boolean unlocked(Context ctx) {
        try {
            UserManager um = ctx.getSystemService(UserManager.class);
            return um == null || um.isUserUnlocked();
        } catch (Throwable t) {
            return true;
        }
    }

    /** Request key, or null when this request must never be answered from storage. */
    static String key(int mode, String method, String arg, Bundle extras) {
        if (arg == null) {
            return null;
        }
        if ("get".equals(method)) {
            if (!"item".equals(arg) && !"items".equals(arg) && !"lock_data_bundle".equals(arg)
                    && !"all_item_keys".equals(arg)) {
                return null;
            }
        } else if ("lock-star-get".equals(method)) {
            if (mode < 2 || !"lock_star_enabled".equals(arg)) {
                return null;
            }
        } else {
            return null;
        }
        StringBuilder sb = new StringBuilder(method).append('\n').append(arg);
        if (extras != null) {
            ArrayList<String> names = new ArrayList<>(extras.keySet());
            Collections.sort(names);
            for (String name : names) {
                // added by AODService's AodDataProvider to every request: its own (here: default) answer and the
                // caller's package. Neither selects what LockStar returns.
                if ("primary_result".equals(name) || "request_from".equals(name)) {
                    continue;
                }
                Object v = extras.get(name);
                String s;
                if (v == null || v instanceof String || v instanceof Boolean || v instanceof Integer
                        || v instanceof Long) {
                    s = String.valueOf(v);
                } else if (v instanceof String[]) {
                    s = Arrays.toString((String[]) v);
                } else {
                    return null;
                }
                sb.append('\n').append(name).append('=').append(s);
            }
        }
        return sb.toString();
    }

    private static Bundle lookup(Context app, String key) {
        String json;
        synchronized (sLock) {
            load(app);
            json = sEntries.get(key);
        }
        if (json == null) {
            return null;
        }
        try {
            return toBundle(new JSONObject(json));
        } catch (Throwable t) {
            Log.w(TAG, "stored answer unreadable: " + t);
            return null;
        }
    }

    private static void record(Context app, String key, Bundle result) {
        String json = null;
        if (result != null) {
            JSONObject o = toJson(result);
            json = o == null ? null : o.toString();
        }
        synchronized (sLock) {
            load(app);
            String old = sEntries.get(key);
            if (json == null ? old == null : json.equals(old)) {
                return;
            }
            if (json == null) {
                sEntries.remove(key);
            } else {
                sEntries.remove(key);
                sEntries.put(key, json);
                while (sEntries.size() > MAX_ENTRIES) {
                    Iterator<String> it = sEntries.keySet().iterator();
                    it.next();
                    it.remove();
                }
            }
            Log.i(TAG, (json == null ? "dropped " : "stored ") + key.replace('\n', ' '));
            scheduleWrite(app);
        }
    }

    // ---- storage -------------------------------------------------------------------------------------------------

    private static File file(Context app) {
        return new File(app.createDeviceProtectedStorageContext().getFilesDir(), FILE_NAME);
    }

    /** Caller holds sLock. */
    private static void load(Context app) {
        if (sEntries != null) {
            return;
        }
        sEntries = new LinkedHashMap<>();
        try {
            File f = file(app);
            if (!f.exists()) {
                return;
            }
            JSONObject root = new JSONObject(new String(new AtomicFile(f).readFully(), StandardCharsets.UTF_8));
            if (root.optInt("format") != FORMAT) {
                Log.w(TAG, "ignoring snapshot with format " + root.optInt("format"));
                return;
            }
            JSONObject entries = root.getJSONObject("entries");
            Iterator<String> it = entries.keys();
            while (it.hasNext()) {
                String k = it.next();
                sEntries.put(k, entries.getJSONObject(k).toString());
            }
            Log.i(TAG, "loaded " + sEntries.size() + " stored answers");
        } catch (Throwable t) {
            Log.w(TAG, "snapshot unreadable, starting empty: " + t);
            sEntries.clear();
        }
    }

    /** Caller holds sLock. */
    private static void scheduleWrite(Context app) {
        if (sWritePending) {
            return;
        }
        if (sHandler == null) {
            HandlerThread t = new HandlerThread(TAG, Process.THREAD_PRIORITY_BACKGROUND);
            t.start();
            sHandler = new Handler(t.getLooper());
        }
        sWritePending = true;
        sHandler.postDelayed(new Writer(app), WRITE_DELAY_MS);
    }

    static void write(Context app) {
        String data;
        synchronized (sLock) {
            sWritePending = false;
            try {
                JSONObject entries = new JSONObject();
                for (Map.Entry<String, String> e : sEntries.entrySet()) {
                    entries.put(e.getKey(), new JSONObject(e.getValue()));
                }
                JSONObject root = new JSONObject();
                root.put("format", FORMAT);
                root.put("entries", entries);
                data = root.toString();
            } catch (Throwable t) {
                Log.w(TAG, "snapshot serialize failed", t);
                return;
            }
        }
        AtomicFile af = new AtomicFile(file(app));
        FileOutputStream out = null;
        try {
            out = af.startWrite();
            out.write(data.getBytes(StandardCharsets.UTF_8));
            af.finishWrite(out);
        } catch (Throwable t) {
            Log.w(TAG, "snapshot write failed", t);
            if (out != null) {
                af.failWrite(out);
            }
        }
    }

    static final class Writer implements Runnable {
        private final Context mApp;

        Writer(Context app) {
            mApp = app;
        }

        @Override
        public void run() {
            write(mApp);
        }
    }

    // ---- Bundle <-> JSON (only the plain types LockStar answers with) -------------------------------------------

    /** null when the bundle holds anything that cannot be stored faithfully. */
    static JSONObject toJson(Bundle b) {
        try {
            JSONObject o = new JSONObject();
            for (String k : b.keySet()) {
                Object v = b.get(k);
                JSONObject e = new JSONObject();
                if (v == null) {
                    e.put("t", "n");
                } else if (v instanceof String) {
                    e.put("t", "s").put("v", v);
                } else if (v instanceof Boolean) {
                    e.put("t", "z").put("v", v);
                } else if (v instanceof Integer) {
                    e.put("t", "i").put("v", v);
                } else if (v instanceof Long) {
                    e.put("t", "l").put("v", String.valueOf(v));
                } else if (v instanceof Float) {
                    e.put("t", "f").put("v", String.valueOf(v));
                } else if (v instanceof Double) {
                    e.put("t", "d").put("v", String.valueOf(v));
                } else if (v instanceof String[]) {
                    JSONArray a = new JSONArray();
                    for (String s : (String[]) v) {
                        a.put(s == null ? JSONObject.NULL : s);
                    }
                    e.put("t", "S").put("v", a);
                } else if (v instanceof Bundle) {
                    JSONObject inner = toJson((Bundle) v);
                    if (inner == null) {
                        return null;
                    }
                    e.put("t", "B").put("v", inner);
                } else {
                    Log.i(TAG, "not storable: " + k + " is " + v.getClass().getName());
                    return null;
                }
                o.put(k, e);
            }
            return o;
        } catch (Throwable t) {
            Log.w(TAG, "toJson failed: " + t);
            return null;
        }
    }

    static Bundle toBundle(JSONObject o) throws Exception {
        Bundle b = new Bundle();
        Iterator<String> it = o.keys();
        while (it.hasNext()) {
            String k = it.next();
            JSONObject e = o.getJSONObject(k);
            String t = e.getString("t");
            switch (t) {
                case "n":
                    b.putString(k, null);
                    break;
                case "s":
                    b.putString(k, e.getString("v"));
                    break;
                case "z":
                    b.putBoolean(k, e.getBoolean("v"));
                    break;
                case "i":
                    b.putInt(k, e.getInt("v"));
                    break;
                case "l":
                    b.putLong(k, Long.parseLong(e.getString("v")));
                    break;
                case "f":
                    b.putFloat(k, Float.parseFloat(e.getString("v")));
                    break;
                case "d":
                    b.putDouble(k, Double.parseDouble(e.getString("v")));
                    break;
                case "S": {
                    JSONArray a = e.getJSONArray("v");
                    String[] s = new String[a.length()];
                    for (int i = 0; i < s.length; i++) {
                        s[i] = a.isNull(i) ? null : a.getString(i);
                    }
                    b.putStringArray(k, s);
                    break;
                }
                case "B":
                    b.putBundle(k, toBundle(e.getJSONObject("v")));
                    break;
                default:
                    throw new IllegalArgumentException("type " + t);
            }
        }
        return b;
    }
}
