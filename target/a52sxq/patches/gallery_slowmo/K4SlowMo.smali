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
#    (MediaExtractor, about 10 ms) and remembers per player whether it is 8-bit SDR and whether the neural engine
#    takes it (isNeuralEligible(): the daemon pipe's own size checks - at least 320x240, even sizes, up to 1920x1088
#    either way round - and a known frame rate up to 30 fps; the one place to widen). For a video the
#    neural engine takes it also sends the k4front daemon a one-way "warm up" (transaction 0x4B3401), so the network
#    is being built before the first hold; that call never waits and never throws into the player.
#  - setVideoFrc(): replaces the body of SemMediaPlayer.setVideoFrc(). "Scale up N at rate R" (Gallery: 4 at 0.25x
#    while a video is held) picks one of three paths, all through the native player (customize.sh has the native
#    side), which itself refuses what the pipe cannot take by throwing before it changes anything:
#      neural    - persist.sys.k4.slowmo_neural is not 0 (default 1), the MPP store instance "k4front" is registered
#                  (the k4neuralmpp daemon of the gallery_slowmo_neural patch; looked up through the service manager,
#                  a hit cached for 10 s, a miss for 3 s), the source is eligible and the daemon does not report its
#                  network as unusable (transaction 0x4B3404, answered without waiting for the engine; -1 after a
#                  failed build or inference, or while a build hangs): the player is asked for x4 at 0.25x, three
#                  generated frames per real one. An unusable engine takes the classical path below instead of x4
#                  into the classic pipe.
#      classical - otherwise, for 8-bit SDR sources: the A52s frame rate conversion pipe, which doubles the frame
#                  rate. persist.sys.k4.slowmo_frc=1 (default) plays 0.5x with every second frame interpolated,
#                  =2 keeps Gallery's 0.25x, =0 switches it off.
#      plain     - everything else, and every refusal: playback at speed R without interpolation.
#    One "K4SlowMo: hold: ..." log line per hold names the path and says why the better ones were not taken.
#    "FRC off" (scale 0/1) undoes whichever path the hold took, for the player it was applied to.
#  - run()/hideMotionPhotoViewModes(): Gallery's one feature flag also adds the motion photo view modes "Boomerang"
#    and "Slow-mo". Those play through libaplayer's dynamic viewing, which the native player drops without AI FRC
#    ("failed to start dynamic viewing as AI FRC is not supported"), so they would just play the motion photo
#    normally. Posted to Gallery's main thread once, this turns the two modes off again (the spinner lists
#    MotionPhotoViewMode.values() filtered by isEnabled()), leaving "Motion photo" and "Off" as on any phone
#    without AI FRC. Gallery is not modified; if an updated Gallery renames the class, nothing happens.

# static fields
.field private static final blacklist FRC:I = 0x2

.field private static final blacklist NEURAL:I = 0x2

.field private static final blacklist NEURAL_SERVICE:Ljava/lang/String; = "vendor.samsung.hardware.media.mpp.ISehMppStore/k4front"

.field private static final blacklist NEURAL_STATUS:I = 0x4b3404

.field private static final blacklist NEURAL_WARM_UP:I = 0x4b3401

.field private static final blacklist PLAIN:I = 0x1

.field private static final blacklist SDR8:I = 0x1

.field private static final blacklist STORE:Ljava/lang/String; = "vendor.samsung.hardware.media.mpp.ISehMppStore"

.field private static final blacklist TAG:Ljava/lang/String; = "K4SlowMo"

.field private static blacklist sGallery:I

.field private static blacklist sNeural:Landroid/os/IBinder;

.field private static blacklist sNeuralLookup:J

.field private static blacklist sNeuralWarmUp:J

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
            "Ljava/lang/Integer;",
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

.method public static blacklist isNeuralEligible(Landroid/media/MediaFormat;)Z
    .registers 7

    const/4 v0, 0x0

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "width"

    invoke-virtual {p0, v2, v1}, Landroid/media/MediaFormat;->getNumber(Ljava/lang/String;Ljava/lang/Number;)Ljava/lang/Number;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Number;->intValue()I

    move-result v2

    const-string v3, "height"

    invoke-virtual {p0, v3, v1}, Landroid/media/MediaFormat;->getNumber(Ljava/lang/String;Ljava/lang/Number;)Ljava/lang/Number;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Number;->intValue()I

    move-result v3

    const/16 v4, 0x140

    if-lt v2, v4, :cond_58

    const/16 v4, 0xf0

    if-lt v3, v4, :cond_58

    and-int/lit8 v4, v2, 0x1

    if-nez v4, :cond_58

    and-int/lit8 v4, v3, 0x1

    if-nez v4, :cond_58

    invoke-static {v2, v3}, Ljava/lang/Math;->max(II)I

    move-result v4

    const/16 v5, 0x780

    if-gt v4, v5, :cond_58

    invoke-static {v2, v3}, Ljava/lang/Math;->min(II)I

    move-result v2

    const/16 v3, 0x440

    if-le v2, v3, :cond_3a

    goto :goto_58

    :cond_3a
    const-string v2, "frame-rate"

    invoke-virtual {p0, v2}, Landroid/media/MediaFormat;->containsKey(Ljava/lang/String;)Z

    move-result v3

    if-nez v3, :cond_43

    return v0

    :cond_43
    invoke-virtual {p0, v2, v1}, Landroid/media/MediaFormat;->getNumber(Ljava/lang/String;Ljava/lang/Number;)Ljava/lang/Number;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/Number;->floatValue()F

    move-result p0

    const/4 v1, 0x0

    cmpl-float v1, p0, v1

    if-lez v1, :cond_58

    const/high16 v1, 0x41f40000    # 30.5f

    cmpg-float p0, p0, v1

    if-gtz p0, :cond_58

    const/4 p0, 0x1

    return p0

    :cond_58
    :goto_58
    return v0
.end method

.method private static blacklist nativeFrc(Lcom/samsung/android/media/SemMediaPlayer;IFZ)V
    .registers 4

    invoke-virtual {p0, p1, p2, p3}, Lcom/samsung/android/media/SemMediaPlayer;->k4NativeVideoFrc(IFZ)V

    return-void
.end method

.method private static blacklist neuralEnabled()Z
    .registers 2

    const-string v0, "persist.sys.k4.slowmo_neural"

    const/4 v1, 0x1

    invoke-static {v0, v1}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v0

    if-eqz v0, :cond_a

    return v1

    :cond_a
    const/4 v0, 0x0

    return v0
.end method

.method public static blacklist neuralEngineState(Landroid/os/IBinder;)I
    .registers 5

    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;

    move-result-object v0

    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;

    move-result-object v1

    const/4 v2, 0x0

    :try_start_9
    const-string v3, "vendor.samsung.hardware.media.mpp.ISehMppStore"

    invoke-virtual {v0, v3}, Landroid/os/Parcel;->writeInterfaceToken(Ljava/lang/String;)V

    const v3, 0x4b3404

    invoke-interface {p0, v3, v0, v1, v2}, Landroid/os/IBinder;->transact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z

    move-result p0
    :try_end_15
    .catch Landroid/os/RemoteException; {:try_start_9 .. :try_end_15} :catch_2c
    .catchall {:try_start_9 .. :try_end_15} :catchall_17

    if-nez p0, :cond_1e

    :catchall_17
    invoke-virtual {v0}, Landroid/os/Parcel;->recycle()V

    invoke-virtual {v1}, Landroid/os/Parcel;->recycle()V

    return v2

    :cond_1e
    :try_start_1e
    invoke-virtual {v1}, Landroid/os/Parcel;->readException()V

    invoke-virtual {v1}, Landroid/os/Parcel;->readInt()I

    move-result p0
    :try_end_25
    .catch Landroid/os/RemoteException; {:try_start_1e .. :try_end_25} :catch_2c
    .catchall {:try_start_1e .. :try_end_25} :catchall_17

    invoke-virtual {v0}, Landroid/os/Parcel;->recycle()V

    invoke-virtual {v1}, Landroid/os/Parcel;->recycle()V

    return p0

    :catch_2c
    :try_start_2c
    sget-object p0, Lcom/k4/media/K4SlowMo;->sSources:Ljava/util/WeakHashMap;

    monitor-enter p0
    :try_end_2f
    .catchall {:try_start_2c .. :try_end_2f} :catchall_42

    const/4 v2, 0x0

    :try_start_30
    sput-object v2, Lcom/k4/media/K4SlowMo;->sNeural:Landroid/os/IBinder;

    const-wide/16 v2, 0x0

    sput-wide v2, Lcom/k4/media/K4SlowMo;->sNeuralLookup:J

    monitor-exit p0
    :try_end_37
    .catchall {:try_start_30 .. :try_end_37} :catchall_3f

    invoke-virtual {v0}, Landroid/os/Parcel;->recycle()V

    invoke-virtual {v1}, Landroid/os/Parcel;->recycle()V

    const/4 p0, -0x1

    return p0

    :catchall_3f
    move-exception v2

    :try_start_40
    monitor-exit p0
    :try_end_41
    .catchall {:try_start_40 .. :try_end_41} :catchall_3f

    :try_start_41
    throw v2
    :try_end_42
    .catchall {:try_start_41 .. :try_end_42} :catchall_42

    :catchall_42
    move-exception p0

    invoke-virtual {v0}, Landroid/os/Parcel;->recycle()V

    invoke-virtual {v1}, Landroid/os/Parcel;->recycle()V

    throw p0
.end method

.method private static blacklist neuralService()Landroid/os/IBinder;
    .registers 12

    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v0

    sget-object v2, Lcom/k4/media/K4SlowMo;->sSources:Ljava/util/WeakHashMap;

    monitor-enter v2

    :try_start_7
    sget-object v3, Lcom/k4/media/K4SlowMo;->sNeural:Landroid/os/IBinder;

    sget-wide v4, Lcom/k4/media/K4SlowMo;->sNeuralLookup:J

    sub-long v6, v0, v4

    const-wide/16 v8, 0x0

    cmp-long v4, v4, v8

    const/4 v5, 0x0

    if-eqz v4, :cond_30

    cmp-long v4, v6, v8

    if-ltz v4, :cond_30

    if-nez v3, :cond_22

    const-wide/16 v3, 0xbb8

    cmp-long v3, v6, v3

    if-gez v3, :cond_30

    monitor-exit v2

    return-object v5

    :cond_22
    const-wide/16 v10, 0x2710

    cmp-long v4, v6, v10

    if-gez v4, :cond_30

    invoke-interface {v3}, Landroid/os/IBinder;->isBinderAlive()Z

    move-result v4

    if-eqz v4, :cond_30

    monitor-exit v2

    return-object v3

    :cond_30
    monitor-exit v2
    :try_end_31
    .catchall {:try_start_7 .. :try_end_31} :catchall_49

    :try_start_31
    const-string v2, "vendor.samsung.hardware.media.mpp.ISehMppStore/k4front"

    invoke-static {v2}, Landroid/os/ServiceManager;->checkService(Ljava/lang/String;)Landroid/os/IBinder;

    move-result-object v5
    :try_end_37
    .catchall {:try_start_31 .. :try_end_37} :catchall_37

    :catchall_37
    sget-object v3, Lcom/k4/media/K4SlowMo;->sSources:Ljava/util/WeakHashMap;

    monitor-enter v3

    :try_start_3a
    sput-object v5, Lcom/k4/media/K4SlowMo;->sNeural:Landroid/os/IBinder;

    cmp-long v2, v0, v8

    if-nez v2, :cond_42

    const-wide/16 v0, 0x1

    :cond_42
    sput-wide v0, Lcom/k4/media/K4SlowMo;->sNeuralLookup:J

    monitor-exit v3

    return-object v5

    :catchall_46
    move-exception v0

    monitor-exit v3
    :try_end_48
    .catchall {:try_start_3a .. :try_end_48} :catchall_46

    throw v0

    :catchall_49
    move-exception v0

    :try_start_4a
    monitor-exit v2
    :try_end_4b
    .catchall {:try_start_4a .. :try_end_4b} :catchall_49

    throw v0
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
    .registers 11

    const-string v0, "hold: frame interpolation x2, playing at "

    const/4 v1, 0x0

    const/4 v2, 0x2

    if-lt p1, v2, :cond_10e

    const/4 v3, 0x0

    cmpl-float v3, p2, v3

    if-gtz v3, :cond_d

    goto/16 :goto_13a

    :cond_d
    sget-object v3, Lcom/k4/media/K4SlowMo;->sSources:Ljava/util/WeakHashMap;

    monitor-enter v3

    :try_start_10
    invoke-virtual {v3, p0}, Ljava/util/WeakHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/Integer;

    monitor-exit v3
    :try_end_17
    .catchall {:try_start_10 .. :try_end_17} :catchall_10b

    if-nez v4, :cond_1b

    const/4 v3, 0x0

    goto :goto_1f

    :cond_1b
    invoke-virtual {v4}, Ljava/lang/Integer;->intValue()I

    move-result v3

    :goto_1f
    invoke-static {}, Lcom/k4/media/K4SlowMo;->neuralEnabled()Z

    move-result v5

    if-nez v5, :cond_28

    const-string v1, "persist.sys.k4.slowmo_neural is off"

    goto :goto_45

    :cond_28
    invoke-static {}, Lcom/k4/media/K4SlowMo;->neuralService()Landroid/os/IBinder;

    move-result-object v5

    if-nez v5, :cond_31

    const-string v1, "no k4front service"

    goto :goto_45

    :cond_31
    if-nez v4, :cond_36

    const-string v1, "source was not examined"

    goto :goto_45

    :cond_36
    and-int/lit8 v6, v3, 0x2

    if-nez v6, :cond_3d

    const-string v1, "source not eligible"

    goto :goto_45

    :cond_3d
    invoke-static {v5}, Lcom/k4/media/K4SlowMo;->neuralEngineState(Landroid/os/IBinder;)I

    move-result v5

    if-gez v5, :cond_45

    const-string v1, "neural engine not usable (see the K4Neural log)"

    :cond_45
    :goto_45
    const/4 v5, 0x1

    if-nez v1, :cond_6e

    const/4 p1, 0x4

    const/high16 v0, 0x3e800000    # 0.25f

    :try_start_4b
    invoke-static {p0, p1, v0, p3}, Lcom/k4/media/K4SlowMo;->nativeFrc(Lcom/samsung/android/media/SemMediaPlayer;IFZ)V

    new-instance p1, Ljava/lang/ref/WeakReference;

    invoke-direct {p1, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object p1, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    sput v2, Lcom/k4/media/K4SlowMo;->sPath:I

    const-string p1, "K4SlowMo"

    const-string p3, "hold: neural x4, playing at 0.25x"

    invoke-static {p1, p3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_5e
    .catch Ljava/lang/IllegalStateException; {:try_start_4b .. :try_end_5e} :catch_6c
    .catch Ljava/lang/RuntimeException; {:try_start_4b .. :try_end_5e} :catch_5f

    return-void

    :catch_5f
    move-exception p1

    new-instance p3, Ljava/lang/StringBuilder;

    const-string v0, "neural frame interpolation refused: "

    invoke-direct {p3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    goto/16 :goto_d8

    :catch_6c
    move-exception p0

    throw p0

    :cond_6e
    const-string v6, "persist.sys.k4.slowmo_frc"

    invoke-static {v6, v5}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v6

    if-gtz v6, :cond_79

    const-string p1, "persist.sys.k4.slowmo_frc is off"

    goto :goto_c8

    :cond_79
    if-nez v4, :cond_7e

    const-string p1, "source was not examined"

    goto :goto_c8

    :cond_7e
    and-int/2addr v3, v5

    if-nez v3, :cond_84

    const-string p1, "not an 8-bit SDR video"

    goto :goto_c8

    :cond_84
    if-ne v6, v2, :cond_87

    goto :goto_88

    :cond_87
    move p1, v2

    :goto_88
    if-ne v6, v2, :cond_8c

    move v3, p2

    goto :goto_8e

    :cond_8c
    const/high16 v3, 0x3f000000    # 0.5f

    :goto_8e
    :try_start_8e
    invoke-static {p0, p1, v3, p3}, Lcom/k4/media/K4SlowMo;->nativeFrc(Lcom/samsung/android/media/SemMediaPlayer;IFZ)V

    new-instance p1, Ljava/lang/ref/WeakReference;

    invoke-direct {p1, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object p1, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    sput v2, Lcom/k4/media/K4SlowMo;->sPath:I

    const-string p1, "K4SlowMo"

    new-instance p3, Ljava/lang/StringBuilder;

    invoke-direct {p3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p3, v3}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    const-string v0, "x (no neural: "

    invoke-virtual {p3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, ")"

    invoke-virtual {p3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p3

    invoke-static {p1, p3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_b8
    .catch Ljava/lang/IllegalStateException; {:try_start_8e .. :try_end_b8} :catch_109
    .catch Ljava/lang/RuntimeException; {:try_start_8e .. :try_end_b8} :catch_b9

    return-void

    :catch_b9
    move-exception p1

    new-instance p3, Ljava/lang/StringBuilder;

    const-string v0, "frame interpolation refused: "

    invoke-direct {p3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    :goto_c8
    new-instance p3, Ljava/lang/StringBuilder;

    invoke-direct {p3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p1, "; no neural: "

    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    :goto_d8
    invoke-virtual {p3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    new-instance p3, Ljava/lang/ref/WeakReference;

    invoke-direct {p3, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object p3, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    sput v5, Lcom/k4/media/K4SlowMo;->sPath:I

    invoke-static {p0, p2}, Lcom/k4/media/K4SlowMo;->setSpeed(Lcom/samsung/android/media/SemMediaPlayer;F)V

    const-string p0, "K4SlowMo"

    new-instance p3, Ljava/lang/StringBuilder;

    const-string v0, "hold: plain "

    invoke-direct {p3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p3, p2}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    const-string p2, "x ("

    invoke-virtual {p3, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p1, ")"

    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p0, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void

    :catch_109
    move-exception p0

    throw p0

    :catchall_10b
    move-exception p0

    :try_start_10c
    monitor-exit v3
    :try_end_10d
    .catchall {:try_start_10c .. :try_end_10d} :catchall_10b

    throw p0

    :cond_10e
    sget-object p2, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    if-eqz p2, :cond_13a

    invoke-virtual {p2}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p2

    if-eq p2, p0, :cond_119

    goto :goto_13a

    :cond_119
    sput-object v1, Lcom/k4/media/K4SlowMo;->sSlowed:Ljava/lang/ref/WeakReference;

    sget p2, Lcom/k4/media/K4SlowMo;->sPath:I

    const/high16 v0, 0x3f800000    # 1.0f

    if-ne p2, v2, :cond_137

    :try_start_121
    invoke-static {p0, p1, v0, p3}, Lcom/k4/media/K4SlowMo;->nativeFrc(Lcom/samsung/android/media/SemMediaPlayer;IFZ)V

    const-string p1, "K4SlowMo"

    const-string p2, "release: frame interpolation off"

    invoke-static {p1, p2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_12b
    .catch Ljava/lang/IllegalStateException; {:try_start_121 .. :try_end_12b} :catch_135
    .catch Ljava/lang/RuntimeException; {:try_start_121 .. :try_end_12b} :catch_12c

    return-void

    :catch_12c
    move-exception p1

    const-string p2, "K4SlowMo"

    const-string p3, "release: frame interpolation did not switch off, setting 1x"

    invoke-static {p2, p3, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_137

    :catch_135
    move-exception p0

    throw p0

    :cond_137
    :goto_137
    invoke-static {p0, v0}, Lcom/k4/media/K4SlowMo;->setSpeed(Lcom/samsung/android/media/SemMediaPlayer;F)V

    :cond_13a
    :goto_13a
    return-void
.end method

.method public static blacklist sourceOpened(Lcom/samsung/android/media/SemMediaPlayer;Ljava/io/FileDescriptor;JJ)V
    .registers 14

    invoke-static {}, Lcom/k4/media/K4SlowMo;->isGallery()Z

    move-result v0

    if-nez v0, :cond_7

    goto :goto_5c

    :cond_7
    const/4 v0, 0x0

    const/4 v1, 0x0

    :try_start_9
    new-instance v2, Landroid/media/MediaExtractor;

    invoke-direct {v2}, Landroid/media/MediaExtractor;-><init>()V
    :try_end_e
    .catchall {:try_start_9 .. :try_end_e} :catchall_44

    move-object v3, p1

    move-wide v4, p2

    move-wide v6, p4

    :try_start_11
    invoke-virtual/range {v2 .. v7}, Landroid/media/MediaExtractor;->setDataSource(Ljava/io/FileDescriptor;JJ)V

    invoke-virtual {v2}, Landroid/media/MediaExtractor;->getTrackCount()I

    move-result p1

    move p2, v0

    :goto_19
    if-ge p2, p1, :cond_45

    invoke-virtual {v2, p2}, Landroid/media/MediaExtractor;->getTrackFormat(I)Landroid/media/MediaFormat;

    move-result-object p3

    const-string p4, "mime"

    invoke-virtual {p3, p4}, Landroid/media/MediaFormat;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p4

    if-eqz p4, :cond_40

    const-string p5, "video/"

    invoke-virtual {p4, p5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result p5

    if-eqz p5, :cond_40

    invoke-static {p4, p3}, Lcom/k4/media/K4SlowMo;->isEightBitSdr(Ljava/lang/String;Landroid/media/MediaFormat;)Z

    move-result p1

    if-eqz p1, :cond_45

    invoke-static {p3}, Lcom/k4/media/K4SlowMo;->isNeuralEligible(Landroid/media/MediaFormat;)Z

    move-result p1
    :try_end_39
    .catchall {:try_start_11 .. :try_end_39} :catchall_43

    if-eqz p1, :cond_3d

    const/4 p1, 0x3

    goto :goto_3e

    :cond_3d
    const/4 p1, 0x1

    :goto_3e
    move v0, p1

    goto :goto_45

    :cond_40
    add-int/lit8 p2, p2, 0x1

    goto :goto_19

    :catchall_43
    move-object v1, v2

    :catchall_44
    move-object v2, v1

    :cond_45
    :goto_45
    if-eqz v2, :cond_4a

    :try_start_47
    invoke-virtual {v2}, Landroid/media/MediaExtractor;->release()V
    :try_end_4a
    .catchall {:try_start_47 .. :try_end_4a} :catchall_4a

    :catchall_4a
    :cond_4a
    sget-object p1, Lcom/k4/media/K4SlowMo;->sSources:Ljava/util/WeakHashMap;

    monitor-enter p1

    :try_start_4d
    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p2

    invoke-virtual {p1, p0, p2}, Ljava/util/WeakHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    monitor-exit p1
    :try_end_55
    .catchall {:try_start_4d .. :try_end_55} :catchall_5d

    and-int/lit8 p0, v0, 0x2

    if-eqz p0, :cond_5c

    invoke-static {}, Lcom/k4/media/K4SlowMo;->warmUpNeural()V

    :cond_5c
    :goto_5c
    return-void

    :catchall_5d
    move-exception v0

    move-object p0, v0

    :try_start_5f
    monitor-exit p1
    :try_end_60
    .catchall {:try_start_5f .. :try_end_60} :catchall_5d

    throw p0
.end method

.method private static blacklist warmUpNeural()V
    .registers 10

    const/4 v0, 0x0

    const-wide/16 v1, 0x0

    :try_start_3
    invoke-static {}, Lcom/k4/media/K4SlowMo;->neuralEnabled()Z

    move-result v3

    if-nez v3, :cond_a

    goto :goto_60

    :cond_a
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v3

    sget-object v5, Lcom/k4/media/K4SlowMo;->sSources:Ljava/util/WeakHashMap;

    monitor-enter v5
    :try_end_11
    .catchall {:try_start_3 .. :try_end_11} :catchall_58

    :try_start_11
    sget-wide v6, Lcom/k4/media/K4SlowMo;->sNeuralWarmUp:J

    cmp-long v8, v6, v1

    if-eqz v8, :cond_27

    sub-long v8, v3, v6

    cmp-long v8, v8, v1

    if-ltz v8, :cond_27

    sub-long v6, v3, v6

    const-wide/16 v8, 0x1388

    cmp-long v6, v6, v8

    if-gez v6, :cond_27

    monitor-exit v5

    return-void

    :cond_27
    monitor-exit v5
    :try_end_28
    .catchall {:try_start_11 .. :try_end_28} :catchall_55

    :try_start_28
    invoke-static {}, Lcom/k4/media/K4SlowMo;->neuralService()Landroid/os/IBinder;

    move-result-object v6

    if-nez v6, :cond_2f

    goto :goto_60

    :cond_2f
    monitor-enter v5
    :try_end_30
    .catchall {:try_start_28 .. :try_end_30} :catchall_58

    cmp-long v7, v3, v1

    if-nez v7, :cond_36

    const-wide/16 v3, 0x1

    :cond_36
    :try_start_36
    sput-wide v3, Lcom/k4/media/K4SlowMo;->sNeuralWarmUp:J

    monitor-exit v5
    :try_end_39
    .catchall {:try_start_36 .. :try_end_39} :catchall_52

    :try_start_39
    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;

    move-result-object v3
    :try_end_3d
    .catchall {:try_start_39 .. :try_end_3d} :catchall_58

    :try_start_3d
    const-string v4, "vendor.samsung.hardware.media.mpp.ISehMppStore"

    invoke-virtual {v3, v4}, Landroid/os/Parcel;->writeInterfaceToken(Ljava/lang/String;)V

    const v4, 0x4b3401

    const/4 v5, 0x1

    invoke-interface {v6, v4, v3, v0, v5}, Landroid/os/IBinder;->transact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z
    :try_end_49
    .catchall {:try_start_3d .. :try_end_49} :catchall_4d

    :try_start_49
    invoke-virtual {v3}, Landroid/os/Parcel;->recycle()V

    return-void

    :catchall_4d
    move-exception v4

    invoke-virtual {v3}, Landroid/os/Parcel;->recycle()V

    throw v4
    :try_end_52
    .catchall {:try_start_49 .. :try_end_52} :catchall_58

    :catchall_52
    move-exception v3

    :try_start_53
    monitor-exit v5
    :try_end_54
    .catchall {:try_start_53 .. :try_end_54} :catchall_52

    :try_start_54
    throw v3
    :try_end_55
    .catchall {:try_start_54 .. :try_end_55} :catchall_58

    :catchall_55
    move-exception v3

    :try_start_56
    monitor-exit v5
    :try_end_57
    .catchall {:try_start_56 .. :try_end_57} :catchall_55

    :try_start_57
    throw v3
    :try_end_58
    .catchall {:try_start_57 .. :try_end_58} :catchall_58

    :catchall_58
    sget-object v3, Lcom/k4/media/K4SlowMo;->sSources:Ljava/util/WeakHashMap;

    monitor-enter v3

    :try_start_5b
    sput-object v0, Lcom/k4/media/K4SlowMo;->sNeural:Landroid/os/IBinder;

    sput-wide v1, Lcom/k4/media/K4SlowMo;->sNeuralLookup:J

    monitor-exit v3

    :goto_60
    return-void

    :catchall_61
    move-exception v0

    monitor-exit v3
    :try_end_63
    .catchall {:try_start_5b .. :try_end_63} :catchall_61

    throw v0
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
