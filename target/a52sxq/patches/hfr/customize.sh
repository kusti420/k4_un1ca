# Adaptive motion smoothness is driven by SurfaceFlinger's own scheduler on this port: the One UI 9 (S26 Ultra)
# SurfaceFlinger ignores Samsung's HFR/passive mode hint (SurfaceComposerAIDL::notifyHFRmode only logs
# "VRR/HFR feature is not supported at SF, hfrMode : %d" and returns), so the stock "keep the rate stable at low
# brightness / low lux" protection never reaches the display and every 60 <-> 120 Hz switch is visible on the
# A52s AMOLED as a brightness/gamma flicker. With the old 250 ms idle / 300 ms touch timers SurfaceFlinger switched
# down after every short pause and back up on the next touch or frame, i.e. several times per scroll.
# Touch timer: every touch (PowerManagerService user activity -> SurfaceFlinger::notifyPowerBoost(INTERACTION) ->
# Scheduler::onTouchHint) boosts to the maximum of the primary range and keeps it for the timer length after the
# last touch. Idle timer: once nothing has been drawn for that long the scheduler drops to the policy minimum.
# So the panel switches at most once up per touch session and once down after it, instead of per gesture.
#
# When Adaptive drops to 60 Hz is NOT decided by these two timers but by a system_server vote (K4AdaptiveTouch,
# below): any frame resets the idle timer, and frames without layer votes would otherwise pick 120 Hz again. That
# delay is user-selectable (Settings > Display > "Adaptive smoothness delay", ADAPTIVE_IDLE_CHOICES_MS, default
# ADAPTIVE_IDLE_DEFAULT_MS = 2 s; 3 s fixed up to 9.3.15, 2 s fixed in 9.3.16) and lives in the system property
# ADAPTIVE_IDLE_PROP: persist.sys.* is system_prop (plat_property_contexts), which system_app (SecSettings) may set
# and system_server reads without a Settings provider call under the PowerManagerService lock.
# The SurfaceFlinger timers are ro.surface_flinger.* props read once when it starts, so they cannot follow the
# setting; they only have to outlast the longest choice: until the vote arrives the touch boost keeps 120 Hz, and
# once the vote has made the primary range single-rate [60, 60] the same touch boost ("rank the primary range
# descending") yields 60 Hz, so an earlier vote cannot bounce back. 500 ms on top of the longest choice keeps the
# timer expiry and the vote from racing when both would otherwise fall on the same instant.
ADAPTIVE_IDLE_PROP="persist.sys.k4.adaptive_idle_ms"
ADAPTIVE_IDLE_CHOICES_MS="1000 1500 2000 2500 3000"
ADAPTIVE_IDLE_DEFAULT_MS=2000
ADAPTIVE_IDLE_MIN_MS="$(tr " " "\n" <<< "$ADAPTIVE_IDLE_CHOICES_MS" | sort -n | head -n 1)"
ADAPTIVE_IDLE_MAX_MS="$(tr " " "\n" <<< "$ADAPTIVE_IDLE_CHOICES_MS" | sort -n | tail -n 1)"
[[ "$ADAPTIVE_IDLE_MIN_MS" =~ ^[1-9][0-9]*$ ]] && [[ "$ADAPTIVE_IDLE_MAX_MS" =~ ^[1-9][0-9]*$ ]] && \
    [ "$ADAPTIVE_IDLE_MIN_MS" -le "$ADAPTIVE_IDLE_DEFAULT_MS" ] && [ "$ADAPTIVE_IDLE_DEFAULT_MS" -le "$ADAPTIVE_IDLE_MAX_MS" ] && \
    grep -q -w "$ADAPTIVE_IDLE_DEFAULT_MS" <<< "$ADAPTIVE_IDLE_CHOICES_MS" || \
    ABORT "hfr: bad Adaptive delay choices \"$ADAPTIVE_IDLE_CHOICES_MS\" (default $ADAPTIVE_IDLE_DEFAULT_MS)"
# https://android.googlesource.com/platform/frameworks/native/+/refs/tags/android-16.0.0_r2/services/surfaceflinger/Scheduler/RefreshRateSelector.h#314
IDLE_TIMER_MS=$((ADAPTIVE_IDLE_MAX_MS + 500))
# https://android.googlesource.com/platform/frameworks/native/+/refs/tags/android-16.0.0_r2/services/surfaceflinger/sysprop/SurfaceFlingerProperties.sysprop#346
TOUCH_TIMER_MS=$((ADAPTIVE_IDLE_MAX_MS + 500))

SET_PROP "vendor" "ro.surface_flinger.use_content_detection_for_refresh_rate" "true"
LOG "- Adding \"ro.surface_flinger.set_idle_timer_ms\" prop with \"$IDLE_TIMER_MS\" in /vendor/default.prop"
EVAL "sed -i \"/use_content_detection/a ro.surface_flinger.set_idle_timer_ms=$IDLE_TIMER_MS\" \"$WORK_DIR/vendor/default.prop\""
LOG "- Adding \"ro.surface_flinger.set_touch_timer_ms\" prop with \"$TOUCH_TIMER_MS\" in /vendor/default.prop"
EVAL "sed -i \"/set_idle_timer_ms/a ro.surface_flinger.set_touch_timer_ms=$TOUCH_TIMER_MS\" \"$WORK_DIR/vendor/default.prop\""
LOG "- Replacing \"ro.surface_flinger.enable_frame_rate_override\" prop with \"true\" in /vendor/default.prop"
EVAL "sed -i \"/enable_frame_rate_override/d\" \"$WORK_DIR/vendor/default.prop\""
EVAL "sed -i \"/persist.sys.usb.config/i ro.surface_flinger.enable_frame_rate_override=true\" \"$WORK_DIR/vendor/default.prop\""

# The source SurfaceFlinger's getKernelIdleTimerController() always answers "Sysprop" for the primary display
# (an LTPO panel whose kernel/panel driver drops the refresh rate on idle by itself), so SurfaceFlinger never runs
# its own idle timer and Adaptive mode sits at the maximum rate whenever no layer votes otherwise. The A52s panel
# has no kernel idle timer: turn that `b.ne` into an unconditional branch so the AOSP path (HIDL composer reports
# no kernel idle timer -> SurfaceFlinger's own set_idle_timer_ms timer) is taken.
# Samsung's addition in SurfaceFlinger::getKernelIdleTimerProperties(PhysicalDisplayId):
#     cmp  x20, x0                      ; displayId == primary display id?
#     b.ne <AOSP path>                  ; <- patched to `b <AOSP path>`
#     adrp/add "SurfaceFlinger", adrp/add "Enabling KernelIdleTimer for main display"; __android_log_print
#     return {KernelIdleTimerController::Sysprop, timeout}
# Located by pattern, not offset (Fold8 F976B: 0x546d08, S25 S931B: 0x5465a0): the only ADRP+ADD reference to the
# log string, then the closest preceding `b.ne` (within 8 instructions, directly after a 64-bit `cmp`) that jumps
# forward past the log call. Anything else aborts.
SF="$WORK_DIR/system/system/bin/surfaceflinger"
if [ -f "$SF" ]; then
    LOG "- Disabling the kernel idle timer controller in /system/bin/surfaceflinger"
    python3 - "$SF" << 'PYEOF' || ABORT "Failed to patch the kernel idle timer controller in surfaceflinger"
import struct, sys
from array import array
p = sys.argv[1]
d = bytearray(open(p, "rb").read())
MSG = b"Enabling KernelIdleTimer for main display"

def segments():
    phoff = struct.unpack_from("<Q", d, 0x20)[0]
    phentsize, phnum = struct.unpack_from("<HH", d, 0x36)
    for i in range(phnum):
        p_type, p_flags, off, va, _, filesz, _, _ = struct.unpack_from("<IIQQQQQQ", d, phoff + i * phentsize)
        if p_type == 1:
            yield p_flags, off, va, filesz

hits, i = [], -1
while True:
    i = d.find(MSG + b"\0", i + 1)
    if i < 0:
        break
    if i == 0 or d[i - 1] == 0:
        hits.append(i)
assert len(hits) == 1, "log string: %d copies" % len(hits)
so = hits[0]
tva = next(so - off + va for _, off, va, fs in segments() if off <= so < off + fs)

refs = []   # (file offset of ADRP, file offset of ADD)
for flags, off, va, fs in segments():
    if not flags & 1:
        continue
    n = fs // 4
    w = array("I", bytes(d[off:off + n * 4]))
    if sys.byteorder != "little":
        w.byteswap()
    for i in range(n):
        x = w[i]
        if x & 0x9F000000 != 0x90000000:
            continue
        rd = x & 31
        imm = ((x >> 29) & 3) | (((x >> 5) & 0x7FFFF) << 2)
        if imm & (1 << 20):
            imm -= 1 << 21
        if ((va + 4 * i) & ~0xFFF) + (imm << 12) != tva & ~0xFFF:
            continue
        for k in range(i + 1, min(n, i + 16)):
            y = w[k]
            if y & 0xFFC00000 == 0x91000000 and (y >> 5) & 31 == rd and (y >> 10) & 0xFFF == tva & 0xFFF:
                refs.append((off + 4 * i, off + 4 * k))
            if y & 0x9F00001F == 0x90000000 | rd:
                break
assert len(refs) == 1, "references to the log string: %d" % len(refs)
adrp = refs[0][0]

W = lambda o: struct.unpack_from("<I", d, o)[0]
site = None
for k in range(1, 9):
    o = adrp - 4 * k
    x = W(o)
    if x & 0xFF00001F == 0x54000001:                                   # b.ne
        rel = ((x >> 5) & 0x7FFFF) << 2
        rel -= (1 << 21) if rel & (1 << 20) else 0
        site, kind = (o, rel), "bne"
        break
    if x & 0xFC000000 == 0x14000000:                                   # b (already patched)
        rel = (x & 0x3FFFFFF) << 2
        rel -= (1 << 28) if rel & (1 << 27) else 0
        site, kind = (o, rel), "b"
        break
assert site, "no b.ne before the log string reference at 0x%x" % adrp
o, rel = site
assert rel > (adrp - o) + 4, "branch at 0x%x does not skip the log/return block" % o
assert W(o - 4) & 0xFF20001F == 0xEB00001F, "no `cmp Xn, Xm` before the branch at 0x%x" % o   # subs xzr, Xn, Xm
if kind == "b":
    print("already patched at 0x%x" % o)
else:
    struct.pack_into("<I", d, o, 0x14000000 | ((rel >> 2) & 0x3FFFFFF))
    open(p, "wb").write(d)
    print("b.ne -> b at 0x%x (target +0x%x)" % (o, rel))
PYEOF
fi

# Motion smoothness modes (Settings.Secure refresh_rate_mode), enforced in system_server by
# RefreshRateController.updateRefreshRateModeLocked() as a PRIORITY_REFRESH_RATE_MODE vote (above app requests):
#   0 Standard -> normal-speed rates [60, 60]: single rate, SurfaceFlinger cannot switch (locked 60 Hz)
#   1 Adaptive -> high-speed rates [60, 120]: SurfaceFlinger picks within it (touch/idle timers above)
#   2 High (REFRESH_RATE_MODE_ALWAYS) -> on seamless panels the source votes [60, 120] exactly like Adaptive;
#     Samsung only offers it on switchable (HFR mode 1) panels, where it means a fixed maximum. Vote
#     [max, max] for it instead, so High is a single-rate 120 Hz policy (Vote.forPolicyRate(120, 120) also
#     disables refresh-rate switching) on the A52s too.
SERVICES="system/framework/services.jar"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"
LOG "- Making refresh_rate_mode 2 (High) a fixed maximum refresh rate vote in RefreshRateController"
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" << 'PYEOF' || ABORT "Failed to patch RefreshRateController"
import glob, re, sys
hits = glob.glob(sys.argv[1] + "/smali*/com/android/server/display/mode/RefreshRateController.smali")
assert len(hits) == 1, "RefreshRateController: %d" % len(hits)
f = hits[0]
s = open(f).read()
if ":cond_unica_rr_always" in s:
    print("  - already patched"); sys.exit(0)
m = re.search(r"^\.method public final updateRefreshRateModeLocked\(Z\)V\n.*?^\.end method\n", s, re.M | re.S)
assert m, "updateRefreshRateModeLocked(Z)V"
body = m.group(0)
# if (mode == 0) normal-speed vote; else if (mode == 1 || mode == 2) high-speed min..max vote; else null
branch = "    const/4 v3, 0x2\n\n    if-eq v0, v3, :cond_3\n"
assert body.count(branch) == 1, "mode 2 branch"
cfg = "Lcom/android/server/display/mode/RefreshRateController;->mConfig:Lcom/samsung/android/hardware/display/RefreshRateConfig;"
hs = re.search(
    r"\n    :cond_3\n    iget-object v0, p0, " + re.escape(cfg) + r"\n\n"
    r"    invoke-virtual \{v0\}, (Lcom/samsung/android/hardware/display/RefreshRateConfig;->getHighSpeedRefreshRates\(\)L[^;]+;)\n\n"
    r"    move-result-object v0\n\n"
    r"    invoke-virtual \{v0\}, (L[^;]+;)->min\(\)I\n"
    r".*?"
    r"    invoke-static \{v0, v3\}, (Lcom/android/server/display/mode/Vote;->forPolicyRate\(FF\)Lcom/android/server/display/mode/Vote;)\n\n"
    r"    move-result-object v0\n\n"
    r"    goto :goto_3\n", body, re.S)
assert hs and body.count("\n    :cond_3\n") == 1, "high-speed vote block"
always = """
    :cond_unica_rr_always
    iget-object v0, p0, %s

    invoke-virtual {v0}, %s

    move-result-object v0

    invoke-virtual {v0}, %s->max()I

    move-result v0

    int-to-float v0, v0

    invoke-static {v0, v0}, %s

    move-result-object v0

    goto :goto_3
""" % (cfg, hs.group(1), hs.group(2), hs.group(3))
new = body[:hs.end()] + always + body[hs.end():]
new = new.replace(branch, "    const/4 v3, 0x2\n\n    if-eq v0, v3, :cond_unica_rr_always\n")
open(f, "w").write(s[:m.start()] + new + s[m.end():])
print("  - refresh_rate_mode 2 -> forPolicyRate(max, max)")
PYEOF

# Adaptive = 120 Hz while touched, 60 Hz from the chosen delay (1-3 s, default 2 s) after the last touch, decided
# in system_server.
# SurfaceFlinger alone cannot do this: every client transaction resets its idle timer, and a frame whose layers
# carry no usable vote lands in RefreshRateSelector's "No layers with votes" branch, which ranks the primary
# range descending, i.e. picks 120 Hz. On this non-VRR panel the View toolkit's frame-rate categories are
# dropped (frame_rate_category_mrr is off), so ordinary UI frames - here a single status bar frame every few
# seconds while idle on the home screen, "VRI-StatusBar ... voted NoVote" -> "No layers with votes - choose 120.00 Hz"
# right after each "Idle - choose 60.00 Hz" - push the panel back to 120 Hz, a visible 60 <-> 120 Hz flicker.
# Fix it in DisplayModeDirector instead: K4AdaptiveTouch votes the minimum high-speed rate [60, 60] at
# PRIORITY_FIXED_REFRESH_RATE (8) that delay after the last user-activity power boost, and removes the vote on the next
# boost. The boost is the one PowerManagerService.userActivityNoUpdateLocked() already sends for touches
# (nativeSetPowerBoost(INTERACTION) -> SurfaceFlinger::notifyPowerBoost -> the touch timer above), so both
# sides see the same touches. While the vote stands the primary range is single-rate 60 Hz, so the same
# "No layers with votes" ranking now yields 60 Hz, and since priority 8 is below the app-request cutoff (9) the
# app-request range stays [60, 120], so a focused layer with an explicit setFrameRate() vote (a game asking for
# 120 Hz) still gets it. On touch the vote goes away, SurfaceFlinger re-ranks with its touch signal and switches
# to 120 Hz; it holds there until the delay after the last touch has passed. The delay is read from
# ADAPTIVE_IDLE_PROP on every boost (a lock-free property lookup; no Settings provider call under the
# PowerManagerService lock), clamped to the shortest/longest choice, so a new value applies from the next touch
# without a reboot; unset or unparsable means the default. High/Standard (and any higher vote: tokens, UDFPS,
# thermal, power saving) override or clear it. RefreshRateController.updateRefreshRateModeLocked() arms the vote
# for refresh_rate_mode 1 only. In refresh_rate_mode 2 the slot holds a render rate floor instead (see the class
# comment): the High mode vote fixes the panel at 120 Hz but leaves the render range [0, 120].
LOG "- Holding Adaptive at 60 Hz from $ADAPTIVE_IDLE_MIN_MS-$ADAPTIVE_IDLE_MAX_MS ms (default $ADAPTIVE_IDLE_DEFAULT_MS, $ADAPTIVE_IDLE_PROP) after the last touch (K4AdaptiveTouch)"
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" "$ADAPTIVE_IDLE_PROP" "$ADAPTIVE_IDLE_MIN_MS" "$ADAPTIVE_IDLE_DEFAULT_MS" \
    "$ADAPTIVE_IDLE_MAX_MS" << 'PYEOF' || ABORT "Failed to add the Adaptive touch vote"
import glob, os, re, sys
root = sys.argv[1]
IDLE_PROP = sys.argv[2]
IDLE_MIN, IDLE_DEFAULT, IDLE_MAX = (int(a) for a in sys.argv[3:6])
assert re.fullmatch(r"persist\.sys\.[a-z0-9_.]+", IDLE_PROP) and len(IDLE_PROP) < 92, IDLE_PROP
assert 0 < IDLE_MIN <= IDLE_DEFAULT <= IDLE_MAX <= 0x7fff, (IDLE_MIN, IDLE_DEFAULT, IDLE_MAX)

def one(rel):
    hits = glob.glob(root + "/smali*/" + rel)
    assert len(hits) == 1, "%s: %d" % (rel, len(hits))
    return hits[0]

rrc = one("com/android/server/display/mode/RefreshRateController.smali")
pms = one("com/android/server/power/PowerManagerService.smali")
if glob.glob(root + "/smali*/com/android/server/display/mode/K4AdaptiveTouch.smali"):
    print("  - already patched"); sys.exit(0)

RRC = "Lcom/android/server/display/mode/RefreshRateController;"
CFG = "Lcom/samsung/android/hardware/display/RefreshRateConfig;"
K4 = "Lcom/android/server/display/mode/K4AdaptiveTouch;"
s = open(rrc).read()
for need in (".field public static mHandler:Lcom/android/server/display/DisplayManagerService$DisplayManagerHandler;",
             ".field public static mVotesStorage:Lcom/android/server/display/mode/VotesStorage;",
             ".field public final mConfig:" + CFG,
             ".field public final mIsExtraBuiltinScreen:Z"):
    assert need in s, need
hs = re.search(r"invoke-virtual \{v\d+\}, (" + re.escape(CFG) + r"->getHighSpeedRefreshRates\(\)L[^;]+;)\n\n"
               r"    move-result-object v\d+\n\n"
               r"    invoke-virtual \{v\d+\}, (L[^;]+;)->min\(\)I", s)
assert hs, "getHighSpeedRefreshRates().min()"

# 1. RefreshRateController.updateRefreshRateModeLocked(Z): hand every refresh_rate_mode change (v0 = new mode) to
#    K4AdaptiveTouch right before the PRIORITY_REFRESH_RATE_MODE vote is built
m = re.search(r"^\.method public final updateRefreshRateModeLocked\(Z\)V\n.*?^\.end method\n", s, re.M | re.S)
assert m, "updateRefreshRateModeLocked(Z)V"
body = m.group(0)
anchor = re.findall(r"\n    invoke-virtual \{p1, v0\}, Ljava/util/concurrent/atomic/AtomicInteger;->set\(I\)V\n"
                    r".*?\n(    sget-object p1, " + re.escape(RRC + "->mVotesStorage:Lcom/android/server/display/mode/VotesStorage;") +
                    r"\n\n    if-eqz v0, :cond_\w+\n)", body, re.S)
assert len(anchor) == 1, "mode vote anchor: %d" % len(anchor)
body = body.replace(anchor[0], "    invoke-static {p0, v0}, %s->onRefreshRateMode(%sI)V\n\n" % (K4, RRC) + anchor[0], 1)
s = s[:m.start()] + body + s[m.end():]
open(rrc, "w").write(s)

# 2. PowerManagerService.userActivityNoUpdateLocked(PowerGroup, ...): every time it sends the INTERACTION power boost
#    (the same call that reaches SurfaceFlinger::notifyPowerBoost -> its touch timer), tell K4AdaptiveTouch too
p = open(pms).read()
m = re.search(r"^\.method public final userActivityNoUpdateLocked\(Lcom/android/server/power/PowerGroup;JIII\)Z\n.*?^\.end method\n",
              p, re.M | re.S)
assert m, "userActivityNoUpdateLocked(PowerGroup...)"
body = m.group(0)
boost = re.findall(r"\n    invoke-static \{v\d+, v\d+\}, Lcom/android/server/power/PowerManagerService;->-\$\$Nest\$smnativeSetPowerBoost\(II\)V\n", body)
assert len(boost) == 1, "INTERACTION boost: %d" % len(boost)
body = body.replace(boost[0], boost[0] + "\n    invoke-static {}, %s->onUserActivity()V\n" % K4, 1)
p = p[:m.start()] + body + p[m.end():]
open(pms, "w").write(p)

# 3. The helper (classes2.dex has more method-id headroom than classes.dex)
os.makedirs(root + "/smali_classes2/com/android/server/display/mode", exist_ok=True)
open(root + "/smali_classes2/com/android/server/display/mode/K4AdaptiveTouch.smali", "w").write("""\
.class public final %(K4)s
.super Ljava/lang/Object;
.source "K4AdaptiveTouch.java"

# interfaces
.implements Ljava/lang/Runnable;


# Adaptive motion smoothness = 120 Hz while touched, 60 Hz from idleDelayMs() after the last touch.
# A PRIORITY_FIXED_REFRESH_RATE (8) vote for the minimum high-speed rate [60, 60] is placed that long after the last
# user-activity power boost and removed on the next one. Priority 8 is below the app-request cutoff (9), so it
# only narrows the primary range: SurfaceFlinger cannot pick 120 Hz for frames that carry no vote (its
# "No layers with votes -> max" rule), while focused layers with an explicit setFrameRate() vote (games) still
# get the app-request range, and every higher vote (High/Standard mode, tokens, UDFPS, thermal, power saving)
# overrides it. The slot belongs to Samsung's seamless opt-out passive mode, which is off on this device
# (CoreRune.FW_VRR_SEAMLESS_OPTOUT_PASSIVE); if it ever gets enabled the vote is left to Samsung.
#
# High = 120 Hz panel AND 120 fps rendering. The mode vote only fixes the physical rate; with frame rate override
# on, SurfaceFlinger still lowers the render rate by content detection once its touch timer runs out (60 fps, or
# 40 fps for a slow animation - what "Show refresh rate" displays). In High the same slot therefore carries a
# RenderVote [max, max], touched and idle alike. Below the app-request cutoff it only raises the primary range,
# so an app that explicitly asks for a lower frame rate (video, a 60 fps game cap) still gets it.

# static fields
.field public static final IDLE:%(K4)s

.field public static final TOUCH:%(K4)s

.field public static volatile sIdleVote:Lcom/android/server/display/mode/Vote;

.field public static volatile sTouchVote:Lcom/android/server/display/mode/Vote;


# instance fields
.field public final mIdle:Z


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, %(K4)s

    const/4 v1, 0x1

    invoke-direct {v0, v1}, %(K4)s-><init>(Z)V

    sput-object v0, %(K4)s->IDLE:%(K4)s

    new-instance v0, %(K4)s

    const/4 v1, 0x0

    invoke-direct {v0, v1}, %(K4)s-><init>(Z)V

    sput-object v0, %(K4)s->TOUCH:%(K4)s

    return-void
.end method

.method public constructor <init>(Z)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-boolean p1, p0, %(K4)s->mIdle:Z

    return-void
.end method

# PowerManagerService, with its lock held: only post to the display thread
.method public static onUserActivity()V
    .locals 4

    sget-object v0, %(RRC)s->mHandler:Lcom/android/server/display/DisplayManagerService$DisplayManagerHandler;

    if-eqz v0, :cond_0

    sget-object v1, %(K4)s->IDLE:%(K4)s

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    sget-object v2, %(K4)s->TOUCH:%(K4)s

    invoke-virtual {v0, v2}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    invoke-static {}, %(K4)s->idleDelayMs()J

    move-result-wide v2

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :cond_0
    return-void
.end method

# The delay between the last touch and the 60 Hz vote: %(IDLE_PROP)s
# (Settings > Display > "Adaptive smoothness delay"), %(IDLE_MIN_DEC)s..%(IDLE_MAX_DEC)s ms, %(IDLE_DEFAULT_DEC)s ms when unset, not a number or
# not positive. SystemProperties.getInt() is a lock-free read of the property area, cheap enough for every boost.
.method public static idleDelayMs()J
    .locals 2

    const-string v0, "%(IDLE_PROP)s"

    const/16 v1, %(IDLE_DEFAULT)s

    invoke-static {v0, v1}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v0

    if-gtz v0, :cond_0

    move v0, v1

    :cond_0
    const/16 v1, %(IDLE_MIN)s

    if-ge v0, v1, :cond_1

    move v0, v1

    :cond_1
    const/16 v1, %(IDLE_MAX)s

    if-le v0, v1, :cond_2

    move v0, v1

    :cond_2
    int-to-long v0, v0

    return-wide v0
.end method

# RefreshRateController.updateRefreshRateModeLocked(): Adaptive (1) on the main display arms the idle vote,
# High (2) holds the render rate floor in the same slot both touched and idle, any other mode clears it; then
# start a fresh idle window
.method public static onRefreshRateMode(%(RRC)sI)V
    .locals 3

    iget-boolean v0, p0, %(RRC)s->mIsExtraBuiltinScreen:Z

    if-nez v0, :cond_0

    const/4 v0, 0x0

    const/4 v2, 0x0

    const/4 v1, 0x1

    if-ne p1, v1, :cond_2

    iget-object v0, p0, %(RRC)s->mConfig:%(CFG)s

    invoke-virtual {v0}, %(HS)s

    move-result-object v0

    invoke-virtual {v0}, %(SR)s->min()I

    move-result v0

    int-to-float v0, v0

    invoke-static {v0, v0}, Lcom/android/server/display/mode/Vote;->forPhysicalRefreshRates(FF)Lcom/android/server/display/mode/CombinedVote;

    move-result-object v0

    goto :cond_1

    :cond_2
    const/4 v1, 0x2

    if-ne p1, v1, :cond_1

    iget-object v0, p0, %(RRC)s->mConfig:%(CFG)s

    invoke-virtual {v0}, %(HS)s

    move-result-object v0

    invoke-virtual {v0}, %(SR)s->max()I

    move-result v0

    int-to-float v0, v0

    new-instance v2, Lcom/android/server/display/mode/RefreshRateVote$RenderVote;

    invoke-direct {v2, v0, v0}, Lcom/android/server/display/mode/RefreshRateVote;-><init>(FF)V

    move-object v0, v2

    :cond_1
    sput-object v0, %(K4)s->sIdleVote:Lcom/android/server/display/mode/Vote;

    sput-object v2, %(K4)s->sTouchVote:Lcom/android/server/display/mode/Vote;

    invoke-static {}, %(K4)s->onUserActivity()V

    :cond_0
    return-void
.end method

# Display thread: place (idle) or remove (touch) the vote
.method public static setIdle(Z)V
    .locals 3

    sget-boolean v0, Lcom/samsung/android/rune/CoreRune;->FW_VRR_SEAMLESS_OPTOUT_PASSIVE:Z

    if-nez v0, :cond_0

    sget-object v0, %(RRC)s->mVotesStorage:Lcom/android/server/display/mode/VotesStorage;

    if-eqz v0, :cond_0

    sget-object v1, %(K4)s->sTouchVote:Lcom/android/server/display/mode/Vote;

    if-eqz p0, :cond_1

    sget-object v1, %(K4)s->sIdleVote:Lcom/android/server/display/mode/Vote;

    :cond_1
    const/4 v2, -0x1

    const/16 p0, 0x8

    invoke-virtual {v0, v2, p0, v1}, Lcom/android/server/display/mode/VotesStorage;->updateVote(IILcom/android/server/display/mode/Vote;)V

    :cond_0
    return-void
.end method


# virtual methods
.method public final run()V
    .locals 0

    iget-boolean p0, p0, %(K4)s->mIdle:Z

    invoke-static {p0}, %(K4)s->setIdle(Z)V

    return-void
.end method
""" % dict(K4=K4, RRC=RRC, CFG=CFG, HS=hs.group(1), SR=hs.group(2), IDLE_PROP=IDLE_PROP,
           IDLE_MIN="0x%x" % IDLE_MIN, IDLE_DEFAULT="0x%x" % IDLE_DEFAULT, IDLE_MAX="0x%x" % IDLE_MAX,
           IDLE_MIN_DEC=IDLE_MIN, IDLE_DEFAULT_DEC=IDLE_DEFAULT, IDLE_MAX_DEC=IDLE_MAX))
print("  - idle vote on PRIORITY_FIXED_REFRESH_RATE, armed from PowerManagerService user activity, delay from %s" % IDLE_PROP)
PYEOF

# Settings.System peak_refresh_rate / min_refresh_rate are AOSP's "Smooth display" / "Force peak refresh rate" keys.
# Motion smoothness never writes them and both are unset on a clean install, but
# DisplayModeDirector$SettingsObserver.updateRefreshRateSettingLocked(int) still turns them into votes that outrank
# the Motion smoothness vote: peak becomes the render rate cap (PRIORITY_USER_SETTING_PEAK_RENDER_FRAME_RATE), min
# the render rate floor. A value left behind by something else - Samsung's factory DisplayModeSetting test writes
# both keys to one rate, root "battery" tweaks do the same - then decides the frame rate in every mode: a tester had
# both at 48 (a real S26 Ultra LTPO rate, meaningless on this 60/120 Hz panel), so the render rate was capped at 48
# and SurfaceFlinger picked 40 fps on the 120 Hz mode (30 fps on 60 Hz) in High, Adaptive and Standard alike.
# Ignore such a value right where the two settings are read: a finite, positive rate more than 1 Hz below the
# lowest refresh rate the display has is treated as unset (peak -> the default peak the observer already uses,
# min -> 0), with one WARN line (tag K4RefreshRate) per ignored value. The floor is the lowest rate among the
# display's modes, but never above the panel minimum from TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE, so a mode
# list narrowed at runtime cannot turn a deliberate 60 into "stale". Everything that means something keeps working:
# 0 (off), infinity (Force peak refresh rate), 60 as a real cap, 120 (the retired UN1CA Force peak toggle wrote
# min_refresh_rate=120). The settings themselves are left alone - system_server only stops acting on them. This is
# the only reader in services.jar (DisplayModeDirector$Injector just holds the two Uris).
MIN_PANEL_RATE="$(tr "," "\n" <<< "$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" | sort -n | head -n 1)"
[[ "$MIN_PANEL_RATE" =~ ^[1-9][0-9]*$ ]] || \
    ABORT "hfr: no panel minimum in TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE=\"$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE\""
LOG "- Ignoring peak_refresh_rate/min_refresh_rate settings below the panel's lowest refresh rate ($MIN_PANEL_RATE Hz)"
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" "$MIN_PANEL_RATE" << 'PYEOF' || ABORT "Failed to patch DisplayModeDirector\$SettingsObserver"
import glob, os, re, struct, sys
root, floor = sys.argv[1], float(sys.argv[2])
assert 1 <= floor <= 240, "panel minimum %r" % floor

def one(rel):
    hits = glob.glob(root + "/smali*/" + rel)
    assert len(hits) == 1, "%s: %d" % (rel, len(hits))
    return hits[0]

K4 = "Lcom/android/server/display/mode/K4RefreshRateSettings;"
OBS = "Lcom/android/server/display/mode/DisplayModeDirector$SettingsObserver;"
DMD = "Lcom/android/server/display/mode/DisplayModeDirector;"
MODES = "Landroid/util/SparseArray;"
obs = one("com/android/server/display/mode/DisplayModeDirector$SettingsObserver.smali")
helper = glob.glob(root + "/smali*/com/android/server/display/mode/K4RefreshRateSettings.smali")
s = open(obs).read()
if K4 in s:
    assert len(helper) == 1, "hooked, but %d helper classes" % len(helper)
    print("  - already patched"); sys.exit(0)
assert not helper, "stale K4RefreshRateSettings.smali"

# no other class of the display code may read the two keys (the Injector only builds their Uris)
readers = sorted(os.path.basename(f) for f in glob.glob(root + "/smali*/com/android/server/display/**/*.smali", recursive=True)
                 if re.search(r'"(?:peak|min)_refresh_rate"', open(f).read()))
assert readers == ["DisplayModeDirector$Injector.smali", "DisplayModeDirector$SettingsObserver.smali"], readers

m = re.search(r"^\.method public final updateRefreshRateSettingLocked\(I\)V\n.*?^\.end method\n", s, re.M | re.S)
assert m, "updateRefreshRateSettingLocked(I)V"
body = m.group(0)
loc = re.search(r"^    \.locals (\d+)$", body, re.M)
assert loc and int(loc.group(1)) >= 6, "locals"
assert len(re.findall(r'"(?:peak|min)_refresh_rate"', s)) == 4 and len(re.findall(r'"(?:peak|min)_refresh_rate"', body)) == 2, \
    "the two keys are read outside updateRefreshRateSettingLocked(I)V"
# the method reaches the per-display mode table exactly like the hooks below do (same fields, same access)
for need in ("    iget-object v1, p0, %s->this$0:%s\n" % (OBS, DMD),
             "    iget-object v1, v1, %s->mSupportedModesByDisplay:%s\n" % (DMD, MODES),
             "    invoke-virtual {v1, p1}, %s->contains(I)Z\n" % MODES):
    assert body.count(need) >= 1, need
GET = r"Landroid/provider/Settings\$System;->getFloatForUser\(Landroid/content/ContentResolver;Ljava/lang/String;FI\)F"
INF = r"    invoke-static \{%s\}, Ljava/lang/Float;->isInfinite\(F\)Z\n\n    move-result v3\n"

def modes(reg):
    return ("    iget-object %(r)s, p0, %(OBS)s->this$0:%(DMD)s\n\n"
            "    iget-object %(r)s, %(r)s, %(DMD)s->mSupportedModesByDisplay:%(MODES)s\n\n" % dict(r=reg, OBS=OBS, DMD=DMD, MODES=MODES))

# min: v2 = getFloatForUser(v0 resolver, "min_refresh_rate", v3 = 0f, v4 = USER_CURRENT). v3 (the 0f default) is dead
# after the call and is rewritten by the isInfinite() result right below, so it can carry the mode table; v0, v1
# (max rate), v4 and p1 (display id) stay untouched. v2 is a float before and after.
rd = re.search(r'(    const-string(?:/jumbo)? v2, "min_refresh_rate"\n\n'
               r"    const/4 v3, 0x0\n\n"
               r"    const/4 v4, -0x2\n\n"
               r"    invoke-static \{v0, v2, v3, v4\}, " + GET + r"\n\n"
               r"    move-result v2\n\n)" + INF % "v2", body)
assert rd, "min_refresh_rate read"
body = body[:rd.end(1)] + modes("v3") + \
    "    invoke-static {v3, p1, v2}, %s->min(%sIF)F\n\n    move-result v2\n\n" % (K4, MODES) + body[rd.end(1):]

# peak: v0 = getFloatForUser(v0 resolver, v3 = "peak_refresh_rate", v5 = mDefaultPeakRefreshRate, v4). v3 (the key
# string) is dead after the call and rewritten by isInfinite() below; v5 still holds the default peak (a float) and
# is the fallback; v1 (max rate) and v2 (min) stay untouched. v0 is a float before and after.
rd = re.search(r'(    const-string(?:/jumbo)? v3, "peak_refresh_rate"\n\n'
               r"    iget v5, p0, " + re.escape(OBS) + r"->mDefaultPeakRefreshRate:F\n\n"
               r"    invoke-static \{v0, v3, v5, v4\}, " + GET + r"\n\n"
               r"    move-result v0\n\n)" + INF % "v0", body)
assert rd, "peak_refresh_rate read"
body = body[:rd.end(1)] + modes("v3") + \
    "    invoke-static {v3, p1, v0, v5}, %s->peak(%sIFF)F\n\n    move-result v0\n\n" % (K4, MODES) + body[rd.end(1):]
assert body.count(K4) == 2
open(obs, "w").write(s[:m.start()] + body + s[m.end():])

# The helper (classes2.dex, next to K4AdaptiveTouch)
os.makedirs(root + "/smali_classes2/com/android/server/display/mode", exist_ok=True)
open(root + "/smali_classes2/com/android/server/display/mode/K4RefreshRateSettings.smali", "w").write("""\
.class public final %(K4)s
.super Ljava/lang/Object;
.source "K4RefreshRateSettings.java"


# Settings.System peak_refresh_rate / min_refresh_rate, as DisplayModeDirector$SettingsObserver reads them:
# a finite, positive rate more than 1 Hz below the lowest refresh rate of the display is not a setting anyone
# can mean on this panel (a 48 left behind caps rendering at 40 fps), so it is treated as unset.

# static fields
.field private static sIgnoredMin:F

.field private static sIgnoredPeak:F


# direct methods

# Lowest refresh rate among the display's modes, 0 if unknown
.method private static lowestRefreshRate(%(MODES)sI)F
    .locals 6

    const/4 v0, 0x0

    if-eqz p0, :cond_done

    invoke-virtual {p0, p1}, %(MODES)s->get(I)Ljava/lang/Object;

    move-result-object v1

    instance-of v2, v1, [Landroid/view/Display$Mode;

    if-eqz v2, :cond_done

    check-cast v1, [Landroid/view/Display$Mode;

    array-length v2, v1

    const/4 v3, 0x0

    :goto_loop
    if-ge v3, v2, :cond_done

    aget-object v4, v1, v3

    if-eqz v4, :cond_next

    invoke-virtual {v4}, Landroid/view/Display$Mode;->getRefreshRate()F

    move-result v5

    const/4 v4, 0x0

    cmpl-float v4, v5, v4

    if-lez v4, :cond_next

    const/4 v4, 0x0

    cmpl-float v4, v0, v4

    if-eqz v4, :cond_take

    cmpg-float v4, v5, v0

    if-gez v4, :cond_next

    :cond_take
    move v0, v5

    :cond_next
    add-int/lit8 v3, v3, 0x1

    goto :goto_loop

    :cond_done
    return v0
.end method

.method private static isStale(%(MODES)sIF)Z
    .locals 4

    const/4 v0, 0x0

    # 0, negative, NaN and infinity all keep their AOSP meaning
    cmpl-float v1, p2, v0

    if-lez v1, :cond_no

    invoke-static {p2}, Ljava/lang/Float;->isInfinite(F)Z

    move-result v1

    if-nez v1, :cond_no

    invoke-static {p0, p1}, %(K4)s->lowestRefreshRate(%(MODES)sI)F

    move-result v2

    # the panel minimum from TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE
    const v3, %(FLOOR)s

    cmpl-float v1, v2, v0

    if-lez v1, :cond_panel

    cmpg-float v1, v2, v3

    if-lez v1, :cond_floor

    :cond_panel
    move v2, v3

    # 1 Hz of slack: a stored 60.0 against a 60.000004 Hz mode is not stale
    :cond_floor
    const/high16 v3, 0x3f800000    # 1.0f

    add-float/2addr v3, p2

    cmpg-float v1, v3, v2

    if-gez v1, :cond_no

    const/4 v0, 0x1

    return v0

    :cond_no
    const/4 v0, 0x0

    return v0
.end method

.method private static warn(Ljava/lang/String;F)V
    .locals 2

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Ignoring Settings.System "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, "="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    const-string v1, ": below every refresh rate of this display, treated as unset"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "K4RefreshRate"

    invoke-static {v1, v0}, Landroid/util/Slog;->w(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

# min_refresh_rate as read for display p1: 0 instead of a stale value
.method public static min(%(MODES)sIF)F
    .locals 1

    invoke-static {p0, p1, p2}, %(K4)s->isStale(%(MODES)sIF)Z

    move-result v0

    if-nez v0, :cond_stale

    const/4 v0, 0x0

    sput v0, %(K4)s->sIgnoredMin:F

    return p2

    :cond_stale
    sget v0, %(K4)s->sIgnoredMin:F

    cmpl-float v0, v0, p2

    if-eqz v0, :cond_logged

    sput p2, %(K4)s->sIgnoredMin:F

    const-string v0, "min_refresh_rate"

    invoke-static {v0, p2}, %(K4)s->warn(Ljava/lang/String;F)V

    :cond_logged
    const/4 v0, 0x0

    return v0
.end method

# peak_refresh_rate as read for display p1: the default peak (p3) instead of a stale value
.method public static peak(%(MODES)sIFF)F
    .locals 1

    invoke-static {p0, p1, p2}, %(K4)s->isStale(%(MODES)sIF)Z

    move-result v0

    if-nez v0, :cond_stale

    const/4 v0, 0x0

    sput v0, %(K4)s->sIgnoredPeak:F

    return p2

    :cond_stale
    sget v0, %(K4)s->sIgnoredPeak:F

    cmpl-float v0, v0, p2

    if-eqz v0, :cond_logged

    sput p2, %(K4)s->sIgnoredPeak:F

    const-string v0, "peak_refresh_rate"

    invoke-static {v0, p2}, %(K4)s->warn(Ljava/lang/String;F)V

    :cond_logged
    return p3
.end method
""" % dict(K4=K4, MODES=MODES, FLOOR="0x%08x    # %sf" % (struct.unpack("<I", struct.pack("<f", floor))[0], floor)))
print("  - updateRefreshRateSettingLocked(I)V: min/peak read through K4RefreshRateSettings (panel minimum %g Hz)" % floor)
PYEOF
unset MIN_PANEL_RATE

# The touch IC gets the raw refresh_rate_mode value ("refresh_rate_mode,<n>" sec_cmd). The A52s stock never sends 2
# (seamless panels only offer 0/1); hand it 1, the high-rate scan mode it already uses for Adaptive.
INPUTDEV="system/framework/secinputdev-service.jar"
if [ -f "$WORK_DIR/system/$INPUTDEV" ]; then
    DECODE_APK "system" "$INPUTDEV" || ABORT "Failed to decode $INPUTDEV"
    LOG "- Sending refresh_rate_mode 2 to the touch IC as 1 in SemInputDeviceManagerService"
    python3 - "$APKTOOL_DIR/system/${INPUTDEV//system\//}" << 'PYEOF' || ABORT "Failed to patch SemInputDeviceManagerService\$SettingHandler"
import glob, re, sys
hits = glob.glob(sys.argv[1] + "/smali*/com/samsung/android/hardware/secinputdev/SemInputDeviceManagerService$SettingHandler.smali")
assert len(hits) == 1, "SettingHandler: %d" % len(hits)
f = hits[0]
s = open(f).read()
if ":cond_unica_rr_touch" in s:
    print("  - already patched"); sys.exit(0)
head = ".method private updateRefreshRateMode(I)I\n    .locals 4\n"
assert s.count(head) == 1, "updateRefreshRateMode(I)I"
m = re.search(re.escape(head) + r".*?^\.end method\n", s, re.M | re.S)
assert "Command;->REFRESH_RATE:" in m.group(0), "REFRESH_RATE command"
s = s.replace(head, head + """
    const/4 v0, 0x2

    if-ne p1, v0, :cond_unica_rr_touch

    const/4 p1, 0x1

    :cond_unica_rr_touch
""")
open(f, "w").write(s)
print("  - refresh_rate_mode 2 -> 1 for the touch IC")
PYEOF
fi

# Settings > Display > Motion smoothness: HighRefreshRateFragment shows one "high" radio button next to Standard -
# "High" (sec_high_refresh_rate_powerful_on, mode 2) on switchable panels, "Adaptive"
# (sec_high_refresh_rate_adaptive_on, mode 1) on seamless ones. Show the hidden High button on seamless panels too,
# so the page offers High (locked 120 Hz) / Adaptive / Standard (locked 60 Hz). The Display page summary
# (HighRefreshRatePreferenceController) already names mode 2 "High", and the Apply button writes
# refresh_rate_mode through SecDisplayUtils.putIntRefreshRate as before.
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"
DECODE_APK "system" "$SECSETTINGS" || ABORT "Failed to decode $SECSETTINGS"
LOG "- Adding the High (locked max refresh rate) option to Motion smoothness"
python3 - "$APKTOOL_DIR/system/${SECSETTINGS//system\//}" << 'PYEOF' || ABORT "Failed to patch HighRefreshRateFragment"
import glob, re, sys
root = sys.argv[1]
hits = glob.glob(root + "/smali*/com/samsung/android/settings/display/HighRefreshRateFragment.smali")
assert len(hits) == 1, "HighRefreshRateFragment: %d" % len(hits)
f = hits[0]
s = orig = open(f).read()
if "unicaSyncHighMode" in s:
    print("  - already patched"); sys.exit(0)
pub = open(root + "/res/values/public.xml").read()
rid = re.search(r'<public type="string" name="sec_high_refresh_rate_best_display_pd_summary" id="(0x[0-9a-f]+)" />', pub)
assert rid, "string/sec_high_refresh_rate_best_display_pd_summary"
rid = rid.group(1)

C = "Lcom/samsung/android/settings/display/HighRefreshRateFragment;"
R = "Lcom/samsung/android/settings/widget/SecRadioButtonPreference;"
L = "Lcom/samsung/android/settings/widget/SecRadioButtonPreference$OnClickListener;"
for fld in ("mPowerfulMode:" + R, "mSeamless:I", "mMode:I", "mFlags:I", "mContext:Landroid/content/Context;"):
    assert re.search(r"^\.field public " + re.escape(fld) + "$", s, re.M), fld
assert "%s->mListener:%s" % (R, L) in s, "SecRadioButtonPreference.mListener"
find = re.search(r"invoke-virtual \{p0, v\d+\}, (L[^;]+;->findPreference\(Ljava/lang/CharSequence;\)Landroidx/preference/Preference;)", s).group(1)
refresh = re.findall(r"^\.method public final (refreshUI\S*)\(\)V$", s, re.M)
assert len(refresh) == 1, "refreshUI: %s" % refresh
refresh = refresh[0]
maxrr = set(re.findall(r"Lcom/samsung/android/settings/display/SecDisplayUtils;->getHighRefreshRateMaxValue\(((?:Landroid/content/Context;)?)\)I", s))
assert len(maxrr) == 1, "getHighRefreshRateMaxValue: %s" % maxrr
maxrr = maxrr.pop()
if maxrr:
    maxcall = "iget-object v3, p0, %s->mContext:Landroid/content/Context;\n\n    invoke-static {v3}, Lcom/samsung/android/settings/display/SecDisplayUtils;->getHighRefreshRateMaxValue(Landroid/content/Context;)I" % C
else:
    maxcall = "invoke-static {}, Lcom/samsung/android/settings/display/SecDisplayUtils;->getHighRefreshRateMaxValue()I"

# 1. field
anchor = ".field public mPowerfulMode:%s\n" % R
s = s.replace(anchor, anchor + "\n.field public mUnicaHighMode:%s\n" % R)

# 2. initUI: register the High button right after mPowerfulMode got its listener
init = re.search(r"(    iput-object p0, v\d+, " + re.escape(R + "->mListener:" + L) + r"\n\n)(    const-string v\d+, \"sec_high_refresh_rate_standard_off\"\n)", s)
assert init and s.count('"sec_high_refresh_rate_standard_off"') == 1, "initUI anchor"
s = s[:init.end(1)] + "    invoke-virtual {p0}, %s->unicaInitHighMode()V\n\n" % C + s[init.end(1):]

# 3. onRadioButtonClicked: the High button selects mode 2
click = re.search(r"^\.method public final onRadioButtonClicked\(" + re.escape(R) + r"\)V\n    \.locals ([1-9]\d*)\n", s, re.M)
assert click, "onRadioButtonClicked"
s = s[:click.end()] + """
    invoke-virtual {p0, p1}, %s->unicaOnHighClicked(%s)Z

    move-result v0

    if-eqz v0, :cond_unica_hrr_click

    return-void

    :cond_unica_hrr_click
""" % (C, R) + s[click.end():]

# 4. refreshUI: after the checked state is set, sync the High button (checked / enabled / summary)
m = re.search(r"^\.method public final " + re.escape(refresh) + r"\(\)V\n.*?^\.end method\n", s, re.M | re.S)
body = m.group(0)
hs60 = re.search(r"\n(    invoke-static \{v\d+\}, Lcom/samsung/android/settings/display/SecDisplayUtils;->isSupportMaxHS60RefreshRate\()", body)
assert hs60 and body.count("isSupportMaxHS60RefreshRate(") == 1, "refreshUI anchor"
body = body[:hs60.start(1)] + "    invoke-virtual {p0}, %s->unicaSyncHighMode()V\n\n" % C + body[hs60.start(1):]
s = s[:m.start()] + body + s[m.end():]

s = s.rstrip("\n") + "\n" + """
# k4_un1ca: High (refresh_rate_mode 2, locked max refresh rate) on seamless panels too
.method public final unicaInitHighMode()V
    .locals 2

    iget v0, p0, %(C)s->mSeamless:I

    const/4 v1, 0x1

    if-eq v0, v1, :cond_0

    const-string v0, "sec_high_refresh_rate_powerful_on"

    invoke-virtual {p0, v0}, %(find)s

    move-result-object v0

    check-cast v0, %(R)s

    if-eqz v0, :cond_0

    iput-object v0, p0, %(C)s->mUnicaHighMode:%(R)s

    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setVisible(Z)V

    iput-object p0, v0, %(R)s->mListener:%(L)s

    :cond_0
    return-void
.end method

.method public final unicaOnHighClicked(%(R)s)Z
    .locals 1

    iget-object v0, p0, %(C)s->mUnicaHighMode:%(R)s

    if-eqz v0, :cond_0

    invoke-virtual {p1, v0}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x2

    iput v0, p0, %(C)s->mMode:I

    invoke-virtual {p0}, %(C)s->%(refresh)s()V

    const/4 v0, 0x1

    return v0

    :cond_0
    const/4 v0, 0x0

    return v0
.end method

.method public final unicaSyncHighMode()V
    .locals 4

    iget-object v0, p0, %(C)s->mUnicaHighMode:%(R)s

    if-eqz v0, :cond_0

    invoke-virtual {p0}, %(C)s->getRefreshRateMode()I

    move-result v1

    const/4 v2, 0x2

    if-ne v1, v2, :cond_1

    iget-object v1, p0, %(C)s->mPowerfulMode:%(R)s

    const/4 v2, 0x0

    invoke-virtual {v1, v2}, Landroidx/preference/TwoStatePreference;->setChecked(Z)V

    const/4 v2, 0x1

    invoke-virtual {v0, v2}, Landroidx/preference/TwoStatePreference;->setChecked(Z)V

    :cond_1
    iget v1, p0, %(C)s->mFlags:I

    const v2, 0xffff

    and-int/2addr v1, v2

    if-nez v1, :cond_2

    const/4 v1, 0x1

    goto :goto_0

    :cond_2
    const/4 v1, 0x0

    :goto_0
    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setEnabled(Z)V

    iget-object v1, p0, %(C)s->mContext:Landroid/content/Context;

    const v2, %(rid)s

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    %(maxcall)s

    move-result v2

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    invoke-static {v1, v2}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_0
    return-void
.end method
""" % dict(C=C, R=R, L=L, find=find, refresh=refresh, rid=rid, maxcall=maxcall)
# Everything the new methods call is already used by the stock fragment (the shrunk androidx keeps it)
assert re.search(r"^\.method public final getRefreshRateMode\(\)I$", orig, re.M), "getRefreshRateMode()I"
for need in ("Landroidx/preference/TwoStatePreference;->setChecked(Z)V", "Landroidx/preference/Preference;->setEnabled(Z)V",
             "Landroidx/preference/Preference;->setVisible(Z)V", "Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V"):
    assert need in orig, need
open(f, "w").write(s)
print("  - High/Adaptive/Standard (pd_summary=%s, %s)" % (rid, refresh))
PYEOF

# Settings > Display > "Adaptive smoothness delay", the row right under Motion smoothness: how long after the last
# touch Adaptive drops to 60 Hz. A plain SecPreference that opens a single-choice dialog (the same pair of widgets
# unica/mods/settings uses for Screen resolution; SecDropDownPreference fails to resolve its item text attribute
# under this theme), enabled only while Motion smoothness is Adaptive, with the current choice - or why it is
# greyed out - as its summary. Its controller (K4AdaptiveDelayPreferenceController.smali next to this script,
# generated from the .java beside it) writes ADAPTIVE_IDLE_PROP, which K4AdaptiveTouch reads on the next touch;
# choices, labels and default are resources generated here from ADAPTIVE_IDLE_CHOICES_MS / ADAPTIVE_IDLE_DEFAULT_MS,
# so the class carries no numbers. This R8-processed SecSettings leaves several BasePreferenceController / Sliceable
# methods abstract and gives every controller its own copies; the class has them, and the script refuses to install
# it if the base ever grows another one (it would be an AbstractMethodError at runtime otherwise).
# Other editors of sec_display_settings.xml anchor on other rows (hdr_brightness_toggle: outdoor_mode_caption, runs
# before this patch; unica/mods/settings: sec_screen_size, runs after target patches), so every order works.
LOG "- Adding the \"Adaptive smoothness delay\" choice (${ADAPTIVE_IDLE_CHOICES_MS// /, } ms) to Display settings"
# shellcheck disable=SC2086
python3 - "$APKTOOL_DIR/system/${SECSETTINGS//system\//}" "$MODPATH/K4AdaptiveDelayPreferenceController.smali" \
    "$ADAPTIVE_IDLE_PROP" "$ADAPTIVE_IDLE_DEFAULT_MS" $ADAPTIVE_IDLE_CHOICES_MS << 'PYEOF' || ABORT "Failed to add the Adaptive delay setting"
import glob, os, re, sys
root, helper_src, prop, default = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
choices = sorted(int(a) for a in sys.argv[5:])
assert len(choices) >= 2 and len(set(choices)) == len(choices) and choices[0] > 0 and default in choices, (choices, default)

OURS = "Lcom/k4/settings/display/K4AdaptiveDelayPreferenceController;"
KEY = "k4_adaptive_delay"
LITERAL = "persist.sys.k4.adaptive_idle_ms"     # the property name compiled into the generated class


def label(ms):
    if ms % 1000:
        return "%g seconds" % (ms / 1000.0)
    return "1 second" if ms == 1000 else "%d seconds" % (ms // 1000)


STRINGS = (
    ("k4_adaptive_delay_title", "Adaptive smoothness delay"),
    ("k4_adaptive_delay_summary", "Switch to 60 Hz %1$s after the last touch"),
    ("k4_adaptive_delay_summary_off", "Only used when Motion smoothness is set to Adaptive"),
)
ARRAYS = (
    ("string-array", "k4_adaptive_delay_entries", [label(c) for c in choices]),
    ("integer-array", "k4_adaptive_delay_values", [str(c) for c in choices]),
)
INTEGERS = (("k4_adaptive_delay_default", str(default)),)

_cache = {}
def load(desc):
    """smali text of a class of this apk, None for framework/boot classes"""
    if desc not in _cache:
        hits = glob.glob(root + "/smali*/" + desc[1:-1] + ".smali")
        assert len(hits) <= 1, "%s: %d copies" % (desc, len(hits))
        _cache[desc] = open(hits[0]).read() if hits else None
    return _cache[desc]

def supers(desc):
    """desc with its superclasses and interfaces inside the apk; True if the superclass chain continues in the
    framework (android.app.Dialog under AlertDialog), i.e. a member may be inherited from there"""
    seen, todo, left = [], [(desc, True)], False
    while todo:
        d, is_super = todo.pop(0)
        if d in seen:
            continue
        s = load(d)
        if s is None:
            left = left or (is_super and d != "Ljava/lang/Object;")
            continue
        seen.append(d)
        todo += [(c, is_super) for c in re.findall(r"^\.super (L[^;]+;)$", s, re.M)]
        todo += [(c, False) for c in re.findall(r"^\.implements (L[^;]+;)$", s, re.M)]
    return seen, left

def declares(desc, kind, member, text=None):
    return re.search(r"^\.%s (?:[^\n]* )?%s$" % (kind, re.escape(member)), text or load(desc), re.M)

h = open(helper_src).read()
assert h.count(LITERAL) >= 3 and ("\n.class public %s\n" % OURS) in h, "unexpected helper source"
parent = re.search(r"^\.super (L[^;]+;)$", h, re.M).group(1)
assert parent == "Lcom/android/settings/core/BasePreferenceController;" and load(parent), parent

# 1. Everything the generated class touches in this apk must exist with exactly that signature (it was compiled
#    against stubs), looked up through the superclass chain like the runtime does
checked = 0
for owner, member in sorted(set(re.findall(r"(L(?:androidx|com/android/settings|com/android/settingslib|com/samsung|com/k4)/[^;]+;)->([^\s]+)", h))):
    kind = "field" if ":" in member else "method"
    if owner == OURS and declares(None, kind, member, h):
        continue                                    # the class's own fields and methods
    start = parent if owner == OURS else owner      # inherited through `this`
    assert load(start), "%s is not in this SecSettings" % start
    chain, left = supers(start)
    found = any(declares(d, kind, member) for d in chain)
    assert found or (left and kind == "method"), "%s->%s not found in this SecSettings" % (owner, member)
    checked += 1
assert checked >= 15, checked
for cls in sorted(set(re.findall(r"L(?:androidx|com/android/settings|com/android/settingslib|com/samsung)/[^;]+;", h))):
    assert load(cls), "%s is not in this SecSettings" % cls
assert declares("Lcom/samsung/android/settings/cube/Controllable$ControllableType;", "field",
                "NO_INTERACTION:Lcom/samsung/android/settings/cube/Controllable$ControllableType;"), "ControllableType.NO_INTERACTION"

# 2. Overrides must not hit a final method, and no inherited method may stay abstract
mine = set(re.findall(r"^\.method (?!.*\b(?:static|private|constructor)\b)[^\n]*? ([\w$]+\([^)]*\)\S+)$", h, re.M))
chain, _ = supers(parent)
abstract, concrete = set(), set()
for d in chain:
    for flags, sig in re.findall(r"^\.method ([^\n]*? )?([\w$<>-]+\([^)]*\)\S+)$", load(d), re.M):
        flags = " " + (flags or "")
        assert not (sig in mine and " final " in flags), "%s->%s is final" % (d, sig)
        (abstract if " abstract " in flags else concrete).add(sig)
missing = sorted(abstract - concrete - mine)
assert not missing, "the controller base now has more abstract methods: %s" % missing
for sig in ("getAvailabilityStatus()I", "getSummary()Ljava/lang/CharSequence;", "updateState(Landroidx/preference/Preference;)V",
            "displayPreference(Landroidx/preference/PreferenceScreen;)V", "handlePreferenceTreeClick(Landroidx/preference/Preference;)Z"):
    assert sig in mine and sig in abstract | concrete, sig
# the row is refreshed (summary, enabled state) through AbstractPreferenceController.updateState -> refreshSummary
assert "->refreshSummary(Landroidx/preference/Preference;)V" in \
    re.search(r"^\.method public updateState\(Landroidx/preference/Preference;\)V\n.*?^\.end method\n",
              load("Lcom/android/settingslib/core/AbstractPreferenceController;"), re.M | re.S).group(0), "updateState no longer refreshes the summary"

# 3. Install the class: the highest-numbered dex has the most method-id headroom (classes.dex is all but full)
dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
assert dirs, "no smali_classesN"
dst = dirs[-1] + "/com/k4/settings/display/K4AdaptiveDelayPreferenceController.smali"
stale = [f for f in glob.glob(root + "/smali*/com/k4/settings/display/K4AdaptiveDelayPreferenceController.smali") if f != dst]
assert not stale, "stale controller copies: %s" % stale
os.makedirs(os.path.dirname(dst), exist_ok=True)
text = h.replace(LITERAL, prop)
if not (os.path.exists(dst) and open(dst).read() == text):
    open(dst, "w").write(text)
    print("  - controller %s in %s (%d references checked, property %s)" % (OURS[1:-1].replace("/", "."), os.path.basename(dirs[-1]), checked, prop))

# 4. Resources (English only; other locales fall back to it)
def add(path, items, render, existing):
    s = open(path).read()
    added = []
    for item in items:
        name = item[-2] if len(item) == 3 else item[0]
        want = render(item)
        m = re.search(existing % re.escape(name), s, re.S)
        if m:
            assert re.sub(r"\s+", "", m.group(0)) == re.sub(r"\s+", "", want), "%s already exists with other content" % name
            continue
        assert s.count("</resources>") == 1, path + ": </resources>"
        s = s.replace("</resources>", want + "</resources>")
        added.append(name)
    if added:
        open(path, "w").write(s)
        print("  - %s: %s" % (os.path.basename(path), ", ".join(added)))

add(root + "/res/values/strings.xml", STRINGS, lambda i: '    <string name="%s">%s</string>\n' % i,
    r'<string name="%s">.*?</string>')
add(root + "/res/values/arrays.xml", ARRAYS,
    lambda i: '    <%s name="%s">\n%s    </%s>\n' % (i[0], i[1], "".join("        <item>%s</item>\n" % v for v in i[2]), i[0]),
    r'<(?:string|integer)-array name="%s">.*?</(?:string|integer)-array>')
add(root + "/res/values/integers.xml", INTEGERS, lambda i: '    <integer name="%s">%s</integer>\n' % i,
    r'<integer name="%s">.*?</integer>')
assert re.search(r'<string name="summary_placeholder">', open(root + "/res/values/strings.xml").read()), "string/summary_placeholder"

# 5. The row, directly under Motion smoothness
xf = root + "/res/xml/sec_display_settings.xml"
x = open(xf).read()
if 'android:key="%s"' % KEY in x:
    print("  - Display settings row already present")
else:
    assert any("<SecPreference " in open(f).read() for f in glob.glob(root + "/res/xml/*.xml")), "SecPreference is not used by this SecSettings"
    assert load("Landroidx/preference/SecPreference;"), "androidx.preference.SecPreference"
    assert 'xmlns:settings="http://schemas.android.com/apk/res-auto"' in x, "settings namespace"
    lines = x.split("\n")
    hits = [i for i, l in enumerate(lines) if 'android:key="sec_high_refresh_rate"' in l]
    assert len(hits) == 1, "sec_high_refresh_rate anchor: %d" % len(hits)
    i = hits[0]
    assert lines[i].lstrip().startswith("<") and lines[i].rstrip().endswith("/>") and \
        'android:fragment="com.samsung.android.settings.display.HighRefreshRateFragment"' in lines[i], "anchor is not the single-line Motion smoothness row"
    indent = lines[i][:len(lines[i]) - len(lines[i].lstrip())]
    lines.insert(i + 1, indent + '<SecPreference android:title="@string/k4_adaptive_delay_title" android:key="%s" '
                 'android:summary="@string/summary_placeholder" settings:controller="%s" />' % (KEY, OURS[1:-1].replace("/", ".")))
    open(xf, "w").write("\n".join(lines))
    print("  - row after sec_high_refresh_rate in sec_display_settings.xml")
PYEOF

unset IDLE_TIMER_MS TOUCH_TIMER_MS SF SERVICES INPUTDEV SECSETTINGS
unset ADAPTIVE_IDLE_PROP ADAPTIVE_IDLE_CHOICES_MS ADAPTIVE_IDLE_DEFAULT_MS ADAPTIVE_IDLE_MIN_MS ADAPTIVE_IDLE_MAX_MS
