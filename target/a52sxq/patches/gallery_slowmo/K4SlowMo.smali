.class public final Lcom/k4/media/K4SlowMo;
.super Ljava/lang/Object;
.source "K4SlowMo.java"

# interfaces
.implements Ljava/lang/Runnable;

# Backend of the a52sxq gallery_slowmo patch (see module.prop):
#  - featureBoolean()/featureString(): called first thing from SemFloatingFeature.getBoolean(String)/getString(String).
#    Only inside Samsung Gallery they report the Instant Slow-mo feature (CAMERA_SUPPORT_AIFRC) and its limits
#    (CAMERA_CONFIG_AIFRC_SPEC); every other process, and every native reader of floating_feature.xml (libaplayer,
#    Camera motion photo, MotionPhoto, Video Player, the share sheet), keeps seeing the feature as absent.
#  - setVideoFrc(): replaces SemMediaPlayer's native _setVideoFrc(). The A52s vendor has no AI frame rate conversion
#    pipe (MPP HAL V1: FRUC + deflicker only), so "scale up N at rate R" becomes plain playback at speed R, and
#    "FRC off" (scale 0/1) puts the player this class slowed down back to normal speed.
#  - run()/hideMotionPhotoViewModes(): Gallery's one feature flag also adds the motion photo view modes "Boomerang"
#    and "Slow-mo". Those play through libaplayer's dynamic viewing, which the native player drops without AI FRC
#    ("failed to start dynamic viewing as AI FRC is not supported"), so they would just play the motion photo
#    normally. Posted to Gallery's main thread once, this turns the two modes off again (the spinner lists
#    MotionPhotoViewMode.values() filtered by isEnabled()), leaving "Motion photo" and "Off" as on any phone
#    without AI FRC. Gallery is not modified; if an updated Gallery renames the class, nothing happens.


# static fields
.field private static blacklist sGallery:I

.field private static blacklist sSlowed:Ljava/lang/ref/WeakReference;


# direct methods
.method private constructor blacklist <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static blacklist featureBoolean(Ljava/lang/String;)Z
    .locals 1

    const-string v0, "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AIFRC"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_no

    invoke-static {}, Lcom/k4/media/K4SlowMo;->isGallery()Z

    move-result v0

    return v0

    :cond_no
    const/4 v0, 0x0

    return v0
.end method

# Limits as Gallery's InstantSlowMoUtils$Limitation parses them: min size, (unused), max long side, max short side,
# min fps, max fps, HDR allowed, no motion photo fps scale-up. Nothing is interpolated here, so the S26 Ultra limits
# (480p..2160p, 24..60 fps) are safe as they are.
.method public static blacklist featureString(Ljava/lang/String;)Ljava/lang/String;
    .locals 1

    const-string v0, "SEC_FLOATING_FEATURE_CAMERA_CONFIG_AIFRC_SPEC"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_no

    invoke-static {}, Lcom/k4/media/K4SlowMo;->isGallery()Z

    move-result v0

    if-eqz v0, :cond_no

    const-string v0, "480,480,3840,2160,23,61,HDR,MP_PLAYBACK_OFF"

    return-object v0

    :cond_no
    const/4 v0, 0x0

    return-object v0
.end method

# Returns true when both modes were switched off. Public so it can be exercised from a test process.
.method public static blacklist hideMotionPhotoViewModes(Ljava/lang/ClassLoader;)Z
    .locals 4

    :try_start_0
    const-string v0, "com.samsung.android.gallery.module.motionphoto.MotionPhotoViewMode"

    const/4 v1, 0x1

    invoke-static {v0, v1, p0}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v0

    const-string v2, "mEnabled"

    invoke-virtual {v0, v2}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    const/4 v1, 0x0

    const-string v3, "BOOMERANG"

    invoke-virtual {v0, v3}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v3

    invoke-virtual {v3, v1}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v2, v3, v1}, Ljava/lang/reflect/Field;->setBoolean(Ljava/lang/Object;Z)V

    const-string v3, "SLOW_MO"

    invoke-virtual {v0, v3}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v3

    invoke-virtual {v3, v1}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v2, v3, v1}, Ljava/lang/reflect/Field;->setBoolean(Ljava/lang/Object;Z)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    const/4 v0, 0x1

    return v0

    :catchall_0
    move-exception v0

    const-string v1, "K4SlowMo"

    const-string v2, "Motion photo Boomerang/Slow-mo view modes were not turned off"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    const/4 v0, 0x0

    return v0
.end method

# sGallery: 0 = not known yet (the process is not bound to a package yet), 1 = Gallery, 2 = any other package
.method private static blacklist isGallery()Z
    .locals 2

    sget v0, Lcom/k4/media/K4SlowMo;->sGallery:I

    if-nez v0, :cond_known

    invoke-static {}, Landroid/app/ActivityThread;->currentPackageName()Ljava/lang/String;

    move-result-object v0

    if-nez v0, :cond_bound

    const/4 v0, 0x0

    return v0

    :cond_bound
    const-string v1, "com.sec.android.gallery3d"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_other

    invoke-static {}, Lcom/k4/media/K4SlowMo;->scheduleGalleryFixups()V

    const/4 v0, 0x1

    goto :goto_store

    :cond_other
    const/4 v0, 0x2

    :goto_store
    sput v0, Lcom/k4/media/K4SlowMo;->sGallery:I

    :cond_known
    const/4 v1, 0x1

    if-ne v0, v1, :cond_no

    return v1

    :cond_no
    const/4 v0, 0x0

    return v0
.end method

# Runs later on Gallery's main thread: never inside the class initializer that asked for the feature.
.method private static blacklist scheduleGalleryFixups()V
    .locals 2

    :try_start_0
    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    new-instance v1, Lcom/k4/media/K4SlowMo;

    invoke-direct {v1}, Lcom/k4/media/K4SlowMo;-><init>()V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception v0

    return-void
.end method

.method public static blacklist setVideoFrc(Lcom/samsung/android/media/SemMediaPlayer;IF)V
    .locals 2

    const/4 v0, 0x2

    if-lt p1, v0, :cond_off

    # FRC on: play at the requested rate (Gallery: scale 4 at 0.25x while the video is held)
    const/4 v0, 0x0

    cmpl-float v0, p2, v0

    if-gtz v0, :cond_rate

    return-void

    :cond_rate
    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    invoke-virtual {p0}, Lcom/samsung/android/media/SemMediaPlayer;->getPlaybackParams()Landroid/media/PlaybackParams;

    move-result-object v0

    invoke-virtual {v0, p2}, Landroid/media/PlaybackParams;->setSpeed(F)Landroid/media/PlaybackParams;

    invoke-virtual {p0, v0}, Lcom/samsung/android/media/SemMediaPlayer;->setPlaybackParams(Landroid/media/PlaybackParams;)V

    return-void

    # FRC off: back to normal speed, but only for the player slowed down above (Gallery starts Instant Slow-mo at
    # 1x only), so a stray "off" never resets a speed the user picked in the speed menu
    :cond_off
    sget-object v0, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    if-eqz v0, :cond_done

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    if-ne v0, p0, :cond_done

    const/4 v0, 0x0

    sput-object v0, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    invoke-virtual {p0}, Lcom/samsung/android/media/SemMediaPlayer;->getPlaybackParams()Landroid/media/PlaybackParams;

    move-result-object v0

    const/high16 v1, 0x3f800000    # 1.0f

    invoke-virtual {v0, v1}, Landroid/media/PlaybackParams;->setSpeed(F)Landroid/media/PlaybackParams;

    invoke-virtual {p0, v0}, Lcom/samsung/android/media/SemMediaPlayer;->setPlaybackParams(Landroid/media/PlaybackParams;)V

    :cond_done
    return-void
.end method

# virtual methods
.method public blacklist run()V
    .locals 1

    invoke-static {}, Landroid/app/ActivityThread;->currentApplication()Landroid/app/Application;

    move-result-object v0

    if-eqz v0, :cond_done

    invoke-virtual {v0}, Landroid/app/Application;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v0

    invoke-static {v0}, Lcom/k4/media/K4SlowMo;->hideMotionPhotoViewModes(Ljava/lang/ClassLoader;)Z

    :cond_done
    return-void
.end method
