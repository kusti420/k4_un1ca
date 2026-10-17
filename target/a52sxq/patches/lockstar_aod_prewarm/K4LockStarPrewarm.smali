# patches/lockstar_aod_prewarm (see module.prop). The same class is added to SystemUI and to services.jar.
#
# K4LockStarPrewarm.prewarm(context, who) starts one background thread (at most one at a time) that, if AOD is on
# (Settings.System aod_mode != 0), acquires and immediately releases an unstable ContentProviderClient for Good Lock
# LockStar's LockEditorDataProvider. If the LockStar process is not running, that makes ActivityManager start it now,
# off every UI thread, so it is already up when AODService's BrightnessManager (running inside SystemUI on its main
# thread while the AOD plugin is created) reads aod_brightness_level_main from it a few hundred ms later. Without
# LockStar installed, or before the first unlock, the acquire returns null at once. An unstable client is used so that
# a LockStar crash can never take the caller down with it, and it is closed right away so LockStar is not kept at a
# raised OOM priority.

.class public final Lcom/k4/lockstar/K4LockStarPrewarm;
.super Ljava/lang/Object;
.source "K4LockStarPrewarm.java"

# interfaces
.implements Ljava/lang/Runnable;


# static fields
.field private static volatile sBusy:Z


# instance fields
.field private final mContext:Landroid/content/Context;

.field private final mWho:Ljava/lang/String;


# direct methods
.method private constructor <init>(Landroid/content/Context;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/k4/lockstar/K4LockStarPrewarm;->mContext:Landroid/content/Context;

    iput-object p2, p0, Lcom/k4/lockstar/K4LockStarPrewarm;->mWho:Ljava/lang/String;

    return-void
.end method

.method public static prewarm(Landroid/content/Context;Ljava/lang/String;)V
    .locals 3

    if-eqz p0, :cond_ret

    sget-boolean v0, Lcom/k4/lockstar/K4LockStarPrewarm;->sBusy:Z

    if-nez v0, :cond_ret

    const/4 v0, 0x1

    sput-boolean v0, Lcom/k4/lockstar/K4LockStarPrewarm;->sBusy:Z

    :try_start_0
    new-instance v0, Lcom/k4/lockstar/K4LockStarPrewarm;

    invoke-direct {v0, p0, p1}, Lcom/k4/lockstar/K4LockStarPrewarm;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    new-instance v1, Ljava/lang/Thread;

    const-string v2, "k4-lockstar-prewarm"

    invoke-direct {v1, v0, v2}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/lang/Thread;->start()V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    :cond_ret
    return-void

    :catch_0
    const/4 v0, 0x0

    sput-boolean v0, Lcom/k4/lockstar/K4LockStarPrewarm;->sBusy:Z

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 6

    :try_start_0
    iget-object v0, p0, Lcom/k4/lockstar/K4LockStarPrewarm;->mContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    const-string v1, "aod_mode"

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Landroid/provider/Settings$System;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    move-result v1

    if-eqz v1, :cond_done

    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v2

    const-string v1, "com.samsung.systemui.lockstar.data.provider.LockEditorDataProvider"

    invoke-virtual {v0, v1}, Landroid/content/ContentResolver;->acquireUnstableContentProviderClient(Ljava/lang/String;)Landroid/content/ContentProviderClient;

    move-result-object v0

    if-eqz v0, :cond_done

    invoke-virtual {v0}, Landroid/content/ContentProviderClient;->close()V

    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v4

    sub-long/2addr v4, v2

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "lockstar provider ready in "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, v4, v5}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string v1, " ms ("

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lcom/k4/lockstar/K4LockStarPrewarm;->mWho:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ")"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "K4LockStarPrewarm"

    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    :cond_done
    const/4 v0, 0x0

    sput-boolean v0, Lcom/k4/lockstar/K4LockStarPrewarm;->sBusy:Z

    return-void

    :catch_0
    goto :cond_done
.end method
