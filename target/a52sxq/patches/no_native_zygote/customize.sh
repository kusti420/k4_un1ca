# Android 17 runs services that are both android:nativeService and isolatedProcess in the new native zygote
# (zygote_next). On this port zygote_next starts but never sets zygote.zygote_next.server_ready, so the
# ActivityManager procStart thread waits on it until the watchdog kills system_server ("Blocked in handler on
# ActivityManager:procStart for 70s"): a soft reboot. Chrome declares such services
# (NativeOnlySandboxedProcessService0/1); when it uses them its GPU process never starts, Chrome aborts with
# "Timed out waiting for GPU channel" and the phone restarts its UI a minute later.
# Chrome falls back to its regular sandbox when that bind fails, so resolve native isolated services as
# "not found" and keep ServiceRecord from routing to or prewarming the native zygote.
DECODE_APK "system" "system/framework/services.jar"
python3 - "$APKTOOL_DIR/system/framework/services.jar" << 'PYEOF' || ABORT "Failed to apply the native zygote patch"
import glob, re, sys
root = sys.argv[1]

def one(pattern):
    f = glob.glob(root + "/smali*/" + pattern)
    assert len(f) == 1, pattern
    return f[0]

# 1. ActiveServices.retrieveServiceLocked: right after the resolved ServiceInfo is taken from the ResolveInfo,
#    treat FLAG_NATIVE_SERVICE (0x20) | FLAG_ISOLATED_PROCESS (0x2) as unresolved. The existing ":not found"
#    branch then logs and returns null, so bindService returns false.
f = one("com/android/server/am/ActiveServices.smali")
s = open(f).read()
start = s.index(".method public final retrieveServiceLocked(")
end = s.index(".end method", start)
body = s[start:end]
pat = re.compile(r"(\n    iget-object (v\d+), \2, Landroid/content/pm/ResolveInfo;->serviceInfo:Landroid/content/pm/ServiceInfo;\n"
                 r"\n?    move-object (v\d+), \2\n)(\n?    goto(?:/16)? (:goto_\w+)\n)")
m = list(pat.finditer(body))
assert len(m) == 1, "retrieveServiceLocked resolve block: %d" % len(m)
m = m[0]
tmp, info, target = m.group(2), m.group(3), m.group(5)
nul = re.search(r"\n    const/16 (v\d+), 0x0\n", body[:m.start()])
assert nul, "null register"
guard = (m.group(1) +
         "\n    if-eqz %(i)s, :unica_native_ok\n"
         "\n    iget %(t)s, %(i)s, Landroid/content/pm/ServiceInfo;->flags:I\n"
         "\n    and-int/lit8 %(t)s, %(t)s, 0x22\n"
         "\n    xor-int/lit8 %(t)s, %(t)s, 0x22\n"
         "\n    if-nez %(t)s, :unica_native_ok\n"
         "\n    move-object/from16 %(i)s, %(n)s\n"
         "\n    :unica_native_ok\n" % {"i": info, "t": tmp, "n": nul.group(1)} +
         m.group(4))
body = body[:m.start()] + guard + body[m.end():]
s = s[:start] + body + s[end:]
open(f, "w").write(s)

# 2. ServiceRecord.<init>: never mark a record native-isolated, so it is neither prewarmed nor started in zygote_next.
f = one("com/android/server/am/ServiceRecord.smali")
s = open(f).read()
s, n = re.subn(r"(\n    and-int/lit8 (\w+), \w+, 0x20\n\n?    if-eqz \2, (:cond_\w+)\n)", r"\n    goto \3\n\1", s, count=1)
assert n == 1, "ServiceRecord native isolated check"
assert "iput-boolean" in s and "mIsNativeIsolated:Z" in s, "mIsNativeIsolated"
open(f, "w").write(s)
PYEOF
LOG "- Native isolated services resolved as not found, zygote_next never used"
