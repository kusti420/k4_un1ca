# vendor.samsung.hardware.gnss@2.0-impl-sec.so: SecLocAPIClient::onBdmsgCb() (called from libloc_api_v02
# handleAgnssConfigIndMsg) invokes the Samsung GNSS callback registered by system_server and destroys the returned
# Return<void> without checking it. If system_server died (callback binder is dead), ~return_status() aborts the
# GNSS HAL: "Failed HIDL return status not checked", seen ~10 s after each system_server restart in tester logs.
# Fix: the call to return_status::~return_status at 0xdedc goes through a trampoline placed in the zero padding
# between .text (ends 0xe5f4) and .plt (0xe600) that first sets return_status::mCheckedStatus (offset 0x20, same in
# the VNDK v30 libhidlbase the service loads), then tail-calls the normal destructor PLT entry (0xe8f0), so the
# Return is still cleaned up but a transport error no longer aborts.
LIB="$WORK_DIR/vendor/lib64/hw/vendor.samsung.hardware.gnss@2.0-impl-sec.so"
[ -f "$LIB" ] || ABORT "gnss_hidl_return: $LIB not found"
python3 - "$LIB" << 'PYEOF' || ABORT "Failed to patch vendor.samsung.hardware.gnss@2.0-impl-sec.so"
import struct, sys
p = sys.argv[1]
d = bytearray(open(p, "rb").read())
def u32(o):
    return struct.unpack_from("<I", d, o)[0]
CALL, CAVE, PLT_D2 = 0xDEDC, 0xE5F4, 0xE8F0   # file offset == vaddr in this segment
def bl(src, dst):
    return 0x94000000 | (((dst - src) >> 2) & 0x3FFFFFF)
def b(src, dst):
    return 0x14000000 | (((dst - src) >> 2) & 0x3FFFFFF)
assert len(d) == 70808, "file size"
assert u32(CALL - 4) == 0x910083E0, "add x0, sp, #0x20 before the call"
assert u32(CALL) == bl(CALL, PLT_D2), "bl return_status::~return_status@plt"
assert d[CAVE:CAVE + 12] == bytes(12), "padding after .text not empty"
assert u32(0xE600) == 0xA9BF7BF0, ".plt start"
cave = [0x52800029,            # mov  w9, #1
        0x39008009,            # strb w9, [x0, #0x20]   (return_status::mCheckedStatus = true)
        b(CAVE + 8, PLT_D2)]   # b    return_status::~return_status@plt
for i, w in enumerate(cave):
    struct.pack_into("<I", d, CAVE + 4 * i, w)
struct.pack_into("<I", d, CALL, bl(CALL, CAVE))
open(p, "wb").write(d)
PYEOF
LOG "- GNSS HAL no longer aborts when the Samsung location callback is dead"
unset LIB
