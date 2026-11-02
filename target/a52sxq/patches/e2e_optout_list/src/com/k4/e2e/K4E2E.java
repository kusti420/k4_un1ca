package com.k4.e2e;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Packages forced out of edge-to-edge enforcement by the ROM (target/a52sxq/patches/e2e_optout_list).
 * Stock One UI's list (ActivityTaskManagerServiceExt.mForceOptOutEdgeToEdge) is a PackageSpecialManagementList that
 * SCPM's FoldablePackagePolicy refresh clears and refills ~40 s after boot and on every later refresh, so packages
 * added to it at boot do not stick. Both readers (WindowManagerService.isEdgeToEdgeDisabled, ActivityRecord's
 * constructor) call contains() here instead: the stock list OR /system/etc/k4/force_opt_out_e2e.txt.
 */
public final class K4E2E {
    private static final String LIST = "/system/etc/k4/force_opt_out_e2e.txt";
    private static volatile Set<String> sSet;

    private K4E2E() {}

    public static boolean contains(List list, Object pkg) {
        if (list != null && list.contains(pkg)) return true;
        return pkg != null && set().contains(pkg);
    }

    private static Set<String> set() {
        Set<String> s = sSet;
        if (s != null) return s;
        HashSet<String> out = new HashSet<>();
        try (BufferedReader r = new BufferedReader(new FileReader(LIST))) {
            String line;
            while ((line = r.readLine()) != null) {
                int hash = line.indexOf('#');
                if (hash >= 0) line = line.substring(0, hash);
                line = line.trim();
                if (!line.isEmpty()) out.add(line);
            }
        } catch (Throwable t) {
            // no list: nothing forced
        }
        s = Collections.unmodifiableSet(out);
        sSet = s;
        return s;
    }
}
