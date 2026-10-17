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

# 2. LayeredEngine (f3.a): minute ticker follows visibility; stopped in onDestroy.
f = one("f3/a.smali")
s = open(f).read()
assert s.startswith(".class public final Lf3/a;\n.super Lcom/samsung/android/wallpaper/live/sdk/service/switchable/d;"), "f3.a: not the LayeredEngine"
assert ".field public final g:Lh3/a;" in s and "->b(Landroid/view/SurfaceHolder;)V" in s, "f3.a: presenter field / draw method changed"
for sig, call in ((".method public final onVisibilityChanged(Z)V\n", "invoke-static {p0, p1}, %s->onVisibility(Lf3/a;Z)V" % HDC),
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

# 3. helper classes into the last dex
for old in glob.glob(root + "/smali*/com/k4/homeclock"):
    shutil.rmtree(old)
dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
dst = os.path.join(dirs[-1] if dirs else root + "/smali", "com/k4/homeclock")
shutil.copytree(os.path.join(helpers, "com/k4/homeclock"), dst)
print("  - %d helper classes -> %s" % (len(os.listdir(dst)), os.path.relpath(dst, root)))
PYEOF
unset SPRITE
