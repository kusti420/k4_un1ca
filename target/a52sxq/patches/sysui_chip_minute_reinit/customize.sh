# Status bar: the ongoing-activity chip controller is torn down and rebuilt whenever the Compose status bar recomposes
# (see module.prop). Field log 2026-10-16: at 19:08:00, 19:10:00, 19:11:00 ... the clock width changes
# (OngoingChipAdapter "updateEnableMaxWidth : 303 -:> 309"), StatusBarRootKt's composable lambda re-runs and calls
#   ongoingActivityController.initCapsuleLayout(phoneStatusBarView.findViewById(ongoing_activity_capsule), phoneStatusBarView)
# which unregisters ~10 listeners, cancels the icon-count job (logged as JobCancellationException), builds a new
# ChipAnimationController and LinearLayoutManager, re-sets the RecyclerView adapter, re-registers everything and runs
# updateOngoingList + Debug.getCallers: ~10-25 ms of SystemUI main thread at every minute boundary, chips or not.
# initCapsuleLayout now returns at once when the controller is already bound to the very same capsule view and status
# bar view and has its RecyclerView. A new status bar view (re-inflation, theme/density change) still re-initialises.
# The only other caller, configurationListener.onDisplayDeviceTypeChanged (re-init with the same views on purpose), is
# gated by BasicRune.BASIC_FOLDABLE_TYPE_FOLD, false on the A52s.
# The guard is inlined at the top of the method rather than added as a helper: smali_classes3 of this SystemUI is at
# ~65,528 of 65,535 method references (9.3.4x decode), so no new method or method reference is added.
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to patch the ongoing chip re-init"
import glob, re, sys
A = sys.argv[1]
OAC = "Lcom/android/systemui/statusbar/phone/ongoingactivity/OngoingActivityController;"
MARK = "# k4 sysui_chip_minute_reinit"

f = glob.glob(A + "/smali*/com/android/systemui/statusbar/phone/ongoingactivity/OngoingActivityController.smali")
assert len(f) == 1, f
f = f[0]
s = open(f).read()
if MARK in s:
    print("  - initCapsuleLayout already patched")
    sys.exit(0)
for fld in ("mParentView:Landroid/view/View;", "mStatusBar:Landroid/view/View;",
            "mCapsuleRecyclerView:Landroidx/recyclerview/widget/RecyclerView;"):
    assert s.count("\n.field public " + fld + "\n") == 1, fld
head = ".method public final initCapsuleLayout(Landroid/view/View;Landroid/view/View;)V\n    .locals 6\n\n"
assert s.count(head) == 1, "initCapsuleLayout head"
# v0 is free at method entry (the stock body starts with iget-object v0, ...ongoingChipAdapter)
assert s.count(head + "    iget-object v0, p0, " + OAC + "->ongoingChipAdapter:Ldagger/Lazy;\n") == 1, "stock first instruction"
guard = """    %(MARK)s: already bound to these views -> nothing to rebuild
    iget-object v0, p0, %(OAC)s->mParentView:Landroid/view/View;

    if-ne v0, p1, :k4_cap_init

    iget-object v0, p0, %(OAC)s->mStatusBar:Landroid/view/View;

    if-ne v0, p2, :k4_cap_init

    iget-object v0, p0, %(OAC)s->mCapsuleRecyclerView:Landroidx/recyclerview/widget/RecyclerView;

    if-eqz v0, :k4_cap_init

    return-void

    :k4_cap_init
""" % {"MARK": MARK, "OAC": OAC}
s = s.replace(head, head + guard, 1)
open(f, "w").write(s)
print("  - initCapsuleLayout: skipped when the capsule and status bar views are unchanged")
PYEOF
