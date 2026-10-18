.class public final Lcom/k4/homeclock/HomeDepthClock;
.super Ljava/lang/Object;
.source "HomeDepthClock.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/k4/homeclock/HomeDepthClock$PostDim;
    }
.end annotation


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

.field public static final EXTRA_WALLPAPER_PENDING:Ljava/lang/String; = "com.k4.homeclock.extra.WALLPAPER_PENDING"

.field private static final POST_DIM:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Lf3/a;",
            "Ljava/lang/Boolean;",
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

    .line 43
    new-instance v0, Ljava/util/WeakHashMap;

    invoke-direct {v0}, Ljava/util/WeakHashMap;-><init>()V

    sput-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    .line 44
    new-instance v0, Ljava/util/WeakHashMap;

    invoke-direct {v0}, Ljava/util/WeakHashMap;-><init>()V

    sput-object v0, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    .line 175
    new-instance v0, Ljava/util/WeakHashMap;

    invoke-direct {v0}, Ljava/util/WeakHashMap;-><init>()V

    sput-object v0, Lcom/k4/homeclock/HomeDepthClock;->POST_DIM:Ljava/util/Map;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 46
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static afterBuild(Lh3/a;)V
    .registers 12

    .line 92
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

    .line 95
    :cond_1e
    iget-object v0, p0, Lh3/a;->e:Lg0/a;

    .line 96
    if-nez v0, :cond_23

    .line 97
    return-void

    .line 99
    :cond_23
    iget-object v2, p0, Lh3/a;->f:Li3/k;

    iget-object v2, v2, Li3/k;->c:Ljava/util/ArrayList;

    .line 100
    iget-object v3, v0, Lg0/a;->d:Ljava/lang/Object;

    if-nez v3, :cond_2d

    const/4 v3, -0x1

    goto :goto_33

    :cond_2d
    iget-object v3, v0, Lg0/a;->d:Ljava/lang/Object;

    invoke-virtual {v2, v3}, Ljava/util/ArrayList;->indexOf(Ljava/lang/Object;)I

    move-result v3

    .line 101
    :goto_33
    if-gez v3, :cond_39

    .line 102
    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result v3

    .line 104
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

    .line 105
    :goto_46
    iget-object v6, v0, Lg0/a;->c:Ljava/lang/Object;

    instance-of v6, v6, Li3/c;

    if-eqz v6, :cond_51

    iget-object v0, v0, Lg0/a;->c:Ljava/lang/Object;

    move-object v5, v0

    check-cast v5, Li3/c;

    :cond_51
    move-object v9, v5

    .line 106
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

    .line 107
    invoke-virtual {v2, v3, p0}, Ljava/util/ArrayList;->add(ILjava/lang/Object;)V

    .line 108
    invoke-static {v10, p0}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 109
    iget-object p0, v10, Lh3/a;->a:Landroid/content/Context;

    invoke-static {p0}, Lcom/k4/homeclock/KeyguardWatch;->ensure(Landroid/content/Context;)V

    .line 110
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

    .line 113
    goto :goto_a8

    .line 93
    :cond_a0
    :goto_a0
    return-void

    .line 111
    :catchall_a1
    move-exception v0

    move-object p0, v0

    .line 112
    const-string v0, "afterBuild"

    invoke-static {v1, v0, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 114
    :goto_a8
    return-void
.end method

.method static clockOf(Lf3/a;)Lcom/k4/homeclock/DepthClock;
    .registers 3

    .line 153
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    monitor-enter v0

    .line 154
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

    .line 155
    :catchall_15
    move-exception p0

    monitor-exit v0
    :try_end_17
    .catchall {:try_start_3 .. :try_end_17} :catchall_15

    throw p0
.end method

.method static dimOf(Lf3/a;)F
    .registers 2

    .line 201
    iget-object p0, p0, Lf3/a;->j:Li3/e;

    .line 202
    if-eqz p0, :cond_17

    iget-boolean v0, p0, Li3/e;->c:Z

    if-eqz v0, :cond_17

    iget v0, p0, Li3/e;->d:I

    if-eqz v0, :cond_17

    iget p0, p0, Li3/e;->d:I

    invoke-static {p0}, Landroid/graphics/Color;->alpha(I)I

    move-result p0

    int-to-float p0, p0

    const/high16 v0, 0x437f0000    # 255.0f

    div-float/2addr p0, v0

    goto :goto_18

    :cond_17
    const/4 p0, 0x0

    :goto_18
    return p0
.end method

.method public static enabled()Z
    .registers 2

    .line 58
    const-string v0, "persist.sys.k4.home_depth_clock"

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->prop(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 59
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

    .line 159
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0

    .line 160
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

    .line 161
    if-eqz v2, :cond_21

    iget-object v3, v2, Lf3/a;->g:Lh3/a;

    if-ne v3, p0, :cond_21

    .line 162
    monitor-exit v0

    return-object v2

    .line 164
    :cond_21
    goto :goto_d

    .line 165
    :cond_22
    monitor-exit v0

    .line 166
    const/4 p0, 0x0

    return-object p0

    .line 165
    :catchall_25
    move-exception p0

    monitor-exit v0
    :try_end_27
    .catchall {:try_start_3 .. :try_end_27} :catchall_25

    throw p0
.end method

.method static homeCapable(I)Z
    .registers 2

    .line 72
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

    .line 123
    new-instance v1, Lcom/k4/homeclock/ClockNode;

    move-object v2, p0

    move v3, p1

    move v4, p2

    move v5, p3

    move-object v6, p4

    move-object v7, p5

    move-object v8, p6

    invoke-direct/range {v1 .. v8}, Lcom/k4/homeclock/ClockNode;-><init>(Landroid/content/Context;IIFLandroid/graphics/Bitmap;Li3/c;Lh3/a;)V

    .line 124
    move-object v5, v1

    move-object v0, v2

    move v1, v3

    move v2, v4

    move-object v4, v6

    move-object v6, v7

    move-object v7, v8

    invoke-static {v0}, Lcom/k4/homeclock/HomeClockItem;->read(Landroid/content/Context;)Lcom/k4/homeclock/HomeClockItem;

    move-result-object v3

    .line 125
    const-string p0, "K4HomeClock"

    if-nez v3, :cond_21

    .line 126
    const-string p1, "no saved home clock item: plain clock"

    invoke-static {p0, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 127
    return-object v5

    .line 130
    :cond_21
    :try_start_21
    invoke-static/range {v0 .. v7}, Lcom/k4/homeclock/AodClockNode;->create(Landroid/content/Context;IILcom/k4/homeclock/HomeClockItem;Landroid/graphics/Bitmap;Lcom/k4/homeclock/ClockNode;Li3/c;Lh3/a;)Lcom/k4/homeclock/AodClockNode;

    move-result-object p0
    :try_end_25
    .catchall {:try_start_21 .. :try_end_25} :catchall_26

    return-object p0

    .line 131
    :catchall_26
    move-exception v0

    move-object p1, v0

    .line 132
    instance-of p2, p1, Ljava/lang/reflect/InvocationTargetException;

    if-eqz p2, :cond_36

    invoke-virtual {p1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object p2

    if-eqz p2, :cond_36

    invoke-virtual {p1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object p1

    .line 133
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

    .line 134
    return-object v5
.end method

.method public static onCreate(Lf3/a;)V
    .registers 5

    .line 226
    :try_start_0
    invoke-virtual {p0}, Lf3/a;->getWhich()I

    move-result v0

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->homeCapable(I)Z

    move-result v0

    if-nez v0, :cond_b

    .line 227
    return-void

    .line 229
    :cond_b
    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->states()[Lcom/k4/homeclock/EngineState;

    move-result-object v0

    array-length v1, v0

    const/4 v2, 0x0

    :goto_11
    if-ge v2, v1, :cond_1b

    aget-object v3, v0, v2

    .line 230
    invoke-virtual {v3}, Lcom/k4/homeclock/EngineState;->newEngine()V

    .line 229
    add-int/lit8 v2, v2, 0x1

    goto :goto_11

    .line 232
    :cond_1b
    iget-object v0, p0, Lf3/a;->g:Lh3/a;

    instance-of v0, v0, Lcom/k4/homeclock/HomeClockPresenter;
    :try_end_1f
    .catchall {:try_start_0 .. :try_end_1f} :catchall_87

    if-eqz v0, :cond_72

    .line 238
    :try_start_21
    invoke-virtual {p0}, Lf3/a;->d()Z
    :try_end_24
    .catchall {:try_start_21 .. :try_end_24} :catchall_25

    .line 241
    goto :goto_2d

    .line 239
    :catchall_25
    move-exception v0

    .line 240
    :try_start_26
    const-string v1, "K4HomeClock"

    const-string v2, "dark mode dim"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_2d
    .catchall {:try_start_26 .. :try_end_2d} :catchall_87

    .line 243
    :goto_2d
    :try_start_2d
    iget-object v0, p0, Lf3/a;->h:Li3/k;

    if-eqz v0, :cond_62

    iget-object v0, p0, Lf3/a;->h:Li3/k;

    iget-object v0, v0, Li3/k;->c:Ljava/util/ArrayList;

    if-eqz v0, :cond_62

    iget-object v0, p0, Lf3/a;->j:Li3/e;

    if-eqz v0, :cond_62

    iget-object v0, p0, Lf3/a;->h:Li3/k;

    iget-object v0, v0, Li3/k;->c:Ljava/util/ArrayList;

    iget-object v1, p0, Lf3/a;->j:Li3/e;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_62

    .line 244
    iget-object v0, p0, Lf3/a;->h:Li3/k;

    iget-object v0, v0, Li3/k;->c:Ljava/util/ArrayList;

    new-instance v1, Lcom/k4/homeclock/HomeDepthClock$PostDim;

    invoke-direct {v1, p0}, Lcom/k4/homeclock/HomeDepthClock$PostDim;-><init>(Lf3/a;)V

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 245
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->POST_DIM:Ljava/util/Map;

    monitor-enter v0
    :try_end_56
    .catchall {:try_start_2d .. :try_end_56} :catchall_6a

    .line 246
    :try_start_56
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->POST_DIM:Ljava/util/Map;

    sget-object v2, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-interface {v1, p0, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 247
    monitor-exit v0

    goto :goto_69

    :catchall_5f
    move-exception v1

    monitor-exit v0
    :try_end_61
    .catchall {:try_start_56 .. :try_end_61} :catchall_5f

    :try_start_61
    throw v1

    .line 249
    :cond_62
    const-string v0, "K4HomeClock"

    const-string v1, "no DarkModeNode in the engine\'s node list: clock drawn under the dark mode dim"

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_69
    .catchall {:try_start_61 .. :try_end_69} :catchall_6a

    .line 253
    :goto_69
    goto :goto_72

    .line 251
    :catchall_6a
    move-exception v0

    .line 252
    :try_start_6b
    const-string v1, "K4HomeClock"

    const-string v2, "post-dim node"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 255
    :cond_72
    :goto_72
    new-instance v0, Lcom/k4/homeclock/EngineState;

    invoke-direct {v0, p0}, Lcom/k4/homeclock/EngineState;-><init>(Lf3/a;)V

    .line 256
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v1
    :try_end_7a
    .catchall {:try_start_6b .. :try_end_7a} :catchall_87

    .line 257
    :try_start_7a
    sget-object v2, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    invoke-interface {v2, p0, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 258
    monitor-exit v1
    :try_end_80
    .catchall {:try_start_7a .. :try_end_80} :catchall_84

    .line 259
    :try_start_80
    invoke-virtual {v0}, Lcom/k4/homeclock/EngineState;->start()V
    :try_end_83
    .catchall {:try_start_80 .. :try_end_83} :catchall_87

    .line 262
    goto :goto_8f

    .line 258
    :catchall_84
    move-exception p0

    :try_start_85
    monitor-exit v1
    :try_end_86
    .catchall {:try_start_85 .. :try_end_86} :catchall_84

    :try_start_86
    throw p0
    :try_end_87
    .catchall {:try_start_86 .. :try_end_87} :catchall_87

    .line 260
    :catchall_87
    move-exception p0

    .line 261
    const-string v0, "K4HomeClock"

    const-string v1, "onCreate"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 263
    :goto_8f
    return-void
.end method

.method public static onDestroy(Lf3/a;)V
    .registers 4

    .line 282
    :try_start_0
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0
    :try_end_3
    .catchall {:try_start_0 .. :try_end_3} :catchall_21

    .line 283
    :try_start_3
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    invoke-interface {v1, p0}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/k4/homeclock/EngineState;

    .line 284
    monitor-exit v0
    :try_end_c
    .catchall {:try_start_3 .. :try_end_c} :catchall_1e

    .line 285
    :try_start_c
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->POST_DIM:Ljava/util/Map;

    monitor-enter v0
    :try_end_f
    .catchall {:try_start_c .. :try_end_f} :catchall_21

    .line 286
    :try_start_f
    sget-object v2, Lcom/k4/homeclock/HomeDepthClock;->POST_DIM:Ljava/util/Map;

    invoke-interface {v2, p0}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    .line 287
    monitor-exit v0
    :try_end_15
    .catchall {:try_start_f .. :try_end_15} :catchall_1b

    .line 288
    if-eqz v1, :cond_1a

    .line 289
    :try_start_17
    invoke-virtual {v1}, Lcom/k4/homeclock/EngineState;->stop()V
    :try_end_1a
    .catchall {:try_start_17 .. :try_end_1a} :catchall_21

    .line 293
    :cond_1a
    goto :goto_29

    .line 287
    :catchall_1b
    move-exception p0

    :try_start_1c
    monitor-exit v0
    :try_end_1d
    .catchall {:try_start_1c .. :try_end_1d} :catchall_1b

    :try_start_1d
    throw p0
    :try_end_1e
    .catchall {:try_start_1d .. :try_end_1e} :catchall_21

    .line 284
    :catchall_1e
    move-exception p0

    :try_start_1f
    monitor-exit v0
    :try_end_20
    .catchall {:try_start_1f .. :try_end_20} :catchall_1e

    :try_start_20
    throw p0
    :try_end_21
    .catchall {:try_start_20 .. :try_end_21} :catchall_21

    .line 291
    :catchall_21
    move-exception p0

    .line 292
    const-string v0, "K4HomeClock"

    const-string v1, "onDestroy"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 294
    :goto_29
    return-void
.end method

.method public static onVisibility(Lf3/a;Z)V
    .registers 4

    .line 268
    :try_start_0
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0
    :try_end_3
    .catchall {:try_start_0 .. :try_end_3} :catchall_15

    .line 269
    :try_start_3
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    invoke-interface {v1, p0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/k4/homeclock/EngineState;

    .line 270
    monitor-exit v0
    :try_end_c
    .catchall {:try_start_3 .. :try_end_c} :catchall_12

    .line 271
    if-eqz p0, :cond_11

    .line 272
    :try_start_e
    invoke-virtual {p0, p1}, Lcom/k4/homeclock/EngineState;->setVisible(Z)V
    :try_end_11
    .catchall {:try_start_e .. :try_end_11} :catchall_15

    .line 276
    :cond_11
    goto :goto_1d

    .line 270
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

    .line 274
    :catchall_15
    move-exception p0

    .line 275
    const-string p1, "K4HomeClock"

    const-string v0, "onVisibility"

    invoke-static {p1, v0, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 277
    :goto_1d
    return-void
.end method

.method static postDimInstalled(Lh3/a;)Z
    .registers 4

    .line 207
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->POST_DIM:Ljava/util/Map;

    monitor-enter v0

    .line 208
    :try_start_3
    sget-object v1, Lcom/k4/homeclock/HomeDepthClock;->POST_DIM:Ljava/util/Map;

    invoke-interface {v1}, Ljava/util/Map;->keySet()Ljava/util/Set;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_d
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_23

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lf3/a;

    .line 209
    if-eqz v2, :cond_22

    iget-object v2, v2, Lf3/a;->g:Lh3/a;

    if-ne v2, p0, :cond_22

    .line 210
    monitor-exit v0

    const/4 p0, 0x1

    return p0

    .line 212
    :cond_22
    goto :goto_d

    .line 213
    :cond_23
    monitor-exit v0

    .line 214
    const/4 p0, 0x0

    return p0

    .line 213
    :catchall_26
    move-exception p0

    monitor-exit v0
    :try_end_28
    .catchall {:try_start_3 .. :try_end_28} :catchall_26

    throw p0
.end method

.method public static presenter(Lh3/a;Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)Lh3/a;
    .registers 7

    .line 77
    const-string v0, "K4HomeClock"

    and-int/lit8 v1, p2, 0x3

    const/4 v2, 0x1

    if-ne v1, v2, :cond_37

    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->enabled()Z

    move-result v1

    if-nez v1, :cond_e

    goto :goto_37

    .line 81
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

    .line 82
    new-instance v1, Lcom/k4/homeclock/HomeClockPresenter;

    invoke-direct {v1, p1, p2, p3}, Lcom/k4/homeclock/HomeClockPresenter;-><init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V
    :try_end_2f
    .catchall {:try_start_e .. :try_end_2f} :catchall_30

    return-object v1

    .line 83
    :catchall_30
    move-exception p1

    .line 84
    const-string p2, "presenter: falling back to stock"

    invoke-static {v0, p2, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 85
    return-object p0

    .line 78
    :cond_37
    :goto_37
    return-object p0
.end method

.method static prop(Ljava/lang/String;)Ljava/lang/String;
    .registers 2

    .line 50
    const-string v0, ""

    :try_start_2
    invoke-static {p0}, Landroid/os/SemSystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    .line 51
    if-nez p0, :cond_9

    goto :goto_d

    :cond_9
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0
    :try_end_d
    .catchall {:try_start_2 .. :try_end_d} :catchall_e

    :goto_d
    return-object v0

    .line 52
    :catchall_e
    move-exception p0

    .line 53
    return-object v0
.end method

.method static redrawStale(Ljava/lang/String;)V
    .registers 5

    .line 219
    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->states()[Lcom/k4/homeclock/EngineState;

    move-result-object v0

    array-length v1, v0

    const/4 v2, 0x0

    :goto_6
    if-ge v2, v1, :cond_10

    aget-object v3, v0, v2

    .line 220
    invoke-virtual {v3, p0}, Lcom/k4/homeclock/EngineState;->redrawIfStale(Ljava/lang/String;)V

    .line 219
    add-int/lit8 v2, v2, 0x1

    goto :goto_6

    .line 222
    :cond_10
    return-void
.end method

.method static setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V
    .registers 4

    .line 140
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->CLOCKS:Ljava/util/Map;

    monitor-enter v0

    .line 141
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

    .line 142
    monitor-exit v0
    :try_end_15
    .catchall {:try_start_5 .. :try_end_15} :catchall_26

    .line 143
    if-eqz p0, :cond_25

    if-eq p0, p1, :cond_25

    .line 145
    :try_start_19
    invoke-virtual {p0}, Lcom/k4/homeclock/DepthClock;->release()V
    :try_end_1c
    .catchall {:try_start_19 .. :try_end_1c} :catchall_1d

    .line 148
    goto :goto_25

    .line 146
    :catchall_1d
    move-exception p0

    .line 147
    const-string p1, "K4HomeClock"

    const-string v0, "release"

    invoke-static {p1, v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 150
    :cond_25
    :goto_25
    return-void

    .line 142
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

    .line 67
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

    .line 170
    sget-object v0, Lcom/k4/homeclock/HomeDepthClock;->ENGINES:Ljava/util/Map;

    monitor-enter v0

    .line 171
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

    .line 172
    :catchall_14
    move-exception v1

    monitor-exit v0
    :try_end_16
    .catchall {:try_start_3 .. :try_end_16} :catchall_14

    throw v1
.end method
