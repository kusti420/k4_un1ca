# One UI 9's AudioPolicyManager::broadcastDeviceConnectionState() builds the HAL device connection parameters with
# Samsung's renamed keys (l_device_connect / l_device_disconnect, plus l_a2dp_format for A2DP devices). The A52s A14
# audio HAL (audio.primary.lahaina, sec_set_parameters) only parses the AOSP keys connect / disconnect / format: on
# "connect=128;format=<0x200000 set>" it sets its bt_offload flag, and start_output_stream refuses A2DP while that flag
# is false ("A2DP profile is not ready, return error"). AudioFlinger only accepts those keys from audioserver itself,
# so the fix has to be in the policy. Each renamed string ends with the plain key ("l_device_" + "connect",
# "l_a2dp_" + "format"), so only the three ADD immediates that point at them change.
LIB="$WORK_DIR/system/system/lib64/libaudiopolicymanagerdefault.so"
[ -f "$LIB" ] || ABORT "audio_policy_legacy_keys: $LIB not found"
python3 - "$LIB" << 'PYEOF' || ABORT "Failed to patch libaudiopolicymanagerdefault.so"
import struct, sys
p = sys.argv[1]
d = bytearray(open(p, "rb").read())
def cstr(o):
    return bytes(d[o:o + 40].split(b"\0")[0])
# (ADD instruction file offset, string offset, renamed key, bytes to skip, plain key)
patches = [
    (0x62178, 0x1e1b4, b"l_device_disconnect", 9, b"disconnect"),
    (0x62198, 0x21549, b"l_device_connect", 9, b"connect"),
    (0x62234, 0x1e7e9, b"l_a2dp_format", 7, b"format"),
]
for insn, so, name, skip, plain in patches:
    assert cstr(so) == name, "string %s at 0x%x" % (name, so)
    assert cstr(so + skip) == plain, "tail %s" % plain
    w = struct.unpack_from("<I", d, insn)[0]
    assert (w >> 23) & 0x1FF == 0x122, "ADD (immediate, 64-bit) at 0x%x" % insn
    imm = (w >> 10) & 0xFFF
    assert imm == so & 0xFFF, "ADD at 0x%x points at 0x%x" % (insn, imm)
    assert (so & ~0xFFF) == ((so + skip) & ~0xFFF), "page crossing"
    w = (w & ~(0xFFF << 10)) | (((imm + skip) & 0xFFF) << 10)
    struct.pack_into("<I", d, insn, w)
open(p, "wb").write(d)
PYEOF
LOG "- AudioPolicyManager sends connect/disconnect/format to the HAL again"

# AudioFlinger's Samsung layer (SecAudioParamFlinger) matches the policy's device connection message by the key
# l_device_connect: for A2DP devices it records the connect time ("connection mConnectedDevice[%x]") and notifies its
# registered listeners (e.g. AVRCP absolute volume handling). With the policy now sending "connect", point that key at
# the "connect" tail of its own "l_device_connect" string too (its only reference), so this keeps working.
LIB="$WORK_DIR/system/system/lib64/libaudioflinger.so"
[ -f "$LIB" ] || ABORT "audio_policy_legacy_keys: $LIB not found"
python3 - "$LIB" << 'PYEOF2' || ABORT "Failed to patch libaudioflinger.so"
import struct, sys
p = sys.argv[1]
d = bytearray(open(p, "rb").read())
insn, so, name, skip, plain = 0x83AE4, 0x299A6, b"l_device_connect", 9, b"connect"
assert bytes(d[so:so + len(name) + 1]) == name + b"\0", "string %s" % name
assert bytes(d[so + skip:so + skip + len(plain) + 1]) == plain + b"\0", "tail %s" % plain
w = struct.unpack_from("<I", d, insn)[0]
assert (w >> 23) & 0x1FF == 0x122, "ADD (immediate, 64-bit) at 0x%x" % insn
imm = (w >> 10) & 0xFFF
assert imm == so & 0xFFF, "ADD at 0x%x points at 0x%x" % (insn, imm)
assert (so & ~0xFFF) == ((so + skip) & ~0xFFF), "page crossing"
struct.pack_into("<I", d, insn, (w & ~(0xFFF << 10)) | (((imm + skip) & 0xFFF) << 10))
open(p, "wb").write(d)
PYEOF2
LOG "- AudioFlinger tracks A2DP connections by the connect key"
unset LIB
