.class final Lcom/k4/homeclock/ClockNode;
.super Li3/j;
.source "ClockNode.java"


# instance fields
.field private final accent:Z

.field private final baseline:F

.field private final centerX:F

.field private final fixedColor:Ljava/lang/Integer;

.field volatile lastDrawn:Ljava/lang/String;

.field private final lightBackground:Z

.field private final owner:Lh3/a;

.field private final paint:Landroid/graphics/Paint;

.field private final scaleRef:Li3/c;


# direct methods
.method constructor <init>(Landroid/content/Context;IIFLandroid/graphics/Bitmap;Li3/c;Lh3/a;)V
    .registers 13

    .line 40
    const-string v0, "K4DepthClockNode"

    invoke-direct {p0, p1, v0}, Li3/j;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 29
    new-instance p1, Landroid/graphics/Paint;

    const/16 v0, 0x81

    invoke-direct {p1, v0}, Landroid/graphics/Paint;-><init>(I)V

    iput-object p1, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    .line 37
    const-string p1, ""

    iput-object p1, p0, Lcom/k4/homeclock/ClockNode;->lastDrawn:Ljava/lang/String;

    .line 41
    iput-object p6, p0, Lcom/k4/homeclock/ClockNode;->scaleRef:Li3/c;

    .line 42
    iput-object p7, p0, Lcom/k4/homeclock/ClockNode;->owner:Lh3/a;

    .line 43
    iget-object p6, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    sget-object p7, Landroid/graphics/Typeface;->DEFAULT:Landroid/graphics/Typeface;

    const/16 v0, 0x1f4

    const/4 v1, 0x0

    invoke-static {p7, v0, v1}, Landroid/graphics/Typeface;->create(Landroid/graphics/Typeface;IZ)Landroid/graphics/Typeface;

    move-result-object p7

    invoke-virtual {p6, p7}, Landroid/graphics/Paint;->setTypeface(Landroid/graphics/Typeface;)Landroid/graphics/Typeface;

    .line 44
    iget-object p6, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    sget-object p7, Landroid/graphics/Paint$Align;->CENTER:Landroid/graphics/Paint$Align;

    invoke-virtual {p6, p7}, Landroid/graphics/Paint;->setTextAlign(Landroid/graphics/Paint$Align;)V

    .line 45
    iget-object p6, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    const-string p7, "tnum"

    invoke-virtual {p6, p7}, Landroid/graphics/Paint;->setFontFeatureSettings(Ljava/lang/String;)V

    .line 46
    iget-object p6, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    const/high16 p7, 0x42c80000    # 100.0f

    invoke-virtual {p6, p7}, Landroid/graphics/Paint;->setTextSize(F)V

    .line 47
    if-gt p2, p3, :cond_3f

    const p6, 0x3f570a3d    # 0.84f

    goto :goto_42

    :cond_3f
    const p6, 0x3ed70a3d    # 0.42f

    :goto_42
    int-to-float p2, p2

    mul-float/2addr p6, p2

    .line 48
    iget-object v0, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    mul-float v2, p6, p7

    iget-object v3, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    const-string v4, "00:00"

    invoke-virtual {v3, v4}, Landroid/graphics/Paint;->measureText(Ljava/lang/String;)F

    move-result v3

    div-float/2addr v2, v3

    invoke-virtual {v0, v2}, Landroid/graphics/Paint;->setTextSize(F)V

    .line 49
    new-instance v0, Landroid/graphics/Rect;

    invoke-direct {v0}, Landroid/graphics/Rect;-><init>()V

    .line 50
    iget-object v2, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    const-string v3, "0123456789"

    const/16 v4, 0xa

    invoke-virtual {v2, v3, v1, v4, v0}, Landroid/graphics/Paint;->getTextBounds(Ljava/lang/String;IILandroid/graphics/Rect;)V

    .line 51
    iget v0, v0, Landroid/graphics/Rect;->top:I

    neg-int v0, v0

    int-to-float v0, v0

    .line 53
    const-string v2, "persist.sys.k4.home_depth_clock_y"

    invoke-static {v2}, Lcom/k4/homeclock/HomeDepthClock;->prop(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/k4/homeclock/ClockNode;->parse(Ljava/lang/String;)F

    move-result v2

    .line 54
    invoke-static {v2}, Ljava/lang/Float;->isNaN(F)Z

    move-result v3

    const/high16 v4, 0x40000000    # 2.0f

    if-nez v3, :cond_89

    .line 55
    int-to-float p3, p3

    mul-float/2addr v2, p3

    div-float/2addr v2, p7

    div-float p7, v0, v4

    add-float/2addr v2, p7

    invoke-static {v0, v2}, Ljava/lang/Math;->max(FF)F

    move-result p7

    invoke-static {p3, p7}, Ljava/lang/Math;->min(FF)F

    move-result p3

    iput p3, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    goto :goto_b4

    .line 57
    :cond_89
    const/4 p7, 0x0

    cmpl-float p7, p4, p7

    if-ltz p7, :cond_94

    const p7, 0x3eb33333    # 0.35f

    mul-float/2addr p7, v0

    add-float/2addr p7, p4

    goto :goto_9c

    :cond_94
    const p7, 0x3e99999a    # 0.3f

    int-to-float v2, p3

    mul-float/2addr v2, p7

    div-float p7, v0, v4

    add-float/2addr p7, v2

    .line 58
    :goto_9c
    int-to-float p3, p3

    const v2, 0x3dcccccd    # 0.1f

    mul-float/2addr v2, p3

    add-float/2addr v2, v0

    .line 59
    const v3, 0x3ee66666    # 0.45f

    mul-float/2addr p3, v3

    invoke-static {v2, p3}, Ljava/lang/Math;->max(FF)F

    move-result p3

    .line 60
    invoke-static {v2, p7}, Ljava/lang/Math;->max(FF)F

    move-result p7

    invoke-static {p3, p7}, Ljava/lang/Math;->min(FF)F

    move-result p3

    iput p3, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    .line 62
    :goto_b4
    div-float/2addr p2, v4

    iput p2, p0, Lcom/k4/homeclock/ClockNode;->centerX:F

    .line 64
    const-string p2, "persist.sys.k4.home_depth_clock_color"

    invoke-static {p2}, Lcom/k4/homeclock/HomeDepthClock;->prop(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p2

    .line 65
    const/4 p3, -0x1

    invoke-static {p3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p3

    .line 66
    nop

    .line 67
    const-string p7, "accent"

    invoke-virtual {p7, p2}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v2

    const/4 v3, 0x1

    if-eqz v2, :cond_ce

    .line 68
    move p2, v3

    goto :goto_e2

    .line 69
    :cond_ce
    const-string v2, "#"

    invoke-virtual {p2, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_e1

    .line 71
    :try_start_d6
    invoke-static {p2}, Landroid/graphics/Color;->parseColor(Ljava/lang/String;)I

    move-result p2

    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p3
    :try_end_de
    .catch Ljava/lang/IllegalArgumentException; {:try_start_d6 .. :try_end_de} :catch_e0

    .line 73
    move p2, v1

    goto :goto_e2

    .line 72
    :catch_e0
    move-exception p2

    .line 75
    :cond_e1
    move p2, v1

    :goto_e2
    iput-boolean p2, p0, Lcom/k4/homeclock/ClockNode;->accent:Z

    .line 76
    iput-object p3, p0, Lcom/k4/homeclock/ClockNode;->fixedColor:Ljava/lang/Integer;

    .line 77
    if-eqz p2, :cond_106

    if-eqz p5, :cond_106

    iget p2, p0, Lcom/k4/homeclock/ClockNode;->centerX:F

    div-float/2addr p6, v4

    sub-float/2addr p2, p6

    float-to-int p2, p2

    iget v2, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    sub-float/2addr v2, v0

    float-to-int v2, v2

    iget v4, p0, Lcom/k4/homeclock/ClockNode;->centerX:F

    add-float/2addr v4, p6

    float-to-int p6, v4

    iget v4, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    float-to-int v4, v4

    invoke-static {p5, p2, v2, p6, v4}, Lcom/k4/homeclock/ClockNode;->luminance(Landroid/graphics/Bitmap;IIII)F

    move-result p2

    const p5, 0x3f19999a    # 0.6f

    cmpl-float p2, p2, p5

    if-lez p2, :cond_106

    move v1, v3

    :cond_106
    iput-boolean v1, p0, Lcom/k4/homeclock/ClockNode;->lightBackground:Z

    .line 79
    iget-object p2, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    invoke-virtual {p2}, Landroid/graphics/Paint;->getTextSize()F

    move-result p2

    iget p5, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    .line 80
    iget-boolean p6, p0, Lcom/k4/homeclock/ClockNode;->accent:Z

    if-eqz p6, :cond_115

    goto :goto_11d

    :cond_115
    invoke-virtual {p3}, Ljava/lang/Integer;->intValue()I

    move-result p3

    invoke-static {p3}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    move-result-object p7

    .line 81
    :goto_11d
    iget-object p3, p0, Lcom/k4/homeclock/ClockNode;->owner:Lh3/a;

    if-eqz p3, :cond_123

    const-string p1, ", gated"

    :cond_123
    new-instance p3, Ljava/lang/StringBuilder;

    invoke-direct {p3}, Ljava/lang/StringBuilder;-><init>()V

    const-string p6, "layout: textSize="

    invoke-virtual {p3, p6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, p2}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, ", digitH="

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, ", baseline="

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p5}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, " (subjectTop="

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p4}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, "), color="

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 79
    const-string p2, "K4HomeClock"

    invoke-static {p2, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 82
    return-void
.end method

.method private static luminance(Landroid/graphics/Bitmap;IIII)F
    .registers 15

    .line 145
    const/4 v0, 0x0

    invoke-static {v0, p1}, Ljava/lang/Math;->max(II)I

    move-result p1

    .line 146
    invoke-static {v0, p2}, Ljava/lang/Math;->max(II)I

    move-result p2

    .line 147
    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v1

    add-int/lit8 v1, v1, -0x1

    invoke-static {v1, p3}, Ljava/lang/Math;->min(II)I

    move-result p3

    .line 148
    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v1

    add-int/lit8 v1, v1, -0x1

    invoke-static {v1, p4}, Ljava/lang/Math;->min(II)I

    move-result p4

    .line 149
    const/4 v1, 0x0

    if-le p3, p1, :cond_6c

    if-gt p4, p2, :cond_23

    goto :goto_6c

    .line 152
    :cond_23
    nop

    .line 153
    nop

    .line 154
    move v2, v0

    move v3, v2

    :goto_27
    const/16 v4, 0x8

    if-ge v2, v4, :cond_69

    .line 155
    sub-int v4, p4, p2

    mul-int/2addr v4, v2

    div-int/lit8 v4, v4, 0x7

    add-int/2addr v4, p2

    .line 156
    move v5, v0

    :goto_32
    const/16 v6, 0x18

    if-ge v5, v6, :cond_66

    .line 157
    sub-int v6, p3, p1

    mul-int/2addr v6, v5

    div-int/lit8 v6, v6, 0x17

    add-int/2addr v6, p1

    invoke-virtual {p0, v6, v4}, Landroid/graphics/Bitmap;->getPixel(II)I

    move-result v6

    .line 158
    invoke-static {v6}, Landroid/graphics/Color;->red(I)I

    move-result v7

    int-to-float v7, v7

    const v8, 0x3e59b3d0    # 0.2126f

    mul-float/2addr v7, v8

    invoke-static {v6}, Landroid/graphics/Color;->green(I)I

    move-result v8

    int-to-float v8, v8

    const v9, 0x3f371759    # 0.7152f

    mul-float/2addr v8, v9

    add-float/2addr v7, v8

    invoke-static {v6}, Landroid/graphics/Color;->blue(I)I

    move-result v6

    int-to-float v6, v6

    const v8, 0x3d93dd98    # 0.0722f

    mul-float/2addr v6, v8

    add-float/2addr v7, v6

    const/high16 v6, 0x437f0000    # 255.0f

    div-float/2addr v7, v6

    add-float/2addr v1, v7

    .line 159
    add-int/lit8 v3, v3, 0x1

    .line 156
    add-int/lit8 v5, v5, 0x1

    goto :goto_32

    .line 154
    :cond_66
    add-int/lit8 v2, v2, 0x1

    goto :goto_27

    .line 162
    :cond_69
    int-to-float p0, v3

    div-float/2addr v1, p0

    return v1

    .line 150
    :cond_6c
    :goto_6c
    return v1
.end method

.method private static parse(Ljava/lang/String;)F
    .registers 3

    .line 132
    invoke-virtual {p0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    const/high16 v1, 0x7fc00000    # Float.NaN

    if-eqz v0, :cond_9

    .line 133
    return v1

    .line 136
    :cond_9
    :try_start_9
    invoke-static {p0}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result p0
    :try_end_d
    .catch Ljava/lang/NumberFormatException; {:try_start_9 .. :try_end_d} :catch_1a

    .line 137
    const/4 v0, 0x0

    cmpl-float v0, p0, v0

    if-ltz v0, :cond_19

    const/high16 v0, 0x42c80000    # 100.0f

    cmpg-float v0, p0, v0

    if-gtz v0, :cond_19

    move v1, p0

    :cond_19
    return v1

    .line 138
    :catch_1a
    move-exception p0

    .line 139
    return v1
.end method


# virtual methods
.method public a(Landroid/graphics/Canvas;)V
    .registers 8

    .line 112
    invoke-virtual {p0}, Lcom/k4/homeclock/ClockNode;->showing()Z

    move-result v0

    if-nez v0, :cond_b

    .line 113
    const-string p1, ""

    iput-object p1, p0, Lcom/k4/homeclock/ClockNode;->lastDrawn:Ljava/lang/String;

    .line 114
    return-void

    .line 116
    :cond_b
    invoke-virtual {p0}, Lcom/k4/homeclock/ClockNode;->text()Ljava/lang/String;

    move-result-object v0

    .line 117
    iget-boolean v1, p0, Lcom/k4/homeclock/ClockNode;->accent:Z

    if-eqz v1, :cond_25

    .line 118
    iget-object v1, p0, Lcom/k4/homeclock/ClockNode;->a:Landroid/content/Context;

    iget-boolean v2, p0, Lcom/k4/homeclock/ClockNode;->lightBackground:Z

    if-eqz v2, :cond_1d

    const v2, 0x1060041

    goto :goto_20

    :cond_1d
    const v2, 0x1060039

    :goto_20
    invoke-virtual {v1, v2}, Landroid/content/Context;->getColor(I)I

    move-result v1

    goto :goto_2b

    .line 119
    :cond_25
    iget-object v1, p0, Lcom/k4/homeclock/ClockNode;->fixedColor:Ljava/lang/Integer;

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1

    .line 120
    :goto_2b
    iget-object v2, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    invoke-virtual {v2, v1}, Landroid/graphics/Paint;->setColor(I)V

    .line 121
    iget-object v1, p0, Lcom/k4/homeclock/ClockNode;->scaleRef:Li3/c;

    const/high16 v2, 0x3f800000    # 1.0f

    if-eqz v1, :cond_3b

    iget-object v1, p0, Lcom/k4/homeclock/ClockNode;->scaleRef:Li3/c;

    iget v1, v1, Li3/c;->e:F

    goto :goto_3c

    :cond_3b
    move v1, v2

    .line 122
    :goto_3c
    invoke-virtual {p1}, Landroid/graphics/Canvas;->save()I

    move-result v3

    .line 123
    cmpl-float v2, v1, v2

    if-eqz v2, :cond_5a

    const/4 v2, 0x0

    cmpl-float v2, v1, v2

    if-lez v2, :cond_5a

    .line 124
    invoke-virtual {p1}, Landroid/graphics/Canvas;->getWidth()I

    move-result v2

    int-to-float v2, v2

    const/high16 v4, 0x40000000    # 2.0f

    div-float/2addr v2, v4

    invoke-virtual {p1}, Landroid/graphics/Canvas;->getHeight()I

    move-result v5

    int-to-float v5, v5

    div-float/2addr v5, v4

    invoke-virtual {p1, v1, v1, v2, v5}, Landroid/graphics/Canvas;->scale(FFFF)V

    .line 126
    :cond_5a
    iget v1, p0, Lcom/k4/homeclock/ClockNode;->centerX:F

    iget v2, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    iget-object v4, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    invoke-virtual {p1, v0, v1, v2, v4}, Landroid/graphics/Canvas;->drawText(Ljava/lang/String;FFLandroid/graphics/Paint;)V

    .line 127
    invoke-virtual {p1, v3}, Landroid/graphics/Canvas;->restoreToCount(I)V

    .line 128
    iput-object v0, p0, Lcom/k4/homeclock/ClockNode;->lastDrawn:Ljava/lang/String;

    .line 129
    return-void
.end method

.method expected()Ljava/lang/String;
    .registers 2

    .line 107
    invoke-virtual {p0}, Lcom/k4/homeclock/ClockNode;->showing()Z

    move-result v0

    if-eqz v0, :cond_b

    invoke-virtual {p0}, Lcom/k4/homeclock/ClockNode;->text()Ljava/lang/String;

    move-result-object v0

    goto :goto_d

    :cond_b
    const-string v0, ""

    :goto_d
    return-object v0
.end method

.method showing()Z
    .registers 5

    .line 91
    iget-object v0, p0, Lcom/k4/homeclock/ClockNode;->owner:Lh3/a;

    const/4 v1, 0x1

    if-nez v0, :cond_6

    .line 92
    return v1

    .line 94
    :cond_6
    sget-boolean v0, Lcom/k4/homeclock/KeyguardWatch;->locked:Z

    const/4 v2, 0x0

    if-eqz v0, :cond_c

    .line 95
    return v2

    .line 97
    :cond_c
    iget-object v0, p0, Lcom/k4/homeclock/ClockNode;->owner:Lh3/a;

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->engineOf(Lh3/a;)Lf3/a;

    move-result-object v0

    .line 98
    if-nez v0, :cond_15

    .line 99
    return v2

    .line 101
    :cond_15
    invoke-virtual {v0}, Lf3/a;->getDisplayState()LB2/a;

    move-result-object v0

    .line 102
    instance-of v3, v0, Ljava/lang/Enum;

    if-eqz v3, :cond_2c

    check-cast v0, Ljava/lang/Enum;

    invoke-virtual {v0}, Ljava/lang/Enum;->name()Ljava/lang/String;

    move-result-object v0

    const-string v3, "ON"

    invoke-virtual {v3, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_2c

    goto :goto_2d

    :cond_2c
    move v1, v2

    :goto_2d
    return v1
.end method

.method text()Ljava/lang/String;
    .registers 4

    .line 85
    iget-object v0, p0, Lcom/k4/homeclock/ClockNode;->a:Landroid/content/Context;

    invoke-static {v0}, Landroid/text/format/DateFormat;->is24HourFormat(Landroid/content/Context;)Z

    move-result v0

    .line 86
    new-instance v1, Ljava/text/SimpleDateFormat;

    if-eqz v0, :cond_d

    const-string v0, "HH:mm"

    goto :goto_f

    :cond_d
    const-string v0, "h:mm"

    :goto_f
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v2

    invoke-direct {v1, v0, v2}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;Ljava/util/Locale;)V

    new-instance v0, Ljava/util/Date;

    invoke-direct {v0}, Ljava/util/Date;-><init>()V

    invoke-virtual {v1, v0}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
