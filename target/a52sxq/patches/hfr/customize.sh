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

unset IDLE_TIMER_MS TOUCH_TIMER_MS SF
