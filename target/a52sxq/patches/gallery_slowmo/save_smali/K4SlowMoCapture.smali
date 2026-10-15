.class public final Lcom/k4/media/K4SlowMoCapture;
.super Ljava/lang/Object;

# interfaces
.implements Lcom/k4/media/K4SlowMoExport$Listener;
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/k4/media/K4SlowMoCapture$FakeCapture;,
        Lcom/k4/media/K4SlowMoCapture$FakeWrapper;
    }
.end annotation


# static fields
.field private static final blacklist MSG_RECORDING_COMPLETED:I = 0x7

.field private static final blacklist PARAM_CAPTURE_TYPE:I = 0x3f4

.field private static final blacklist SERVICE:Ljava/lang/String; = "vendor.samsung.hardware.media.mpp.ISehMppStore/k4front"

.field private static final blacklist TAG:Ljava/lang/String; = "K4SlowMo"

.field private static final blacklist TYPE_INSTANT_SLOW_MO_CLIP:I = 0x59

.field private static final blacklist sStates:Ljava/util/WeakHashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/WeakHashMap<",
            "Ljava/lang/Object;",
            "Lcom/k4/media/K4SlowMoCapture;",
            ">;"
        }
    .end annotation
.end field

.field private static blacklist sTest:Z


# instance fields
.field private blacklist mCancelled:Z

.field private blacklist mCapture:Ljava/lang/Object;

.field private blacklist mDvCount:I

.field private blacklist mDvEnd:I

.field private blacklist mDvRate:F

.field private blacklist mDvStart:I

.field private blacklist mEnd:I

.field private blacklist mExport:Lcom/k4/media/K4SlowMoExport;

.field private blacklist mFinished:Z

.field private blacklist mIn:Ljava/io/FileDescriptor;

.field private blacklist mInLength:J

.field private blacklist mInOffset:J

.field private blacklist mOurs:Z

.field private blacklist mOut:Ljava/io/FileDescriptor;

.field private blacklist mStart:I

.field private blacklist mType:I


# direct methods
.method static constructor blacklist <clinit>()V
    .registers 1

    new-instance v0, Ljava/util/WeakHashMap;

    invoke-direct {v0}, Ljava/util/WeakHashMap;-><init>()V

    sput-object v0, Lcom/k4/media/K4SlowMoCapture;->sStates:Ljava/util/WeakHashMap;

    return-void
.end method

.method private constructor blacklist <init>()V
    .registers 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, -0x1

    iput v0, p0, Lcom/k4/media/K4SlowMoCapture;->mStart:I

    iput v0, p0, Lcom/k4/media/K4SlowMoCapture;->mEnd:I

    iput v0, p0, Lcom/k4/media/K4SlowMoCapture;->mType:I

    return-void
.end method

.method private blacklist clearOutput()V
    .registers 4

    :try_start_0
    iget-object v0, p0, Lcom/k4/media/K4SlowMoCapture;->mOut:Ljava/io/FileDescriptor;

    const-wide/16 v1, 0x0

    invoke-static {v0, v1, v2}, Landroid/system/Os;->ftruncate(Ljava/io/FileDescriptor;J)V

    iget-object p0, p0, Lcom/k4/media/K4SlowMoCapture;->mOut:Ljava/io/FileDescriptor;

    sget v0, Landroid/system/OsConstants;->SEEK_SET:I

    invoke-static {p0, v1, v2, v0}, Landroid/system/Os;->lseek(Ljava/io/FileDescriptor;JI)J
    :try_end_e
    .catchall {:try_start_0 .. :try_end_e} :catchall_f

    return-void

    :catchall_f
    move-exception p0

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "save: output not cleared: "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string v0, "K4SlowMo"

    invoke-static {v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

.method public static blacklist dynamicViewing(Ljava/lang/Object;Ljava/util/List;)V
    .registers 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Object;",
            "Ljava/util/List<",
            "*>;)V"
        }
    .end annotation

    const/4 v0, 0x1

    :try_start_1
    invoke-static {p0, v0}, Lcom/k4/media/K4SlowMoCapture;->of(Ljava/lang/Object;Z)Lcom/k4/media/K4SlowMoCapture;

    move-result-object v1

    const/4 v2, 0x0

    if-nez p1, :cond_a

    move v3, v2

    goto :goto_e

    :cond_a
    invoke-interface {p1}, Ljava/util/List;->size()I

    move-result v3

    :goto_e
    iput v3, v1, Lcom/k4/media/K4SlowMoCapture;->mDvCount:I

    if-ne v3, v0, :cond_59

    invoke-interface {p1, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    const-string v3, "getStartTime"

    const/4 v4, 0x0

    invoke-virtual {v2, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v3

    invoke-virtual {v3, p1, v4}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/Integer;

    invoke-virtual {v3}, Ljava/lang/Integer;->intValue()I

    move-result v3

    iput v3, v1, Lcom/k4/media/K4SlowMoCapture;->mDvStart:I

    const-string v3, "getEndTime"

    invoke-virtual {v2, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v3

    invoke-virtual {v3, p1, v4}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/Integer;

    invoke-virtual {v3}, Ljava/lang/Integer;->intValue()I

    move-result v3

    iput v3, v1, Lcom/k4/media/K4SlowMoCapture;->mDvEnd:I

    const-string v3, "getSpeedRate"

    invoke-virtual {v2, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    invoke-virtual {v2, p1, v4}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Float;

    invoke-virtual {p1}, Ljava/lang/Float;->floatValue()F

    move-result p1

    iput p1, v1, Lcom/k4/media/K4SlowMoCapture;->mDvRate:F
    :try_end_51
    .catchall {:try_start_1 .. :try_end_51} :catchall_52

    return-void

    :catchall_52
    :try_start_52
    invoke-static {p0, v0}, Lcom/k4/media/K4SlowMoCapture;->of(Ljava/lang/Object;Z)Lcom/k4/media/K4SlowMoCapture;

    move-result-object p0

    const/4 p1, -0x1

    iput p1, p0, Lcom/k4/media/K4SlowMoCapture;->mDvCount:I
    :try_end_59
    .catchall {:try_start_52 .. :try_end_59} :catchall_59

    :catchall_59
    :cond_59
    return-void
.end method

.method private static blacklist handler(Ljava/lang/Object;)Landroid/os/Handler;
    .registers 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    const-string v1, "mEventHandler"

    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    invoke-virtual {v0, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/os/Handler;

    return-object p0
.end method

.method private static blacklist intProp(Ljava/lang/String;I)I
    .registers 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-string v0, "android.os.SystemProperties"

    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    const-class v1, Ljava/lang/String;

    sget-object v2, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v1, v2}, [Ljava/lang/Class;

    move-result-object v1

    const-string v2, "getInt"

    invoke-virtual {v0, v2, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    filled-new-array {p0, p1}, [Ljava/lang/Object;

    move-result-object p0

    const/4 p1, 0x0

    invoke-virtual {v0, p1, p0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Integer;

    invoke-virtual {p0}, Ljava/lang/Integer;->intValue()I

    move-result p0

    return p0
.end method

.method public static blacklist main([Ljava/lang/String;)V
    .registers 11
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    invoke-static {}, Landroid/os/Looper;->prepareMainLooper()V

    const/4 v0, 0x1

    sput-boolean v0, Lcom/k4/media/K4SlowMoCapture;->sTest:Z

    new-instance v5, Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    invoke-direct {v5}, Lcom/k4/media/K4SlowMoCapture$FakeCapture;-><init>()V

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v3

    new-instance v6, Ljava/io/FileOutputStream;

    aget-object v1, p0, v0

    invoke-direct {v6, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/lang/String;)V

    new-instance v1, Lcom/k4/media/K4SlowMoCapture$1;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v2

    invoke-direct/range {v1 .. v6}, Lcom/k4/media/K4SlowMoCapture$1;-><init>(Landroid/os/Looper;JLcom/k4/media/K4SlowMoCapture$FakeCapture;Ljava/io/FileOutputStream;)V

    iput-object v1, v5, Lcom/k4/media/K4SlowMoCapture$FakeCapture;->mEventHandler:Landroid/os/Handler;

    const/4 v1, 0x2

    aget-object v2, p0, v1

    invoke-static {v2}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v2

    const/4 v3, 0x3

    aget-object v3, p0, v3

    invoke-static {v3}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v3

    array-length v4, p0

    const/4 v7, 0x0

    const/4 v8, 0x4

    if-le v4, v8, :cond_3f

    aget-object v4, p0, v8

    const-string v9, "fail"

    invoke-virtual {v4, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_3f

    goto :goto_40

    :cond_3f
    move v0, v7

    :goto_40
    new-instance v4, Ljava/io/FileInputStream;

    aget-object v9, p0, v7

    invoke-direct {v4, v9}, Ljava/io/FileInputStream;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4}, Ljava/io/FileInputStream;->getFD()Ljava/io/FileDescriptor;

    move-result-object v4

    invoke-static {v5, v4}, Lcom/k4/media/K4SlowMoCapture;->source(Ljava/lang/Object;Ljava/io/FileDescriptor;)V

    invoke-virtual {v6}, Ljava/io/FileOutputStream;->getFD()Ljava/io/FileDescriptor;

    move-result-object v4

    invoke-static {v5, v4}, Lcom/k4/media/K4SlowMoCapture;->output(Ljava/lang/Object;Ljava/io/FileDescriptor;)V

    const/16 v4, 0x3f3

    invoke-static {v5, v4, v1}, Lcom/k4/media/K4SlowMoCapture;->parameter(Ljava/lang/Object;II)V

    const/16 v1, 0x3f4

    const/16 v4, 0x59

    invoke-static {v5, v1, v4}, Lcom/k4/media/K4SlowMoCapture;->parameter(Ljava/lang/Object;II)V

    invoke-static {v5, v2, v3}, Lcom/k4/media/K4SlowMoCapture;->startEnd(Ljava/lang/Object;II)V

    const-string v1, "com.samsung.android.media.mediacapture.SemMediaCapture$DynamicViewingConfiguration"

    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    const-string v4, "com.samsung.android.media.mediacapture.SemMediaCapture"

    invoke-static {v4}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v4

    const/4 v9, 0x0

    invoke-virtual {v4, v9}, Ljava/lang/Class;->getDeclaredConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v4

    invoke-virtual {v4, v9}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    new-instance v9, Ljava/util/ArrayList;

    invoke-direct {v9}, Ljava/util/ArrayList;-><init>()V

    invoke-virtual {v1}, Ljava/lang/Class;->getDeclaredConstructors()[Ljava/lang/reflect/Constructor;

    move-result-object v1

    aget-object v1, v1, v7

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    const/high16 v7, 0x3e800000    # 0.25f

    invoke-static {v7}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v7

    filled-new-array {v4, v2, v3, v7}, [Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v9, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    invoke-static {v5, v9}, Lcom/k4/media/K4SlowMoCapture;->dynamicViewing(Ljava/lang/Object;Ljava/util/List;)V

    if-eqz v0, :cond_a5

    invoke-virtual {v6}, Ljava/io/FileOutputStream;->close()V

    :cond_a5
    sget-object v1, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "K4G startCapture -> "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-static {v5}, Lcom/k4/media/K4SlowMoCapture;->startCapture(Ljava/lang/Object;)Z

    move-result v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    const-string v3, ", ours "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {v5}, Lcom/k4/media/K4SlowMoCapture;->ours(Ljava/lang/Object;)Z

    move-result v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    array-length v1, p0

    if-le v1, v8, :cond_de

    if-nez v0, :cond_de

    iget-object v0, v5, Lcom/k4/media/K4SlowMoCapture$FakeCapture;->mEventHandler:Landroid/os/Handler;

    new-instance v1, Lcom/k4/media/K4SlowMoCapture$2;

    invoke-direct {v1, v5, v6}, Lcom/k4/media/K4SlowMoCapture$2;-><init>(Lcom/k4/media/K4SlowMoCapture$FakeCapture;Ljava/io/FileOutputStream;)V

    aget-object p0, p0, v8

    invoke-static {p0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p0

    int-to-long v2, p0

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :cond_de
    new-instance p0, Ljava/lang/Thread;

    new-instance v0, Lcom/k4/media/K4SlowMoCapture$3;

    invoke-direct {v0, v5}, Lcom/k4/media/K4SlowMoCapture$3;-><init>(Lcom/k4/media/K4SlowMoCapture$FakeCapture;)V

    invoke-direct {p0, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    invoke-virtual {p0}, Ljava/lang/Thread;->start()V

    iget-object p0, v5, Lcom/k4/media/K4SlowMoCapture$FakeCapture;->mEventHandler:Landroid/os/Handler;

    new-instance v0, Lcom/k4/media/K4SlowMoCapture$4;

    invoke-direct {v0}, Lcom/k4/media/K4SlowMoCapture$4;-><init>()V

    const-wide/32 v1, 0xea60

    invoke-virtual {p0, v0, v1, v2}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    invoke-static {}, Landroid/os/Looper;->loop()V

    return-void
.end method

.method private static blacklist of(Ljava/lang/Object;Z)Lcom/k4/media/K4SlowMoCapture;
    .registers 4

    sget-object v0, Lcom/k4/media/K4SlowMoCapture;->sStates:Ljava/util/WeakHashMap;

    monitor-enter v0

    :try_start_3
    invoke-virtual {v0, p0}, Ljava/util/WeakHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/k4/media/K4SlowMoCapture;

    if-nez v1, :cond_15

    if-eqz p1, :cond_15

    new-instance v1, Lcom/k4/media/K4SlowMoCapture;

    invoke-direct {v1}, Lcom/k4/media/K4SlowMoCapture;-><init>()V

    invoke-virtual {v0, p0, v1}, Ljava/util/WeakHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_15
    monitor-exit v0

    return-object v1

    :catchall_17
    move-exception p0

    monitor-exit v0
    :try_end_19
    .catchall {:try_start_3 .. :try_end_19} :catchall_17

    throw p0
.end method

.method public static blacklist ours(Ljava/lang/Object;)Z
    .registers 2

    const/4 v0, 0x0

    :try_start_1
    invoke-static {p0, v0}, Lcom/k4/media/K4SlowMoCapture;->of(Ljava/lang/Object;Z)Lcom/k4/media/K4SlowMoCapture;

    move-result-object p0

    if-eqz p0, :cond_d

    iget-boolean p0, p0, Lcom/k4/media/K4SlowMoCapture;->mOurs:Z
    :try_end_9
    .catchall {:try_start_1 .. :try_end_9} :catchall_d

    if-eqz p0, :cond_d

    const/4 p0, 0x1

    return p0

    :catchall_d
    :cond_d
    return v0
.end method

.method public static blacklist output(Ljava/lang/Object;Ljava/io/FileDescriptor;)V
    .registers 3

    const/4 v0, 0x1

    :try_start_1
    invoke-static {p0, v0}, Lcom/k4/media/K4SlowMoCapture;->of(Ljava/lang/Object;Z)Lcom/k4/media/K4SlowMoCapture;

    move-result-object p0

    iput-object p1, p0, Lcom/k4/media/K4SlowMoCapture;->mOut:Ljava/io/FileDescriptor;
    :try_end_7
    .catchall {:try_start_1 .. :try_end_7} :catchall_7

    :catchall_7
    return-void
.end method

.method public static blacklist parameter(Ljava/lang/Object;II)V
    .registers 4

    const/16 v0, 0x3f4

    if-ne p1, v0, :cond_b

    const/4 p1, 0x1

    :try_start_5
    invoke-static {p0, p1}, Lcom/k4/media/K4SlowMoCapture;->of(Ljava/lang/Object;Z)Lcom/k4/media/K4SlowMoCapture;

    move-result-object p0

    iput p2, p0, Lcom/k4/media/K4SlowMoCapture;->mType:I
    :try_end_b
    .catchall {:try_start_5 .. :try_end_b} :catchall_b

    :catchall_b
    :cond_b
    return-void
.end method

.method public static blacklist progress(Ljava/lang/Object;)F
    .registers 3

    const/4 v0, 0x0

    const/high16 v1, -0x40800000    # -1.0f

    :try_start_3
    invoke-static {p0, v0}, Lcom/k4/media/K4SlowMoCapture;->of(Ljava/lang/Object;Z)Lcom/k4/media/K4SlowMoCapture;

    move-result-object p0

    if-eqz p0, :cond_1f

    iget-boolean v0, p0, Lcom/k4/media/K4SlowMoCapture;->mOurs:Z

    if-nez v0, :cond_e

    goto :goto_1f

    :cond_e
    iget-object v0, p0, Lcom/k4/media/K4SlowMoCapture;->mExport:Lcom/k4/media/K4SlowMoExport;

    iget-boolean p0, p0, Lcom/k4/media/K4SlowMoCapture;->mFinished:Z

    if-nez p0, :cond_1c

    if-nez v0, :cond_17

    goto :goto_1c

    :cond_17
    invoke-virtual {v0}, Lcom/k4/media/K4SlowMoExport;->getProgress()F

    move-result p0
    :try_end_1b
    .catchall {:try_start_3 .. :try_end_1b} :catchall_1f

    return p0

    :cond_1c
    :goto_1c
    const/high16 p0, 0x3f800000    # 1.0f

    return p0

    :catchall_1f
    :cond_1f
    :goto_1f
    return v1
.end method

.method private blacklist refusal()Ljava/lang/String;
    .registers 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    sget-boolean v0, Lcom/k4/media/K4SlowMoCapture;->sTest:Z

    if-nez v0, :cond_f

    const-string v0, "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AIFRC"

    invoke-static {v0}, Lcom/k4/media/K4SlowMo;->featureBoolean(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_f

    const-string p0, "not Gallery"

    return-object p0

    :cond_f
    const-string v0, "persist.sys.k4.slowmo_neural"

    const/4 v1, 0x1

    invoke-static {v0, v1}, Lcom/k4/media/K4SlowMoCapture;->intProp(Ljava/lang/String;I)I

    move-result v0

    if-nez v0, :cond_1b

    const-string p0, "persist.sys.k4.slowmo_neural is off"

    return-object p0

    :cond_1b
    iget v0, p0, Lcom/k4/media/K4SlowMoCapture;->mDvCount:I

    if-eq v0, v1, :cond_33

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    iget p0, p0, Lcom/k4/media/K4SlowMoCapture;->mDvCount:I

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p0, " dynamic viewing sections"

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    :goto_2e
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0

    :cond_33
    iget v0, p0, Lcom/k4/media/K4SlowMoCapture;->mType:I

    const/16 v1, 0x59

    if-eq v0, v1, :cond_46

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "capture type "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget p0, p0, Lcom/k4/media/K4SlowMoCapture;->mType:I

    :goto_42
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    goto :goto_2e

    :cond_46
    iget-object v0, p0, Lcom/k4/media/K4SlowMoCapture;->mIn:Ljava/io/FileDescriptor;

    if-eqz v0, :cond_cf

    iget-object v0, p0, Lcom/k4/media/K4SlowMoCapture;->mOut:Ljava/io/FileDescriptor;

    if-nez v0, :cond_50

    goto/16 :goto_cf

    :cond_50
    iget v0, p0, Lcom/k4/media/K4SlowMoCapture;->mDvEnd:I

    iget v1, p0, Lcom/k4/media/K4SlowMoCapture;->mDvStart:I

    if-le v0, v1, :cond_a8

    iget v2, p0, Lcom/k4/media/K4SlowMoCapture;->mStart:I

    if-ne v1, v2, :cond_a8

    iget v1, p0, Lcom/k4/media/K4SlowMoCapture;->mEnd:I

    if-eq v0, v1, :cond_5f

    goto :goto_a8

    :cond_5f
    iget v0, p0, Lcom/k4/media/K4SlowMoCapture;->mDvRate:F

    const/high16 v1, 0x3e800000    # 0.25f

    cmpl-float v1, v0, v1

    if-eqz v1, :cond_7a

    const/high16 v1, 0x3f000000    # 0.5f

    cmpl-float v0, v0, v1

    if-eqz v0, :cond_7a

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "rate "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget p0, p0, Lcom/k4/media/K4SlowMoCapture;->mDvRate:F

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    goto :goto_2e

    :cond_7a
    const-string p0, "android.os.ServiceManager"

    invoke-static {p0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object p0

    const-class v0, Ljava/lang/String;

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    const-string v1, "checkService"

    invoke-virtual {p0, v1, v0}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p0

    const-string v0, "vendor.samsung.hardware.media.mpp.ISehMppStore/k4front"

    filled-new-array {v0}, [Ljava/lang/Object;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {p0, v1, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    if-nez p0, :cond_9c

    const-string p0, "no neural service"

    return-object p0

    :cond_9c
    check-cast p0, Landroid/os/IBinder;

    invoke-static {p0}, Lcom/k4/media/K4SlowMo;->neuralEngineState(Landroid/os/IBinder;)I

    move-result p0

    if-gez p0, :cond_a7

    const-string p0, "neural engine not usable (see the K4Neural log)"

    return-object p0

    :cond_a7
    return-object v1

    :cond_a8
    :goto_a8
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "section "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget v1, p0, Lcom/k4/media/K4SlowMoCapture;->mDvStart:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, ".."

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v2, p0, Lcom/k4/media/K4SlowMoCapture;->mDvEnd:I

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " of "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v2, p0, Lcom/k4/media/K4SlowMoCapture;->mStart:I

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget p0, p0, Lcom/k4/media/K4SlowMoCapture;->mEnd:I

    goto/16 :goto_42

    :cond_cf
    :goto_cf
    const-string p0, "no file descriptors"

    return-object p0
.end method

.method public static blacklist release(Ljava/lang/Object;)V
    .registers 2

    :try_start_0
    invoke-static {p0}, Lcom/k4/media/K4SlowMoCapture;->stopCapture(Ljava/lang/Object;)Z

    sget-object v0, Lcom/k4/media/K4SlowMoCapture;->sStates:Ljava/util/WeakHashMap;

    monitor-enter v0
    :try_end_6
    .catchall {:try_start_0 .. :try_end_6} :catchall_e

    :try_start_6
    invoke-virtual {v0, p0}, Ljava/util/WeakHashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    monitor-exit v0

    return-void

    :catchall_b
    move-exception p0

    monitor-exit v0
    :try_end_d
    .catchall {:try_start_6 .. :try_end_d} :catchall_b

    :try_start_d
    throw p0
    :try_end_e
    .catchall {:try_start_d .. :try_end_e} :catchall_e

    :catchall_e
    return-void
.end method

.method public static blacklist source(Ljava/lang/Object;Ljava/io/FileDescriptor;)V
    .registers 8

    const-wide/16 v2, 0x0

    const-wide v4, 0x7ffffffffffffffL

    move-object v0, p0

    move-object v1, p1

    invoke-static/range {v0 .. v5}, Lcom/k4/media/K4SlowMoCapture;->source(Ljava/lang/Object;Ljava/io/FileDescriptor;JJ)V

    return-void
.end method

.method public static blacklist source(Ljava/lang/Object;Ljava/io/FileDescriptor;JJ)V
    .registers 7

    const/4 v0, 0x1

    :try_start_1
    invoke-static {p0, v0}, Lcom/k4/media/K4SlowMoCapture;->of(Ljava/lang/Object;Z)Lcom/k4/media/K4SlowMoCapture;

    move-result-object p0

    iput-object p1, p0, Lcom/k4/media/K4SlowMoCapture;->mIn:Ljava/io/FileDescriptor;

    iput-wide p2, p0, Lcom/k4/media/K4SlowMoCapture;->mInOffset:J

    iput-wide p4, p0, Lcom/k4/media/K4SlowMoCapture;->mInLength:J
    :try_end_b
    .catchall {:try_start_1 .. :try_end_b} :catchall_b

    :catchall_b
    return-void
.end method

.method public static blacklist startCapture(Ljava/lang/Object;)Z
    .registers 20

    move-object/from16 v0, p0

    const-string v1, ")"

    const-string v2, "K4SlowMo"

    const-string v3, "save: neural export of "

    const-string v4, "save: stock path ("

    const/4 v5, 0x0

    const/4 v6, 0x0

    :try_start_c
    invoke-static {v0, v5}, Lcom/k4/media/K4SlowMoCapture;->of(Ljava/lang/Object;Z)Lcom/k4/media/K4SlowMoCapture;

    move-result-object v7
    :try_end_10
    .catchall {:try_start_c .. :try_end_10} :catchall_b3

    if-nez v7, :cond_13

    return v5

    :cond_13
    :try_start_13
    iget-boolean v8, v7, Lcom/k4/media/K4SlowMoCapture;->mOurs:Z

    const/4 v9, 0x1

    if-eqz v8, :cond_1d

    iget-boolean v8, v7, Lcom/k4/media/K4SlowMoCapture;->mFinished:Z

    if-nez v8, :cond_1d

    return v9

    :cond_1d
    iput-boolean v5, v7, Lcom/k4/media/K4SlowMoCapture;->mOurs:Z

    iput-object v6, v7, Lcom/k4/media/K4SlowMoCapture;->mExport:Lcom/k4/media/K4SlowMoExport;

    invoke-direct {v7}, Lcom/k4/media/K4SlowMoCapture;->refusal()Ljava/lang/String;

    move-result-object v8

    if-eqz v8, :cond_3e

    iget v0, v7, Lcom/k4/media/K4SlowMoCapture;->mDvCount:I

    if-lez v0, :cond_3d

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :cond_3d
    return v5

    :cond_3e
    iput-object v0, v7, Lcom/k4/media/K4SlowMoCapture;->mCapture:Ljava/lang/Object;

    iput-boolean v5, v7, Lcom/k4/media/K4SlowMoCapture;->mFinished:Z

    iput-boolean v5, v7, Lcom/k4/media/K4SlowMoCapture;->mCancelled:Z

    const-string v0, "persist.sys.k4.slowmo_save_film"

    invoke-static {v0, v9}, Lcom/k4/media/K4SlowMoCapture;->intProp(Ljava/lang/String;I)I

    move-result v0

    if-eqz v0, :cond_4f

    move/from16 v18, v9

    goto :goto_51

    :cond_4f
    move/from16 v18, v5

    :goto_51
    new-instance v0, Lcom/k4/media/K4SlowMoExport;

    iget-object v8, v7, Lcom/k4/media/K4SlowMoCapture;->mIn:Ljava/io/FileDescriptor;

    move v4, v9

    iget-wide v9, v7, Lcom/k4/media/K4SlowMoCapture;->mInOffset:J

    iget-wide v11, v7, Lcom/k4/media/K4SlowMoCapture;->mInLength:J

    iget-object v13, v7, Lcom/k4/media/K4SlowMoCapture;->mOut:Ljava/io/FileDescriptor;

    iget v14, v7, Lcom/k4/media/K4SlowMoCapture;->mDvStart:I

    iget v15, v7, Lcom/k4/media/K4SlowMoCapture;->mDvEnd:I

    iget v4, v7, Lcom/k4/media/K4SlowMoCapture;->mDvRate:F
    :try_end_62
    .catchall {:try_start_13 .. :try_end_62} :catchall_b1

    move/from16 v16, v4

    move-object/from16 v17, v7

    const/4 v4, 0x1

    move-object v7, v0

    :try_start_68
    invoke-direct/range {v7 .. v18}, Lcom/k4/media/K4SlowMoExport;-><init>(Ljava/io/FileDescriptor;JJLjava/io/FileDescriptor;IIFLcom/k4/media/K4SlowMoExport$Listener;Z)V
    :try_end_6b
    .catchall {:try_start_68 .. :try_end_6b} :catchall_ad

    move-object v0, v7

    move-object/from16 v7, v17

    :try_start_6e
    iput-object v0, v7, Lcom/k4/media/K4SlowMoCapture;->mExport:Lcom/k4/media/K4SlowMoExport;

    invoke-virtual {v0}, Lcom/k4/media/K4SlowMoExport;->start()V

    iput-boolean v4, v7, Lcom/k4/media/K4SlowMoCapture;->mOurs:Z

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget v3, v7, Lcom/k4/media/K4SlowMoCapture;->mDvStart:I

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, ".."

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v3, v7, Lcom/k4/media/K4SlowMoCapture;->mDvEnd:I

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, " ms at "

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v3, v7, Lcom/k4/media/K4SlowMoCapture;->mDvRate:F

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    const-string v3, "x started ("

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    if-eqz v18, :cond_9d

    const-string v3, "offline render"

    goto :goto_9f

    :cond_9d
    const-string v3, "real time"

    :goto_9f
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_ac
    .catchall {:try_start_6e .. :try_end_ac} :catchall_b1

    return v4

    :catchall_ad
    move-exception v0

    move-object/from16 v7, v17

    goto :goto_b5

    :catchall_b1
    move-exception v0

    goto :goto_b5

    :catchall_b3
    move-exception v0

    move-object v7, v6

    :goto_b5
    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "save: stock path (neural export did not start: "

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    if-eqz v7, :cond_d1

    iput-boolean v5, v7, Lcom/k4/media/K4SlowMoCapture;->mOurs:Z

    iput-object v6, v7, Lcom/k4/media/K4SlowMoCapture;->mExport:Lcom/k4/media/K4SlowMoExport;

    iput-object v6, v7, Lcom/k4/media/K4SlowMoCapture;->mCapture:Ljava/lang/Object;

    :cond_d1
    return v5
.end method

.method public static blacklist startEnd(Ljava/lang/Object;II)V
    .registers 4

    const/4 v0, 0x1

    :try_start_1
    invoke-static {p0, v0}, Lcom/k4/media/K4SlowMoCapture;->of(Ljava/lang/Object;Z)Lcom/k4/media/K4SlowMoCapture;

    move-result-object p0

    iput p1, p0, Lcom/k4/media/K4SlowMoCapture;->mStart:I

    iput p2, p0, Lcom/k4/media/K4SlowMoCapture;->mEnd:I
    :try_end_9
    .catchall {:try_start_1 .. :try_end_9} :catchall_9

    :catchall_9
    return-void
.end method

.method public static blacklist stopCapture(Ljava/lang/Object;)Z
    .registers 7

    const-string v0, "save: Gallery stopped the capture at "

    const/4 v1, 0x0

    :try_start_3
    invoke-static {p0, v1}, Lcom/k4/media/K4SlowMoCapture;->of(Ljava/lang/Object;Z)Lcom/k4/media/K4SlowMoCapture;

    move-result-object p0

    if-eqz p0, :cond_4e

    iget-boolean v2, p0, Lcom/k4/media/K4SlowMoCapture;->mOurs:Z

    if-nez v2, :cond_e

    goto :goto_4e

    :cond_e
    iget-object v2, p0, Lcom/k4/media/K4SlowMoCapture;->mExport:Lcom/k4/media/K4SlowMoExport;

    iget-boolean v3, p0, Lcom/k4/media/K4SlowMoCapture;->mFinished:Z

    const/4 v4, 0x1

    if-nez v3, :cond_4d

    if-eqz v2, :cond_4d

    iput-boolean v4, p0, Lcom/k4/media/K4SlowMoCapture;->mCancelled:Z

    invoke-virtual {v2}, Lcom/k4/media/K4SlowMoExport;->cancel()V

    const-string p0, "K4SlowMo"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2}, Lcom/k4/media/K4SlowMoExport;->getProgress()F

    move-result v0

    const/high16 v5, 0x42c80000    # 100.0f

    mul-float/2addr v0, v5

    float-to-int v0, v0

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v0, " % ("

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Lcom/k4/media/K4SlowMoExport;->isOffline()Z

    move-result v0

    if-eqz v0, :cond_3c

    const-string v0, "offline render"

    goto :goto_3e

    :cond_3c
    const-string v0, "real-time recording"

    :goto_3e
    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, "); nothing is saved"

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_4d
    .catchall {:try_start_3 .. :try_end_4d} :catchall_4e

    :cond_4d
    return v4

    :catchall_4e
    :cond_4e
    :goto_4e
    return v1
.end method


# virtual methods
.method public blacklist onFinished(Lcom/k4/media/K4SlowMoExport;ZLjava/lang/String;)V
    .registers 20

    move-object/from16 v10, p0

    move-object/from16 v0, p3

    const-string v12, "real-time path did not start: "

    const-string v1, "save: offline render failed ("

    const-string v13, "save: neural export failed ("

    const-string v2, "save: cancelled ("

    iget-object v14, v10, Lcom/k4/media/K4SlowMoCapture;->mCapture:Ljava/lang/Object;

    const/4 v3, 0x1

    const-string v15, "K4SlowMo"

    if-eqz p2, :cond_24

    :try_start_13
    iput-boolean v3, v10, Lcom/k4/media/K4SlowMoCapture;->mFinished:Z

    invoke-static {v14}, Lcom/k4/media/K4SlowMoCapture;->handler(Ljava/lang/Object;)Landroid/os/Handler;

    move-result-object v0

    if-eqz v0, :cond_c4

    const/4 v1, 0x7

    invoke-virtual {v0, v1}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/os/Handler;->sendMessage(Landroid/os/Message;)Z

    return-void

    :cond_24
    invoke-direct {v10}, Lcom/k4/media/K4SlowMoCapture;->clearOutput()V

    iget-boolean v4, v10, Lcom/k4/media/K4SlowMoCapture;->mCancelled:Z

    if-eqz v4, :cond_42

    iput-boolean v3, v10, Lcom/k4/media/K4SlowMoCapture;->mFinished:Z

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, "), output cleared"

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v15, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    return-void

    :cond_42
    invoke-virtual/range {p1 .. p1}, Lcom/k4/media/K4SlowMoExport;->isOffline()Z

    move-result v2

    if-eqz v2, :cond_8a

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, "), recording the neural playback instead"

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v15, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_5c
    .catchall {:try_start_13 .. :try_end_5c} :catchall_b2

    :try_start_5c
    new-instance v0, Lcom/k4/media/K4SlowMoExport;

    iget-object v1, v10, Lcom/k4/media/K4SlowMoCapture;->mIn:Ljava/io/FileDescriptor;

    iget-wide v2, v10, Lcom/k4/media/K4SlowMoCapture;->mInOffset:J

    iget-wide v4, v10, Lcom/k4/media/K4SlowMoCapture;->mInLength:J

    iget-object v6, v10, Lcom/k4/media/K4SlowMoCapture;->mOut:Ljava/io/FileDescriptor;

    iget v7, v10, Lcom/k4/media/K4SlowMoCapture;->mDvStart:I

    iget v8, v10, Lcom/k4/media/K4SlowMoCapture;->mDvEnd:I

    iget v9, v10, Lcom/k4/media/K4SlowMoCapture;->mDvRate:F

    const/4 v11, 0x0

    invoke-direct/range {v0 .. v11}, Lcom/k4/media/K4SlowMoExport;-><init>(Ljava/io/FileDescriptor;JJLjava/io/FileDescriptor;IIFLcom/k4/media/K4SlowMoExport$Listener;Z)V

    iput-object v0, v10, Lcom/k4/media/K4SlowMoCapture;->mExport:Lcom/k4/media/K4SlowMoExport;

    invoke-virtual {v0}, Lcom/k4/media/K4SlowMoExport;->start()V

    iget-boolean v1, v10, Lcom/k4/media/K4SlowMoCapture;->mCancelled:Z

    if-eqz v1, :cond_c4

    invoke-virtual {v0}, Lcom/k4/media/K4SlowMoExport;->cancel()V
    :try_end_7c
    .catchall {:try_start_5c .. :try_end_7c} :catchall_7d

    return-void

    :catchall_7d
    move-exception v0

    :try_start_7e
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1, v12}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    :cond_8a
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1, v13}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, "), falling back to the stock path"

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v15, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    const/4 v0, 0x0

    iput-boolean v0, v10, Lcom/k4/media/K4SlowMoCapture;->mOurs:Z

    const/4 v0, 0x0

    iput-object v0, v10, Lcom/k4/media/K4SlowMoCapture;->mExport:Lcom/k4/media/K4SlowMoExport;

    invoke-static {v14}, Lcom/k4/media/K4SlowMoCapture;->handler(Ljava/lang/Object;)Landroid/os/Handler;

    move-result-object v0

    if-eqz v0, :cond_ae

    invoke-virtual {v0, v10}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    goto :goto_c4

    :cond_ae
    invoke-virtual {v10}, Lcom/k4/media/K4SlowMoCapture;->run()V
    :try_end_b1
    .catchall {:try_start_7e .. :try_end_b1} :catchall_b2

    goto :goto_c4

    :catchall_b2
    move-exception v0

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "save: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v15, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    :cond_c4
    :goto_c4
    return-void
.end method

.method public blacklist run()V
    .registers 4

    :try_start_0
    iget-object v0, p0, Lcom/k4/media/K4SlowMoCapture;->mCapture:Ljava/lang/Object;

    const/4 v1, 0x0

    iput-object v1, p0, Lcom/k4/media/K4SlowMoCapture;->mCapture:Ljava/lang/Object;

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p0

    const-string v2, "mWrapper"

    invoke-virtual {p0, v2}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object p0

    const/4 v2, 0x1

    invoke-virtual {p0, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    invoke-virtual {p0, v0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    const-string v2, "startCapture"

    invoke-virtual {v0, v2, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    invoke-virtual {v0, p0, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_24
    .catchall {:try_start_0 .. :try_end_24} :catchall_25

    return-void

    :catchall_25
    move-exception p0

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "save: stock path did not start: "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string v0, "K4SlowMo"

    invoke-static {v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method
