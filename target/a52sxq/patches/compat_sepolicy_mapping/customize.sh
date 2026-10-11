# The A14 vendor policy is versioned 30.0 (plat_sepolicy_vers.txt) and Android 17 ships no 30.0 mapping, so
# unica/patches/selinux restores system/etc/selinux/mapping/30.0.cil from the A14 target firmware. That file predates
# the domains Android split off later, e.g. "(typeattributeset platform_app_30_0 (platform_app))" misses
# platform_app_36, and untrusted_app_30_0 misses untrusted_app_34. Every vendor rule for those versioned types then
# skips apps that target newer SDKs (Samsung Internet, Samsung Keyboard and other SDK 36 Samsung apps run as
# platform_app_36; most Play Store apps run as untrusted_app_34): denied ISehCodecSolution, ro.chipname, etc.
# Android keeps old mappings current by adding the split types to them; merge the members that the source's own
# oldest mapping (31.0) adds for the same attributes. Device patches run before unica/patches, so restore the
# target mapping here first (same as unica/patches/selinux does); that patch then keeps the existing file.
if [[ "$(head -n 1 "$WORK_DIR/vendor/etc/selinux/plat_sepolicy_vers.txt")" != "30.0" ]]; then
    LOG "- Vendor SELinux policy is not 30.0, nothing to do"
    return 0
fi
MAP="$WORK_DIR/system/system/etc/selinux/mapping/30.0.cil"
REF="$WORK_DIR/system/system/etc/selinux/mapping/31.0.cil"
[ -f "$REF" ] || ABORT "compat_sepolicy_mapping: $REF not found"
for f in 30.0.cil 30.0.compat.cil; do
    if [ ! -f "$WORK_DIR/system/system/etc/selinux/mapping/$f" ]; then
        ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/selinux/mapping/$f" \
            0 0 644 "u:object_r:system_file:s0" || ABORT "compat_sepolicy_mapping: failed to restore $f"
    fi
done
python3 - "$MAP" "$REF" "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil" << 'PYEOF' || ABORT "Failed to update the 30.0 SELinux mapping"
import re, sys
mp, ref, plat = sys.argv[1:4]
pat = r"^\(typeattributeset (\S+)_%s \((.*)\)\)\s*$"
def load(p, suf):
    out = {}
    for l in open(p):
        m = re.match(pat % suf, l)
        if m:
            out[m.group(1)] = m.group(2).split()
    return out
b = load(ref, "31_0")
text = open(plat).read()
known = set(re.findall(r"\((?:type|typeattribute) (\S+)\)", text))
lines = open(mp).read().split("\n")
changed = []
for i, l in enumerate(lines):
    m = re.match(pat % "30_0", l)
    if not m or m.group(1) not in b:
        continue
    have = m.group(2).split()
    add = [t for t in b[m.group(1)] if t not in have and t in known]
    if add:
        lines[i] = "(typeattributeset %s_30_0 (%s))" % (m.group(1), " ".join(have + add))
        changed.append("%s +%s" % (m.group(1), ",".join(add)))
assert any(c.startswith("platform_app +") for c in changed) or "platform_app_36" in open(mp).read(), "platform_app"
open(mp, "w").write("\n".join(lines))
for c in changed:
    print("    " + c)
PYEOF
LOG "- 30.0 SELinux mapping extended with the Android 17 split domains"
unset MAP REF f

# The product partition has its own half of the mapping. The A14 one (product/etc/selinux/mapping/30.0.cil) maps the
# Qualcomm product/system_ext public types the vendor policy uses by their versioned names (vendor_systemhelper_app,
# vendor_hal_systemhelper_hwservice, vendor_sys_qti_display, vendor_display_notch_prop); the source ships product
# mappings for 31.0+ only, so every vendor rule on those *_30_0 attributes matched nothing (e.g.
# vendor_systemhelper_app as a vendor_hal_trustedui_client). Restore only the 30.0 lines for types this policy still
# defines: the *_31_0.. attribute declarations in the A14 file belong to the source's own newer mappings, and the
# device secilc rejects duplicates. Verified with the device's secilc (full init argument list) before shipping.
PMAP_SRC="$FW_DIR/$(cut -d "/" -f 1 <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 <<< "$TARGET_FIRMWARE")/product/etc/selinux/mapping/30.0.cil"
PMAP="$WORK_DIR/product/etc/selinux/mapping/30.0.cil"
if [ ! -f "$PMAP" ]; then
    [ -f "$PMAP_SRC" ] || ABORT "compat_sepolicy_mapping: target product 30.0.cil not found"
    python3 - "$PMAP_SRC" "$PMAP" "$WORK_DIR" << 'PYEOF' || ABORT "Failed to restore the product 30.0 SELinux mapping"
import glob, re, sys
src, dst, work = sys.argv[1:4]
known = set()
for f in glob.glob(work + "/product/etc/selinux/*.cil") + glob.glob(work + "/system/system/etc/selinux/*.cil") + \
        glob.glob(work + "/system/system/system_ext/etc/selinux/*.cil") + glob.glob(work + "/system_ext/etc/selinux/*.cil"):
    known |= set(re.findall(r"^\(type (\S+)\)", open(f).read(), re.M))
vendor = open(work + "/vendor/etc/selinux/plat_pub_versioned.cil").read()
out = []
for l in open(src):
    m = re.match(r"^\(typeattributeset (\S+)_30_0 \((.*)\)\)\s*$", l)
    if not m:
        continue
    attr = m.group(1) + "_30_0"
    types = [t for t in m.group(2).split() if t in known]
    if not types or "(typeattribute %s)" % attr not in vendor:
        continue
    out.append("(expandtypeattribute (%s) true)" % attr)
    out.append("(typeattributeset %s (%s))" % (attr, " ".join(types)))
    print("    %s <- %s" % (attr, " ".join(types)))
assert out, "nothing to map"
open(dst, "w").write("\n".join(sorted(out)) + "\n")
PYEOF
    SET_METADATA "product" "etc/selinux/mapping/30.0.cil" 0 0 644 "u:object_r:system_file:s0"
    LOG "- Product 30.0 SELinux mapping restored for the types this policy defines"
fi
unset PMAP PMAP_SRC
