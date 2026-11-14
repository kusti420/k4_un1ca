SKIPUNZIP=1

# See module.prop.
for d in lib lib64; do
    for f in liblivefocus_preview_engine.so liblivefocus_capture_engine.so libDualCamBokehCapture.camera.samsung.so; do
        LIB="$WORK_DIR/vendor/$d/$f"
        [ -f "$LIB" ] || ABORT "camera_livefocus_profile: /vendor/$d/$f not found"
        python3 - "$LIB" << 'PYEOF' || ABORT "camera_livefocus_profile: failed to patch /vendor/$d/$f"
import sys
p = sys.argv[1]
b = open(p, "rb").read()
old, new = b"\x00a52\x00", b"\x00m3q\x00"
if b.count(new) == 1 and b.count(old) == 0:
    sys.exit(0)  # already patched
assert b.count(old) == 1 and b.count(b"m3q") == 0, "unexpected match strings in %s" % p
open(p, "wb").write(b.replace(old, new))
PYEOF
    done
done
LOG "- Portrait engines: A52 live focus profile on the S26U ro.build.flavor"
unset d f LIB
