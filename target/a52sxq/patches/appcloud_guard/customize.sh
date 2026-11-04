SKIPUNZIP=1
# See module.prop. Two layers:
#  1. build time: keep PackageManager from ever scanning the stock /prism OOBE app pushers (AppCloud, Ignite,
#     App Center, My Apps, SFR Jeux, App Starter, Facebook/Instagram stubs) and strip every grant the source
#     firmware hands them by package name;
#  2. boot time: /system/bin/k4-appcloud-guard removes what an earlier ROM / the stock firmware left in /data.

# --- 1a. /system/etc/skipping_apk_exceptions.xml ------------------------------------------------------------
# services.jar PmLifecycleImpl.onInitPreparing() builds the "SkippingApks" list from the CSC's
# enforceskippingpackages.txt and then adds every <exception name="<apk dir>.apk"/> (no product= attribute =
# every product) of this file (SkippingApksExceptions.parseSkippingApkExceptions ->
# SkippingApks.addSkippingPackage). InstallPackageHelper skips a scanned app dir whose "<name>.apk" is on the
# list (isSkippingApk), before parsing, on every boot including the first one after a factory reset. The names
# are the APK dirs of Samsung's /prism (OXM multi-CSC set of the A52s) plus the pusher names Samsung's own
# per-CSC skip lists know for other regions (same exact-name semantics as Samsung's lists).
APPCLOUD_SKIP_APKS="
appcloud_oobe_samsungGlobal_BaseVersion_V6.0.0.2.apk
appcloud_oobe_samsungOrange.apk
appcloud_oobe_hutchison-release_V4.1.6.0.apk
appcloud_oobe_digicel-release_V2.17.3.apk
Ignite-telefonicaSamsungSamsungAgent_9.6.002-6452_release.apk
Ignite-timSamsungSamsungAgent_9.6.003-6473_release.apk
Ignite-SamsungAgent_7.0.135-5353_release.apk
Ignite-samsungSamsungAgent_9.6.003-6482_release.apk
Ignite-globeIgniteAgent_9.6.003-6474_release.apk
Ignite-singtelIgniteAgent_6.1.037-4944_release.apk
Ignite-telefonica.apk
Ignite-Tigo.apk
Ignite-attMexico.apk
Ignite-uscc.apk
IgniteVerizon.apk
Ignite_AIO.apk
com.dti.samsung_Ignite.apk
AppCenter_Orange.apk
MyApps-1.8.2-logoff-obson-prodSamsungRelease.apk
SFRJeux-9.0.2-logoff-obson-samsungRelease.apk
CombinedStarter-16.00.00(160005783)-build_5783-Release-signed-aligned-pd.apk
AppSelect_ATT.apk
MobileInstaller.apk
appnext.apk
MaftPreloadManagerAndroidApp-MovistarMX.apk
MaftPreloadManagerAndroidApp-TEF_LATAM.apk
instagram-stub.apk
instagram-stub-BR.apk
messenger-stub_27.2.0.apk
messenger-stub-BR.apk
"
APPCLOUD_SKIP_XML="$WORK_DIR/system/system/etc/skipping_apk_exceptions.xml"
[ -f "$APPCLOUD_SKIP_XML" ] || ABORT "appcloud_guard: ${APPCLOUD_SKIP_XML//$WORK_DIR/} is missing"
[ "$(grep -c "^</exceptions>" "$APPCLOUD_SKIP_XML")" = "1" ] || ABORT "appcloud_guard: unexpected ${APPCLOUD_SKIP_XML//$WORK_DIR/} layout"
APPCLOUD_SKIP_APKS="$APPCLOUD_SKIP_APKS" python3 - "$APPCLOUD_SKIP_XML" <<'PYEOF' || ABORT "appcloud_guard: failed to patch skipping_apk_exceptions.xml"
import os, sys
path = sys.argv[1]
src = open(path).read()
names = [n for n in os.environ["APPCLOUD_SKIP_APKS"].split("\n") if n]
rows = []
for n in names:
    if 'name="%s"' % n in src:
        continue
    rows.append('    <exception name="%s" />' % n)   # no product= attribute: skipped on every product
if rows:
    block = "\n    <!-- K4: stock /prism OOBE app pushers, never scanned (target/a52sxq/patches/appcloud_guard) -->\n" + "\n".join(rows) + "\n\n</exceptions>"
    src = src.replace("\n</exceptions>", block, 1)
    open(path, "w").write(src)
print("  - %d /prism pusher APK names added to the PackageManager skip list" % len(rows))
PYEOF
for n in $APPCLOUD_SKIP_APKS; do
    grep -qF "name=\"$n\"" "$APPCLOUD_SKIP_XML" || ABORT "appcloud_guard: $n missing from skipping_apk_exceptions.xml"
done
LOG "- PackageManager skips the /prism OOBE app pusher APKs (/system/etc/skipping_apk_exceptions.xml)"

# --- 1b. package-name grants of the source firmware ------------------------------------------------------------
# Exact package names (the stock /prism set of the A52s, the US/LATAM Aura/Ignite/AppLovin Array variants named
# by the same files, and the Facebook preload stub family); com.dti.* is matched as a whole (Digital Turbine).
APPCLOUD_PKGS="
com.aura.oobe.samsung.gl
com.aura.oobe.samsung
com.aura.oobe.att
com.aura.oobe.dish
com.aura.jet.att
com.ironsource.appcloud.oobe.hutchison
com.ironsource.appcloud.oobe
com.ironsrc.aura.tmo
com.ironsrc.aura.appmanager.tmo
com.LogiaGroup.LogiaDeck
com.digitalturbine.android.apps.news.att
com.applovin.array.apphub.samsung
com.array.deviceservices
com.orange.update
com.altice.android.myapps.samsung
com.sfr.android.sfrjeux.samsung
com.sfr.android.sfrjeux
de.telekom.tsc
com.dish.wireless.installer
com.sprint.w.installer
com.instagram.android
com.facebook.katana
com.facebook.orca
com.facebook.appmanager
com.facebook.services
com.facebook.system
"
APPCLOUD_PKG_RE="package=\"($(printf '%s\n' $APPCLOUD_PKGS | sed 's/\./\\./g' | paste -sd '|')|com\.dti\.[^\"]*)\""

_APPCLOUD_STRIP()
{
    # $1 = file (relative to $WORK_DIR), $2 = what the entries grant (for the log)
    local f="$WORK_DIR/$1" n
    [ -f "$f" ] || { LOG "- No $1 in this source"; return 0; }
    n="$(grep -c -E "$APPCLOUD_PKG_RE" "$f")"
    [ "$n" != "0" ] || { LOG "- $1: no pusher entries"; return 0; }
    sed -i -E "/$APPCLOUD_PKG_RE/d" "$f"
    [ "$(grep -c -E "$APPCLOUD_PKG_RE" "$f")" = "0" ] || ABORT "appcloud_guard: failed to strip $1"
    LOG "- $1: dropped $n pusher entries ($2)"
}

# InstallPackageHelper.processParseResult() refuses every system-scanned package that is not on this list
# ("Package is not in allowed list") when PMRune.PM_ALLOWED_SYSTEM_PRELOAD_APPS is set, i.e. on every
# non-factory build: second gate for the /prism pushers (by package name, after parsing).
_APPCLOUD_STRIP "system/system/etc/sysconfig/allowed-system-preload-apps.xml" "allowed to be installed from a system partition"
# Doze / Data saver exemptions
_APPCLOUD_STRIP "system/system/etc/permissions/platform.xml" "allow-in-power-save / allow-in-data-usage-save"
sed -i '/<!-- FaceBook -->/d' "$WORK_DIR/system/system/etc/permissions/platform.xml"
# deviceidle reviewed allow list (DozeRune.DOZE_ALLOWLIST_GATEKEEPER): entry plus its "Allowed :" review comments
python3 - "$WORK_DIR/system/system/etc/deviceidle/reviewed_allowlist.xml" "$APPCLOUD_PKG_RE" <<'PYEOF' || ABORT "appcloud_guard: failed to patch reviewed_allowlist.xml"
import os, re, sys
path, pkg_re = sys.argv[1], re.compile(sys.argv[2])
if not os.path.isfile(path):
    print("  - no deviceidle/reviewed_allowlist.xml in this source"); sys.exit(0)
lines = open(path).read().split("\n")
out, dropped = [], 0
for line in lines:
    if "<reviewed-in-power-save " in line and pkg_re.search(line):
        dropped += 1
        # the entry's own review comment block right above it (never a section header)
        while out and out[-1].strip().startswith("<!--") and re.search(r"Allowed :|Review(ed)? link|Detail reason", out[-1]):
            out.pop()
        continue
    out.append(line)
if dropped:
    open(path, "w").write("\n".join(out))
print("  - deviceidle/reviewed_allowlist.xml: dropped %d pusher entries (reviewed-in-power-save)" % dropped)
PYEOF
# default runtime-permission grants (POST_NOTIFICATIONS for Ignite / AppHub / Aura, b/242662883 b/238047865 b/237992875)
python3 - "$WORK_DIR/system/system/etc/default-permissions/default-permissions-platform.xml" "$APPCLOUD_PKG_RE" <<'PYEOF' || ABORT "appcloud_guard: failed to patch default-permissions-platform.xml"
import os, re, sys
path, pkg_re = sys.argv[1], re.compile(sys.argv[2])
if not os.path.isfile(path):
    print("  - no default-permissions-platform.xml in this source"); sys.exit(0)
src = open(path).read()
blocks = re.findall(r'(?:[ \t]*<!--[^\n]*-->\n)?[ \t]*<exception package="[^"]*">.*?</exception>\n', src, re.S)
dropped = 0
for b in blocks:
    m = re.search(r'<exception package="([^"]*)"', b)
    if m and pkg_re.search('package="%s"' % m.group(1)):
        src = src.replace(b, "", 1)
        dropped += 1
if dropped:
    open(path, "w").write(src)
print("  - default-permissions-platform.xml: dropped %d pusher exception blocks (POST_NOTIFICATIONS default grant)" % dropped)
PYEOF
# OMC default grants: Digital Turbine's LogiaDeck (VZW/VPP sales codes, "DTIgnite b/24273045") READ_PHONE_STATE
APPCLOUD_OMC_GRANTS="$WORK_DIR/system/system/etc/omc-default-permissions/DefaultGrantPermission.xml"
if [ -f "$APPCLOUD_OMC_GRANTS" ] && grep -q 'package name="com.LogiaGroup.LogiaDeck"' "$APPCLOUD_OMC_GRANTS"; then
    sed -i -e '/<!-- DTIgnite Buganizer ID/d' -e '/<package name="com.LogiaGroup.LogiaDeck">/,/<\/package>/d' "$APPCLOUD_OMC_GRANTS"
    grep -q 'LogiaDeck' "$APPCLOUD_OMC_GRANTS" && ABORT "appcloud_guard: failed to strip DefaultGrantPermission.xml"
    LOG "- omc-default-permissions/DefaultGrantPermission.xml: dropped the LogiaDeck (Digital Turbine) grant blocks"
fi

# --- 2. boot-time guard ---------------------------------------------------------------------------------------
EVAL "cp -f \"$MODPATH/k4-appcloud-guard\" \"$WORK_DIR/system/system/bin/k4-appcloud-guard\""
SET_METADATA "system" "system/bin/k4-appcloud-guard" 0 2000 755 "u:object_r:system_file:s0"
cat > "$WORK_DIR/system/system/etc/init/k4_appcloud_guard.rc" << 'RCEOF'
# OOBE app pusher removal (target/a52sxq/patches/appcloud_guard)
on property:sys.boot_completed=1
    start k4_appcloud_guard

service k4_appcloud_guard /system/bin/sh /system/bin/k4-appcloud-guard
    user root
    group root
    seclabel u:r:shell:s0
    oneshot
    disabled
RCEOF
SET_METADATA "system" "system/etc/init/k4_appcloud_guard.rc" 0 0 644 "u:object_r:system_file:s0"
LOG "- Stock /prism OOBE app pushers (AppCloud, Ignite, App Center, My Apps, SFR Jeux, App Starter, Facebook/Instagram stubs) are removed for the user at boot (k4-appcloud-guard)"

unset -f _APPCLOUD_STRIP
unset APPCLOUD_SKIP_APKS APPCLOUD_SKIP_XML APPCLOUD_PKGS APPCLOUD_PKG_RE APPCLOUD_OMC_GRANTS
