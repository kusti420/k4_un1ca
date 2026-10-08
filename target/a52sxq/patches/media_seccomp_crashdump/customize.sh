# The Codec2 HALs run under the A14 vendor seccomp policies. Those already allow what the A14 crash_dump needs, but
# crash_dump inherits the HAL's seccomp filter and the Android 17 crash_dump also uses getppid, setsockopt and uname
# (and recvfrom, which the Samsung policy never had). Each native stack dump of these HALs (app ANRs and watchdog
# half-triggers dump HAL_INTERFACES_OF_INTEREST stacks, bugreports dump all HALs) therefore kills them: tester log
# 9.1.13 18:44:35/18:45:13 "dumpStackTraces nativepids=..." -> both codec services restart with new pids, and the
# 9.1.15 bugreport shows Chrome's "Codec2 component "c2.qti.vp9.decoder" died" / MediaCodec error 1101 at that point.
# Append the system crash_dump rules (exact lines, so argument filters are kept) for syscalls the policy lacks.
python3 - "$WORK_DIR" << 'PYEOF' || ABORT "Failed to update the codec HAL seccomp policies"
import os, re, sys
wd = sys.argv[1]
crash = {a: os.path.join(wd, "system/system/etc/seccomp_policy/crash_dump.%s.policy" % a) for a in ("arm", "arm64")}
# policy file -> (binary using it, arch of that binary)
targets = [
    ("vendor/etc/seccomp_policy/codec2.vendor.base-arm.policy", "vendor/bin/hw/vendor.qti.media.c2@1.0-service", "arm"),
    ("vendor/etc/seccomp_policy/samsung.software.media.c2-base-policy", "vendor/bin/hw/samsung.software.media.c2@1.0-service", "arm64"),
]
def rules(path):
    out = {}
    for line in open(path):
        s = line.strip()
        if not s or s.startswith("#") or s.startswith("@"):
            continue
        name = s.split(":", 1)[0].strip()
        out.setdefault(name, s)
    return out
for pol, binary, arch in targets:
    pol_p, bin_p = os.path.join(wd, pol), os.path.join(wd, binary)
    assert os.path.isfile(pol_p), pol
    assert os.path.isfile(bin_p), binary
    with open(bin_p, "rb") as f:
        ident = f.read(5)
    assert ident[:4] == b"\x7fELF" and ident[4] == (1 if arch == "arm" else 2), "ELF class of " + binary
    have = set(rules(pol_p))
    # the service loads <name>base<...> plus its <name>ext<...> device policy; rules must not be duplicated
    sibling = os.path.join(os.path.dirname(pol_p), os.path.basename(pol_p).replace("base", "ext", 1))
    assert sibling != pol_p and os.path.isfile(sibling), "ext policy for " + pol
    have |= set(rules(sibling))
    want = rules(crash[arch])
    missing = [n for n in want if n not in have]
    if not missing:
        print("%s: nothing to add" % pol)
        continue
    with open(pol_p, "a") as f:
        f.write("\n# Android 17 crash_dump additions (a52sxq media_seccomp_crashdump)\n")
        for n in missing:
            f.write(want[n] + "\n")
    print("%s: added %s" % (pol, " ".join(missing)))
PYEOF
LOG "- Codec2 HAL seccomp policies allow the Android 17 crash_dump syscalls"
# The same applies to every other vendor HAL/daemon with an A14 seccomp policy (GNSS + its XTRA/xtwifi helpers, imsrtp
# (VoLTE RTP), qspm, qti-systemd, sxrhalservice, dspservice, mediaextractor_sec): a native stack dump during an ANR or a
# bugreport would kill them. Their binaries load the policy by name from libraries, so pick the arch from the policy
# content (arm-only syscalls like mmap2/_llseek/fstat64 => arm). Duplicate rules are harmless (stock files already have some).
python3 - "$WORK_DIR" << 'PYEOF' || ABORT "Failed to update the vendor seccomp policies"
import glob, os, sys
wd = sys.argv[1]
crash = {a: os.path.join(wd, "system/system/etc/seccomp_policy/crash_dump.%s.policy" % a) for a in ("arm", "arm64")}
def rules(path):
    out = {}
    for line in open(path):
        t = line.strip()
        if t and not t.startswith(("#", "@")):
            out.setdefault(t.split(":", 1)[0].strip(), t)
    return out
skip = ("codec2.vendor.", "samsung.software.media.c2-")
for pol_p in sorted(glob.glob(os.path.join(wd, "vendor/etc/seccomp_policy/*"))):
    name = os.path.basename(pol_p)
    if name.startswith(skip):
        continue
    have = rules(pol_p)
    # fragments merged with another policy (no read/write rules) are left alone, and only the syscalls the Android 17
    # crash_dump added over A14 are granted, so the sandboxes are not widened beyond what a stack dump needs
    if "read" not in have or "write" not in have:
        continue
    arch = "arm" if any(k in have for k in ("mmap2", "_llseek", "fstat64", "fcntl64")) else "arm64"
    want = rules(crash[arch])
    missing = [n for n in ("getppid", "setsockopt", "uname", "readlinkat", "recvfrom") if n in want and n not in have]
    if not missing:
        continue
    with open(pol_p, "a") as f:
        f.write("\n# Android 17 crash_dump additions (a52sxq media_seccomp_crashdump)\n")
        for n in missing:
            f.write(want[n] + "\n")
    print("%s (%s): added %s" % (name, arch, " ".join(missing)))
PYEOF
LOG "- Vendor HAL seccomp policies allow the Android 17 crash_dump syscalls"
