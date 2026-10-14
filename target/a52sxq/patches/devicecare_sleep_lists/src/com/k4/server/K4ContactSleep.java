package com.k4.server;

import com.android.server.am.MARsPackageInfo;
import com.android.server.am.MARsPolicyManager;

/**
 * K4_UN1CA: contact-sync half of MARs' ImportantRoleFilter (filter 22).
 *
 * Stock MARs refuses deep sleep for every package that owns an account type with raw contacts, because deep sleep
 * (setApplicationEnabledSetting DISABLED_UNTIL_USED by "auto_disabler") made its authenticator vanish from the account
 * cache and the contacts provider then wiped that account's contacts. framework.jar RegisteredServicesCache now keeps
 * services of MARs-deep-sleeping packages registered (flag 0x20000000), so the user may deep sleep such apps:
 * - policy 7 (manual deep sleep check: canRestrict / canRestrictWithReason, Device Care's Add list): no objection;
 * - any other policy (auto deep sleep candidates, triggerAction re-disable): no objection only when the user put the
 *   app to deep sleep (maxLevel 4 and disableReason by user), so MARs keeps re-applying the user's choice after the app
 *   was opened; MARs' own automatic deep sleep still leaves these apps alone.
 * The system gallery role half of filter 22 is untouched (handled in ImportantRoleFilter before this is called).
 */
public final class K4ContactSleep {
    private K4ContactSleep() {}

    public static int contactFilter(int userId, int policy, String pkg) {
        if (policy == 7) return 0;
        try {
            synchronized (MARsPolicyManager.MARsLock) {
                MARsPackageInfo i = MARsPolicyManager.getMARsPackageInfo(
                        MARsPolicyManager.MARsPolicyManagerHolder.INSTANCE.mMARsTargetPackages, pkg, userId);
                if (i != null && i.maxLevel == 4 && MARsPolicyManager.isDisabledByUser(i.disableReason)) return 0;
            }
        } catch (Throwable ignored) {
        }
        return 22;
    }
}
