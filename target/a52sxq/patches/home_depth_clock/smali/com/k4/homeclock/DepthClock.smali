.class abstract Lcom/k4/homeclock/DepthClock;
.super Li3/j;
.source "DepthClock.java"


# instance fields
.field volatile lastDrawn:Ljava/lang/String;

.field final owner:Lh3/a;

.field final scaleRef:Li3/c;


# direct methods
.method constructor <init>(Landroid/content/Context;Ljava/lang/String;Li3/c;Lh3/a;)V
    .registers 5

    .line 25
    invoke-direct {p0, p1, p2}, Li3/j;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 22
    const-string p1, ""

    iput-object p1, p0, Lcom/k4/homeclock/DepthClock;->lastDrawn:Ljava/lang/String;

    .line 26
    iput-object p3, p0, Lcom/k4/homeclock/DepthClock;->scaleRef:Li3/c;

    .line 27
    iput-object p4, p0, Lcom/k4/homeclock/DepthClock;->owner:Lh3/a;

    .line 28
    return-void
.end method

.method static luminance(Landroid/graphics/Bitmap;IIII)F
    .registers 15

    .line 69
    const/high16 v0, -0x40800000    # -1.0f

    if-eqz p0, :cond_81

    invoke-virtual {p0}, Landroid/graphics/Bitmap;->isRecycled()Z

    move-result v1

    if-nez v1, :cond_81

    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getConfig()Landroid/graphics/Bitmap$Config;

    move-result-object v1

    sget-object v2, Landroid/graphics/Bitmap$Config;->HARDWARE:Landroid/graphics/Bitmap$Config;

    if-ne v1, v2, :cond_14

    goto/16 :goto_81

    .line 72
    :cond_14
    const/4 v1, 0x0

    invoke-static {v1, p1}, Ljava/lang/Math;->max(II)I

    move-result p1

    .line 73
    invoke-static {v1, p2}, Ljava/lang/Math;->max(II)I

    move-result p2

    .line 74
    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v2

    add-int/lit8 v2, v2, -0x1

    invoke-static {v2, p3}, Ljava/lang/Math;->min(II)I

    move-result p3

    .line 75
    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v2

    add-int/lit8 v2, v2, -0x1

    invoke-static {v2, p4}, Ljava/lang/Math;->min(II)I

    move-result p4

    .line 76
    if-le p3, p1, :cond_80

    if-gt p4, p2, :cond_36

    goto :goto_80

    .line 79
    :cond_36
    nop

    .line 80
    nop

    .line 81
    const/4 v0, 0x0

    move v2, v1

    move v3, v2

    :goto_3b
    const/16 v4, 0x8

    if-ge v2, v4, :cond_7d

    .line 82
    sub-int v4, p4, p2

    mul-int/2addr v4, v2

    div-int/lit8 v4, v4, 0x7

    add-int/2addr v4, p2

    .line 83
    move v5, v1

    :goto_46
    const/16 v6, 0x18

    if-ge v5, v6, :cond_7a

    .line 84
    sub-int v6, p3, p1

    mul-int/2addr v6, v5

    div-int/lit8 v6, v6, 0x17

    add-int/2addr v6, p1

    invoke-virtual {p0, v6, v4}, Landroid/graphics/Bitmap;->getPixel(II)I

    move-result v6

    .line 85
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

    add-float/2addr v0, v7

    .line 86
    add-int/lit8 v3, v3, 0x1

    .line 83
    add-int/lit8 v5, v5, 0x1

    goto :goto_46

    .line 81
    :cond_7a
    add-int/lit8 v2, v2, 0x1

    goto :goto_3b

    .line 89
    :cond_7d
    int-to-float p0, v3

    div-float/2addr v0, p0

    return v0

    .line 77
    :cond_80
    :goto_80
    return v0

    .line 70
    :cond_81
    :goto_81
    return v0
.end method

.method static meanColor(Landroid/graphics/Bitmap;IIII)I
    .registers 22

    .line 94
    move-object/from16 v0, p0

    const/4 v1, 0x0

    if-eqz v0, :cond_98

    invoke-virtual {v0}, Landroid/graphics/Bitmap;->isRecycled()Z

    move-result v2

    if-nez v2, :cond_98

    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getConfig()Landroid/graphics/Bitmap$Config;

    move-result-object v2

    sget-object v3, Landroid/graphics/Bitmap$Config;->HARDWARE:Landroid/graphics/Bitmap$Config;

    if-ne v2, v3, :cond_17

    move/from16 v16, v1

    goto/16 :goto_9a

    .line 97
    :cond_17
    move/from16 v2, p1

    invoke-static {v1, v2}, Ljava/lang/Math;->max(II)I

    move-result v2

    .line 98
    move/from16 v3, p2

    invoke-static {v1, v3}, Ljava/lang/Math;->max(II)I

    move-result v3

    .line 99
    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v4

    add-int/lit8 v4, v4, -0x1

    move/from16 v5, p3

    invoke-static {v4, v5}, Ljava/lang/Math;->min(II)I

    move-result v4

    .line 100
    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v5

    add-int/lit8 v5, v5, -0x1

    move/from16 v6, p4

    invoke-static {v5, v6}, Ljava/lang/Math;->min(II)I

    move-result v5

    .line 101
    if-le v4, v2, :cond_95

    if-gt v5, v3, :cond_42

    move/from16 v16, v1

    goto :goto_97

    .line 104
    :cond_42
    nop

    .line 105
    nop

    .line 106
    const-wide/16 v6, 0x0

    move v12, v1

    move v13, v12

    move-wide v8, v6

    move-wide v10, v8

    :goto_4a
    const/16 v14, 0x8

    if-ge v12, v14, :cond_89

    .line 107
    sub-int v14, v5, v3

    mul-int/2addr v14, v12

    div-int/lit8 v14, v14, 0x7

    add-int/2addr v14, v3

    .line 108
    move v15, v1

    :goto_55
    move/from16 v16, v1

    const/16 v1, 0x18

    if-ge v15, v1, :cond_82

    .line 109
    sub-int v1, v4, v2

    mul-int/2addr v1, v15

    div-int/lit8 v1, v1, 0x17

    add-int/2addr v1, v2

    invoke-virtual {v0, v1, v14}, Landroid/graphics/Bitmap;->getPixel(II)I

    move-result v1

    .line 110
    invoke-static {v1}, Landroid/graphics/Color;->red(I)I

    move-result v0

    move/from16 p1, v1

    int-to-long v0, v0

    add-long/2addr v6, v0

    .line 111
    invoke-static/range {p1 .. p1}, Landroid/graphics/Color;->green(I)I

    move-result v0

    int-to-long v0, v0

    add-long/2addr v8, v0

    .line 112
    invoke-static/range {p1 .. p1}, Landroid/graphics/Color;->blue(I)I

    move-result v0

    int-to-long v0, v0

    add-long/2addr v10, v0

    .line 113
    add-int/lit8 v13, v13, 0x1

    .line 108
    add-int/lit8 v15, v15, 0x1

    move-object/from16 v0, p0

    move/from16 v1, v16

    goto :goto_55

    .line 106
    :cond_82
    add-int/lit8 v12, v12, 0x1

    move-object/from16 v0, p0

    move/from16 v1, v16

    goto :goto_4a

    .line 116
    :cond_89
    int-to-long v0, v13

    div-long/2addr v6, v0

    long-to-int v2, v6

    div-long/2addr v8, v0

    long-to-int v3, v8

    div-long/2addr v10, v0

    long-to-int v0, v10

    invoke-static {v2, v3, v0}, Landroid/graphics/Color;->rgb(III)I

    move-result v0

    return v0

    .line 101
    :cond_95
    move/from16 v16, v1

    .line 102
    :goto_97
    return v16

    .line 94
    :cond_98
    move/from16 v16, v1

    .line 95
    :goto_9a
    return v16
.end method


# virtual methods
.method expected()Ljava/lang/String;
    .registers 2

    .line 54
    invoke-virtual {p0}, Lcom/k4/homeclock/DepthClock;->showing()Z

    move-result v0

    if-eqz v0, :cond_b

    invoke-virtual {p0}, Lcom/k4/homeclock/DepthClock;->text()Ljava/lang/String;

    move-result-object v0

    goto :goto_d

    :cond_b
    const-string v0, ""

    :goto_d
    return-object v0
.end method

.method release()V
    .registers 1

    .line 59
    return-void
.end method

.method showing()Z
    .registers 5

    .line 38
    iget-object v0, p0, Lcom/k4/homeclock/DepthClock;->owner:Lh3/a;

    const/4 v1, 0x1

    if-nez v0, :cond_6

    .line 39
    return v1

    .line 41
    :cond_6
    sget-boolean v0, Lcom/k4/homeclock/KeyguardWatch;->locked:Z

    const/4 v2, 0x0

    if-eqz v0, :cond_c

    .line 42
    return v2

    .line 44
    :cond_c
    iget-object v0, p0, Lcom/k4/homeclock/DepthClock;->owner:Lh3/a;

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->engineOf(Lh3/a;)Lf3/a;

    move-result-object v0

    .line 45
    if-nez v0, :cond_15

    .line 46
    return v2

    .line 48
    :cond_15
    invoke-virtual {v0}, Lf3/a;->getDisplayState()LB2/a;

    move-result-object v0

    .line 49
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

    .line 32
    iget-object v0, p0, Lcom/k4/homeclock/DepthClock;->a:Landroid/content/Context;

    invoke-static {v0}, Landroid/text/format/DateFormat;->is24HourFormat(Landroid/content/Context;)Z

    move-result v0

    .line 33
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

.method zoom()F
    .registers 4

    .line 63
    iget-object v0, p0, Lcom/k4/homeclock/DepthClock;->scaleRef:Li3/c;

    const/high16 v1, 0x3f800000    # 1.0f

    if-eqz v0, :cond_b

    iget-object v0, p0, Lcom/k4/homeclock/DepthClock;->scaleRef:Li3/c;

    iget v0, v0, Li3/c;->e:F

    goto :goto_c

    :cond_b
    move v0, v1

    .line 64
    :goto_c
    const/4 v2, 0x0

    cmpl-float v2, v0, v2

    if-lez v2, :cond_12

    move v1, v0

    :cond_12
    return v1
.end method
