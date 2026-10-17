.class public final Lcom/k4/homeclock/HomeDepthClock;
.super Ljava/lang/Object;
.source "HomeDepthClock.java"


# static fields
.field static final PROP:Ljava/lang/String; = "persist.sys.k4.home_depth_clock"

.field static final TAG:Ljava/lang/String; = "K4HomeClock"


# direct methods
.method private constructor <init>()V
    .registers 1

    .line 22
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static enabled()Z
    .registers 2

    .line 34
    const-string v0, "persist.sys.k4.home_depth_clock"

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->prop(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 35
    const-string v1, "1"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_19

    const-string v1, "true"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_17

    goto :goto_19

    :cond_17
    const/4 v0, 0x0

    goto :goto_1a

    :cond_19
    :goto_19
    const/4 v0, 0x1

    :goto_1a
    return v0
.end method

.method public static onDestroy(Lf3/a;)V
    .registers 3

    .line 64
    :try_start_0
    iget-object v0, p0, Lf3/a;->g:Lh3/a;

    instance-of v0, v0, Lcom/k4/homeclock/HomeClockPresenter;

    if-eqz v0, :cond_10

    .line 65
    iget-object v0, p0, Lf3/a;->g:Lh3/a;

    check-cast v0, Lcom/k4/homeclock/HomeClockPresenter;

    iget-object v0, v0, Lcom/k4/homeclock/HomeClockPresenter;->ticker:Lcom/k4/homeclock/Ticker;

    const/4 v1, 0x0

    invoke-virtual {v0, p0, v1}, Lcom/k4/homeclock/Ticker;->setVisible(Lf3/a;Z)V
    :try_end_10
    .catchall {:try_start_0 .. :try_end_10} :catchall_11

    .line 69
    :cond_10
    goto :goto_19

    .line 67
    :catchall_11
    move-exception p0

    .line 68
    const-string v0, "K4HomeClock"

    const-string v1, "onDestroy"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 70
    :goto_19
    return-void
.end method

.method public static onVisibility(Lf3/a;Z)V
    .registers 3

    .line 54
    :try_start_0
    iget-object v0, p0, Lf3/a;->g:Lh3/a;

    instance-of v0, v0, Lcom/k4/homeclock/HomeClockPresenter;

    if-eqz v0, :cond_f

    .line 55
    iget-object v0, p0, Lf3/a;->g:Lh3/a;

    check-cast v0, Lcom/k4/homeclock/HomeClockPresenter;

    iget-object v0, v0, Lcom/k4/homeclock/HomeClockPresenter;->ticker:Lcom/k4/homeclock/Ticker;

    invoke-virtual {v0, p0, p1}, Lcom/k4/homeclock/Ticker;->setVisible(Lf3/a;Z)V
    :try_end_f
    .catchall {:try_start_0 .. :try_end_f} :catchall_10

    .line 59
    :cond_f
    goto :goto_18

    .line 57
    :catchall_10
    move-exception p0

    .line 58
    const-string p1, "K4HomeClock"

    const-string v0, "onVisibility"

    invoke-static {p1, v0, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 60
    :goto_18
    return-void
.end method

.method public static presenter(Lh3/a;Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)Lh3/a;
    .registers 7

    .line 40
    const-string v0, "K4HomeClock"

    and-int/lit8 v1, p2, 0x3

    const/4 v2, 0x1

    if-ne v1, v2, :cond_37

    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->enabled()Z

    move-result v1

    if-nez v1, :cond_e

    goto :goto_37

    .line 44
    :cond_e
    :try_start_e
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "home layered wallpaper (which="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "): depth clock presenter"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 45
    new-instance v1, Lcom/k4/homeclock/HomeClockPresenter;

    invoke-direct {v1, p1, p2, p3}, Lcom/k4/homeclock/HomeClockPresenter;-><init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V
    :try_end_2f
    .catchall {:try_start_e .. :try_end_2f} :catchall_30

    return-object v1

    .line 46
    :catchall_30
    move-exception p1

    .line 47
    const-string p2, "presenter: falling back to stock"

    invoke-static {v0, p2, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 48
    return-object p0

    .line 41
    :cond_37
    :goto_37
    return-object p0
.end method

.method static prop(Ljava/lang/String;)Ljava/lang/String;
    .registers 2

    .line 26
    const-string v0, ""

    :try_start_2
    invoke-static {p0}, Landroid/os/SemSystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    .line 27
    if-nez p0, :cond_9

    goto :goto_d

    :cond_9
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0
    :try_end_d
    .catchall {:try_start_2 .. :try_end_d} :catchall_e

    :goto_d
    return-object v0

    .line 28
    :catchall_e
    move-exception p0

    .line 29
    return-object v0
.end method
