# Lock screen: shade / quick panel closed by a swipe shows only the wallpaper for ~0.5 s before the clock, date,
# shortcuts and lock-screen status bar come back (tester report + 60 fps video + logcat, 2026-10-16).
#
# Flow (stock One UI 9 code, same on the S26U): pulling the shade down on the lock screen is status bar state
# SHADE_LOCKED. FaceWidgetContainerWrapper/KeyguardSecVisibilityHelper fade the clock container out and set it GONE,
# the bottom shortcuts and KeyguardStatusBar go to alpha 0. They only come back after the collapse animation has
# completely finished: onFlingEnd -> STATE_CLOSED -> post mMaybeHideExpandedRunnable -> post mHideExpandedRunnable ->
# ShadeControllerImpl.makeExpandedInvisible -> SecStatusBarKeyguardViewManager.reset -> setState(SHADE_LOCKED ->
# KEYGUARD) -> instant re-expand -> next layout/draw. Meanwhile the quick panel content (SecQuickSettingScene
# "[PanelAction] alpha") is 2 x fraction - 1, i.e. 0 from expansion 0.5 down, and the window blur follows the
# fraction, so everything below 0.5 is bare wallpaper.
# A swipe collapse with a secure lock (mCanDismissLockScreen false, still tracking) is animated with
# mFlingAnimationUtilsClosing: duration = 0.6 s x sqrt(distance / panel height) whenever the velocity-matched curve
# would be longer, with a slow-in tail. Tester log: release at expansion 0.87, vel -7074 px/s, fling 14:05:14.554 ->
# 15.123 (569 ms); panel content alpha 0 at 14.736 (fraction 0.475); 390 ms of fling left; KEYGUARD at 15.183;
# first keyguard frame 15.247 => ~510 ms of wallpaper only, then the clock pops in.
#
# Fix: for SHADE_LOCKED collapses with a velocity (= swipes), replace that curve by a linear one at the finger's
# speed: duration = 1000 x mExpandedHeight / |velocity| ms, clamped to 150..300 ms. No velocity discontinuity at
# release, no tail; the empty part becomes about half of <= 300 ms. Velocity-0 collapses (tap outside, back,
# `cmd statusbar collapse`) already use PANEL_CLOSE_ACCELERATED for 200-300 ms and are left alone, as are the
# unlocked shade (state SHADE) and the lock-screen swipe-up to the bouncer (state KEYGUARD).
# Inserted at the merge point after the collapse branch picked its curve and applied the collapseSpeedUpFactor,
# before mFixedDuration (tests) and the screen-off 1 ms override, so both still win.
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to shorten the SHADE_LOCKED collapse fling"
import glob, re, sys
A = sys.argv[1]
NPVC = "Lcom/android/systemui/shade/NotificationPanelViewController;"
MARK = "# k4 shade_locked_collapse"

f = glob.glob(A + "/smali*/com/android/systemui/shade/NotificationPanelViewController.smali")
assert len(f) == 1, f
f = f[0]
s = open(f).read()
m = re.search(r"^\.method public flingToHeight\(FZFFZ\)V\n.*?^\.end method\n", s, re.M | re.S)
assert m, "flingToHeight(FZFFZ)V"
body = m.group(0)
if MARK in body:
    print("  - flingToHeight already patched")
    sys.exit(0)

# The collapse branch: closing / dismissing / accelerated curve, then
#   if (vel == 0) setDuration(getDuration() / collapseSpeedUpFactor)
#   :cond  <- merge point
#   if (mFixedDuration != -1) setDuration(mFixedDuration)
# v0 = this, v2 = the ValueAnimator, v1/v3/v4 are rewritten right after the merge point.
assert body.count("->mFlingAnimationUtilsClosing:") == 1 and body.count("->mFlingAnimationUtilsDismissing:") == 1, "collapse curves"
assert body.count("Lcom/android/app/animation/Interpolators;->PANEL_CLOSE_ACCELERATED:") == 1, "accelerated close"
anchor = re.compile(
    r"(    invoke-virtual \{v2, v3, v4\}, Landroid/animation/ValueAnimator;->setDuration\(J\)Landroid/animation/ValueAnimator;\n\n"
    r"    :cond_\w+\n)"
    r"(    iget v1, v0, " + re.escape(NPVC) + r"->mFixedDuration:I\n\n"
    r"    const/4 v3, -0x1\n\n"
    r"    if-eq v1, v3, :cond_\w+\n\n"
    r"    int-to-long v3, v1\n)")
hits = anchor.findall(body)
assert len(hits) == 1, "merge point before mFixedDuration: %d" % len(hits)
# the speed-up division right before it must still use p1 (velocity) == 0
pre = body[:anchor.search(body).start()]
assert re.search(r"    cmpl-float v1, p1, v11\n\n    if-nez v1, :cond_\w+\n\n    invoke-virtual \{v2\}, Landroid/animation/ValueAnimator;->getDuration\(\)J\n", pre), "vel == 0 speed-up block"

ins = """\
    %(mark)s: SHADE_LOCKED swipe collapse -> linear at the finger's speed, 150..300 ms
    iget v1, v0, %(NPVC)s->mBarState:I

    const/4 v3, 0x2

    if-ne v1, v3, :cond_k4_slc_done

    move/from16 v1, p1

    invoke-static {v1}, Ljava/lang/Math;->abs(F)F

    move-result v1

    const/4 v3, 0x0

    cmpl-float v3, v1, v3

    if-eqz v3, :cond_k4_slc_done

    iget v3, v0, %(NPVC)s->mExpandedHeight:F

    const/high16 v4, 0x447a0000    # 1000.0f

    mul-float/2addr v3, v4

    div-float/2addr v3, v1

    const/high16 v4, 0x43160000    # 150.0f

    invoke-static {v3, v4}, Ljava/lang/Math;->max(FF)F

    move-result v1

    const/high16 v4, 0x43960000    # 300.0f

    invoke-static {v1, v4}, Ljava/lang/Math;->min(FF)F

    move-result v1

    float-to-long v3, v1

    invoke-virtual {v2, v3, v4}, Landroid/animation/ValueAnimator;->setDuration(J)Landroid/animation/ValueAnimator;

    sget-object v1, Lcom/android/app/animation/Interpolators;->LINEAR:Landroid/view/animation/Interpolator;

    invoke-virtual {v2, v1}, Landroid/animation/ValueAnimator;->setInterpolator(Landroid/animation/TimeInterpolator;)V

    :cond_k4_slc_done
""" % {"mark": MARK, "NPVC": NPVC}
new = anchor.sub(lambda g: g.group(1) + ins + g.group(2), body)
assert new.count(MARK) == 1
s = s.replace(body, new)
assert s.count(MARK) == 1
open(f, "w").write(s)
print("  - flingToHeight: SHADE_LOCKED swipe collapse linear, 150-300 ms")
PYEOF
LOG "- Lock screen: shade collapse from SHADE_LOCKED without the long empty fling tail"
