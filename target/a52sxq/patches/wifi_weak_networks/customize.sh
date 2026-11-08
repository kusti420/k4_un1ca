# See module.prop. Lower Samsung's Wi-Fi list cut (SemWifiEntryFilter) from -78/-75 dBm to -88 dBm in both copies of
# wifitrackerlib: SecSettings (Settings > Connections > Wi-Fi) and SystemUI (quick panel Wi-Fi list). Only the list
# changes; the framework auto-join thresholds in WifiRROverlayApp stay as they are.
WEAK_RSSI="-0x58" # -88 dBm = the first step of config_wifiRssiLevelThresholds (one bar)
DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk" || ABORT "wifi_weak_networks: failed to decode SecSettings.apk"
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk" || ABORT "wifi_weak_networks: failed to decode SystemUI.apk"
python3 - "$WEAK_RSSI" \
    "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk" \
    "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "wifi_weak_networks: failed to patch SemWifiEntryFilter"
import glob, re, sys
new = sys.argv[1]
C = "Lcom/samsung/android/wifitrackerlib/SemWifiEntryFilter;"
for root in sys.argv[2:]:
    hits = glob.glob(root + "/smali*/com/samsung/android/wifitrackerlib/SemWifiEntryFilter.smali")
    assert len(hits) == 1, "%s: SemWifiEntryFilter.smali x%d" % (root, len(hits))
    f = hits[0]; s = open(f).read()
    app = root.rstrip("/").split("/")[-1]

    def method(sig):
        m = re.search(r"^\.method [^\n]*%s\n.*?^\.end method\n" % re.escape(sig), s, re.M | re.S)
        assert m, "%s: %s not found" % (app, sig)
        return m

    # updateRssiFilter(): the branch taken without Wi-Fi Labs (sem_wifi_developer_option_visible != 1)
    #   const/16 vX, -0x4e / iput vX, p0, ->mWeakSignalRssi:I ; const/16 vX, -0x4b / iput vX, p0, ->mWeakSignalRssi5Ghz:I
    m = method("updateRssiFilter()V"); body = m.group(0)
    done = 0
    for field, old in (("mWeakSignalRssi", "-0x4e"), ("mWeakSignalRssi5Ghz", "-0x4b")):
        pat = re.compile(r"( +const/16 (\w+), )(-0x[0-9a-f]+)(\n\n +iput \2, p0, %s->%s:I\n)" % (re.escape(C), field))
        found = pat.findall(body)
        assert len(found) == 1, "%s: %s default store x%d" % (app, field, len(found))
        cur = found[0][2]
        if cur == new:
            done += 1
            continue
        assert cur == old, "%s: %s default is %s, expected %s" % (app, field, cur, old)
        body = pat.sub(lambda x: x.group(1) + new + x.group(4), body, count=1)
    s = s[:m.start()] + body + s[m.end():]

    # <clinit>: Wi-Fi Labs filter levels {strong, default, all}. Make the default level (index 1, which
    # sec_wifi_developer_rssi_level falls back to) the same -88 dBm; index 0 (-73/-70) and 2 (-127) stay.
    m = method("<clinit>()V"); body = m.group(0)
    for field, old in (("SETTING_DEVELOPER_RSSI", "-0x4e"), ("SETTING_DEVELOPER_RSSI_5G", "-0x4b")):
        pat = re.compile(r"( +const/16 v0, -0x[0-9a-f]+\n\n +const/16 v1, )(-0x[0-9a-f]+)"
                         r"(\n\n(?: +const/16 v2, -0x7f\n\n)? +filled-new-array \{v0, v1, v2\}, \[I\n\n"
                         r" +move-result-object v0\n\n +sput-object v0, %s->%s:\[I\n)" % (re.escape(C), field))
        found = pat.findall(body)
        assert len(found) == 1, "%s: %s table x%d" % (app, field, len(found))
        cur = found[0][1]
        if cur == new:
            done += 1
            continue
        assert cur == old, "%s: %s[1] is %s, expected %s" % (app, field, cur, old)
        body = pat.sub(lambda x: x.group(1) + new + x.group(3), body, count=1)
    s = s[:m.start()] + body + s[m.end():]

    if done == 4:
        print("  - %s: already patched" % app)
    else:
        open(f, "w").write(s)
        print("  - %s: Wi-Fi list shows networks down to -88 dBm (was -78 dBm 2.4 GHz / -75 dBm 5 GHz)" % app)
PYEOF
LOG "- Wi-Fi list (Settings + quick panel): weak networks down to -88 dBm are shown"
