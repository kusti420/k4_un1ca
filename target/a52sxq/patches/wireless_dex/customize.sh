# Samsung DeX on the A52s: wireless only (Smart View / Miracast to a TV or monitor). See module.prop.
#
# How One UI 9 starts DeX on a phone (S26U, same code on this port):
#   QS tile "DeX" (launcher com.honeyspace.dexservice.DesktopModeTile) or
#   Settings > Connected devices > Samsung DeX > "Connect wirelessly" (DexModeSettingsFragment)
#     -> launcher com.sec.android.desktopmode.activity.connectivity.ConnectivityActivity (Wi-Fi Display scan list)
#     -> DisplayManager.semConnectWifiDisplay(SemWifiDisplayConfig mode 2, "wfd_sec_mirroring_mode=dex")
#     -> WifiDisplayAdapter: mode 2 = "wifi:desktop:" device that may host tasks (not mirror-only)
#     -> LogicalDisplay: external desktop flag -> RootWindowContainer.startSystemDecorations()
#     -> DexController.setExternalDesktopDisplayId(), launcher SecondaryLauncher + taskbar on the TV,
#        WMShell DesktopStateImpl.isDesktopModeSupportedOnDisplay() = true for it (projected desktop mode).
# All of that only needs desktop windowing on (sff.sh) and the stock aconfig flags (enable_desktop_windowing_mode,
# enable_projected_display_desktop_mode, enable_display_content_mode_management: all ENABLED/RO in the S26U system).
#
# What is A52s-specific: the two entry points are only offered when /sys/class/dp_sec/dex exists (Samsung DisplayPort
# driver; CONFIG_SEC_DISPLAYPORT is not set in the a52sxq kernel, the phone has no DP alt mode).
#   - SecSettings DexModePreferenceController: isWirelessDexOnlyDevice() || dp_sec/dex exists, else UNSUPPORTED (hidden).
#     isWirelessDexOnlyDevice() is hard-coded false; making it true is exactly this phone's situation: it shows the entry,
#     the wireless-only help text/image, and the top-level "Connected devices" summary. Its only other users hide
#     tablet/fold-only rows, which are hidden on a phone anyway.
#   - Launcher k6/b.g() ("DeX available") = desktop windowing && (dp_sec/dex exists || tablet without stand-alone DeX).
#     When false, the DeX tile toggles stand-alone desktop windowing on the phone screen (tablet behaviour; the phone
#     display cannot host desktops, config_canInternalDisplayHostDesktops=false) instead of opening the wireless list.
#     Make the launcher's lazy "Supports dp" check true. Its other users are the DeX routine action and the tile state.

DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk"
python3 - "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk" << 'PYEOF' || ABORT "Failed to show the Samsung DeX settings entry"
import glob, sys
f = glob.glob(sys.argv[1] + "/smali*/com/samsung/android/settings/desktop/ExternalDisplayUtils.smali")
assert len(f) == 1, "ExternalDisplayUtils: %d" % len(f)
s = open(f[0]).read()
SIG = ".method public static isWirelessDexOnlyDevice(Landroid/content/Context;)Z\n"
assert s.count(SIG) == 1, "isWirelessDexOnlyDevice: %d" % s.count(SIG)
start = s.index(SIG)
end = s.index(".end method", start)
body = s[start:end]
if "const/4 p0, 0x1\n" in body:
    print("  - isWirelessDexOnlyDevice() already true")
    sys.exit(0)
OLD = "    .locals 0\n\n    const/4 p0, 0x0\n\n    return p0\n"
assert body == SIG + OLD, "isWirelessDexOnlyDevice() is no longer a constant false:\n" + body
open(f[0], "w").write(s[:start] + SIG + OLD.replace("const/4 p0, 0x0", "const/4 p0, 0x1") + s[end:])
print("  - isWirelessDexOnlyDevice() -> true")
PYEOF
LOG "- Settings: Samsung DeX entry shown (wireless DeX only)"

DECODE_APK "system" "system/priv-app/TouchWizHome_2017/TouchWizHome_2017.apk"
python3 - "$APKTOOL_DIR/system/priv-app/TouchWizHome_2017/TouchWizHome_2017.apk" << 'PYEOF' || ABORT "Failed to point the launcher DeX tile at wireless DeX"
import glob, re, sys
pat = re.compile(r'(    const-string (v\d+), "/sys/class/dp_sec/dex"\n\n'
                 r'    invoke-direct \{(v\d+), \2\}, Ljava/io/File;-><init>\(Ljava/lang/String;\)V\n\n'
                 r'    invoke-virtual \{\3\}, Ljava/io/File;->exists\(\)Z\n\n'
                 r'    move-result (v\d+)\n)(\n    const/4 \4, 0x1\n)?'
                 r'(\n    if-nez \4, :cond_\w+\n\n    const-string v\d+, "Do not Supports dp"\n)')
hits = done = 0
for f in glob.glob(sys.argv[1] + "/smali*/**/*.smali", recursive=True):
    s = open(f).read()
    if '"/sys/class/dp_sec/dex"' not in s:
        continue
    found = pat.findall(s)
    assert len(found) <= 1, "%s: %d dp_sec checks" % (f, len(found))
    assert found, "%s: dp_sec/dex check no longer matches" % f
    hits += 1
    if found[0][4]:
        done += 1
        continue
    s = pat.sub(lambda m: m.group(1) + "\n    const/4 " + m.group(4) + ", 0x1\n" + m.group(6), s)
    open(f, "w").write(s)
assert hits == 1, "launcher dp_sec/dex checks: %d" % hits
print("  - launcher dp check already forced" if done else "  - launcher \"Supports dp\" -> true")
PYEOF
LOG "- Launcher: DeX tile opens the wireless DeX device list"
