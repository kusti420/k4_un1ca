# One UI Home: info/debug logging on the launcher's main thread during animations (see module.prop).
#
# com.honeyspace.common.log.LogTagBuildersKt.info/debug (7,722 info call sites) always build "HoneySpace." + TAG and
# call Log.i/Log.d. Field log 2026-10-16: 7,097 HoneySpace lines in ~10 minutes, bursts of 300-930 lines/s while
# opening Recents (RecentAdapter, TaskListViewModel, WallpaperBlurView, AnimationSession, ...) and per-frame lines from
# the blur applier (h4/f "apply(): progress=..."), CellLayoutBlurUpdater.updateBlur and GestureMotionDetector.onScroll.
# The four info/debug entry points now return unless `log.tag.HoneySpace` is D or lower (Log.isLoggable("HoneySpace",
# DEBUG); false by default). `adb shell setprop log.tag.HoneySpace D` turns them back on at runtime, no restart.
# warn/errorInfo/verbose/secure/infoToFile are unchanged.
#
# FastRecyclerView.updateScrollPosLog (twice per frame from swipeScrollToWithOverScroll during a home page swipe)
# String.format("(%d, %d)-", unboundedScroll, time) into a StringBuffer that is only printed as one info line at the end
# of the swipe; it now returns at once (that line just prints an empty list).
DECODE_APK "system" "system/priv-app/TouchWizHome_2017/TouchWizHome_2017.apk"
python3 - "$APKTOOL_DIR/system/priv-app/TouchWizHome_2017/TouchWizHome_2017.apk" << 'PYEOF' || ABORT "Failed to gate the launcher info logs"
import glob, re, sys
A = sys.argv[1]
MARK = "# k4 launcher_log_gate"

f = glob.glob(A + "/smali*/com/honeyspace/common/log/LogTagBuildersKt.smali")
assert len(f) == 1, f
f = f[0]
s = open(f).read()
if MARK in s:
    print("  - LogTagBuildersKt already gated")
else:
    gate = ("    %s: only with log.tag.HoneySpace <= D\n"
            "    const-string v0, \"HoneySpace\"\n\n"
            "    const/4 v1, 0x3\n\n"
            "    invoke-static {v0, v1}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z\n\n"
            "    move-result v0\n\n"
            "    if-nez v0, :k4_log_on\n\n"
            "    return-void\n\n"
            "    :k4_log_on\n") % MARK
    for name, call in (("info", "i"), ("debug", "d")):
        for sig in ("Lcom/honeyspace/common/log/LogTag;Ljava/lang/String;", "Ljava/lang/String;Ljava/lang/String;"):
            head = ".method public static final %s(%s)V\n    .locals 2\n\n" % (name, sig)
            assert s.count(head) == 1, "%s(%s)" % (name, sig)
            i = s.index(head)
            body = s[i:s.index(".end method\n", i)]
            # stock body: null checks, "HoneySpace." + tag, one Log.<call>, nothing else
            assert body.count("Landroid/util/Log;->") == 1 and \
                   body.count("Landroid/util/Log;->%s(Ljava/lang/String;Ljava/lang/String;)I" % call) == 1, (name, sig)
            assert body.count('const-string v1, "HoneySpace."') == 1, (name, sig)
            s = s.replace(head, head + gate, 1)
    open(f, "w").write(s)
    print("  - LogTagBuildersKt.info/debug: gated on log.tag.HoneySpace")

f = glob.glob(A + "/smali*/com/honeyspace/ui/common/FastRecyclerView.smali")
assert len(f) == 1, f
f = f[0]
s = open(f).read()
if MARK in s:
    print("  - FastRecyclerView.updateScrollPosLog already disabled")
    sys.exit(0)
head = ".method private final updateScrollPosLog()V\n    .locals 4\n\n"
assert s.count(head) == 1, "updateScrollPosLog"
i = s.index(head)
body = s[i:s.index(".end method\n", i)]
assert body.count('const-string v0, "(%d, %d)-"') == 1 and "->scrollPosDebug:Ljava/lang/StringBuffer;" in body, "scroll pos log body"
s = s.replace(head, head + "    %s: no String.format per scroll frame\n    return-void\n\n" % MARK, 1)
open(f, "w").write(s)
print("  - FastRecyclerView.updateScrollPosLog disabled")
PYEOF
