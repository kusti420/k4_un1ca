# AOD -> lock screen clock morph: SystemUI calls a plugin method that does not exist, every frame (see module.prop).
#
# SecLightRevealScrimHelper (LsRune.AOD_LIGHT_REVEAL, true here: AOD_FULLSCREEN + clocktransition) collects the 500 ms
# reveal animator and calls FaceWidgetContainerWrapper.setDarkAmounts(linear, reveal) on every frame, as do
# NotificationPanelViewController$StatusBarStateListener and PluginAODManager. setDarkAmounts does
#   try { plugin.setDarkAmounts(f1, f2) } catch (Throwable) { plugin.setDarkAmount(f2) }
# and neither the AODService the ROM ships (system/priv-app/AODService_v80) nor the 8.5.10 Store update implements
# PluginKeyguardStatusView.setDarkAmounts(FF): every call throws AbstractMethodError (allocation + message +
# fillInStackTrace over a deep coroutine stack) before falling back. Remember the plugin instance that threw an
# IncompatibleClassChangeError (AbstractMethodError / NoSuchMethodError) and call setDarkAmount(f2) directly for it from
# then on. A plugin that implements setDarkAmounts still gets it; any other exception still only falls back once.
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to patch FaceWidgetContainerWrapper.setDarkAmounts"
import glob, re, sys
A = sys.argv[1]
C = "Lcom/android/systemui/facewidget/plugin/FaceWidgetContainerWrapper;"
P = "Lcom/android/systemui/plugins/keyguardstatusview/PluginKeyguardStatusView;"
MARK = "# k4 sysui_aod_dark_amounts"

f = glob.glob(A + "/smali*/com/android/systemui/facewidget/plugin/FaceWidgetContainerWrapper.smali")
assert len(f) == 1, f
f = f[0]
s = open(f).read()
if MARK in s:
    print("  - setDarkAmounts already patched")
    sys.exit(0)

m = list(re.finditer(r"^\.method public final setDarkAmounts\(FF\)V\n.*?^\.end method\n", s, re.M | re.S))
assert len(m) == 1, "setDarkAmounts(FF)V: %d" % len(m)
m = m[0]
body = m.group(0)
# expected stock shape: one try { setDarkAmounts(p1, p2) } catchall -> setDarkAmount(p2) on the re-read field
assert body.count("->setDarkAmounts(FF)V") == 1 and body.count("->setDarkAmount(F)V") == 1, "calls"
assert body.count(".catchall ") == 1 and body.count("iget-object") == 2, "try/catch shape"
assert "->mPluginKeyguardStatusView:" + P in body, "plugin field"

new = """.method public final setDarkAmounts(FF)V
    .locals 2

    %(MARK)s: skip the AbstractMethodError for plugins without setDarkAmounts(FF)
    iget-object v0, p0, %(C)s->mPluginKeyguardStatusView:%(P)s

    if-eqz v0, :k4_ret

    iget-object v1, p0, %(C)s->k4NoDarkAmounts:%(P)s

    if-eq v1, v0, :k4_single

    :try_start_k4
    invoke-interface {v0, p1, p2}, %(P)s->setDarkAmounts(FF)V
    :try_end_k4
    .catchall {:try_start_k4 .. :try_end_k4} :catchall_k4

    return-void

    :catchall_k4
    move-exception v1

    instance-of v1, v1, Ljava/lang/IncompatibleClassChangeError;

    if-eqz v1, :k4_single

    iput-object v0, p0, %(C)s->k4NoDarkAmounts:%(P)s

    :k4_single
    invoke-interface {v0, p2}, %(P)s->setDarkAmount(F)V

    :k4_ret
    return-void
.end method
""" % {"MARK": MARK, "C": C, "P": P}
s = s[:m.start()] + new + s[m.end():]

anchor = ".field public mPluginKeyguardStatusView:" + P + "\n"
assert s.count(anchor) == 1, "field anchor"
s = s.replace(anchor, anchor + "\n.field public k4NoDarkAmounts:" + P + "\n", 1)
open(f, "w").write(s)
print("  - setDarkAmounts: no AbstractMethodError per frame")
PYEOF
