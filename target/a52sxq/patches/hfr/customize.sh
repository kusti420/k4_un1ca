# Adaptive motion smoothness is driven by SurfaceFlinger's own scheduler on this port: the One UI 9 (S26 Ultra)
# SurfaceFlinger ignores Samsung's HFR/passive mode hint (SurfaceComposerAIDL::notifyHFRmode only logs
# "VRR/HFR feature is not supported at SF, hfrMode : %d" and returns), so the stock "keep the rate stable at low
# brightness / low lux" protection never reaches the display and every 60 <-> 120 Hz switch is visible on the
# A52s AMOLED as a brightness/gamma flicker. With the old 250 ms idle / 300 ms touch timers SurfaceFlinger switched
# down after every short pause and back up on the next touch or frame, i.e. several times per scroll.
# Touch timer: every touch (PowerManagerService user activity -> SurfaceFlinger::notifyPowerBoost(INTERACTION) ->
# Scheduler::onTouchHint) boosts to the panel maximum (120 Hz) and keeps it for 3 s after the last touch.
# Idle timer: once nothing has been drawn for 3 s the scheduler drops to the policy minimum (60 Hz).
# So the panel switches at most once up per touch session and once down 3 s after it, instead of per gesture.
# Untouched, the 60 Hz state is held by a system_server vote (K4AdaptiveTouch, below), not by this idle timer:
# any frame resets the idle timer, and frames without layer votes would otherwise pick 120 Hz again.
# https://android.googlesource.com/platform/frameworks/native/+/refs/tags/android-16.0.0_r2/services/surfaceflinger/Scheduler/RefreshRateSelector.h#314
IDLE_TIMER_MS=3000
# https://android.googlesource.com/platform/frameworks/native/+/refs/tags/android-16.0.0_r2/services/surfaceflinger/sysprop/SurfaceFlingerProperties.sysprop#346
TOUCH_TIMER_MS=3000

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

# Adaptive = 120 Hz while touched, 60 Hz from 3 s after the last touch, decided in system_server.
# SurfaceFlinger alone cannot do this: every client transaction resets its idle timer, and a frame whose layers
# carry no usable vote lands in RefreshRateSelector's "No layers with votes" branch, which ranks the primary
# range descending, i.e. picks 120 Hz. On this non-VRR panel the View toolkit's frame-rate categories are
# dropped (frame_rate_category_mrr is off), so ordinary UI frames - here a single status bar frame roughly every
# 3 s while idle on the home screen, "VRI-StatusBar ... voted NoVote" -> "No layers with votes - choose 120.00 Hz"
# right after each "Idle - choose 60.00 Hz" - push the panel back to 120 Hz, a visible 60 <-> 120 Hz flicker.
# Fix it in DisplayModeDirector instead: K4AdaptiveTouch votes the minimum high-speed rate [60, 60] at
# PRIORITY_FIXED_REFRESH_RATE (8) 3 s after the last user-activity power boost, and removes the vote on the next
# boost. The boost is the one PowerManagerService.userActivityNoUpdateLocked() already sends for touches
# (nativeSetPowerBoost(INTERACTION) -> SurfaceFlinger::notifyPowerBoost -> the 3 s touch timer above), so both
# sides see the same touches. While the vote stands the primary range is single-rate 60 Hz, so the same
# "No layers with votes" ranking now yields 60 Hz, and since priority 8 is below the app-request cutoff (9) the
# app-request range stays [60, 120], so a focused layer with an explicit setFrameRate() vote (a game asking for
# 120 Hz) still gets it. On touch the vote goes away, SurfaceFlinger re-ranks with its touch signal and switches
# to 120 Hz; it holds there until 3 s after the last touch. High/Standard (and any higher vote: tokens, UDFPS,
# thermal, power saving) override or clear it. RefreshRateController.updateRefreshRateModeLocked() arms the vote
# for refresh_rate_mode 1 only.
LOG "- Holding Adaptive at 60 Hz from 3 s after the last touch (K4AdaptiveTouch)"
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" << 'PYEOF' || ABORT "Failed to add the Adaptive touch vote"
import glob, os, re, sys
root = sys.argv[1]

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


# Adaptive motion smoothness = 120 Hz while touched, 60 Hz from 3 s after the last touch.
# A PRIORITY_FIXED_REFRESH_RATE (8) vote for the minimum high-speed rate [60, 60] is placed 3 s after the last
# user-activity power boost and removed on the next one. Priority 8 is below the app-request cutoff (9), so it
# only narrows the primary range: SurfaceFlinger cannot pick 120 Hz for frames that carry no vote (its
# "No layers with votes -> max" rule), while focused layers with an explicit setFrameRate() vote (games) still
# get the app-request range, and every higher vote (High/Standard mode, tokens, UDFPS, thermal, power saving)
# overrides it. The slot belongs to Samsung's seamless opt-out passive mode, which is off on this device
# (CoreRune.FW_VRR_SEAMLESS_OPTOUT_PASSIVE); if it ever gets enabled the vote is left to Samsung.

# static fields
.field public static final IDLE:%(K4)s

.field public static final TOUCH:%(K4)s

.field public static volatile sIdleVote:Lcom/android/server/display/mode/Vote;


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

    const-wide/16 v2, 0xbb8

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :cond_0
    return-void
.end method

# RefreshRateController.updateRefreshRateModeLocked(): Adaptive (1) on the main display arms the idle vote,
# any other mode clears it; then start a fresh 3 s window
.method public static onRefreshRateMode(%(RRC)sI)V
    .locals 2

    iget-boolean v0, p0, %(RRC)s->mIsExtraBuiltinScreen:Z

    if-nez v0, :cond_0

    const/4 v0, 0x0

    const/4 v1, 0x1

    if-ne p1, v1, :cond_1

    iget-object v0, p0, %(RRC)s->mConfig:%(CFG)s

    invoke-virtual {v0}, %(HS)s

    move-result-object v0

    invoke-virtual {v0}, %(SR)s->min()I

    move-result v0

    int-to-float v0, v0

    invoke-static {v0, v0}, Lcom/android/server/display/mode/Vote;->forPhysicalRefreshRates(FF)Lcom/android/server/display/mode/CombinedVote;

    move-result-object v0

    :cond_1
    sput-object v0, %(K4)s->sIdleVote:Lcom/android/server/display/mode/Vote;

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

    const/4 v1, 0x0

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
""" % dict(K4=K4, RRC=RRC, CFG=CFG, HS=hs.group(1), SR=hs.group(2)))
print("  - idle vote on PRIORITY_FIXED_REFRESH_RATE, armed from PowerManagerService user activity")
PYEOF

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

unset IDLE_TIMER_MS TOUCH_TIMER_MS SF SERVICES INPUTDEV SECSETTINGS
