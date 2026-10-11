# Stock file capabilities (security.capability permitted mask, as in fs_config) that scripts/extract_fw.sh drops.
# Read from the xattrs of the A528BXXU5FWK4 vendor.img; odm has none, and on the source side (system, system_ext,
# product) only run-as and simpleperf_app_runner carry any, which extract_fw.sh already restores.
#   <partition> <fs_config entry> <mask>
FILE_CAPABILITIES="
vendor vendor/bin/loc_launcher 0xc0
vendor vendor/bin/pd-mapper 0x400
vendor vendor/bin/pm-service 0x400
vendor vendor/bin/hw/android.hardware.bluetooth@1.0-service-qti 0x1000001000
"

LOG_STEP_IN "- Restoring stock file capabilities"
while read -r PARTITION ENTRY MASK; do
    [ "$PARTITION" ] || continue

    if [ ! -f "$WORK_DIR/$ENTRY" ]; then
        LOG "- /$ENTRY is not in the work dir, skipping"
        continue
    fi

    FS_CONFIG="$WORK_DIR/configs/fs_config-$PARTITION"
    [ -f "$FS_CONFIG" ] || ABORT "file_capabilities: ${FS_CONFIG//$WORK_DIR/} not found"

    python3 - "$FS_CONFIG" "$ENTRY" "$MASK" << 'PYEOF' || ABORT "Failed to set capabilities for /$ENTRY"
import re, sys
path, entry, mask = sys.argv[1:4]
lines = open(path).read().split("\n")
hits = [i for i, l in enumerate(lines) if l.startswith(entry + " ")]
assert len(hits) == 1, "%s: %d fs_config entries" % (entry, len(hits))
m = re.fullmatch(re.escape(entry) + r" (\d+ \d+ \d+) capabilities=(0x[0-9a-fA-F]+)", lines[hits[0]])
assert m, "unexpected fs_config line: %r" % lines[hits[0]]
if int(m.group(2), 16) == int(mask, 16):
    print("  - already set"); sys.exit(0)
assert int(m.group(2), 16) == 0, "%s already has capabilities=%s" % (entry, m.group(2))
lines[hits[0]] = "%s %s capabilities=%s" % (entry, m.group(1), mask)
open(path, "w").write("\n".join(lines))
PYEOF
    LOG "- /$ENTRY capabilities=$MASK"
done <<< "$FILE_CAPABILITIES"
LOG_STEP_OUT

unset FILE_CAPABILITIES PARTITION ENTRY MASK FS_CONFIG
