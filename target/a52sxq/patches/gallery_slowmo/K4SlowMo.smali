.class public final Lcom/k4/media/K4SlowMo;
.super Ljava/lang/Object;
.source "K4SlowMo.java"

# interfaces
.implements Ljava/lang/Runnable;

# Backend of the a52sxq gallery_slowmo patch (see module.prop). Generated from K4SlowMo.java (kept next to this file,
# rebuild recipe at its top); edit the Java source, not this file.
#  - featureBoolean()/featureString(): called first thing from SemFloatingFeature.getBoolean(String)/getString(String).
#    Only inside Samsung Gallery they report the Instant Slow-mo feature (CAMERA_SUPPORT_AIFRC) and its limits
#    (CAMERA_CONFIG_AIFRC_SPEC); every other process, and every native reader of floating_feature.xml (libaplayer,
#    Camera motion photo, MotionPhoto, Video Player, the share sheet), keeps seeing the feature as absent.
#  - sourceOpened(): called from SemMediaPlayer.init(FileDescriptor, long, long), the funnel of every local source,
#    before the native player gets the file. Inside Gallery only, it reads the video track's format once
#    (MediaExtractor, about 10 ms) and remembers per player whether it is 8-bit SDR.
#  - setVideoFrc(): replaces the body of SemMediaPlayer.setVideoFrc(). "Scale up N at rate R" (Gallery: 4 at 0.25x
#    while a video is held) first tries the A52s frame rate conversion pipe through the native player, see
#    customize.sh for the native side: 8-bit SDR sources only, and the native player itself refuses what the pipe
#    cannot take (more than 1920x1088 or 30 fps) by throwing before it changes anything. The pipe doubles the frame
#    rate, so the default is 0.5x with every second frame interpolated (30 shown frames per second from a 30 fps
#    video); persist.sys.k4.slowmo_frc=2 keeps Gallery's 0.25x (15 per second), =0 switches the pipe off. Whatever
#    cannot use the pipe plays at plain speed R as before. One "K4SlowMo: hold: ..." log line per hold says which
#    path ran and why. "FRC off" (scale 0/1) undoes whichever path the hold took, for the player it was applied to.
#  - run()/hideMotionPhotoViewModes(): Gallery's one feature flag also adds the motion photo view modes "Boomerang"
#    and "Slow-mo". Those play through libaplayer's dynamic viewing, which the native player drops without AI FRC
#    ("failed to start dynamic viewing as AI FRC is not supported"), so they would just play the motion photo
#    normally. Posted to Gallery's main thread once, this turns the two modes off again (the spinner lists
#    MotionPhotoViewMode.values() filtered by isEnabled()), leaving "Motion photo" and "Off" as on any phone
#    without AI FRC. Gallery is not modified; if an updated Gallery renames the class, nothing happens.

# static fields
.field private static final blacklist FRC:I = 0x2

.field private static final blacklist PLAIN:I = 0x1

.field private static final blacklist TAG:Ljava/lang/String; = "K4SlowMo"

.field private static blacklist sGallery:I

.field private static blacklist sPath:I

.field private static blacklist sSlowed:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Lcom/samsung/android/media/SemMediaPlayer;",
            ">;"
        }
    .end annotation
.end field

.field private static final blacklist sSources:Ljava/util/WeakHashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/WeakHashMap<",
            "Lcom/samsung/android/media/SemMediaPlayer;",
            "Ljava/lang/Boolean;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor blacklist <clinit>()V
    .registers 1

    new-instance v0, Ljava/util/WeakHashMap;

    invoke-direct {v0}, Ljava/util/WeakHashMap;-><init>()V

    sput-object v0, Lcom/k4/media/K4SlowMo;->sSources:Ljava/util/WeakHashMap;

    return-void
.end method

.method private constructor blacklist <init>()V
    .registers 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static blacklist featureBoolean(Ljava/lang/String;)Z
    .registers 2

    const-string v0, "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AIFRC"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_d

    invoke-static {}, Lcom/k4/media/K4SlowMo;->isGallery()Z

    move-result p0

    return p0

    :cond_d
    const/4 p0, 0x0

    return p0
.end method

.method public static blacklist featureString(Ljava/lang/String;)Ljava/lang/String;
    .registers 2

    const-string v0, "SEC_FLOATING_FEATURE_CAMERA_CONFIG_AIFRC_SPEC"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_11

    invoke-static {}, Lcom/k4/media/K4SlowMo;->isGallery()Z

    move-result p0

    if-eqz p0, :cond_11

    const-string p0, "480,480,3840,2160,23,61,HDR,MP_PLAYBACK_OFF"

    return-object p0

    :cond_11
    const/4 p0, 0x0

    return-object p0
.end method

.method public static blacklist hideMotionPhotoViewModes(Ljava/lang/ClassLoader;)Z
    .registers 6

    const/4 v0, 0x0

    :try_start_1
    const-string v1, "com.samsung.android.gallery.module.motionphoto.MotionPhotoViewMode"

    const/4 v2, 0x1

    invoke-static {v1, v2, p0}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object p0

    const-string v1, "mEnabled"

    invoke-virtual {p0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v1

    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    const-string v3, "BOOMERANG"

    invoke-virtual {p0, v3}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v3

    const/4 v4, 0x0

    invoke-virtual {v3, v4}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v1, v3, v0}, Ljava/lang/reflect/Field;->setBoolean(Ljava/lang/Object;Z)V

    const-string v3, "SLOW_MO"

    invoke-virtual {p0, v3}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object p0

    invoke-virtual {p0, v4}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    invoke-virtual {v1, p0, v0}, Ljava/lang/reflect/Field;->setBoolean(Ljava/lang/Object;Z)V
    :try_end_2c
    .catchall {:try_start_1 .. :try_end_2c} :catchall_2d

    return v2

    :catchall_2d
    move-exception p0

    const-string v1, "K4SlowMo"

    const-string v2, "Motion photo Boomerang/Slow-mo view modes were not turned off"

    invoke-static {v1, v2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    return v0
.end method

.method public static blacklist isEightBitSdr(Ljava/lang/String;Landroid/media/MediaFormat;)Z
    .registers 6

    const-string v0, "color-transfer"

    const/4 v1, 0x0

    invoke-virtual {p1, v0, v1}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;I)I

    move-result v0

    const/4 v2, 0x6

    if-eq v0, v2, :cond_51

    const/4 v3, 0x7

    if-eq v0, v3, :cond_51

    const-string v0, "color-standard"

    invoke-virtual {p1, v0, v1}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;I)I

    move-result v0

    if-ne v0, v2, :cond_16

    goto :goto_51

    :cond_16
    const-string v0, "profile"

    const/4 v2, -0x1

    invoke-virtual {p1, v0, v2}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;I)I

    move-result p1

    const-string v0, "video/avc"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    const/4 v2, 0x1

    if-eqz v0, :cond_34

    const/16 p0, 0x10

    if-eq p1, p0, :cond_33

    const/16 p0, 0x20

    if-eq p1, p0, :cond_33

    const/16 p0, 0x40

    if-eq p1, p0, :cond_33

    return v2

    :cond_33
    return v1

    :cond_34
    const-string v0, "video/hevc"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_4e

    const-string v0, "video/x-vnd.on2.vp9"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_4e

    const-string v0, "video/av01"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_4d

    goto :goto_4e

    :cond_4d
    return v1

    :cond_4e
    :goto_4e
    if-ne p1, v2, :cond_51

    return v2

    :cond_51
    :goto_51
    return v1
.end method

.method private static blacklist isGallery()Z
    .registers 4

    sget v0, Lcom/k4/media/K4SlowMo;->sGallery:I

    const/4 v1, 0x0

    const/4 v2, 0x1

    if-nez v0, :cond_1d

    invoke-static {}, Landroid/app/ActivityThread;->currentPackageName()Ljava/lang/String;

    move-result-object v0

    if-nez v0, :cond_d

    return v1

    :cond_d
    const-string v3, "com.sec.android.gallery3d"

    invoke-virtual {v3, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1a

    invoke-static {}, Lcom/k4/media/K4SlowMo;->scheduleGalleryFixups()V

    move v0, v2

    goto :goto_1b

    :cond_1a
    const/4 v0, 0x2

    :goto_1b
    sput v0, Lcom/k4/media/K4SlowMo;->sGallery:I

    :cond_1d
    if-ne v0, v2, :cond_20

    return v2

    :cond_20
    return v1
.end method

.method private static blacklist nativeFrc(Lcom/samsung/android/media/SemMediaPlayer;IFZ)V
    .registers 4

    invoke-virtual {p0, p1, p2, p3}, Lcom/samsung/android/media/SemMediaPlayer;->k4NativeVideoFrc(IFZ)V

    return-void
.end method

.method private static blacklist scheduleGalleryFixups()V
    .registers 2

    :try_start_0
    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    new-instance v1, Lcom/k4/media/K4SlowMo;

    invoke-direct {v1}, Lcom/k4/media/K4SlowMo;-><init>()V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_11
    .catchall {:try_start_0 .. :try_end_11} :catchall_11

    :catchall_11
    return-void
.end method

.method private static blacklist setSpeed(Lcom/samsung/android/media/SemMediaPlayer;F)V
    .registers 3

    invoke-virtual {p0}, Lcom/samsung/android/media/SemMediaPlayer;->getPlaybackParams()Landroid/media/PlaybackParams;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/media/PlaybackParams;->setSpeed(F)Landroid/media/PlaybackParams;

    invoke-virtual {p0, v0}, Lcom/samsung/android/media/SemMediaPlayer;->setPlaybackParams(Landroid/media/PlaybackParams;)V

    return-void
.end method

.method public static blacklist setVideoFrc(Lcom/samsung/android/media/SemMediaPlayer;IFZ)V
    .registers 10

    const-string v0, "hold: frame interpolation x2, playing at "

    const/4 v1, 0x2

    if-lt p1, v1, :cond_a5

    const/4 v2, 0x0

    cmpl-float v2, p2, v2

    if-gtz v2, :cond_c

    goto/16 :goto_d2

    :cond_c
    const-string v2, "persist.sys.k4.slowmo_frc"

    const/4 v3, 0x1

    invoke-static {v2, v3}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v2

    if-gtz v2, :cond_18

    const-string p1, "persist.sys.k4.slowmo_frc is off"

    goto :goto_6f

    :cond_18
    sget-object v4, Lcom/k4/media/K4SlowMo;->sSources:Ljava/util/WeakHashMap;

    monitor-enter v4

    :try_start_1b
    invoke-virtual {v4, p0}, Ljava/util/WeakHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/Boolean;

    monitor-exit v4
    :try_end_22
    .catchall {:try_start_1b .. :try_end_22} :catchall_a2

    if-nez v5, :cond_27

    const-string p1, "source was not examined"

    goto :goto_6f

    :cond_27
    invoke-virtual {v5}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v4

    if-nez v4, :cond_30

    const-string p1, "not an 8-bit SDR video"

    goto :goto_6f

    :cond_30
    if-ne v2, v1, :cond_33

    goto :goto_34

    :cond_33
    move p1, v1

    :goto_34
    if-ne v2, v1, :cond_38

    move v2, p2

    goto :goto_3a

    :cond_38
    const/high16 v2, 0x3f000000    # 0.5f

    :goto_3a
    :try_start_3a
    invoke-static {p0, p1, v2, p3}, Lcom/k4/media/K4SlowMo;->nativeFrc(Lcom/samsung/android/media/SemMediaPlayer;IFZ)V

    new-instance p1, Ljava/lang/ref/WeakReference;

    invoke-direct {p1, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object p1, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    sput v1, Lcom/k4/media/K4SlowMo;->sPath:I

    const-string p1, "K4SlowMo"

    new-instance p3, Ljava/lang/StringBuilder;

    invoke-direct {p3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p3, v2}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p3

    const-string v0, "x"

    invoke-virtual {p3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p3

    invoke-static {p1, p3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_5e
    .catch Ljava/lang/IllegalStateException; {:try_start_3a .. :try_end_5e} :catch_a0
    .catch Ljava/lang/RuntimeException; {:try_start_3a .. :try_end_5e} :catch_5f

    return-void

    :catch_5f
    move-exception p1

    new-instance p3, Ljava/lang/StringBuilder;

    const-string v0, "frame interpolation refused: "

    invoke-direct {p3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    :goto_6f
    new-instance p3, Ljava/lang/ref/WeakReference;

    invoke-direct {p3, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object p3, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    sput v3, Lcom/k4/media/K4SlowMo;->sPath:I

    invoke-static {p0, p2}, Lcom/k4/media/K4SlowMo;->setSpeed(Lcom/samsung/android/media/SemMediaPlayer;F)V

    const-string p0, "K4SlowMo"

    new-instance p3, Ljava/lang/StringBuilder;

    const-string v0, "hold: plain "

    invoke-direct {p3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p3, p2}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, "x ("

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p2, ")"

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p0, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void

    :catch_a0
    move-exception p0

    throw p0

    :catchall_a2
    move-exception p0

    :try_start_a3
    monitor-exit v4
    :try_end_a4
    .catchall {:try_start_a3 .. :try_end_a4} :catchall_a2

    throw p0

    :cond_a5
    sget-object p2, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    if-eqz p2, :cond_d2

    invoke-virtual {p2}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p2

    if-eq p2, p0, :cond_b0

    goto :goto_d2

    :cond_b0
    const/4 p2, 0x0

    sput-object p2, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    sget p2, Lcom/k4/media/K4SlowMo;->sPath:I

    const/high16 v0, 0x3f800000    # 1.0f

    if-ne p2, v1, :cond_cf

    :try_start_b9
    invoke-static {p0, p1, v0, p3}, Lcom/k4/media/K4SlowMo;->nativeFrc(Lcom/samsung/android/media/SemMediaPlayer;IFZ)V

    const-string p1, "K4SlowMo"

    const-string p2, "release: frame interpolation off"

    invoke-static {p1, p2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_c3
    .catch Ljava/lang/IllegalStateException; {:try_start_b9 .. :try_end_c3} :catch_cd
    .catch Ljava/lang/RuntimeException; {:try_start_b9 .. :try_end_c3} :catch_c4

    return-void

    :catch_c4
    move-exception p1

    const-string p2, "K4SlowMo"

    const-string p3, "release: frame interpolation did not switch off, setting 1x"

    invoke-static {p2, p3, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_cf

    :catch_cd
    move-exception p0

    throw p0

    :cond_cf
    :goto_cf
    invoke-static {p0, v0}, Lcom/k4/media/K4SlowMo;->setSpeed(Lcom/samsung/android/media/SemMediaPlayer;F)V

    :cond_d2
    :goto_d2
    return-void
.end method

.method public static blacklist sourceOpened(Lcom/samsung/android/media/SemMediaPlayer;Ljava/io/FileDescriptor;JJ)V
    .registers 14

    invoke-static {}, Lcom/k4/media/K4SlowMo;->isGallery()Z

    move-result v0

    if-nez v0, :cond_7

    goto :goto_49

    :cond_7
    const/4 v0, 0x0

    const/4 v1, 0x0

    :try_start_9
    new-instance v2, Landroid/media/MediaExtractor;

    invoke-direct {v2}, Landroid/media/MediaExtractor;-><init>()V
    :try_end_e
    .catchall {:try_start_9 .. :try_end_e} :catchall_38

    move-object v3, p1

    move-wide v4, p2

    move-wide v6, p4

    :try_start_11
    invoke-virtual/range {v2 .. v7}, Landroid/media/MediaExtractor;->setDataSource(Ljava/io/FileDescriptor;JJ)V

    invoke-virtual {v2}, Landroid/media/MediaExtractor;->getTrackCount()I

    move-result p1

    move p2, v0

    :goto_19
    if-ge p2, p1, :cond_39

    invoke-virtual {v2, p2}, Landroid/media/MediaExtractor;->getTrackFormat(I)Landroid/media/MediaFormat;

    move-result-object p3

    const-string p4, "mime"

    invoke-virtual {p3, p4}, Landroid/media/MediaFormat;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p4

    if-eqz p4, :cond_34

    const-string p5, "video/"

    invoke-virtual {p4, p5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result p5

    if-eqz p5, :cond_34

    invoke-static {p4, p3}, Lcom/k4/media/K4SlowMo;->isEightBitSdr(Ljava/lang/String;Landroid/media/MediaFormat;)Z

    move-result v0
    :try_end_33
    .catchall {:try_start_11 .. :try_end_33} :catchall_37

    goto :goto_39

    :cond_34
    add-int/lit8 p2, p2, 0x1

    goto :goto_19

    :catchall_37
    move-object v1, v2

    :catchall_38
    move-object v2, v1

    :cond_39
    :goto_39
    if-eqz v2, :cond_3e

    :try_start_3b
    invoke-virtual {v2}, Landroid/media/MediaExtractor;->release()V
    :try_end_3e
    .catchall {:try_start_3b .. :try_end_3e} :catchall_3e

    :catchall_3e
    :cond_3e
    sget-object p1, Lcom/k4/media/K4SlowMo;->sSources:Ljava/util/WeakHashMap;

    monitor-enter p1

    :try_start_41
    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p2

    invoke-virtual {p1, p0, p2}, Ljava/util/WeakHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    monitor-exit p1

    :goto_49
    return-void

    :catchall_4a
    move-exception v0

    move-object p0, v0

    monitor-exit p1
    :try_end_4d
    .catchall {:try_start_41 .. :try_end_4d} :catchall_4a

    throw p0
.end method


# virtual methods
.method public blacklist run()V
    .registers 1

    invoke-static {}, Landroid/app/ActivityThread;->currentApplication()Landroid/app/Application;

    move-result-object p0

    if-eqz p0, :cond_d

    invoke-virtual {p0}, Landroid/app/Application;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object p0

    invoke-static {p0}, Lcom/k4/media/K4SlowMo;->hideMotionPhotoViewModes(Ljava/lang/ClassLoader;)Z

    :cond_d
    return-void
.end method
