package com.samsung.android.sdhms;
import java.util.List;
public class SemAppRestrictionManager {
    public SemAppRestrictionManager(android.content.Context c) {}
    public boolean canRestrict(int t, String p, int u) { return false; }
    public long canRestrictWithReason(int t, String p, int u) { return 0; }
    public List<AppRestrictionInfo> getAllList() { return null; }
    public static class AppRestrictionInfo {
        public AppRestrictionInfo(String p, int u) {}
        public String getPackageName() { return null; }
        public int getUid() { return 0; }
    }
}
