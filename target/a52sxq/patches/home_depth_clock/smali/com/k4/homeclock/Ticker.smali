.class final Lcom/k4/homeclock/Ticker;
.super Landroid/content/BroadcastReceiver;
.source "Ticker.java"


# instance fields
.field private engine:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Lf3/a;",
            ">;"
        }
    .end annotation
.end field

.field private final presenter:Lcom/k4/homeclock/HomeClockPresenter;

.field private registeredOn:Landroid/content/Context;


# direct methods
.method constructor <init>(Lcom/k4/homeclock/HomeClockPresenter;)V
    .registers 4

    .line 22
    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    .line 19
    new-instance v0, Ljava/lang/ref/WeakReference;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    iput-object v0, p0, Lcom/k4/homeclock/Ticker;->engine:Ljava/lang/ref/WeakReference;

    .line 23
    iput-object p1, p0, Lcom/k4/homeclock/Ticker;->presenter:Lcom/k4/homeclock/HomeClockPresenter;

    .line 24
    return-void
.end method

.method private redrawIfStale(Ljava/lang/String;)V
    .registers 7

    .line 58
    iget-object v0, p0, Lcom/k4/homeclock/Ticker;->engine:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lf3/a;

    .line 59
    iget-object v1, p0, Lcom/k4/homeclock/Ticker;->presenter:Lcom/k4/homeclock/HomeClockPresenter;

    iget-object v1, v1, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/ClockNode;

    .line 60
    if-eqz v0, :cond_54

    if-nez v1, :cond_11

    goto :goto_54

    .line 63
    :cond_11
    invoke-virtual {v1}, Lcom/k4/homeclock/ClockNode;->text()Ljava/lang/String;

    move-result-object v2

    .line 64
    iget-object v3, v1, Lcom/k4/homeclock/ClockNode;->lastDrawn:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_1e

    .line 65
    return-void

    .line 67
    :cond_1e
    iget-object v1, v1, Lcom/k4/homeclock/ClockNode;->lastDrawn:Ljava/lang/String;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "redraw ("

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v3, "): "

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v1, " -> "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string v1, "K4HomeClock"

    invoke-static {v1, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 68
    invoke-virtual {v0}, Lf3/a;->getSurfaceHolder()Landroid/view/SurfaceHolder;

    move-result-object p1

    invoke-virtual {v0, p1}, Lf3/a;->b(Landroid/view/SurfaceHolder;)V

    .line 69
    return-void

    .line 61
    :cond_54
    :goto_54
    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .registers 4

    .line 51
    :try_start_0
    invoke-virtual {p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Lcom/k4/homeclock/Ticker;->redrawIfStale(Ljava/lang/String;)V
    :try_end_7
    .catchall {:try_start_0 .. :try_end_7} :catchall_8

    .line 54
    goto :goto_10

    .line 52
    :catchall_8
    move-exception p1

    .line 53
    const-string p2, "K4HomeClock"

    const-string v0, "tick"

    invoke-static {p2, v0, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 55
    :goto_10
    return-void
.end method

.method setVisible(Lf3/a;Z)V
    .registers 4

    .line 27
    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, p1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    iput-object v0, p0, Lcom/k4/homeclock/Ticker;->engine:Ljava/lang/ref/WeakReference;

    .line 28
    if-eqz p2, :cond_37

    .line 29
    iget-object p1, p0, Lcom/k4/homeclock/Ticker;->registeredOn:Landroid/content/Context;

    if-nez p1, :cond_31

    .line 30
    iget-object p1, p0, Lcom/k4/homeclock/Ticker;->presenter:Lcom/k4/homeclock/HomeClockPresenter;

    iget-object p1, p1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    invoke-virtual {p1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p1

    .line 31
    new-instance p2, Landroid/content/IntentFilter;

    const-string v0, "android.intent.action.TIME_TICK"

    invoke-direct {p2, v0}, Landroid/content/IntentFilter;-><init>(Ljava/lang/String;)V

    .line 32
    const-string v0, "android.intent.action.TIME_SET"

    invoke-virtual {p2, v0}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 33
    const-string v0, "android.intent.action.TIMEZONE_CHANGED"

    invoke-virtual {p2, v0}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 34
    const-string v0, "android.intent.action.LOCALE_CHANGED"

    invoke-virtual {p2, v0}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 35
    const/4 v0, 0x4

    invoke-virtual {p1, p0, p2, v0}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;I)Landroid/content/Intent;

    .line 36
    iput-object p1, p0, Lcom/k4/homeclock/Ticker;->registeredOn:Landroid/content/Context;

    .line 38
    :cond_31
    const-string p1, "visible"

    invoke-direct {p0, p1}, Lcom/k4/homeclock/Ticker;->redrawIfStale(Ljava/lang/String;)V

    goto :goto_45

    .line 39
    :cond_37
    iget-object p1, p0, Lcom/k4/homeclock/Ticker;->registeredOn:Landroid/content/Context;

    if-eqz p1, :cond_45

    .line 41
    :try_start_3b
    iget-object p1, p0, Lcom/k4/homeclock/Ticker;->registeredOn:Landroid/content/Context;

    invoke-virtual {p1, p0}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V
    :try_end_40
    .catch Ljava/lang/IllegalArgumentException; {:try_start_3b .. :try_end_40} :catch_41

    .line 43
    goto :goto_42

    .line 42
    :catch_41
    move-exception p1

    .line 44
    :goto_42
    const/4 p1, 0x0

    iput-object p1, p0, Lcom/k4/homeclock/Ticker;->registeredOn:Landroid/content/Context;

    .line 46
    :cond_45
    :goto_45
    return-void
.end method
