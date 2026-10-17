# See module.prop. smali/com/k4/homeclock/*.smali is generated from src/ (src/build.sh: javac + d8 + baksmali, stubs in src/stubs).
SPRITE="system/priv-app/SpriteWallpaper/SpriteWallpaper.apk"
DECODE_APK "system" "$SPRITE" || ABORT "Failed to decode $SPRITE"
LOG "- Home-screen depth clock in the layered wallpaper engine (off unless persist.sys.k4.home_depth_clock=1)"
python3 - "$APKTOOL_DIR/system/${SPRITE//system\//}" "$SRC_DIR/target/a52sxq/patches/home_depth_clock/smali" << 'PYEOF' || ABORT "Failed to apply the home depth clock"
import glob, os, re, shutil, sys
root, helpers = sys.argv[1], sys.argv[2]
SRC_B = "Lcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;"
HDC = "Lcom/k4/homeclock/HomeDepthClock;"

def one(pattern):
    hits = glob.glob(root + "/smali*/" + pattern)
    assert len(hits) == 1, "%s: %d" % (pattern, len(hits))
    return hits[0]

def regnum(r, nlocals):
    return int(r[1:]) + (nlocals if r[0] == "p" else 0)

# 1. WallpaperEngineFactory (c3.a.a): after `new h3.d(context, which, wallpaperId, source)` (FlattenLayeredPresenter,
#    the home path) let HomeDepthClock.presenter() return the clock presenter instead when it is switched on.
f = one("c3/a.smali")
s = open(f).read()
if HDC + "->presenter(" in s:
    print("  - engine factory already hooked")
else:
    m = re.search(r"\.method public static a\(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/sdk/service/switchable/e;\)"
                  r"Lcom/samsung/android/wallpaper/live/sdk/service/switchable/d;\n    \.(locals|registers) (\d+)\n", s)
    assert m, "c3.a.a: factory method changed"
    nlocals = int(m.group(2)) - (3 if m.group(1) == "registers" else 0)
    pat = re.compile(r"(    invoke-direct \{(\w+), (\w+), (\w+), \w+, (\w+)\}, Lh3/d;-><init>\(Landroid/content/Context;II" + re.escape(SRC_B) + r"\)V\n)")
    hits = pat.findall(s)
    assert len(hits) == 1, "c3.a.a: new h3.d(...): %d" % len(hits)
    full, pres, ctx, which, src = hits[0]
    assert ctx == "p0" and which == "p1", "c3.a.a: unexpected h3.d arguments %s %s" % (ctx, which)
    assert all(regnum(r, nlocals) < 16 for r in (pres, ctx, which, src)), "c3.a.a: registers out of 4-bit range"
    call = ("\n    invoke-static {%s, %s, %s, %s}, %s->presenter(Lh3/a;Landroid/content/Context;I%s)Lh3/a;\n\n"
            "    move-result-object %s\n" % (pres, ctx, which, src, HDC, SRC_B, pres))
    s = s.replace(full, full + call, 1)
    open(f, "w").write(s)
    print("  - c3.a.a: home FlattenLayeredPresenter -> HomeDepthClock.presenter()")

# 2. AbstractLayeredPresenter.updateSurfaceSize (h3.a.e): right after the layer list is built (this.a(source, w, h,
#    data)), HomeDepthClock.afterBuild(this) adds the gated clock to a shared home+lock instance's h3.b.
f = one("h3/a.smali")
s = open(f).read()
assert s.startswith(".class public abstract Lh3/a;\n"), "h3.a: not the abstract layered presenter"
m = re.search(r"^\.method public e\(II\)V\n.*?^\.end method\n", s, re.M | re.S)
assert m, "h3.a.e(II)V"
body = m.group(0)
call = "    invoke-static {p0}, %s->afterBuild(Lh3/a;)V\n" % HDC
if call in body:
    print("  - h3.a.e already hooked")
else:
    pat = re.compile(r"(    invoke-virtual \{p0, \w+, \w+, \w+, \w+\}, Lh3/a;->a\(" + re.escape(SRC_B) + r"IILg0/a;\)V\n)")
    assert len(pat.findall(body)) == 1, "h3.a.e: build call: %d" % len(pat.findall(body))
    s = s.replace(body, pat.sub(lambda g: g.group(1) + "\n" + call, body), 1)
    open(f, "w").write(s)
    print("  - h3.a.e: layer list built -> HomeDepthClock.afterBuild()")
assert re.search(r"^\.field public final c:I$", s, re.M) and re.search(r"^\.field public e:Lg0/a;$", s, re.M), "h3.a fields changed"
assert re.search(r"^\.class public final Lh3/b;\n\.super Lh3/f;$", open(one("h3/b.smali")).read(), re.M), "h3.b is not the BgCachableLayeredPresenter"

# 3. LayeredEngine (f3.a): engine state (reload receiver, minute ticker) from onCreate to onDestroy.
f = one("f3/a.smali")
s = open(f).read()
assert s.startswith(".class public final Lf3/a;\n.super Lcom/samsung/android/wallpaper/live/sdk/service/switchable/d;"), "f3.a: not the LayeredEngine"
assert ".field public final g:Lh3/a;" in s and "->b(Landroid/view/SurfaceHolder;)V" in s, "f3.a: presenter field / draw method changed"
sw = open(one("com/samsung/android/wallpaper/live/sdk/service/switchable/d.smali")).read()
for m_ in ("stopSelf()V", "getDisplayState()LB2/a;", "getWhich()I", "getAppContext()Landroid/content/Context;"):
    assert re.search(r"^\.method public %s$" % re.escape(m_), sw, re.M), "switchable.d." + m_
for sig, call in ((".method public final onCreate(Landroid/view/SurfaceHolder;)V\n", "invoke-static {p0}, %s->onCreate(Lf3/a;)V" % HDC),
                  (".method public final onVisibilityChanged(Z)V\n", "invoke-static {p0, p1}, %s->onVisibility(Lf3/a;Z)V" % HDC),
                  (".method public final onDestroy()V\n", "invoke-static {p0}, %s->onDestroy(Lf3/a;)V" % HDC)):
    assert s.count(sig) == 1, "f3.a: %s" % sig.strip()
    i = s.index(sig) + len(sig)
    m = re.match(r"    \.(?:locals|registers) \d+\n\n", s[i:])
    assert m, "f3.a: no .locals line in %s" % sig.strip()
    j = i + m.end()
    line = "    " + call + "\n\n"
    if s[j:].startswith(line):
        print("  - f3.a.%s already hooked" % sig.split()[3].split("(")[0])
        continue
    s = s[:j] + line + s[j:]
    print("  - f3.a.%s -> HomeDepthClock" % sig.split()[3].split("(")[0])
open(f, "w").write(s)

# 4. helper classes into the last dex
for old in glob.glob(root + "/smali*/com/k4/homeclock"):
    shutil.rmtree(old)
dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
dst = os.path.join(dirs[-1] if dirs else root + "/smali", "com/k4/homeclock")
shutil.copytree(os.path.join(helpers, "com/k4/homeclock"), dst)
print("  - %d helper classes -> %s" % (len(os.listdir(dst)), os.path.relpath(dst, root)))

# 5. AodClockNode loads Samsung's AOD lock-screen clock plugin in-process (AodHost). The permissions LockStar holds for
#    the clockpack data, so the AOD clock code reading lock-screen data from our process is not refused. The app is
#    re-signed with the ROM platform key, so the signature|privileged ones are also allowlisted (step 6).
f = os.path.join(root, "AndroidManifest.xml")
s = open(f).read()
assert 'package="com.samsung.android.wallpaper.live"' in s, "SpriteWallpaper manifest"
add = [p for p in ("com.samsung.android.app.clockpack.LOCK_PROVIDER",
                   "com.samsung.android.app.aodservice.permission.AOD_PROVIDER",
                   "com.samsung.android.app.aodservice.permission.ACCESS_LOCK_SCREEN_DATA",
                   "com.samsung.android.clockpack.permission.ACCESS_CLOCK_PROVIDER")
       if 'android:name="%s"' % p not in s]
if add:
    i = s.index("<uses-permission ")
    s = s[:i] + "".join('<uses-permission android:name="%s"/>\n    ' % p for p in add) + s[i:]
    open(f, "w").write(s)
print("  - manifest: %s" % (", ".join(p.rsplit(".", 1)[1] for p in add) if add else "AOD clock permissions already requested"))
PYEOF

# 6. priv-app allowlist (ro.control_privapp_permissions=enforce) for the signature|privileged AOD clock permissions above
PRIVAPP="$WORK_DIR/system/system/etc/permissions/privapp-permissions-com.samsung.android.wallpaper.live.xml"
[ -f "$PRIVAPP" ] || ABORT "File not found: ${PRIVAPP//$WORK_DIR/}"
python3 - "$PRIVAPP" << 'PYEOF' || ABORT "Failed to patch ${PRIVAPP//$WORK_DIR/}"
import sys
f = sys.argv[1]
s = open(f).read()
tag = '<privapp-permissions package="com.samsung.android.wallpaper.live">'
assert s.count(tag) == 1, "privapp-permissions block for com.samsung.android.wallpaper.live"
add = [p for p in ("com.samsung.android.app.clockpack.LOCK_PROVIDER",
                   "com.samsung.android.app.aodservice.permission.AOD_PROVIDER",
                   "com.samsung.android.app.aodservice.permission.ACCESS_LOCK_SCREEN_DATA")
       if '"%s"' % p not in s]
if add:
    i = s.index(tag) + len(tag)
    s = s[:i] + "".join('\n        <permission name="%s"/>' % p for p in add) + s[i:]
    open(f, "w").write(s)
print("  - privapp allowlist: %s" % (", ".join(p.rsplit(".", 1)[1] for p in add) if add else "already there"))
PYEOF
unset SPRITE PRIVAPP

# Wallpaper & style (DressRoom): the clock item in the Home "Set as wallpaper" editor (see dressroom.sh)
# shellcheck source=/dev/null
source "$SRC_DIR/target/a52sxq/patches/home_depth_clock/dressroom.sh"
