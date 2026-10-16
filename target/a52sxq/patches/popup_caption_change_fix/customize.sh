# Pop-up view (freeform) caption stays on top of a maximized app, under the status bar (tester video 2026-10-16:
# Calculator / Samsung Internet maximized from a pop-up window keep the back/minimize/maximize/close buttons at y=0).
#
# Cause: desktop windowing is off on this port (sff.sh SEC_FLOATING_FEATURE_COMMON_SUPPORT_DESKTOP_WINDOWING=FALSE +
# overlay config_isDesktopModeSupported=false), so WMShell's SwitchingProvider falls back from the empty
# Optional<DesktopModeWindowDecorViewModel> to the AOSP CaptionWindowDecorViewModel. Samsung changed
# FreeformTaskTransitionObserver.onTransitionReady: for TRANSIT_CHANGE (mode 6: maximize, resize, freeform -> fullscreen)
# it calls the 5-argument WindowDecorViewModel.onTaskChanging(info, leash, t, t, isFreeformTaskWithoutChange), an
# interface default that is an empty method. Only DesktopModeWindowDecorViewModel overrides it (its 4-argument variant
# just forwards to it); CaptionWindowDecorViewModel implements only the 4-argument one. The change is dropped, the
# decoration of a maximized task is never destroyed (onTaskVanished keeps it because the task still exists, and the
# task has left FreeformTaskListener, so no onTaskInfoChanged reaches the view model either).
#
# Fix: CaptionWindowDecorViewModel gets the 5-argument overload, forwarding to its 4-argument onTaskChanging, which is
# what AOSP calls for TRANSIT_CHANGE: shouldShowWindowDecor() is false for a fullscreen task on a fullscreen display,
# so the caption is destroyed; for a resized pop-up window it is relaid out.
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to apply the pop-up view caption change fix"
import glob, sys
A = sys.argv[1]
f = glob.glob(A + "/smali*/com/android/wm/shell/windowdecor/CaptionWindowDecorViewModel.smali")
assert len(f) == 1, "CaptionWindowDecorViewModel: %d" % len(f)
s = open(f[0]).read()
VM = "Lcom/android/wm/shell/windowdecor/CaptionWindowDecorViewModel;"
ARGS = "Landroid/app/ActivityManager$RunningTaskInfo;Landroid/view/SurfaceControl;Landroid/view/SurfaceControl$Transaction;Landroid/view/SurfaceControl$Transaction;"
FIVE = ".method public final onTaskChanging(" + ARGS + "Z)V"
FOUR = ".method public final onTaskChanging(" + ARGS + ")V"
if FIVE in s:
    print("CaptionWindowDecorViewModel: 5-argument onTaskChanging already present")
    sys.exit(0)
assert s.count(FOUR) == 1, "4-argument onTaskChanging: %d" % s.count(FOUR)
assert s.startswith(".class public " + VM), "class header changed"
assert ".implements Lcom/android/wm/shell/windowdecor/WindowDecorViewModel;" in s, "no longer a WindowDecorViewModel"
# The call site this is for: the TRANSIT_CHANGE branch of FreeformTaskTransitionObserver
o = glob.glob(A + "/smali*/com/android/wm/shell/freeform/FreeformTaskTransitionObserver.smali")
assert len(o) == 1, "FreeformTaskTransitionObserver: %d" % len(o)
assert ("Lcom/android/wm/shell/windowdecor/WindowDecorViewModel;->onTaskChanging(" + ARGS + "Z)V") in open(o[0]).read(), \
    "FreeformTaskTransitionObserver no longer calls the 5-argument onTaskChanging"
s = s.rstrip("\n") + "\n\n" + FIVE + """
    .locals 0

    invoke-virtual {p0, p1, p2, p3, p4}, """ + VM + "->onTaskChanging(" + ARGS + """)V

    return-void
.end method
"""
open(f[0], "w").write(s)
PYEOF
LOG "- SystemUI: pop-up view caption is removed on Maximize and follows resizes (CaptionWindowDecorViewModel CHANGE overload)"

# The close button of the same caption sat lower than the others: res/layout/caption_window_decor.xml gives back /
# minimize / maximize android:layout_gravity="end|center" but close_window none. The buttons (32 dp + 5 dp margins) are
# taller than the caption, so the centred ones shift up evenly while the top-aligned close button keeps its 5 dp top
# margin. AOSP centres all four; give close_window the same gravity.
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk/res/layout/caption_window_decor.xml" << 'PYEOF' || ABORT "Failed to centre the pop-up view close button"
import sys
p = sys.argv[1]; s = open(p).read()
old = '<Button android:id="@id/close_window" '
new = '<Button android:layout_gravity="end|center" android:id="@id/close_window" '
if new in s:
    print("  - caption close button already centred")
else:
    assert s.count(old) == 1, "close_window button: %d" % s.count(old)
    assert s.count('android:layout_gravity="end|center"') == 3, "the other caption buttons changed"
    open(p, "w").write(s.replace(old, new))
    print("  - caption close button centred like back / minimize / maximize")
PYEOF
LOG "- SystemUI: pop-up view caption close button vertically centred"
