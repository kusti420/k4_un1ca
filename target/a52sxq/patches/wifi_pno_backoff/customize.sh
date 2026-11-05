# See module.prop. Edit the shipped source overlay rather than adding a second RRO for com.android.wifi.resources:
# two product overlays of one target would depend on overlay priority order.
DECODE_APK "product" "overlay/WifiRROverlayApp.apk" || ABORT "wifi_pno_backoff: failed to decode WifiRROverlayApp.apk"
python3 - "$APKTOOL_DIR/product/overlay/WifiRROverlayApp.apk/res/values/integers.xml" << 'PYEOF' || ABORT "wifi_pno_backoff: failed to patch the PNO back-off"
import re, sys
p = sys.argv[1]; s = open(p).read()
for name in ("config_wifiPnoScanIterations", "config_wifiPnoScanIntervalMultiplier"):
    pat = r'(<integer name="%s">)(\d+)(</integer>)' % name
    m = re.search(pat, s)
    assert m, name + " not in the overlay"
    if m.group(2) != "3":
        print("  - %s %s -> 3 (stock A52s)" % (name, m.group(2)))
        s = re.sub(pat, r"\g<1>3\3", s, count=1)
    else:
        print("  - %s already 3" % name)
open(p, "w").write(s)
PYEOF
