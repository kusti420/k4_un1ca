.class final Lcom/k4/homeclock/HomeClockPresenter;
.super Lh3/a;
.source "HomeClockPresenter.java"


# instance fields
.field volatile clock:Lcom/k4/homeclock/ClockNode;

.field final ticker:Lcom/k4/homeclock/Ticker;


# direct methods
.method constructor <init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V
    .registers 4

    .line 30
    invoke-direct {p0, p1, p2, p3}, Lh3/a;-><init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V

    .line 31
    new-instance p1, Lcom/k4/homeclock/Ticker;

    invoke-direct {p1, p0}, Lcom/k4/homeclock/Ticker;-><init>(Lcom/k4/homeclock/HomeClockPresenter;)V

    iput-object p1, p0, Lcom/k4/homeclock/HomeClockPresenter;->ticker:Lcom/k4/homeclock/Ticker;

    .line 32
    return-void
.end method

.method private static create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;
    .registers 5

    .line 106
    if-nez p3, :cond_7

    .line 107
    invoke-static {p0, p1, p2}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;)Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0

    .line 109
    :cond_7
    invoke-static {p0, p1, p2, p4, p3}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;ZLandroid/graphics/ColorSpace;)Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0
.end method

.method private static subjectTop(Li3/c;)F
    .registers 13

    .line 114
    const/high16 v0, -0x40800000    # -1.0f

    if-nez p0, :cond_5

    .line 115
    return v0

    .line 117
    :cond_5
    iget-object p0, p0, Li3/c;->c:Landroid/graphics/drawable/Drawable;

    .line 118
    instance-of v1, p0, Landroid/graphics/drawable/BitmapDrawable;

    if-nez v1, :cond_c

    .line 119
    return v0

    .line 121
    :cond_c
    move-object v1, p0

    check-cast v1, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v1}, Landroid/graphics/drawable/BitmapDrawable;->getBitmap()Landroid/graphics/Bitmap;

    move-result-object v2

    .line 122
    invoke-virtual {p0}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object p0

    .line 123
    if-eqz v2, :cond_70

    invoke-virtual {v2}, Landroid/graphics/Bitmap;->isRecycled()Z

    move-result v1

    if-nez v1, :cond_70

    invoke-virtual {p0}, Landroid/graphics/Rect;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_70

    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getConfig()Landroid/graphics/Bitmap$Config;

    move-result-object v1

    sget-object v3, Landroid/graphics/Bitmap$Config;->HARDWARE:Landroid/graphics/Bitmap$Config;

    if-ne v1, v3, :cond_2e

    goto :goto_70

    .line 126
    :cond_2e
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v5

    .line 127
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v1

    .line 128
    new-array v3, v5, [I

    .line 129
    div-int/lit8 v4, v5, 0x64

    const/4 v6, 0x3

    invoke-static {v6, v4}, Ljava/lang/Math;->max(II)I

    move-result v10

    .line 130
    const/4 v11, 0x0

    move v7, v11

    :goto_41
    if-ge v7, v1, :cond_6f

    .line 131
    const/4 v6, 0x0

    const/4 v9, 0x1

    const/4 v4, 0x0

    move v8, v5

    invoke-virtual/range {v2 .. v9}, Landroid/graphics/Bitmap;->getPixels([IIIIIII)V

    .line 132
    nop

    .line 133
    move v4, v11

    move v6, v4

    :goto_4d
    if-ge v4, v5, :cond_6c

    .line 134
    aget v8, v3, v4

    ushr-int/lit8 v8, v8, 0x18

    const/16 v9, 0xa0

    if-le v8, v9, :cond_69

    add-int/lit8 v6, v6, 0x1

    if-lt v6, v10, :cond_69

    .line 135
    iget v0, p0, Landroid/graphics/Rect;->top:I

    int-to-float v0, v0

    int-to-float v2, v7

    invoke-virtual {p0}, Landroid/graphics/Rect;->height()I

    move-result p0

    int-to-float p0, p0

    mul-float/2addr v2, p0

    int-to-float p0, v1

    div-float/2addr v2, p0

    add-float/2addr v0, v2

    return v0

    .line 133
    :cond_69
    add-int/lit8 v4, v4, 0x2

    goto :goto_4d

    .line 130
    :cond_6c
    add-int/lit8 v7, v7, 0x2

    goto :goto_41

    .line 139
    :cond_6f
    return v0

    .line 124
    :cond_70
    :goto_70
    return v0
.end method


# virtual methods
.method public a(Lcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;IILg0/a;)V
    .registers 27

    .line 36
    move-object/from16 v1, p0

    move/from16 v4, p2

    move/from16 v5, p3

    move-object/from16 v8, p4

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v9

    .line 37
    new-instance v0, Lh3/f;

    iget-object v2, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    iget v3, v1, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    move-object/from16 v6, p1

    invoke-direct {v0, v2, v3, v6}, Lh3/f;-><init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V

    .line 38
    invoke-virtual {v0, v4, v5}, Lh3/f;->e(II)V

    .line 39
    iget-object v11, v0, Lh3/f;->e:Lg0/a;

    .line 40
    iget-object v2, v8, Lg0/a;->b:Ljava/lang/Object;

    move-object v12, v2

    check-cast v12, Li3/k;

    .line 41
    const-string v13, "K4HomeClock"

    if-nez v11, :cond_2e

    .line 42
    const-string v1, "build: no presenter data"

    invoke-static {v13, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 43
    invoke-virtual {v0}, Lh3/f;->d()V

    .line 44
    return-void

    .line 46
    :cond_2e
    new-instance v14, Ljava/util/ArrayList;

    iget-object v2, v0, Lh3/f;->f:Li3/k;

    iget-object v2, v2, Li3/k;->c:Ljava/util/ArrayList;

    invoke-direct {v14, v2}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    .line 47
    iget-boolean v2, v11, Lg0/a;->a:Z

    iput-boolean v2, v8, Lg0/a;->a:Z

    .line 48
    iget-object v2, v11, Lg0/a;->f:Ljava/lang/Object;

    iput-object v2, v8, Lg0/a;->f:Ljava/lang/Object;

    .line 49
    iget-object v2, v11, Lg0/a;->g:Ljava/io/Serializable;

    iput-object v2, v8, Lg0/a;->g:Ljava/io/Serializable;

    .line 51
    :try_start_43
    iget-object v2, v11, Lg0/a;->d:Ljava/lang/Object;

    if-nez v2, :cond_49

    const/4 v2, -0x1

    goto :goto_4f

    :cond_49
    iget-object v2, v11, Lg0/a;->d:Ljava/lang/Object;

    invoke-virtual {v14, v2}, Ljava/util/ArrayList;->indexOf(Ljava/lang/Object;)I

    move-result v2

    .line 52
    :goto_4f
    iget-object v3, v11, Lg0/a;->g:Ljava/io/Serializable;

    instance-of v3, v3, Landroid/graphics/Bitmap$Config;

    if-eqz v3, :cond_5a

    iget-object v3, v11, Lg0/a;->g:Ljava/io/Serializable;

    check-cast v3, Landroid/graphics/Bitmap$Config;

    goto :goto_5c

    :cond_5a
    sget-object v3, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    .line 53
    :goto_5c
    iget-object v6, v11, Lg0/a;->f:Ljava/lang/Object;

    instance-of v6, v6, Landroid/graphics/ColorSpace;

    if-eqz v6, :cond_67

    iget-object v6, v11, Lg0/a;->f:Ljava/lang/Object;

    check-cast v6, Landroid/graphics/ColorSpace;

    goto :goto_68

    :cond_67
    const/4 v6, 0x0

    .line 54
    :goto_68
    const/4 v7, 0x0

    invoke-static {v4, v5, v3, v6, v7}, Lcom/k4/homeclock/HomeClockPresenter;->create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;

    move-result-object v15

    .line 55
    nop

    .line 56
    new-instance v7, Landroid/graphics/Canvas;

    invoke-direct {v7, v15}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    .line 57
    nop

    .line 58
    move-object/from16 v17, v0

    move-wide/from16 v19, v9

    const/4 v0, 0x0

    const/4 v9, 0x0

    const/16 v18, 0x0

    :goto_7c
    invoke-virtual {v14}, Ljava/util/ArrayList;->size()I

    move-result v10

    if-ge v9, v10, :cond_af

    .line 59
    invoke-virtual {v14, v9}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Li3/j;

    .line 60
    if-ltz v2, :cond_a5

    if-lt v9, v2, :cond_a5

    .line 61
    if-nez v0, :cond_9b

    .line 62
    const/4 v0, 0x1

    invoke-static {v4, v5, v3, v6, v0}, Lcom/k4/homeclock/HomeClockPresenter;->create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;

    move-result-object v0

    .line 63
    move/from16 v21, v2

    new-instance v2, Landroid/graphics/Canvas;

    invoke-direct {v2, v0}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    goto :goto_9f

    .line 61
    :cond_9b
    move/from16 v21, v2

    move-object/from16 v2, v18

    .line 65
    :goto_9f
    invoke-virtual {v10, v2}, Li3/j;->a(Landroid/graphics/Canvas;)V

    move-object/from16 v18, v2

    goto :goto_aa

    .line 60
    :cond_a5
    move/from16 v21, v2

    .line 67
    invoke-virtual {v10, v7}, Li3/j;->a(Landroid/graphics/Canvas;)V

    .line 58
    :goto_aa
    add-int/lit8 v9, v9, 0x1

    move/from16 v2, v21

    goto :goto_7c

    .line 70
    :cond_af
    move/from16 v21, v2

    iget-object v2, v11, Lg0/a;->d:Ljava/lang/Object;

    instance-of v2, v2, Li3/c;

    if-eqz v2, :cond_bc

    iget-object v2, v11, Lg0/a;->d:Ljava/lang/Object;

    check-cast v2, Li3/c;

    goto :goto_bd

    :cond_bc
    const/4 v2, 0x0

    :goto_bd
    invoke-static {v2}, Lcom/k4/homeclock/HomeClockPresenter;->subjectTop(Li3/c;)F

    move-result v6

    .line 72
    new-instance v9, Landroid/graphics/Rect;

    const/4 v2, 0x0

    invoke-direct {v9, v2, v2, v4, v5}, Landroid/graphics/Rect;-><init>(IIII)V

    .line 73
    new-instance v10, Li3/c;

    iget-object v2, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    new-instance v3, Li3/b;

    const/4 v7, 0x0

    invoke-direct {v3, v15, v9, v9, v7}, Li3/b;-><init>(Landroid/graphics/Bitmap;Landroid/graphics/Rect;Landroid/graphics/Rect;Landroid/graphics/Point;)V

    iget v7, v1, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    invoke-direct {v10, v2, v3, v7}, Li3/c;-><init>(Landroid/content/Context;Li3/b;I)V

    .line 74
    new-instance v2, Lcom/k4/homeclock/ClockNode;

    iget-object v3, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    move-object v7, v15

    move/from16 v15, v21

    invoke-direct/range {v2 .. v7}, Lcom/k4/homeclock/ClockNode;-><init>(Landroid/content/Context;IIFLandroid/graphics/Bitmap;)V

    .line 75
    iput-object v10, v8, Lg0/a;->c:Ljava/lang/Object;

    .line 76
    iget-object v3, v12, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v3, v10}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 77
    iget-object v3, v12, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v3, v2}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 78
    if-eqz v0, :cond_105

    .line 79
    iget-object v3, v12, Li3/k;->c:Ljava/util/ArrayList;

    new-instance v7, Li3/c;

    iget-object v10, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;
    :try_end_f4
    .catchall {:try_start_43 .. :try_end_f4} :catchall_167

    move-object/from16 v16, v14

    :try_start_f6
    new-instance v14, Li3/b;

    const/4 v8, 0x0

    invoke-direct {v14, v0, v9, v9, v8}, Li3/b;-><init>(Landroid/graphics/Bitmap;Landroid/graphics/Rect;Landroid/graphics/Rect;Landroid/graphics/Point;)V

    iget v0, v1, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    invoke-direct {v7, v10, v14, v0}, Li3/c;-><init>(Landroid/content/Context;Li3/b;I)V

    invoke-virtual {v3, v7}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_107

    .line 78
    :cond_105
    move-object/from16 v16, v14

    .line 81
    :goto_107
    iput-object v2, v1, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/ClockNode;

    .line 82
    invoke-virtual/range {v17 .. v17}, Lh3/f;->d()V

    .line 83
    invoke-virtual/range {v16 .. v16}, Ljava/util/ArrayList;->size()I

    move-result v0

    .line 84
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v2

    sub-long v2, v2, v19

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "build: "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v7, "x"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, ", layers="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v4, ", subjectAt="

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v15}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v4, ", subjectTop="

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v4, ", "

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, " ms"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 83
    invoke-static {v13, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_164
    .catchall {:try_start_f6 .. :try_end_164} :catchall_165

    .line 96
    goto :goto_199

    .line 85
    :catchall_165
    move-exception v0

    goto :goto_16a

    :catchall_167
    move-exception v0

    move-object/from16 v16, v14

    .line 87
    :goto_16a
    const-string v2, "build failed, showing the layers without a clock"

    invoke-static {v13, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 88
    const/4 v7, 0x0

    iput-object v7, v1, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/ClockNode;

    .line 89
    iget-object v0, v12, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    .line 90
    invoke-virtual/range {v16 .. v16}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_17b
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_18b

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    .line 91
    iget-object v2, v12, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v2, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 92
    goto :goto_17b

    .line 93
    :cond_18b
    iget-object v0, v11, Lg0/a;->c:Ljava/lang/Object;

    move-object/from16 v8, p4

    iput-object v0, v8, Lg0/a;->c:Ljava/lang/Object;

    .line 94
    iget-object v0, v11, Lg0/a;->d:Ljava/lang/Object;

    iput-object v0, v8, Lg0/a;->d:Ljava/lang/Object;

    .line 95
    iget-object v0, v11, Lg0/a;->e:Ljava/io/Serializable;

    iput-object v0, v8, Lg0/a;->e:Ljava/io/Serializable;

    .line 97
    :goto_199
    return-void
.end method

.method public d()V
    .registers 2

    .line 101
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/ClockNode;

    .line 102
    iget-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter;->f:Li3/k;

    invoke-virtual {v0}, Li3/k;->b()V

    .line 103
    return-void
.end method
