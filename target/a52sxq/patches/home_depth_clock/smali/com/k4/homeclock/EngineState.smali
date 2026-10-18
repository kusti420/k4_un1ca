.class final Lcom/k4/homeclock/EngineState;
.super Ljava/lang/Object;
.source "EngineState.java"


# static fields
.field private static final WALLPAPER_WAIT_MS:J = 0x1770L


# instance fields
.field private final context:Landroid/content/Context;

.field private final engine:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Lf3/a;",
            ">;"
        }
    .end annotation
.end field

.field private final main:Landroid/os/Handler;

.field private final reload:Ljava/lang/Runnable;

.field private reloadAwaitsWallpaper:Z

.field private reloadOn:Z

.field private final reloadReceiver:Landroid/content/BroadcastReceiver;

.field private final tickReceiver:Landroid/content/BroadcastReceiver;

.field private tickerOn:Z

.field private visible:Z


# direct methods
.method static bridge synthetic -$$Nest$fgetengine(Lcom/k4/homeclock/EngineState;)Ljava/lang/ref/WeakReference;
    .registers 1

    iget-object p0, p0, Lcom/k4/homeclock/EngineState;->engine:Ljava/lang/ref/WeakReference;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetmain(Lcom/k4/homeclock/EngineState;)Landroid/os/Handler;
    .registers 1

    iget-object p0, p0, Lcom/k4/homeclock/EngineState;->main:Landroid/os/Handler;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetreload(Lcom/k4/homeclock/EngineState;)Ljava/lang/Runnable;
    .registers 1

    iget-object p0, p0, Lcom/k4/homeclock/EngineState;->reload:Ljava/lang/Runnable;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetreloadAwaitsWallpaper(Lcom/k4/homeclock/EngineState;)Z
    .registers 1

    iget-boolean p0, p0, Lcom/k4/homeclock/EngineState;->reloadAwaitsWallpaper:Z

    return p0
.end method

.method static bridge synthetic -$$Nest$fputreloadAwaitsWallpaper(Lcom/k4/homeclock/EngineState;Z)V
    .registers 2

    iput-boolean p1, p0, Lcom/k4/homeclock/EngineState;->reloadAwaitsWallpaper:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$mretryWeather(Lcom/k4/homeclock/EngineState;Ljava/lang/String;)V
    .registers 2

    invoke-direct {p0, p1}, Lcom/k4/homeclock/EngineState;->retryWeather(Ljava/lang/String;)V

    return-void
.end method

.method constructor <init>(Lf3/a;)V
    .registers 4

    .line 73
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 26
    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lcom/k4/homeclock/EngineState;->main:Landroid/os/Handler;

    .line 31
    new-instance v0, Lcom/k4/homeclock/EngineState$1;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/EngineState$1;-><init>(Lcom/k4/homeclock/EngineState;)V

    iput-object v0, p0, Lcom/k4/homeclock/EngineState;->reload:Ljava/lang/Runnable;

    .line 51
    new-instance v0, Lcom/k4/homeclock/EngineState$2;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/EngineState$2;-><init>(Lcom/k4/homeclock/EngineState;)V

    iput-object v0, p0, Lcom/k4/homeclock/EngineState;->reloadReceiver:Landroid/content/BroadcastReceiver;

    .line 65
    new-instance v0, Lcom/k4/homeclock/EngineState$3;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/EngineState$3;-><init>(Lcom/k4/homeclock/EngineState;)V

    iput-object v0, p0, Lcom/k4/homeclock/EngineState;->tickReceiver:Landroid/content/BroadcastReceiver;

    .line 74
    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, p1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    iput-object v0, p0, Lcom/k4/homeclock/EngineState;->engine:Ljava/lang/ref/WeakReference;

    .line 75
    invoke-virtual {p1}, Lf3/a;->getAppContext()Landroid/content/Context;

    move-result-object p1

    invoke-virtual {p1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p1

    iput-object p1, p0, Lcom/k4/homeclock/EngineState;->context:Landroid/content/Context;

    .line 76
    return-void
.end method

.method private retryWeather(Ljava/lang/String;)V
    .registers 4

    .line 126
    :try_start_0
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->engine:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lf3/a;

    .line 127
    if-eqz v0, :cond_14

    iget-boolean v1, p0, Lcom/k4/homeclock/EngineState;->visible:Z

    if-nez v1, :cond_f

    goto :goto_14

    :cond_f
    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->clockOf(Lf3/a;)Lcom/k4/homeclock/DepthClock;

    move-result-object v0

    goto :goto_15

    :cond_14
    :goto_14
    const/4 v0, 0x0

    .line 128
    :goto_15
    if-eqz v0, :cond_1a

    .line 129
    invoke-virtual {v0, p1}, Lcom/k4/homeclock/DepthClock;->retryWeather(Ljava/lang/String;)V
    :try_end_1a
    .catchall {:try_start_0 .. :try_end_1a} :catchall_1b

    .line 133
    :cond_1a
    goto :goto_23

    .line 131
    :catchall_1b
    move-exception p1

    .line 132
    const-string v0, "K4HomeClock"

    const-string v1, "weather retry"

    invoke-static {v0, v1, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 134
    :goto_23
    return-void
.end method

.method private unregister(Landroid/content/BroadcastReceiver;)V
    .registers 3

    .line 161
    :try_start_0
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->context:Landroid/content/Context;

    invoke-virtual {v0, p1}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V
    :try_end_5
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_5} :catch_6

    .line 163
    goto :goto_7

    .line 162
    :catch_6
    move-exception p1

    .line 164
    :goto_7
    return-void
.end method


# virtual methods
.method newEngine()V
    .registers 3

    .line 86
    iget-boolean v0, p0, Lcom/k4/homeclock/EngineState;->reloadAwaitsWallpaper:Z

    if-eqz v0, :cond_1c

    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->main:Landroid/os/Handler;

    iget-object v1, p0, Lcom/k4/homeclock/EngineState;->reload:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->hasCallbacks(Ljava/lang/Runnable;)Z

    move-result v0

    if-eqz v0, :cond_1c

    .line 87
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->main:Landroid/os/Handler;

    iget-object v1, p0, Lcom/k4/homeclock/EngineState;->reload:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 88
    const-string v0, "K4HomeClock"

    const-string v1, "new wallpaper engine: queued reload of the old one dropped"

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 90
    :cond_1c
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/k4/homeclock/EngineState;->reloadAwaitsWallpaper:Z

    .line 91
    return-void
.end method

.method redrawIfStale(Ljava/lang/String;)V
    .registers 3

    .line 137
    const/4 v0, 0x0

    invoke-virtual {p0, p1, v0}, Lcom/k4/homeclock/EngineState;->redrawIfStale(Ljava/lang/String;Z)V

    .line 138
    return-void
.end method

.method redrawIfStale(Ljava/lang/String;Z)V
    .registers 8

    .line 143
    const-string v0, "K4HomeClock"

    :try_start_2
    iget-object v1, p0, Lcom/k4/homeclock/EngineState;->engine:Ljava/lang/ref/WeakReference;

    invoke-virtual {v1}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lf3/a;

    .line 144
    if-nez v1, :cond_e

    const/4 v2, 0x0

    goto :goto_12

    :cond_e
    invoke-static {v1}, Lcom/k4/homeclock/HomeDepthClock;->clockOf(Lf3/a;)Lcom/k4/homeclock/DepthClock;

    move-result-object v2

    .line 145
    :goto_12
    if-eqz v2, :cond_62

    iget-boolean v3, p0, Lcom/k4/homeclock/EngineState;->visible:Z

    if-nez v3, :cond_1b

    if-nez p2, :cond_1b

    goto :goto_62

    .line 148
    :cond_1b
    invoke-virtual {v2}, Lcom/k4/homeclock/DepthClock;->expected()Ljava/lang/String;

    move-result-object p2

    .line 149
    iget-object v3, v2, Lcom/k4/homeclock/DepthClock;->lastDrawn:Ljava/lang/String;

    invoke-virtual {p2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_28

    .line 150
    return-void

    .line 152
    :cond_28
    iget-object v2, v2, Lcom/k4/homeclock/DepthClock;->lastDrawn:Ljava/lang/String;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "redraw ("

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v3, "): \'"

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v2, "\' -> \'"

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p2, "\'"

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v0, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 153
    invoke-virtual {v1}, Lf3/a;->getSurfaceHolder()Landroid/view/SurfaceHolder;

    move-result-object p1

    invoke-virtual {v1, p1}, Lf3/a;->b(Landroid/view/SurfaceHolder;)V
    :try_end_61
    .catchall {:try_start_2 .. :try_end_61} :catchall_63

    .line 156
    goto :goto_69

    .line 146
    :cond_62
    :goto_62
    return-void

    .line 154
    :catchall_63
    move-exception p1

    .line 155
    const-string p2, "redraw"

    invoke-static {v0, p2, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 157
    :goto_69
    return-void
.end method

.method setVisible(Z)V
    .registers 8

    .line 103
    iput-boolean p1, p0, Lcom/k4/homeclock/EngineState;->visible:Z

    .line 104
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->engine:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lf3/a;

    .line 105
    const/4 v1, 0x1

    const/4 v2, 0x0

    if-eqz p1, :cond_18

    if-eqz v0, :cond_18

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->clockOf(Lf3/a;)Lcom/k4/homeclock/DepthClock;

    move-result-object p1

    if-eqz p1, :cond_18

    move p1, v1

    goto :goto_19

    :cond_18
    move p1, v2

    .line 106
    :goto_19
    if-eqz p1, :cond_40

    iget-boolean v0, p0, Lcom/k4/homeclock/EngineState;->tickerOn:Z

    if-nez v0, :cond_40

    .line 107
    new-instance v0, Landroid/content/IntentFilter;

    const-string v3, "android.intent.action.TIME_TICK"

    invoke-direct {v0, v3}, Landroid/content/IntentFilter;-><init>(Ljava/lang/String;)V

    .line 108
    const-string v3, "android.intent.action.TIME_SET"

    invoke-virtual {v0, v3}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 109
    const-string v3, "android.intent.action.TIMEZONE_CHANGED"

    invoke-virtual {v0, v3}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 110
    const-string v3, "android.intent.action.LOCALE_CHANGED"

    invoke-virtual {v0, v3}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 111
    iget-object v3, p0, Lcom/k4/homeclock/EngineState;->context:Landroid/content/Context;

    iget-object v4, p0, Lcom/k4/homeclock/EngineState;->tickReceiver:Landroid/content/BroadcastReceiver;

    const/4 v5, 0x4

    invoke-virtual {v3, v4, v0, v5}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;I)Landroid/content/Intent;

    .line 112
    iput-boolean v1, p0, Lcom/k4/homeclock/EngineState;->tickerOn:Z

    goto :goto_4e

    .line 113
    :cond_40
    if-nez p1, :cond_4e

    iget-boolean v0, p0, Lcom/k4/homeclock/EngineState;->tickerOn:Z

    if-eqz v0, :cond_4e

    .line 114
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->tickReceiver:Landroid/content/BroadcastReceiver;

    invoke-direct {p0, v0}, Lcom/k4/homeclock/EngineState;->unregister(Landroid/content/BroadcastReceiver;)V

    .line 115
    iput-boolean v2, p0, Lcom/k4/homeclock/EngineState;->tickerOn:Z

    goto :goto_4f

    .line 113
    :cond_4e
    :goto_4e
    nop

    .line 117
    :goto_4f
    if-eqz p1, :cond_59

    .line 118
    const-string p1, "visible"

    invoke-virtual {p0, p1, v2}, Lcom/k4/homeclock/EngineState;->redrawIfStale(Ljava/lang/String;Z)V

    .line 119
    invoke-direct {p0, p1}, Lcom/k4/homeclock/EngineState;->retryWeather(Ljava/lang/String;)V

    .line 121
    :cond_59
    return-void
.end method

.method start()V
    .registers 7

    .line 79
    new-instance v2, Landroid/content/IntentFilter;

    const-string v0, "com.k4.homeclock.action.RELOAD"

    invoke-direct {v2, v0}, Landroid/content/IntentFilter;-><init>(Ljava/lang/String;)V

    .line 80
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->context:Landroid/content/Context;

    iget-object v1, p0, Lcom/k4/homeclock/EngineState;->reloadReceiver:Landroid/content/BroadcastReceiver;

    const/4 v4, 0x0

    const/4 v5, 0x2

    const-string v3, "android.permission.WRITE_SECURE_SETTINGS"

    invoke-virtual/range {v0 .. v5}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;Ljava/lang/String;Landroid/os/Handler;I)Landroid/content/Intent;

    .line 81
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/k4/homeclock/EngineState;->reloadOn:Z

    .line 82
    return-void
.end method

.method stop()V
    .registers 3

    .line 94
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->main:Landroid/os/Handler;

    iget-object v1, p0, Lcom/k4/homeclock/EngineState;->reload:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 95
    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Lcom/k4/homeclock/EngineState;->setVisible(Z)V

    .line 96
    iget-boolean v1, p0, Lcom/k4/homeclock/EngineState;->reloadOn:Z

    if-eqz v1, :cond_16

    .line 97
    iget-object v1, p0, Lcom/k4/homeclock/EngineState;->reloadReceiver:Landroid/content/BroadcastReceiver;

    invoke-direct {p0, v1}, Lcom/k4/homeclock/EngineState;->unregister(Landroid/content/BroadcastReceiver;)V

    .line 98
    iput-boolean v0, p0, Lcom/k4/homeclock/EngineState;->reloadOn:Z

    .line 100
    :cond_16
    return-void
.end method
