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
            "Lcom/k4/homeclock/ClockNode;",
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
    :try_start_0
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    const-class v1, Lh3/b;

    if-ne v0, v1, :cond_aa

    iget v0, p0, Lh3/a;->c:I

    const/4 v1, 0x3

    and-int/2addr v0, v1

    if-ne v0, v1, :cond_aa

    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->enabled()Z

    move-result v0

    if-eqz v0, :cond_aa

    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->sharedEnabled()Z

    move-result v0

    if-nez v0, :cond_1c

    goto/16 :goto_aa

    .line 89
    :cond_1c
    iget-object v0, p0, Lh3/a;->e:Lg0/a;

    .line 90
    if-nez v0, :cond_21

    .line 91
    return-void

    .line 93
    :cond_21
    iget-object v1, p0, Lh3/a;->f:Li3/k;

    iget-object v1, v1, Li3/k;->c:Ljava/util/ArrayList;

    .line 94
    iget-object v2, v0, Lg0/a;->d:Ljava/lang/Object;

    if-nez v2, :cond_2b

    const/4 v2, -0x1

    goto :goto_31

    :cond_2b
    iget-object v2, v0, Lg0/a;->d:Ljava/lang/Object;

    invoke-virtual {v1, v2}, Ljava/util/ArrayList;->indexOf(Ljava/lang/Object;)I

    move-result v2

    .line 95
    :goto_31
    if-gez v2, :cond_37

    .line 96
    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    move-result v2

    .line 98
    :cond_37
    iget-object v3, v0, Lg0/a;->d:Ljava/lang/Object;

    instance-of v3, v3, Li3/c;

    const/4 v4, 0x0

    if-eqz v3, :cond_43

    iget-object v3, v0, Lg0/a;->d:Ljava/lang/Object;

    check-cast v3, Li3/c;

    goto :goto_44

    :cond_43
    move-object v3, v4

    .line 99
    :goto_44
    iget-object v5, v0, Lg0/a;->c:Ljava/lang/Object;

    instance-of v5, v5, Li3/c;

    if-eqz v5, :cond_4f

    iget-object v0, v0, Lg0/a;->c:Ljava/lang/Object;

    move-object v4, v0

    check-cast v4, Li3/c;

    :cond_4f
    move-object v9, v4

    .line 100
    move-object v4, v3

    new-instance v3, Lcom/k4/homeclock/ClockNode;

    move-object v0, v4

    iget-object v4, p0, Lh3/a;->a:Landroid/content/Context;

    iget v5, p0, Lh3/a;->g:I

    iget v6, p0, Lh3/a;->h:I

    invoke-static {v0}, Lcom/k4/homeclock/HomeClockPresenter;->subjectTop(Li3/c;)F

    move-result v7

    const/4 v8, 0x0

    move-object v10, p0

    invoke-direct/range {v3 .. v10}, Lcom/k4/homeclock/ClockNode;-><init>(Landroid/content/Context;IIFLandroid/graphics/Bitmap;Li3/c;Lh3/a;)V

    .line 101
    invoke-virtual {v1, v2, v3}, Ljava/util/ArrayList;->add(ILjava/lang/Object;)V

    .line 102
    sget-object p0, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    monitor-enter p0
    :try_end_69
    .catchall {:try_start_0 .. :try_end_69} :catchall_ab

    .line 103
    :try_start_69
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    invoke-interface {v0, v10, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 104
    monitor-exit p0
    :try_end_6f
    .catchall {:try_start_69 .. :try_end_6f} :catchall_a7

    .line 105
    :try_start_6f
    iget-object p0, v10, Lh3/a;->a:Landroid/content/Context;

    invoke-static {p0}, Lcom/k4/homeclock/KeyguardWatch;->ensure(Landroid/content/Context;)V

    .line 106
    const-string p0, "K4HomeClock"

    iget v0, v10, Lh3/a;->c:I

    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    move-result v1

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "shared home+lock wallpaper (which="

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, "): gated clock at layer "

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, "/"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_a6
    .catchall {:try_start_6f .. :try_end_a6} :catchall_ab

    .line 109
    goto :goto_b4

    .line 104
    :catchall_a7
    move-exception v0

    :try_start_a8
    monitor-exit p0
    :try_end_a9
    .catchall {:try_start_a8 .. :try_end_a9} :catchall_a7

    :try_start_a9
    throw v0
    :try_end_aa
    .catchall {:try_start_a9 .. :try_end_aa} :catchall_ab

    .line 87
    :cond_aa
    :goto_aa
    return-void

    .line 107
    :catchall_ab
    move-exception v0

    move-object p0, v0

    .line 108
    const-string v0, "K4HomeClock"

    const-string v1, "afterBuild"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 110
    :goto_b4
    return-void
.end method

.method static clockOf(Lf3/a;)Lcom/k4/homeclock/ClockNode;
    .registers 3

    .line 123
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    monitor-enter v0

    .line 124
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

    check-cast p0, Lcom/k4/homeclock/ClockNode;

    :goto_13
    monitor-exit v0

    return-object p0

    .line 125
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

    .line 129
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0

    .line 130
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

    .line 131
    if-eqz v2, :cond_21

    iget-object v3, v2, Lf3/a;->g:Lh3/a;

    if-ne v3, p0, :cond_21

    .line 132
    monitor-exit v0

    return-object v2

    .line 134
    :cond_21
    goto :goto_d

    .line 135
    :cond_22
    monitor-exit v0

    .line 136
    const/4 p0, 0x0

    return-object p0

    .line 135
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

.method public static onCreate(Lf3/a;)V
    .registers 4

    .line 147
    :try_start_0
    invoke-virtual {p0}, Lf3/a;->getWhich()I

    move-result v0

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->homeCapable(I)Z

    move-result v0

    if-nez v0, :cond_b

    .line 148
    return-void

    .line 150
    :cond_b
    new-instance v0, Lcom/k4/homeclock/EngineState;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/EngineState;-><init>(Lf3/a;)V

    .line 151
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v1
    :try_end_13
    .catchall {:try_start_0 .. :try_end_13} :catchall_20

    .line 152
    :try_start_13
    sget-object v2, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    invoke-interface {v2, p0, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 153
    monitor-exit v1
    :try_end_19
    .catchall {:try_start_13 .. :try_end_19} :catchall_1d

    .line 154
    :try_start_19
    invoke-virtual {v0}, Lcom/k4/homeclock/EngineState;->start()V
    :try_end_1c
    .catchall {:try_start_19 .. :try_end_1c} :catchall_20

    .line 157
    goto :goto_28

    .line 153
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

    .line 155
    :catchall_20
    move-exception p0

    .line 156
    const-string v0, "K4HomeClock"

    const-string v1, "onCreate"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 158
    :goto_28
    return-void
.end method

.method public static onDestroy(Lf3/a;)V
    .registers 3

    .line 177
    :try_start_0
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0
    :try_end_3
    .catchall {:try_start_0 .. :try_end_3} :catchall_15

    .line 178
    :try_start_3
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    invoke-interface {v1, p0}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/k4/homeclock/EngineState;

    .line 179
    monitor-exit v0
    :try_end_c
    .catchall {:try_start_3 .. :try_end_c} :catchall_12

    .line 180
    if-eqz p0, :cond_11

    .line 181
    :try_start_e
    invoke-virtual {p0}, Lcom/k4/homeclock/EngineState;->stop()V
    :try_end_11
    .catchall {:try_start_e .. :try_end_11} :catchall_15

    .line 185
    :cond_11
    goto :goto_1d

    .line 179
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

    .line 183
    :catchall_15
    move-exception p0

    .line 184
    const-string v0, "K4HomeClock"

    const-string v1, "onDestroy"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 186
    :goto_1d
    return-void
.end method

.method public static onVisibility(Lf3/a;Z)V
    .registers 4

    .line 163
    :try_start_0
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0
    :try_end_3
    .catchall {:try_start_0 .. :try_end_3} :catchall_15

    .line 164
    :try_start_3
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    invoke-interface {v1, p0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/k4/homeclock/EngineState;

    .line 165
    monitor-exit v0
    :try_end_c
    .catchall {:try_start_3 .. :try_end_c} :catchall_12

    .line 166
    if-eqz p0, :cond_11

    .line 167
    :try_start_e
    invoke-virtual {p0, p1}, Lcom/k4/homeclock/EngineState;->setVisible(Z)V
    :try_end_11
    .catchall {:try_start_e .. :try_end_11} :catchall_15

    .line 171
    :cond_11
    goto :goto_1d

    .line 165
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

    .line 169
    :catchall_15
    move-exception p0

    .line 170
    const-string p1, "K4HomeClock"

    const-string v0, "onVisibility"

    invoke-static {p1, v0, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 172
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

.method static setClock(Lh3/a;Lcom/k4/homeclock/ClockNode;)V
    .registers 4

    .line 113
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    monitor-enter v0

    .line 114
    if-nez p1, :cond_b

    .line 115
    :try_start_5
    sget-object p1, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    invoke-interface {p1, p0}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_10

    .line 117
    :cond_b
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    invoke-interface {v1, p0, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 119
    :goto_10
    monitor-exit v0

    .line 120
    return-void

    .line 119
    :catchall_12
    move-exception p0

    monitor-exit v0
    :try_end_14
    .catchall {:try_start_5 .. :try_end_14} :catchall_12

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

    .line 140
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0

    .line 141
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

    .line 142
    :catchall_14
    move-exception v1

    monitor-exit v0
    :try_end_16
    .catchall {:try_start_3 .. :try_end_16} :catchall_14

    throw v1
.end method
