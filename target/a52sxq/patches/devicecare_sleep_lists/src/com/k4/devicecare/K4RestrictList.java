package com.k4.devicecare;

import android.app.WallpaperInfo;
import android.app.WallpaperManager;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.ContentValues;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.IBinder;
import android.os.Process;
import android.os.SystemClock;
import android.provider.Settings;
import android.util.Log;
import com.samsung.android.sdhms.SemAppRestrictionManager;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;

/**
 * K4_UN1CA: Device Care sleeping-app Add lists.
 *
 * MARs only manages packages that have a row in SDHMS' ForcedAppStandby table, and SDHMS never gives a row to a package
 * on the doze power-save allowlist (battery "Unrestricted"). Such apps were therefore in none of the Add lists, and
 * restrict() on them is a silent no-op. Here a user-installed app on the USER allowlist is offered in the Sleeping and
 * Deep sleeping Add lists; when the user adds it, it is first taken off the allowlist (what App info > Battery >
 * Optimized does), given its FAS row (same provider insert SDHMS does on install) and only restricted once MARs tracks it
 * and, for deep sleep, MARs' own protection check (canRestrictWithReason) has no objection.
 */
public final class K4RestrictList {
    private static final String TAG = "K4RestrictList";
    /** canRestrictWithReason bits that are soft for a manual add: widget (0x8) and quick panel tile (0x100000). */
    private static final long SOFT = 0x8L | 0x100000L;
    private static final Uri FAS = Uri.parse("content://com.sec.android.sdhms.fasprovider/ForcedAppStandby");
    private static final long WAIT_MS = 4000L;
    private static final String[] ROLES = {"android.app.role.DIALER", "android.app.role.SMS", "android.app.role.HOME",
            "android.app.role.ASSISTANT", "android.app.role.WALLET", "android.app.role.SYSTEM_GALLERY"};

    private K4RestrictList() {}

    /** Add-list filter (jc.e.c(II)). type 0 = deep sleep, 1 = sleep, 3 = never auto sleep. */
    public static boolean canList(SemAppRestrictionManager m, int type, String pkg, int uid) {
        if (pkg == null) return false;
        if (isTracked(m, pkg, uid)) return (m.canRestrictWithReason(type, pkg, uid) & ~SOFT) == 0L;
        // Not managed by MARs: only allowlisted candidates, and not for Never auto sleeping (they are already exempt).
        if (type != 0 && type != 1) return false;
        try {
            Context c = context(m);
            if (c == null || !isCandidate(c, pkg, uid)) return false;
            return type == 1 || protection(c, pkg, uid) == null;
        } catch (Throwable t) {
            Log.w(TAG, "canList " + pkg, t);
            return false;
        }
    }

    /** FAS cache loader (jc.e.e()): MARs' list plus the allowlisted candidates as "no restriction" rows. */
    public static List getAllList(SemAppRestrictionManager m) {
        List all = m.getAllList();
        if (all == null) return null;
        try {
            Context c = context(m);
            if (c == null) return all;
            HashSet<String> known = new HashSet<>();
            for (Object o : all) known.add(((SemAppRestrictionManager.AppRestrictionInfo) o).getPackageName());
            ArrayList<Object> out = null;
            for (String pkg : candidates(c)) {
                if (known.contains(pkg)) continue;
                int uid = c.getPackageManager().getApplicationInfo(pkg, 0).uid;
                if (out == null) out = new ArrayList<>(all);
                out.add(new SemAppRestrictionManager.AppRestrictionInfo(pkg, uid));
                Log.i(TAG, "offering allowlisted app " + pkg + "/" + uid);
            }
            return out == null ? all : out;
        } catch (Throwable t) {
            Log.w(TAG, "getAllList", t);
            return all;
        }
    }

    /**
     * Entry of ed.z.c(Context, List, type, on, reason): makes allowlisted candidates that are being put to sleep / deep
     * sleep manageable by MARs before the stock code restricts the list. Returns the list the stock code should use.
     */
    public static List prepare(Context c, List list, int type, boolean on) {
        if (!on || (type != 0 && type != 1) || c == null || list == null || list.isEmpty()) return list;
        try {
            SemAppRestrictionManager m = new SemAppRestrictionManager(c);
            ArrayList<kc.d> pending = new ArrayList<>();
            ArrayList<Object> drop = new ArrayList<>();
            for (Object o : list) {
                if (!(o instanceof kc.d)) continue;
                kc.d e = (kc.d) o;
                if (e.a == null || isTracked(m, e.a, e.c) || !isCandidate(c, e.a, e.c)) continue;
                String why = type == 0 ? protection(c, e.a, e.c) : null;
                if (why != null) {
                    Log.w(TAG, "not deep sleeping " + e.a + ": " + why);
                    drop.add(o);
                    continue;
                }
                Object idle = deviceIdle();
                call(idle, "removePowerSaveWhitelistApp", e.a);
                if (Boolean.TRUE.equals(call(idle, "isPowerSaveWhitelistApp", e.a))) {
                    Log.w(TAG, "could not take " + e.a + " off the doze allowlist");
                    drop.add(o);
                    continue;
                }
                Log.i(TAG, e.a + " taken off the doze allowlist for type " + type);
                try {
                    ContentValues v = new ContentValues();
                    v.put("package_name", e.a);
                    v.put("uid", e.c);
                    c.getContentResolver().insert(FAS, v);
                } catch (Throwable t) {
                    Log.w(TAG, "FAS insert " + e.a, t);
                }
                pending.add(e);
            }
            long end = SystemClock.uptimeMillis() + WAIT_MS;
            for (kc.d e : pending) {
                while (!isTracked(m, e.a, e.c) && SystemClock.uptimeMillis() < end) SystemClock.sleep(100);
                if (!isTracked(m, e.a, e.c)) {
                    Log.w(TAG, e.a + " not managed by MARs after " + WAIT_MS + " ms, left battery-optimized");
                    drop.add(e);
                    continue;
                }
                long veto = type == 0 ? m.canRestrictWithReason(0, e.a, e.c) & ~SOFT : 0L;
                if (veto != 0L) {
                    Log.w(TAG, "MARs protects " + e.a + " (0x" + Long.toHexString(veto) + "), restoring allowlist");
                    call(deviceIdle(), "addPowerSaveWhitelistApp", e.a);
                    drop.add(e);
                    continue;
                }
                Log.i(TAG, e.a + " is managed by MARs now, restricting type " + type);
            }
            if (drop.isEmpty()) return list;
            ArrayList<Object> out = new ArrayList<>(list);
            out.removeAll(drop);
            return out;
        } catch (Throwable t) {
            Log.w(TAG, "prepare", t);
            return list;
        }
    }

    // ---------------------------------------------------------------------------------------------------------------

    /** canRestrict(1, ...) is exactly "current user and a MARs target" (MARsPolicyManager.canRestrictBySEP...). */
    public static boolean isTracked(SemAppRestrictionManager m, String pkg, int uid) {
        try {
            return m.canRestrict(1, pkg, uid);
        } catch (Throwable t) {
            return false;
        }
    }

    /** Untracked only because of the USER doze allowlist, i.e. SDHMS will track it once it is off the allowlist. */
    public static boolean isCandidate(Context c, String pkg, int uid) {
        if (uid / 100000 != Process.myUid() / 100000 || uid % 100000 < 10000) return false;
        return candidates(c).contains(pkg) && c.getPackageManager().getPackagesForUid(uid) != null
                && Arrays.asList(c.getPackageManager().getPackagesForUid(uid)).contains(pkg);
    }

    public static List<String> candidates(Context c) {
        ArrayList<String> out = new ArrayList<>();
        Object idle = deviceIdle();
        String[] user = (String[]) call(idle, "getUserPowerWhitelist");
        if (user == null || user.length == 0) return out;
        String[] sys = (String[]) call(idle, "getSystemPowerWhitelist");
        HashSet<String> system = new HashSet<>(sys == null ? new ArrayList<String>() : Arrays.asList(sys));
        HashSet<String> userSet = new HashSet<>(Arrays.asList(user));
        List<String> smsDialer = roleHolders(c, "android.app.role.SMS");
        smsDialer.addAll(roleHolders(c, "android.app.role.DIALER"));
        PackageManager pm = c.getPackageManager();
        for (String pkg : user) {
            if (system.contains(pkg) || smsDialer.contains(pkg)) continue;
            ApplicationInfo ai;
            try {
                ai = pm.getApplicationInfo(pkg, 0);
            } catch (PackageManager.NameNotFoundException e) {
                continue;
            }
            if ((ai.flags & (ApplicationInfo.FLAG_SYSTEM | ApplicationInfo.FLAG_UPDATED_SYSTEM_APP)) != 0) continue;
            if (!ai.enabled || ai.uid % 100000 < 10000) continue;
            boolean sibling = false;
            String[] sharing = pm.getPackagesForUid(ai.uid);
            if (sharing != null) for (String s : sharing) if (!s.equals(pkg) && (userSet.contains(s) || system.contains(s))) sibling = true;
            if (!sibling) out.add(pkg);
        }
        return out;
    }

    /** Mirror of MARs' manual deep sleep chain (filters 9,10,11,14,22 gallery role,25,30), without widget/tile. null = no objection. */
    public static String protection(Context c, String pkg, int uid) {
        if (uid % 100000 == 1000) return "system uid";
        try {
            DevicePolicyManager dpm = c.getSystemService(DevicePolicyManager.class);
            List<ComponentName> admins = dpm == null ? null : dpm.getActiveAdmins();
            if (admins != null) for (ComponentName a : admins) if (pkg.equals(a.getPackageName())) return "device admin";
        } catch (Throwable ignored) {
        }
        for (String r : ROLES) if (roleHolders(c, r).contains(pkg)) return r;
        try {
            String ime = Settings.Secure.getString(c.getContentResolver(), "default_input_method");
            ComponentName cn = ime == null ? null : ComponentName.unflattenFromString(ime);
            if (cn != null && pkg.equals(cn.getPackageName())) return "keyboard";
        } catch (Throwable ignored) {
        }
        try {
            WallpaperManager wm = WallpaperManager.getInstance(c);
            for (int which : new int[] {WallpaperManager.FLAG_SYSTEM, WallpaperManager.FLAG_LOCK}) {
                WallpaperInfo wi = wm.getWallpaperInfo(which);
                if (wi != null && pkg.equals(wi.getPackageName())) return "wallpaper";
            }
        } catch (Throwable ignored) {
        }
        try {
            Method m = PackageManager.class.getMethod("isPackageStateProtected", String.class, int.class);
            if (Boolean.TRUE.equals(m.invoke(c.getPackageManager(), pkg, uid / 100000))) return "protected package";
        } catch (Throwable ignored) {
        }
        // Contact-sync account owners (MARs filter 22, second half) are allowed: framework.jar keeps their
        // authenticator and sync adapter registered while MARs deep-sleeps them (see services/framework part).
        return null;
    }

    @SuppressWarnings("unchecked")
    private static List<String> roleHolders(Context c, String role) {
        try {
            Object rm = c.getSystemService("role");
            Method m = rm.getClass().getMethod("getRoleHolders", String.class);
            return new ArrayList<>((List<String>) m.invoke(rm, role));
        } catch (Throwable t) {
            return new ArrayList<>();
        }
    }

    private static Context context(SemAppRestrictionManager m) {
        try {
            Field f = SemAppRestrictionManager.class.getDeclaredField("mContext");
            f.setAccessible(true);
            Object c = f.get(m);
            if (c instanceof Context) return (Context) c;
        } catch (Throwable ignored) {
        }
        try {
            return (Context) Class.forName("android.app.ActivityThread").getMethod("currentApplication").invoke(null);
        } catch (Throwable t) {
            return null;
        }
    }

    private static Object deviceIdle() {
        try {
            IBinder b = (IBinder) Class.forName("android.os.ServiceManager").getMethod("getService", String.class).invoke(null, "deviceidle");
            return Class.forName("android.os.IDeviceIdleController$Stub").getMethod("asInterface", IBinder.class).invoke(null, b);
        } catch (Throwable t) {
            Log.w(TAG, "deviceidle", t);
            return null;
        }
    }

    private static Object call(Object target, String name, Object... args) {
        if (target == null) return null;
        try {
            for (Method m : target.getClass().getMethods()) {
                if (m.getName().equals(name) && m.getParameterTypes().length == args.length) return m.invoke(target, args);
            }
        } catch (Throwable t) {
            Log.w(TAG, name, t);
        }
        return null;
    }
}
