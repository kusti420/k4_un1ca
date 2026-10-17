#!/usr/bin/env python3
# Emergency tool (host side, not used by the build): remove one module from Android 17's list of active Play-updated
# APEX images, so apexd falls back to that module's /system version on the next boot (see tethering/customize.sh,
# "Recovery if a Tethering train breaks boot"). From TWRP with /metadata mounted:
#   adb pull /metadata/apex/images/active active
#   drop_active_apex.py active com.android.tethering active.new      # prints what it keeps and drops
#   adb push active.new /metadata/apex/images/active
#   adb shell chcon u:object_r:apex_metadata_file:s0 /metadata/apex/images/active; adb shell chmod 0640 /metadata/apex/images/active
# Format (apex_image_list.proto): repeated Entry entries = 1; Entry { string image_name = 1; string apex_name = 2; }
import sys


def varint(b, i):
    v = s = 0
    while True:
        c = b[i]; i += 1; v |= (c & 0x7F) << s; s += 7
        if not c & 0x80: return v, i


def fields(b):
    i = 0
    while i < len(b):
        start = i; key, i = varint(b, i); wt = key & 7
        assert wt == 2, f"unexpected wire type {wt} at {start}"
        n, i = varint(b, i); yield key >> 3, b[i:i + n], b[start:i + n]; i += n


src, apex, dst = sys.argv[1:4]
data = open(src, "rb").read()
out, dropped = b"", 0
for num, val, raw in fields(data):
    assert num == 1, f"unexpected top-level field {num}"
    sub = {n: v.decode() for n, v, _ in fields(val)}
    if sub.get(2) == apex:
        print("drop", sub); dropped += 1
    else:
        print("keep", sub); out += raw
assert dropped == 1, f"{apex}: {dropped} entries"
open(dst, "wb").write(out)
