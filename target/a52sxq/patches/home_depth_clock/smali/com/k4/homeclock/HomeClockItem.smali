.class final Lcom/k4/homeclock/HomeClockItem;
.super Ljava/lang/Object;
.source "HomeClockItem.java"


# static fields
.field static final KEY:Ljava/lang/String; = "k4_home_clock_item"


# instance fields
.field blur:Z

.field clockType:I

.field color:Ljava/lang/Integer;

.field colorType:Ljava/lang/String;

.field fontIndex:Ljava/lang/Integer;

.field fontPath:Ljava/lang/String;

.field fontRounded:Ljava/lang/Integer;

.field fontWeight:Ljava/lang/Integer;

.field gravityX:Ljava/lang/String;

.field hasShadow:Z

.field presetIndex:I

.field raw:Ljava/lang/String;

.field final rect:Landroid/graphics/Rect;

.field scale:F

.field shadowColor:I

.field shadowDx:F

.field shadowDy:F

.field shadowRadius:F

.field showDateFirst:Z


# direct methods
.method private constructor <init>()V
    .registers 3

    .line 43
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 23
    const-string v0, ""

    iput-object v0, p0, Lcom/k4/homeclock/HomeClockItem;->fontPath:Ljava/lang/String;

    .line 27
    iput-object v0, p0, Lcom/k4/homeclock/HomeClockItem;->colorType:Ljava/lang/String;

    .line 35
    const/4 v1, 0x1

    iput-boolean v1, p0, Lcom/k4/homeclock/HomeClockItem;->showDateFirst:Z

    .line 38
    const-string v1, "Start"

    iput-object v1, p0, Lcom/k4/homeclock/HomeClockItem;->gravityX:Ljava/lang/String;

    .line 39
    new-instance v1, Landroid/graphics/Rect;

    invoke-direct {v1}, Landroid/graphics/Rect;-><init>()V

    iput-object v1, p0, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    .line 40
    const/high16 v1, 0x3f800000    # 1.0f

    iput v1, p0, Lcom/k4/homeclock/HomeClockItem;->scale:F

    .line 41
    iput-object v0, p0, Lcom/k4/homeclock/HomeClockItem;->raw:Ljava/lang/String;

    .line 43
    return-void
.end method

.method static parse(Ljava/lang/String;Ljava/lang/String;)Lcom/k4/homeclock/HomeClockItem;
    .registers 12
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 67
    new-instance v0, Lcom/k4/homeclock/HomeClockItem;

    invoke-direct {v0}, Lcom/k4/homeclock/HomeClockItem;-><init>()V

    .line 68
    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->raw:Ljava/lang/String;

    .line 69
    new-instance v1, Lorg/json/JSONObject;

    invoke-direct {v1, p0}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 70
    const-string p0, "isEnabled"

    const/4 v2, 0x1

    invoke-virtual {v1, p0, v2}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result p0

    if-eqz p0, :cond_18d

    .line 73
    const-string p0, "clockType"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->clockType:I

    .line 74
    const-string p0, "font"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p0

    .line 75
    const-string v3, ""

    if-eqz p0, :cond_77

    .line 76
    const-string v4, "presetFontIndex"

    invoke-virtual {p0, v4}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v5

    if-eqz v5, :cond_3f

    invoke-virtual {p0, v4}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v5

    if-nez v5, :cond_3f

    .line 77
    invoke-virtual {p0, v4}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v4

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    iput-object v4, v0, Lcom/k4/homeclock/HomeClockItem;->fontIndex:Ljava/lang/Integer;

    .line 79
    :cond_3f
    const-string v4, "fontPath"

    invoke-virtual {p0, v4, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    iput-object v4, v0, Lcom/k4/homeclock/HomeClockItem;->fontPath:Ljava/lang/String;

    .line 80
    const-string v4, "fontWeight"

    invoke-virtual {p0, v4}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v5

    if-eqz v5, :cond_5f

    invoke-virtual {p0, v4}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v5

    if-nez v5, :cond_5f

    .line 81
    invoke-virtual {p0, v4}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v4

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    iput-object v4, v0, Lcom/k4/homeclock/HomeClockItem;->fontWeight:Ljava/lang/Integer;

    .line 83
    :cond_5f
    const-string v4, "fontRoundedCorners"

    invoke-virtual {p0, v4}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v5

    if-eqz v5, :cond_77

    invoke-virtual {p0, v4}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v5

    if-nez v5, :cond_77

    .line 84
    invoke-virtual {p0, v4}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p0

    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->fontRounded:Ljava/lang/Integer;

    .line 87
    :cond_77
    const-string p0, "color"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v4

    .line 88
    const/4 v5, 0x0

    if-eqz v4, :cond_d8

    .line 89
    const-string v6, "_type_"

    invoke-virtual {v4, v6, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 90
    const/16 v6, 0x2e

    invoke-virtual {v3, v6}, Ljava/lang/String;->lastIndexOf(I)I

    move-result v6

    add-int/2addr v6, v2

    invoke-virtual {v3, v6}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v3

    iput-object v3, v0, Lcom/k4/homeclock/HomeClockItem;->colorType:Ljava/lang/String;

    .line 91
    const-string v3, "presetIndex"

    invoke-virtual {v4, v3, v5}, Lorg/json/JSONObject;->optInt(Ljava/lang/String;I)I

    move-result v3

    iput v3, v0, Lcom/k4/homeclock/HomeClockItem;->presetIndex:I

    .line 92
    invoke-virtual {v4, p0}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v3

    if-eqz v3, :cond_ab

    .line 93
    invoke-virtual {v4, p0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p0

    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->color:Ljava/lang/Integer;

    .line 95
    :cond_ab
    const-string p0, "shadowColor"

    invoke-virtual {v4, p0}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v3

    if-eqz v3, :cond_d8

    .line 96
    iput-boolean v2, v0, Lcom/k4/homeclock/HomeClockItem;->hasShadow:Z

    .line 97
    invoke-virtual {v4, p0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowColor:I

    .line 98
    const-string p0, "shadowRadius"

    const-wide/16 v6, 0x0

    invoke-virtual {v4, p0, v6, v7}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v8

    double-to-float p0, v8

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowRadius:F

    .line 99
    const-string p0, "shadowDx"

    invoke-virtual {v4, p0, v6, v7}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v8

    double-to-float p0, v8

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowDx:F

    .line 100
    const-string p0, "shadowDy"

    invoke-virtual {v4, p0, v6, v7}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v3

    double-to-float p0, v3

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowDy:F

    .line 103
    :cond_d8
    const-string p0, "isShowDateFirst"

    invoke-virtual {v1, p0, v2}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result p0

    iput-boolean p0, v0, Lcom/k4/homeclock/HomeClockItem;->showDateFirst:Z

    .line 104
    const-string p0, "isBlurEffectEnabled"

    invoke-virtual {v1, p0, v5}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result p0

    iput-boolean p0, v0, Lcom/k4/homeclock/HomeClockItem;->blur:Z

    .line 105
    const-string p0, "x"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p0

    .line 106
    if-eqz p0, :cond_fa

    .line 107
    const-string v1, "locatedAt"

    const-string v3, "Start"

    invoke-virtual {p0, v1, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->gravityX:Ljava/lang/String;

    .line 109
    :cond_fa
    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0

    const-string v1, ","

    invoke-virtual {p0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object p0

    .line 110
    array-length v1, p0

    const/4 v3, 0x4

    if-lt v1, v3, :cond_174

    .line 113
    iget-object v1, v0, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    aget-object v4, p0, v5

    invoke-static {v4}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result v4

    invoke-static {v4}, Ljava/lang/Math;->round(F)I

    move-result v4

    aget-object v2, p0, v2

    invoke-static {v2}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result v2

    invoke-static {v2}, Ljava/lang/Math;->round(F)I

    move-result v2

    const/4 v5, 0x2

    aget-object v5, p0, v5

    .line 114
    invoke-static {v5}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result v5

    invoke-static {v5}, Ljava/lang/Math;->round(F)I

    move-result v5

    const/4 v6, 0x3

    aget-object v6, p0, v6

    invoke-static {v6}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result v6

    invoke-static {v6}, Ljava/lang/Math;->round(F)I

    move-result v6

    .line 113
    invoke-virtual {v1, v4, v2, v5, v6}, Landroid/graphics/Rect;->set(IIII)V

    .line 115
    iget-object v1, v0, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_15b

    .line 118
    array-length p1, p0

    if-le p1, v3, :cond_15a

    .line 119
    aget-object p0, p0, v3

    invoke-static {p0}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result p0

    .line 120
    const p1, 0x3d4ccccd    # 0.05f

    cmpl-float p1, p0, p1

    if-lez p1, :cond_156

    const/high16 p1, 0x41a00000    # 20.0f

    cmpg-float p1, p0, p1

    if-gez p1, :cond_156

    goto :goto_158

    :cond_156
    const/high16 p0, 0x3f800000    # 1.0f

    :goto_158
    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->scale:F

    .line 122
    :cond_15a
    return-object v0

    .line 116
    :cond_15b
    new-instance p0, Ljava/lang/IllegalArgumentException;

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "rect empty: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 111
    :cond_174
    new-instance p0, Ljava/lang/IllegalArgumentException;

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "rect: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 71
    :cond_18d
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "clock item disabled"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static read(Landroid/content/Context;)Lcom/k4/homeclock/HomeClockItem;
    .registers 5

    .line 49
    const-string v0, "K4HomeClock"

    const/4 v1, 0x0

    :try_start_3
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    const-string v3, "k4_home_clock_item"

    invoke-static {v2, v3}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 50
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object p0

    const-string v3, "k4_home_clock_item_rect"

    invoke-static {p0, v3}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0
    :try_end_17
    .catchall {:try_start_3 .. :try_end_17} :catchall_59

    .line 54
    nop

    .line 55
    if-eqz v2, :cond_58

    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_58

    if-eqz p0, :cond_58

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    move-result v3

    if-eqz v3, :cond_31

    goto :goto_58

    .line 59
    :cond_31
    :try_start_31
    invoke-static {v2, p0}, Lcom/k4/homeclock/HomeClockItem;->parse(Ljava/lang/String;Ljava/lang/String;)Lcom/k4/homeclock/HomeClockItem;

    move-result-object p0
    :try_end_35
    .catchall {:try_start_31 .. :try_end_35} :catchall_36

    return-object p0

    .line 60
    :catchall_36
    move-exception p0

    .line 61
    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "clock item: unreadable, using the plain clock ("

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v2, ")"

    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 62
    return-object v1

    .line 56
    :cond_58
    :goto_58
    return-object v1

    .line 51
    :catchall_59
    move-exception p0

    .line 52
    const-string v2, "clock item: settings not readable"

    invoke-static {v0, v2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 53
    return-object v1
.end method


# virtual methods
.method public toString()Ljava/lang/String;
    .registers 17

    .line 127
    move-object/from16 v0, p0

    iget v1, v0, Lcom/k4/homeclock/HomeClockItem;->clockType:I

    iget-object v2, v0, Lcom/k4/homeclock/HomeClockItem;->fontIndex:Ljava/lang/Integer;

    iget-object v3, v0, Lcom/k4/homeclock/HomeClockItem;->fontWeight:Ljava/lang/Integer;

    iget-object v4, v0, Lcom/k4/homeclock/HomeClockItem;->fontRounded:Ljava/lang/Integer;

    .line 128
    iget-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontPath:Ljava/lang/String;

    invoke-virtual {v5}, Ljava/lang/String;->isEmpty()Z

    move-result v5

    const-string v6, ""

    const-string v7, "/"

    if-eqz v5, :cond_18

    move-object v5, v6

    goto :goto_2b

    :cond_18
    iget-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontPath:Ljava/lang/String;

    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v8, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    :goto_2b
    iget-object v8, v0, Lcom/k4/homeclock/HomeClockItem;->colorType:Ljava/lang/String;

    iget v9, v0, Lcom/k4/homeclock/HomeClockItem;->presetIndex:I

    .line 129
    iget-object v10, v0, Lcom/k4/homeclock/HomeClockItem;->color:Ljava/lang/Integer;

    if-nez v10, :cond_36

    const-string v10, "-"

    goto :goto_40

    :cond_36
    iget-object v10, v0, Lcom/k4/homeclock/HomeClockItem;->color:Ljava/lang/Integer;

    invoke-virtual {v10}, Ljava/lang/Integer;->intValue()I

    move-result v10

    invoke-static {v10}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    move-result-object v10

    :goto_40
    iget-boolean v11, v0, Lcom/k4/homeclock/HomeClockItem;->hasShadow:Z

    if-eqz v11, :cond_46

    const-string v6, ", shadow"

    :cond_46
    iget-boolean v11, v0, Lcom/k4/homeclock/HomeClockItem;->showDateFirst:Z

    iget-boolean v12, v0, Lcom/k4/homeclock/HomeClockItem;->blur:Z

    iget-object v13, v0, Lcom/k4/homeclock/HomeClockItem;->gravityX:Ljava/lang/String;

    iget-object v14, v0, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    .line 130
    invoke-virtual {v14}, Landroid/graphics/Rect;->toShortString()Ljava/lang/String;

    move-result-object v14

    iget v0, v0, Lcom/k4/homeclock/HomeClockItem;->scale:F

    new-instance v15, Ljava/lang/StringBuilder;

    invoke-direct {v15}, Ljava/lang/StringBuilder;-><init>()V

    move/from16 p0, v0

    const-string v0, "clockType="

    invoke-virtual {v15, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", font="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", color="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "("

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v9}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "), dateFirst="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v11}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", blur="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v12}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", x="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", rect="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " x"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    move/from16 v1, p0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 127
    return-object v0
.end method
