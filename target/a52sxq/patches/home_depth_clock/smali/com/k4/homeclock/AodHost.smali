.class final Lcom/k4/homeclock/AodHost;
.super Ljava/lang/Object;
.source "AodHost.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/k4/homeclock/AodHost$PluginContext;
    }
.end annotation


# static fields
.field static final AOD:Ljava/lang/String; = "com.samsung.android.app.aodservice"

.field private static final CATEGORY_LOCK_SCREEN:I = 0x2

.field static final CP:Ljava/lang/String; = "com.samsung.android.clockpack.plugins.clock."

.field private static final DESTROY:Ljava/lang/Runnable;

.field private static final DESTROY_DELAY_MS:J = 0x1388L

.field private static final PROVIDER:Ljava/lang/String; = "com.samsung.android.uniform.plugins.UfClockProvider"

.field private static sHost:Lcom/k4/homeclock/AodHost;

.field private static sMain:Landroid/os/Handler;


# instance fields
.field final aod:Landroid/content/Context;

.field final loader:Ljava/lang/ClassLoader;

.field private final plugin:Landroid/content/Context;

.field private final provider:Ljava/lang/Object;

.field private refs:I

.field private final sourceDir:Ljava/lang/String;


# direct methods
.method static bridge synthetic -$$Nest$fgetrefs(Lcom/k4/homeclock/AodHost;)I
    .registers 1

    iget p0, p0, Lcom/k4/homeclock/AodHost;->refs:I

    return p0
.end method

.method static bridge synthetic -$$Nest$mdestroy(Lcom/k4/homeclock/AodHost;)V
    .registers 1

    invoke-direct {p0}, Lcom/k4/homeclock/AodHost;->destroy()V

    return-void
.end method

.method static bridge synthetic -$$Nest$sfgetsHost()Lcom/k4/homeclock/AodHost;
    .registers 1

    sget-object v0, Lcom/k4/homeclock/AodHost;->sHost:Lcom/k4/homeclock/AodHost;

    return-object v0
.end method

.method static bridge synthetic -$$Nest$sfputsHost(Lcom/k4/homeclock/AodHost;)V
    .registers 1

    sput-object p0, Lcom/k4/homeclock/AodHost;->sHost:Lcom/k4/homeclock/AodHost;

    return-void
.end method

.method static constructor <clinit>()V
    .registers 1

    .line 33
    new-instance v0, Lcom/k4/homeclock/AodHost$1;

    invoke-direct {v0}, Lcom/k4/homeclock/AodHost$1;-><init>()V

    sput-object v0, Lcom/k4/homeclock/AodHost;->DESTROY:Ljava/lang/Runnable;

    return-void
.end method

.method private constructor <init>(Landroid/content/Context;)V
    .registers 10
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 83
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 84
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v0

    .line 85
    const/4 v2, 0x3

    const-string v3, "com.samsung.android.app.aodservice"

    invoke-virtual {p1, v3, v2}, Landroid/content/Context;->createPackageContext(Ljava/lang/String;I)Landroid/content/Context;

    move-result-object v2

    iput-object v2, p0, Lcom/k4/homeclock/AodHost;->aod:Landroid/content/Context;

    .line 86
    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->aod:Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v2

    iput-object v2, p0, Lcom/k4/homeclock/AodHost;->loader:Ljava/lang/ClassLoader;

    .line 87
    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->aod:Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v2

    iget-object v2, v2, Landroid/content/pm/ApplicationInfo;->sourceDir:Ljava/lang/String;

    iput-object v2, p0, Lcom/k4/homeclock/AodHost;->sourceDir:Ljava/lang/String;

    .line 88
    new-instance v2, Lcom/k4/homeclock/AodHost$PluginContext;

    iget-object v4, p0, Lcom/k4/homeclock/AodHost;->aod:Landroid/content/Context;

    iget-object v5, p0, Lcom/k4/homeclock/AodHost;->loader:Ljava/lang/ClassLoader;

    invoke-direct {v2, v4, v5}, Lcom/k4/homeclock/AodHost$PluginContext;-><init>(Landroid/content/Context;Ljava/lang/ClassLoader;)V

    iput-object v2, p0, Lcom/k4/homeclock/AodHost;->plugin:Landroid/content/Context;

    .line 89
    const/4 v2, 0x1

    iget-object v4, p0, Lcom/k4/homeclock/AodHost;->loader:Ljava/lang/ClassLoader;

    const-string v5, "com.samsung.android.uniform.plugins.UfClockProvider"

    invoke-static {v5, v2, v4}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v2

    .line 90
    const/4 v4, 0x0

    new-array v5, v4, [Ljava/lang/Class;

    invoke-virtual {v2, v5}, Ljava/lang/Class;->getDeclaredConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v5

    new-array v6, v4, [Ljava/lang/Object;

    invoke-virtual {v5, v6}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    iput-object v5, p0, Lcom/k4/homeclock/AodHost;->provider:Ljava/lang/Object;

    .line 91
    invoke-virtual {p1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v5

    .line 92
    const-class v6, Landroid/content/Context;

    const-class v7, Landroid/content/Context;

    filled-new-array {v6, v7}, [Ljava/lang/Class;

    move-result-object v6

    const-string v7, "onCreate"

    invoke-virtual {v2, v7, v6}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    iget-object v6, p0, Lcom/k4/homeclock/AodHost;->provider:Ljava/lang/Object;

    if-eqz v5, :cond_5c

    move-object p1, v5

    :cond_5c
    iget-object v5, p0, Lcom/k4/homeclock/AodHost;->plugin:Landroid/content/Context;

    filled-new-array {p1, v5}, [Ljava/lang/Object;

    move-result-object p1

    invoke-virtual {v2, v6, p1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 93
    iget-object p1, p0, Lcom/k4/homeclock/AodHost;->sourceDir:Ljava/lang/String;

    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->aod:Landroid/content/Context;

    .line 94
    invoke-virtual {v2}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v2

    invoke-virtual {v2, v3, v4}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    move-result-object v2

    iget-object v2, v2, Landroid/content/pm/PackageInfo;->versionName:Ljava/lang/String;

    .line 95
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v3

    sub-long/2addr v3, v0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "AOD clock plugin loaded from "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v0, " ("

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v0, "), "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v3, v4}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v0, " ms"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 93
    const-string v0, "K4HomeClock"

    invoke-static {v0, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 96
    return-void
.end method

.method static acquire(Landroid/content/Context;)Lcom/k4/homeclock/AodHost;
    .registers 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 99
    invoke-static {}, Landroid/os/Looper;->myLooper()Landroid/os/Looper;

    move-result-object v0

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    if-ne v0, v1, :cond_3f

    .line 102
    invoke-static {}, Lcom/k4/homeclock/AodHost;->main()Landroid/os/Handler;

    move-result-object v0

    sget-object v1, Lcom/k4/homeclock/AodHost;->DESTROY:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 103
    sget-object v0, Lcom/k4/homeclock/AodHost;->sHost:Lcom/k4/homeclock/AodHost;

    .line 104
    if-eqz v0, :cond_2f

    invoke-direct {v0, p0}, Lcom/k4/homeclock/AodHost;->current(Landroid/content/Context;)Z

    move-result v1

    if-nez v1, :cond_2f

    .line 105
    const-string v1, "K4HomeClock"

    const-string v2, "AOD clock plugin: AODService was updated, reloading"

    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 106
    const/4 v1, 0x0

    sput-object v1, Lcom/k4/homeclock/AodHost;->sHost:Lcom/k4/homeclock/AodHost;

    .line 107
    iget v2, v0, Lcom/k4/homeclock/AodHost;->refs:I

    if-nez v2, :cond_2e

    .line 108
    invoke-direct {v0}, Lcom/k4/homeclock/AodHost;->destroy()V

    .line 110
    :cond_2e
    move-object v0, v1

    .line 112
    :cond_2f
    if-nez v0, :cond_38

    .line 113
    new-instance v0, Lcom/k4/homeclock/AodHost;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/AodHost;-><init>(Landroid/content/Context;)V

    .line 114
    sput-object v0, Lcom/k4/homeclock/AodHost;->sHost:Lcom/k4/homeclock/AodHost;

    .line 116
    :cond_38
    iget p0, v0, Lcom/k4/homeclock/AodHost;->refs:I

    add-int/lit8 p0, p0, 0x1

    iput p0, v0, Lcom/k4/homeclock/AodHost;->refs:I

    .line 117
    return-object v0

    .line 100
    :cond_3f
    new-instance p0, Ljava/lang/IllegalStateException;

    const-string v0, "AOD clock: not on the main thread"

    invoke-direct {p0, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method private current(Landroid/content/Context;)Z
    .registers 5

    .line 143
    const/4 v0, 0x0

    :try_start_1
    iget-object v1, p0, Lcom/k4/homeclock/AodHost;->sourceDir:Ljava/lang/String;

    invoke-virtual {p1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object p1

    const-string v2, "com.samsung.android.app.aodservice"

    invoke-virtual {p1, v2, v0}, Landroid/content/pm/PackageManager;->getApplicationInfo(Ljava/lang/String;I)Landroid/content/pm/ApplicationInfo;

    move-result-object p1

    iget-object p1, p1, Landroid/content/pm/ApplicationInfo;->sourceDir:Ljava/lang/String;

    invoke-virtual {v1, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1
    :try_end_13
    .catchall {:try_start_1 .. :try_end_13} :catchall_14

    return p1

    .line 144
    :catchall_14
    move-exception p1

    .line 145
    return v0
.end method

.method private destroy()V
    .registers 6

    .line 165
    const-string v0, "K4HomeClock"

    :try_start_2
    iget-object v1, p0, Lcom/k4/homeclock/AodHost;->provider:Ljava/lang/Object;

    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    const-string v2, "onDestroy"

    const/4 v3, 0x0

    new-array v4, v3, [Ljava/lang/Class;

    invoke-virtual {v1, v2, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->provider:Ljava/lang/Object;

    new-array v3, v3, [Ljava/lang/Object;

    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 166
    const-string v1, "AOD clock plugin destroyed"

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_1d
    .catchall {:try_start_2 .. :try_end_1d} :catchall_1e

    .line 169
    goto :goto_24

    .line 167
    :catchall_1e
    move-exception v1

    .line 168
    const-string v2, "AOD clock plugin onDestroy"

    invoke-static {v0, v2, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 170
    :goto_24
    return-void
.end method

.method private static declared-synchronized main()Landroid/os/Handler;
    .registers 3

    const-class v0, Lcom/k4/homeclock/AodHost;

    monitor-enter v0

    .line 121
    :try_start_3
    sget-object v1, Lcom/k4/homeclock/AodHost;->sMain:Landroid/os/Handler;

    if-nez v1, :cond_12

    .line 122
    new-instance v1, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    sput-object v1, Lcom/k4/homeclock/AodHost;->sMain:Landroid/os/Handler;

    .line 124
    :cond_12
    sget-object v1, Lcom/k4/homeclock/AodHost;->sMain:Landroid/os/Handler;
    :try_end_14
    .catchall {:try_start_3 .. :try_end_14} :catchall_16

    monitor-exit v0

    return-object v1

    .line 120
    :catchall_16
    move-exception v1

    :try_start_17
    monitor-exit v0
    :try_end_18
    .catchall {:try_start_17 .. :try_end_18} :catchall_16

    throw v1
.end method


# virtual methods
.method clockView(I)Landroid/view/View;
    .registers 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 151
    iget-object v0, p0, Lcom/k4/homeclock/AodHost;->provider:Ljava/lang/Object;

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    sget-object v1, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    sget-object v2, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v1, v2}, [Ljava/lang/Class;

    move-result-object v1

    const-string v2, "getClockView"

    invoke-virtual {v0, v2, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    iget-object v1, p0, Lcom/k4/homeclock/AodHost;->provider:Ljava/lang/Object;

    .line 152
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    const/4 v3, 0x2

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    filled-new-array {v2, v3}, [Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    .line 153
    instance-of v1, v0, Landroid/view/View;

    if-eqz v1, :cond_2e

    .line 156
    check-cast v0, Landroid/view/View;

    return-object v0

    .line 154
    :cond_2e
    new-instance v0, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "AOD clock: no view for clockType "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {v0, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method cls(Ljava/lang/String;)Ljava/lang/Class;
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            ")",
            "Ljava/lang/Class<",
            "*>;"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/ClassNotFoundException;
        }
    .end annotation

    .line 160
    const/4 v0, 0x0

    iget-object v1, p0, Lcom/k4/homeclock/AodHost;->loader:Ljava/lang/ClassLoader;

    invoke-static {p1, v0, v1}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object p1

    return-object p1
.end method

.method release()V
    .registers 5

    .line 128
    iget v0, p0, Lcom/k4/homeclock/AodHost;->refs:I

    if-lez v0, :cond_a

    .line 129
    iget v0, p0, Lcom/k4/homeclock/AodHost;->refs:I

    add-int/lit8 v0, v0, -0x1

    iput v0, p0, Lcom/k4/homeclock/AodHost;->refs:I

    .line 131
    :cond_a
    iget v0, p0, Lcom/k4/homeclock/AodHost;->refs:I

    if-nez v0, :cond_2a

    .line 132
    sget-object v0, Lcom/k4/homeclock/AodHost;->sHost:Lcom/k4/homeclock/AodHost;

    if-ne v0, p0, :cond_27

    .line 133
    invoke-static {}, Lcom/k4/homeclock/AodHost;->main()Landroid/os/Handler;

    move-result-object v0

    sget-object v1, Lcom/k4/homeclock/AodHost;->DESTROY:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 134
    invoke-static {}, Lcom/k4/homeclock/AodHost;->main()Landroid/os/Handler;

    move-result-object v0

    sget-object v1, Lcom/k4/homeclock/AodHost;->DESTROY:Ljava/lang/Runnable;

    const-wide/16 v2, 0x1388

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    goto :goto_2a

    .line 136
    :cond_27
    invoke-direct {p0}, Lcom/k4/homeclock/AodHost;->destroy()V

    .line 139
    :cond_2a
    :goto_2a
    return-void
.end method
