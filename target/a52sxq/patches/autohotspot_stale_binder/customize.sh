# From the phone sweep of 2026-10-16 (P3, /mnt/B1/OneUi9/scratch/deepdive_1016/phone_sweep/log_autohotspot_deadobject.txt)
#
# SemAutohotspotServiceBind$MyHandler message 2 (CMD_UNBIND_MCF_AUTOHOTSPOT_SERVICE, sent on Bluetooth off and Samsung
# account logout) calls unbindService() and clears iSemAutohotspotMcfBinded, but leaves iSemAutohotspotMcfService set.
# onServiceDisconnected() is not called for a deliberate unbind, so the proxy stays. The unbound
# com.samsung.android.mcf.autohotspot process is then killed as an empty process ("Killing ...: empty #25") and every
# SemWifiServiceImpl.getWifiApBleScanDetail() -> SemAutohotspotServiceBind.getMcfScanDetail() call transacts on the
# dead binder (DeadObjectException + stack trace in system_server on each Wi-Fi picker refresh). The code is the
# same in the S26U firmware: a stock bug that shows up here because Bluetooth is usually off.
# Not rebinding while Bluetooth is off is intended (the bind handler refuses to bind without BT / account), so the fix
# is just to forget the proxy on unbind: getMcfScanDetail() returns an empty list for a null service.
DECODE_APK "system" "system/framework/semwifi-service.jar"
python3 - "$APKTOOL_DIR/system/framework/semwifi-service.jar" << 'PYEOF' || ABORT "Failed to clear the Auto Hotspot binder on unbind"
import glob, sys
A = sys.argv[1]
f = glob.glob(A + "/smali*/com/samsung/android/server/wifi/ap/mde/SemAutohotspotServiceBind$MyHandler.smali")
assert len(f) == 1, "MyHandler: %d" % len(f)
f = f[0]
s = open(f).read()
B = "Lcom/samsung/android/server/wifi/ap/mde/SemAutohotspotServiceBind;"
SVC = "%s->iSemAutohotspotMcfService:Lcom/samsung/android/mcf/autohotspot/ISemAutohotspotMcf;" % B
old = ("    invoke-virtual {v1, p1}, Landroid/content/Context;->unbindService(Landroid/content/ServiceConnection;)V\n\n"
       "    iget-object p0, p0, Lcom/samsung/android/server/wifi/ap/mde/SemAutohotspotServiceBind$MyHandler;->this$0:%s\n\n"
       "    iput-boolean v0, p0, %s->iSemAutohotspotMcfBinded:Z\n\n" % (B, B))
fix = "    const/4 v1, 0x0\n\n    iput-object v1, p0, %s\n\n" % SVC
if s.count(old + fix) == 1:
    print("semwifi-service.jar: Auto Hotspot unbind already clears the binder")
    sys.exit(0)
assert s.count(old) == 1, "unbind path: %d" % s.count(old)
assert SVC not in s, "MyHandler already touches iSemAutohotspotMcfService"
s = s.replace(old, old + fix)
open(f, "w").write(s)
PYEOF
LOG "- Auto Hotspot: MCF binder cleared on unbind (no DeadObjectException spam after the service process is killed)"
