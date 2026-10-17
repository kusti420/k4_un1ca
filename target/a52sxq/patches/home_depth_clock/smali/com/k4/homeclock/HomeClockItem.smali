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

.field fontColorType:Ljava/lang/Integer;

.field fontHeights:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Ljava/lang/Float;",
            ">;"
        }
    .end annotation
.end field

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

    .line 47
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 23
    const-string v0, ""

    iput-object v0, p0, Lcom/k4/homeclock/HomeClockItem;->fontPath:Ljava/lang/String;

    .line 31
    iput-object v0, p0, Lcom/k4/homeclock/HomeClockItem;->colorType:Ljava/lang/String;

    .line 39
    const/4 v1, 0x1

    iput-boolean v1, p0, Lcom/k4/homeclock/HomeClockItem;->showDateFirst:Z

    .line 42
    const-string v1, "Start"

    iput-object v1, p0, Lcom/k4/homeclock/HomeClockItem;->gravityX:Ljava/lang/String;

    .line 43
    new-instance v1, Landroid/graphics/Rect;

    invoke-direct {v1}, Landroid/graphics/Rect;-><init>()V

    iput-object v1, p0, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    .line 44
    const/high16 v1, 0x3f800000    # 1.0f

    iput v1, p0, Lcom/k4/homeclock/HomeClockItem;->scale:F

    .line 45
    iput-object v0, p0, Lcom/k4/homeclock/HomeClockItem;->raw:Ljava/lang/String;

    .line 47
    return-void
.end method

.method static parse(Ljava/lang/String;Ljava/lang/String;)Lcom/k4/homeclock/HomeClockItem;
    .registers 12
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 71
    new-instance v0, Lcom/k4/homeclock/HomeClockItem;

    invoke-direct {v0}, Lcom/k4/homeclock/HomeClockItem;-><init>()V

    .line 72
    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->raw:Ljava/lang/String;

    .line 73
    new-instance v1, Lorg/json/JSONObject;

    invoke-direct {v1, p0}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 74
    const-string p0, "isEnabled"

    const/4 v2, 0x1

    invoke-virtual {v1, p0, v2}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result p0

    if-eqz p0, :cond_1d6

    .line 77
    const-string p0, "clockType"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->clockType:I

    .line 78
    const-string p0, "font"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p0

    .line 79
    const-string v3, ""

    const/4 v4, 0x0

    if-eqz p0, :cond_a5

    .line 80
    const-string v5, "presetFontIndex"

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v6

    if-eqz v6, :cond_40

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v6

    if-nez v6, :cond_40

    .line 81
    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v5

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    iput-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontIndex:Ljava/lang/Integer;

    .line 83
    :cond_40
    const-string v5, "fontPath"

    invoke-virtual {p0, v5, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    iput-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontPath:Ljava/lang/String;

    .line 84
    const-string v5, "fontWeight"

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v6

    if-eqz v6, :cond_60

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v6

    if-nez v6, :cond_60

    .line 85
    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v5

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    iput-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontWeight:Ljava/lang/Integer;

    .line 87
    :cond_60
    const-string v5, "fontRoundedCorners"

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v6

    if-eqz v6, :cond_78

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v6

    if-nez v6, :cond_78

    .line 88
    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v5

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    iput-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontRounded:Ljava/lang/Integer;

    .line 91
    :cond_78
    const-string v5, "fontHeights"

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->optJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object p0

    .line 92
    if-eqz p0, :cond_a5

    invoke-virtual {p0}, Lorg/json/JSONArray;->length()I

    move-result v5

    if-lez v5, :cond_a5

    .line 93
    new-instance v5, Ljava/util/ArrayList;

    invoke-direct {v5}, Ljava/util/ArrayList;-><init>()V

    iput-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontHeights:Ljava/util/List;

    .line 94
    move v5, v4

    :goto_8e
    invoke-virtual {p0}, Lorg/json/JSONArray;->length()I

    move-result v6

    if-ge v5, v6, :cond_a5

    .line 95
    iget-object v6, v0, Lcom/k4/homeclock/HomeClockItem;->fontHeights:Ljava/util/List;

    invoke-virtual {p0, v5}, Lorg/json/JSONArray;->getDouble(I)D

    move-result-wide v7

    double-to-float v7, v7

    invoke-static {v7}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v7

    invoke-interface {v6, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 94
    add-int/lit8 v5, v5, 0x1

    goto :goto_8e

    .line 99
    :cond_a5
    const-string p0, "color"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v5

    .line 100
    if-eqz v5, :cond_105

    .line 101
    const-string v6, "_type_"

    invoke-virtual {v5, v6, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 102
    const/16 v6, 0x2e

    invoke-virtual {v3, v6}, Ljava/lang/String;->lastIndexOf(I)I

    move-result v6

    add-int/2addr v6, v2

    invoke-virtual {v3, v6}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v3

    iput-object v3, v0, Lcom/k4/homeclock/HomeClockItem;->colorType:Ljava/lang/String;

    .line 103
    const-string v3, "presetIndex"

    invoke-virtual {v5, v3, v4}, Lorg/json/JSONObject;->optInt(Ljava/lang/String;I)I

    move-result v3

    iput v3, v0, Lcom/k4/homeclock/HomeClockItem;->presetIndex:I

    .line 104
    invoke-virtual {v5, p0}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v3

    if-eqz v3, :cond_d8

    .line 105
    invoke-virtual {v5, p0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p0

    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->color:Ljava/lang/Integer;

    .line 107
    :cond_d8
    const-string p0, "shadowColor"

    invoke-virtual {v5, p0}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v3

    if-eqz v3, :cond_105

    .line 108
    iput-boolean v2, v0, Lcom/k4/homeclock/HomeClockItem;->hasShadow:Z

    .line 109
    invoke-virtual {v5, p0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowColor:I

    .line 110
    const-string p0, "shadowRadius"

    const-wide/16 v6, 0x0

    invoke-virtual {v5, p0, v6, v7}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v8

    double-to-float p0, v8

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowRadius:F

    .line 111
    const-string p0, "shadowDx"

    invoke-virtual {v5, p0, v6, v7}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v8

    double-to-float p0, v8

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowDx:F

    .line 112
    const-string p0, "shadowDy"

    invoke-virtual {v5, p0, v6, v7}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v5

    double-to-float p0, v5

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowDy:F

    .line 115
    :cond_105
    const-string p0, "isShowDateFirst"

    invoke-virtual {v1, p0, v2}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result p0

    iput-boolean p0, v0, Lcom/k4/homeclock/HomeClockItem;->showDateFirst:Z

    .line 116
    const-string p0, "isBlurEffectEnabled"

    invoke-virtual {v1, p0, v4}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result p0

    iput-boolean p0, v0, Lcom/k4/homeclock/HomeClockItem;->blur:Z

    .line 117
    const-string p0, "x"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p0

    .line 118
    if-eqz p0, :cond_127

    .line 119
    const-string v1, "locatedAt"

    const-string v3, "Start"

    invoke-virtual {p0, v1, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->gravityX:Ljava/lang/String;

    .line 121
    :cond_127
    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0

    const-string v1, ","

    invoke-virtual {p0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object p0

    .line 122
    array-length v1, p0

    const/4 v3, 0x4

    if-lt v1, v3, :cond_1bd

    .line 125
    iget-object v1, v0, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    aget-object v4, p0, v4

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

    .line 126
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

    .line 125
    invoke-virtual {v1, v4, v2, v5, v6}, Landroid/graphics/Rect;->set(IIII)V

    .line 127
    iget-object v1, v0, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_1a4

    .line 130
    array-length p1, p0

    if-le p1, v3, :cond_187

    .line 131
    aget-object p1, p0, v3

    invoke-static {p1}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result p1

    .line 132
    const v1, 0x3d4ccccd    # 0.05f

    cmpl-float v1, p1, v1

    if-lez v1, :cond_183

    const/high16 v1, 0x41a00000    # 20.0f

    cmpg-float v1, p1, v1

    if-gez v1, :cond_183

    goto :goto_185

    :cond_183
    const/high16 p1, 0x3f800000    # 1.0f

    :goto_185
    iput p1, v0, Lcom/k4/homeclock/HomeClockItem;->scale:F

    .line 134
    :cond_187
    array-length p1, p0

    const/4 v1, 0x5

    if-le p1, v1, :cond_1a3

    aget-object p1, p0, v1

    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    move-result p1

    if-nez p1, :cond_1a3

    .line 135
    aget-object p0, p0, v1

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p0

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p0

    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->fontColorType:Ljava/lang/Integer;

    .line 137
    :cond_1a3
    return-object v0

    .line 128
    :cond_1a4
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

    .line 123
    :cond_1bd
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

    .line 75
    :cond_1d6
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "clock item disabled"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static read(Landroid/content/Context;)Lcom/k4/homeclock/HomeClockItem;
    .registers 5

    .line 53
    const-string v0, "K4HomeClock"

    const/4 v1, 0x0

    :try_start_3
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    const-string v3, "k4_home_clock_item"

    invoke-static {v2, v3}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 54
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object p0

    const-string v3, "k4_home_clock_item_rect"

    invoke-static {p0, v3}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0
    :try_end_17
    .catchall {:try_start_3 .. :try_end_17} :catchall_59

    .line 58
    nop

    .line 59
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

    .line 63
    :cond_31
    :try_start_31
    invoke-static {v2, p0}, Lcom/k4/homeclock/HomeClockItem;->parse(Ljava/lang/String;Ljava/lang/String;)Lcom/k4/homeclock/HomeClockItem;

    move-result-object p0
    :try_end_35
    .catchall {:try_start_31 .. :try_end_35} :catchall_36

    return-object p0

    .line 64
    :catchall_36
    move-exception p0

    .line 65
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

    .line 66
    return-object v1

    .line 60
    :cond_58
    :goto_58
    return-object v1

    .line 55
    :catchall_59
    move-exception p0

    .line 56
    const-string v2, "clock item: settings not readable"

    invoke-static {v0, v2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 57
    return-object v1
.end method


# virtual methods
.method public toString()Ljava/lang/String;
    .registers 17

    .line 142
    move-object/from16 v0, p0

    iget v1, v0, Lcom/k4/homeclock/HomeClockItem;->clockType:I

    iget-object v2, v0, Lcom/k4/homeclock/HomeClockItem;->fontIndex:Ljava/lang/Integer;

    iget-object v3, v0, Lcom/k4/homeclock/HomeClockItem;->fontWeight:Ljava/lang/Integer;

    iget-object v4, v0, Lcom/k4/homeclock/HomeClockItem;->fontRounded:Ljava/lang/Integer;

    .line 143
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

    .line 144
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

    .line 145
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

    .line 142
    return-object v0
.end method
