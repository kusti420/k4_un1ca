# Samsung's SystemServer (and a few of its services) load extra jars with `new PathClassLoader("/system/framework/X.jar",
# getSystemClassLoader())` instead of the standalone-system-server-jar mechanism. Stock compiles them at build time into
# /system/framework/oat, which this build drops (the boot image is rebuilt on device, so build-time odex would be
# kOatBootImageOutOfDate anyway). Result on every boot: system_server verifies each jar again, tries to cache an
# "anonymous vdex" next to the jar (read-only /system -> "Could not create directory /system/framework/oat") and then
# interprets/JITs them. motionrecognitionservice.jar alone is 11 MB, imsmanager (IMS/VoLTE) 650 KB.
#
# odrefresh compiles everything derive_classpath exports as STANDALONE_SYSTEMSERVER_JARS into
# /data/misc/apexdata/com.android.art/dalvik-cache, and ART's OatFileAssistant looks there first for ANY dex location
# (GetApexDataOdexFilename), so listing the jars in systemserverclasspath.pb is enough for system_server to pick up
# the compiled code. The pb is the ExportedClasspathsJars proto: Jar { path = 1; classpath = 2 (4 =
# STANDALONE_SYSTEMSERVER_JARS); min_sdk_version = 3; max_sdk_version = 4 }, repeated as field 1.
PB="$WORK_DIR/system/system/etc/classpaths/systemserverclasspath.pb"
if [ -f "$PB" ]; then
    LOG "- Listing Samsung's dynamically loaded system_server jars as STANDALONE_SYSTEMSERVER_JARS"
    python3 - "$PB" "$WORK_DIR/system/system/framework" << 'PYEOF' || ABORT "Failed to update systemserverclasspath.pb"
import os, sys
pb_path, fw = sys.argv[1], sys.argv[2]
# jars system_server loads by hand on this source (from the "Could not write anonymous vdex" list on a booted device)
CANDIDATES = ["imsmanager.jar", "hcm.jar", "hqm.jar", "knox_mtd.jar", "semcontextservice.jar",
              "motionrecognitionservice.jar", "perfsdkservice.jar", "secinputdev-service.jar", "gamemanager.jar",
              "CloService.jar", "displayaiqe_svc.jar", "vendor.samsung.frameworks.codecsolution-service.jar",
              "vendor.samsung.frameworks.hdrsolution-service.jar", "semuwb-service.jar"]
data = open(pb_path, "rb").read()

def rvar(b, i):
    r = s = 0
    while True:
        c = b[i]; i += 1; r |= (c & 0x7f) << s; s += 7
        if not c & 0x80: return r, i
def wvar(v):
    out = bytearray()
    while True:
        c = v & 0x7f; v >>= 7
        if v: out.append(c | 0x80)
        else: out.append(c); return bytes(out)
def jar_msg(path, classpath):
    p = path.encode()
    body = b"\x0a" + wvar(len(p)) + p + b"\x10" + wvar(classpath)
    return b"\x0a" + wvar(len(body)) + body

# existing entries (sanity check + skip duplicates)
present = set(); i = 0
while i < len(data):
    tag, i = rvar(data, i)
    if tag != 0x0a: sys.exit("unexpected top-level tag 0x%x" % tag)
    ln, i = rvar(data, i); jar = data[i:i+ln]; i += ln
    j = 0
    while j < len(jar):
        t, j = rvar(jar, j)
        if t & 7 == 2:
            l, j = rvar(jar, j)
            if t >> 3 == 1: present.add(jar[j:j+l].decode())
            j += l
        else:
            _, j = rvar(jar, j)
added = []
for name in CANDIDATES:
    path = "/system/framework/" + name
    if not os.path.isfile(os.path.join(fw, name)) or path in present: continue
    data += jar_msg(path, 4); added.append(name)
open(pb_path, "wb").write(data)
print("  - Added %d jars: %s" % (len(added), " ".join(added)))
PYEOF
else
    LOG "- systemserverclasspath.pb not found, skipping"
fi
# Keep system_server and these jars fully compiled: with Samsung's (regenerated) services.jar.prof present odrefresh
# would otherwise switch to speed-profile and compile only the profiled methods.
SET_PROP "system" "dalvik.vm.systemservercompilerfilter" "speed"
unset PB
