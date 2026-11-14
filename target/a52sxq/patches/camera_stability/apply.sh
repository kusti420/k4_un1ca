# Sourced by target/a52sxq/post_mods.sh, after unica/patches/camera installed and decoded the r9qxxx SamsungCamera
# 16.0.00.74 (see module.prop and customize.sh for why it can't run as a plain device patch). Each edit is located by
# exact anchors, counted, and recognised when it is already there, so running this twice changes nothing.
CAMERA_APK="system/priv-app/SamsungCamera/SamsungCamera.apk"
[ -f "$WORK_DIR/system/$CAMERA_APK" ] || ABORT "camera_stability: /$CAMERA_APK not found"
DECODE_APK "system" "$CAMERA_APK" || ABORT "camera_stability: failed to decode /$CAMERA_APK"
# 1c turns the camera's Single Take stills back on because the service we ship is the stp1 SingleTakeService 6.2.00.27
# from a73xqxx (unica/patches/camera), which picks its best shots only from those stills. A different service may pick
# them from the video like the S26U one (singletake.capture.support.off): re-check 1c before shipping one.
ST_APK="system/priv-app/SingleTakeService/SingleTakeService.apk"
cmp -s "$WORK_DIR/system/$ST_APK" "$SRC_DIR/prebuilts/samsung/a73xqxx/$ST_APK" || \
    ABORT "camera_stability: /$ST_APK is not the a73xqxx stp1 service 1c (SUPPORT_SINGLE_TAKE_VIDEO_SNAPSHOT) was made for"
unset ST_APK
LOG "- SamsungCamera: Single Take on the MediaRecorder path with its stills, vendor CaptureResult keys looked up once, is_drm on PPP drafts"
python3 - "$APKTOOL_DIR/system/${CAMERA_APK//system\//}" << 'PYEOF' || ABORT "camera_stability: failed to patch SamsungCamera"
import glob, os, re, sys

root = sys.argv[1]
MARK = "# k4 camera_stability"

yml = open(os.path.join(root, "apktool.yml")).read()
assert re.search(r"^  versionName: 16\.0\.00\.74$", yml, re.M), "SamsungCamera is not 16.0.00.74: re-check every anchor"


def one(rel):
    hits = glob.glob(root + "/smali*/" + rel)
    assert len(hits) == 1, "%s: %d files" % (rel, len(hits))
    return hits[0]


def method(s, decl):
    """(start, end) of the method whose declaration line is exactly `decl`."""
    ms = [m for m in re.finditer(r"^\.method .*$", s, re.M) if m.group(0) == decl]
    assert len(ms) == 1, "%s: %d" % (decl, len(ms))
    end = s.index("\n.end method\n", ms[0].start()) + len("\n.end method\n")
    return ms[0].start(), end


def replace_once(body, old, new, what):
    n = body.count(old)
    assert n == 1, "%s: anchor found %d times" % (what, n)
    return body.replace(old, new)


all_smali = None


def files_containing(needle):
    global all_smali
    if all_smali is None:
        all_smali = {}
        for p in glob.glob(root + "/smali*/**/*.smali", recursive=True):
            with open(p, encoding="utf-8") as f:
                all_smali[p] = f.read()
    return [p for p, s in all_smali.items() if needle in s]


# ---------------------------------------------------------------------------------------------------------------------
# 1a. Single Take: SUPPORT_SINGLE_TAKE_VIDEO_PREVIOUS_RECORDING is filled by a static Boolean getter (x1.e.m0 in this
#     build) that returns TRUE when SEC_FLOATING_FEATURE_GALLERY_CONFIG_AI_EXPANSION contains
#     "singletake.video.previous_record" (S26U value). Make it return FALSE, as on the S21 FE and stock A52s.
PREV_MARK = MARK + ": SUPPORT_SINGLE_TAKE_VIDEO_PREVIOUS_RECORDING"
hits = sorted(set(files_containing('"singletake.video.previous_record"')) | set(files_containing(PREV_MARK)))
assert len(hits) == 1, "previous_record reader: %d files" % len(hits)
f = hits[0]
s = open(f).read()
cls = re.search(r"^\.class [^\n]* (L[^;\s]+;)$", s, re.M).group(1)
decls = [m for m in re.finditer(r"^\.method public static (\w+)\(\)Ljava/lang/Boolean;$", s, re.M)
         if "singletake.video.previous_record" in s[m.start():s.index("\n.end method\n", m.start())]
         or PREV_MARK in s[m.start():s.index("\n.end method\n", m.start())]]
assert len(decls) == 1, "previous_record getter: %d" % len(decls)
name = decls[0].group(1)
a, b = method(s, decls[0].group(0))
body = s[a:b]
# its only caller must be the feature map entry for SUPPORT_SINGLE_TAKE_VIDEO_PREVIOUS_RECORDING
call = "invoke-static {}, %s->%s()Ljava/lang/Boolean;" % (cls, name)
callers = files_containing(call)
assert callers == [f] and s.count(call) == 1, "%s callers: %s" % (call, callers)
assert re.search(r"sget-object v\d+, L[^;]+;->SUPPORT_SINGLE_TAKE_VIDEO_PREVIOUS_RECORDING:L[^;]+;\n\n    "
                 + re.escape(call), s), "previous_record getter is not the feature map entry"
new = ("%s\n    .locals 1\n\n    %s (A52s camera-feature.xml has only SINGLE_TAKE_VIDEO, which needs a\n"
       "    # RecordingSession; the S26U floating feature's singletake.video.previous_record left it without one)\n"
       "    sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;\n\n    return-object v0\n.end method\n") % (
    decls[0].group(0), PREV_MARK)
if PREV_MARK in body:
    assert body == new, "%s->%s carries another camera_stability version" % (cls, name)
    print("  - %s->%s() already returns FALSE" % (cls, name))
else:
    assert body.count("SemFloatingFeature;->getInstance()") == 1 and \
        '"SEC_FLOATING_FEATURE_GALLERY_CONFIG_AI_EXPANSION"' in body, "%s->%s: unexpected stock body" % (cls, name)
    s = s[:a] + new + s[b:]
    open(f, "w").write(s)
    print("  - %s->%s(): SUPPORT_SINGLE_TAKE_VIDEO_PREVIOUS_RECORDING = false" % (cls, name))

# 1b. Safety net: RecordingSessionManagerImpl.prepareRecording() throws the app's own "Fail to prepare media recorder."
#     exception (caught by PrepareMediaRecorderRequest.execute) instead of the RuntimeException from getMainSession()'s
#     orElseThrow when no main session exists.
RSM = "Lcom/sec/android/app/camera/engine/recording/session/RecordingSessionManagerImpl;"
f = one("com/sec/android/app/camera/engine/recording/session/RecordingSessionManagerImpl.smali")
s = open(f).read()
a, b = method(s, ".method private getMainSession()" + "Lcom/sec/android/app/camera/engine/recording/session/RecordingSession;")
gm = s[a:b]
assert '"There is no main session"' not in gm  # the message lives in the lambda
pm = re.search(r"    new-instance v0, (L[^;]+;)\n\n    const/4 v1, (0x[0-9a-f]+)\n\n    invoke-direct \{v0, v1\}, \1-><init>\(I\)V\n\n"
               r"    invoke-interface \{p0, v0\}, Ljava/util/stream/Stream;->filter\(Ljava/util/function/Predicate;\)Ljava/util/stream/Stream;\n\n"
               r"    move-result-object p0\n\n    invoke-interface \{p0\}, Ljava/util/stream/Stream;->findFirst\(\)Ljava/util/Optional;\n\n"
               r"    move-result-object p0\n\n    new-instance v0, (L[^;]+;)\n\n    invoke-direct \{v0\}, Ljava/lang/Object;-><init>\(\)V\n\n"
               r"    invoke-virtual \{p0, v0\}, Ljava/util/Optional;->orElseThrow\(Ljava/util/function/Supplier;\)Ljava/lang/Object;\n", gm)
assert pm, "getMainSession(): unexpected body"
pred, pred_idx = pm.group(1), pm.group(2)
# the prepare-failure exception PrepareMediaRecorderRequest catches
req = open(one("com/sec/android/app/camera/engine/core/request/PrepareMediaRecorderRequest.smali")).read()
ca = re.findall(r"^    \.catch (L[^;]+;) \{:try_start_0 \.\. :try_end_0\} :catch_0$", req, re.M)
assert len(ca) == 1, "PrepareMediaRecorderRequest: %d catch blocks" % len(ca)
exc = ca[0]
assert "%s->prepareRecording()V" % "Lcom/sec/android/app/camera/engine/interfaces/InternalRecordingManager;" in req
ef = one(exc[1:-1] + ".smali")
es = open(ef).read()
assert ".super Ljava/lang/RuntimeException;" in es and ".method public constructor <init>(I)V" in es and \
    re.search(r"\.packed-switch 0x1\n        :(pswitch_\d+)\n        :(pswitch_\d+)\n", es), "%s: unexpected exception class" % exc
second = re.search(r"\.packed-switch 0x1\n        :pswitch_\d+\n        :(pswitch_\d+)\n", es).group(1)
assert re.search(r":%s\n    const-string v0, \"Fail to prepare media recorder\.\"\n" % second, es), "%s(2) is not the prepare failure" % exc
a, b = method(s, ".method public prepareRecording()V")
body = s[a:b]
GUARD_MARK = MARK + ": no main session"
guard = (
    "    %s -> fail the prepare request the app's own way, don't crash\n"
    "    iget-object v0, p0, %s->mRecordingSessionMap:Ljava/util/concurrent/ConcurrentHashMap;\n\n"
    "    invoke-virtual {v0}, Ljava/util/concurrent/ConcurrentHashMap;->values()Ljava/util/Collection;\n\n"
    "    move-result-object v0\n\n"
    "    invoke-interface {v0}, Ljava/util/Collection;->stream()Ljava/util/stream/Stream;\n\n"
    "    move-result-object v0\n\n"
    "    new-instance v1, %s\n\n"
    "    const/4 v2, %s\n\n"
    "    invoke-direct {v1, v2}, %s-><init>(I)V\n\n"
    "    invoke-interface {v0, v1}, Ljava/util/stream/Stream;->filter(Ljava/util/function/Predicate;)Ljava/util/stream/Stream;\n\n"
    "    move-result-object v0\n\n"
    "    invoke-interface {v0}, Ljava/util/stream/Stream;->findFirst()Ljava/util/Optional;\n\n"
    "    move-result-object v0\n\n"
    "    invoke-virtual {v0}, Ljava/util/Optional;->isPresent()Z\n\n"
    "    move-result v0\n\n"
    "    if-nez v0, :k4_has_main_session\n\n"
    "    const-string v0, \"RecordingSessionController\"\n\n"
    "    const-string v1, \"prepareRecording : there is no main session, media recorder not prepared\"\n\n"
    "    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I\n\n"
    "    new-instance v0, %s\n\n"
    "    const/4 v1, 0x2\n\n"
    "    invoke-direct {v0, v1}, %s-><init>(I)V\n\n"
    "    throw v0\n\n"
    "    :k4_has_main_session\n") % (GUARD_MARK, RSM, pred, pred_idx, pred, exc, exc)
head = ".method public prepareRecording()V\n    .locals 3\n\n"
if GUARD_MARK in body:
    assert body.startswith(head + guard), "prepareRecording(): another camera_stability version"
    print("  - RecordingSessionManagerImpl.prepareRecording() already guarded")
else:
    stock = (head +
             "    invoke-direct {p0}, %s->getSubSessions()Ljava/util/List;\n\n" % RSM)
    assert body.startswith(stock), "prepareRecording(): unexpected stock start"
    calls = re.findall(r"invoke-\S+ \{[^}]*\}, (\S+)", body)
    # getSubSessions().forEach(new n(this, 3)) [prepares the sub sessions], then prepareRecordingSession(getMainSession())
    assert len(calls) == 5 and calls[1].endswith("-><init>(" + RSM + "I)V") and [calls[0]] + calls[2:] == [
        RSM + "->getSubSessions()Ljava/util/List;",
        "Ljava/lang/Iterable;->forEach(Ljava/util/function/Consumer;)V",
        RSM + "->getMainSession()Lcom/sec/android/app/camera/engine/recording/session/RecordingSession;",
        RSM + "->prepareRecordingSession(Lcom/sec/android/app/camera/engine/recording/session/RecordingSession;)V",
    ], "prepareRecording(): unexpected stock calls %s" % calls
    body = head + guard + "\n" + body[len(head):]
    s = s[:a] + body + s[b:]
    open(f, "w").write(s)
    print("  - RecordingSessionManagerImpl.prepareRecording(): no main session -> %s(2) instead of a crash" % exc)

# 1c. Single Take best shots: SUPPORT_SINGLE_TAKE_VIDEO_SNAPSHOT is filled by a static boolean getter (x1.e.n0 in this
#     build) that returns FALSE when SEC_FLOATING_FEATURE_GALLERY_CONFIG_AI_EXPANSION contains
#     "singletake.capture.support.off" (S26U value). Without it SingleTakeManager.getCaptureType() picks type 2
#     ("video only"): no TAKE_MULTI_VIDEO_SNAPSHOT every REAR_/SINGLE_TAKE_CAPTURE_INTERVAL ms during the recording, no
#     still is queued into the stp1 service's main_cap_surface, and the service ("count = 0/0", "Capture Empty", "BEST:
#     null") makes only the fast forward clip. The S26U's own service picks its shots from the video; the legacy stp1
#     6.2 Lite service we ship (a73xqxx) only scores the stills the camera sends it. Make the getter return TRUE, as it
#     does on the S21 FE and stock A52s (AI_EXPANSION there is just "AI_Timelapse").
SNAP_MARK = MARK + ": SUPPORT_SINGLE_TAKE_VIDEO_SNAPSHOT"
hits = sorted(set(files_containing('"singletake.capture.support.off"')) | set(files_containing(SNAP_MARK)))
assert len(hits) == 1, "capture.support.off reader: %d files" % len(hits)
f = hits[0]
s = open(f).read()  # fresh: 1a may have rewritten this file (the getters live in the same feature map class)
cls = re.search(r"^\.class [^\n]* (L[^;\s]+;)$", s, re.M).group(1)
decls = [m for m in re.finditer(r"^\.method public static (\w+)\(\)Z$", s, re.M)
         if "singletake.capture.support.off" in s[m.start():s.index("\n.end method\n", m.start())]
         or SNAP_MARK in s[m.start():s.index("\n.end method\n", m.start())]]
assert len(decls) == 1, "capture.support.off getter: %d" % len(decls)
name = decls[0].group(1)
a, b = method(s, decls[0].group(0))
body = s[a:b]
# its only caller must be the feature map entry for SUPPORT_SINGLE_TAKE_VIDEO_SNAPSHOT
call = "invoke-static {}, %s->%s()Z" % (cls, name)
callers = files_containing(call)
assert callers == [f] and s.count(call) == 1, "%s callers: %s" % (call, callers)
assert re.search(r"sget-object v\d+, L[^;]+;->SUPPORT_SINGLE_TAKE_VIDEO_SNAPSHOT:L[^;]+;\n\n    "
                 + re.escape(call) + r"\n\n    move-result (v\d+)\n\n    invoke-static \{\1\}, "
                 r"Ljava/lang/Boolean;->valueOf\(Z\)Ljava/lang/Boolean;\n", s), \
    "capture.support.off getter is not the SUPPORT_SINGLE_TAKE_VIDEO_SNAPSHOT feature map entry"
# the reader of the flag must still be what picks the capture type: video only (2) <=> !SUPPORT_SINGLE_TAKE_VIDEO_SNAPSHOT
stm = open(one("com/sec/android/app/camera/engine/SingleTakeManager.smali")).read()
a2, b2 = method(stm, ".method private isSingleTakeVideoOnlyMode()Z")
assert "->SUPPORT_SINGLE_TAKE_VIDEO_SNAPSHOT:" in stm[a2:b2], "isSingleTakeVideoOnlyMode() no longer reads SUPPORT_SINGLE_TAKE_VIDEO_SNAPSHOT"
new = ("%s\n    .locals 1\n\n    %s (the stp1 Single Take service we ship picks its best shots\n"
       "    # from the stills the camera sends it; the S26U floating feature's singletake.capture.support.off sent none)\n"
       "    const/4 v0, 0x1\n\n    return v0\n.end method\n") % (decls[0].group(0), SNAP_MARK)
if SNAP_MARK in body:
    assert body == new, "%s->%s carries another camera_stability version" % (cls, name)
    print("  - %s->%s() already returns TRUE" % (cls, name))
else:
    assert body.count("SemFloatingFeature;->getInstance()") == 1 and \
        '"SEC_FLOATING_FEATURE_GALLERY_CONFIG_AI_EXPANSION"' in body, "%s->%s: unexpected stock body" % (cls, name)
    s = s[:a] + new + s[b:]
    open(f, "w").write(s)
    if all_smali is not None:
        all_smali[f] = s
    print("  - %s->%s(): SUPPORT_SINGLE_TAKE_VIDEO_SNAPSHOT = true" % (cls, name))

# ---------------------------------------------------------------------------------------------------------------------
# 2. SemCaptureResult.a(CaptureResult, Key): remember keys without a vendor tag on this HAL and stop asking for them.
SCR = "Lcom/samsung/android/camera/core2/local/vendorkey/SemCaptureResult;"
f = one("com/samsung/android/camera/core2/local/vendorkey/SemCaptureResult.smali")
s = open(f).read()
FIELD = SCR + "->k4UnsupportedKeys:Ljava/util/Set;"
field_decl = ".field private static final k4UnsupportedKeys:Ljava/util/Set;\n\n"
clinit_init = ("    %s: names of keys without a vendor tag on this HAL\n"
               "    invoke-static {}, Ljava/util/concurrent/ConcurrentHashMap;->newKeySet()Ljava/util/concurrent/ConcurrentHashMap$KeySetView;\n\n"
               "    move-result-object v0\n\n"
               "    sput-object v0, %s\n\n") % (MARK, FIELD)
skip = ("    %s: no vendor tag for this key on this HAL, don't look it up again\n"
        "    sget-object v2, %s\n\n"
        "    invoke-virtual {p1}, Landroid/hardware/camera2/CaptureResult$Key;->getName()Ljava/lang/String;\n\n"
        "    move-result-object v3\n\n"
        "    invoke-interface {v2, v3}, Ljava/util/Set;->contains(Ljava/lang/Object;)Z\n\n"
        "    move-result v2\n\n"
        "    if-eqz v2, :k4_lookup\n\n"
        "    return-object v0\n\n"
        "    :k4_lookup\n") % (MARK, FIELD)
remember = ("    %s: \"Could not find tag for key\" = this HAL has no such vendor tag\n"
            "    instance-of v2, p0, Ljava/lang/IllegalArgumentException;\n\n"
            "    if-eqz v2, :k4_log\n\n"
            "    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;\n\n"
            "    move-result-object v2\n\n"
            "    if-eqz v2, :k4_log\n\n"
            "    const-string v3, \"Could not find tag for key\"\n\n"
            "    invoke-virtual {v2, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n"
            "    move-result v2\n\n"
            "    if-eqz v2, :k4_log\n\n"
            "    sget-object v2, %s\n\n"
            "    invoke-virtual {p1}, Landroid/hardware/camera2/CaptureResult$Key;->getName()Ljava/lang/String;\n\n"
            "    move-result-object v3\n\n"
            "    invoke-interface {v2, v3}, Ljava/util/Set;->add(Ljava/lang/Object;)Z\n\n"
            "    :k4_log\n") % (MARK, FIELD)
GET_DECL = ".method public static a(Landroid/hardware/camera2/CaptureResult;Landroid/hardware/camera2/CaptureResult$Key;)Ljava/lang/Object;"
a, b = method(s, GET_DECL)
body = s[a:b]
if FIELD in s:
    assert s.count(field_decl) == 1 and s.count(clinit_init) == 1 and body.count(skip) == 1 and body.count(remember) == 1, \
        "SemCaptureResult: another camera_stability version"
    print("  - SemCaptureResult.a() already caches unsupported keys")
else:
    assert body.startswith(GET_DECL + "\n    .locals 4\n\n    const/4 v0, 0x0\n\n    const-string v1, \"SemCaptureResult\"\n"), \
        "SemCaptureResult.a(): unexpected stock start"
    body = replace_once(body, "    :cond_1\n    :try_start_0\n    invoke-virtual {p0, p1}, Landroid/hardware/camera2/CaptureResult;->get(",
                        "    :cond_1\n" + skip + "\n    :try_start_0\n    invoke-virtual {p0, p1}, Landroid/hardware/camera2/CaptureResult;->get(",
                        "SemCaptureResult.a() lookup")
    body = replace_once(body, "    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0\n\n    goto :goto_0\n\n"
                              "    :catch_0\n    move-exception p0\n\n",
                        "    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0\n\n    goto :goto_0\n\n"
                        "    :catch_0\n    move-exception p0\n\n" + remember + "\n",
                        "SemCaptureResult.a() catch")
    # the stock log line must still follow (p1 is only overwritten after the key name was taken)
    assert re.search(r":k4_log\n\n    new-instance v2, Ljava/lang/StringBuilder;\n\n    const-string v3, \"UnsupportedOperationException - \"\n", body)
    s = s[:a] + body + s[b:]
    s = replace_once(s, "\n# direct methods\n", "\n" + field_decl + "\n# direct methods\n", "SemCaptureResult fields")
    s = replace_once(s, ".method static constructor <clinit>()V\n    .locals 12\n\n",
                     ".method static constructor <clinit>()V\n    .locals 12\n\n" + clinit_init, "SemCaptureResult.<clinit>")
    open(f, "w").write(s)
    print("  - SemCaptureResult.a(): keys without a vendor tag are looked up once")

# ---------------------------------------------------------------------------------------------------------------------
# 3. PostSavingModuleSecMpInsert.insertToSecMpForDraft: is_drm=1 on the PPP draft insert (sef_file_type 0xb70).
# The rejected draft was not harmless: the null draft Uri makes PostSavingModuleRecoveryDataSave throw, the save goes
# IDLE->RECOVERY and the photo written is the draft run through DraftRecoveryProcess, saved before the real
# post-processing ends; the processed result (LLHDR merge, UW shape correction, ...) is then dropped (camera audit
# 2026-11-14). The S26U camera puts is_drm=1 on its draft the same way; the final photo row ends with is_drm=0 because
# the MediaStore scan sync overwrites it (verified on 9.3.117: SecMP is_drm 0, _data_draft and sef_file_type NULL,
# MediaStore is_drm 0; save path runDraft -> runComplete state DRAFT). K4_CAMERA_PPP_DRM=0 leaves it out.
import os
if os.environ.get("K4_CAMERA_PPP_DRM", "1") != "1":
    print("  - PPP draft is_drm: not applied (K4_CAMERA_PPP_DRM=0)")
else:
    f = one("com/samsung/android/camera/core2/processor/postSaving/module/PostSavingModuleSecMpInsert.smali")
    s = open(f).read()
    a, b = method(s, ".method private insertToSecMpForDraft(Lcom/samsung/android/camera/core2/container/SavingInfoContainer;"
                     "Lcom/samsung/android/camera/core2/util/ImageBuffer;)V")
    body = s[a:b]
    DB = "Lcom/samsung/android/camera/core2/processor/PostProcessDBHelper;"
    anchor = ("    invoke-static/range {v0 .. v6}, %s->createContentValues(Landroid/content/Context;Ljava/io/File;"
              "Lcom/samsung/android/camera/core2/util/ImageInfo;Lcom/samsung/android/camera/core2/container/ExtraBundle;"
              "Ljava/io/File;ZI)Landroid/content/ContentValues;\n\n    move-result-object p0\n\n") % DB
    drm = ("    %s: One UI 9 MediaProvider only takes a PPP draft (sef_file_type 2928) with is_drm=1\n"
           "    const/4 p2, 0x1\n\n"
           "    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;\n\n"
           "    move-result-object p2\n\n"
           "    const-string v0, \"is_drm\"\n\n"
           "    invoke-virtual {p0, v0, p2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V\n\n") % MARK
    tail = "    sget-object p2, %s->SEC_MEDIA_PROVIDER_URI:Landroid/net/Uri;\n\n    invoke-static {v7, p2, p0}, %s->insertToDB(" % (DB, DB)
    if MARK in body:
        assert body.count(anchor + drm + tail) == 1, "insertToSecMpForDraft: another camera_stability version"
        print("  - PostSavingModuleSecMpInsert draft insert already sets is_drm")
    else:
        assert '"is_drm"' not in body and "iget-boolean v5, p0, Lcom/samsung/android/camera/core2/processor/postSaving/module/" \
            "PostSavingModuleSecMpInsert;->mIsDraft:Z" in body, "insertToSecMpForDraft: unexpected stock body"
        # setContentFileValues() is what adds _data_draft + sef_file_type 0xb70 for a draft
        dbh = open(one("com/samsung/android/camera/core2/processor/PostProcessDBHelper.smali")).read()
        da, db = method(dbh, ".method public static setContentFileValues(Landroid/content/ContentValues;Ljava/io/File;Ljava/io/File;Z)V")
        assert '"_data_draft"' in dbh[da:db] and "const/16 p1, 0xb70" in dbh[da:db], "setContentFileValues: no draft values"
        body = replace_once(body, anchor + tail, anchor + drm + tail, "insertToSecMpForDraft insert")
        s = s[:a] + body + s[b:]
        open(f, "w").write(s)
        print("  - PostSavingModuleSecMpInsert.insertToSecMpForDraft(): is_drm=1")
PYEOF
unset CAMERA_APK
