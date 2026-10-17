# Home screen depth clock inside Wallpaper & style (DressRoom): the Home "Set as wallpaper" editor shows Samsung's own
# lock clock item (guide box, drag, resize, tap -> clock panel) behind the cut-out subject, with a "Clock" entry in the
# editor's menu. See dressroom/src/com/k4/dressroom/HomeClock.java for what each hook does. Sourced from customize.sh.
# Built on the DressRoom the phone runs from the Galaxy Store (3.0.10.38, prebuilts/samsung_store_apps): a Store copy
# in /data/app would shadow a patched system APK, so the patched one ships as the system priv-app with a versionCode
# above the Store's (DRESSROOM_VERSION_CODE); PackageManager drops the /data update at boot (same version line, no
# downgrade of its data) and the Store stops offering updates. Classes are found by log text, every member asserted.
DRESSROOM="system/priv-app/DressRoom/DressRoom.apk"
DRESSROOM_SRC="$SRC_DIR/target/a52sxq/patches/home_depth_clock/dressroom"
DRESSROOM_VERSION_CODE="1301038000"
# The Galaxy Store build the phone runs, Samsung-signed, stored like the other Store APKs we ship
DRESSROOM_APK="$SRC_DIR/prebuilts/samsung_store_apps/DressRoom_3.0.10.38.apk"
DRESSROOM_SHA="f493af985544c1f08b6146a0d3d71c40b9e2c7e5161e102f9b8619f712a90600"
[ -f "$DRESSROOM_APK" ] || ABORT "home_depth_clock: $DRESSROOM_APK not found"
[ "$(sha256sum "$DRESSROOM_APK" | cut -d " " -f 1)" = "$DRESSROOM_SHA" ] || ABORT "home_depth_clock: sha256 mismatch for $DRESSROOM_APK"
[ -f "$WORK_DIR/system/$DRESSROOM" ] || ABORT "home_depth_clock: no $DRESSROOM in this base"
EVAL "cp -f \"$DRESSROOM_APK\" \"$WORK_DIR/system/$DRESSROOM\""
DECODE_APK "system" "$DRESSROOM" || ABORT "Failed to decode $DRESSROOM"
LOG "- Clock in the Home screen wallpaper editor (DressRoom)"
python3 - "$APKTOOL_DIR/system/${DRESSROOM//system\//}" "$DRESSROOM_SRC/smali" "$DRESSROOM_SRC/res" \
    "$DRESSROOM_VERSION_CODE" << 'PYEOF' || ABORT "Failed to add the home clock to DressRoom"
import glob, os, re, shutil, sys
root, helpers, res, version_code = sys.argv[1:5]
HC = "Lcom/k4/dressroom/HomeClock;"

def by_text(text, sub="smali*"):
    hits = [f for f in glob.glob(root + "/%s/**/*.smali" % sub, recursive=True) if text in open(f).read()]
    assert len(hits) == 1, "%r: %d classes" % (text, len(hits))
    return hits[0]

def cls(f):
    return re.match(r"\.class [^\n]*?(L[^;\s]+;)", open(f).read()).group(1)

def method(s, sig):
    m = re.search(r"^\.method %s\n.*?^\.end method\n" % re.escape(sig), s, re.M | re.S)
    assert m, sig
    return m.group(0)

def nlocals(body):
    return int(re.search(r"^    \.locals (\d+)$", body, re.M).group(1))

def low(body, reg):
    return int(reg[1:]) + (nlocals(body) if reg[0] == "p" else 0) < 16

def patch(f, sig, fn, what):
    s = open(f).read()
    body = method(s, sig)
    if HC in body:
        print("  - %s already hooked" % what)
        return
    new = fn(body)
    assert new != body and HC in new, what
    open(f, "w").write(s.replace(body, new, 1))
    print("  - %s" % what)

def call_after(body, anchor_re, call, what):
    hits = re.findall(anchor_re, body)
    assert len(hits) == 1, "%s: anchor %d" % (what, len(hits))
    return re.sub(anchor_re, lambda m: m.group(0) + "\n" + call, body, 1)

# 1. ComponentMediator.<init>: which (h) / isCover (j) are parsed before the "parseIntent:  Which: " log
f = by_text('"generateComponents: Generate Lockscreen and Homescreen components."')
med = cls(f)
s = open(f).read()
for fld in (".field public f:Landroid/view/View;", ".field public g:Landroid/view/View;", ".field public final h:I", ".field public final j:Z"):
    assert fld in s, "ComponentMediator " + fld
sig = re.search(r"^\.method public constructor (<init>\(Lcom/samsung/android/app/dressroom/presentation/preview/activity/EditBaseActivity;\)V)$", s, re.M)
assert sig, "ComponentMediator.<init>(EditBaseActivity)"
def h1(body):
    a = '    const-string v6, "parseIntent:  Which: "\n'
    assert body.count(a) == 1 and low(body, "p0"), "parseIntent log"
    return body.replace(a, "    invoke-static {p0}, %s->begin(%s)V\n\n" % (HC, med) + a, 1)
patch(f, "public constructor " + sig.group(1), h1, "ComponentMediator.<init> -> HomeClock.begin")
# ... and at the end of w(Bundle), once every component is set up
def h2(body):
    # p0 is reused as a scratch register inside w(): keep `this` in one extra local for the call at the end
    rets = body.count("    return-void\n")
    n = nlocals(body)
    assert rets == 1 and n + 2 <= 16, "ComponentMediator.w: %d returns, %d locals" % (rets, n)
    body = body.replace("    .locals %d\n\n" % n, "    .locals %d\n\n    move-object v%d, p0\n\n" % (n + 1, n), 1)
    return body.replace("    return-void\n", "    invoke-static {v%d}, %s->afterComponents(%s)V\n\n    return-void\n" % (n, HC, med))
patch(f, "public final w(Landroid/os/Bundle;)V", h2, "ComponentMediator.w -> HomeClock.afterComponents")

# 2. ItemEditorController / BlurItemController: their item set (Set) goes through HomeClock.filter
for text, what in (('"inflateEditor: "', "ItemEditorController"), ('"BlurItemController"', "BlurItemController")):
    f = by_text(text)
    c = cls(f)
    s = open(f).read()
    sig = re.findall(r"^\.method public constructor (<init>\([^)]*Ljava/util/Set;[^)]*\)V)$", s, re.M)
    assert len(sig) == 1, what + " constructor"
    def hs(body, c=c, what=what):
        m = re.findall(r"    iput-object (\w+), \w+, %s->\w+:Ljava/util/Set;\n" % re.escape(c), body)
        assert len(m) == 1 and low(body, m[0]), what + ": Set store"
        reg = m[0]
        store = re.search(r"    iput-object %s, \w+, %s->\w+:Ljava/util/Set;\n" % (reg, re.escape(c)), body).group(0)
        call = "    invoke-static {%s}, %s->filter(Ljava/util/Set;)Ljava/util/Set;\n\n    move-result-object %s\n\n" % (reg, HC, reg)
        return body.replace(store, call + store, 1)
    patch(f, "public constructor " + sig[0], hs, "%s.<init> -> HomeClock.filter" % what)
assert any("Lmf/o0;" in l for l in open(by_text('"inflateEditor: "')).read().splitlines()) or glob.glob(root + "/smali*/mf/o0.smali"), "mf.o0 (clock item data)"

# 3. WALLPAPER menu: one more slot (DesignPreviewController.V1) and the Clock entry in it (EffectPreviewController.U1)
f = by_text('"getEffectMenuItemsCount: "')
eff = cls(f)
def hu(body):
    a = "    :goto_4\n    iget-object p0, p0, Lo6/e0;->T0:Lp8/i;\n"
    if body.count(a) != 1:
        raise AssertionError("U1: menu hand-off")
    return body.replace(a, "    :goto_4\n    invoke-static {p0, v0}, %s->addMenu(Lo6/e0;[Lk6/m;)V\n\n    iget-object p0, p0, Lo6/e0;->T0:Lp8/i;\n" % HC, 1)
patch(f, "public final U1()[Lk6/m;", hu, "EffectPreviewController.U1 -> HomeClock.addMenu")
f = [x for x in glob.glob(root + "/smali*/e7/*.smali") if re.search(r"^\.method public final V1\(\)I$", open(x).read(), re.M)]
assert len(f) == 1, "V1: %d" % len(f)
def hv(body):
    rets = re.findall(r"    return (\w+)\n", body)
    assert len(rets) == 2 and rets[0] == "p0", "V1 returns %s" % rets
    r = rets[1]
    return body.replace("    return %s\n" % r, "    invoke-static {%s}, %s->menuSize(I)I\n\n    move-result %s\n\n    return %s\n" % (r, HC, r, r), 1)
patch(f[0], "public final V1()I", hv, "DesignPreviewController.V1 -> HomeClock.menuSize")
s = open(glob.glob(root + "/smali*/o6/e0.smali")[0]).read()
assert ".field public final M:Landroid/app/Activity;" in s and ".field public T0:Lp8/i;" in s, "o6.e0 fields"
s = open(by_text('"setMenuItemActivated: null menu"')).read()
assert cls(by_text('"setMenuItemActivated: null menu"')) == "Lp8/i;" and ".method public final g(Ljava/lang/String;Z)V" in s, "EditorMenuMediator.g"
km = open(glob.glob(root + "/smali*/k6/m.smali")[0]).read()
assert ".field public j:Z" in km and ".method public constructor <init>(IILjava/lang/Runnable;Ljava/lang/String;)V" in km, "k6.m"

# 3b. Menu bar scroll mode (v8.y.a: phone + more than 4 entries -> scrolling bar): not for the Home editor's 5 entries
f = [x for x in glob.glob(root + "/smali*/v8/*.smali") if "edit_button_container_width" in open(x).read() and re.search(r"^\.method public a\(\)Z$", open(x).read(), re.M)]
assert len(f) == 1, "menu bar class: %d" % len(f)
def hm(body):
    a_ = "    const/4 v0, 0x4\n\n    if-le p0, v0, :cond_1\n\n    const/4 p0, 0x1\n\n    return p0\n"
    assert body.count(a_) == 1, "menu bar a(): more-than-4 branch"
    return body.replace(a_, "    const/4 v0, 0x4\n\n    if-le p0, v0, :cond_1\n\n    invoke-static {}, %s->menuScrolls()Z\n\n    move-result p0\n\n    return p0\n" % HC, 1)
patch(f[0], "public a()Z", hm, "menu bar a() -> HomeClock.menuScrolls")
assert ".field public b:I" in km, "k6.m.b (icon)"

# 4. NotifyObjectFinish (y7.d.c): Samsung's subject segmentation result -> subject above the clock
f = by_text('"intersect result is empty"')
s = open(f).read()
sig = re.findall(r"^\.method public static (c\(Lcom/samsung/android/app/dressroom/presentation/preview/widget/CropImageView;L[^;]+;Landroid/graphics/Bitmap;\)V)$", s, re.M)
assert len(sig) == 1, "NotifyObjectFinish.c"
def ho(body):
    # at the start, while p0..p2 (CropImageView, result, bitmap) are still the parameters
    n = nlocals(body)
    assert n + 3 <= 16, "NotifyObjectFinish.c locals"
    hdr = "    .locals %d\n\n" % n
    assert body.count(hdr) == 1
    return body.replace(hdr, hdr + "    invoke-static {p0, p1, p2}, %s->onObject(Landroid/view/View;Ljava/lang/Object;Landroid/graphics/Bitmap;)V\n\n" % HC, 1)
patch(f, "public static " + sig[0], ho, "NotifyObjectFinish.c -> HomeClock.onObject")
assert re.search(r"^\.method public final a\(Ljava/lang/Boolean;\)Z$", open(glob.glob(root + "/smali*/d7/m.smali")[0]).read(), re.M), "d7.m.a(Boolean) (object saved?)"
m8 = open(glob.glob(root + "/smali*/m8/c.smali")[0]).read()
for fld in (".field public h:Landroid/graphics/RectF;", ".field public i:Landroid/graphics/Bitmap;", ".field public j:Landroid/graphics/Rect;"):
    assert fld in m8, "m8.c " + fld
assert ".field public static c:Lm8/c;" in open(glob.glob(root + "/smali*/q8/m.smali")[0]).read(), "q8.m.c"

# 5. LockScreenComponent.Y: the lock save is skipped for a Home-only apply -> HomeClock.onHomeSave
f = by_text('"save skipped isLockPreviewScreenExists:"')
s = open(f).read()
assert re.search(r"^\.field public g0:Lmf/o0;$", s, re.M), "LockScreenComponent.g0"
def hsave(body):
    a = r"    invoke-static \{(v\d+), v\d+, v\d+\}, Loc/d;->k\(Loc/c;Ljava/lang/String;Ljava/lang/String;\)V\n"
    i = body.index('"save skipped isLockPreviewScreenExists:"')
    m = re.compile(a).search(body, i)
    assert m and m.start() - i < 400 and int(m.group(1)[1:]) < 16, "save skip log"
    return body[:m.end()] + "\n    invoke-static {%s}, %s->onHomeSave(Ljava/lang/Object;)V\n" % (m.group(1), HC) + body[m.end():]
patch(f, "public final Y(Lk6/s;Lj6/d;)V", hsave, "LockScreenComponent.Y -> HomeClock.onHomeSave")

# 5b. ClockStoreRepositoryImpl.c(String) (the clock item the clock editor starts from): remember the store at the
#     start (p0 is reused later), and pass every returned item through HomeClock.seedItem (saved home clock)
f = by_text('"ClockStoreRepositoryImpl"')
s = open(f).read()
for fld in (".field public final a:Landroid/content/Context;", ".field public final c:Ljavax/inject/Provider;"):
    assert fld in s, "ClockStoreRepositoryImpl " + fld
CI = "Lcom/samsung/android/sdk/aodservice/entities/item/ClockItem;"
assert re.search(r"^\.method public final d\(Lcom/samsung/android/lockscreen/editor/item/domain/entity/item/common/LockScreenItemData;Ljava/lang/String;Landroid/os/Bundle;\)Lcom/samsung/android/sdk/aodservice/entities/item/LockScreenItem;$", s, re.M), "makeLockScreenItem"
def hc(body):
    n = nlocals(body)
    assert n + 2 <= 16
    hdr = "    .locals %d\n\n" % n
    body = body.replace(hdr, hdr + "    invoke-static {p0}, %s->storeSeen(Ljava/lang/Object;)V\n\n" % HC, 1)
    def ret(m):
        r = m.group(1)
        return ("    invoke-static {%s}, %s->seedItem(Ljava/lang/Object;)Ljava/lang/Object;\n\n    move-result-object %s\n\n"
                "    check-cast %s, %s\n\n    return-object %s\n") % (r, HC, r, r, CI, r)
    new, k = re.subn(r"    return-object (\w+)\n", ret, body)
    assert k >= 1
    return new
patch(f, "public final c(Ljava/lang/String;)" + CI, hc, "ClockStoreRepositoryImpl.c -> HomeClock.storeSeen/seedItem")
# the item JSON goes through the lock editor's own serializer: LockScreenRemoteItemStoreImpl.b -> .c -> serializer.b (Gson)
q = open(by_text('"LockScreenRemoteItemStoreImpl"')).read()
assert re.search(r"^\.field public final b:Lji/d;$", q, re.M), "LockScreenRemoteItemStoreImpl.b"

# 5d. the saved home clock's place and stretch heights (Samsung keeps them per wallpaper in a WallpaperClockBundle):
#     WallpaperClockBundleRepository get/put (cd.c.o / cd.c.l) -> HomeClock.bundle / bundlePut, and the not-reedit stretch
#     reset of ManageLifeCycleClockDataUseCase (mf.t1, r = !isReeditCase()) -> HomeClock.reedit
WCB = "Lcom/samsung/android/lockscreen/editor/item/domain/entity/item/clock/wallpaperbundle/WallpaperClockBundle;"
f = by_text('"] get: id="')
def hb(body):
    n = nlocals(body)
    hdr = "    .locals %d\n\n" % n
    a = "    invoke-static {p0, p1}, Loc/d;->b(Loc/c;Ljava/lang/String;)V\n\n    return-object v0\n"
    assert n + 1 + 2 <= 16 and body.count(hdr) == 1 and body.count(a) == 1 and body.count("return-object") == 1, "bundle get"
    # the id (p1 is reused for the log text): kept in one extra local from the start
    body = body.replace(hdr, "    .locals %d\n\n    move-object v%d, p1\n\n" % (n + 1, n), 1)
    return body.replace(a, a.replace("    return-object v0\n", "    invoke-static {p0, v%d, v0}, %s->bundle(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/Object;\n\n"
                                     "    move-result-object v0\n\n    check-cast v0, %s\n\n    return-object v0\n" % (n, HC, WCB)), 1)
patch(f, "public final o(Ljava/lang/String;)" + WCB, hb, "WallpaperClockBundleRepository.o -> HomeClock.bundle")
def hp(body):
    hdr = "    .locals %d\n\n" % nlocals(body)
    assert body.count(hdr) == 1
    return body.replace(hdr, hdr + "    invoke-static {p0, p1}, %s->bundlePut(Ljava/lang/Object;Ljava/lang/String;)V\n\n" % HC, 1)
patch(f, "public final l(Ljava/lang/String;%s)V" % WCB, hp, "WallpaperClockBundleRepository.l -> HomeClock.bundlePut")
f = by_text('"ManageLifeCycleClockDataUseCase"')
def hr(body):
    a = ("    invoke-virtual {v1}, Lcom/samsung/android/lockscreen/editor/item/domain/entity/preview/EntryInfo;->isReeditCase()Z\n\n"
         "    move-result v1\n\n    xor-int/lit8 v1, v1, 0x1\n\n    iput-boolean v1, v0, Lmf/t1;->r:Z\n")
    assert body.count(a) == 1, "ManageLifeCycleClockData: r = !isReeditCase()"
    return body.replace(a, a.replace("    move-result v1\n\n", "    move-result v1\n\n    invoke-static {v1}, %s->reedit(Z)Z\n\n    move-result v1\n\n" % HC), 1)
patch(f, "public final c(Lgf/c;)V", hr, "ManageLifeCycleClockDataUseCase.c -> HomeClock.reedit")
# ... and the automatic clock place / stretch suggestion for a new picture (ClockPositionSuggestion, "not reedit case")
f = by_text('"not reedit case"')
def hq(body):
    a = "    invoke-virtual {v7}, Lcom/samsung/android/lockscreen/editor/item/domain/entity/preview/EntryInfo;->isReeditCase()Z\n\n    move-result v7\n"
    assert body.count(a) == 1, "suggestion policy: isReeditCase"
    return body.replace(a, a + "\n    invoke-static {v7}, %s->reedit(Z)Z\n\n    move-result v7\n" % HC, 1)
patch(f, "public final a(Lke/e;)V", hq, "ClockPositionSuggestion reedit check -> HomeClock.reedit")
yb = open(glob.glob(root + "/smali*/yc/b0.smali")[0]).read()
assert re.search(r"^\.method public static b\(Lcom/samsung/android/lockscreen/editor/item/domain/entity/item/clock/ClockData;\)%s$" % re.escape(WCB), yb, re.M), "yc.b0.b (bundle from ClockData)"

# 5c. Home editor zoom-out + rotation (EditXf): CropImageView touch / pinch, MaskImageView draw, SaveImageMaker save
XF = "Lcom/k4/dressroom/EditXf;"
W = "com/samsung/android/app/dressroom/presentation/preview/widget/"
def one(path):
    hits = glob.glob(root + "/smali*/" + path)
    assert len(hits) == 1, "%s: %d" % (path, len(hits))
    return hits[0]
def xpatch(f, sig, fn, what):
    s = open(f).read()
    body = method(s, sig)
    if XF in body:
        print("  - %s already hooked" % what)
        return
    new = fn(body)
    assert new != body and XF in new, what
    open(f, "w").write(s.replace(body, new, 1))
    print("  - %s" % what)
def at_start(call, regs_max):
    def fn(body):
        n = nlocals(body)
        assert n + regs_max <= 16, "locals %d" % n
        hdr = "    .locals %d\n\n" % n
        assert body.count(hdr) == 1
        return body.replace(hdr, hdr + call, 1)
    return fn
f = one(W + "CropImageView.smali")
s = open(f).read()
for fld in (".field public C:Z", ".field public D:Z", ".field public E:Z", ".field public x:F", ".field public R:Lv9/i;"):
    assert fld in s, "CropImageView " + fld
for m in ("public final getDrawableInner()Landroid/graphics/drawable/Drawable;", "public final getDrawableBounds()Landroid/graphics/RectF;",
          "public final getDrawableOriginScaledBounds()Landroid/graphics/RectF;"):
    assert re.search(r"^\.method %s$" % re.escape(m), s, re.M), "CropImageView." + m
xpatch(f, "public final onTouchEvent(Landroid/view/MotionEvent;)Z", at_start(
    "    invoke-static {p0, p1}, %s->touch(Landroid/view/View;Landroid/view/MotionEvent;)Landroid/view/MotionEvent;\n\n    move-result-object p1\n\n" % XF, 2),
    "CropImageView.onTouchEvent -> EditXf.touch")
xpatch(f, "public final N(F)V", at_start(
    "    invoke-static {p0, p1}, %s->scale(Landroid/view/View;F)F\n\n    move-result p1\n\n" % XF, 2), "CropImageView.N -> EditXf.scale")
f = one(W + "MaskImageView.smali")
def hdraw(body):
    a = "    :try_start_0\n    invoke-super {p0, p1}, Landroid/widget/ImageView;->onDraw(Landroid/graphics/Canvas;)V\n    :try_end_0\n"
    assert body.count(a) == 1 and "    :goto_0\n    invoke-virtual {p1, v3}, Landroid/graphics/Canvas;->restoreToCount(I)V\n\n    sget-boolean v0," in body, "MaskImageView.onDraw: super call"
    return body.replace(a, "    :try_start_0\n    invoke-static {p0, p1}, %s->draw(Landroid/view/View;Landroid/graphics/Canvas;)Z\n\n    move-result v0\n\n"
                        "    if-nez v0, :k4_drawn\n\n    invoke-super {p0, p1}, Landroid/widget/ImageView;->onDraw(Landroid/graphics/Canvas;)V\n\n    :k4_drawn\n    :try_end_0\n" % XF, 1)
xpatch(f, "public onDraw(Landroid/graphics/Canvas;)V", hdraw, "MaskImageView.onDraw -> EditXf.draw")
f = by_text('"makeBackgroundImage"')
s = open(f).read()
for fld in (".field public final f:Landroid/util/Size;", ".field public h:Landroid/graphics/Bitmap;", ".field public o:F", ".field public p:F"):
    assert fld in s, "SaveImageMaker " + fld
assert re.search(r"^\.field private a:Ljava/util/ArrayList;$", open(one("c7/c0.smali")).read(), re.M), "c7.c0.a (expand offsets)"
for name, typ in (("preview_switch_title_layout", "id"), ("set_wallpaper_btn_bg", "drawable"), ("preview_selector_text_set", "drawable"),
                  ("edit_switch_preview_title_text_size", "dimen"), ("tab_color", "string"), ("style_item_blur", "string"),
                  ("align_assist_line", "drawable"), ("guide_box_white", "color"), ("align_assist_line_width", "dimen")):
    assert re.search(r'<public type="%s" name="%s" ' % (typ, name), open(root + "/res/values/public.xml").read()), "resource %s/%s" % (typ, name)
xpatch(f, "public final f(Landroid/graphics/RectF;Landroid/graphics/RectF;Landroid/graphics/RectF;Ljava/lang/String;)V", at_start(
    "    invoke-static {p0, p1, p2, p3}, %s->bakeBackground(Ljava/lang/Object;Landroid/graphics/RectF;Landroid/graphics/RectF;Landroid/graphics/RectF;)V\n\n" % XF, 0),
    "SaveImageMaker.f -> EditXf.bakeBackground")
def hobj(body):
    hdr = "    .locals %d\n\n" % nlocals(body)
    assert body.count(hdr) == 1
    return body.replace(hdr, hdr + "    invoke-static/range {p0 .. p3}, %s->bakeObject(Ljava/lang/Object;Landroid/graphics/Bitmap;Landroid/graphics/Rect;F)Landroid/graphics/Bitmap;\n\n"
                        "    move-result-object p1\n\n    invoke-static/range {p3 .. p3}, %s->objectScale(F)F\n\n    move-result p3\n\n" % (XF, XF), 1)
xpatch(f, "public final h(Landroid/graphics/Bitmap;Landroid/graphics/Rect;FLjava/lang/String;)Landroid/graphics/Bitmap;", hobj, "SaveImageMaker.h -> EditXf.bakeObject")
def hthumb(body):
    hdr = "    .locals %d\n\n" % nlocals(body)
    assert body.count(hdr) == 1 and nlocals(body) + 2 <= 16
    return body.replace(hdr, hdr + "    invoke-static {p0, p1}, %s->thumbnail(Ljava/lang/Object;Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;\n\n    move-result-object p1\n\n" % XF, 1)
xpatch(f, "public final o(Landroid/graphics/Bitmap;)Ljava/lang/String;", hthumb, "SaveImageMaker.o -> EditXf.thumbnail")
def hxml(body):
    hdr = "    .locals %d\n\n" % nlocals(body)
    assert body.count(hdr) == 1
    return body.replace(hdr, hdr + "    invoke-static/range {p0 .. p2}, %s->beforeXml(Ljava/lang/Object;Ljava/util/ArrayList;Ljava/lang/Object;)V\n\n" % XF, 1)
xpatch(f, "public final i(Ljava/util/ArrayList;Lc7/c0;)V", hxml, "SaveImageMaker.i -> EditXf.beforeXml")

# 6. helper classes into the last dex, menu icon resources
for old in glob.glob(root + "/smali*/com/k4/dressroom"):
    shutil.rmtree(old)
dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
dst = os.path.join(dirs[-1] if dirs else root + "/smali", "com/k4/dressroom")
shutil.copytree(os.path.join(helpers, "com/k4/dressroom"), dst)
print("  - %d helper classes -> %s" % (len(os.listdir(dst)), os.path.relpath(dst, root)))
for name in os.listdir(os.path.join(res, "drawable")):
    shutil.copyfile(os.path.join(res, "drawable", name), os.path.join(root, "res/drawable", name))
assert os.path.exists(root + "/res/drawable/preview_selector_icon_frame.xml") and 'name="clock_item_name"' in open(root + "/res/values/strings.xml").read()

# 7. versionCode above the Galaxy Store builds
if version_code:
    y = root + "/apktool.yml"
    t = open(y).read()
    m = re.search(r"^(\s*versionCode: )'?(\d+)'?$", t, re.M)
    assert m, "apktool.yml versionCode"
    if m.group(2) != version_code:
        assert int(version_code) > int(m.group(2)), "versionCode would go down"
        open(y, "w").write(t[:m.start()] + m.group(1) + version_code + t[m.end():])
        print("  - versionCode %s -> %s" % (m.group(2), version_code))
PYEOF
unset DRESSROOM DRESSROOM_SRC DRESSROOM_VERSION_CODE DRESSROOM_APK DRESSROOM_SHA
