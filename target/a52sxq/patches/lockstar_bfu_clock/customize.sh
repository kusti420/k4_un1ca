# Owner's lock screen clock before the first unlock after a restart (see module.prop).
#
# Evidence (9.3.55 boot log, /mnt/B1/OneUi9/scratch/lock_bfu/logcat_boot4_9355.txt, SystemUI pid 3079):
#   SQLiteOpenHelperAdapter: query : cannot query in direct boot mode          <- AODService's own DB is CE
#   ProfileDataMediator: Return default profile (0)
#   GetClockItemImpl: storedData=LockProfileV3(... clockType=2 ... clockFontWeight=700 ...)
#   AodDataProvider: Installed lockStar. 900005000
#   ActivityThread: Failed to find provider info for com.samsung.systemui.lockstar.provider.LockScreenDataContent
#                   (user not unlocked)
#   AodDataProvider: call: primary result(error) - get, item, [item_data]
#   KeyguardClockProvider ... clockType=2, fontData=ClockFontData(fontType=0, ..., fontWeight=700)  <- default clock
# After the unlock (logcat_boot_9353.txt 09:50:04) the same request reaches LockStar ("merge result - get, item,
# item_data") and the clock item becomes clockType=2, presetFontIndex=800 (stretch font), fontWeight=0,
# fontHeights=[2.77, 2.69, ...], fontStretchEnabled=true, AdaptiveColor - the owner's clock.
#
# Code path (AODService 8.9.66.1 = the Galaxy Store copy running on the phone; its lock screen code runs inside
# SystemUI as the FACE_WIDGET / AOD plugins): AodDataProvider.call() computes the local answer from AODService's CE
# database, then, when LockStar >= 9.0 is installed, calls
# ContentResolver.call(content://com.samsung.systemui.lockstar.provider.LockScreenDataContent, method, arg, extras)
# and returns LockStar's merged answer; on any Throwable it returns the local answer (defaults before unlock).
# AODService is Samsung-signed and Store-updated, so it is not modified (same rule as patches/aod_brightness).
#
# Fix: framework.jar ContentResolver.call(String, String, String, Bundle) first asks
# com.k4.lockscreen.K4LockSnapshot.handles(authority) - true only for LockStar's authority inside the
# com.android.systemui process - and then lets K4LockSnapshot.call() answer: unlocked = real call + the answer to the
# read-only "get" requests (item, items, lock_data_bundle, all_item_keys) is stored in SystemUI's device-protected
# storage; locked = the stored answer for the identical request, or the stock call when there is none.
# The helper source is src/com/k4/lockscreen/K4LockSnapshot.java (src/build.sh regenerates smali/); it goes into the
# last framework.jar dex (classes6 is close to the 65536 method reference limit).
FRAMEWORK="system/framework/framework.jar"
HELPERS="$SRC_DIR/target/a52sxq/patches/lockstar_bfu_clock/smali/com/k4/lockscreen"

LOG "- Lock screen: keep the LockStar clock layout for the time before the first unlock"

DECODE_APK "system" "$FRAMEWORK" || ABORT "Failed to decode $FRAMEWORK"

python3 - "$APKTOOL_DIR/system/framework/framework.jar" "$HELPERS" << 'PYEOF' || ABORT "Failed to apply lockstar_bfu_clock"
import glob, os, re, shutil, sys
fw, helper_dir = sys.argv[1:3]
MARK = "# k4 lockstar_bfu_clock"
CLS = "Lcom/k4/lockscreen/K4LockSnapshot;"
HANDLES = CLS + "->handles(Ljava/lang/String;)Z"
CALL = CLS + "->call(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;"

# helper smali: must offer exactly the two entry points the hook calls
helpers = sorted(glob.glob(os.path.join(helper_dir, "*.smali")))
names = [os.path.basename(h) for h in helpers]
assert "K4LockSnapshot.smali" in names, "smali/com/k4/lockscreen/K4LockSnapshot.smali is missing"
main = open(os.path.join(helper_dir, "K4LockSnapshot.smali")).read()
assert re.search(r"^\.class public final " + re.escape(CLS) + r"$", main, re.M)
assert ".method public static blacklist handles(Ljava/lang/String;)Z" in main
assert ".method public static blacklist call(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;" in main

# the hook: ContentResolver.call(String authority, String method, String arg, Bundle extras)
hits = glob.glob(fw + "/smali*/android/content/ContentResolver.smali")
assert len(hits) == 1, hits
path = hits[0]
s = open(path).read()
sig = re.compile(r"^\.method public final (?:[\w-]+ )?call\(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
                 r"Landroid/os/Bundle;\)Landroid/os/Bundle;\n.*?^\.end method\n", re.M | re.S)
m = list(sig.finditer(s))
assert len(m) == 1, "ContentResolver.call(String, ...): %d" % len(m)
body = m[0].group(0)
if MARK in body:
    assert body.count(HANDLES) == 1 and body.count(CALL) == 1
    print("  - ContentResolver.call already hooked")
else:
    assert HANDLES not in body and CALL not in body
    loc = re.search(r"^    \.locals (\d+)$", body, re.M)
    assert loc and int(loc.group(1)) >= 1, "ContentResolver.call: unexpected .locals"
    # stock entry: requireNonNull(authority) / requireNonNull(method), then v0 = null and the mWrapped / provider
    # path. The hook goes between the two (v0 is written again right after it, p0-p4 untouched).
    anchor = ("    invoke-static {p2, v0}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;\n\n"
              "    const/4 v0, 0x0\n\n"
              "    :try_start_0\n"
              "    iget-object v1, p0, Landroid/content/ContentResolver;->mWrapped:Landroid/content/ContentInterface;\n")
    assert body.count(anchor) == 1, "ContentResolver.call: stock entry changed"
    assert body.index(anchor) < body.index("invoke-virtual {p0, p1}, Landroid/content/ContentResolver;->acquireProvider(Ljava/lang/String;)Landroid/content/IContentProvider;")
    head = anchor.split("\n\n")[0] + "\n\n"
    hook = ("    " + MARK + "\n"
            "    invoke-static {p1}, " + HANDLES + "\n\n"
            "    move-result v0\n\n"
            "    if-eqz v0, :k4_lock_snapshot_skip\n\n"
            "    invoke-static {p0, p1, p2, p3, p4}, " + CALL + "\n\n"
            "    move-result-object v0\n\n"
            "    return-object v0\n\n"
            "    :k4_lock_snapshot_skip\n")
    body = body.replace(anchor, head + hook + anchor[len(head):], 1)
    s = s[:m[0].start()] + body + s[m[0].end():]
    open(path, "w").write(s)
    print("  - hooked ContentResolver.call(String, String, String, Bundle)")

# helper classes -> last dex
dirs = [d for d in glob.glob(fw + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))]
assert dirs, "no smali_classesN in framework.jar"
last = max(dirs, key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
dst = os.path.join(last, "com", "k4", "lockscreen")
for old in glob.glob(fw + "/smali*/com/k4/lockscreen/K4LockSnapshot*.smali"):
    os.remove(old)
os.makedirs(dst, exist_ok=True)
for h in helpers:
    shutil.copyfile(h, os.path.join(dst, os.path.basename(h)))
print("  - %d K4LockSnapshot smali files -> %s" % (len(helpers), os.path.relpath(dst, fw)))
PYEOF

unset FRAMEWORK HELPERS
