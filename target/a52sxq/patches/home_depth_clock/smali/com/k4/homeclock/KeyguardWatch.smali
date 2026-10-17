.class final Lcom/k4/homeclock/KeyguardWatch;
.super Ljava/lang/Object;
.source "KeyguardWatch.java"


# static fields
.field private static installed:Z

.field static volatile locked:Z


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 14
    const/4 v0, 0x1

    sput-boolean v0, Lcom/k4/homeclock/KeyguardWatch;->locked:Z

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 17
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static declared-synchronized ensure(Landroid/content/Context;)V
    .registers 5

    const-class v0, Lcom/k4/homeclock/KeyguardWatch;

    monitor-enter v0

    .line 20
    :try_start_3
    sget-boolean v1, Lcom/k4/homeclock/KeyguardWatch;->installed:Z
    :try_end_5
    .catchall {:try_start_3 .. :try_end_5} :catchall_4a

    if-eqz v1, :cond_9

    .line 21
    monitor-exit v0

    return-void

    .line 23
    :cond_9
    :try_start_9
    const-class v1, Landroid/app/KeyguardManager;

    invoke-virtual {p0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/app/KeyguardManager;
    :try_end_11
    .catchall {:try_start_9 .. :try_end_11} :catchall_4a

    .line 24
    if-nez v1, :cond_15

    .line 25
    monitor-exit v0

    return-void

    .line 27
    :cond_15
    :try_start_15
    invoke-virtual {v1}, Landroid/app/KeyguardManager;->isKeyguardLocked()Z

    move-result v2

    sput-boolean v2, Lcom/k4/homeclock/KeyguardWatch;->locked:Z

    .line 28
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p0

    invoke-virtual {p0}, Landroid/content/Context;->getMainExecutor()Ljava/util/concurrent/Executor;

    move-result-object p0

    new-instance v2, Lcom/k4/homeclock/KeyguardWatch$1;

    invoke-direct {v2}, Lcom/k4/homeclock/KeyguardWatch$1;-><init>()V

    invoke-virtual {v1, p0, v2}, Landroid/app/KeyguardManager;->addKeyguardLockedStateListener(Ljava/util/concurrent/Executor;Landroid/app/KeyguardManager$KeyguardLockedStateListener;)V

    .line 38
    const/4 p0, 0x1

    sput-boolean p0, Lcom/k4/homeclock/KeyguardWatch;->installed:Z

    .line 39
    const-string p0, "K4HomeClock"

    sget-boolean v1, Lcom/k4/homeclock/KeyguardWatch;->locked:Z

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "keyguard watch installed, locked="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {p0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_48
    .catchall {:try_start_15 .. :try_end_48} :catchall_4a

    .line 40
    monitor-exit v0

    return-void

    .line 19
    :catchall_4a
    move-exception p0

    :try_start_4b
    monitor-exit v0
    :try_end_4c
    .catchall {:try_start_4b .. :try_end_4c} :catchall_4a

    throw p0
.end method
