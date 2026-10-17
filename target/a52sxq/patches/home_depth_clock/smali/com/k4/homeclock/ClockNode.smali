.class final Lcom/k4/homeclock/ClockNode;
.super Li3/j;
.source "ClockNode.java"


# instance fields
.field private final baseline:F

.field private final centerX:F

.field private final fixedColor:Ljava/lang/Integer;

.field volatile lastDrawn:Ljava/lang/String;

.field private final lightBackground:Z

.field private final paint:Landroid/graphics/Paint;


# direct methods
.method constructor <init>(Landroid/content/Context;IIFLandroid/graphics/Bitmap;)V
    .registers 12

    .line 35
    const-string v0, "K4DepthClockNode"

    invoke-direct {p0, p1, v0}, Li3/j;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 27
    new-instance p1, Landroid/graphics/Paint;

    const/16 v0, 0x81

    invoke-direct {p1, v0}, Landroid/graphics/Paint;-><init>(I)V

    iput-object p1, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    .line 32
    const-string p1, ""

    iput-object p1, p0, Lcom/k4/homeclock/ClockNode;->lastDrawn:Ljava/lang/String;

    .line 36
    iget-object p1, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    sget-object v0, Landroid/graphics/Typeface;->DEFAULT:Landroid/graphics/Typeface;

    const/16 v1, 0x1f4

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Landroid/graphics/Typeface;->create(Landroid/graphics/Typeface;IZ)Landroid/graphics/Typeface;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroid/graphics/Paint;->setTypeface(Landroid/graphics/Typeface;)Landroid/graphics/Typeface;

    .line 37
    iget-object p1, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    sget-object v0, Landroid/graphics/Paint$Align;->CENTER:Landroid/graphics/Paint$Align;

    invoke-virtual {p1, v0}, Landroid/graphics/Paint;->setTextAlign(Landroid/graphics/Paint$Align;)V

    .line 38
    iget-object p1, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    const-string v0, "tnum"

    invoke-virtual {p1, v0}, Landroid/graphics/Paint;->setFontFeatureSettings(Ljava/lang/String;)V

    .line 39
    iget-object p1, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    const/high16 v0, 0x42c80000    # 100.0f

    invoke-virtual {p1, v0}, Landroid/graphics/Paint;->setTextSize(F)V

    .line 40
    if-gt p2, p3, :cond_3b

    const p1, 0x3f570a3d    # 0.84f

    goto :goto_3e

    :cond_3b
    const p1, 0x3ed70a3d    # 0.42f

    :goto_3e
    int-to-float p2, p2

    mul-float/2addr p1, p2

    .line 41
    iget-object v1, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    mul-float v3, p1, v0

    iget-object v4, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    const-string v5, "00:00"

    invoke-virtual {v4, v5}, Landroid/graphics/Paint;->measureText(Ljava/lang/String;)F

    move-result v4

    div-float/2addr v3, v4

    invoke-virtual {v1, v3}, Landroid/graphics/Paint;->setTextSize(F)V

    .line 42
    new-instance v1, Landroid/graphics/Rect;

    invoke-direct {v1}, Landroid/graphics/Rect;-><init>()V

    .line 43
    iget-object v3, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    const-string v4, "0123456789"

    const/16 v5, 0xa

    invoke-virtual {v3, v4, v2, v5, v1}, Landroid/graphics/Paint;->getTextBounds(Ljava/lang/String;IILandroid/graphics/Rect;)V

    .line 44
    iget v1, v1, Landroid/graphics/Rect;->top:I

    neg-int v1, v1

    int-to-float v1, v1

    .line 46
    const-string v3, "persist.sys.k4.home_depth_clock_y"

    invoke-static {v3}, Lcom/k4/homeclock/HomeDepthClock;->prop(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Lcom/k4/homeclock/ClockNode;->parse(Ljava/lang/String;)F

    move-result v3

    .line 47
    invoke-static {v3}, Ljava/lang/Float;->isNaN(F)Z

    move-result v4

    const/high16 v5, 0x40000000    # 2.0f

    if-nez v4, :cond_85

    .line 48
    int-to-float p3, p3

    mul-float/2addr v3, p3

    div-float/2addr v3, v0

    div-float v0, v1, v5

    add-float/2addr v3, v0

    invoke-static {v1, v3}, Ljava/lang/Math;->max(FF)F

    move-result v0

    invoke-static {p3, v0}, Ljava/lang/Math;->min(FF)F

    move-result p3

    iput p3, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    goto :goto_b0

    .line 50
    :cond_85
    const/4 v0, 0x0

    cmpl-float v0, p4, v0

    if-ltz v0, :cond_90

    const v0, 0x3eb33333    # 0.35f

    mul-float/2addr v0, v1

    add-float/2addr v0, p4

    goto :goto_98

    :cond_90
    const v0, 0x3e99999a    # 0.3f

    int-to-float v3, p3

    mul-float/2addr v3, v0

    div-float v0, v1, v5

    add-float/2addr v0, v3

    .line 51
    :goto_98
    int-to-float p3, p3

    const v3, 0x3dcccccd    # 0.1f

    mul-float/2addr v3, p3

    add-float/2addr v3, v1

    .line 52
    const v4, 0x3ee66666    # 0.45f

    mul-float/2addr p3, v4

    invoke-static {v3, p3}, Ljava/lang/Math;->max(FF)F

    move-result p3

    .line 53
    invoke-static {v3, v0}, Ljava/lang/Math;->max(FF)F

    move-result v0

    invoke-static {p3, v0}, Ljava/lang/Math;->min(FF)F

    move-result p3

    iput p3, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    .line 55
    :goto_b0
    div-float/2addr p2, v5

    iput p2, p0, Lcom/k4/homeclock/ClockNode;->centerX:F

    .line 57
    iget p2, p0, Lcom/k4/homeclock/ClockNode;->centerX:F

    div-float/2addr p1, v5

    sub-float/2addr p2, p1

    float-to-int p2, p2

    iget p3, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    sub-float/2addr p3, v1

    float-to-int p3, p3

    iget v0, p0, Lcom/k4/homeclock/ClockNode;->centerX:F

    add-float/2addr v0, p1

    float-to-int p1, v0

    iget v0, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    float-to-int v0, v0

    invoke-static {p5, p2, p3, p1, v0}, Lcom/k4/homeclock/ClockNode;->luminance(Landroid/graphics/Bitmap;IIII)F

    move-result p1

    const p2, 0x3f19999a    # 0.6f

    cmpl-float p1, p1, p2

    if-lez p1, :cond_cf

    const/4 v2, 0x1

    :cond_cf
    iput-boolean v2, p0, Lcom/k4/homeclock/ClockNode;->lightBackground:Z

    .line 59
    nop

    .line 60
    const-string p1, "persist.sys.k4.home_depth_clock_color"

    invoke-static {p1}, Lcom/k4/homeclock/HomeDepthClock;->prop(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 61
    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    move-result p2

    if-nez p2, :cond_e8

    .line 63
    :try_start_de
    invoke-static {p1}, Landroid/graphics/Color;->parseColor(Ljava/lang/String;)I

    move-result p1

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1
    :try_end_e6
    .catch Ljava/lang/IllegalArgumentException; {:try_start_de .. :try_end_e6} :catch_e7

    .line 65
    goto :goto_e9

    .line 64
    :catch_e7
    move-exception p1

    .line 67
    :cond_e8
    const/4 p1, 0x0

    :goto_e9
    iput-object p1, p0, Lcom/k4/homeclock/ClockNode;->fixedColor:Ljava/lang/Integer;

    .line 68
    iget-object p1, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    invoke-virtual {p1}, Landroid/graphics/Paint;->getTextSize()F

    move-result p1

    iget p2, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    iget-boolean p3, p0, Lcom/k4/homeclock/ClockNode;->lightBackground:Z

    new-instance p5, Ljava/lang/StringBuilder;

    invoke-direct {p5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "layout: textSize="

    invoke-virtual {p5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p5

    invoke-virtual {p5, p1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p5, ", digitH="

    invoke-virtual {p1, p5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p5, ", baseline="

    invoke-virtual {p1, p5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p2, " (subjectTop="

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p4}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p2, "), lightBg="

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p3}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string p2, "K4HomeClock"

    invoke-static {p2, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 70
    return-void
.end method

.method private static luminance(Landroid/graphics/Bitmap;IIII)F
    .registers 15

    .line 105
    const/4 v0, 0x0

    invoke-static {v0, p1}, Ljava/lang/Math;->max(II)I

    move-result p1

    .line 106
    invoke-static {v0, p2}, Ljava/lang/Math;->max(II)I

    move-result p2

    .line 107
    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v1

    add-int/lit8 v1, v1, -0x1

    invoke-static {v1, p3}, Ljava/lang/Math;->min(II)I

    move-result p3

    .line 108
    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v1

    add-int/lit8 v1, v1, -0x1

    invoke-static {v1, p4}, Ljava/lang/Math;->min(II)I

    move-result p4

    .line 109
    const/4 v1, 0x0

    if-le p3, p1, :cond_6c

    if-gt p4, p2, :cond_23

    goto :goto_6c

    .line 112
    :cond_23
    nop

    .line 113
    nop

    .line 114
    move v2, v0

    move v3, v2

    :goto_27
    const/16 v4, 0x8

    if-ge v2, v4, :cond_69

    .line 115
    sub-int v4, p4, p2

    mul-int/2addr v4, v2

    div-int/lit8 v4, v4, 0x7

    add-int/2addr v4, p2

    .line 116
    move v5, v0

    :goto_32
    const/16 v6, 0x18

    if-ge v5, v6, :cond_66

    .line 117
    sub-int v6, p3, p1

    mul-int/2addr v6, v5

    div-int/lit8 v6, v6, 0x17

    add-int/2addr v6, p1

    invoke-virtual {p0, v6, v4}, Landroid/graphics/Bitmap;->getPixel(II)I

    move-result v6

    .line 118
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

    .line 119
    add-int/lit8 v3, v3, 0x1

    .line 116
    add-int/lit8 v5, v5, 0x1

    goto :goto_32

    .line 114
    :cond_66
    add-int/lit8 v2, v2, 0x1

    goto :goto_27

    .line 122
    :cond_69
    int-to-float p0, v3

    div-float/2addr v1, p0

    return v1

    .line 110
    :cond_6c
    :goto_6c
    return v1
.end method

.method private static parse(Ljava/lang/String;)F
    .registers 3

    .line 92
    invoke-virtual {p0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    const/high16 v1, 0x7fc00000    # Float.NaN

    if-eqz v0, :cond_9

    .line 93
    return v1

    .line 96
    :cond_9
    :try_start_9
    invoke-static {p0}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result p0
    :try_end_d
    .catch Ljava/lang/NumberFormatException; {:try_start_9 .. :try_end_d} :catch_1a

    .line 97
    const/4 v0, 0x0

    cmpl-float v0, p0, v0

    if-ltz v0, :cond_19

    const/high16 v0, 0x42c80000    # 100.0f

    cmpg-float v0, p0, v0

    if-gtz v0, :cond_19

    move v1, p0

    :cond_19
    return v1

    .line 98
    :catch_1a
    move-exception p0

    .line 99
    return v1
.end method


# virtual methods
.method public a(Landroid/graphics/Canvas;)V
    .registers 6

    .line 79
    invoke-virtual {p0}, Lcom/k4/homeclock/ClockNode;->text()Ljava/lang/String;

    move-result-object v0

    .line 81
    iget-object v1, p0, Lcom/k4/homeclock/ClockNode;->fixedColor:Ljava/lang/Integer;

    if-eqz v1, :cond_f

    .line 82
    iget-object v1, p0, Lcom/k4/homeclock/ClockNode;->fixedColor:Ljava/lang/Integer;

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1

    goto :goto_20

    .line 84
    :cond_f
    iget-object v1, p0, Lcom/k4/homeclock/ClockNode;->a:Landroid/content/Context;

    iget-boolean v2, p0, Lcom/k4/homeclock/ClockNode;->lightBackground:Z

    if-eqz v2, :cond_19

    const v2, 0x1060041

    goto :goto_1c

    :cond_19
    const v2, 0x1060039

    :goto_1c
    invoke-virtual {v1, v2}, Landroid/content/Context;->getColor(I)I

    move-result v1

    .line 86
    :goto_20
    iget-object v2, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    invoke-virtual {v2, v1}, Landroid/graphics/Paint;->setColor(I)V

    .line 87
    iget v1, p0, Lcom/k4/homeclock/ClockNode;->centerX:F

    iget v2, p0, Lcom/k4/homeclock/ClockNode;->baseline:F

    iget-object v3, p0, Lcom/k4/homeclock/ClockNode;->paint:Landroid/graphics/Paint;

    invoke-virtual {p1, v0, v1, v2, v3}, Landroid/graphics/Canvas;->drawText(Ljava/lang/String;FFLandroid/graphics/Paint;)V

    .line 88
    iput-object v0, p0, Lcom/k4/homeclock/ClockNode;->lastDrawn:Ljava/lang/String;

    .line 89
    return-void
.end method

.method text()Ljava/lang/String;
    .registers 4

    .line 73
    iget-object v0, p0, Lcom/k4/homeclock/ClockNode;->a:Landroid/content/Context;

    invoke-static {v0}, Landroid/text/format/DateFormat;->is24HourFormat(Landroid/content/Context;)Z

    move-result v0

    .line 74
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
