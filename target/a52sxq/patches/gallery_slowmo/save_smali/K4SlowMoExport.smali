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
.field private static final blacklist PLAYER:Ljava/lang/String; = "com.samsung.android.media.SemMediaPlayer"

.field private static final blacklist TAG:Ljava/lang/String; = "K4SlowMo"

.field public static blacklist sPlaybackFactor:F = 0.5f


# instance fields
.field private volatile blacklist mCancelled:Z

.field private volatile blacklist mDone:Z

.field private blacklist mDrain:Ljava/lang/Thread;

.field private blacklist mDropped:I

.field private blacklist mEncoder:Landroid/media/MediaCodec;

.field private final blacklist mEndMs:I

.field private volatile blacklist mError:Ljava/lang/String;

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

.field private blacklist mLastPtsUs:J

.field private final blacklist mListener:Lcom/k4/media/K4SlowMoExport$Listener;

.field private blacklist mMuxer:Landroid/media/MediaMuxer;

.field private final blacklist mOut:Ljava/io/FileDescriptor;

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

.field private volatile blacklist mPositionMs:I

.field private final blacklist mRate:F

.field private blacklist mRotation:I

.field private final blacklist mScale:I

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

    if-gtz p1, :cond_33

    const/4 p1, 0x4

    goto :goto_34

    :cond_33
    const/4 p1, 0x2

    :goto_34
    iput p1, p0, Lcom/k4/media/K4SlowMoExport;->mScale:I

    iput-object p10, p0, Lcom/k4/media/K4SlowMoExport;->mListener:Lcom/k4/media/K4SlowMoExport$Listener;

    iput p7, p0, Lcom/k4/media/K4SlowMoExport;->mPositionMs:I

    return-void
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

    long-to-int v1, v3

    const-string v3, "bitrate"

    invoke-virtual {v0, v3, v1}, Landroid/media/MediaFormat;->setInteger(Ljava/lang/String;I)V

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

    if-ne v1, v2, :cond_24

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mMuxer:Landroid/media/MediaMuxer;

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    invoke-virtual {v2}, Landroid/media/MediaCodec;->getOutputFormat()Landroid/media/MediaFormat;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/media/MediaMuxer;->addTrack(Landroid/media/MediaFormat;)I

    move-result v1

    iput v1, p0, Lcom/k4/media/K4SlowMoExport;->mTrack:I

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mMuxer:Landroid/media/MediaMuxer;

    invoke-virtual {v1}, Landroid/media/MediaMuxer;->start()V

    goto :goto_5

    :cond_24
    if-gez v1, :cond_2c

    iget-boolean v1, p0, Lcom/k4/media/K4SlowMoExport;->mDone:Z

    if-eqz v1, :cond_5

    goto/16 :goto_d3

    :cond_2c
    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    invoke-virtual {v2, v1}, Landroid/media/MediaCodec;->getOutputBuffer(I)Ljava/nio/ByteBuffer;

    move-result-object v2

    iget v3, v0, Landroid/media/MediaCodec$BufferInfo;->flags:I

    and-int/lit8 v3, v3, 0x2

    const/4 v4, 0x0

    const/4 v5, 0x1

    if-eqz v3, :cond_3c

    move v3, v5

    goto :goto_3d

    :cond_3c
    move v3, v4

    :goto_3d
    iget v6, v0, Landroid/media/MediaCodec$BufferInfo;->flags:I

    and-int/2addr v6, v5

    if-eqz v6, :cond_44

    move v6, v5

    goto :goto_45

    :cond_44
    move v6, v4

    :goto_45
    if-nez v3, :cond_aa

    iget v3, v0, Landroid/media/MediaCodec$BufferInfo;->size:I

    if-lez v3, :cond_aa

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mTrack:I

    if-ltz v3, :cond_aa

    iget-wide v7, v0, Landroid/media/MediaCodec$BufferInfo;->presentationTimeUs:J

    iget-wide v9, p0, Lcom/k4/media/K4SlowMoExport;->mFrcCallUs:J

    cmp-long v3, v7, v9

    if-ltz v3, :cond_a5

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mWritten:I

    if-nez v3, :cond_5e

    if-nez v6, :cond_5e

    goto :goto_a5

    :cond_5e
    iget-wide v6, p0, Lcom/k4/media/K4SlowMoExport;->mLastPtsUs:J

    const-wide/16 v8, 0x0

    cmp-long v3, v6, v8

    if-ltz v3, :cond_82

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

    if-lez v3, :cond_82

    iget v3, p0, Lcom/k4/media/K4SlowMoExport;->mGaps:I

    add-int/2addr v3, v5

    iput v3, p0, Lcom/k4/media/K4SlowMoExport;->mGaps:I

    :cond_82
    iget-wide v6, p0, Lcom/k4/media/K4SlowMoExport;->mFirstPtsUs:J

    cmp-long v3, v6, v8

    if-gez v3, :cond_8c

    iget-wide v6, v0, Landroid/media/MediaCodec$BufferInfo;->presentationTimeUs:J

    iput-wide v6, p0, Lcom/k4/media/K4SlowMoExport;->mFirstPtsUs:J

    :cond_8c
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

    goto :goto_aa

    :cond_a5
    :goto_a5
    iget v2, p0, Lcom/k4/media/K4SlowMoExport;->mDropped:I

    add-int/2addr v2, v5

    iput v2, p0, Lcom/k4/media/K4SlowMoExport;->mDropped:I

    :cond_aa
    :goto_aa
    iget v2, v0, Landroid/media/MediaCodec$BufferInfo;->flags:I

    and-int/lit8 v2, v2, 0x4

    if-eqz v2, :cond_b1

    goto :goto_b2

    :cond_b1
    move v5, v4

    :goto_b2
    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport;->mEncoder:Landroid/media/MediaCodec;

    invoke-virtual {v2, v1, v4}, Landroid/media/MediaCodec;->releaseOutputBuffer(IZ)V
    :try_end_b7
    .catchall {:try_start_5 .. :try_end_b7} :catchall_ba

    if-eqz v5, :cond_5

    goto :goto_d3

    :catchall_ba
    move-exception v0

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mError:Ljava/lang/String;

    if-nez v1, :cond_d3

    iget-boolean v1, p0, Lcom/k4/media/K4SlowMoExport;->mDone:Z

    if-nez v1, :cond_d3

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "encoder: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mError:Ljava/lang/String;

    :cond_d3
    :goto_d3
    return-void
.end method

.method private blacklist finish(ZLjava/lang/String;)V
    .registers 8

    iget-boolean v0, p0, Lcom/k4/media/K4SlowMoExport;->mDone:Z

    if-eqz v0, :cond_6

    goto/16 :goto_13c

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

    const-string v1, " before the section, "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mGaps:I

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " gaps, played at "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    const-string v1, "x) in "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v1

    iget-wide v3, p0, Lcom/k4/media/K4SlowMoExport;->mT0:J

    sub-long/2addr v1, v3

    invoke-virtual {p1, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string v1, " ms: "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    if-eqz v0, :cond_116

    const-string v1, "ok"

    goto :goto_124

    :cond_116
    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "FAILED "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    :goto_124
    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string v1, "K4SlowMo"

    invoke-static {v1, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    iget-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mThread:Landroid/os/HandlerThread;

    invoke-virtual {p1}, Landroid/os/HandlerThread;->quitSafely()Z

    iget-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mListener:Lcom/k4/media/K4SlowMoExport$Listener;

    if-eqz p1, :cond_13c

    invoke-interface {p1, p0, v0, p2}, Lcom/k4/media/K4SlowMoExport$Listener;->onFinished(Lcom/k4/media/K4SlowMoExport;ZLjava/lang/String;)V

    :cond_13c
    :goto_13c
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

    if-le v0, v1, :cond_3a

    aget-object v0, p0, v1

    invoke-static {v0}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result v0

    goto :goto_3c

    :cond_3a
    const/high16 v0, 0x3e800000    # 0.25f

    :goto_3c
    move v13, v0

    new-instance v14, Lcom/k4/media/K4SlowMoExport$3;

    invoke-direct {v14, v2, v3}, Lcom/k4/media/K4SlowMoExport$3;-><init>(J)V

    const-wide/16 v6, 0x0

    const-wide v8, 0x7ffffffffffffffL

    invoke-direct/range {v4 .. v14}, Lcom/k4/media/K4SlowMoExport;-><init>(Ljava/io/FileDescriptor;JJLjava/io/FileDescriptor;IIFLcom/k4/media/K4SlowMoExport$Listener;)V

    array-length v0, p0

    const/4 v1, 0x6

    if-le v0, v1, :cond_58

    aget-object v0, p0, v1

    invoke-static {v0}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result v0

    sput v0, Lcom/k4/media/K4SlowMoExport;->sPlaybackFactor:F

    :cond_58
    invoke-virtual {v4}, Lcom/k4/media/K4SlowMoExport;->start()V

    array-length v0, p0

    const/4 v1, 0x5

    if-le v0, v1, :cond_7f

    aget-object v0, p0, v1

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0

    if-lez v0, :cond_7f

    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v2

    invoke-direct {v0, v2}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    new-instance v2, Lcom/k4/media/K4SlowMoExport$4;

    invoke-direct {v2, v4}, Lcom/k4/media/K4SlowMoExport$4;-><init>(Lcom/k4/media/K4SlowMoExport;)V

    aget-object p0, p0, v1

    invoke-static {p0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p0

    int-to-long v5, p0

    invoke-virtual {v0, v2, v5, v6}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :cond_7f
    new-instance p0, Ljava/lang/Thread;

    new-instance v0, Lcom/k4/media/K4SlowMoExport$5;

    invoke-direct {v0, v4}, Lcom/k4/media/K4SlowMoExport$5;-><init>(Lcom/k4/media/K4SlowMoExport;)V

    invoke-direct {p0, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    invoke-virtual {p0}, Ljava/lang/Thread;->start()V

    invoke-static {}, Landroid/os/Looper;->loop()V

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
    .registers 3

    iget-boolean v0, p0, Lcom/k4/media/K4SlowMoExport;->mDone:Z

    if-eqz v0, :cond_7

    const/high16 p0, 0x3f800000    # 1.0f

    return p0

    :cond_7
    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mPositionMs:I

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    sub-int/2addr v0, v1

    int-to-float v0, v0

    iget p0, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    sub-int/2addr p0, v1

    const/4 v1, 0x1

    invoke-static {v1, p0}, Ljava/lang/Math;->max(II)I

    move-result p0

    int-to-float p0, p0

    div-float/2addr v0, p0

    const/4 p0, 0x0

    cmpg-float v1, v0, p0

    if-gez v1, :cond_1d

    return p0

    :cond_1d
    const p0, 0x3f7d70a4    # 0.99f

    cmpl-float v1, v0, p0

    if-lez v1, :cond_25

    return p0

    :cond_25
    return v0
.end method

.method public blacklist invoke(Ljava/lang/Object;Ljava/lang/reflect/Method;[Ljava/lang/Object;)Ljava/lang/Object;
    .registers 10

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
    .catchall {:try_start_9 .. :try_end_f} :catchall_12b

    const/4 v4, 0x1

    if-eqz v3, :cond_ee

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

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    filled-new-array {v0}, [Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {p1, p3, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    iget-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string p3, "start"

    invoke-virtual {p1, p3, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p1

    iget-object p3, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    invoke-virtual {p1, p3, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    iget p1, p0, Lcom/k4/media/K4SlowMoExport;->mScale:I

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    iget p3, p0, Lcom/k4/media/K4SlowMoExport;->mRate:F

    invoke-static {p3}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object p3

    sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    filled-new-array {p1, p3, v0}, [Ljava/lang/Object;

    move-result-object p1
    :try_end_83
    .catchall {:try_start_36 .. :try_end_83} :catchall_12b

    :try_start_83
    iget-object p3, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string v0, "k4NativeVideoFrc"

    sget-object v1, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    sget-object v3, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    sget-object v5, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    filled-new-array {v1, v3, v5}, [Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {p3, v0, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p3
    :try_end_95
    .catch Ljava/lang/NoSuchMethodException; {:try_start_83 .. :try_end_95} :catch_96
    .catchall {:try_start_83 .. :try_end_95} :catchall_12b

    goto :goto_ab

    :catch_96
    :try_start_96
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

    :goto_ab
    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    invoke-virtual {p3, v0, p1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    iget p1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

    iget p3, p0, Lcom/k4/media/K4SlowMoExport;->mRate:F

    cmpl-float p1, p1, p3

    if-eqz p1, :cond_e4

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

    :cond_e4
    invoke-static {}, Ljava/lang/System;->nanoTime()J

    move-result-wide v0

    const-wide/16 v3, 0x3e8

    div-long/2addr v0, v3

    iput-wide v0, p0, Lcom/k4/media/K4SlowMoExport;->mFrcCallUs:J

    goto :goto_146

    :cond_ee
    const-string p1, "onError"

    invoke-virtual {v1, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_114

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

    :cond_114
    const-string p1, "onPlaybackComplete"

    invoke-virtual {v1, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_146

    iget p1, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iput p1, p0, Lcom/k4/media/K4SlowMoExport;->mPositionMs:I

    iget-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mHandler:Landroid/os/Handler;

    new-instance p3, Lcom/k4/media/K4SlowMoExport$2;

    invoke-direct {p3, p0}, Lcom/k4/media/K4SlowMoExport$2;-><init>(Lcom/k4/media/K4SlowMoExport;)V

    invoke-virtual {p1, p3}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_12a
    .catchall {:try_start_96 .. :try_end_12a} :catchall_12b

    goto :goto_146

    :catchall_12b
    move-exception p1

    new-instance p3, Ljava/lang/StringBuilder;

    const-string v0, "player call failed: "

    invoke-direct {p3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v0

    if-eqz v0, :cond_13d

    invoke-virtual {p1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object p1

    :cond_13d
    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    iput-object p1, p0, Lcom/k4/media/K4SlowMoExport;->mError:Ljava/lang/String;

    :cond_146
    :goto_146
    invoke-virtual {p2}, Ljava/lang/reflect/Method;->getReturnType()Ljava/lang/Class;

    move-result-object p0

    sget-object p1, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    if-ne p0, p1, :cond_150

    sget-object v2, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    :cond_150
    return-object v2
.end method

.method public blacklist run()V
    .registers 12

    const/4 v0, 0x0

    :try_start_1
    iget-boolean v1, p0, Lcom/k4/media/K4SlowMoExport;->mDone:Z

    if-eqz v1, :cond_7

    goto/16 :goto_8b

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

    const/4 v4, 0x1

    if-nez v1, :cond_23

    iput-boolean v4, p0, Lcom/k4/media/K4SlowMoExport;->mStarted:Z

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

    move-result-wide v5

    iget-wide v7, p0, Lcom/k4/media/K4SlowMoExport;->mT0:J

    sub-long/2addr v5, v7

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iget v7, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    sub-int/2addr v1, v7

    int-to-float v1, v1

    iget v7, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

    div-float/2addr v1, v7

    const/high16 v7, 0x40400000    # 3.0f

    mul-float/2addr v1, v7

    float-to-long v7, v1

    const-wide/16 v9, 0x4e20

    add-long/2addr v7, v9

    cmp-long v1, v5, v7

    if-lez v1, :cond_48

    const-string v1, "timeout"

    goto :goto_d

    :cond_48
    iget-wide v5, p0, Lcom/k4/media/K4SlowMoExport;->mFrcCallUs:J

    const-wide v7, 0x7fffffffffffffffL

    cmp-long v1, v5, v7

    if-eqz v1, :cond_76

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mPlayerClass:Ljava/lang/Class;

    const-string v5, "getCurrentPosition"

    const/4 v6, 0x0

    invoke-virtual {v1, v5, v6}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    iget-object v5, p0, Lcom/k4/media/K4SlowMoExport;->mPlayer:Ljava/lang/Object;

    invoke-virtual {v1, v5, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Integer;

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1

    iget v5, p0, Lcom/k4/media/K4SlowMoExport;->mPositionMs:I

    if-le v1, v5, :cond_6e

    iput v1, p0, Lcom/k4/media/K4SlowMoExport;->mPositionMs:I

    :cond_6e
    iget v5, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    if-lt v1, v5, :cond_76

    invoke-direct {p0, v4, v6}, Lcom/k4/media/K4SlowMoExport;->finish(ZLjava/lang/String;)V

    return-void

    :cond_76
    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport;->mHandler:Landroid/os/Handler;
    :try_end_78
    .catchall {:try_start_1 .. :try_end_78} :catchall_79

    goto :goto_1f

    :catchall_79
    move-exception v1

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "export failed: "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {p0, v0, v1}, Lcom/k4/media/K4SlowMoExport;->finish(ZLjava/lang/String;)V

    :goto_8b
    return-void
.end method

.method public blacklist start()V
    .registers 9
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
    if-eqz v5, :cond_101

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

    if-eqz v4, :cond_5d

    invoke-virtual {v5, v1}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;)I

    move-result v3

    :cond_5d
    iput v3, p0, Lcom/k4/media/K4SlowMoExport;->mRotation:I

    invoke-virtual {v5, v0}, Landroid/media/MediaFormat;->containsKey(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_78

    invoke-virtual {v5, v0}, Landroid/media/MediaFormat;->getNumber(Ljava/lang/String;)Ljava/lang/Number;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Number;->floatValue()F

    move-result v0

    invoke-static {v0}, Ljava/lang/Math;->round(F)I

    move-result v0

    const/4 v1, 0x1

    invoke-static {v1, v0}, Ljava/lang/Math;->max(II)I

    move-result v0

    iput v0, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    :cond_78
    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    const/16 v1, 0x1f

    if-gt v0, v1, :cond_d4

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mWidth:I

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mHeight:I

    invoke-static {v0, v1}, Ljava/lang/Math;->max(II)I

    move-result v0

    const/16 v1, 0x780

    if-gt v0, v1, :cond_d4

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mWidth:I

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mHeight:I

    invoke-static {v0, v1}, Ljava/lang/Math;->min(II)I

    move-result v0

    const/16 v1, 0x440

    if-gt v0, v1, :cond_d4

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mEndMs:I

    iget v1, p0, Lcom/k4/media/K4SlowMoExport;->mStartMs:I

    if-le v0, v1, :cond_d4

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mFps:I

    int-to-long v0, v0

    const-wide/32 v3, 0xf4240

    div-long/2addr v3, v0

    iput-wide v3, p0, Lcom/k4/media/K4SlowMoExport;->mFrameUs:J
    :try_end_a5
    .catchall {:try_start_9 .. :try_end_a5} :catchall_109

    invoke-virtual {v2}, Landroid/media/MediaExtractor;->release()V

    iget v0, p0, Lcom/k4/media/K4SlowMoExport;->mRate:F

    sget v1, Lcom/k4/media/K4SlowMoExport;->sPlaybackFactor:F

    mul-float/2addr v0, v1

    iput v0, p0, Lcom/k4/media/K4SlowMoExport;->mPlayRate:F

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

    :cond_d4
    :try_start_d4
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

    :cond_101
    new-instance p0, Ljava/lang/IllegalStateException;

    const-string v0, "no video track"

    invoke-direct {p0, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p0
    :try_end_109
    .catchall {:try_start_d4 .. :try_end_109} :catchall_109

    :catchall_109
    move-exception v0

    move-object p0, v0

    invoke-virtual {v2}, Landroid/media/MediaExtractor;->release()V

    throw p0
.end method
