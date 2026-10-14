package com.android.server.am;
public class MARsPolicyManager {
    public static class Lock {}
    public static final Lock MARsLock = null;
    public MARsPkgMap mMARsTargetPackages;
    public static MARsPackageInfo getMARsPackageInfo(MARsPkgMap m, String p, int u) { return null; }
    public static boolean isDisabledByUser(int r) { return false; }
    public static abstract class MARsPolicyManagerHolder { public static final MARsPolicyManager INSTANCE = null; }
}
