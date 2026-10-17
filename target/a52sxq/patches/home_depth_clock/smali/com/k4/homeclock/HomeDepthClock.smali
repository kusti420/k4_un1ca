.class public final Lcom/k4/homeclock/HomeDepthClock;
.super Ljava/lang/Object;
.source "HomeDepthClock.java"


# static fields
.field public static final ACTION_RELOAD:Ljava/lang/String; = "com.k4.homeclock.action.RELOAD"

.field private static final CLOCKS:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Lh3/a;",
            "Lcom/k4/homeclock/DepthClock;",
            ">;"
        }
    .end annotation
.end field

.field private static final ENGINES:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Lf3/a;",
            "Lcom/k4/homeclock/EngineState;",
            ">;"
        }
    .end annotation
.end field

.field static final PROP:Ljava/lang/String; = "persist.sys.k4.home_depth_clock"

.field static final RELOAD_PERMISSION:Ljava/lang/String; = "android.permission.WRITE_SECURE_SETTINGS"

.field static final TAG:Ljava/lang/String; = "K4HomeClock"


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 37
    new-instance v0, Ljava/util/WeakHashMap;

    invoke-direct {v0}, Ljava/util/WeakHashMap;-><init>()V

    sput-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    .line 38
    new-instance v0, Ljava/util/WeakHashMap;

    invoke-direct {v0}, Ljava/util/WeakHashMap;-><init>()V

    sput-object v0, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 40
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static afterBuild(Lh3/a;)V
    .registers 12

    .line 86
    const-string v1, "K4HomeClock"

    :try_start_2
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    const-class v2, Lh3/b;

    if-ne v0, v2, :cond_a0

    iget v0, p0, Lh3/a;->c:I

    const/4 v2, 0x3

    and-int/2addr v0, v2

    if-ne v0, v2, :cond_a0

    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->enabled()Z

    move-result v0

    if-eqz v0, :cond_a0

    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->sharedEnabled()Z

    move-result v0

    if-nez v0, :cond_1e

    goto/16 :goto_a0

    .line 89
    :cond_1e
    iget-object v0, p0, Lh3/a;->e:Lg0/a;

    .line 90
    if-nez v0, :cond_23

    .line 91
    return-void

    .line 93
    :cond_23
    iget-object v2, p0, Lh3/a;->f:Li3/k;

    iget-object v2, v2, Li3/k;->c:Ljava/util/ArrayList;

    .line 94
    iget-object v3, v0, Lg0/a;->d:Ljava/lang/Object;

    if-nez v3, :cond_2d

    const/4 v3, -0x1

    goto :goto_33

    :cond_2d
    iget-object v3, v0, Lg0/a;->d:Ljava/lang/Object;

    invoke-virtual {v2, v3}, Ljava/util/ArrayList;->indexOf(Ljava/lang/Object;)I

    move-result v3

    .line 95
    :goto_33
    if-gez v3, :cond_39

    .line 96
    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result v3

    .line 98
    :cond_39
    iget-object v4, v0, Lg0/a;->d:Ljava/lang/Object;

    instance-of v4, v4, Li3/c;

    const/4 v5, 0x0

    if-eqz v4, :cond_45

    iget-object v4, v0, Lg0/a;->d:Ljava/lang/Object;

    check-cast v4, Li3/c;

    goto :goto_46

    :cond_45
    move-object v4, v5

    .line 99
    :goto_46
    iget-object v6, v0, Lg0/a;->c:Ljava/lang/Object;

    instance-of v6, v6, Li3/c;

    if-eqz v6, :cond_51

    iget-object v0, v0, Lg0/a;->c:Ljava/lang/Object;

    move-object v5, v0

    check-cast v5, Li3/c;

    :cond_51
    move-object v9, v5

    .line 100
    move-object v5, v4

    iget-object v4, p0, Lh3/a;->a:Landroid/content/Context;

    move-object v0, v5

    iget v5, p0, Lh3/a;->g:I

    iget v6, p0, Lh3/a;->h:I

    invoke-static {v0}, Lcom/k4/homeclock/HomeClockPresenter;->subjectTop(Li3/c;)F

    move-result v7

    const/4 v8, 0x0

    move-object v10, p0

    invoke-static/range {v4 .. v10}, Lcom/k4/homeclock/HomeDepthClock;->makeClock(Landroid/content/Context;IIFLandroid/graphics/Bitmap;Li3/c;Lh3/a;)Lcom/k4/homeclock/DepthClock;

    move-result-object p0

    .line 101
    invoke-virtual {v2, v3, p0}, Ljava/util/ArrayList;->add(ILjava/lang/Object;)V

    .line 102
    invoke-static {v10, p0}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 103
    iget-object p0, v10, Lh3/a;->a:Landroid/content/Context;

    invoke-static {p0}, Lcom/k4/homeclock/KeyguardWatch;->ensure(Landroid/content/Context;)V

    .line 104
    iget p0, v10, Lh3/a;->c:I

    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result v0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "shared home+lock wallpaper (which="

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v2, "): gated clock at layer "

    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v2, "/"

    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v1, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_9f
    .catchall {:try_start_2 .. :try_end_9f} :catchall_a1

    .line 107
    goto :goto_a8

    .line 87
    :cond_a0
    :goto_a0
    return-void

    .line 105
    :catchall_a1
    move-exception v0

    move-object p0, v0

    .line 106
    const-string v0, "afterBuild"

    invoke-static {v1, v0, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 108
    :goto_a8
    return-void
.end method

.method static clockOf(Lf3/a;)Lcom/k4/homeclock/DepthClock;
    .registers 3

    .line 147
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    monitor-enter v0

    .line 148
    :try_start_3
    iget-object v1, p0, Lf3/a;->g:Lh3/a;

    if-nez v1, :cond_9

    const/4 p0, 0x0

    goto :goto_13

    :cond_9
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    iget-object p0, p0, Lf3/a;->g:Lh3/a;

    invoke-interface {v1, p0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/k4/homeclock/DepthClock;

    :goto_13
    monitor-exit v0

    return-object p0

    .line 149
    :catchall_15
    move-exception p0

    monitor-exit v0
    :try_end_17
    .catchall {:try_start_3 .. :try_end_17} :catchall_15

    throw p0
.end method

.method public static enabled()Z
    .registers 2

    .line 52
    const-string v0, "persist.sys.k4.home_depth_clock"

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->prop(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 53
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

.method static engineOf(Lh3/a;)Lf3/a;
    .registers 5

    .line 153
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0

    .line 154
    :try_start_3
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    invoke-interface {v1}, Ljava/util/Map;->keySet()Ljava/util/Set;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_d
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_22

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lf3/a;

    .line 155
    if-eqz v2, :cond_21

    iget-object v3, v2, Lf3/a;->g:Lh3/a;

    if-ne v3, p0, :cond_21

    .line 156
    monitor-exit v0

    return-object v2

    .line 158
    :cond_21
    goto :goto_d

    .line 159
    :cond_22
    monitor-exit v0

    .line 160
    const/4 p0, 0x0

    return-object p0

    .line 159
    :catchall_25
    move-exception p0

    monitor-exit v0
    :try_end_27
    .catchall {:try_start_3 .. :try_end_27} :catchall_25

    throw p0
.end method

.method static homeCapable(I)Z
    .registers 2

    .line 66
    const/4 v0, 0x1

    and-int/2addr p0, v0

    if-eqz p0, :cond_5

    goto :goto_6

    :cond_5
    const/4 v0, 0x0

    :goto_6
    return v0
.end method

.method static makeClock(Landroid/content/Context;IIFLandroid/graphics/Bitmap;Li3/c;Lh3/a;)Lcom/k4/homeclock/DepthClock;
    .registers 16

    .line 117
    new-instance v1, Lcom/k4/homeclock/ClockNode;

    move-object v2, p0

    move v3, p1

    move v4, p2

    move v5, p3

    move-object v6, p4

    move-object v7, p5

    move-object v8, p6

    invoke-direct/range {v1 .. v8}, Lcom/k4/homeclock/ClockNode;-><init>(Landroid/content/Context;IIFLandroid/graphics/Bitmap;Li3/c;Lh3/a;)V

    .line 118
    move-object v5, v1

    move-object v0, v2

    move v1, v3

    move v2, v4

    move-object v4, v6

    move-object v6, v7

    move-object v7, v8

    invoke-static {v0}, Lcom/k4/homeclock/HomeClockItem;->read(Landroid/content/Context;)Lcom/k4/homeclock/HomeClockItem;

    move-result-object v3

    .line 119
    const-string p0, "K4HomeClock"

    if-nez v3, :cond_21

    .line 120
    const-string p1, "no saved home clock item: plain clock"

    invoke-static {p0, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 121
    return-object v5

    .line 124
    :cond_21
    :try_start_21
    invoke-static/range {v0 .. v7}, Lcom/k4/homeclock/AodClockNode;->create(Landroid/content/Context;IILcom/k4/homeclock/HomeClockItem;Landroid/graphics/Bitmap;Lcom/k4/homeclock/ClockNode;Li3/c;Lh3/a;)Lcom/k4/homeclock/AodClockNode;

    move-result-object p0
    :try_end_25
    .catchall {:try_start_21 .. :try_end_25} :catchall_26

    return-object p0

    .line 125
    :catchall_26
    move-exception v0

    move-object p1, v0

    .line 126
    instance-of p2, p1, Ljava/lang/reflect/InvocationTargetException;

    if-eqz p2, :cond_36

    invoke-virtual {p1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object p2

    if-eqz p2, :cond_36

    invoke-virtual {p1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object p1

    .line 127
    :cond_36
    invoke-static {v3}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p2

    new-instance p3, Ljava/lang/StringBuilder;

    invoke-direct {p3}, Ljava/lang/StringBuilder;-><init>()V

    const-string p4, "AOD clock unavailable, plain clock ("

    invoke-virtual {p3, p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, ")"

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    invoke-static {p0, p2, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 128
    return-object v5
.end method

.method public static onCreate(Lf3/a;)V
    .registers 4

    .line 171
    :try_start_0
    invoke-virtual {p0}, Lf3/a;->getWhich()I

    move-result v0

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->homeCapable(I)Z

    move-result v0

    if-nez v0, :cond_b

    .line 172
    return-void

    .line 174
    :cond_b
    new-instance v0, Lcom/k4/homeclock/EngineState;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/EngineState;-><init>(Lf3/a;)V

    .line 175
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v1
    :try_end_13
    .catchall {:try_start_0 .. :try_end_13} :catchall_20

    .line 176
    :try_start_13
    sget-object v2, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    invoke-interface {v2, p0, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 177
    monitor-exit v1
    :try_end_19
    .catchall {:try_start_13 .. :try_end_19} :catchall_1d

    .line 178
    :try_start_19
    invoke-virtual {v0}, Lcom/k4/homeclock/EngineState;->start()V
    :try_end_1c
    .catchall {:try_start_19 .. :try_end_1c} :catchall_20

    .line 181
    goto :goto_28

    .line 177
    :catchall_1d
    move-exception p0

    :try_start_1e
    monitor-exit v1
    :try_end_1f
    .catchall {:try_start_1e .. :try_end_1f} :catchall_1d

    :try_start_1f
    throw p0
    :try_end_20
    .catchall {:try_start_1f .. :try_end_20} :catchall_20

    .line 179
    :catchall_20
    move-exception p0

    .line 180
    const-string v0, "K4HomeClock"

    const-string v1, "onCreate"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 182
    :goto_28
    return-void
.end method

.method public static onDestroy(Lf3/a;)V
    .registers 3

    .line 201
    :try_start_0
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0
    :try_end_3
    .catchall {:try_start_0 .. :try_end_3} :catchall_15

    .line 202
    :try_start_3
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    invoke-interface {v1, p0}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/k4/homeclock/EngineState;

    .line 203
    monitor-exit v0
    :try_end_c
    .catchall {:try_start_3 .. :try_end_c} :catchall_12

    .line 204
    if-eqz p0, :cond_11

    .line 205
    :try_start_e
    invoke-virtual {p0}, Lcom/k4/homeclock/EngineState;->stop()V
    :try_end_11
    .catchall {:try_start_e .. :try_end_11} :catchall_15

    .line 209
    :cond_11
    goto :goto_1d

    .line 203
    :catchall_12
    move-exception p0

    :try_start_13
    monitor-exit v0
    :try_end_14
    .catchall {:try_start_13 .. :try_end_14} :catchall_12

    :try_start_14
    throw p0
    :try_end_15
    .catchall {:try_start_14 .. :try_end_15} :catchall_15

    .line 207
    :catchall_15
    move-exception p0

    .line 208
    const-string v0, "K4HomeClock"

    const-string v1, "onDestroy"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 210
    :goto_1d
    return-void
.end method

.method public static onVisibility(Lf3/a;Z)V
    .registers 4

    .line 187
    :try_start_0
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0
    :try_end_3
    .catchall {:try_start_0 .. :try_end_3} :catchall_15

    .line 188
    :try_start_3
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    invoke-interface {v1, p0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/k4/homeclock/EngineState;

    .line 189
    monitor-exit v0
    :try_end_c
    .catchall {:try_start_3 .. :try_end_c} :catchall_12

    .line 190
    if-eqz p0, :cond_11

    .line 191
    :try_start_e
    invoke-virtual {p0, p1}, Lcom/k4/homeclock/EngineState;->setVisible(Z)V
    :try_end_11
    .catchall {:try_start_e .. :try_end_11} :catchall_15

    .line 195
    :cond_11
    goto :goto_1d

    .line 189
    :catchall_12
    move-exception p0

    :try_start_13
    monitor-exit v0
    :try_end_14
    .catchall {:try_start_13 .. :try_end_14} :catchall_12

    :try_start_14
    throw p0
    :try_end_15
    .catchall {:try_start_14 .. :try_end_15} :catchall_15

    .line 193
    :catchall_15
    move-exception p0

    .line 194
    const-string p1, "K4HomeClock"

    const-string v0, "onVisibility"

    invoke-static {p1, v0, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 196
    :goto_1d
    return-void
.end method

.method public static presenter(Lh3/a;Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)Lh3/a;
    .registers 7

    .line 71
    const-string v0, "K4HomeClock"

    and-int/lit8 v1, p2, 0x3

    const/4 v2, 0x1

    if-ne v1, v2, :cond_37

    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->enabled()Z

    move-result v1

    if-nez v1, :cond_e

    goto :goto_37

    .line 75
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

    .line 76
    new-instance v1, Lcom/k4/homeclock/HomeClockPresenter;

    invoke-direct {v1, p1, p2, p3}, Lcom/k4/homeclock/HomeClockPresenter;-><init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V
    :try_end_2f
    .catchall {:try_start_e .. :try_end_2f} :catchall_30

    return-object v1

    .line 77
    :catchall_30
    move-exception p1

    .line 78
    const-string p2, "presenter: falling back to stock"

    invoke-static {v0, p2, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 79
    return-object p0

    .line 72
    :cond_37
    :goto_37
    return-object p0
.end method

.method static prop(Ljava/lang/String;)Ljava/lang/String;
    .registers 2

    .line 44
    const-string v0, ""

    :try_start_2
    invoke-static {p0}, Landroid/os/SemSystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    .line 45
    if-nez p0, :cond_9

    goto :goto_d

    :cond_9
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0
    :try_end_d
    .catchall {:try_start_2 .. :try_end_d} :catchall_e

    :goto_d
    return-object v0

    .line 46
    :catchall_e
    move-exception p0

    .line 47
    return-object v0
.end method

.method static setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V
    .registers 4

    .line 134
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    monitor-enter v0

    .line 135
    if-nez p1, :cond_c

    :try_start_5
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    invoke-interface {v1, p0}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    goto :goto_12

    :cond_c
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    invoke-interface {v1, p0, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    :goto_12
    check-cast p0, Lcom/k4/homeclock/DepthClock;

    .line 136
    monitor-exit v0
    :try_end_15
    .catchall {:try_start_5 .. :try_end_15} :catchall_26

    .line 137
    if-eqz p0, :cond_25

    if-eq p0, p1, :cond_25

    .line 139
    :try_start_19
    invoke-virtual {p0}, Lcom/k4/homeclock/DepthClock;->release()V
    :try_end_1c
    .catchall {:try_start_19 .. :try_end_1c} :catchall_1d

    .line 142
    goto :goto_25

    .line 140
    :catchall_1d
    move-exception p0

    .line 141
    const-string p1, "K4HomeClock"

    const-string v0, "release"

    invoke-static {p1, v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 144
    :cond_25
    :goto_25
    return-void

    .line 136
    :catchall_26
    move-exception p0

    :try_start_27
    monitor-exit v0
    :try_end_28
    .catchall {:try_start_27 .. :try_end_28} :catchall_26

    throw p0
.end method

.method static sharedEnabled()Z
    .registers 2

    .line 61
    const-string v0, "persist.sys.k4.home_depth_clock_shared"

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->prop(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v1, "1"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    return v0
.end method

.method static states()[Lcom/k4/homeclock/EngineState;
    .registers 3

    .line 164
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0

    .line 165
    :try_start_3
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    invoke-interface {v1}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v1

    const/4 v2, 0x0

    new-array v2, v2, [Lcom/k4/homeclock/EngineState;

    invoke-interface {v1, v2}, Ljava/util/Collection;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v1

    check-cast v1, [Lcom/k4/homeclock/EngineState;

    monitor-exit v0

    return-object v1

    .line 166
    :catchall_14
    move-exception v1

    monitor-exit v0
    :try_end_16
    .catchall {:try_start_3 .. :try_end_16} :catchall_14

    throw v1
.end method
