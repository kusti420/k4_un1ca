.class public final Lcom/k4/media/K4SlowMoExport;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;
.implements Ljava/lang/reflect/InvocationHandler;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/k4/media/K4SlowMoExport$Listener;
    }
.end annotation


# static fields
.field public static final blacklist AUDIO_PROPERTY:Ljava/lang/String; = "persist.sys.k4.slowmo_save_audio"

.field private static final blacklist PLAYER:Ljava/lang/String; = "com.samsung.android.media.SemMediaPlayer"

.field private static final blacklist TAG:Ljava/lang/String; = "K4SlowMo"

.field public static blacklist sAudio:Z = false

.field private static blacklist sKeep:Ljava/lang/Object; = null

.field public static blacklist sPlaybackFactor:F = 0.5f


# instance fields
.field private blacklist mAudio:Z

.field private final blacklist mAudioData:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Ljava/nio/ByteBuffer;",
            ">;"
        }
    .end annotation
.end field

.field private blacklist mAudioFormat:Landroid/media/MediaFormat;

.field private final blacklist mAudioInfo:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "[J>;"
        }
    .end annotation
.end field

.field private blacklist mAudioNext:I

.field private blacklist mAudioNote:Ljava/lang/String;

.field private blacklist mAudioTrack:I

.field private volatile blacklist mCancelled:Z

.field private volatile blacklist mDone:Z

.field private blacklist mDrain:Ljava/lang/Thread;

.field private blacklist mDropped:I

.field private blacklist mEncoder:Landroid/media/MediaCodec;

.field private final blacklist mEndMs:I

.field private volatile blacklist mError:Ljava/lang/String;

.field private blacklist mExpected:I

.field private blacklist mFirstPtsUs:J

.field private blacklist mFps:I

.field private blacklist mFrameUs:J

.field private blacklist mFrcCallUs:J

.field private blacklist mGaps:I

.field private blacklist mHandler:Landroid/os/Handler;

.field private blacklist mHeight:I

.field private final blacklist mIn:Ljava/io/FileDescriptor;

.field private final blacklist mInLength:J

.field private final blacklist mInOffset:J

.field private volatile blacklist mLastFrameAt:J

.field private blacklist mLastPtsUs:J

.field private final blacklist mListener:Lcom/k4/media/K4SlowMoExport$Listener;

.field private blacklist mMuxer:Landroid/media/MediaMuxer;

.field private final blacklist mOut:Ljava/io/FileDescriptor;

.field private blacklist mPhaseAt:J

.field private blacklist mPlayRate:F

.field private blacklist mPlayer:Ljava/lang/Object;

.field private blacklist mPlayerClass:Ljava/lang/Class;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/Class<",
            "*>;"
        }
    .end annotation
.end field

.field private volatile blacklist mPlaying:Z

.field private volatile blacklist mPositionMs:I

.field private blacklist mPreRollMs:I

.field private final blacklist mRate:F

.field private blacklist mRotation:I

.field private final blacklist mScale:I

.field private blacklist mSkip:I

.field private final blacklist mStartMs:I

.field private volatile blacklist mStarted:Z

.field private volatile blacklist mStopping:Z

.field private blacklist mSurface:Landroid/view/Surface;

.field private blacklist mT0:J

.field private blacklist mThread:Landroid/os/HandlerThread;

.field private blacklist mTrack:I

.field private blacklist mWidth:I

.field private blacklist mWritten:I


# direct methods
.method static bridge synthetic blacklist -$$Nest$mdrain(Lcom/k4/media/K4SlowMoExport;)V
    .registers 1

    invoke-direct {p0}, Lcom/k4/media/K4SlowMoExport;->drain()V

    return-void
.end method

.method static bridge synthetic blacklist -$$Nest$mfinish(Lcom/k4/media/K4SlowMoExport;ZLjava/lang/String;)V
    .registers 3

    invoke-direct {p0, p1, p2}, Lcom/k4/media/K4SlowMoExport;->finish(ZLjava/lang/String;)V

    return-void
.end method

.method static constructor blacklist <clinit>()V
    .registers 0

    return-void
.end method

.method public constructor blacklist <init>(Ljava/io/FileDescriptor;JJLjava/io/FileDescriptor;IIFLcom/k4/media/K4SlowMoExport$Listener;)V
    .registers 13

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, -0x1

    iput v0, p0, Lcom/k4/media/K4SlowMoExport;->mAudioTrack:I

    const-string v1, "no audio track (persist.sys.k4.slowmo_save_audio is 0)"

    iput-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mAudioNote:Ljava/lang/String;

    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    iput-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mAudioData:Ljava/util/ArrayList;

    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    iput-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mAudioInfo:Ljava/util/ArrayList;

    iput v0, p0, Lcom/k4/media/K4SlowMoExport;->mTrack:I

    const/16 v0, 0x1e

    iput v0, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    const-wide v0, 0x7fffffffffffffffL

    iput-wide v0, p0, Lcom/k4/media/K4SlowMoExport;->mFrcCallUs:J

    const-wide/16 v0, -0x1

    iput-wide v0, p0, Lcom/k4/media/K4SlowMoExport;->mFirstPtsUs:J

    iput-wide v0, p0, Lcom/k4/media/K4SlowMoExport;->mLastPtsUs:J

    const-wide/32 v0, 0x8235

    iput-wide v0, p0, Lcom/k4/media/K4SlowMoExport;->mFrameUs:J

    iput-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mIn:Ljava/io/FileDescriptor;

    iput-wide p2, p0, Lcom/k4/media/K4SlowMoExport;->mInOffset:J

    iput-wide p4, p0, Lcom/k4/media/K4SlowMoExport;->mInLength:J

    iput-object p6, p0, Lcom/k4/media/K4SlowMoExport;->mOut:Ljava/io/FileDescriptor;

    iput p7, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    iput p8, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iput p9, p0, Lcom/k4/media/K4SlowMoExport;->mRate:F

    const p1, 0x3e99999a    # 0.3f

    cmpg-float p1, p9, p1

    if-gtz p1, :cond_47

    const/4 p1, 0x4

    goto :goto_48

    :cond_47
    const/4 p1, 0x2

    :goto_48
    iput p1, p0, Lcom/k4/media/K4SlowMoExport;->mScale:I

    iput-object p10, p0, Lcom/k4/media/K4SlowMoExport;->mListener:Lcom/k4/media/K4SlowMoExport$Listener;

    iput p7, p0, Lcom/k4/media/K4SlowMoExport;->mPositionMs:I

    return-void
.end method

.method private static blacklist announceSave()V
    .registers 5

    :try_start_0
    const-string v0, "android.os.ServiceManager"

    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    const-string v1, "checkService"

    const-class v2, Ljava/lang/String;

    filled-new-array {v2}, [Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    const-string v1, "vendor.samsung.hardware.media.mpp.ISehMppStore/k4front"

    filled-new-array {v1}, [Ljava/lang/Object;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {v0, v2, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/os/IBinder;

    if-nez v0, :cond_22

    goto :goto_59

    :cond_22
    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;

    move-result-object v1

    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;

    move-result-object v2
    :try_end_2a
    .catchall {:try_start_0 .. :try_end_2a} :catchall_45

    :try_start_2a
    const-string v3, "vendor.samsung.hardware.media.mpp.ISehMppStore"

    invoke-virtual {v1, v3}, Landroid/os/Parcel;->writeInterfaceToken(Ljava/lang/String;)V

    const v3, 0x4b3402

    const/4 v4, 0x0

    invoke-interface {v0, v3, v1, v2, v4}, Landroid/os/IBinder;->transact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z
    :try_end_36
    .catchall {:try_start_2a .. :try_end_36} :catchall_3d

    :try_start_36
    invoke-virtual {v1}, Landroid/os/Parcel;->recycle()V

    invoke-virtual {v2}, Landroid/os/Parcel;->recycle()V

    return-void

    :catchall_3d
    move-exception v0

    invoke-virtual {v1}, Landroid/os/Parcel;->recycle()V

    invoke-virtual {v2}, Landroid/os/Parcel;->recycle()V

    throw v0
    :try_end_45
    .catchall {:try_start_36 .. :try_end_45} :catchall_45

    :catchall_45
    move-exception v0

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "save: could not announce the recording to the neural front: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "K4SlowMo"

    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    :goto_59
    return-void
.end method

.method private static blacklist audioProperty()Z
    .registers 5

    const/4 v0, 0x0

    :try_start_1
    const-string v1, "android.os.SystemProperties"

    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    const-string v2, "getInt"

    const-class v3, Ljava/lang/String;

    sget-object v4, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v3, v4}, [Ljava/lang/Class;

    move-result-object v3

    invoke-virtual {v1, v2, v3}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    const-string v2, "persist.sys.k4.slowmo_save_audio"

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    filled-new-array {v2, v3}, [Ljava/lang/Object;

    move-result-object v2

    const/4 v3, 0x0

    invoke-virtual {v1, v3, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Integer;

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1
    :try_end_2a
    .catchall {:try_start_1 .. :try_end_2a} :catchall_2d

    if-eqz v1, :cond_2d

    const/4 v0, 0x1

    :catchall_2d
    :cond_2d
    return v0
.end method

.method private blacklist begin()V
    .registers 8
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mWidth:I

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mHeight:I

    const-string v2, "video/avc"

    invoke-static {v2, v0, v1}, Landroid/media/MediaFormat;->createVideoFormat(Ljava/lang/String;II)Landroid/media/MediaFormat;

    move-result-object v0

    const-string v1, "color-format"

    const v3, 0x7f000789

    invoke-virtual {v0, v1, v3}, Landroid/media/MediaFormat;->setInteger(Ljava/lang/String;I)V

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mWidth:I

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mHeight:I

    mul-int/2addr v1, v3

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    mul-int/2addr v1, v3

    int-to-double v3, v1

    const-wide v5, 0x3fd6978d4fdf3b64L    # 0.353

    mul-double/2addr v3, v5

    double-to-long v3, v3

    const-wide/32 v5, 0x16e3600

    invoke-static {v5, v6, v3, v4}, Ljava/lang/Math;->min(JJ)J

    move-result-wide v3

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mScale:I

    int-to-long v5, v1

    mul-long/2addr v3, v5

    long-to-float v1, v3

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

    mul-float/2addr v1, v3

    float-to-long v3, v1

    const-wide/32 v5, 0x3938700

    invoke-static {v5, v6, v3, v4}, Ljava/lang/Math;->min(JJ)J

    move-result-wide v3

    const-wide/32 v5, 0xf4240

    invoke-static {v5, v6, v3, v4}, Ljava/lang/Math;->max(JJ)J

    move-result-wide v3

    long-to-int v1, v3

    const-string v3, "bitrate"

    invoke-virtual {v0, v3, v1}, Landroid/media/MediaFormat;->setInteger(Ljava/lang/String;I)V

    const-string v1, "bitrate-mode"

    const/4 v3, 0x2

    invoke-virtual {v0, v1, v3}, Landroid/media/MediaFormat;->setInteger(Ljava/lang/String;I)V

    const-string v1, "frame-rate"

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    invoke-virtual {v0, v1, v3}, Landroid/media/MediaFormat;->setInteger(Ljava/lang/String;I)V

    const-string v1, "i-frame-interval"

    const/4 v3, 0x1

    invoke-virtual {v0, v1, v3}, Landroid/media/MediaFormat;->setInteger(Ljava/lang/String;I)V

    const-string v1, "profile"

    const/16 v4, 0x8

    invoke-virtual {v0, v1, v4}, Landroid/media/MediaFormat;->setInteger(Ljava/lang/String;I)V

    const-string v1, "level"

    const/16 v4, 0x1000

    invoke-virtual {v0, v1, v4}, Landroid/media/MediaFormat;->setInteger(Ljava/lang/String;I)V

    invoke-static {v2}, Landroid/media/MediaCodec;->createEncoderByType(Ljava/lang/String;)Landroid/media/MediaCodec;

    move-result-object v1

    iput-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    const/4 v2, 0x0

    invoke-virtual {v1, v0, v2, v2, v3}, Landroid/media/MediaCodec;->configure(Landroid/media/MediaFormat;Landroid/view/Surface;Landroid/media/MediaCrypto;I)V

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    invoke-virtual {v0}, Landroid/media/MediaCodec;->createInputSurface()Landroid/view/Surface;

    move-result-object v0

    iput-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mSurface:Landroid/view/Surface;

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    invoke-virtual {v0}, Landroid/media/MediaCodec;->start()V

    new-instance v0, Landroid/media/MediaMuxer;

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mOut:Ljava/io/FileDescriptor;

    const/4 v3, 0x0

    invoke-direct {v0, v1, v3}, Landroid/media/MediaMuxer;-><init>(Ljava/io/FileDescriptor;I)V

    iput-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mMuxer:Landroid/media/MediaMuxer;

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mRotation:I

    invoke-virtual {v0, v1}, Landroid/media/MediaMuxer;->setOrientationHint(I)V

    iget-boolean v0, p0, Lcom/k4/media/K4SlowMoExport;->mAudio:Z

    if-eqz v0, :cond_b2

    :try_start_91
    invoke-direct {p0}, Lcom/k4/media/K4SlowMoExport;->prepareAudio()V
    :try_end_94
    .catchall {:try_start_91 .. :try_end_94} :catchall_95

    goto :goto_b2

    :catchall_95
    move-exception v0

    iput-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mAudioFormat:Landroid/media/MediaFormat;

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mAudioData:Ljava/util/ArrayList;

    invoke-virtual {v1}, Ljava/util/ArrayList;->clear()V

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mAudioInfo:Ljava/util/ArrayList;

    invoke-virtual {v1}, Ljava/util/ArrayList;->clear()V

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v3, "audio left out: "

    invoke-direct {v1, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mAudioNote:Ljava/lang/String;

    :cond_b2
    :goto_b2
    new-instance v0, Ljava/lang/Thread;

    new-instance v1, Lcom/k4/media/K4SlowMoExport$1;

    invoke-direct {v1, p0}, Lcom/k4/media/K4SlowMoExport$1;-><init>(Lcom/k4/media/K4SlowMoExport;)V

    const-string v3, "K4SlowMoExportDrain"

    invoke-direct {v0, v1, v3}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V

    iput-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mDrain:Ljava/lang/Thread;

    invoke-virtual {v0}, Ljava/lang/Thread;->start()V

    const-string v0, "com.samsung.android.media.SemMediaPlayer"

    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    iput-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    invoke-static {}, Lcom/k4/media/K4SlowMoExport;->announceSave()V

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    invoke-virtual {v0, v2}, Ljava/lang/Class;->getDeclaredConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    iput-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    const-string v0, "OnInitCompleteListener"

    invoke-direct {p0, v0}, Lcom/k4/media/K4SlowMoExport;->listen(Ljava/lang/String;)V

    const-string v0, "OnErrorListener"

    invoke-direct {p0, v0}, Lcom/k4/media/K4SlowMoExport;->listen(Ljava/lang/String;)V

    const-string v0, "OnPlaybackCompleteListener"

    invoke-direct {p0, v0}, Lcom/k4/media/K4SlowMoExport;->listen(Ljava/lang/String;)V

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-class v1, Landroid/view/Surface;

    filled-new-array {v1}, [Ljava/lang/Class;

    move-result-object v1

    const-string v2, "setSurface"

    invoke-virtual {v0, v2, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mSurface:Landroid/view/Surface;

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-class v1, Ljava/io/FileDescriptor;

    sget-object v2, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    sget-object v3, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    filled-new-array {v1, v2, v3}, [Ljava/lang/Class;

    move-result-object v1

    const-string v2, "init"

    invoke-virtual {v0, v2, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mIn:Ljava/io/FileDescriptor;

    iget-wide v3, p0, Lcom/k4/media/K4SlowMoExport;->mInOffset:J

    invoke-static {v3, v4}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    iget-wide v4, p0, Lcom/k4/media/K4SlowMoExport;->mInLength:J

    invoke-static {v4, v5}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p0

    filled-new-array {v2, v3, p0}, [Ljava/lang/Object;

    move-result-object p0

    invoke-virtual {v0, v1, p0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    return-void
.end method

.method private blacklist drain()V
    .registers 13

    new-instance v0, Landroid/media/MediaCodec$BufferInfo;

    invoke-direct {v0}, Landroid/media/MediaCodec$BufferInfo;-><init>()V

    :cond_5
    :goto_5
    :try_start_5
    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    const-wide/16 v2, 0x4e20

    invoke-virtual {v1, v0, v2, v3}, Landroid/media/MediaCodec;->dequeueOutputBuffer(Landroid/media/MediaCodec$BufferInfo;J)I

    move-result v1

    const/4 v2, -0x2

    if-ne v1, v2, :cond_30

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mMuxer:Landroid/media/MediaMuxer;

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    invoke-virtual {v2}, Landroid/media/MediaCodec;->getOutputFormat()Landroid/media/MediaFormat;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/media/MediaMuxer;->addTrack(Landroid/media/MediaFormat;)I

    move-result v1

    iput v1, p0, Lcom/k4/media/K4SlowMoExport;->mTrack:I

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mAudioFormat:Landroid/media/MediaFormat;

    if-eqz v1, :cond_2a

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mMuxer:Landroid/media/MediaMuxer;

    invoke-virtual {v2, v1}, Landroid/media/MediaMuxer;->addTrack(Landroid/media/MediaFormat;)I

    move-result v1

    iput v1, p0, Lcom/k4/media/K4SlowMoExport;->mAudioTrack:I

    :cond_2a
    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mMuxer:Landroid/media/MediaMuxer;

    invoke-virtual {v1}, Landroid/media/MediaMuxer;->start()V

    goto :goto_5

    :cond_30
    if-gez v1, :cond_38

    iget-boolean v1, p0, Lcom/k4/media/K4SlowMoExport;->mDone:Z

    if-eqz v1, :cond_5

    goto/16 :goto_fa

    :cond_38
    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    invoke-virtual {v2, v1}, Landroid/media/MediaCodec;->getOutputBuffer(I)Ljava/nio/ByteBuffer;

    move-result-object v2

    iget v3, v0, Landroid/media/MediaCodec$BufferInfo;->flags:I

    and-int/lit8 v3, v3, 0x2

    const/4 v4, 0x0

    const/4 v5, 0x1

    if-eqz v3, :cond_48

    move v3, v5

    goto :goto_49

    :cond_48
    move v3, v4

    :goto_49
    iget v6, v0, Landroid/media/MediaCodec$BufferInfo;->flags:I

    and-int/2addr v6, v5

    if-eqz v6, :cond_50

    move v6, v5

    goto :goto_51

    :cond_50
    move v6, v4

    :goto_51
    if-nez v3, :cond_eb

    iget v3, v0, Landroid/media/MediaCodec$BufferInfo;->size:I

    if-lez v3, :cond_eb

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mTrack:I

    if-ltz v3, :cond_eb

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v7

    iput-wide v7, p0, Lcom/k4/media/K4SlowMoExport;->mLastFrameAt:J

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    iget v7, p0, Lcom/k4/media/K4SlowMoExport;->mExpected:I

    if-lt v3, v7, :cond_69

    goto/16 :goto_eb

    :cond_69
    iget-wide v7, v0, Landroid/media/MediaCodec$BufferInfo;->presentationTimeUs:J

    iget-wide v9, p0, Lcom/k4/media/K4SlowMoExport;->mFrcCallUs:J

    cmp-long v3, v7, v9

    if-ltz v3, :cond_e6

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mDropped:I

    iget v7, p0, Lcom/k4/media/K4SlowMoExport;->mSkip:I

    if-lt v3, v7, :cond_e6

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    if-nez v3, :cond_7e

    if-nez v6, :cond_7e

    goto :goto_e6

    :cond_7e
    iget-wide v6, p0, Lcom/k4/media/K4SlowMoExport;->mLastPtsUs:J

    const-wide/16 v8, 0x0

    cmp-long v3, v6, v8

    if-ltz v3, :cond_a2

    iget-wide v6, v0, Landroid/media/MediaCodec$BufferInfo;->presentationTimeUs:J

    iget-wide v10, p0, Lcom/k4/media/K4SlowMoExport;->mLastPtsUs:J

    sub-long/2addr v6, v10

    iget-wide v10, p0, Lcom/k4/media/K4SlowMoExport;->mFrameUs:J

    long-to-float v3, v10

    iget v10, p0, Lcom/k4/media/K4SlowMoExport;->mRate:F

    mul-float/2addr v3, v10

    iget v10, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

    div-float/2addr v3, v10

    const v10, 0x3fcccccd    # 1.6f

    mul-float/2addr v3, v10

    float-to-long v10, v3

    cmp-long v3, v6, v10

    if-lez v3, :cond_a2

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mGaps:I

    add-int/2addr v3, v5

    iput v3, p0, Lcom/k4/media/K4SlowMoExport;->mGaps:I

    :cond_a2
    iget-wide v6, p0, Lcom/k4/media/K4SlowMoExport;->mFirstPtsUs:J

    cmp-long v3, v6, v8

    if-gez v3, :cond_ac

    iget-wide v6, v0, Landroid/media/MediaCodec$BufferInfo;->presentationTimeUs:J

    iput-wide v6, p0, Lcom/k4/media/K4SlowMoExport;->mFirstPtsUs:J

    :cond_ac
    iget-wide v6, v0, Landroid/media/MediaCodec$BufferInfo;->presentationTimeUs:J

    iput-wide v6, p0, Lcom/k4/media/K4SlowMoExport;->mLastPtsUs:J

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    int-to-long v6, v3

    iget-wide v8, p0, Lcom/k4/media/K4SlowMoExport;->mFrameUs:J

    mul-long/2addr v6, v8

    iput-wide v6, v0, Landroid/media/MediaCodec$BufferInfo;->presentationTimeUs:J

    iget-object v3, p0, Lcom/k4/media/K4SlowMoExport;->mMuxer:Landroid/media/MediaMuxer;

    iget v6, p0, Lcom/k4/media/K4SlowMoExport;->mTrack:I

    invoke-virtual {v3, v6, v2, v0}, Landroid/media/MediaMuxer;->writeSampleData(ILjava/nio/ByteBuffer;Landroid/media/MediaCodec$BufferInfo;)V

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    add-int/2addr v2, v5

    iput v2, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    int-to-long v2, v2

    iget-wide v6, p0, Lcom/k4/media/K4SlowMoExport;->mFrameUs:J

    mul-long/2addr v2, v6

    invoke-direct {p0, v2, v3}, Lcom/k4/media/K4SlowMoExport;->writeAudio(J)V

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mExpected:I

    if-ne v2, v3, :cond_eb

    iget-boolean v2, p0, Lcom/k4/media/K4SlowMoExport;->mStopping:Z

    if-nez v2, :cond_eb

    iput-boolean v5, p0, Lcom/k4/media/K4SlowMoExport;->mStopping:Z

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iput v2, p0, Lcom/k4/media/K4SlowMoExport;->mPositionMs:I

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mHandler:Landroid/os/Handler;

    new-instance v3, Lcom/k4/media/K4SlowMoExport$3;

    invoke-direct {v3, p0}, Lcom/k4/media/K4SlowMoExport$3;-><init>(Lcom/k4/media/K4SlowMoExport;)V

    invoke-virtual {v2, v3}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    goto :goto_eb

    :cond_e6
    :goto_e6
    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mDropped:I

    add-int/2addr v2, v5

    iput v2, p0, Lcom/k4/media/K4SlowMoExport;->mDropped:I

    :cond_eb
    :goto_eb
    iget v2, v0, Landroid/media/MediaCodec$BufferInfo;->flags:I

    and-int/lit8 v2, v2, 0x4

    if-eqz v2, :cond_f2

    goto :goto_f3

    :cond_f2
    move v5, v4

    :goto_f3
    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    invoke-virtual {v2, v1, v4}, Landroid/media/MediaCodec;->releaseOutputBuffer(IZ)V

    if-eqz v5, :cond_5

    :goto_fa
    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    int-to-long v0, v0

    iget-wide v2, p0, Lcom/k4/media/K4SlowMoExport;->mFrameUs:J

    mul-long/2addr v0, v2

    invoke-direct {p0, v0, v1}, Lcom/k4/media/K4SlowMoExport;->writeAudio(J)V
    :try_end_103
    .catchall {:try_start_5 .. :try_end_103} :catchall_104

    return-void

    :catchall_104
    move-exception v0

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mError:Ljava/lang/String;

    if-nez v1, :cond_124

    iget-boolean v1, p0, Lcom/k4/media/K4SlowMoExport;->mDone:Z

    if-nez v1, :cond_124

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "encoder: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    iput-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mError:Ljava/lang/String;

    const-string p0, "K4SlowMo"

    const-string v1, "save: encoder/muxer thread"

    invoke-static {p0, v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_124
    return-void
.end method

.method private blacklist finish(ZLjava/lang/String;)V
    .registers 8

    iget-boolean v0, p0, Lcom/k4/media/K4SlowMoExport;->mDone:Z

    if-eqz v0, :cond_6

    goto/16 :goto_150

    :cond_6
    :try_start_6
    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    if-eqz v0, :cond_18

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string v1, "release"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    invoke-virtual {v0, v1, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_18
    .catchall {:try_start_6 .. :try_end_18} :catchall_18

    :catchall_18
    :cond_18
    :try_start_18
    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    if-eqz v0, :cond_1f

    invoke-virtual {v0}, Landroid/media/MediaCodec;->signalEndOfInputStream()V
    :try_end_1f
    .catchall {:try_start_18 .. :try_end_1f} :catchall_1f

    :catchall_1f
    :cond_1f
    :try_start_1f
    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mDrain:Ljava/lang/Thread;

    if-eqz v0, :cond_28

    const-wide/16 v1, 0xbb8

    invoke-virtual {v0, v1, v2}, Ljava/lang/Thread;->join(J)V
    :try_end_28
    .catch Ljava/lang/InterruptedException; {:try_start_1f .. :try_end_28} :catch_28

    :catch_28
    :cond_28
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/k4/media/K4SlowMoExport;->mDone:Z

    const/4 v0, 0x0

    :try_start_2c
    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mTrack:I

    if-ltz v1, :cond_47

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mMuxer:Landroid/media/MediaMuxer;

    invoke-virtual {v1}, Landroid/media/MediaMuxer;->stop()V
    :try_end_35
    .catchall {:try_start_2c .. :try_end_35} :catchall_36

    goto :goto_48

    :catchall_36
    move-exception p1

    if-nez p2, :cond_47

    new-instance p2, Ljava/lang/StringBuilder;

    const-string v1, "muxer: "

    invoke-direct {p2, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    :cond_47
    move p1, v0

    :goto_48
    :try_start_48
    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mMuxer:Landroid/media/MediaMuxer;

    if-eqz v1, :cond_4f

    invoke-virtual {v1}, Landroid/media/MediaMuxer;->release()V
    :try_end_4f
    .catchall {:try_start_48 .. :try_end_4f} :catchall_4f

    :catchall_4f
    :cond_4f
    :try_start_4f
    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    if-eqz v1, :cond_5b

    invoke-virtual {v1}, Landroid/media/MediaCodec;->stop()V

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    invoke-virtual {v1}, Landroid/media/MediaCodec;->release()V
    :try_end_5b
    .catchall {:try_start_4f .. :try_end_5b} :catchall_5b

    :catchall_5b
    :cond_5b
    :try_start_5b
    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mSurface:Landroid/view/Surface;

    if-eqz v1, :cond_62

    invoke-virtual {v1}, Landroid/view/Surface;->release()V
    :try_end_62
    .catchall {:try_start_5b .. :try_end_62} :catchall_62

    :catchall_62
    :cond_62
    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    sub-int/2addr v1, v2

    int-to-long v1, v1

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    int-to-long v3, v3

    mul-long/2addr v1, v3

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mScale:I

    int-to-long v3, v3

    mul-long/2addr v1, v3

    const-wide/16 v3, 0x3e8

    div-long/2addr v1, v3

    long-to-int v1, v1

    if-eqz p1, :cond_9a

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    div-int/lit8 v3, v1, 0x2

    if-ge v2, v3, :cond_9a

    new-instance p1, Ljava/lang/StringBuilder;

    const-string p2, "only "

    invoke-direct {p1, p2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget p2, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p2, " of "

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p2, " frames"

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    goto :goto_9b

    :cond_9a
    move v0, p1

    :goto_9b
    new-instance p1, Ljava/lang/StringBuilder;

    const-string v2, "save: neural x"

    invoke-direct {p1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mScale:I

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " "

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mWidth:I

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, "x"

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mHeight:I

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, ".."

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " ms -> "

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " frames (expected "

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, ", "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mDropped:I

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " before the section ("

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mSkip:I

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " pre-roll), "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mGaps:I

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " gaps, played at "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    const-string v1, "x; "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mAudioNote:Ljava/lang/String;

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ") in "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v1

    iget-wide v3, p0, Lcom/k4/media/K4SlowMoExport;->mT0:J

    sub-long/2addr v1, v3

    invoke-virtual {p1, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string v1, " ms: "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    if-eqz v0, :cond_12a

    const-string v1, "ok"

    goto :goto_138

    :cond_12a
    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "FAILED "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    :goto_138
    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string v1, "K4SlowMo"

    invoke-static {v1, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    iget-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mThread:Landroid/os/HandlerThread;

    invoke-virtual {p1}, Landroid/os/HandlerThread;->quitSafely()Z

    iget-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mListener:Lcom/k4/media/K4SlowMoExport$Listener;

    if-eqz p1, :cond_150

    invoke-interface {p1, p0, v0, p2}, Lcom/k4/media/K4SlowMoExport$Listener;->onFinished(Lcom/k4/media/K4SlowMoExport;ZLjava/lang/String;)V

    :cond_150
    :goto_150
    return-void
.end method

.method private blacklist listen(Ljava/lang/String;)V
    .registers 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "com.samsung.android.media.SemMediaPlayer$"

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "set"

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {v1, p1, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p1

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    invoke-virtual {v0}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v2

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    invoke-static {v2, v0, p0}, Ljava/lang/reflect/Proxy;->newProxyInstance(Ljava/lang/ClassLoader;[Ljava/lang/Class;Ljava/lang/reflect/InvocationHandler;)Ljava/lang/Object;

    move-result-object p0

    filled-new-array {p0}, [Ljava/lang/Object;

    move-result-object p0

    invoke-virtual {p1, v1, p0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    return-void
.end method

.method public static blacklist main([Ljava/lang/String;)V
    .registers 16
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    invoke-static {}, Landroid/os/Looper;->prepareMainLooper()V

    new-instance v0, Ljava/io/FileInputStream;

    const/4 v1, 0x0

    aget-object v1, p0, v1

    invoke-direct {v0, v1}, Ljava/io/FileInputStream;-><init>(Ljava/lang/String;)V

    new-instance v1, Ljava/io/FileOutputStream;

    const/4 v2, 0x1

    aget-object v2, p0, v2

    invoke-direct {v1, v2}, Ljava/io/FileOutputStream;-><init>(Ljava/lang/String;)V

    filled-new-array {v0, v1}, [Ljava/lang/Object;

    move-result-object v2

    sput-object v2, Lcom/k4/media/K4SlowMoExport;->sKeep:Ljava/lang/Object;

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v2

    new-instance v4, Lcom/k4/media/K4SlowMoExport;

    invoke-virtual {v0}, Ljava/io/FileInputStream;->getFD()Ljava/io/FileDescriptor;

    move-result-object v5

    invoke-virtual {v1}, Ljava/io/FileOutputStream;->getFD()Ljava/io/FileDescriptor;

    move-result-object v10

    const/4 v0, 0x2

    aget-object v0, p0, v0

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v11

    const/4 v0, 0x3

    aget-object v0, p0, v0

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v12

    array-length v0, p0

    const/4 v1, 0x4

    if-le v0, v1, :cond_40

    aget-object v0, p0, v1

    invoke-static {v0}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result v0

    goto :goto_42

    :cond_40
    const/high16 v0, 0x3e800000    # 0.25f

    :goto_42
    move v13, v0

    new-instance v14, Lcom/k4/media/K4SlowMoExport$4;

    invoke-direct {v14, v2, v3}, Lcom/k4/media/K4SlowMoExport$4;-><init>(J)V

    const-wide/16 v6, 0x0

    const-wide v8, 0x7ffffffffffffffL

    invoke-direct/range {v4 .. v14}, Lcom/k4/media/K4SlowMoExport;-><init>(Ljava/io/FileDescriptor;JJLjava/io/FileDescriptor;IIFLcom/k4/media/K4SlowMoExport$Listener;)V

    array-length v0, p0

    const/4 v1, 0x6

    if-le v0, v1, :cond_5e

    aget-object v0, p0, v1

    invoke-static {v0}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result v0

    sput v0, Lcom/k4/media/K4SlowMoExport;->sPlaybackFactor:F

    :cond_5e
    array-length v0, p0

    const/4 v1, 0x7

    if-le v0, v1, :cond_6c

    aget-object v0, p0, v1

    const-string v1, "audio"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    sput-boolean v0, Lcom/k4/media/K4SlowMoExport;->sAudio:Z

    :cond_6c
    invoke-virtual {v4}, Lcom/k4/media/K4SlowMoExport;->start()V

    array-length v0, p0

    const/4 v1, 0x5

    if-le v0, v1, :cond_93

    aget-object v0, p0, v1

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0

    if-lez v0, :cond_93

    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v2

    invoke-direct {v0, v2}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    new-instance v2, Lcom/k4/media/K4SlowMoExport$5;

    invoke-direct {v2, v4}, Lcom/k4/media/K4SlowMoExport$5;-><init>(Lcom/k4/media/K4SlowMoExport;)V

    aget-object p0, p0, v1

    invoke-static {p0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p0

    int-to-long v5, p0

    invoke-virtual {v0, v2, v5, v6}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :cond_93
    new-instance p0, Ljava/lang/Thread;

    new-instance v0, Lcom/k4/media/K4SlowMoExport$6;

    invoke-direct {v0, v4}, Lcom/k4/media/K4SlowMoExport$6;-><init>(Lcom/k4/media/K4SlowMoExport;)V

    invoke-direct {p0, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    invoke-virtual {p0}, Ljava/lang/Thread;->start()V

    invoke-static {}, Landroid/os/Looper;->loop()V

    return-void
.end method

.method private blacklist prepareAudio()V
    .registers 44
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    move-object/from16 v0, p0

    const-string v1, "audio/mp4a-latm"

    const-string v2, "pcm-encoding"

    const-string v3, "channel-count"

    const-string v4, "sample-rate"

    new-instance v5, Landroid/media/MediaExtractor;

    invoke-direct {v5}, Landroid/media/MediaExtractor;-><init>()V

    const/4 v11, 0x0

    :try_start_10
    iget-object v6, v0, Lcom/k4/media/K4SlowMoExport;->mIn:Ljava/io/FileDescriptor;

    iget-wide v7, v0, Lcom/k4/media/K4SlowMoExport;->mInOffset:J

    iget-wide v9, v0, Lcom/k4/media/K4SlowMoExport;->mInLength:J

    invoke-virtual/range {v5 .. v10}, Landroid/media/MediaExtractor;->setDataSource(Ljava/io/FileDescriptor;JJ)V

    const/4 v6, 0x0

    move v7, v6

    :goto_1b
    invoke-virtual {v5}, Landroid/media/MediaExtractor;->getTrackCount()I

    move-result v8
    :try_end_1f
    .catchall {:try_start_10 .. :try_end_1f} :catchall_418

    const-string v9, "mime"

    if-ge v7, v8, :cond_42

    :try_start_23
    invoke-virtual {v5, v7}, Landroid/media/MediaExtractor;->getTrackFormat(I)Landroid/media/MediaFormat;

    move-result-object v8

    invoke-virtual {v8, v9}, Landroid/media/MediaFormat;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v10

    if-eqz v10, :cond_39

    const-string v12, "audio/"

    invoke-virtual {v10, v12}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v10

    if-eqz v10, :cond_39

    invoke-virtual {v5, v7}, Landroid/media/MediaExtractor;->selectTrack(I)V

    goto :goto_43

    :cond_39
    add-int/lit8 v7, v7, 0x1

    goto :goto_1b

    :catchall_3c
    move-exception v0

    move-object/from16 v18, v5

    move-object v1, v11

    goto/16 :goto_41e

    :cond_42
    move-object v8, v11

    :goto_43
    if-nez v8, :cond_4d

    const-string v1, "no audio track in the source"

    iput-object v1, v0, Lcom/k4/media/K4SlowMoExport;->mAudioNote:Ljava/lang/String;
    :try_end_49
    .catchall {:try_start_23 .. :try_end_49} :catchall_3c

    :try_start_49
    invoke-virtual {v5}, Landroid/media/MediaExtractor;->release()V
    :try_end_4c
    .catchall {:try_start_49 .. :try_end_4c} :catchall_400

    return-void

    :cond_4d
    :try_start_4d
    iget v7, v0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    int-to-long v12, v7

    const-wide/16 v14, 0x3e8

    mul-long/2addr v12, v14

    iget v7, v0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    move-wide/from16 v16, v14

    int-to-long v14, v7

    mul-long v14, v14, v16

    invoke-virtual {v5, v12, v13, v6}, Landroid/media/MediaExtractor;->seekTo(JI)V

    invoke-virtual {v8, v9}, Landroid/media/MediaFormat;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    invoke-static {v7}, Landroid/media/MediaCodec;->createDecoderByType(Ljava/lang/String;)Landroid/media/MediaCodec;

    move-result-object v7
    :try_end_65
    .catchall {:try_start_4d .. :try_end_65} :catchall_418

    :try_start_65
    invoke-virtual {v7, v8, v11, v11, v6}, Landroid/media/MediaCodec;->configure(Landroid/media/MediaFormat;Landroid/view/Surface;Landroid/media/MediaCrypto;I)V

    invoke-virtual {v7}, Landroid/media/MediaCodec;->start()V

    invoke-virtual {v8, v4}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;)I

    move-result v9

    invoke-virtual {v8, v3}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;)I

    move-result v8

    new-instance v10, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v10}, Ljava/io/ByteArrayOutputStream;-><init>()V
    :try_end_78
    .catchall {:try_start_65 .. :try_end_78} :catchall_40e

    :try_start_78
    new-instance v11, Landroid/media/MediaCodec$BufferInfo;

    invoke-direct {v11}, Landroid/media/MediaCodec$BufferInfo;-><init>()V

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v25
    :try_end_81
    .catchall {:try_start_78 .. :try_end_81} :catchall_407

    move/from16 v27, v6

    move/from16 v28, v27

    :goto_85
    const/16 v30, 0x4

    const-wide/32 v31, 0xf4240

    move-object/from16 v18, v7

    if-nez v27, :cond_1bc

    :try_start_8e
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v19
    :try_end_92
    .catchall {:try_start_8e .. :try_end_92} :catchall_1b3

    sub-long v19, v19, v25

    const-wide/16 v21, 0x1f40

    cmp-long v19, v19, v21

    if-gez v19, :cond_1bc

    if-nez v28, :cond_ed

    move/from16 v34, v8

    move-wide/from16 v36, v12

    move-object/from16 v6, v18

    const-wide/16 v7, 0x1388

    :try_start_a4
    invoke-virtual {v6, v7, v8}, Landroid/media/MediaCodec;->dequeueInputBuffer(J)I

    move-result v12

    if-ltz v12, :cond_f3

    invoke-virtual {v6, v12}, Landroid/media/MediaCodec;->getInputBuffer(I)Ljava/nio/ByteBuffer;

    move-result-object v7

    const/4 v8, 0x0

    invoke-virtual {v5, v7, v8}, Landroid/media/MediaExtractor;->readSampleData(Ljava/nio/ByteBuffer;I)I

    move-result v21

    invoke-virtual {v5}, Landroid/media/MediaExtractor;->getSampleTime()J

    move-result-wide v22
    :try_end_b7
    .catchall {:try_start_a4 .. :try_end_b7} :catchall_1b1

    if-ltz v21, :cond_d9

    const-wide/32 v7, 0x186a0

    add-long/2addr v7, v14

    cmp-long v7, v22, v7

    if-lez v7, :cond_c2

    goto :goto_d9

    :cond_c2
    const/16 v20, 0x0

    const/16 v24, 0x0

    move-object/from16 v18, v6

    move/from16 v19, v12

    :try_start_ca
    invoke-virtual/range {v18 .. v24}, Landroid/media/MediaCodec;->queueInputBuffer(IIIJI)V

    invoke-virtual {v5}, Landroid/media/MediaExtractor;->advance()Z
    :try_end_d0
    .catchall {:try_start_ca .. :try_end_d0} :catchall_d1

    goto :goto_f1

    :catchall_d1
    move-exception v0

    move-object/from16 v11, v18

    const/4 v1, 0x0

    move-object/from16 v18, v5

    goto/16 :goto_41e

    :cond_d9
    :goto_d9
    move-object/from16 v18, v6

    move/from16 v19, v12

    const-wide/16 v22, 0x0

    const/16 v24, 0x4

    const/16 v20, 0x0

    const/16 v21, 0x0

    :try_start_e5
    invoke-virtual/range {v18 .. v24}, Landroid/media/MediaCodec;->queueInputBuffer(IIIJI)V
    :try_end_e8
    .catchall {:try_start_e5 .. :try_end_e8} :catchall_1b3

    move-object/from16 v6, v18

    const/16 v28, 0x1

    goto :goto_f3

    :cond_ed
    move/from16 v34, v8

    move-wide/from16 v36, v12

    :goto_f1
    move-object/from16 v6, v18

    :cond_f3
    :goto_f3
    const-wide/16 v7, 0x1388

    :try_start_f5
    invoke-virtual {v6, v11, v7, v8}, Landroid/media/MediaCodec;->dequeueOutputBuffer(Landroid/media/MediaCodec$BufferInfo;J)I

    move-result v7

    const/4 v8, -0x2

    if-ne v7, v8, :cond_12d

    invoke-virtual {v6}, Landroid/media/MediaCodec;->getOutputFormat()Landroid/media/MediaFormat;

    move-result-object v7

    invoke-virtual {v7, v4}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;)I

    move-result v8

    invoke-virtual {v7, v3}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;)I

    move-result v9

    invoke-virtual {v7, v2}, Landroid/media/MediaFormat;->containsKey(Ljava/lang/String;)Z

    move-result v12

    if-eqz v12, :cond_11e

    invoke-virtual {v7, v2}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;)I

    move-result v7

    const/4 v12, 0x2

    if-ne v7, v12, :cond_116

    goto :goto_11e

    :cond_116
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "PCM is not 16 bit"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_11e
    :goto_11e
    move/from16 v18, v9

    move v9, v8

    move/from16 v8, v18

    move-object/from16 v20, v2

    move-object/from16 v21, v3

    move-object/from16 v19, v4

    move-object/from16 v18, v5

    goto/16 :goto_1a4

    :cond_12d
    if-ltz v7, :cond_19a

    iget v8, v11, Landroid/media/MediaCodec$BufferInfo;->size:I

    if-lez v8, :cond_180

    iget-wide v12, v11, Landroid/media/MediaCodec$BufferInfo;->presentationTimeUs:J

    iget v8, v11, Landroid/media/MediaCodec$BufferInfo;->size:I

    mul-int/lit8 v18, v34, 0x2

    div-int v8, v8, v18

    sub-long v18, v36, v12

    move-object/from16 v20, v2

    move-object/from16 v21, v3

    int-to-long v2, v9

    mul-long v18, v18, v2

    move-wide/from16 v22, v2

    div-long v2, v18, v31
    :try_end_148
    .catchall {:try_start_f5 .. :try_end_148} :catchall_1b1

    move-object/from16 v19, v4

    move-object/from16 v18, v5

    const-wide/16 v4, 0x0

    :try_start_14e
    invoke-static {v4, v5, v2, v3}, Ljava/lang/Math;->max(JJ)J

    move-result-wide v2

    long-to-int v2, v2

    int-to-long v3, v8

    sub-long v12, v14, v12

    mul-long v12, v12, v22

    div-long v12, v12, v31

    invoke-static {v3, v4, v12, v13}, Ljava/lang/Math;->min(JJ)J

    move-result-wide v3

    long-to-int v3, v3

    if-le v3, v2, :cond_188

    sub-int/2addr v3, v2

    const/16 v35, 0x2

    mul-int/lit8 v3, v3, 0x2

    mul-int v3, v3, v34

    new-array v4, v3, [B

    invoke-virtual {v6, v7}, Landroid/media/MediaCodec;->getOutputBuffer(I)Ljava/nio/ByteBuffer;

    move-result-object v5

    iget v8, v11, Landroid/media/MediaCodec$BufferInfo;->offset:I

    mul-int/lit8 v2, v2, 0x2

    mul-int v2, v2, v34

    add-int/2addr v8, v2

    invoke-virtual {v5, v8}, Ljava/nio/ByteBuffer;->position(I)Ljava/nio/ByteBuffer;

    invoke-virtual {v5, v4}, Ljava/nio/ByteBuffer;->get([B)Ljava/nio/ByteBuffer;

    const/4 v8, 0x0

    invoke-virtual {v10, v4, v8, v3}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_188

    :cond_180
    move-object/from16 v20, v2

    move-object/from16 v21, v3

    move-object/from16 v19, v4

    move-object/from16 v18, v5

    :cond_188
    :goto_188
    iget v2, v11, Landroid/media/MediaCodec$BufferInfo;->flags:I

    and-int/lit8 v2, v2, 0x4

    if-eqz v2, :cond_191

    const/16 v27, 0x1

    goto :goto_193

    :cond_191
    const/16 v27, 0x0

    :goto_193
    const/4 v8, 0x0

    invoke-virtual {v6, v7, v8}, Landroid/media/MediaCodec;->releaseOutputBuffer(IZ)V
    :try_end_197
    .catchall {:try_start_14e .. :try_end_197} :catchall_198

    goto :goto_1a2

    :catchall_198
    move-exception v0

    goto :goto_1b8

    :cond_19a
    move-object/from16 v20, v2

    move-object/from16 v21, v3

    move-object/from16 v19, v4

    move-object/from16 v18, v5

    :goto_1a2
    move/from16 v8, v34

    :goto_1a4
    move-object v7, v6

    move-object/from16 v5, v18

    move-object/from16 v4, v19

    move-object/from16 v2, v20

    move-object/from16 v3, v21

    move-wide/from16 v12, v36

    goto/16 :goto_85

    :catchall_1b1
    move-exception v0

    goto :goto_1b6

    :catchall_1b3
    move-exception v0

    move-object/from16 v6, v18

    :goto_1b6
    move-object/from16 v18, v5

    :goto_1b8
    move-object v11, v6

    const/4 v1, 0x0

    goto/16 :goto_41e

    :cond_1bc
    move/from16 v34, v8

    move-object/from16 v6, v18

    move-object/from16 v18, v5

    :try_start_1c2
    invoke-virtual {v10}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v2

    move/from16 v8, v34

    const/4 v3, 0x1

    if-lt v8, v3, :cond_3d1

    const/4 v12, 0x2

    if-gt v8, v12, :cond_3d1

    array-length v3, v2

    mul-int v4, v9, v8

    div-int/lit8 v4, v4, 0x5

    if-ge v3, v4, :cond_1d7

    goto/16 :goto_3d1

    :cond_1d7
    array-length v3, v2

    div-int/2addr v3, v12

    new-array v4, v3, [S

    invoke-static {v2}, Ljava/nio/ByteBuffer;->wrap([B)Ljava/nio/ByteBuffer;

    move-result-object v2

    sget-object v5, Ljava/nio/ByteOrder;->LITTLE_ENDIAN:Ljava/nio/ByteOrder;

    invoke-virtual {v2, v5}, Ljava/nio/ByteBuffer;->order(Ljava/nio/ByteOrder;)Ljava/nio/ByteBuffer;

    move-result-object v2

    invoke-virtual {v2}, Ljava/nio/ByteBuffer;->asShortBuffer()Ljava/nio/ShortBuffer;

    move-result-object v2

    invoke-virtual {v2, v4}, Ljava/nio/ShortBuffer;->get([S)Ljava/nio/ShortBuffer;

    div-int/2addr v3, v8

    iget v2, v0, Lcom/k4/media/K4SlowMoExport;->mExpected:I

    int-to-long v12, v2

    iget-wide v14, v0, Lcom/k4/media/K4SlowMoExport;->mFrameUs:J

    mul-long/2addr v12, v14

    int-to-long v14, v9

    mul-long/2addr v12, v14

    div-long v12, v12, v31

    iget v2, v0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iget v5, v0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I
    :try_end_1fb
    .catchall {:try_start_1c2 .. :try_end_1fb} :catchall_403

    sub-int/2addr v2, v5

    move-object v7, v6

    int-to-long v5, v2

    mul-long/2addr v5, v14

    :try_start_1ff
    div-long v5, v5, v16

    move-wide/from16 v19, v5

    int-to-long v5, v3

    sub-long v21, v5, v19

    invoke-static/range {v21 .. v22}, Ljava/lang/Math;->abs(J)J

    move-result-wide v21

    const-wide/16 v23, 0x32

    div-long v19, v19, v23

    cmp-long v2, v21, v19

    if-gtz v2, :cond_216

    long-to-double v12, v12

    int-to-double v2, v3

    :goto_214
    div-double/2addr v12, v2

    goto :goto_21c

    :cond_216
    iget v2, v0, Lcom/k4/media/K4SlowMoExport;->mRate:F

    float-to-double v2, v2

    const-wide/high16 v12, 0x3ff0000000000000L    # 1.0

    goto :goto_214

    :goto_21c
    invoke-static {v4, v8, v9, v12, v13}, Lcom/k4/media/K4TimeStretch;->stretch([SIID)[S

    move-result-object v2

    invoke-static {v1, v9, v8}, Landroid/media/MediaFormat;->createAudioFormat(Ljava/lang/String;II)Landroid/media/MediaFormat;

    move-result-object v3

    const-string v4, "aac-profile"

    const/4 v12, 0x2

    invoke-virtual {v3, v4, v12}, Landroid/media/MediaFormat;->setInteger(Ljava/lang/String;I)V

    const-string v4, "bitrate"

    const v10, 0xfa00

    mul-int/2addr v10, v8

    invoke-virtual {v3, v4, v10}, Landroid/media/MediaFormat;->setInteger(Ljava/lang/String;I)V

    const-string v4, "max-input-size"

    const/16 v10, 0x4000

    invoke-virtual {v3, v4, v10}, Landroid/media/MediaFormat;->setInteger(Ljava/lang/String;I)V

    invoke-static {v1}, Landroid/media/MediaCodec;->createEncoderByType(Ljava/lang/String;)Landroid/media/MediaCodec;

    move-result-object v1
    :try_end_23e
    .catchall {:try_start_1ff .. :try_end_23e} :catchall_3cf

    const/4 v4, 0x1

    const/4 v10, 0x0

    :try_start_240
    invoke-virtual {v1, v3, v10, v10, v4}, Landroid/media/MediaCodec;->configure(Landroid/media/MediaFormat;Landroid/view/Surface;Landroid/media/MediaCrypto;I)V

    invoke-virtual {v1}, Landroid/media/MediaCodec;->start()V

    array-length v3, v2

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v12

    const/4 v4, 0x0

    const/4 v10, 0x0

    const/16 v19, 0x0

    :goto_24f
    if-nez v19, :cond_34c

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v20
    :try_end_255
    .catchall {:try_start_240 .. :try_end_255} :catchall_3cb

    sub-long v20, v20, v12

    const-wide/16 v22, 0x3a98

    cmp-long v20, v20, v22

    if-gez v20, :cond_34c

    if-nez v10, :cond_2bd

    move-wide/from16 v20, v5

    move-object/from16 v22, v7

    const-wide/16 v5, 0x1388

    :try_start_265
    invoke-virtual {v1, v5, v6}, Landroid/media/MediaCodec;->dequeueInputBuffer(J)I

    move-result v7

    if-ltz v7, :cond_2c1

    invoke-virtual {v1, v7}, Landroid/media/MediaCodec;->getInputBuffer(I)Ljava/nio/ByteBuffer;

    move-result-object v5

    invoke-virtual {v5}, Ljava/nio/ByteBuffer;->clear()Ljava/nio/ByteBuffer;

    sub-int v6, v3, v4

    invoke-virtual {v5}, Ljava/nio/ByteBuffer;->capacity()I

    move-result v10

    const/16 v35, 0x2

    div-int/lit8 v10, v10, 0x2
    :try_end_27c
    .catchall {:try_start_265 .. :try_end_27c} :catchall_3c9

    move-object/from16 v36, v1

    mul-int/lit16 v1, v8, 0x1000

    :try_start_280
    invoke-static {v10, v1}, Ljava/lang/Math;->min(II)I

    move-result v1

    invoke-static {v6, v1}, Ljava/lang/Math;->min(II)I

    move-result v1

    div-int/2addr v1, v8

    mul-int/2addr v1, v8

    div-int v6, v4, v8

    move/from16 v37, v7

    int-to-long v6, v6

    mul-long v6, v6, v31

    div-long v40, v6, v14

    sget-object v6, Ljava/nio/ByteOrder;->LITTLE_ENDIAN:Ljava/nio/ByteOrder;

    invoke-virtual {v5, v6}, Ljava/nio/ByteBuffer;->order(Ljava/nio/ByteOrder;)Ljava/nio/ByteBuffer;

    move-result-object v5

    invoke-virtual {v5}, Ljava/nio/ByteBuffer;->asShortBuffer()Ljava/nio/ShortBuffer;

    move-result-object v5

    invoke-virtual {v5, v2, v4, v1}, Ljava/nio/ShortBuffer;->put([SII)Ljava/nio/ShortBuffer;

    add-int/2addr v4, v1

    if-lt v4, v3, :cond_2a5

    const/4 v5, 0x1

    goto :goto_2a6

    :cond_2a5
    const/4 v5, 0x0

    :goto_2a6
    mul-int/lit8 v39, v1, 0x2

    if-eqz v5, :cond_2ad

    move/from16 v42, v30

    goto :goto_2af

    :cond_2ad
    const/16 v42, 0x0

    :goto_2af
    const/16 v38, 0x0

    invoke-virtual/range {v36 .. v42}, Landroid/media/MediaCodec;->queueInputBuffer(IIIJI)V
    :try_end_2b4
    .catchall {:try_start_280 .. :try_end_2b4} :catchall_2b8

    move-object/from16 v1, v36

    move v10, v5

    goto :goto_2c1

    :catchall_2b8
    move-exception v0

    move-object/from16 v1, v36

    goto/16 :goto_415

    :cond_2bd
    move-wide/from16 v20, v5

    move-object/from16 v22, v7

    :cond_2c1
    :goto_2c1
    const-wide/16 v5, 0x1388

    :try_start_2c3
    invoke-virtual {v1, v11, v5, v6}, Landroid/media/MediaCodec;->dequeueOutputBuffer(Landroid/media/MediaCodec$BufferInfo;J)I

    move-result v7

    const/4 v5, -0x2

    if-ne v7, v5, :cond_2d1

    invoke-virtual {v1}, Landroid/media/MediaCodec;->getOutputFormat()Landroid/media/MediaFormat;

    move-result-object v6

    iput-object v6, v0, Lcom/k4/media/K4SlowMoExport;->mAudioFormat:Landroid/media/MediaFormat;

    goto :goto_33a

    :cond_2d1
    if-ltz v7, :cond_33a

    iget v6, v11, Landroid/media/MediaCodec$BufferInfo;->size:I

    if-lez v6, :cond_321

    iget v6, v11, Landroid/media/MediaCodec$BufferInfo;->flags:I

    const/16 v35, 0x2

    and-int/lit8 v6, v6, 0x2

    if-nez v6, :cond_321

    invoke-virtual {v1, v7}, Landroid/media/MediaCodec;->getOutputBuffer(I)Ljava/nio/ByteBuffer;

    move-result-object v6

    iget v5, v11, Landroid/media/MediaCodec$BufferInfo;->offset:I

    invoke-virtual {v6, v5}, Ljava/nio/ByteBuffer;->position(I)Ljava/nio/ByteBuffer;

    iget v5, v11, Landroid/media/MediaCodec$BufferInfo;->offset:I

    move/from16 v23, v3

    iget v3, v11, Landroid/media/MediaCodec$BufferInfo;->size:I

    add-int/2addr v5, v3

    invoke-virtual {v6, v5}, Ljava/nio/ByteBuffer;->limit(I)Ljava/nio/ByteBuffer;

    iget v3, v11, Landroid/media/MediaCodec$BufferInfo;->size:I

    invoke-static {v3}, Ljava/nio/ByteBuffer;->allocate(I)Ljava/nio/ByteBuffer;

    move-result-object v3

    invoke-virtual {v3, v6}, Ljava/nio/ByteBuffer;->put(Ljava/nio/ByteBuffer;)Ljava/nio/ByteBuffer;

    invoke-virtual {v3}, Ljava/nio/ByteBuffer;->flip()Ljava/nio/ByteBuffer;

    iget-object v5, v0, Lcom/k4/media/K4SlowMoExport;->mAudioData:Ljava/util/ArrayList;

    invoke-virtual {v5, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    iget-object v3, v0, Lcom/k4/media/K4SlowMoExport;->mAudioInfo:Ljava/util/ArrayList;

    iget-wide v5, v11, Landroid/media/MediaCodec$BufferInfo;->presentationTimeUs:J

    move/from16 v24, v4

    iget v4, v11, Landroid/media/MediaCodec$BufferInfo;->flags:I

    const/16 v33, 0x1

    and-int/lit8 v4, v4, 0x1

    move-wide/from16 v25, v5

    int-to-long v4, v4

    move-wide/from16 v27, v4

    const/4 v6, 0x2

    new-array v4, v6, [J

    const/16 v29, 0x0

    aput-wide v25, v4, v29

    aput-wide v27, v4, v33

    invoke-virtual {v3, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_328

    :cond_321
    move/from16 v23, v3

    move/from16 v24, v4

    const/4 v6, 0x2

    const/16 v33, 0x1

    :goto_328
    iget v3, v11, Landroid/media/MediaCodec$BufferInfo;->flags:I

    and-int/lit8 v3, v3, 0x4

    if-eqz v3, :cond_331

    move/from16 v29, v33

    goto :goto_333

    :cond_331
    const/16 v29, 0x0

    :goto_333
    const/4 v3, 0x0

    invoke-virtual {v1, v7, v3}, Landroid/media/MediaCodec;->releaseOutputBuffer(IZ)V

    move/from16 v19, v29

    goto :goto_342

    :cond_33a
    :goto_33a
    move/from16 v23, v3

    move/from16 v24, v4

    const/4 v3, 0x0

    const/4 v6, 0x2

    const/16 v33, 0x1

    :goto_342
    move-wide/from16 v5, v20

    move-object/from16 v7, v22

    move/from16 v3, v23

    move/from16 v4, v24

    goto/16 :goto_24f

    :cond_34c
    move-wide/from16 v20, v5

    move-object/from16 v22, v7

    iget-object v3, v0, Lcom/k4/media/K4SlowMoExport;->mAudioFormat:Landroid/media/MediaFormat;

    if-eqz v3, :cond_3a5

    iget-object v3, v0, Lcom/k4/media/K4SlowMoExport;->mAudioData:Ljava/util/ArrayList;

    invoke-virtual {v3}, Ljava/util/ArrayList;->isEmpty()Z

    move-result v3

    if-eqz v3, :cond_35d

    goto :goto_3a5

    :cond_35d
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "audio "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v9}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v4, " Hz x"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v8}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v4, ", "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    mul-long v5, v20, v16

    div-long/2addr v5, v14

    invoke-virtual {v3, v5, v6}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string v4, " ms stretched to "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    array-length v2, v2

    div-int/2addr v2, v8

    int-to-long v4, v2

    mul-long v4, v4, v16

    div-long/2addr v4, v14

    invoke-virtual {v3, v4, v5}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string v2, " ms, "

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v2, v0, Lcom/k4/media/K4SlowMoExport;->mAudioData:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result v2

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " AAC frames"

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    :goto_3a2
    iput-object v2, v0, Lcom/k4/media/K4SlowMoExport;->mAudioNote:Ljava/lang/String;

    goto :goto_3b5

    :cond_3a5
    :goto_3a5
    const/4 v10, 0x0

    iput-object v10, v0, Lcom/k4/media/K4SlowMoExport;->mAudioFormat:Landroid/media/MediaFormat;

    iget-object v2, v0, Lcom/k4/media/K4SlowMoExport;->mAudioData:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->clear()V

    iget-object v2, v0, Lcom/k4/media/K4SlowMoExport;->mAudioInfo:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->clear()V

    const-string v2, "audio left out: encoder gave nothing"
    :try_end_3b4
    .catchall {:try_start_2c3 .. :try_end_3b4} :catchall_3c9

    goto :goto_3a2

    :goto_3b5
    :try_start_3b5
    invoke-virtual/range {v18 .. v18}, Landroid/media/MediaExtractor;->release()V
    :try_end_3b8
    .catchall {:try_start_3b5 .. :try_end_3b8} :catchall_3b8

    :catchall_3b8
    if-eqz v22, :cond_3c0

    :try_start_3ba
    invoke-virtual/range {v22 .. v22}, Landroid/media/MediaCodec;->stop()V

    invoke-virtual/range {v22 .. v22}, Landroid/media/MediaCodec;->release()V
    :try_end_3c0
    .catchall {:try_start_3ba .. :try_end_3c0} :catchall_3c0

    :catchall_3c0
    :cond_3c0
    if-eqz v1, :cond_400

    :try_start_3c2
    invoke-virtual {v1}, Landroid/media/MediaCodec;->stop()V

    invoke-virtual {v1}, Landroid/media/MediaCodec;->release()V
    :try_end_3c8
    .catchall {:try_start_3c2 .. :try_end_3c8} :catchall_400

    goto :goto_400

    :catchall_3c9
    move-exception v0

    goto :goto_415

    :catchall_3cb
    move-exception v0

    move-object/from16 v22, v7

    goto :goto_415

    :catchall_3cf
    move-exception v0

    goto :goto_40a

    :cond_3d1
    :goto_3d1
    move-object/from16 v22, v6

    const/4 v10, 0x0

    :try_start_3d4
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "audio left out: "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    array-length v2, v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " bytes of PCM, "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v8}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " channels"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    iput-object v1, v0, Lcom/k4/media/K4SlowMoExport;->mAudioNote:Ljava/lang/String;
    :try_end_3f5
    .catchall {:try_start_3d4 .. :try_end_3f5} :catchall_401

    :try_start_3f5
    invoke-virtual/range {v18 .. v18}, Landroid/media/MediaExtractor;->release()V
    :try_end_3f8
    .catchall {:try_start_3f5 .. :try_end_3f8} :catchall_3f8

    :catchall_3f8
    if-eqz v22, :cond_400

    :try_start_3fa
    invoke-virtual/range {v22 .. v22}, Landroid/media/MediaCodec;->stop()V

    invoke-virtual/range {v22 .. v22}, Landroid/media/MediaCodec;->release()V
    :try_end_400
    .catchall {:try_start_3fa .. :try_end_400} :catchall_400

    :catchall_400
    :cond_400
    :goto_400
    return-void

    :catchall_401
    move-exception v0

    goto :goto_414

    :catchall_403
    move-exception v0

    move-object/from16 v22, v6

    goto :goto_40c

    :catchall_407
    move-exception v0

    move-object/from16 v18, v5

    :goto_40a
    move-object/from16 v22, v7

    :goto_40c
    const/4 v10, 0x0

    goto :goto_414

    :catchall_40e
    move-exception v0

    move-object/from16 v18, v5

    move-object/from16 v22, v7

    move-object v10, v11

    :goto_414
    move-object v1, v10

    :goto_415
    move-object/from16 v11, v22

    goto :goto_41e

    :catchall_418
    move-exception v0

    move-object/from16 v18, v5

    move-object v10, v11

    move-object v1, v10

    move-object v11, v1

    :goto_41e
    :try_start_41e
    invoke-virtual/range {v18 .. v18}, Landroid/media/MediaExtractor;->release()V
    :try_end_421
    .catchall {:try_start_41e .. :try_end_421} :catchall_421

    :catchall_421
    if-eqz v11, :cond_429

    :try_start_423
    invoke-virtual {v11}, Landroid/media/MediaCodec;->stop()V

    invoke-virtual {v11}, Landroid/media/MediaCodec;->release()V
    :try_end_429
    .catchall {:try_start_423 .. :try_end_429} :catchall_429

    :catchall_429
    :cond_429
    if-eqz v1, :cond_431

    :try_start_42b
    invoke-virtual {v1}, Landroid/media/MediaCodec;->stop()V

    invoke-virtual {v1}, Landroid/media/MediaCodec;->release()V
    :try_end_431
    .catchall {:try_start_42b .. :try_end_431} :catchall_431

    :catchall_431
    :cond_431
    throw v0
.end method

.method private blacklist writeAudio(J)V
    .registers 13

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mAudioTrack:I

    if-gez v0, :cond_5

    goto :goto_57

    :cond_5
    new-instance v1, Landroid/media/MediaCodec$BufferInfo;

    invoke-direct {v1}, Landroid/media/MediaCodec$BufferInfo;-><init>()V

    :goto_a
    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mAudioNext:I

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mAudioData:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result v2

    if-ge v0, v2, :cond_57

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mAudioInfo:Ljava/util/ArrayList;

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mAudioNext:I

    invoke-virtual {v0, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [J

    const/4 v2, 0x0

    aget-wide v3, v0, v2

    cmp-long v0, v3, p1

    if-gtz v0, :cond_57

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mAudioData:Ljava/util/ArrayList;

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mAudioNext:I

    invoke-virtual {v0, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/nio/ByteBuffer;

    iget-object v3, p0, Lcom/k4/media/K4SlowMoExport;->mAudioInfo:Ljava/util/ArrayList;

    iget v4, p0, Lcom/k4/media/K4SlowMoExport;->mAudioNext:I

    invoke-virtual {v3, v4}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, [J

    move-object v4, v3

    invoke-virtual {v0}, Ljava/nio/ByteBuffer;->remaining()I

    move-result v3

    aget-wide v5, v4, v2

    const/4 v7, 0x1

    aget-wide v8, v4, v7

    long-to-int v2, v8

    move-wide v4, v5

    move v6, v2

    const/4 v2, 0x0

    invoke-virtual/range {v1 .. v6}, Landroid/media/MediaCodec$BufferInfo;->set(IIJI)V

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mMuxer:Landroid/media/MediaMuxer;

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mAudioTrack:I

    invoke-virtual {v2, v3, v0, v1}, Landroid/media/MediaMuxer;->writeSampleData(ILjava/nio/ByteBuffer;Landroid/media/MediaCodec$BufferInfo;)V

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mAudioNext:I

    add-int/2addr v0, v7

    iput v0, p0, Lcom/k4/media/K4SlowMoExport;->mAudioNext:I

    goto :goto_a

    :cond_57
    :goto_57
    return-void
.end method


# virtual methods
.method public blacklist cancel()V
    .registers 2

    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/k4/media/K4SlowMoExport;->mCancelled:Z

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mHandler:Landroid/os/Handler;

    if-eqz v0, :cond_a

    invoke-virtual {v0, p0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    :cond_a
    return-void
.end method

.method public blacklist getProgress()F
    .registers 4

    iget-boolean v0, p0, Lcom/k4/media/K4SlowMoExport;->mDone:Z

    if-eqz v0, :cond_7

    const/high16 p0, 0x3f800000    # 1.0f

    return p0

    :cond_7
    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mPositionMs:I

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    sub-int/2addr v0, v1

    int-to-float v0, v0

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    sub-int/2addr v2, v1

    const/4 v1, 0x1

    invoke-static {v1, v2}, Ljava/lang/Math;->max(II)I

    move-result v1

    int-to-float v1, v1

    div-float/2addr v0, v1

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mExpected:I

    const/4 v2, 0x0

    if-lez v1, :cond_22

    iget p0, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    int-to-float p0, p0

    int-to-float v1, v1

    div-float/2addr p0, v1

    goto :goto_23

    :cond_22
    move p0, v2

    :goto_23
    invoke-static {v0, p0}, Ljava/lang/Math;->max(FF)F

    move-result p0

    cmpg-float v0, p0, v2

    if-gez v0, :cond_2c

    return v2

    :cond_2c
    const v0, 0x3f7d70a4    # 0.99f

    cmpl-float v1, p0, v0

    if-lez v1, :cond_34

    return v0

    :cond_34
    return p0
.end method

.method public blacklist invoke(Ljava/lang/Object;Ljava/lang/reflect/Method;[Ljava/lang/Object;)Ljava/lang/Object;
    .registers 11

    const-string p1, "export: player not muted: "

    const-string v0, "player error "

    invoke-virtual {p2}, Ljava/lang/reflect/Method;->getName()Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    :try_start_9
    const-string v3, "onInitComplete"

    invoke-virtual {v1, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3
    :try_end_f
    .catchall {:try_start_9 .. :try_end_f} :catchall_136

    const/4 v4, 0x1

    if-eqz v3, :cond_f9

    :try_start_12
    iget-object p3, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string v0, "setVolume"

    sget-object v1, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    sget-object v3, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    filled-new-array {v1, v3}, [Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {p3, v0, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p3

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    const/4 v1, 0x0

    invoke-static {v1}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v3

    invoke-static {v1}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v1

    filled-new-array {v3, v1}, [Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {p3, v0, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_34
    .catchall {:try_start_12 .. :try_end_34} :catchall_35

    goto :goto_47

    :catchall_35
    move-exception p3

    :try_start_36
    const-string v0, "K4SlowMo"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1, p1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v0, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    :goto_47
    iget-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string p3, "seekTo"

    sget-object v0, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {p1, p3, v0}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p1

    iget-object p3, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mPreRollMs:I

    sub-int/2addr v0, v1

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    filled-new-array {v0}, [Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {p1, p3, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    iget p1, p0, Lcom/k4/media/K4SlowMoExport;->mScale:I

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    iget p3, p0, Lcom/k4/media/K4SlowMoExport;->mRate:F

    invoke-static {p3}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object p3

    sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    filled-new-array {p1, p3, v0}, [Ljava/lang/Object;

    move-result-object p1
    :try_end_79
    .catchall {:try_start_36 .. :try_end_79} :catchall_136

    :try_start_79
    iget-object p3, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string v0, "k4NativeVideoFrc"

    sget-object v1, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    sget-object v3, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    sget-object v5, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    filled-new-array {v1, v3, v5}, [Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {p3, v0, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p3
    :try_end_8b
    .catch Ljava/lang/NoSuchMethodException; {:try_start_79 .. :try_end_8b} :catch_8c
    .catchall {:try_start_79 .. :try_end_8b} :catchall_136

    goto :goto_a1

    :catch_8c
    :try_start_8c
    iget-object p3, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string v0, "_setVideoFrc"

    sget-object v1, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    sget-object v3, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    sget-object v5, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    filled-new-array {v1, v3, v5}, [Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {p3, v0, v1}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p3

    invoke-virtual {p3, v4}, Ljava/lang/reflect/Method;->setAccessible(Z)V

    :goto_a1
    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    invoke-virtual {p3, v0, p1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    iget p1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

    iget p3, p0, Lcom/k4/media/K4SlowMoExport;->mRate:F

    cmpl-float p1, p1, p3

    if-eqz p1, :cond_da

    iget-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string p3, "getPlaybackParams"

    invoke-virtual {p1, p3, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p1

    iget-object p3, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    invoke-virtual {p1, p3, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Landroid/media/PlaybackParams;

    iget p3, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

    invoke-virtual {p1, p3}, Landroid/media/PlaybackParams;->setSpeed(F)Landroid/media/PlaybackParams;

    iget-object p3, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string v0, "setPlaybackParams"

    const-class v1, Landroid/media/PlaybackParams;

    filled-new-array {v1}, [Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {p3, v0, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p3

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    filled-new-array {p1}, [Ljava/lang/Object;

    move-result-object p1

    invoke-virtual {p3, v0, p1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    :cond_da
    invoke-static {}, Ljava/lang/System;->nanoTime()J

    move-result-wide v0

    const-wide/16 v5, 0x3e8

    div-long/2addr v0, v5

    iput-wide v0, p0, Lcom/k4/media/K4SlowMoExport;->mFrcCallUs:J

    iget-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string p3, "start"

    invoke-virtual {p1, p3, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p1

    iget-object p3, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    invoke-virtual {p1, p3, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v0

    iput-wide v0, p0, Lcom/k4/media/K4SlowMoExport;->mPhaseAt:J

    iput-boolean v4, p0, Lcom/k4/media/K4SlowMoExport;->mPlaying:Z

    goto :goto_151

    :cond_f9
    const-string p1, "onError"

    invoke-virtual {v1, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_11f

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    aget-object v0, p3, v4

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string v0, " "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const/4 v0, 0x2

    aget-object p3, p3, v0

    invoke-virtual {p1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    iput-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mError:Ljava/lang/String;

    sget-object p0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    return-object p0

    :cond_11f
    const-string p1, "onPlaybackComplete"

    invoke-virtual {v1, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_151

    iget p1, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iput p1, p0, Lcom/k4/media/K4SlowMoExport;->mPositionMs:I

    iget-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mHandler:Landroid/os/Handler;

    new-instance p3, Lcom/k4/media/K4SlowMoExport$2;

    invoke-direct {p3, p0}, Lcom/k4/media/K4SlowMoExport$2;-><init>(Lcom/k4/media/K4SlowMoExport;)V

    invoke-virtual {p1, p3}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_135
    .catchall {:try_start_8c .. :try_end_135} :catchall_136

    goto :goto_151

    :catchall_136
    move-exception p1

    new-instance p3, Ljava/lang/StringBuilder;

    const-string v0, "player call failed: "

    invoke-direct {p3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v0

    if-eqz v0, :cond_148

    invoke-virtual {p1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object p1

    :cond_148
    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    iput-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mError:Ljava/lang/String;

    :cond_151
    :goto_151
    invoke-virtual {p2}, Ljava/lang/reflect/Method;->getReturnType()Ljava/lang/Class;

    move-result-object p0

    sget-object p1, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    if-ne p0, p1, :cond_15b

    sget-object v2, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    :cond_15b
    return-object v2
.end method

.method public blacklist run()V
    .registers 15

    const/4 v0, 0x0

    :try_start_1
    iget-boolean v1, p0, Lcom/k4/media/K4SlowMoExport;->mDone:Z

    if-eqz v1, :cond_7

    goto/16 :goto_b4

    :cond_7
    iget-boolean v1, p0, Lcom/k4/media/K4SlowMoExport;->mCancelled:Z

    if-eqz v1, :cond_11

    const-string v1, "cancelled"

    :goto_d
    invoke-direct {p0, v0, v1}, Lcom/k4/media/K4SlowMoExport;->finish(ZLjava/lang/String;)V

    return-void

    :cond_11
    iget-boolean v1, p0, Lcom/k4/media/K4SlowMoExport;->mStarted:Z

    const-wide/16 v2, 0x5

    if-nez v1, :cond_23

    const/4 v1, 0x1

    iput-boolean v1, p0, Lcom/k4/media/K4SlowMoExport;->mStarted:Z

    invoke-direct {p0}, Lcom/k4/media/K4SlowMoExport;->begin()V

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mHandler:Landroid/os/Handler;

    :goto_1f
    invoke-virtual {v1, p0, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    return-void

    :cond_23
    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mError:Ljava/lang/String;

    if-eqz v1, :cond_2a

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mError:Ljava/lang/String;

    goto :goto_d

    :cond_2a
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v4

    iget-wide v6, p0, Lcom/k4/media/K4SlowMoExport;->mT0:J

    sub-long/2addr v4, v6

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iget v6, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    sub-int/2addr v1, v6

    int-to-float v1, v1

    iget v6, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

    div-float/2addr v1, v6

    const/high16 v6, 0x40400000    # 3.0f

    mul-float/2addr v1, v6

    float-to-long v6, v1

    const-wide/16 v8, 0x4e20

    add-long/2addr v6, v8

    cmp-long v1, v4, v6

    if-lez v1, :cond_48

    const-string v1, "timeout"

    goto :goto_d

    :cond_48
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v4

    iget-boolean v1, p0, Lcom/k4/media/K4SlowMoExport;->mPlaying:Z

    if-eqz v1, :cond_9e

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string v6, "getCurrentPosition"

    const/4 v7, 0x0

    invoke-virtual {v1, v6, v7}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    iget-object v6, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    invoke-virtual {v1, v6, v7}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Integer;

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1

    iget v6, p0, Lcom/k4/media/K4SlowMoExport;->mPositionMs:I

    if-le v1, v6, :cond_6f

    iget v6, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    if-gt v1, v6, :cond_6f

    iput v1, p0, Lcom/k4/media/K4SlowMoExport;->mPositionMs:I

    :cond_6f
    iget-wide v6, p0, Lcom/k4/media/K4SlowMoExport;->mPhaseAt:J

    sub-long v8, v4, v6

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iget v10, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    sub-int/2addr v1, v10

    iget v10, p0, Lcom/k4/media/K4SlowMoExport;->mPreRollMs:I

    add-int/2addr v1, v10

    int-to-float v1, v1

    iget v10, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

    div-float/2addr v1, v10

    const/high16 v10, 0x40000000    # 2.0f

    mul-float/2addr v1, v10

    float-to-long v10, v1

    const-wide/16 v12, 0x3a98

    add-long/2addr v10, v12

    cmp-long v1, v8, v10

    if-lez v1, :cond_8d

    const-string v1, "player did not reach the end of the section"

    goto :goto_d

    :cond_8d
    iget-wide v8, p0, Lcom/k4/media/K4SlowMoExport;->mLastFrameAt:J

    invoke-static {v6, v7, v8, v9}, Ljava/lang/Math;->max(JJ)J

    move-result-wide v6

    sub-long/2addr v4, v6

    const-wide/16 v6, 0x1770

    cmp-long v1, v4, v6

    if-lez v1, :cond_9e

    const-string v1, "no frame from the player for 6 s"

    goto/16 :goto_d

    :cond_9e
    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mHandler:Landroid/os/Handler;
    :try_end_a0
    .catchall {:try_start_1 .. :try_end_a0} :catchall_a2

    goto/16 :goto_1f

    :catchall_a2
    move-exception v1

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "export failed: "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {p0, v0, v1}, Lcom/k4/media/K4SlowMoExport;->finish(ZLjava/lang/String;)V

    :goto_b4
    return-void
.end method

.method public blacklist start()V
    .registers 10
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-string v0, "frame-rate"

    const-string v1, "rotation-degrees"

    new-instance v2, Landroid/media/MediaExtractor;

    invoke-direct {v2}, Landroid/media/MediaExtractor;-><init>()V

    :try_start_9
    iget-object v3, p0, Lcom/k4/media/K4SlowMoExport;->mIn:Ljava/io/FileDescriptor;

    iget-wide v4, p0, Lcom/k4/media/K4SlowMoExport;->mInOffset:J

    iget-wide v6, p0, Lcom/k4/media/K4SlowMoExport;->mInLength:J

    invoke-virtual/range {v2 .. v7}, Landroid/media/MediaExtractor;->setDataSource(Ljava/io/FileDescriptor;JJ)V

    const/4 v3, 0x0

    move v4, v3

    :goto_14
    invoke-virtual {v2}, Landroid/media/MediaExtractor;->getTrackCount()I

    move-result v5

    if-ge v4, v5, :cond_40

    invoke-virtual {v2, v4}, Landroid/media/MediaExtractor;->getTrackFormat(I)Landroid/media/MediaFormat;

    move-result-object v5

    const-string v6, "mime"

    invoke-virtual {v5, v6}, Landroid/media/MediaFormat;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    if-eqz v6, :cond_3d

    const-string v7, "video/"

    invoke-virtual {v6, v7}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v7

    if-eqz v7, :cond_3d

    invoke-static {v6, v5}, Lcom/k4/media/K4SlowMo;->isEightBitSdr(Ljava/lang/String;Landroid/media/MediaFormat;)Z

    move-result v4

    if-eqz v4, :cond_35

    goto :goto_41

    :cond_35
    new-instance p0, Ljava/lang/IllegalStateException;

    const-string v0, "not an 8-bit SDR video"

    invoke-direct {p0, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p0

    :cond_3d
    add-int/lit8 v4, v4, 0x1

    goto :goto_14

    :cond_40
    const/4 v5, 0x0

    :goto_41
    if-eqz v5, :cond_13a

    const-string v4, "width"

    invoke-virtual {v5, v4}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;)I

    move-result v4

    iput v4, p0, Lcom/k4/media/K4SlowMoExport;->mWidth:I

    const-string v4, "height"

    invoke-virtual {v5, v4}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;)I

    move-result v4

    iput v4, p0, Lcom/k4/media/K4SlowMoExport;->mHeight:I

    invoke-virtual {v5, v1}, Landroid/media/MediaFormat;->containsKey(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_5e

    invoke-virtual {v5, v1}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;)I

    move-result v1

    goto :goto_5f

    :cond_5e
    move v1, v3

    :goto_5f
    iput v1, p0, Lcom/k4/media/K4SlowMoExport;->mRotation:I

    invoke-virtual {v5, v0}, Landroid/media/MediaFormat;->containsKey(Ljava/lang/String;)Z

    move-result v1

    const/4 v4, 0x1

    if-eqz v1, :cond_7a

    invoke-virtual {v5, v0}, Landroid/media/MediaFormat;->getNumber(Ljava/lang/String;)Ljava/lang/Number;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Number;->floatValue()F

    move-result v0

    invoke-static {v0}, Ljava/lang/Math;->round(F)I

    move-result v0

    invoke-static {v4, v0}, Ljava/lang/Math;->max(II)I

    move-result v0

    iput v0, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    :cond_7a
    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    const/16 v1, 0x1f

    if-gt v0, v1, :cond_10d

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mWidth:I

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mHeight:I

    invoke-static {v0, v1}, Ljava/lang/Math;->max(II)I

    move-result v0

    const/16 v1, 0x780

    if-gt v0, v1, :cond_10d

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mWidth:I

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mHeight:I

    invoke-static {v0, v1}, Ljava/lang/Math;->min(II)I

    move-result v0

    const/16 v1, 0x440

    if-gt v0, v1, :cond_10d

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    if-le v0, v1, :cond_10d

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    int-to-long v0, v0

    const-wide/32 v5, 0xf4240

    div-long/2addr v5, v0

    iput-wide v5, p0, Lcom/k4/media/K4SlowMoExport;->mFrameUs:J
    :try_end_a7
    .catchall {:try_start_9 .. :try_end_a7} :catchall_142

    invoke-virtual {v2}, Landroid/media/MediaExtractor;->release()V

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mRate:F

    sget v1, Lcom/k4/media/K4SlowMoExport;->sPlaybackFactor:F

    mul-float/2addr v0, v1

    iput v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

    sget-boolean v0, Lcom/k4/media/K4SlowMoExport;->sAudio:Z

    if-nez v0, :cond_be

    invoke-static {}, Lcom/k4/media/K4SlowMoExport;->audioProperty()Z

    move-result v0

    if-eqz v0, :cond_bc

    goto :goto_be

    :cond_bc
    move v0, v3

    goto :goto_bf

    :cond_be
    :goto_be
    move v0, v4

    :goto_bf
    iput-boolean v0, p0, Lcom/k4/media/K4SlowMoExport;->mAudio:Z

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    sub-int/2addr v0, v1

    int-to-long v5, v0

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    int-to-long v7, v0

    mul-long/2addr v5, v7

    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mScale:I

    int-to-long v7, v2

    mul-long/2addr v5, v7

    const-wide/16 v7, 0x3e8

    div-long/2addr v5, v7

    long-to-int v5, v5

    add-int/2addr v5, v4

    iput v5, p0, Lcom/k4/media/K4SlowMoExport;->mExpected:I

    const/16 v4, 0x1f4

    if-lt v1, v4, :cond_db

    move v3, v4

    :cond_db
    iput v3, p0, Lcom/k4/media/K4SlowMoExport;->mPreRollMs:I

    int-to-long v3, v3

    int-to-long v5, v0

    mul-long/2addr v3, v5

    int-to-long v1, v2

    mul-long/2addr v3, v1

    div-long/2addr v3, v7

    long-to-int v1, v3

    div-int/2addr v1, v0

    mul-int/2addr v1, v0

    iput v1, p0, Lcom/k4/media/K4SlowMoExport;->mSkip:I

    new-instance v0, Landroid/os/HandlerThread;

    const-string v1, "K4SlowMoExport"

    invoke-direct {v0, v1}, Landroid/os/HandlerThread;-><init>(Ljava/lang/String;)V

    iput-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mThread:Landroid/os/HandlerThread;

    invoke-virtual {v0}, Landroid/os/HandlerThread;->start()V

    new-instance v0, Landroid/os/Handler;

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mThread:Landroid/os/HandlerThread;

    invoke-virtual {v1}, Landroid/os/HandlerThread;->getLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mHandler:Landroid/os/Handler;

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v0

    iput-wide v0, p0, Lcom/k4/media/K4SlowMoExport;->mT0:J

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mHandler:Landroid/os/Handler;

    invoke-virtual {v0, p0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void

    :cond_10d
    :try_start_10d
    new-instance v0, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "unsupported source "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mWidth:I

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, "x"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mHeight:I

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, "@"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget p0, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_13a
    new-instance p0, Ljava/lang/IllegalStateException;

    const-string v0, "no video track"

    invoke-direct {p0, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p0
    :try_end_142
    .catchall {:try_start_10d .. :try_end_142} :catchall_142

    :catchall_142
    move-exception v0

    move-object p0, v0

    invoke-virtual {v2}, Landroid/media/MediaExtractor;->release()V

    throw p0
.end method
