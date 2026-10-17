.class final Lcom/k4/homeclock/AodClockNode;
.super Lcom/k4/homeclock/DepthClock;
.source "AodClockNode.java"


# instance fields
.field private final areaColor:I

.field private builtFor:Ljava/lang/String;

.field private clock:Landroid/view/View;

.field private volatile failed:Z

.field private final fallback:Lcom/k4/homeclock/ClockNode;

.field private final fontColorType:I

.field private final h:I

.field private host:Lcom/k4/homeclock/AodHost;

.field private final item:Lcom/k4/homeclock/HomeClockItem;

.field private left:F

.field private loggedPlacement:Z

.field private scale:F

.field private top:F

.field private final w:I


# direct methods
.method private constructor <init>(Landroid/content/Context;IILcom/k4/homeclock/HomeClockItem;Landroid/graphics/Bitmap;Lcom/k4/homeclock/ClockNode;Li3/c;Lh3/a;)V
    .registers 11

    .line 45
    const-string v0, "K4AodClockNode"

    invoke-direct {p0, p1, v0, p7, p8}, Lcom/k4/homeclock/DepthClock;-><init>(Landroid/content/Context;Ljava/lang/String;Li3/c;Lh3/a;)V

    .line 39
    const-string p7, ""

    iput-object p7, p0, Lcom/k4/homeclock/AodClockNode;->builtFor:Ljava/lang/String;

    .line 46
    iput-object p4, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    .line 47
    iput-object p6, p0, Lcom/k4/homeclock/AodClockNode;->fallback:Lcom/k4/homeclock/ClockNode;

    .line 48
    iput p2, p0, Lcom/k4/homeclock/AodClockNode;->w:I

    .line 49
    iput p3, p0, Lcom/k4/homeclock/AodClockNode;->h:I

    .line 50
    invoke-static {p1, p2, p3}, Lcom/k4/homeclock/AodClockNode;->screenFactors(Landroid/content/Context;II)[F

    move-result-object p1

    .line 51
    iget-object p2, p4, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    iget p2, p2, Landroid/graphics/Rect;->left:I

    int-to-float p2, p2

    const/4 p3, 0x0

    aget p6, p1, p3

    mul-float/2addr p2, p6

    invoke-static {p2}, Ljava/lang/Math;->round(F)I

    move-result p2

    .line 52
    iget-object p6, p4, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    iget p6, p6, Landroid/graphics/Rect;->top:I

    int-to-float p6, p6

    const/4 p7, 0x1

    aget p8, p1, p7

    mul-float/2addr p6, p8

    invoke-static {p6}, Ljava/lang/Math;->round(F)I

    move-result p6

    .line 53
    iget-object p8, p4, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    iget p8, p8, Landroid/graphics/Rect;->right:I

    int-to-float p8, p8

    aget v0, p1, p3

    mul-float/2addr p8, v0

    invoke-static {p8}, Ljava/lang/Math;->round(F)I

    move-result p8

    .line 54
    iget-object v0, p4, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    iget v0, v0, Landroid/graphics/Rect;->bottom:I

    int-to-float v0, v0

    aget p1, p1, p7

    mul-float/2addr v0, p1

    invoke-static {v0}, Ljava/lang/Math;->round(F)I

    move-result p1

    .line 55
    invoke-static {p5, p2, p6, p8, p1}, Lcom/k4/homeclock/AodClockNode;->luminance(Landroid/graphics/Bitmap;IIII)F

    move-result v0

    .line 58
    iget-object v1, p4, Lcom/k4/homeclock/HomeClockItem;->fontColorType:Ljava/lang/Integer;

    if-eqz v1, :cond_56

    iget-object p3, p4, Lcom/k4/homeclock/HomeClockItem;->fontColorType:Ljava/lang/Integer;

    invoke-virtual {p3}, Ljava/lang/Integer;->intValue()I

    move-result p3

    goto :goto_5e

    :cond_56
    const p4, 0x3f19999a    # 0.6f

    cmpl-float p4, v0, p4

    if-lez p4, :cond_5e

    move p3, p7

    :cond_5e
    :goto_5e
    iput p3, p0, Lcom/k4/homeclock/AodClockNode;->fontColorType:I

    .line 59
    invoke-static {p5, p2, p6, p8, p1}, Lcom/k4/homeclock/AodClockNode;->meanColor(Landroid/graphics/Bitmap;IIII)I

    move-result p1

    iput p1, p0, Lcom/k4/homeclock/AodClockNode;->areaColor:I

    .line 60
    return-void
.end method

.method private static varargs call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;
    .registers 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Object;",
            "Ljava/lang/String;",
            "[",
            "Ljava/lang/Class<",
            "*>;[",
            "Ljava/lang/Object;",
            ")",
            "Ljava/lang/Object;"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 275
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v0, p1, p2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p1

    .line 276
    invoke-virtual {p1, p0, p3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method private config()Ljava/lang/String;
    .registers 5

    .line 92
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v0

    invoke-static {}, Ljava/util/TimeZone;->getDefault()Ljava/util/TimeZone;

    move-result-object v1

    invoke-virtual {v1}, Ljava/util/TimeZone;->getID()Ljava/lang/String;

    move-result-object v1

    iget-object v2, p0, Lcom/k4/homeclock/AodClockNode;->a:Landroid/content/Context;

    .line 93
    invoke-static {v2}, Landroid/text/format/DateFormat;->is24HourFormat(Landroid/content/Context;)Z

    move-result v2

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, "|"

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 92
    return-object v0
.end method

.method private configure(Landroid/view/View;)V
    .registers 12
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 108
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->host:Lcom/k4/homeclock/AodHost;

    const-string v1, "com.samsung.android.clockpack.plugins.clock.ClockView"

    invoke-virtual {v0, v1}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    .line 109
    invoke-virtual {v0, p1}, Ljava/lang/Class;->isInstance(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_279

    .line 113
    sget-object v0, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    const/4 v1, 0x0

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    const-string v3, "setDozing"

    invoke-static {p1, v3, v0, v2}, Lcom/k4/homeclock/AodClockNode;->opt(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)V

    .line 114
    sget-object v0, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    const/4 v2, 0x0

    invoke-static {v2}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v2

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    const-string v3, "setDozeAmount"

    invoke-static {p1, v3, v0, v2}, Lcom/k4/homeclock/AodClockNode;->opt(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)V

    .line 115
    sget-object v0, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    const-string v3, "setAnimationAllowed"

    invoke-static {p1, v3, v0, v2}, Lcom/k4/homeclock/AodClockNode;->opt(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)V

    .line 116
    sget-object v0, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    const-string v3, "setShowWeatherInformation"

    invoke-static {p1, v3, v0, v2}, Lcom/k4/homeclock/AodClockNode;->opt(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)V

    .line 117
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v0, v0, Lcom/k4/homeclock/HomeClockItem;->fontIndex:Ljava/lang/Integer;

    if-eqz v0, :cond_10a

    .line 118
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->host:Lcom/k4/homeclock/AodHost;

    const-string v2, "com.samsung.android.clockpack.plugins.clock.extension.FontExtension"

    invoke-virtual {v0, v2}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    .line 119
    invoke-virtual {v0, p1}, Ljava/lang/Class;->isInstance(Ljava/lang/Object;)Z

    move-result v2

    const-string v3, "setFontType"

    if-eqz v2, :cond_d7

    .line 120
    iget-object v2, p0, Lcom/k4/homeclock/AodClockNode;->host:Lcom/k4/homeclock/AodHost;

    const-string v4, "com.samsung.android.clockpack.plugins.clock.ClockFontData"

    invoke-virtual {v2, v4}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v2

    .line 121
    sget-object v4, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const-class v5, Ljava/lang/String;

    const-class v6, Ljava/lang/Integer;

    const-class v7, Ljava/lang/Integer;

    const-class v8, Ljava/util/List;

    filled-new-array {v4, v5, v6, v7, v8}, [Ljava/lang/Class;

    move-result-object v4

    invoke-virtual {v2, v4}, Ljava/lang/Class;->getConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v4

    iget-object v5, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v5, v5, Lcom/k4/homeclock/HomeClockItem;->fontIndex:Ljava/lang/Integer;

    iget-object v6, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v6, v6, Lcom/k4/homeclock/HomeClockItem;->fontPath:Ljava/lang/String;

    .line 123
    iget-object v7, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v7, v7, Lcom/k4/homeclock/HomeClockItem;->fontWeight:Ljava/lang/Integer;

    const/4 v8, -0x1

    if-eqz v7, :cond_a0

    iget-object v7, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v7, v7, Lcom/k4/homeclock/HomeClockItem;->fontWeight:Ljava/lang/Integer;

    goto :goto_a4

    :cond_a0
    invoke-static {v8}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    .line 124
    :goto_a4
    iget-object v9, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v9, v9, Lcom/k4/homeclock/HomeClockItem;->fontRounded:Ljava/lang/Integer;

    if-eqz v9, :cond_af

    iget-object v8, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v8, v8, Lcom/k4/homeclock/HomeClockItem;->fontRounded:Ljava/lang/Integer;

    goto :goto_b3

    :cond_af
    invoke-static {v8}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v8

    .line 125
    :goto_b3
    invoke-direct {p0}, Lcom/k4/homeclock/AodClockNode;->stretchable()Z

    move-result v9

    if-eqz v9, :cond_be

    iget-object v9, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v9, v9, Lcom/k4/homeclock/HomeClockItem;->fontHeights:Ljava/util/List;

    goto :goto_bf

    :cond_be
    const/4 v9, 0x0

    :goto_bf
    filled-new-array {v5, v6, v7, v8, v9}, [Ljava/lang/Object;

    move-result-object v5

    .line 122
    invoke-virtual {v4, v5}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    .line 126
    filled-new-array {v2}, [Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {v0, v3, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    filled-new-array {v4}, [Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {v0, p1, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 127
    goto :goto_10a

    :cond_d7
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v0, v0, Lcom/k4/homeclock/HomeClockItem;->fontPath:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_f3

    .line 128
    sget-object v0, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    iget-object v2, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v2, v2, Lcom/k4/homeclock/HomeClockItem;->fontIndex:Ljava/lang/Integer;

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    invoke-static {p1, v3, v0, v2}, Lcom/k4/homeclock/AodClockNode;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_10a

    .line 130
    :cond_f3
    sget-object v0, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const-class v2, Ljava/lang/String;

    filled-new-array {v0, v2}, [Ljava/lang/Class;

    move-result-object v0

    iget-object v2, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v2, v2, Lcom/k4/homeclock/HomeClockItem;->fontIndex:Ljava/lang/Integer;

    iget-object v4, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v4, v4, Lcom/k4/homeclock/HomeClockItem;->fontPath:Ljava/lang/String;

    filled-new-array {v2, v4}, [Ljava/lang/Object;

    move-result-object v2

    invoke-static {p1, v3, v0, v2}, Lcom/k4/homeclock/AodClockNode;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 133
    :cond_10a
    :goto_10a
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->a:Landroid/content/Context;

    iget v2, p0, Lcom/k4/homeclock/AodClockNode;->w:I

    iget v3, p0, Lcom/k4/homeclock/AodClockNode;->h:I

    invoke-static {v0, v2, v3}, Lcom/k4/homeclock/AodClockNode;->screenFactors(Landroid/content/Context;II)[F

    move-result-object v0

    .line 134
    iget v2, p0, Lcom/k4/homeclock/AodClockNode;->w:I

    int-to-float v2, v2

    aget v0, v0, v1

    div-float/2addr v2, v0

    invoke-static {v2}, Ljava/lang/Math;->round(F)I

    move-result v0

    .line 135
    iget-object v2, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v2, v2, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    iget v2, v2, Landroid/graphics/Rect;->left:I

    iget-object v3, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v3, v3, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    iget v3, v3, Landroid/graphics/Rect;->right:I

    sub-int v3, v0, v3

    invoke-static {v2, v3}, Ljava/lang/Math;->min(II)I

    move-result v2

    invoke-static {v1, v2}, Ljava/lang/Math;->max(II)I

    move-result v2

    .line 136
    mul-int/lit8 v2, v2, 0x2

    sub-int/2addr v0, v2

    int-to-float v0, v0

    iget-object v2, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget v2, v2, Lcom/k4/homeclock/HomeClockItem;->scale:F

    div-float/2addr v0, v2

    invoke-static {v0}, Ljava/lang/Math;->round(F)I

    move-result v0

    .line 137
    if-lez v0, :cond_156

    .line 138
    sget-object v2, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v2}, [Ljava/lang/Class;

    move-result-object v2

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    filled-new-array {v0}, [Ljava/lang/Object;

    move-result-object v0

    const-string v3, "setClockMaxWidth"

    invoke-static {p1, v3, v2, v0}, Lcom/k4/homeclock/AodClockNode;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 140
    :cond_156
    sget-object v0, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    iget-object v2, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-boolean v2, v2, Lcom/k4/homeclock/HomeClockItem;->showDateFirst:Z

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    const-string v3, "setShowDateInfoFirst"

    invoke-static {p1, v3, v0, v2}, Lcom/k4/homeclock/AodClockNode;->opt(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)V

    .line 141
    iget v0, p0, Lcom/k4/homeclock/AodClockNode;->areaColor:I

    if-eqz v0, :cond_186

    .line 142
    sget-object v0, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    iget v2, p0, Lcom/k4/homeclock/AodClockNode;->areaColor:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    const-string v3, "setClockAreaWallpaperColor"

    invoke-static {p1, v3, v0, v2}, Lcom/k4/homeclock/AodClockNode;->opt(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)V

    .line 144
    :cond_186
    sget-object v0, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    iget v2, p0, Lcom/k4/homeclock/AodClockNode;->fontColorType:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    const-string v3, "setFontColorType"

    invoke-static {p1, v3, v0, v2}, Lcom/k4/homeclock/AodClockNode;->opt(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)V

    .line 145
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v0, v0, Lcom/k4/homeclock/HomeClockItem;->colorType:Ljava/lang/String;

    .line 146
    const-string v2, "Adaptive"

    invoke-virtual {v0, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_237

    .line 147
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v0, v0, Lcom/k4/homeclock/HomeClockItem;->color:Ljava/lang/Integer;

    if-eqz v0, :cond_1b6

    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v0, v0, Lcom/k4/homeclock/HomeClockItem;->color:Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    goto :goto_1c8

    .line 148
    :cond_1b6
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->a:Landroid/content/Context;

    iget v2, p0, Lcom/k4/homeclock/AodClockNode;->fontColorType:I

    const/4 v3, 0x1

    if-ne v2, v3, :cond_1c1

    const v2, 0x1060041

    goto :goto_1c4

    :cond_1c1
    const v2, 0x106003a

    :goto_1c4
    invoke-virtual {v0, v2}, Landroid/content/Context;->getColor(I)I

    move-result v0

    .line 149
    :goto_1c8
    sget-object v2, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v2}, [Ljava/lang/Class;

    move-result-object v2

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    filled-new-array {v0}, [Ljava/lang/Object;

    move-result-object v0

    const-string v3, "setColorThemeAdaptiveColor"

    invoke-static {p1, v3, v2, v0}, Lcom/k4/homeclock/AodClockNode;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 150
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-boolean v0, v0, Lcom/k4/homeclock/HomeClockItem;->hasShadow:Z

    if-eqz v0, :cond_236

    .line 151
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->host:Lcom/k4/homeclock/AodHost;

    const-string v2, "com.samsung.android.clockpack.plugins.clock.ShadowStyle"

    invoke-virtual {v0, v2}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    .line 152
    new-array v2, v1, [Ljava/lang/Class;

    invoke-virtual {v0, v2}, Ljava/lang/Class;->getConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v2

    new-array v1, v1, [Ljava/lang/Object;

    invoke-virtual {v2, v1}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    .line 153
    const-string v2, "shadowColor"

    invoke-virtual {v0, v2}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    iget-object v3, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget v3, v3, Lcom/k4/homeclock/HomeClockItem;->shadowColor:I

    invoke-virtual {v2, v1, v3}, Ljava/lang/reflect/Field;->setInt(Ljava/lang/Object;I)V

    .line 154
    const-string v2, "shadowRadius"

    invoke-virtual {v0, v2}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    iget-object v3, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget v3, v3, Lcom/k4/homeclock/HomeClockItem;->shadowRadius:F

    invoke-virtual {v2, v1, v3}, Ljava/lang/reflect/Field;->setFloat(Ljava/lang/Object;F)V

    .line 155
    const-string v2, "shadowDx"

    invoke-virtual {v0, v2}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    iget-object v3, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget v3, v3, Lcom/k4/homeclock/HomeClockItem;->shadowDx:F

    invoke-virtual {v2, v1, v3}, Ljava/lang/reflect/Field;->setFloat(Ljava/lang/Object;F)V

    .line 156
    const-string v2, "shadowDy"

    invoke-virtual {v0, v2}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    iget-object v3, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget v3, v3, Lcom/k4/homeclock/HomeClockItem;->shadowDy:F

    invoke-virtual {v2, v1, v3}, Ljava/lang/reflect/Field;->setFloat(Ljava/lang/Object;F)V

    .line 157
    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    filled-new-array {v1}, [Ljava/lang/Object;

    move-result-object v1

    const-string v2, "setShadowStyle"

    invoke-static {p1, v2, v0, v1}, Lcom/k4/homeclock/AodClockNode;->opt(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)V

    .line 159
    :cond_236
    goto :goto_278

    :cond_237
    const-string v2, "StaticColorImpl"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_259

    iget-object v2, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v2, v2, Lcom/k4/homeclock/HomeClockItem;->color:Ljava/lang/Integer;

    if-eqz v2, :cond_259

    .line 160
    sget-object v0, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v0}, [Ljava/lang/Class;

    move-result-object v0

    iget-object v1, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v1, v1, Lcom/k4/homeclock/HomeClockItem;->color:Ljava/lang/Integer;

    filled-new-array {v1}, [Ljava/lang/Object;

    move-result-object v1

    const-string v2, "setCustomColor"

    invoke-static {p1, v2, v0, v1}, Lcom/k4/homeclock/AodClockNode;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_278

    .line 162
    :cond_259
    sget-object v2, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v2}, [Ljava/lang/Class;

    move-result-object v2

    const-string v3, "ClockPresetColorImpl"

    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_26b

    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget v1, v0, Lcom/k4/homeclock/HomeClockItem;->presetIndex:I

    :cond_26b
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    filled-new-array {v0}, [Ljava/lang/Object;

    move-result-object v0

    const-string v1, "setPaletteIndex"

    invoke-static {p1, v1, v2, v0}, Lcom/k4/homeclock/AodClockNode;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 164
    :goto_278
    return-void

    .line 110
    :cond_279
    new-instance v0, Ljava/lang/IllegalStateException;

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "not a ClockView: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {v0, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method static create(Landroid/content/Context;IILcom/k4/homeclock/HomeClockItem;Landroid/graphics/Bitmap;Lcom/k4/homeclock/ClockNode;Li3/c;Lh3/a;)Lcom/k4/homeclock/AodClockNode;
    .registers 18
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 65
    new-instance v1, Lcom/k4/homeclock/AodClockNode;

    move-object v2, p0

    move v3, p1

    move v4, p2

    move-object v5, p3

    move-object v6, p4

    move-object v7, p5

    move-object/from16 v8, p6

    move-object/from16 v9, p7

    invoke-direct/range {v1 .. v9}, Lcom/k4/homeclock/AodClockNode;-><init>(Landroid/content/Context;IILcom/k4/homeclock/HomeClockItem;Landroid/graphics/Bitmap;Lcom/k4/homeclock/ClockNode;Li3/c;Lh3/a;)V

    .line 67
    :try_start_f
    invoke-static {p0}, Lcom/k4/homeclock/AodHost;->acquire(Landroid/content/Context;)Lcom/k4/homeclock/AodHost;

    move-result-object p0

    iput-object p0, v1, Lcom/k4/homeclock/AodClockNode;->host:Lcom/k4/homeclock/AodHost;

    .line 68
    invoke-direct {v1}, Lcom/k4/homeclock/AodClockNode;->inflate()V

    .line 69
    const/4 p0, 0x1

    invoke-direct {v1, p0}, Lcom/k4/homeclock/AodClockNode;->place(Z)V
    :try_end_1c
    .catchall {:try_start_f .. :try_end_1c} :catchall_1e

    .line 76
    nop

    .line 77
    return-object v1

    .line 70
    :catchall_1e
    move-exception v0

    move-object p0, v0

    .line 71
    invoke-virtual {v1}, Lcom/k4/homeclock/AodClockNode;->release()V

    .line 72
    instance-of p1, p0, Ljava/lang/Exception;

    if-eqz p1, :cond_2a

    .line 73
    check-cast p0, Ljava/lang/Exception;

    throw p0

    .line 75
    :cond_2a
    new-instance p1, Ljava/lang/RuntimeException;

    invoke-direct {p1, p0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/Throwable;)V

    throw p1
.end method

.method private inflate()V
    .registers 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 97
    invoke-direct {p0}, Lcom/k4/homeclock/AodClockNode;->config()Ljava/lang/String;

    move-result-object v0

    .line 98
    iget-object v1, p0, Lcom/k4/homeclock/AodClockNode;->host:Lcom/k4/homeclock/AodHost;

    iget-object v2, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget v2, v2, Lcom/k4/homeclock/HomeClockItem;->clockType:I

    invoke-virtual {v1, v2}, Lcom/k4/homeclock/AodHost;->clockView(I)Landroid/view/View;

    move-result-object v1

    .line 99
    invoke-direct {p0, v1}, Lcom/k4/homeclock/AodClockNode;->configure(Landroid/view/View;)V

    .line 100
    iput-object v1, p0, Lcom/k4/homeclock/AodClockNode;->clock:Landroid/view/View;

    .line 101
    iput-object v0, p0, Lcom/k4/homeclock/AodClockNode;->builtFor:Ljava/lang/String;

    .line 102
    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v0

    iget-object v1, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    invoke-static {v1}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    iget v2, p0, Lcom/k4/homeclock/AodClockNode;->fontColorType:I

    iget v3, p0, Lcom/k4/homeclock/AodClockNode;->areaColor:I

    .line 103
    invoke-static {v3}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    move-result-object v3

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "AOD clock view "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v4, " ("

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "), fontColorType="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", areaColor=#"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 102
    const-string v1, "K4HomeClock"

    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 104
    return-void
.end method

.method private static varargs opt(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)V
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Object;",
            "Ljava/lang/String;",
            "[",
            "Ljava/lang/Class<",
            "*>;[",
            "Ljava/lang/Object;",
            ")V"
        }
    .end annotation

    .line 282
    :try_start_0
    invoke-static {p0, p1, p2, p3}, Lcom/k4/homeclock/AodClockNode;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_3
    .catchall {:try_start_0 .. :try_end_3} :catchall_4

    .line 285
    goto :goto_2b

    .line 283
    :catchall_4
    move-exception p0

    .line 284
    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string p3, "AOD clock: "

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p2, " failed: "

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string p1, "K4HomeClock"

    invoke-static {p1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 286
    :goto_2b
    return-void
.end method

.method private place(Z)V
    .registers 12
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 179
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->clock:Landroid/view/View;

    .line 180
    const/4 v1, 0x0

    new-array v2, v1, [Ljava/lang/Class;

    new-array v3, v1, [Ljava/lang/Object;

    const-string v4, "stopSpringAnimation"

    invoke-static {v0, v4, v2, v3}, Lcom/k4/homeclock/AodClockNode;->opt(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)V

    .line 181
    sget-object v2, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    filled-new-array {v2}, [Ljava/lang/Class;

    move-result-object v2

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v3

    invoke-static {v3, v4}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    filled-new-array {v3}, [Ljava/lang/Object;

    move-result-object v3

    const-string v4, "forceRefresh"

    invoke-static {v0, v4, v2, v3}, Lcom/k4/homeclock/AodClockNode;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 182
    invoke-static {v1, v1}, Landroid/view/View$MeasureSpec;->makeMeasureSpec(II)I

    move-result v2

    .line 183
    invoke-virtual {v0, v2, v2}, Landroid/view/View;->measure(II)V

    .line 184
    invoke-virtual {v0}, Landroid/view/View;->getMeasuredWidth()I

    move-result v2

    .line 185
    invoke-virtual {v0}, Landroid/view/View;->getMeasuredHeight()I

    move-result v3

    .line 186
    const-string v4, "x"

    if-lez v2, :cond_114

    if-lez v3, :cond_114

    .line 189
    invoke-virtual {v0, v1, v1, v2, v3}, Landroid/view/View;->layout(IIII)V

    .line 190
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->a:Landroid/content/Context;

    iget v5, p0, Lcom/k4/homeclock/AodClockNode;->w:I

    iget v6, p0, Lcom/k4/homeclock/AodClockNode;->h:I

    invoke-static {v0, v5, v6}, Lcom/k4/homeclock/AodClockNode;->screenFactors(Landroid/content/Context;II)[F

    move-result-object v0

    .line 191
    iget-object v5, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget v5, v5, Lcom/k4/homeclock/HomeClockItem;->scale:F

    aget v6, v0, v1

    mul-float/2addr v5, v6

    iput v5, p0, Lcom/k4/homeclock/AodClockNode;->scale:F

    .line 192
    iget-object v5, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v5, v5, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    invoke-virtual {v5}, Landroid/graphics/Rect;->width()I

    move-result v5

    int-to-float v5, v5

    aget v6, v0, v1

    mul-float/2addr v5, v6

    .line 193
    iget-object v6, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v6, v6, Lcom/k4/homeclock/HomeClockItem;->gravityX:Ljava/lang/String;

    const-string v7, "Center"

    invoke-virtual {v7, v6}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v6

    if-eqz v6, :cond_69

    const/high16 v6, 0x3f000000    # 0.5f

    goto :goto_79

    :cond_69
    iget-object v6, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v6, v6, Lcom/k4/homeclock/HomeClockItem;->gravityX:Ljava/lang/String;

    const-string v7, "End"

    invoke-virtual {v7, v6}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v6

    if-eqz v6, :cond_78

    const/high16 v6, 0x3f800000    # 1.0f

    goto :goto_79

    :cond_78
    const/4 v6, 0x0

    .line 194
    :goto_79
    iget-object v7, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v7, v7, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    iget v7, v7, Landroid/graphics/Rect;->left:I

    int-to-float v7, v7

    aget v1, v0, v1

    mul-float/2addr v7, v1

    int-to-float v1, v2

    iget v8, p0, Lcom/k4/homeclock/AodClockNode;->scale:F

    mul-float/2addr v1, v8

    sub-float/2addr v5, v1

    mul-float/2addr v5, v6

    add-float/2addr v7, v5

    iput v7, p0, Lcom/k4/homeclock/AodClockNode;->left:F

    .line 195
    iget-object v1, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v1, v1, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    iget v1, v1, Landroid/graphics/Rect;->top:I

    int-to-float v1, v1

    const/4 v5, 0x1

    aget v0, v0, v5

    mul-float/2addr v1, v0

    iput v1, p0, Lcom/k4/homeclock/AodClockNode;->top:F

    .line 196
    if-nez p1, :cond_9f

    iget-boolean p1, p0, Lcom/k4/homeclock/AodClockNode;->loggedPlacement:Z

    if-nez p1, :cond_113

    .line 197
    :cond_9f
    iput-boolean v5, p0, Lcom/k4/homeclock/AodClockNode;->loggedPlacement:Z

    .line 198
    iget p1, p0, Lcom/k4/homeclock/AodClockNode;->scale:F

    iget v0, p0, Lcom/k4/homeclock/AodClockNode;->left:F

    iget v1, p0, Lcom/k4/homeclock/AodClockNode;->top:F

    iget-object v5, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v5, v5, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    .line 199
    invoke-virtual {v5}, Landroid/graphics/Rect;->toShortString()Ljava/lang/String;

    move-result-object v5

    iget v6, p0, Lcom/k4/homeclock/AodClockNode;->w:I

    iget v7, p0, Lcom/k4/homeclock/AodClockNode;->h:I

    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    const-string v9, "AOD clock placed: measured "

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " x"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v2, " at "

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v0, ","

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v0, " (saved rect "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v0, ", surface "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v0, ")"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 198
    const-string v0, "K4HomeClock"

    invoke-static {v0, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 201
    :cond_113
    return-void

    .line 187
    :cond_114
    new-instance p1, Ljava/lang/IllegalStateException;

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "AOD clock measured "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method private static screenFactors(Landroid/content/Context;II)[F
    .registers 7

    .line 256
    new-instance v0, Landroid/graphics/Point;

    invoke-direct {v0}, Landroid/graphics/Point;-><init>()V

    .line 258
    :try_start_5
    const-class v1, Landroid/view/WindowManager;

    invoke-virtual {p0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/view/WindowManager;

    .line 259
    invoke-interface {p0}, Landroid/view/WindowManager;->getMaximumWindowMetrics()Landroid/view/WindowMetrics;

    move-result-object p0

    invoke-virtual {p0}, Landroid/view/WindowMetrics;->getBounds()Landroid/graphics/Rect;

    move-result-object p0

    .line 260
    invoke-virtual {p0}, Landroid/graphics/Rect;->width()I

    move-result v1

    invoke-virtual {p0}, Landroid/graphics/Rect;->height()I

    move-result p0

    invoke-virtual {v0, v1, p0}, Landroid/graphics/Point;->set(II)V
    :try_end_20
    .catchall {:try_start_5 .. :try_end_20} :catchall_21

    .line 263
    goto :goto_25

    .line 261
    :catchall_21
    move-exception p0

    .line 262
    invoke-virtual {v0, p1, p2}, Landroid/graphics/Point;->set(II)V

    .line 264
    :goto_25
    iget p0, v0, Landroid/graphics/Point;->x:I

    if-lez p0, :cond_2d

    iget p0, v0, Landroid/graphics/Point;->y:I

    if-gtz p0, :cond_30

    .line 265
    :cond_2d
    invoke-virtual {v0, p1, p2}, Landroid/graphics/Point;->set(II)V

    .line 268
    :cond_30
    iget p0, v0, Landroid/graphics/Point;->x:I

    iget v1, v0, Landroid/graphics/Point;->y:I

    const/4 v2, 0x1

    const/4 v3, 0x0

    if-le p0, v1, :cond_3a

    move p0, v2

    goto :goto_3b

    :cond_3a
    move p0, v3

    :goto_3b
    if-le p1, p2, :cond_3f

    move v1, v2

    goto :goto_40

    :cond_3f
    move v1, v3

    :goto_40
    if-eq p0, v1, :cond_49

    .line 269
    iget p0, v0, Landroid/graphics/Point;->y:I

    iget v1, v0, Landroid/graphics/Point;->x:I

    invoke-virtual {v0, p0, v1}, Landroid/graphics/Point;->set(II)V

    .line 271
    :cond_49
    int-to-float p0, p1

    iget p1, v0, Landroid/graphics/Point;->x:I

    int-to-float p1, p1

    div-float/2addr p0, p1

    int-to-float p1, p2

    iget p2, v0, Landroid/graphics/Point;->y:I

    int-to-float p2, p2

    div-float/2addr p1, p2

    const/4 p2, 0x2

    new-array p2, p2, [F

    aput p0, p2, v3

    aput p1, p2, v2

    return-object p2
.end method

.method private stretchable()Z
    .registers 5

    .line 168
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget-object v0, v0, Lcom/k4/homeclock/HomeClockItem;->fontIndex:Ljava/lang/Integer;

    .line 169
    iget-object v1, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget v1, v1, Lcom/k4/homeclock/HomeClockItem;->clockType:I

    const/4 v2, 0x1

    if-eq v1, v2, :cond_12

    iget-object v1, p0, Lcom/k4/homeclock/AodClockNode;->item:Lcom/k4/homeclock/HomeClockItem;

    iget v1, v1, Lcom/k4/homeclock/HomeClockItem;->clockType:I

    const/4 v3, 0x2

    if-ne v1, v3, :cond_3b

    :cond_12
    if-eqz v0, :cond_3b

    .line 170
    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v1

    if-eqz v1, :cond_3c

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v1

    const/16 v3, 0x320

    if-lt v1, v3, :cond_2a

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v1

    const/16 v3, 0x325

    if-le v1, v3, :cond_3c

    :cond_2a
    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v1

    const/16 v3, 0x32c

    if-eq v1, v3, :cond_3c

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    const/16 v1, 0x32d

    if-ne v0, v1, :cond_3b

    goto :goto_3c

    :cond_3b
    const/4 v2, 0x0

    .line 169
    :cond_3c
    :goto_3c
    return v2
.end method


# virtual methods
.method public a(Landroid/graphics/Canvas;)V
    .registers 9

    .line 205
    const-string v0, "K4HomeClock"

    iget-boolean v1, p0, Lcom/k4/homeclock/AodClockNode;->failed:Z

    if-eqz v1, :cond_12

    .line 206
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->fallback:Lcom/k4/homeclock/ClockNode;

    invoke-virtual {v0, p1}, Lcom/k4/homeclock/ClockNode;->a(Landroid/graphics/Canvas;)V

    .line 207
    iget-object p1, p0, Lcom/k4/homeclock/AodClockNode;->fallback:Lcom/k4/homeclock/ClockNode;

    iget-object p1, p1, Lcom/k4/homeclock/ClockNode;->lastDrawn:Ljava/lang/String;

    iput-object p1, p0, Lcom/k4/homeclock/AodClockNode;->lastDrawn:Ljava/lang/String;

    .line 208
    return-void

    .line 210
    :cond_12
    invoke-virtual {p0}, Lcom/k4/homeclock/AodClockNode;->showing()Z

    move-result v1

    if-nez v1, :cond_1d

    .line 211
    const-string p1, ""

    iput-object p1, p0, Lcom/k4/homeclock/AodClockNode;->lastDrawn:Ljava/lang/String;

    .line 212
    return-void

    .line 215
    :cond_1d
    :try_start_1d
    invoke-static {}, Landroid/os/Looper;->myLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v2

    if-eq v1, v2, :cond_45

    .line 216
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Thread;->getName()Ljava/lang/String;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "AOD clock drawn off the main thread: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 218
    :cond_45
    invoke-virtual {p0}, Lcom/k4/homeclock/AodClockNode;->text()Ljava/lang/String;

    move-result-object v1

    .line 219
    iget-object v2, p0, Lcom/k4/homeclock/AodClockNode;->builtFor:Ljava/lang/String;

    invoke-direct {p0}, Lcom/k4/homeclock/AodClockNode;->config()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_5d

    .line 220
    const-string v2, "AOD clock: locale/time zone/12-24 h changed, new view"

    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 221
    invoke-direct {p0}, Lcom/k4/homeclock/AodClockNode;->inflate()V

    .line 223
    :cond_5d
    const/4 v2, 0x0

    invoke-direct {p0, v2}, Lcom/k4/homeclock/AodClockNode;->place(Z)V

    .line 224
    invoke-virtual {p1}, Landroid/graphics/Canvas;->save()I

    move-result v2

    .line 225
    invoke-virtual {p0}, Lcom/k4/homeclock/AodClockNode;->zoom()F

    move-result v3

    .line 226
    const/high16 v4, 0x3f800000    # 1.0f

    cmpl-float v4, v3, v4

    if-eqz v4, :cond_80

    .line 227
    invoke-virtual {p1}, Landroid/graphics/Canvas;->getWidth()I

    move-result v4

    int-to-float v4, v4

    const/high16 v5, 0x40000000    # 2.0f

    div-float/2addr v4, v5

    invoke-virtual {p1}, Landroid/graphics/Canvas;->getHeight()I

    move-result v6

    int-to-float v6, v6

    div-float/2addr v6, v5

    invoke-virtual {p1, v3, v3, v4, v6}, Landroid/graphics/Canvas;->scale(FFFF)V

    .line 229
    :cond_80
    iget v3, p0, Lcom/k4/homeclock/AodClockNode;->left:F

    iget v4, p0, Lcom/k4/homeclock/AodClockNode;->top:F

    invoke-virtual {p1, v3, v4}, Landroid/graphics/Canvas;->translate(FF)V

    .line 230
    iget v3, p0, Lcom/k4/homeclock/AodClockNode;->scale:F

    iget v4, p0, Lcom/k4/homeclock/AodClockNode;->scale:F

    invoke-virtual {p1, v3, v4}, Landroid/graphics/Canvas;->scale(FF)V

    .line 231
    iget-object v3, p0, Lcom/k4/homeclock/AodClockNode;->clock:Landroid/view/View;

    invoke-virtual {v3, p1}, Landroid/view/View;->draw(Landroid/graphics/Canvas;)V

    .line 232
    invoke-virtual {p1, v2}, Landroid/graphics/Canvas;->restoreToCount(I)V

    .line 233
    iput-object v1, p0, Lcom/k4/homeclock/AodClockNode;->lastDrawn:Ljava/lang/String;
    :try_end_98
    .catchall {:try_start_1d .. :try_end_98} :catchall_99

    .line 241
    goto :goto_be

    .line 234
    :catchall_99
    move-exception v1

    .line 235
    instance-of v2, v1, Ljava/lang/reflect/InvocationTargetException;

    if-eqz v2, :cond_a8

    invoke-virtual {v1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v2

    if-eqz v2, :cond_a8

    invoke-virtual {v1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v1

    .line 236
    :cond_a8
    const-string v2, "AOD clock draw failed, plain clock from now on"

    invoke-static {v0, v2, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 237
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/k4/homeclock/AodClockNode;->failed:Z

    .line 238
    invoke-virtual {p0}, Lcom/k4/homeclock/AodClockNode;->release()V

    .line 239
    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->fallback:Lcom/k4/homeclock/ClockNode;

    invoke-virtual {v0, p1}, Lcom/k4/homeclock/ClockNode;->a(Landroid/graphics/Canvas;)V

    .line 240
    iget-object p1, p0, Lcom/k4/homeclock/AodClockNode;->fallback:Lcom/k4/homeclock/ClockNode;

    iget-object p1, p1, Lcom/k4/homeclock/ClockNode;->lastDrawn:Ljava/lang/String;

    iput-object p1, p0, Lcom/k4/homeclock/AodClockNode;->lastDrawn:Ljava/lang/String;

    .line 242
    :goto_be
    return-void
.end method

.method expected()Ljava/lang/String;
    .registers 2

    .line 87
    iget-boolean v0, p0, Lcom/k4/homeclock/AodClockNode;->failed:Z

    if-eqz v0, :cond_b

    iget-object v0, p0, Lcom/k4/homeclock/AodClockNode;->fallback:Lcom/k4/homeclock/ClockNode;

    invoke-virtual {v0}, Lcom/k4/homeclock/ClockNode;->expected()Ljava/lang/String;

    move-result-object v0

    goto :goto_f

    :cond_b
    invoke-super {p0}, Lcom/k4/homeclock/DepthClock;->expected()Ljava/lang/String;

    move-result-object v0

    :goto_f
    return-object v0
.end method

.method release()V
    .registers 3

    .line 246
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/k4/homeclock/AodClockNode;->clock:Landroid/view/View;

    .line 247
    iget-object v1, p0, Lcom/k4/homeclock/AodClockNode;->host:Lcom/k4/homeclock/AodHost;

    .line 248
    iput-object v0, p0, Lcom/k4/homeclock/AodClockNode;->host:Lcom/k4/homeclock/AodHost;

    .line 249
    if-eqz v1, :cond_c

    .line 250
    invoke-virtual {v1}, Lcom/k4/homeclock/AodHost;->release()V

    .line 252
    :cond_c
    return-void
.end method

.method text()Ljava/lang/String;
    .registers 4

    .line 82
    invoke-super {p0}, Lcom/k4/homeclock/DepthClock;->text()Ljava/lang/String;

    move-result-object v0

    invoke-direct {p0}, Lcom/k4/homeclock/AodClockNode;->config()Ljava/lang/String;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, "|"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
