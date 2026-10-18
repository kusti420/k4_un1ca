.class final Lcom/k4/homeclock/HomeClockItem;
.super Ljava/lang/Object;
.source "HomeClockItem.java"


# static fields
.field static final KEY:Ljava/lang/String; = "k4_home_clock_item"


# instance fields
.field adaptiveColor:Ljava/lang/Integer;

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

.field gravity:Ljava/lang/Integer;

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

.field showWeather:Z


# direct methods
.method private constructor <init>()V
    .registers 3

    .line 53
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 23
    const-string v0, ""

    iput-object v0, p0, Lcom/k4/homeclock/HomeClockItem;->fontPath:Ljava/lang/String;

    .line 33
    iput-object v0, p0, Lcom/k4/homeclock/HomeClockItem;->colorType:Ljava/lang/String;

    .line 41
    const/4 v1, 0x1

    iput-boolean v1, p0, Lcom/k4/homeclock/HomeClockItem;->showDateFirst:Z

    .line 43
    iput-boolean v1, p0, Lcom/k4/homeclock/HomeClockItem;->showWeather:Z

    .line 46
    const-string v1, "Start"

    iput-object v1, p0, Lcom/k4/homeclock/HomeClockItem;->gravityX:Ljava/lang/String;

    .line 49
    new-instance v1, Landroid/graphics/Rect;

    invoke-direct {v1}, Landroid/graphics/Rect;-><init>()V

    iput-object v1, p0, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    .line 50
    const/high16 v1, 0x3f800000    # 1.0f

    iput v1, p0, Lcom/k4/homeclock/HomeClockItem;->scale:F

    .line 51
    iput-object v0, p0, Lcom/k4/homeclock/HomeClockItem;->raw:Ljava/lang/String;

    .line 53
    return-void
.end method

.method static bundleGravity(Landroid/content/Context;)Ljava/lang/Integer;
    .registers 4

    .line 84
    const-string v0, "gravity"

    const/4 v1, 0x0

    :try_start_3
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object p0

    const-string v2, "k4_home_clock_bundle"

    invoke-static {p0, v2}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    .line 85
    if-eqz p0, :cond_34

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_1a

    goto :goto_34

    .line 88
    :cond_1a
    new-instance v2, Lorg/json/JSONObject;

    invoke-direct {v2, p0}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 89
    invoke-virtual {v2, v0}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result p0

    if-eqz p0, :cond_33

    invoke-virtual {v2, v0}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result p0

    if-nez p0, :cond_33

    invoke-virtual {v2, v0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1
    :try_end_33
    .catchall {:try_start_3 .. :try_end_33} :catchall_35

    :cond_33
    return-object v1

    .line 86
    :cond_34
    :goto_34
    return-object v1

    .line 90
    :catchall_35
    move-exception p0

    .line 91
    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "clock bundle: no gravity ("

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v0, ")"

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string v0, "K4HomeClock"

    invoke-static {v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 92
    return-object v1
.end method

.method static parse(Ljava/lang/String;Ljava/lang/String;)Lcom/k4/homeclock/HomeClockItem;
    .registers 12
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 97
    new-instance v0, Lcom/k4/homeclock/HomeClockItem;

    invoke-direct {v0}, Lcom/k4/homeclock/HomeClockItem;-><init>()V

    .line 98
    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->raw:Ljava/lang/String;

    .line 99
    new-instance v1, Lorg/json/JSONObject;

    invoke-direct {v1, p0}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 100
    const-string p0, "isEnabled"

    const/4 v2, 0x1

    invoke-virtual {v1, p0, v2}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result p0

    if-eqz p0, :cond_1fe

    .line 103
    const-string p0, "clockType"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->clockType:I

    .line 104
    const-string p0, "font"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p0

    .line 105
    const-string v3, ""

    const/4 v4, 0x0

    if-eqz p0, :cond_a5

    .line 106
    const-string v5, "presetFontIndex"

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v6

    if-eqz v6, :cond_40

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v6

    if-nez v6, :cond_40

    .line 107
    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v5

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    iput-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontIndex:Ljava/lang/Integer;

    .line 109
    :cond_40
    const-string v5, "fontPath"

    invoke-virtual {p0, v5, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    iput-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontPath:Ljava/lang/String;

    .line 110
    const-string v5, "fontWeight"

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v6

    if-eqz v6, :cond_60

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v6

    if-nez v6, :cond_60

    .line 111
    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v5

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    iput-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontWeight:Ljava/lang/Integer;

    .line 113
    :cond_60
    const-string v5, "fontRoundedCorners"

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v6

    if-eqz v6, :cond_78

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v6

    if-nez v6, :cond_78

    .line 114
    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v5

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    iput-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontRounded:Ljava/lang/Integer;

    .line 117
    :cond_78
    const-string v5, "fontHeights"

    invoke-virtual {p0, v5}, Lorg/json/JSONObject;->optJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object p0

    .line 118
    if-eqz p0, :cond_a5

    invoke-virtual {p0}, Lorg/json/JSONArray;->length()I

    move-result v5

    if-lez v5, :cond_a5

    .line 119
    new-instance v5, Ljava/util/ArrayList;

    invoke-direct {v5}, Ljava/util/ArrayList;-><init>()V

    iput-object v5, v0, Lcom/k4/homeclock/HomeClockItem;->fontHeights:Ljava/util/List;

    .line 120
    move v5, v4

    :goto_8e
    invoke-virtual {p0}, Lorg/json/JSONArray;->length()I

    move-result v6

    if-ge v5, v6, :cond_a5

    .line 121
    iget-object v6, v0, Lcom/k4/homeclock/HomeClockItem;->fontHeights:Ljava/util/List;

    invoke-virtual {p0, v5}, Lorg/json/JSONArray;->getDouble(I)D

    move-result-wide v7

    double-to-float v7, v7

    invoke-static {v7}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v7

    invoke-interface {v6, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 120
    add-int/lit8 v5, v5, 0x1

    goto :goto_8e

    .line 125
    :cond_a5
    const-string p0, "color"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v5

    .line 126
    if-eqz v5, :cond_105

    .line 127
    const-string v6, "_type_"

    invoke-virtual {v5, v6, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 128
    const/16 v6, 0x2e

    invoke-virtual {v3, v6}, Ljava/lang/String;->lastIndexOf(I)I

    move-result v6

    add-int/2addr v6, v2

    invoke-virtual {v3, v6}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v3

    iput-object v3, v0, Lcom/k4/homeclock/HomeClockItem;->colorType:Ljava/lang/String;

    .line 129
    const-string v3, "presetIndex"

    invoke-virtual {v5, v3, v4}, Lorg/json/JSONObject;->optInt(Ljava/lang/String;I)I

    move-result v3

    iput v3, v0, Lcom/k4/homeclock/HomeClockItem;->presetIndex:I

    .line 130
    invoke-virtual {v5, p0}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v3

    if-eqz v3, :cond_d8

    .line 131
    invoke-virtual {v5, p0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p0

    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->color:Ljava/lang/Integer;

    .line 133
    :cond_d8
    const-string p0, "shadowColor"

    invoke-virtual {v5, p0}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v3

    if-eqz v3, :cond_105

    .line 134
    iput-boolean v2, v0, Lcom/k4/homeclock/HomeClockItem;->hasShadow:Z

    .line 135
    invoke-virtual {v5, p0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowColor:I

    .line 136
    const-string p0, "shadowRadius"

    const-wide/16 v6, 0x0

    invoke-virtual {v5, p0, v6, v7}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v8

    double-to-float p0, v8

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowRadius:F

    .line 137
    const-string p0, "shadowDx"

    invoke-virtual {v5, p0, v6, v7}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v8

    double-to-float p0, v8

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowDx:F

    .line 138
    const-string p0, "shadowDy"

    invoke-virtual {v5, p0, v6, v7}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v5

    double-to-float p0, v5

    iput p0, v0, Lcom/k4/homeclock/HomeClockItem;->shadowDy:F

    .line 141
    :cond_105
    const-string p0, "isShowDateFirst"

    invoke-virtual {v1, p0, v2}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result p0

    iput-boolean p0, v0, Lcom/k4/homeclock/HomeClockItem;->showDateFirst:Z

    .line 142
    const-string p0, "isShowWeather"

    invoke-virtual {v1, p0, v2}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result p0

    iput-boolean p0, v0, Lcom/k4/homeclock/HomeClockItem;->showWeather:Z

    .line 143
    const-string p0, "isBlurEffectEnabled"

    invoke-virtual {v1, p0, v4}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result p0

    iput-boolean p0, v0, Lcom/k4/homeclock/HomeClockItem;->blur:Z

    .line 144
    const-string p0, "x"

    invoke-virtual {v1, p0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p0

    .line 145
    if-eqz p0, :cond_12f

    .line 146
    const-string v1, "locatedAt"

    const-string v3, "Start"

    invoke-virtual {p0, v1, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->gravityX:Ljava/lang/String;

    .line 148
    :cond_12f
    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0

    const-string v1, ","

    invoke-virtual {p0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object p0

    .line 149
    array-length v1, p0

    const/4 v3, 0x4

    if-lt v1, v3, :cond_1e5

    .line 152
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

    .line 153
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

    .line 152
    invoke-virtual {v1, v4, v2, v5, v6}, Landroid/graphics/Rect;->set(IIII)V

    .line 154
    iget-object v1, v0, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_1cc

    .line 157
    array-length p1, p0

    if-le p1, v3, :cond_18f

    .line 158
    aget-object p1, p0, v3

    invoke-static {p1}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result p1

    .line 159
    const v1, 0x3d4ccccd    # 0.05f

    cmpl-float v1, p1, v1

    if-lez v1, :cond_18b

    const/high16 v1, 0x41a00000    # 20.0f

    cmpg-float v1, p1, v1

    if-gez v1, :cond_18b

    goto :goto_18d

    :cond_18b
    const/high16 p1, 0x3f800000    # 1.0f

    :goto_18d
    iput p1, v0, Lcom/k4/homeclock/HomeClockItem;->scale:F

    .line 161
    :cond_18f
    array-length p1, p0

    const/4 v1, 0x5

    if-le p1, v1, :cond_1ab

    aget-object p1, p0, v1

    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    move-result p1

    if-nez p1, :cond_1ab

    .line 162
    aget-object p1, p0, v1

    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p1

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    iput-object p1, v0, Lcom/k4/homeclock/HomeClockItem;->fontColorType:Ljava/lang/Integer;

    .line 164
    :cond_1ab
    array-length p1, p0

    const/4 v1, 0x6

    if-le p1, v1, :cond_1cb

    aget-object p1, p0, v1

    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    move-result p1

    if-nez p1, :cond_1cb

    .line 165
    aget-object p0, p0, v1

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p0

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p0

    iput-object p0, v0, Lcom/k4/homeclock/HomeClockItem;->adaptiveColor:Ljava/lang/Integer;

    .line 167
    :cond_1cb
    return-object v0

    .line 155
    :cond_1cc
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

    .line 150
    :cond_1e5
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

    .line 101
    :cond_1fe
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "clock item disabled"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static read(Landroid/content/Context;)Lcom/k4/homeclock/HomeClockItem;
    .registers 6

    .line 59
    const-string v0, "K4HomeClock"

    const/4 v1, 0x0

    :try_start_3
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    const-string v3, "k4_home_clock_item"

    invoke-static {v2, v3}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 60
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v3

    const-string v4, "k4_home_clock_item_rect"

    invoke-static {v3, v4}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3
    :try_end_17
    .catchall {:try_start_3 .. :try_end_17} :catchall_5f

    .line 64
    nop

    .line 65
    if-eqz v2, :cond_5e

    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z

    move-result v4

    if-nez v4, :cond_5e

    if-eqz v3, :cond_5e

    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z

    move-result v4

    if-eqz v4, :cond_31

    goto :goto_5e

    .line 69
    :cond_31
    :try_start_31
    invoke-static {v2, v3}, Lcom/k4/homeclock/HomeClockItem;->parse(Ljava/lang/String;Ljava/lang/String;)Lcom/k4/homeclock/HomeClockItem;

    move-result-object v2

    .line 70
    invoke-static {p0}, Lcom/k4/homeclock/HomeClockItem;->bundleGravity(Landroid/content/Context;)Ljava/lang/Integer;

    move-result-object p0

    iput-object p0, v2, Lcom/k4/homeclock/HomeClockItem;->gravity:Ljava/lang/Integer;
    :try_end_3b
    .catchall {:try_start_31 .. :try_end_3b} :catchall_3c

    .line 71
    return-object v2

    .line 72
    :catchall_3c
    move-exception p0

    .line 73
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

    .line 74
    return-object v1

    .line 66
    :cond_5e
    :goto_5e
    return-object v1

    .line 61
    :catchall_5f
    move-exception p0

    .line 62
    const-string v2, "clock item: settings not readable"

    invoke-static {v0, v2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 63
    return-object v1
.end method


# virtual methods
.method public toString()Ljava/lang/String;
    .registers 19

    .line 172
    move-object/from16 v0, p0

    iget v1, v0, Lcom/k4/homeclock/HomeClockItem;->clockType:I

    iget-object v2, v0, Lcom/k4/homeclock/HomeClockItem;->fontIndex:Ljava/lang/Integer;

    iget-object v3, v0, Lcom/k4/homeclock/HomeClockItem;->fontWeight:Ljava/lang/Integer;

    iget-object v4, v0, Lcom/k4/homeclock/HomeClockItem;->fontRounded:Ljava/lang/Integer;

    .line 173
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

    .line 174
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

    if-eqz v11, :cond_47

    const-string v11, ", shadow"

    goto :goto_48

    :cond_47
    move-object v11, v6

    :goto_48
    iget-boolean v12, v0, Lcom/k4/homeclock/HomeClockItem;->showDateFirst:Z

    iget-boolean v13, v0, Lcom/k4/homeclock/HomeClockItem;->showWeather:Z

    iget-boolean v14, v0, Lcom/k4/homeclock/HomeClockItem;->blur:Z

    iget-object v15, v0, Lcom/k4/homeclock/HomeClockItem;->gravityX:Ljava/lang/String;

    .line 176
    move-object/from16 v16, v6

    iget-object v6, v0, Lcom/k4/homeclock/HomeClockItem;->gravity:Ljava/lang/Integer;

    if-nez v6, :cond_5d

    move/from16 v17, v14

    move-object/from16 v6, v16

    move-object/from16 v16, v15

    goto :goto_7e

    :cond_5d
    iget-object v6, v0, Lcom/k4/homeclock/HomeClockItem;->gravity:Ljava/lang/Integer;

    invoke-virtual {v6}, Ljava/lang/Integer;->intValue()I

    move-result v6

    invoke-static {v6}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    move-result-object v6

    move-object/from16 v16, v15

    new-instance v15, Ljava/lang/StringBuilder;

    invoke-direct {v15}, Ljava/lang/StringBuilder;-><init>()V

    move/from16 v17, v14

    const-string v14, "/0x"

    invoke-virtual {v15, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v14

    invoke-virtual {v14, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    :goto_7e
    iget-object v14, v0, Lcom/k4/homeclock/HomeClockItem;->rect:Landroid/graphics/Rect;

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

    invoke-virtual {v0, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "), dateFirst="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v12}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", weather="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v13}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", blur="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    move/from16 v1, v17

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", x="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    move-object/from16 v1, v16

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

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

    .line 172
    return-object v0
.end method
