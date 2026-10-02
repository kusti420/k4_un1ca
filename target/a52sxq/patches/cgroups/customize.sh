# Kernel cgroup subsystems on a52sxq (5.4.233): cpuset cpu cpuacct blkio memory freezer.
# Android 14 ignored unknown controllers; Android 17 fails SetupCgroups entirely, which
# leaves /sys/fs/cgroup/system/uid_* uncreated and kills ueventd/apexd-bootstrap.
KERNEL_CGROUPS="cpuset cpu cpuacct blkio memory freezer"
for FILE in "$WORK_DIR/system/system/etc/cgroups.json" "$WORK_DIR/vendor/etc/cgroups.json"; do
    [ -f "$FILE" ] || continue
    LOG "- Marking unsupported cgroup v1 controllers optional in ${FILE//$WORK_DIR/}"
    python3 - "$FILE" $KERNEL_CGROUPS <<'PYEOF' || ABORT "Failed to patch ${FILE//$WORK_DIR/}"
import json, sys
path, avail = sys.argv[1], set(sys.argv[2:])
d = json.load(open(path))
for c in d.get("Cgroups", []):
    if c["Controller"] not in avail:
        c["Optional"] = True
        print("    optional: " + c["Controller"])
for c in d.get("Cgroups2", {}).get("Controllers", []):
    if c["Controller"] not in avail:
        c["Optional"] = True
        print("    optional (v2): " + c["Controller"])
json.dump(d, open(path, "w"), indent=2)
open(path, "a").write("\n")
PYEOF
done
unset KERNEL_CGROUPS FILE
