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

.field private static final REFETCH_DELAY_MS:J = 0x3e8L

.field private static final REGISTER_DELAY_MS:J = 0x190L

.field private static final SETTING_LOCATION:Ljava/lang/String; = "clock_weather_location_exist"

.field private static final SETTING_TEMPERATURE:Ljava/lang/String; = "clock_weather_temperature"

.field private static sHost:Lcom/k4/homeclock/AodHost;

.field private static sMain:Landroid/os/Handler;


# instance fields
.field final aod:Landroid/content/Context;

.field private final hostContext:Landroid/content/Context;

.field final loader:Ljava/lang/ClassLoader;

.field private final plugin:Landroid/content/Context;

.field private final provider:Ljava/lang/Object;

.field private final refetch:Ljava/lang/Runnable;

.field private refs:I

.field private final sourceDir:Ljava/lang/String;

.field private weatherEnabled:Z

.field private weatherFailed:Z

.field weatherInfo:Ljava/lang/Object;

.field weatherKey:Ljava/lang/String;

.field private weatherListener:Ljava/lang/Object;

.field private weatherManager:Ljava/lang/Object;

.field private weatherObserver:Landroid/database/ContentObserver;

.field private weatherRegistered:Z

.field private weatherTemperature:Ljava/lang/String;


# direct methods
.method static bridge synthetic -$$Nest$fgetrefetch(Lcom/k4/homeclock/AodHost;)Ljava/lang/Runnable;
    .registers 1

    iget-object p0, p0, Lcom/k4/homeclock/AodHost;->refetch:Ljava/lang/Runnable;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetrefs(Lcom/k4/homeclock/AodHost;)I
    .registers 1

    iget p0, p0, Lcom/k4/homeclock/AodHost;->refs:I

    return p0
.end method

.method static bridge synthetic -$$Nest$fgetweatherListener(Lcom/k4/homeclock/AodHost;)Ljava/lang/Object;
    .registers 1

    iget-object p0, p0, Lcom/k4/homeclock/AodHost;->weatherListener:Ljava/lang/Object;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetweatherManager(Lcom/k4/homeclock/AodHost;)Ljava/lang/Object;
    .registers 1

    iget-object p0, p0, Lcom/k4/homeclock/AodHost;->weatherManager:Ljava/lang/Object;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fputweatherFailed(Lcom/k4/homeclock/AodHost;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/k4/homeclock/AodHost;->weatherFailed:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$fputweatherRegistered(Lcom/k4/homeclock/AodHost;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/k4/homeclock/AodHost;->weatherRegistered:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$mdestroy(Lcom/k4/homeclock/AodHost;)V
    .registers 1

    invoke-direct {p0}, Lcom/k4/homeclock/AodHost;->destroy()V

    return-void
.end method

.method static bridge synthetic -$$Nest$monWeather(Lcom/k4/homeclock/AodHost;Ljava/lang/Object;)V
    .registers 2

    invoke-direct {p0, p1}, Lcom/k4/homeclock/AodHost;->onWeather(Ljava/lang/Object;)V

    return-void
.end method

.method static bridge synthetic -$$Nest$mrefetchWeather(Lcom/k4/homeclock/AodHost;Ljava/lang/String;)V
    .registers 2

    invoke-direct {p0, p1}, Lcom/k4/homeclock/AodHost;->refetchWeather(Ljava/lang/String;)V

    return-void
.end method

.method static bridge synthetic -$$Nest$mstopWeather(Lcom/k4/homeclock/AodHost;)V
    .registers 1

    invoke-direct {p0}, Lcom/k4/homeclock/AodHost;->stopWeather()V

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

.method static bridge synthetic -$$Nest$smmain()Landroid/os/Handler;
    .registers 1

    invoke-static {}, Lcom/k4/homeclock/AodHost;->main()Landroid/os/Handler;

    move-result-object v0

    return-object v0
.end method

.method static constructor <clinit>()V
    .registers 1

    .line 50
    new-instance v0, Lcom/k4/homeclock/AodHost$1;

    invoke-direct {v0}, Lcom/k4/homeclock/AodHost$1;-><init>()V

    sput-object v0, Lcom/k4/homeclock/AodHost;->DESTROY:Ljava/lang/Runnable;

    return-void
.end method

.method private constructor <init>(Landroid/content/Context;)V
    .registers 9
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 134
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 81
    const-string v0, ""

    iput-object v0, p0, Lcom/k4/homeclock/AodHost;->weatherKey:Ljava/lang/String;

    .line 83
    iput-object v0, p0, Lcom/k4/homeclock/AodHost;->weatherTemperature:Ljava/lang/String;

    .line 84
    new-instance v0, Lcom/k4/homeclock/AodHost$2;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/AodHost$2;-><init>(Lcom/k4/homeclock/AodHost;)V

    iput-object v0, p0, Lcom/k4/homeclock/AodHost;->refetch:Ljava/lang/Runnable;

    .line 135
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v0

    .line 136
    const/4 v2, 0x3

    const-string v3, "com.samsung.android.app.aodservice"

    invoke-virtual {p1, v3, v2}, Landroid/content/Context;->createPackageContext(Ljava/lang/String;I)Landroid/content/Context;

    move-result-object v2

    iput-object v2, p0, Lcom/k4/homeclock/AodHost;->aod:Landroid/content/Context;

    .line 137
    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->aod:Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v2

    iput-object v2, p0, Lcom/k4/homeclock/AodHost;->loader:Ljava/lang/ClassLoader;

    .line 138
    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->aod:Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v2

    iget-object v2, v2, Landroid/content/pm/ApplicationInfo;->sourceDir:Ljava/lang/String;

    iput-object v2, p0, Lcom/k4/homeclock/AodHost;->sourceDir:Ljava/lang/String;

    .line 139
    invoke-virtual {p1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v2

    .line 140
    if-eqz v2, :cond_36

    move-object p1, v2

    :cond_36
    iput-object p1, p0, Lcom/k4/homeclock/AodHost;->hostContext:Landroid/content/Context;

    .line 141
    new-instance p1, Lcom/k4/homeclock/AodHost$PluginContext;

    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->aod:Landroid/content/Context;

    iget-object v4, p0, Lcom/k4/homeclock/AodHost;->loader:Ljava/lang/ClassLoader;

    iget-object v5, p0, Lcom/k4/homeclock/AodHost;->hostContext:Landroid/content/Context;

    invoke-direct {p1, v2, v4, v5}, Lcom/k4/homeclock/AodHost$PluginContext;-><init>(Landroid/content/Context;Ljava/lang/ClassLoader;Landroid/content/Context;)V

    iput-object p1, p0, Lcom/k4/homeclock/AodHost;->plugin:Landroid/content/Context;

    .line 142
    const/4 p1, 0x1

    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->loader:Ljava/lang/ClassLoader;

    const-string v4, "com.samsung.android.uniform.plugins.UfClockProvider"

    invoke-static {v4, p1, v2}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object p1

    .line 143
    const/4 v2, 0x0

    new-array v4, v2, [Ljava/lang/Class;

    invoke-virtual {p1, v4}, Ljava/lang/Class;->getDeclaredConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v4

    new-array v5, v2, [Ljava/lang/Object;

    invoke-virtual {v4, v5}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    iput-object v4, p0, Lcom/k4/homeclock/AodHost;->provider:Ljava/lang/Object;

    .line 144
    const-class v4, Landroid/content/Context;

    const-class v5, Landroid/content/Context;

    filled-new-array {v4, v5}, [Ljava/lang/Class;

    move-result-object v4

    const-string v5, "onCreate"

    invoke-virtual {p1, v5, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p1

    iget-object v4, p0, Lcom/k4/homeclock/AodHost;->provider:Ljava/lang/Object;

    iget-object v5, p0, Lcom/k4/homeclock/AodHost;->hostContext:Landroid/content/Context;

    iget-object v6, p0, Lcom/k4/homeclock/AodHost;->plugin:Landroid/content/Context;

    filled-new-array {v5, v6}, [Ljava/lang/Object;

    move-result-object v5

    invoke-virtual {p1, v4, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 145
    iget-object p1, p0, Lcom/k4/homeclock/AodHost;->sourceDir:Ljava/lang/String;

    iget-object v4, p0, Lcom/k4/homeclock/AodHost;->aod:Landroid/content/Context;

    .line 146
    invoke-virtual {v4}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v4

    invoke-virtual {v4, v3, v2}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    move-result-object v2

    iget-object v2, v2, Landroid/content/pm/PackageInfo;->versionName:Ljava/lang/String;

    .line 147
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

    .line 145
    const-string v0, "K4HomeClock"

    invoke-static {v0, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 148
    return-void
.end method

.method static acquire(Landroid/content/Context;)Lcom/k4/homeclock/AodHost;
    .registers 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 151
    invoke-static {}, Landroid/os/Looper;->myLooper()Landroid/os/Looper;

    move-result-object v0

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    if-ne v0, v1, :cond_3f

    .line 154
    invoke-static {}, Lcom/k4/homeclock/AodHost;->main()Landroid/os/Handler;

    move-result-object v0

    sget-object v1, Lcom/k4/homeclock/AodHost;->DESTROY:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 155
    sget-object v0, Lcom/k4/homeclock/AodHost;->sHost:Lcom/k4/homeclock/AodHost;

    .line 156
    if-eqz v0, :cond_2f

    invoke-direct {v0, p0}, Lcom/k4/homeclock/AodHost;->current(Landroid/content/Context;)Z

    move-result v1

    if-nez v1, :cond_2f

    .line 157
    const-string v1, "K4HomeClock"

    const-string v2, "AOD clock plugin: AODService was updated, reloading"

    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 158
    const/4 v1, 0x0

    sput-object v1, Lcom/k4/homeclock/AodHost;->sHost:Lcom/k4/homeclock/AodHost;

    .line 159
    iget v2, v0, Lcom/k4/homeclock/AodHost;->refs:I

    if-nez v2, :cond_2e

    .line 160
    invoke-direct {v0}, Lcom/k4/homeclock/AodHost;->destroy()V

    .line 162
    :cond_2e
    move-object v0, v1

    .line 164
    :cond_2f
    if-nez v0, :cond_38

    .line 165
    new-instance v0, Lcom/k4/homeclock/AodHost;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/AodHost;-><init>(Landroid/content/Context;)V

    .line 166
    sput-object v0, Lcom/k4/homeclock/AodHost;->sHost:Lcom/k4/homeclock/AodHost;

    .line 168
    :cond_38
    iget p0, v0, Lcom/k4/homeclock/AodHost;->refs:I

    add-int/lit8 p0, p0, 0x1

    iput p0, v0, Lcom/k4/homeclock/AodHost;->refs:I

    .line 169
    return-object v0

    .line 152
    :cond_3f
    new-instance p0, Ljava/lang/IllegalStateException;

    const-string v0, "AOD clock: not on the main thread"

    invoke-direct {p0, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method private current(Landroid/content/Context;)Z
    .registers 5

    .line 195
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

    .line 196
    :catchall_14
    move-exception p1

    .line 197
    return v0
.end method

.method private destroy()V
    .registers 6

    .line 392
    const-string v0, "K4HomeClock"

    invoke-direct {p0}, Lcom/k4/homeclock/AodHost;->stopWeather()V

    .line 394
    :try_start_5
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

    .line 395
    const-string v1, "AOD clock plugin destroyed"

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_20
    .catchall {:try_start_5 .. :try_end_20} :catchall_21

    .line 398
    goto :goto_27

    .line 396
    :catchall_21
    move-exception v1

    .line 397
    const-string v2, "AOD clock plugin onDestroy"

    invoke-static {v0, v2, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 399
    :goto_27
    return-void
.end method

.method private static declared-synchronized main()Landroid/os/Handler;
    .registers 3

    const-class v0, Lcom/k4/homeclock/AodHost;

    monitor-enter v0

    .line 173
    :try_start_3
    sget-object v1, Lcom/k4/homeclock/AodHost;->sMain:Landroid/os/Handler;

    if-nez v1, :cond_12

    .line 174
    new-instance v1, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    sput-object v1, Lcom/k4/homeclock/AodHost;->sMain:Landroid/os/Handler;

    .line 176
    :cond_12
    sget-object v1, Lcom/k4/homeclock/AodHost;->sMain:Landroid/os/Handler;
    :try_end_14
    .catchall {:try_start_3 .. :try_end_14} :catchall_16

    monitor-exit v0

    return-object v1

    .line 172
    :catchall_16
    move-exception v1

    :try_start_17
    monitor-exit v0
    :try_end_18
    .catchall {:try_start_17 .. :try_end_18} :catchall_16

    throw v1
.end method

.method private onWeather(Ljava/lang/Object;)V
    .registers 10

    .line 340
    const-string v0, "|"

    const-string v1, "K4HomeClock"

    if-eqz p1, :cond_102

    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->weatherManager:Ljava/lang/Object;

    if-nez v2, :cond_c

    goto/16 :goto_102

    .line 344
    :cond_c
    :try_start_c
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    .line 345
    sget-object v3, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v4, "isEnabled"

    const/4 v5, 0x0

    new-array v6, v5, [Ljava/lang/Class;

    invoke-virtual {v2, v4, v6}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v4

    new-array v6, v5, [Ljava/lang/Object;

    invoke-virtual {v4, p1, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v3

    .line 346
    const-string v4, "getTemperature"

    new-array v6, v5, [Ljava/lang/Class;

    invoke-virtual {v2, v4, v6}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v4

    new-array v6, v5, [Ljava/lang/Object;

    invoke-virtual {v4, p1, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    .line 347
    const-string v6, "getWeatherIconDrawable"

    new-array v7, v5, [Ljava/lang/Class;

    invoke-virtual {v2, v6, v7}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    new-array v5, v5, [Ljava/lang/Object;

    invoke-virtual {v2, p1, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    .line 348
    instance-of v5, v2, Landroid/graphics/drawable/Drawable;

    if-eqz v5, :cond_4d

    .line 349
    move-object v5, v2

    check-cast v5, Landroid/graphics/drawable/Drawable;

    invoke-virtual {v5}, Landroid/graphics/drawable/Drawable;->getConstantState()Landroid/graphics/drawable/Drawable$ConstantState;

    move-result-object v5

    goto :goto_4e

    :cond_4d
    const/4 v5, 0x0

    .line 350
    :goto_4e
    invoke-static {v4}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v6

    if-nez v2, :cond_57

    const-string v2, "-"

    goto :goto_82

    .line 351
    :cond_57
    nop

    .line 350
    invoke-virtual {v2}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object v7

    .line 351
    if-eqz v5, :cond_63

    move-object v2, v5

    :cond_63
    invoke-static {v2}, Ljava/lang/System;->identityHashCode(Ljava/lang/Object;)I

    move-result v2

    invoke-static {v2}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    move-result-object v2

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v7, "@"

    invoke-virtual {v5, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    :goto_82
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 352
    iput-object p1, p0, Lcom/k4/homeclock/AodHost;->weatherInfo:Ljava/lang/Object;

    .line 353
    iput-boolean v3, p0, Lcom/k4/homeclock/AodHost;->weatherEnabled:Z

    .line 354
    if-nez v4, :cond_a8

    const-string v2, ""

    goto :goto_ac

    :cond_a8
    invoke-virtual {v4}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v2

    :goto_ac
    iput-object v2, p0, Lcom/k4/homeclock/AodHost;->weatherTemperature:Ljava/lang/String;

    .line 355
    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->weatherKey:Ljava/lang/String;

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_d7

    .line 356
    invoke-static {p1}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "AOD clock weather: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 357
    iput-object v0, p0, Lcom/k4/homeclock/AodHost;->weatherKey:Ljava/lang/String;

    .line 358
    const-string v0, "weather"

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->redrawStale(Ljava/lang/String;)V
    :try_end_d7
    .catchall {:try_start_c .. :try_end_d7} :catchall_d8

    .line 362
    :cond_d7
    goto :goto_101

    .line 360
    :catchall_d8
    move-exception v0

    .line 361
    invoke-static {p1}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "AOD clock weather: unreadable "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v2, ": "

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 363
    :goto_101
    return-void

    .line 341
    :cond_102
    :goto_102
    return-void
.end method

.method private refetchWeather(Ljava/lang/String;)V
    .registers 8

    .line 314
    iget-object v0, p0, Lcom/k4/homeclock/AodHost;->weatherManager:Ljava/lang/Object;

    if-eqz v0, :cond_8f

    iget-boolean v0, p0, Lcom/k4/homeclock/AodHost;->weatherRegistered:Z

    if-nez v0, :cond_a

    goto/16 :goto_8f

    .line 317
    :cond_a
    iget-object v0, p0, Lcom/k4/homeclock/AodHost;->hostContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    .line 318
    const-string v1, "clock_weather_temperature"

    invoke-static {v0, v1}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 319
    const-string v2, "clock_weather_location_exist"

    const/4 v3, 0x0

    invoke-static {v0, v2, v3}, Landroid/provider/Settings$System;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    move-result v0

    .line 320
    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->weatherInfo:Ljava/lang/Object;

    const/4 v4, 0x1

    if-eqz v2, :cond_3a

    if-eqz v0, :cond_26

    move v2, v4

    goto :goto_27

    :cond_26
    move v2, v3

    :goto_27
    iget-boolean v5, p0, Lcom/k4/homeclock/AodHost;->weatherEnabled:Z

    if-ne v2, v5, :cond_3a

    if-nez v1, :cond_30

    const-string v2, ""

    goto :goto_31

    :cond_30
    move-object v2, v1

    :goto_31
    iget-object v5, p0, Lcom/k4/homeclock/AodHost;->weatherTemperature:Ljava/lang/String;

    invoke-virtual {v2, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_3a

    .line 321
    return-void

    .line 323
    :cond_3a
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "AOD clock weather: "

    invoke-virtual {v2, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v2, " ("

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v1, ", location "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v0, "), fetching"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string v0, "K4HomeClock"

    invoke-static {v0, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 325
    :try_start_6c
    invoke-direct {p0, v3}, Lcom/k4/homeclock/AodHost;->resume(Z)V

    .line 326
    invoke-direct {p0, v4}, Lcom/k4/homeclock/AodHost;->resume(Z)V
    :try_end_72
    .catchall {:try_start_6c .. :try_end_72} :catchall_73

    .line 329
    goto :goto_8e

    .line 327
    :catchall_73
    move-exception p1

    .line 328
    invoke-static {p1}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "AOD clock weather: fetch failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v0, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 330
    :goto_8e
    return-void

    .line 315
    :cond_8f
    :goto_8f
    return-void
.end method

.method private resume(Z)V
    .registers 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 334
    const-string v0, "com.samsung.android.clockpack.plugins.Plugin"

    invoke-virtual {p0, v0}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    const-class v1, Ljava/lang/Boolean;

    filled-new-array {v1}, [Ljava/lang/Class;

    move-result-object v1

    const-string v2, "onResume"

    invoke-virtual {v0, v2, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    iget-object v1, p0, Lcom/k4/homeclock/AodHost;->provider:Ljava/lang/Object;

    .line 335
    invoke-static {p1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p1

    filled-new-array {p1}, [Ljava/lang/Object;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 336
    return-void
.end method

.method private stopWeather()V
    .registers 6

    .line 366
    invoke-static {}, Lcom/k4/homeclock/AodHost;->main()Landroid/os/Handler;

    move-result-object v0

    iget-object v1, p0, Lcom/k4/homeclock/AodHost;->refetch:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 367
    iget-object v0, p0, Lcom/k4/homeclock/AodHost;->weatherObserver:Landroid/database/ContentObserver;

    .line 368
    const/4 v1, 0x0

    iput-object v1, p0, Lcom/k4/homeclock/AodHost;->weatherObserver:Landroid/database/ContentObserver;

    .line 369
    if-eqz v0, :cond_1b

    .line 371
    :try_start_10
    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->hostContext:Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    invoke-virtual {v2, v0}, Landroid/content/ContentResolver;->unregisterContentObserver(Landroid/database/ContentObserver;)V
    :try_end_19
    .catchall {:try_start_10 .. :try_end_19} :catchall_1a

    .line 373
    goto :goto_1b

    .line 372
    :catchall_1a
    move-exception v0

    .line 375
    :cond_1b
    :goto_1b
    iget-object v0, p0, Lcom/k4/homeclock/AodHost;->weatherManager:Ljava/lang/Object;

    .line 376
    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->weatherListener:Ljava/lang/Object;

    .line 377
    iget-boolean v3, p0, Lcom/k4/homeclock/AodHost;->weatherRegistered:Z

    .line 378
    iput-object v1, p0, Lcom/k4/homeclock/AodHost;->weatherManager:Ljava/lang/Object;

    .line 379
    iput-object v1, p0, Lcom/k4/homeclock/AodHost;->weatherListener:Ljava/lang/Object;

    .line 380
    const/4 v1, 0x0

    iput-boolean v1, p0, Lcom/k4/homeclock/AodHost;->weatherRegistered:Z

    .line 381
    if-eqz v0, :cond_69

    if-eqz v2, :cond_69

    if-eqz v3, :cond_69

    .line 383
    :try_start_2e
    const-string v1, "com.samsung.android.clockpack.plugins.clock.IWeatherManager"

    invoke-virtual {p0, v1}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    const-string v3, "unregisterListener"

    const-string v4, "com.samsung.android.clockpack.plugins.clock.IWeatherManager$Listener"

    invoke-virtual {p0, v4}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v4

    filled-new-array {v4}, [Ljava/lang/Class;

    move-result-object v4

    invoke-virtual {v1, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    .line 384
    invoke-virtual {v1, v0, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_4b
    .catchall {:try_start_2e .. :try_end_4b} :catchall_4c

    .line 387
    goto :goto_69

    .line 385
    :catchall_4c
    move-exception v0

    .line 386
    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "AOD clock weather: unregisterListener: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "K4HomeClock"

    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 389
    :cond_69
    :goto_69
    return-void
.end method


# virtual methods
.method clockView(I)Landroid/view/View;
    .registers 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 203
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

    .line 204
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    const/4 v3, 0x2

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    filled-new-array {v2, v3}, [Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    .line 205
    instance-of v1, v0, Landroid/view/View;

    if-eqz v1, :cond_2e

    .line 208
    check-cast v0, Landroid/view/View;

    return-object v0

    .line 206
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

    .line 212
    const/4 v0, 0x0

    iget-object v1, p0, Lcom/k4/homeclock/AodHost;->loader:Ljava/lang/ClassLoader;

    invoke-static {p1, v0, v1}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object p1

    return-object p1
.end method

.method release()V
    .registers 5

    .line 180
    iget v0, p0, Lcom/k4/homeclock/AodHost;->refs:I

    if-lez v0, :cond_a

    .line 181
    iget v0, p0, Lcom/k4/homeclock/AodHost;->refs:I

    add-int/lit8 v0, v0, -0x1

    iput v0, p0, Lcom/k4/homeclock/AodHost;->refs:I

    .line 183
    :cond_a
    iget v0, p0, Lcom/k4/homeclock/AodHost;->refs:I

    if-nez v0, :cond_2a

    .line 184
    sget-object v0, Lcom/k4/homeclock/AodHost;->sHost:Lcom/k4/homeclock/AodHost;

    if-ne v0, p0, :cond_27

    .line 185
    invoke-static {}, Lcom/k4/homeclock/AodHost;->main()Landroid/os/Handler;

    move-result-object v0

    sget-object v1, Lcom/k4/homeclock/AodHost;->DESTROY:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 186
    invoke-static {}, Lcom/k4/homeclock/AodHost;->main()Landroid/os/Handler;

    move-result-object v0

    sget-object v1, Lcom/k4/homeclock/AodHost;->DESTROY:Ljava/lang/Runnable;

    const-wide/16 v2, 0x1388

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    goto :goto_2a

    .line 188
    :cond_27
    invoke-direct {p0}, Lcom/k4/homeclock/AodHost;->destroy()V

    .line 191
    :cond_2a
    :goto_2a
    return-void
.end method

.method startWeather()V
    .registers 9

    .line 231
    const-string v0, "K4HomeClock"

    iget-object v1, p0, Lcom/k4/homeclock/AodHost;->weatherManager:Ljava/lang/Object;

    if-nez v1, :cond_9e

    iget-boolean v1, p0, Lcom/k4/homeclock/AodHost;->weatherFailed:Z

    if-eqz v1, :cond_c

    goto/16 :goto_9e

    .line 235
    :cond_c
    const/4 v1, 0x1

    :try_start_d
    const-string v2, "com.samsung.android.clockpack.plugins.clock.ClockProvider"

    invoke-virtual {p0, v2}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v2

    const-string v3, "getWeatherManager"

    const/4 v4, 0x0

    new-array v5, v4, [Ljava/lang/Class;

    invoke-virtual {v2, v3, v5}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    iget-object v3, p0, Lcom/k4/homeclock/AodHost;->provider:Ljava/lang/Object;

    new-array v5, v4, [Ljava/lang/Object;

    invoke-virtual {v2, v3, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    .line 236
    if-eqz v2, :cond_7c

    .line 239
    const-string v3, "com.samsung.android.clockpack.plugins.clock.IWeatherManager$Listener"

    invoke-virtual {p0, v3}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v3

    .line 240
    iget-object v5, p0, Lcom/k4/homeclock/AodHost;->loader:Ljava/lang/ClassLoader;

    filled-new-array {v3}, [Ljava/lang/Class;

    move-result-object v6

    new-instance v7, Lcom/k4/homeclock/AodHost$3;

    invoke-direct {v7, p0}, Lcom/k4/homeclock/AodHost$3;-><init>(Lcom/k4/homeclock/AodHost;)V

    invoke-static {v5, v6, v7}, Ljava/lang/reflect/Proxy;->newProxyInstance(Ljava/lang/ClassLoader;[Ljava/lang/Class;Ljava/lang/reflect/InvocationHandler;)Ljava/lang/Object;

    move-result-object v5

    .line 271
    invoke-direct {p0, v4}, Lcom/k4/homeclock/AodHost;->resume(Z)V

    .line 272
    invoke-direct {p0, v1}, Lcom/k4/homeclock/AodHost;->resume(Z)V

    .line 273
    iput-object v2, p0, Lcom/k4/homeclock/AodHost;->weatherManager:Ljava/lang/Object;

    .line 274
    iput-object v5, p0, Lcom/k4/homeclock/AodHost;->weatherListener:Ljava/lang/Object;

    .line 275
    invoke-static {}, Lcom/k4/homeclock/AodHost;->main()Landroid/os/Handler;

    move-result-object v6

    new-instance v7, Lcom/k4/homeclock/AodHost$4;

    invoke-direct {v7, p0, v2, v5, v3}, Lcom/k4/homeclock/AodHost$4;-><init>(Lcom/k4/homeclock/AodHost;Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Class;)V

    const-wide/16 v2, 0x190

    invoke-virtual {v6, v7, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    .line 292
    new-instance v2, Lcom/k4/homeclock/AodHost$5;

    invoke-static {}, Lcom/k4/homeclock/AodHost;->main()Landroid/os/Handler;

    move-result-object v3

    invoke-direct {v2, p0, v3}, Lcom/k4/homeclock/AodHost$5;-><init>(Lcom/k4/homeclock/AodHost;Landroid/os/Handler;)V

    .line 299
    iget-object v3, p0, Lcom/k4/homeclock/AodHost;->hostContext:Landroid/content/Context;

    invoke-virtual {v3}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v3

    .line 300
    const-string v5, "clock_weather_temperature"

    invoke-static {v5}, Landroid/provider/Settings$System;->getUriFor(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v5

    invoke-virtual {v3, v5, v4, v2}, Landroid/content/ContentResolver;->registerContentObserver(Landroid/net/Uri;ZLandroid/database/ContentObserver;)V

    .line 301
    const-string v5, "clock_weather_location_exist"

    invoke-static {v5}, Landroid/provider/Settings$System;->getUriFor(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v5

    invoke-virtual {v3, v5, v4, v2}, Landroid/content/ContentResolver;->registerContentObserver(Landroid/net/Uri;ZLandroid/database/ContentObserver;)V

    .line 302
    iput-object v2, p0, Lcom/k4/homeclock/AodHost;->weatherObserver:Landroid/database/ContentObserver;

    .line 303
    const-string v2, "AOD clock weather: listening to the plugin\'s weather manager"

    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 309
    goto :goto_9d

    .line 237
    :cond_7c
    new-instance v2, Ljava/lang/IllegalStateException;

    const-string v3, "no weather manager"

    invoke-direct {v2, v3}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v2
    :try_end_84
    .catchall {:try_start_d .. :try_end_84} :catchall_84

    .line 304
    :catchall_84
    move-exception v2

    .line 305
    instance-of v3, v2, Ljava/lang/reflect/InvocationTargetException;

    if-eqz v3, :cond_93

    invoke-virtual {v2}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v3

    if-eqz v3, :cond_93

    invoke-virtual {v2}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v2

    .line 306
    :cond_93
    const-string v3, "AOD clock weather unavailable, date line without weather"

    invoke-static {v0, v3, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 307
    iput-boolean v1, p0, Lcom/k4/homeclock/AodHost;->weatherFailed:Z

    .line 308
    invoke-direct {p0}, Lcom/k4/homeclock/AodHost;->stopWeather()V

    .line 310
    :goto_9d
    return-void

    .line 232
    :cond_9e
    :goto_9e
    return-void
.end method

.method supportsWeather(I)Z
    .registers 7

    .line 218
    :try_start_0
    const-string v0, "com.samsung.android.clockpack.plugins.Category"

    invoke-virtual {p0, v0}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    .line 219
    const-string v1, "LOCK_SCREEN"

    invoke-virtual {v0, v1}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    .line 220
    const-string v2, "com.samsung.android.clockpack.plugins.clock.ClockProvider"

    invoke-virtual {p0, v2}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v2

    const-string v3, "isSupportWeatherInfo"

    sget-object v4, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v0, v4}, [Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v2, v3, v0}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    iget-object v2, p0, Lcom/k4/homeclock/AodHost;->provider:Ljava/lang/Object;

    .line 221
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    filled-new-array {v1, p1}, [Ljava/lang/Object;

    move-result-object p1

    invoke-virtual {v0, v2, p1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    .line 222
    sget-object v0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-virtual {v0, p1}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result p1
    :try_end_37
    .catchall {:try_start_0 .. :try_end_37} :catchall_38

    return p1

    .line 223
    :catchall_38
    move-exception p1

    .line 224
    invoke-static {p1}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "AOD clock: isSupportWeatherInfo failed: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string v0, "K4HomeClock"

    invoke-static {v0, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 225
    const/4 p1, 0x0

    return p1
.end method
