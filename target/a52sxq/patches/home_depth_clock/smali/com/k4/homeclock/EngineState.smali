.class final Lcom/k4/homeclock/EngineState;
.super Ljava/lang/Object;
.source "EngineState.java"


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

.method constructor <init>(Lf3/a;)V
    .registers 4

    .line 62
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 25
    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lcom/k4/homeclock/EngineState;->main:Landroid/os/Handler;

    .line 30
    new-instance v0, Lcom/k4/homeclock/EngineState$1;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/EngineState$1;-><init>(Lcom/k4/homeclock/EngineState;)V

    iput-object v0, p0, Lcom/k4/homeclock/EngineState;->reload:Ljava/lang/Runnable;

    .line 47
    new-instance v0, Lcom/k4/homeclock/EngineState$2;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/EngineState$2;-><init>(Lcom/k4/homeclock/EngineState;)V

    iput-object v0, p0, Lcom/k4/homeclock/EngineState;->reloadReceiver:Landroid/content/BroadcastReceiver;

    .line 55
    new-instance v0, Lcom/k4/homeclock/EngineState$3;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/EngineState$3;-><init>(Lcom/k4/homeclock/EngineState;)V

    iput-object v0, p0, Lcom/k4/homeclock/EngineState;->tickReceiver:Landroid/content/BroadcastReceiver;

    .line 63
    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, p1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    iput-object v0, p0, Lcom/k4/homeclock/EngineState;->engine:Ljava/lang/ref/WeakReference;

    .line 64
    invoke-virtual {p1}, Lf3/a;->getAppContext()Landroid/content/Context;

    move-result-object p1

    invoke-virtual {p1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p1

    iput-object p1, p0, Lcom/k4/homeclock/EngineState;->context:Landroid/content/Context;

    .line 65
    return-void
.end method

.method private unregister(Landroid/content/BroadcastReceiver;)V
    .registers 3

    .line 127
    :try_start_0
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->context:Landroid/content/Context;

    invoke-virtual {v0, p1}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V
    :try_end_5
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_5} :catch_6

    .line 129
    goto :goto_7

    .line 128
    :catch_6
    move-exception p1

    .line 130
    :goto_7
    return-void
.end method


# virtual methods
.method redrawIfStale(Ljava/lang/String;)V
    .registers 3

    .line 103
    const/4 v0, 0x0

    invoke-virtual {p0, p1, v0}, Lcom/k4/homeclock/EngineState;->redrawIfStale(Ljava/lang/String;Z)V

    .line 104
    return-void
.end method

.method redrawIfStale(Ljava/lang/String;Z)V
    .registers 8

    .line 109
    const-string v0, "K4HomeClock"

    :try_start_2
    iget-object v1, p0, Lcom/k4/homeclock/EngineState;->engine:Ljava/lang/ref/WeakReference;

    invoke-virtual {v1}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lf3/a;

    .line 110
    if-nez v1, :cond_e

    const/4 v2, 0x0

    goto :goto_12

    :cond_e
    invoke-static {v1}, Lcom/k4/homeclock/HomeDepthClock;->clockOf(Lf3/a;)Lcom/k4/homeclock/ClockNode;

    move-result-object v2

    .line 111
    :goto_12
    if-eqz v2, :cond_62

    iget-boolean v3, p0, Lcom/k4/homeclock/EngineState;->visible:Z

    if-nez v3, :cond_1b

    if-nez p2, :cond_1b

    goto :goto_62

    .line 114
    :cond_1b
    invoke-virtual {v2}, Lcom/k4/homeclock/ClockNode;->expected()Ljava/lang/String;

    move-result-object p2

    .line 115
    iget-object v3, v2, Lcom/k4/homeclock/ClockNode;->lastDrawn:Ljava/lang/String;

    invoke-virtual {p2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_28

    .line 116
    return-void

    .line 118
    :cond_28
    iget-object v2, v2, Lcom/k4/homeclock/ClockNode;->lastDrawn:Ljava/lang/String;

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

    .line 119
    invoke-virtual {v1}, Lf3/a;->getSurfaceHolder()Landroid/view/SurfaceHolder;

    move-result-object p1

    invoke-virtual {v1, p1}, Lf3/a;->b(Landroid/view/SurfaceHolder;)V
    :try_end_61
    .catchall {:try_start_2 .. :try_end_61} :catchall_63

    .line 122
    goto :goto_69

    .line 112
    :cond_62
    :goto_62
    return-void

    .line 120
    :catchall_63
    move-exception p1

    .line 121
    const-string p2, "redraw"

    invoke-static {v0, p2, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 123
    :goto_69
    return-void
.end method

.method setVisible(Z)V
    .registers 8

    .line 83
    iput-boolean p1, p0, Lcom/k4/homeclock/EngineState;->visible:Z

    .line 84
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->engine:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lf3/a;

    .line 85
    const/4 v1, 0x1

    const/4 v2, 0x0

    if-eqz p1, :cond_18

    if-eqz v0, :cond_18

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->clockOf(Lf3/a;)Lcom/k4/homeclock/ClockNode;

    move-result-object p1

    if-eqz p1, :cond_18

    move p1, v1

    goto :goto_19

    :cond_18
    move p1, v2

    .line 86
    :goto_19
    if-eqz p1, :cond_40

    iget-boolean v0, p0, Lcom/k4/homeclock/EngineState;->tickerOn:Z

    if-nez v0, :cond_40

    .line 87
    new-instance v0, Landroid/content/IntentFilter;

    const-string v3, "android.intent.action.TIME_TICK"

    invoke-direct {v0, v3}, Landroid/content/IntentFilter;-><init>(Ljava/lang/String;)V

    .line 88
    const-string v3, "android.intent.action.TIME_SET"

    invoke-virtual {v0, v3}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 89
    const-string v3, "android.intent.action.TIMEZONE_CHANGED"

    invoke-virtual {v0, v3}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 90
    const-string v3, "android.intent.action.LOCALE_CHANGED"

    invoke-virtual {v0, v3}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 91
    iget-object v3, p0, Lcom/k4/homeclock/EngineState;->context:Landroid/content/Context;

    iget-object v4, p0, Lcom/k4/homeclock/EngineState;->tickReceiver:Landroid/content/BroadcastReceiver;

    const/4 v5, 0x4

    invoke-virtual {v3, v4, v0, v5}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;I)Landroid/content/Intent;

    .line 92
    iput-boolean v1, p0, Lcom/k4/homeclock/EngineState;->tickerOn:Z

    goto :goto_4e

    .line 93
    :cond_40
    if-nez p1, :cond_4e

    iget-boolean v0, p0, Lcom/k4/homeclock/EngineState;->tickerOn:Z

    if-eqz v0, :cond_4e

    .line 94
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->tickReceiver:Landroid/content/BroadcastReceiver;

    invoke-direct {p0, v0}, Lcom/k4/homeclock/EngineState;->unregister(Landroid/content/BroadcastReceiver;)V

    .line 95
    iput-boolean v2, p0, Lcom/k4/homeclock/EngineState;->tickerOn:Z

    goto :goto_4f

    .line 93
    :cond_4e
    :goto_4e
    nop

    .line 97
    :goto_4f
    if-eqz p1, :cond_56

    .line 98
    const-string p1, "visible"

    invoke-virtual {p0, p1, v2}, Lcom/k4/homeclock/EngineState;->redrawIfStale(Ljava/lang/String;Z)V

    .line 100
    :cond_56
    return-void
.end method

.method start()V
    .registers 7

    .line 68
    new-instance v2, Landroid/content/IntentFilter;

    const-string v0, "com.k4.homeclock.action.RELOAD"

    invoke-direct {v2, v0}, Landroid/content/IntentFilter;-><init>(Ljava/lang/String;)V

    .line 69
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->context:Landroid/content/Context;

    iget-object v1, p0, Lcom/k4/homeclock/EngineState;->reloadReceiver:Landroid/content/BroadcastReceiver;

    const/4 v4, 0x0

    const/4 v5, 0x2

    const-string v3, "android.permission.WRITE_SECURE_SETTINGS"

    invoke-virtual/range {v0 .. v5}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;Ljava/lang/String;Landroid/os/Handler;I)Landroid/content/Intent;

    .line 70
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/k4/homeclock/EngineState;->reloadOn:Z

    .line 71
    return-void
.end method

.method stop()V
    .registers 3

    .line 74
    iget-object v0, p0, Lcom/k4/homeclock/EngineState;->main:Landroid/os/Handler;

    iget-object v1, p0, Lcom/k4/homeclock/EngineState;->reload:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 75
    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Lcom/k4/homeclock/EngineState;->setVisible(Z)V

    .line 76
    iget-boolean v1, p0, Lcom/k4/homeclock/EngineState;->reloadOn:Z

    if-eqz v1, :cond_16

    .line 77
    iget-object v1, p0, Lcom/k4/homeclock/EngineState;->reloadReceiver:Landroid/content/BroadcastReceiver;

    invoke-direct {p0, v1}, Lcom/k4/homeclock/EngineState;->unregister(Landroid/content/BroadcastReceiver;)V

    .line 78
    iput-boolean v0, p0, Lcom/k4/homeclock/EngineState;->reloadOn:Z

    .line 80
    :cond_16
    return-void
.end method
