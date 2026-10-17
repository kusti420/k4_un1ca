.class final Lcom/k4/homeclock/HomeClockPresenter;
.super Lh3/a;
.source "HomeClockPresenter.java"


# direct methods
.method constructor <init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V
    .registers 4

    .line 27
    invoke-direct {p0, p1, p2, p3}, Lh3/a;-><init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V

    .line 28
    return-void
.end method

.method private static create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;
    .registers 5

    .line 102
    if-nez p3, :cond_7

    .line 103
    invoke-static {p0, p1, p2}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;)Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0

    .line 105
    :cond_7
    invoke-static {p0, p1, p2, p4, p3}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;ZLandroid/graphics/ColorSpace;)Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0
.end method

.method static subjectTop(Li3/c;)F
    .registers 13

    .line 110
    const/high16 v0, -0x40800000    # -1.0f

    if-nez p0, :cond_5

    .line 111
    return v0

    .line 113
    :cond_5
    iget-object p0, p0, Li3/c;->c:Landroid/graphics/drawable/Drawable;

    .line 114
    instance-of v1, p0, Landroid/graphics/drawable/BitmapDrawable;

    if-nez v1, :cond_c

    .line 115
    return v0

    .line 117
    :cond_c
    move-object v1, p0

    check-cast v1, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v1}, Landroid/graphics/drawable/BitmapDrawable;->getBitmap()Landroid/graphics/Bitmap;

    move-result-object v2

    .line 118
    invoke-virtual {p0}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object p0

    .line 119
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

    .line 122
    :cond_2e
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v5

    .line 123
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v1

    .line 124
    new-array v3, v5, [I

    .line 125
    div-int/lit8 v4, v5, 0x64

    const/4 v6, 0x3

    invoke-static {v6, v4}, Ljava/lang/Math;->max(II)I

    move-result v10

    .line 126
    const/4 v11, 0x0

    move v7, v11

    :goto_41
    if-ge v7, v1, :cond_6f

    .line 127
    const/4 v6, 0x0

    const/4 v9, 0x1

    const/4 v4, 0x0

    move v8, v5

    invoke-virtual/range {v2 .. v9}, Landroid/graphics/Bitmap;->getPixels([IIIIIII)V

    .line 128
    nop

    .line 129
    move v4, v11

    move v6, v4

    :goto_4d
    if-ge v4, v5, :cond_6c

    .line 130
    aget v8, v3, v4

    ushr-int/lit8 v8, v8, 0x18

    const/16 v9, 0xa0

    if-le v8, v9, :cond_69

    add-int/lit8 v6, v6, 0x1

    if-lt v6, v10, :cond_69

    .line 131
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

    .line 129
    :cond_69
    add-int/lit8 v4, v4, 0x2

    goto :goto_4d

    .line 126
    :cond_6c
    add-int/lit8 v7, v7, 0x2

    goto :goto_41

    .line 135
    :cond_6f
    return v0

    .line 120
    :cond_70
    :goto_70
    return v0
.end method


# virtual methods
.method public a(Lcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;IILg0/a;)V
    .registers 27

    .line 32
    move-object/from16 v1, p0

    move/from16 v3, p2

    move/from16 v4, p3

    move-object/from16 v9, p4

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v10

    .line 33
    new-instance v0, Lh3/f;

    iget-object v2, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    iget v5, v1, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    move-object/from16 v6, p1

    invoke-direct {v0, v2, v5, v6}, Lh3/f;-><init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V

    .line 34
    invoke-virtual {v0, v3, v4}, Lh3/f;->e(II)V

    .line 35
    iget-object v12, v0, Lh3/f;->e:Lg0/a;

    .line 36
    iget-object v2, v9, Lg0/a;->b:Ljava/lang/Object;

    move-object v13, v2

    check-cast v13, Li3/k;

    .line 37
    const-string v14, "K4HomeClock"

    if-nez v12, :cond_2e

    .line 38
    const-string v1, "build: no presenter data"

    invoke-static {v14, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 39
    invoke-virtual {v0}, Lh3/f;->d()V

    .line 40
    return-void

    .line 42
    :cond_2e
    new-instance v15, Ljava/util/ArrayList;

    iget-object v2, v0, Lh3/f;->f:Li3/k;

    iget-object v2, v2, Li3/k;->c:Ljava/util/ArrayList;

    invoke-direct {v15, v2}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    .line 43
    iget-boolean v2, v12, Lg0/a;->a:Z

    iput-boolean v2, v9, Lg0/a;->a:Z

    .line 44
    iget-object v2, v12, Lg0/a;->f:Ljava/lang/Object;

    iput-object v2, v9, Lg0/a;->f:Ljava/lang/Object;

    .line 45
    iget-object v2, v12, Lg0/a;->g:Ljava/io/Serializable;

    iput-object v2, v9, Lg0/a;->g:Ljava/io/Serializable;

    .line 47
    :try_start_43
    iget-object v5, v12, Lg0/a;->d:Ljava/lang/Object;

    if-nez v5, :cond_49

    const/4 v5, -0x1

    goto :goto_4f

    :cond_49
    iget-object v5, v12, Lg0/a;->d:Ljava/lang/Object;

    invoke-virtual {v15, v5}, Ljava/util/ArrayList;->indexOf(Ljava/lang/Object;)I

    move-result v5

    .line 48
    :goto_4f
    iget-object v6, v12, Lg0/a;->g:Ljava/io/Serializable;

    instance-of v6, v6, Landroid/graphics/Bitmap$Config;

    if-eqz v6, :cond_5a

    iget-object v6, v12, Lg0/a;->g:Ljava/io/Serializable;

    check-cast v6, Landroid/graphics/Bitmap$Config;

    goto :goto_5c

    :cond_5a
    sget-object v6, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    .line 49
    :goto_5c
    iget-object v7, v12, Lg0/a;->f:Ljava/lang/Object;

    instance-of v7, v7, Landroid/graphics/ColorSpace;

    if-eqz v7, :cond_67

    iget-object v7, v12, Lg0/a;->f:Ljava/lang/Object;

    check-cast v7, Landroid/graphics/ColorSpace;

    goto :goto_68

    :cond_67
    const/4 v7, 0x0

    .line 50
    :goto_68
    const/4 v8, 0x0

    invoke-static {v3, v4, v6, v7, v8}, Lcom/k4/homeclock/HomeClockPresenter;->create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;

    move-result-object v2

    .line 51
    nop

    .line 52
    new-instance v8, Landroid/graphics/Canvas;

    invoke-direct {v8, v2}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    .line 53
    nop

    .line 54
    move-object/from16 v17, v0

    move-wide/from16 v18, v10

    const/4 v0, 0x0

    const/4 v10, 0x0

    const/4 v11, 0x0

    :goto_7b
    move-object/from16 v20, v11

    invoke-virtual {v15}, Ljava/util/ArrayList;->size()I

    move-result v11

    if-ge v0, v11, :cond_af

    .line 55
    invoke-virtual {v15, v0}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v11

    check-cast v11, Li3/j;

    .line 56
    if-ltz v5, :cond_a5

    if-lt v0, v5, :cond_a5

    .line 57
    if-nez v10, :cond_9c

    .line 58
    const/4 v10, 0x1

    invoke-static {v3, v4, v6, v7, v10}, Lcom/k4/homeclock/HomeClockPresenter;->create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;

    move-result-object v10

    .line 59
    move/from16 v21, v0

    new-instance v0, Landroid/graphics/Canvas;

    invoke-direct {v0, v10}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    goto :goto_a0

    .line 57
    :cond_9c
    move/from16 v21, v0

    move-object/from16 v0, v20

    .line 61
    :goto_a0
    invoke-virtual {v11, v0}, Li3/j;->a(Landroid/graphics/Canvas;)V

    move-object v11, v0

    goto :goto_ac

    .line 56
    :cond_a5
    move/from16 v21, v0

    .line 63
    invoke-virtual {v11, v8}, Li3/j;->a(Landroid/graphics/Canvas;)V

    move-object/from16 v11, v20

    .line 54
    :goto_ac
    add-int/lit8 v0, v21, 0x1

    goto :goto_7b

    .line 66
    :cond_af
    iget-object v0, v12, Lg0/a;->d:Ljava/lang/Object;

    instance-of v0, v0, Li3/c;

    if-eqz v0, :cond_ba

    iget-object v0, v12, Lg0/a;->d:Ljava/lang/Object;

    check-cast v0, Li3/c;

    goto :goto_bb

    :cond_ba
    const/4 v0, 0x0

    :goto_bb
    invoke-static {v0}, Lcom/k4/homeclock/HomeClockPresenter;->subjectTop(Li3/c;)F

    move-result v0

    .line 68
    new-instance v11, Landroid/graphics/Rect;

    const/4 v6, 0x0

    invoke-direct {v11, v6, v6, v3, v4}, Landroid/graphics/Rect;-><init>(IIII)V

    .line 69
    new-instance v6, Li3/c;

    iget-object v7, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    new-instance v8, Li3/b;
    :try_end_cb
    .catchall {:try_start_43 .. :try_end_cb} :catchall_186

    const/4 v3, 0x0

    :try_start_cc
    invoke-direct {v8, v2, v11, v11, v3}, Li3/b;-><init>(Landroid/graphics/Bitmap;Landroid/graphics/Rect;Landroid/graphics/Rect;Landroid/graphics/Point;)V
    :try_end_cf
    .catchall {:try_start_cc .. :try_end_cf} :catchall_17f

    :try_start_cf
    iget v3, v1, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    invoke-direct {v6, v7, v8, v3}, Li3/c;-><init>(Landroid/content/Context;Li3/b;I)V

    .line 70
    move-object v3, v6

    move-object v6, v2

    iget-object v2, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;
    :try_end_d8
    .catchall {:try_start_cf .. :try_end_d8} :catchall_186

    const/4 v7, 0x0

    const/4 v8, 0x0

    move/from16 p1, v5

    move v5, v0

    move/from16 v0, p1

    move-object/from16 v16, v12

    move-object/from16 p1, v15

    const/4 v12, 0x0

    move-object v15, v3

    move/from16 v3, p2

    :try_start_e7
    invoke-static/range {v2 .. v8}, Lcom/k4/homeclock/HomeDepthClock;->makeClock(Landroid/content/Context;IIFLandroid/graphics/Bitmap;Li3/c;Lh3/a;)Lcom/k4/homeclock/DepthClock;

    move-result-object v2

    .line 71
    invoke-static {v1, v2}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 72
    iput-object v15, v9, Lg0/a;->c:Ljava/lang/Object;

    .line 73
    iget-object v6, v13, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v6, v15}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 74
    iget-object v6, v13, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v6, v2}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 75
    if-eqz v10, :cond_10f

    .line 76
    iget-object v6, v13, Li3/k;->c:Ljava/util/ArrayList;

    new-instance v7, Li3/c;

    iget-object v8, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    new-instance v15, Li3/b;

    invoke-direct {v15, v10, v11, v11, v12}, Li3/b;-><init>(Landroid/graphics/Bitmap;Landroid/graphics/Rect;Landroid/graphics/Rect;Landroid/graphics/Point;)V

    iget v10, v1, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    invoke-direct {v7, v8, v15, v10}, Li3/c;-><init>(Landroid/content/Context;Li3/b;I)V

    invoke-virtual {v6, v7}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 78
    :cond_10f
    invoke-virtual/range {v17 .. v17}, Lh3/f;->d()V

    .line 79
    invoke-virtual/range {p1 .. p1}, Ljava/util/ArrayList;->size()I

    move-result v6

    .line 80
    invoke-virtual {v2}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object v2

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v7

    sub-long v7, v7, v18

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    const-string v11, "build: "

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v10, "x"

    invoke-virtual {v3, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ", layers="

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ", subjectAt="

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, ", subjectTop="

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, ", clock="

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, ", "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v7, v8}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, " ms"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 79
    invoke-static {v14, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_17c
    .catchall {:try_start_e7 .. :try_end_17c} :catchall_17d

    .line 92
    goto :goto_1bb

    .line 81
    :catchall_17d
    move-exception v0

    goto :goto_18c

    :catchall_17f
    move-exception v0

    move-object/from16 v16, v12

    move-object/from16 p1, v15

    move-object v12, v3

    goto :goto_18c

    :catchall_186
    move-exception v0

    move-object/from16 v16, v12

    move-object/from16 p1, v15

    const/4 v12, 0x0

    .line 83
    :goto_18c
    const-string v2, "build failed, showing the layers without a clock"

    invoke-static {v14, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 84
    invoke-static {v1, v12}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 85
    iget-object v0, v13, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    .line 86
    invoke-virtual/range {p1 .. p1}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_19d
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1ad

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    .line 87
    iget-object v2, v13, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v2, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 88
    goto :goto_19d

    .line 89
    :cond_1ad
    move-object/from16 v1, v16

    iget-object v0, v1, Lg0/a;->c:Ljava/lang/Object;

    iput-object v0, v9, Lg0/a;->c:Ljava/lang/Object;

    .line 90
    iget-object v0, v1, Lg0/a;->d:Ljava/lang/Object;

    iput-object v0, v9, Lg0/a;->d:Ljava/lang/Object;

    .line 91
    iget-object v0, v1, Lg0/a;->e:Ljava/io/Serializable;

    iput-object v0, v9, Lg0/a;->e:Ljava/io/Serializable;

    .line 93
    :goto_1bb
    return-void
.end method

.method public d()V
    .registers 2

    .line 97
    const/4 v0, 0x0

    invoke-static {p0, v0}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 98
    iget-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter;->f:Li3/k;

    invoke-virtual {v0}, Li3/k;->b()V

    .line 99
    return-void
.end method
