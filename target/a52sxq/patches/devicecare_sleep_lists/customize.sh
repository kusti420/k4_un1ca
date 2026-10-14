# See module.prop. Device Care (com.samsung.android.lool) builds every sleeping-app Add list in jc/e.c(II) from the FAS
# cache that jc/e.e() loads from SemAppRestrictionManager.getAllList(); every add goes through ed/z.c(...).
# K4RestrictList.smali is generated from src/com/k4/devicecare/K4RestrictList.java (javac + d8 + baksmali, see src/).
DEVICECARE="system/priv-app/SmartManager_v5/SmartManager_v5.apk"
DECODE_APK "system" "$DEVICECARE" || ABORT "Failed to decode $DEVICECARE"
LOG "- Listing every restrictable app in the sleeping-app Add lists"
DST="$APKTOOL_DIR/system/${DEVICECARE//system\//}/smali/com/k4/devicecare"
mkdir -p "$DST"
cp -f "$SRC_DIR/target/a52sxq/patches/devicecare_sleep_lists/smali/com/k4/devicecare/K4RestrictList.smali" "$DST/"
SMALI_PATCH "system" "$DEVICECARE" \
    "smali/jc/e.smali" "replace" \
    'c(II)Ljava/util/ArrayList;' \
    'invoke-virtual {v2, p1, v5, v7}, Lcom/samsung/android/sdhms/SemAppRestrictionManager;->canRestrict(ILjava/lang/String;I)Z' \
    'invoke-static {v2, p1, v5, v7}, Lcom/k4/devicecare/K4RestrictList;->canList(Lcom/samsung/android/sdhms/SemAppRestrictionManager;ILjava/lang/String;I)Z' \
    || ABORT "Failed to patch the Add list filter"
SMALI_PATCH "system" "$DEVICECARE" \
    "smali/jc/e.smali" "replace" \
    'e()V' \
    'invoke-virtual {v0}, Lcom/samsung/android/sdhms/SemAppRestrictionManager;->getAllList()Ljava/util/List;' \
    'invoke-static {v0}, Lcom/k4/devicecare/K4RestrictList;->getAllList(Lcom/samsung/android/sdhms/SemAppRestrictionManager;)Ljava/util/List;' \
    || ABORT "Failed to patch the FAS cache loader"
python3 - "$APKTOOL_DIR/system/${DEVICECARE//system\//}" << 'PYEOF' || ABORT "Failed to hook the sleeping-app add handler"
import glob, sys
root = sys.argv[1]
# The helper reads kc.d.a (package) and kc.d.c (uid) directly, like Device Care's own code does.
d = glob.glob(root + "/smali*/kc/d.smali")
assert len(d) == 1, "kc/d.smali: %d" % len(d)
ds = open(d[0]).read()
assert ".field public a:Ljava/lang/String;" in ds and ".field public c:I" in ds, "kc.d fields changed"
f = glob.glob(root + "/smali*/ed/z.smali")
assert len(f) == 1, "ed/z.smali: %d" % len(f)
s = open(f[0]).read()
SIG = ".method public final c(Landroid/content/Context;Ljava/util/List;IZLjava/lang/String;)V\n"
HOOK = ("    invoke-static/range {p1 .. p4}, Lcom/k4/devicecare/K4RestrictList;->prepare("
        "Landroid/content/Context;Ljava/util/List;IZ)Ljava/util/List;\n\n    move-result-object p2\n\n")
start = s.index(SIG)
end = s.index(".end method", start)
body = s[start:end]
if "K4RestrictList;->prepare(" in body:
    print("ed/z.c: already hooked"); sys.exit(0)
lines = body.split("\n")
assert lines[1].strip().startswith(".locals"), "ed/z.c: no .locals line"
# insert right after ".locals N" and its blank line, before the first instruction
body = "\n".join(lines[:2]) + "\n\n" + HOOK + "\n".join(lines[2:]).lstrip("\n")
s = s[:start] + body + s[end:]
open(f[0], "w").write(s)
PYEOF
unset DEVICECARE DST

# v3 (owner decision 2026-10-14): apps that own a contact-syncing account may be put to deep sleep by the user.
# MARs' ImportantRoleFilter (filter 22) refused them because deep sleep = setApplicationEnabledSetting(
# DISABLED_UNTIL_USED, "auto_disabler"): RegisteredServicesCache then dropped the app's authenticator and sync adapter,
# AccountManager hid the account (getTypesForCaller only lists cached authenticator types) and the contacts provider
# deleted that account's raw contacts on its next account update ("removeDataOfAccount").
# 1. framework.jar RegisteredServicesCache.queryIntentServices adds 0x20000000: Samsung's PackageUserStateUtils.isEnabled
#    then still matches components of packages disabled-until-used by "auto_disabler" (MARs) - the same bit Samsung ORs
#    into activity queries so launchers keep MARs-disabled apps. Authenticators/sync adapters stay registered while the
#    app sleeps; binding them still fails (services are not resolvable), so the app is not woken.
# 2. services.jar ImportantRoleFilter.filter: the system gallery role half is unchanged; the contact-account half goes
#    through K4ContactSleep.contactFilter (no objection for the manual check, policy 7, and for packages the user put to
#    deep sleep; MARs' automatic deep sleep still skips these apps).
SERVICES="system/framework/services.jar"
FRAMEWORK="system/framework/framework.jar"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"
DECODE_APK "system" "$FRAMEWORK" || ABORT "Failed to decode $FRAMEWORK"
LOG "- Letting the user deep sleep contact-syncing apps without losing their account or contacts"
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" "$APKTOOL_DIR/system/${FRAMEWORK//system\//}" \
    "$SRC_DIR/target/a52sxq/patches/devicecare_sleep_lists/services/K4ContactSleep.smali" << 'PYEOF' || ABORT "Failed to allow deep sleep for contact-syncing apps"
import glob, os, re, shutil, sys
services, framework, helper = sys.argv[1:]

# framework.jar: RegisteredServicesCache.queryIntentServices(I) keeps MARs-deep-sleeping packages' services
hits = glob.glob(framework + "/smali*/android/content/pm/RegisteredServicesCache.smali")
assert len(hits) == 1, "RegisteredServicesCache: %d" % len(hits)
s = open(hits[0]).read()
start = s.index(".method protected greylist-max-o queryIntentServices(I)Ljava/util/List;")
end = s.index(".end method", start)
body = s[start:end]
MARK = "    # K4: system_server keeps services of MARs-deep-sleeping (auto_disabler) packages\n"
if MARK in body:
    print("  - RegisteredServicesCache.queryIntentServices already patched")
else:
    assert body.count("const v2, 0x8c0080\n") == 1 and body.count("const v2, 0xc0080\n") == 1, "queryIntentServices flags changed"
    call = "    invoke-virtual {v0, v1, v2, p1}, Landroid/content/pm/PackageManager;->queryIntentServicesAsUser(Landroid/content/Intent;II)Ljava/util/List;\n"
    anchor = "    new-instance v1, Landroid/content/Intent;\n"
    assert body.count(call) == 1 and body.count(anchor) == 1 and body.index(anchor) < body.index(call), "queryIntentServices body changed"
    assert "    .locals 3\n" in body, "queryIntentServices register count changed"
    add = (MARK +
           "    invoke-static {}, Landroid/os/Process;->myUid()I\n\n    move-result v1\n\n"
           "    add-int/lit16 v1, v1, -0x3e8\n\n    if-nez v1, :cond_k4_not_system\n\n"
           "    const/high16 v1, 0x20000000\n\n    or-int/2addr v2, v1\n\n    :cond_k4_not_system\n")
    body = body.replace(anchor, add + anchor)
    s = s[:start] + body + s[end:]
    open(hits[0], "w").write(s)
    print("  - RegisteredServicesCache.queryIntentServices: + 0x20000000 in system_server (MARs auto_disabler components)")

# services.jar: the flag only helps if Samsung's isEnabled still has the auto_disabler branch
u = glob.glob(services + "/smali*/com/android/server/pm/pkg/PackageUserStateUtils.smali")
assert len(u) == 1, "PackageUserStateUtils: %d" % len(u)
us = open(u[0]).read()
assert "const-wide/32 v5, 0x20000000" in us and '"auto_disabler"' in us, "auto_disabler branch in PackageUserStateUtils.isEnabled changed"

# services.jar: ImportantRoleFilter.filter -> contact-account half via K4ContactSleep
hits = glob.glob(services + "/smali*/com/android/server/am/mars/filter/filter/ImportantRoleFilter.smali")
assert len(hits) == 1, "ImportantRoleFilter: %d" % len(hits)
s = open(hits[0]).read()
sig = ".method public final filter(IIILjava/lang/String;)I\n"
start = s.index(sig)
end = s.index(".end method", start)
body = s[start:end]
if "K4ContactSleep" in body:
    print("  - ImportantRoleFilter.filter already patched")
else:
    for need in ("mSystemGalleryHolderList:Ljava/util/concurrent/ConcurrentHashMap;",
                 "mContactPermissionAppsList:Ljava/util/concurrent/ConcurrentHashMap;",
                 "Ljava/util/concurrent/CopyOnWriteArrayList;->contains(Ljava/lang/Object;)Z", "const/16 p3, 0x16"):
        assert body.count(need) == 1, "ImportantRoleFilter.filter changed: " + need
    assert len(re.findall(r"^    return ", body, re.M)) == 3, "ImportantRoleFilter.filter: return count changed"
    C = "Lcom/android/server/am/mars/filter/filter/ImportantRoleFilter;"
    new = sig + """    .locals 2

    iget-object v0, p0, %(C)s->mSystemGalleryHolderList:Ljava/util/concurrent/ConcurrentHashMap;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/util/concurrent/ConcurrentHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    if-eqz v0, :cond_k4_contacts

    invoke-virtual {v0, p4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_k4_contacts

    const/16 v0, 0x16

    return v0

    :cond_k4_contacts
    iget-object v0, p0, %(C)s->mContactPermissionAppsList:Ljava/util/concurrent/ConcurrentHashMap;

    invoke-virtual {v0, v1}, Ljava/util/concurrent/ConcurrentHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/util/concurrent/CopyOnWriteArrayList;

    if-eqz v0, :cond_k4_none

    invoke-virtual {v0, p4}, Ljava/util/concurrent/CopyOnWriteArrayList;->contains(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_k4_none

    invoke-static {p1, p3, p4}, Lcom/k4/server/K4ContactSleep;->contactFilter(IILjava/lang/String;)I

    move-result v0

    return v0

    :cond_k4_none
    const/4 v0, 0x0

    return v0
""" % {"C": C}
    s = s[:start] + new + s[end:]
    open(hits[0], "w").write(s)
    print("  - ImportantRoleFilter.filter: contact-account half -> K4ContactSleep.contactFilter")
dirs = sorted((d for d in glob.glob(services + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
dst = os.path.join(dirs[-1] if dirs else services + "/smali", "com/k4/server")
for old in glob.glob(services + "/smali*/com/k4/server/K4ContactSleep.smali"):
    os.remove(old)
os.makedirs(dst, exist_ok=True)
shutil.copyfile(helper, os.path.join(dst, "K4ContactSleep.smali"))
print("  - K4ContactSleep.smali -> %s" % os.path.relpath(dst, services))
PYEOF
unset SERVICES FRAMEWORK
