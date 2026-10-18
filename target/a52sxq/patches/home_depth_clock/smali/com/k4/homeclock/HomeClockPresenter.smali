.class final Lcom/k4/homeclock/HomeClockPresenter;
.super Lh3/a;
.source "HomeClockPresenter.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/k4/homeclock/HomeClockPresenter$InPlace;
    }
.end annotation


# instance fields
.field private clock:Lcom/k4/homeclock/DepthClock;

.field private frontNode:Li3/c;


# direct methods
.method constructor <init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V
    .registers 4

    .line 29
    invoke-direct {p0, p1, p2, p3}, Lh3/a;-><init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V

    .line 30
    return-void
.end method

.method static clockSlot(Ljava/util/List;Ljava/lang/Object;Ljava/lang/Object;)I
    .registers 9
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "*>;",
            "Ljava/lang/Object;",
            "Ljava/lang/Object;",
            ")I"
        }
    .end annotation

    .line 169
    const/4 v0, -0x1

    if-nez p1, :cond_5

    move p1, v0

    goto :goto_9

    :cond_5
    invoke-interface {p0, p1}, Ljava/util/List;->indexOf(Ljava/lang/Object;)I

    move-result p1

    .line 170
    :goto_9
    if-ltz p1, :cond_82

    instance-of v1, p2, Ljava/util/List;

    if-eqz v1, :cond_82

    check-cast p2, Ljava/util/List;

    invoke-interface {p2}, Ljava/util/List;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_18

    goto :goto_82

    .line 173
    :cond_18
    const/4 v1, 0x0

    invoke-interface {p2, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p2

    invoke-interface {p0, p2}, Ljava/util/List;->indexOf(Ljava/lang/Object;)I

    move-result p2

    .line 174
    const-string v1, ")"

    const-string v2, "/"

    const-string v3, "K4HomeClock"

    if-le p2, p1, :cond_59

    .line 175
    add-int/lit8 p2, p2, 0x1

    .line 176
    invoke-interface {p0}, Ljava/util/List;->size()I

    move-result p1

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "frame layout, subject inside the frame: clock above the frame plate (layer "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v3, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 177
    invoke-interface {p0}, Ljava/util/List;->size()I

    move-result p0

    if-ge p2, p0, :cond_58

    move v0, p2

    :cond_58
    return v0

    .line 179
    :cond_59
    if-ltz p2, :cond_81

    .line 180
    invoke-interface {p0}, Ljava/util/List;->size()I

    move-result p0

    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "frame layout, subject out of the frame: clock below the subject (layer "

    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v3, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 182
    :cond_81
    return p1

    .line 171
    :cond_82
    :goto_82
    return p1
.end method

.method private static create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;
    .registers 5

    .line 153
    if-nez p3, :cond_7

    .line 154
    invoke-static {p0, p1, p2}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;)Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0

    .line 156
    :cond_7
    invoke-static {p0, p1, p2, p4, p3}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;ZLandroid/graphics/ColorSpace;)Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0
.end method

.method static subjectTop(Li3/c;)F
    .registers 13

    .line 187
    const/high16 v0, -0x40800000    # -1.0f

    if-nez p0, :cond_5

    .line 188
    return v0

    .line 190
    :cond_5
    iget-object p0, p0, Li3/c;->c:Landroid/graphics/drawable/Drawable;

    .line 191
    instance-of v1, p0, Landroid/graphics/drawable/BitmapDrawable;

    if-nez v1, :cond_c

    .line 192
    return v0

    .line 194
    :cond_c
    move-object v1, p0

    check-cast v1, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v1}, Landroid/graphics/drawable/BitmapDrawable;->getBitmap()Landroid/graphics/Bitmap;

    move-result-object v2

    .line 195
    invoke-virtual {p0}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object p0

    .line 196
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

    .line 199
    :cond_2e
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v5

    .line 200
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v1

    .line 201
    new-array v3, v5, [I

    .line 202
    div-int/lit8 v4, v5, 0x64

    const/4 v6, 0x3

    invoke-static {v6, v4}, Ljava/lang/Math;->max(II)I

    move-result v10

    .line 203
    const/4 v11, 0x0

    move v7, v11

    :goto_41
    if-ge v7, v1, :cond_6f

    .line 204
    const/4 v6, 0x0

    const/4 v9, 0x1

    const/4 v4, 0x0

    move v8, v5

    invoke-virtual/range {v2 .. v9}, Landroid/graphics/Bitmap;->getPixels([IIIIIII)V

    .line 205
    nop

    .line 206
    move v4, v11

    move v6, v4

    :goto_4d
    if-ge v4, v5, :cond_6c

    .line 207
    aget v8, v3, v4

    ushr-int/lit8 v8, v8, 0x18

    const/16 v9, 0xa0

    if-le v8, v9, :cond_69

    add-int/lit8 v6, v6, 0x1

    if-lt v6, v10, :cond_69

    .line 208
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

    .line 206
    :cond_69
    add-int/lit8 v4, v4, 0x2

    goto :goto_4d

    .line 203
    :cond_6c
    add-int/lit8 v7, v7, 0x2

    goto :goto_41

    .line 212
    :cond_6f
    return v0

    .line 197
    :cond_70
    :goto_70
    return v0
.end method


# virtual methods
.method public a(Lcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;IILg0/a;)V
    .registers 27

    .line 34
    move-object/from16 v1, p0

    move/from16 v3, p2

    move/from16 v4, p3

    move-object/from16 v9, p4

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v10

    .line 35
    new-instance v0, Lh3/f;

    iget-object v2, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    iget v5, v1, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    move-object/from16 v6, p1

    invoke-direct {v0, v2, v5, v6}, Lh3/f;-><init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V

    .line 36
    invoke-virtual {v0, v3, v4}, Lh3/f;->e(II)V

    .line 37
    iget-object v12, v0, Lh3/f;->e:Lg0/a;

    .line 38
    iget-object v2, v9, Lg0/a;->b:Ljava/lang/Object;

    move-object v13, v2

    check-cast v13, Li3/k;

    .line 39
    const-string v14, "K4HomeClock"

    if-nez v12, :cond_2e

    .line 40
    const-string v1, "build: no presenter data"

    invoke-static {v14, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 41
    invoke-virtual {v0}, Lh3/f;->d()V

    .line 42
    return-void

    .line 44
    :cond_2e
    new-instance v15, Ljava/util/ArrayList;

    iget-object v2, v0, Lh3/f;->f:Li3/k;

    iget-object v2, v2, Li3/k;->c:Ljava/util/ArrayList;

    invoke-direct {v15, v2}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    .line 45
    iget-boolean v2, v12, Lg0/a;->a:Z

    iput-boolean v2, v9, Lg0/a;->a:Z

    .line 46
    iget-object v2, v12, Lg0/a;->f:Ljava/lang/Object;

    iput-object v2, v9, Lg0/a;->f:Ljava/lang/Object;

    .line 47
    iget-object v2, v12, Lg0/a;->g:Ljava/io/Serializable;

    iput-object v2, v9, Lg0/a;->g:Ljava/io/Serializable;

    .line 49
    :try_start_43
    iget-object v5, v12, Lg0/a;->d:Ljava/lang/Object;

    iget-object v6, v12, Lg0/a;->e:Ljava/io/Serializable;

    invoke-static {v15, v5, v6}, Lcom/k4/homeclock/HomeClockPresenter;->clockSlot(Ljava/util/List;Ljava/lang/Object;Ljava/lang/Object;)I

    move-result v5

    .line 50
    iget-object v6, v12, Lg0/a;->g:Ljava/io/Serializable;

    instance-of v6, v6, Landroid/graphics/Bitmap$Config;

    if-eqz v6, :cond_56

    iget-object v6, v12, Lg0/a;->g:Ljava/io/Serializable;

    check-cast v6, Landroid/graphics/Bitmap$Config;

    goto :goto_58

    :cond_56
    sget-object v6, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    .line 51
    :goto_58
    iget-object v7, v12, Lg0/a;->f:Ljava/lang/Object;

    instance-of v7, v7, Landroid/graphics/ColorSpace;

    if-eqz v7, :cond_63

    iget-object v7, v12, Lg0/a;->f:Ljava/lang/Object;

    check-cast v7, Landroid/graphics/ColorSpace;

    goto :goto_64

    :cond_63
    const/4 v7, 0x0

    .line 52
    :goto_64
    const/4 v8, 0x0

    invoke-static {v3, v4, v6, v7, v8}, Lcom/k4/homeclock/HomeClockPresenter;->create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;

    move-result-object v2

    .line 53
    nop

    .line 54
    new-instance v8, Landroid/graphics/Canvas;

    invoke-direct {v8, v2}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    .line 55
    nop

    .line 56
    move-object/from16 v17, v0

    move-wide/from16 v18, v10

    const/4 v0, 0x0

    const/4 v10, 0x0

    const/4 v11, 0x0

    :goto_77
    move-object/from16 v20, v11

    invoke-virtual {v15}, Ljava/util/ArrayList;->size()I

    move-result v11

    if-ge v0, v11, :cond_ab

    .line 57
    invoke-virtual {v15, v0}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v11

    check-cast v11, Li3/j;

    .line 58
    if-ltz v5, :cond_a1

    if-lt v0, v5, :cond_a1

    .line 59
    if-nez v10, :cond_98

    .line 60
    const/4 v10, 0x1

    invoke-static {v3, v4, v6, v7, v10}, Lcom/k4/homeclock/HomeClockPresenter;->create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;

    move-result-object v10

    .line 61
    move/from16 v21, v0

    new-instance v0, Landroid/graphics/Canvas;

    invoke-direct {v0, v10}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    goto :goto_9c

    .line 59
    :cond_98
    move/from16 v21, v0

    move-object/from16 v0, v20

    .line 63
    :goto_9c
    invoke-virtual {v11, v0}, Li3/j;->a(Landroid/graphics/Canvas;)V

    move-object v11, v0

    goto :goto_a8

    .line 58
    :cond_a1
    move/from16 v21, v0

    .line 65
    invoke-virtual {v11, v8}, Li3/j;->a(Landroid/graphics/Canvas;)V

    move-object/from16 v11, v20

    .line 56
    :goto_a8
    add-int/lit8 v0, v21, 0x1

    goto :goto_77

    .line 68
    :cond_ab
    iget-object v0, v12, Lg0/a;->d:Ljava/lang/Object;

    instance-of v0, v0, Li3/c;

    if-eqz v0, :cond_b6

    iget-object v0, v12, Lg0/a;->d:Ljava/lang/Object;

    check-cast v0, Li3/c;

    goto :goto_b7

    :cond_b6
    const/4 v0, 0x0

    :goto_b7
    invoke-static {v0}, Lcom/k4/homeclock/HomeClockPresenter;->subjectTop(Li3/c;)F

    move-result v0

    .line 70
    new-instance v11, Landroid/graphics/Rect;

    const/4 v6, 0x0

    invoke-direct {v11, v6, v6, v3, v4}, Landroid/graphics/Rect;-><init>(IIII)V

    .line 71
    new-instance v6, Li3/c;

    iget-object v7, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    new-instance v8, Li3/b;

    const/4 v3, 0x0

    invoke-direct {v8, v2, v11, v11, v3}, Li3/b;-><init>(Landroid/graphics/Bitmap;Landroid/graphics/Rect;Landroid/graphics/Rect;Landroid/graphics/Point;)V

    iget v3, v1, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    invoke-direct {v6, v7, v8, v3}, Li3/c;-><init>(Landroid/content/Context;Li3/b;I)V

    .line 72
    move-object v3, v6

    move-object v6, v2

    iget-object v2, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;
    :try_end_d4
    .catchall {:try_start_43 .. :try_end_d4} :catchall_181

    const/4 v7, 0x0

    const/4 v8, 0x0

    move/from16 v16, v5

    move v5, v0

    move/from16 v0, v16

    move-object/from16 v16, v15

    move-object v15, v3

    move/from16 v3, p2

    :try_start_e0
    invoke-static/range {v2 .. v8}, Lcom/k4/homeclock/HomeDepthClock;->makeClock(Landroid/content/Context;IIFLandroid/graphics/Bitmap;Li3/c;Lh3/a;)Lcom/k4/homeclock/DepthClock;

    move-result-object v2

    .line 73
    invoke-static {v1, v2}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 74
    iput-object v15, v9, Lg0/a;->c:Ljava/lang/Object;

    .line 75
    iget-object v6, v13, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v6, v15}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 78
    iput-object v2, v1, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/DepthClock;

    .line 79
    if-eqz v10, :cond_102

    new-instance v6, Li3/c;

    iget-object v7, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    new-instance v8, Li3/b;

    const/4 v15, 0x0

    invoke-direct {v8, v10, v11, v11, v15}, Li3/b;-><init>(Landroid/graphics/Bitmap;Landroid/graphics/Rect;Landroid/graphics/Rect;Landroid/graphics/Point;)V

    iget v10, v1, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    invoke-direct {v6, v7, v8, v10}, Li3/c;-><init>(Landroid/content/Context;Li3/b;I)V

    goto :goto_103

    :cond_102
    const/4 v6, 0x0

    :goto_103
    iput-object v6, v1, Lcom/k4/homeclock/HomeClockPresenter;->frontNode:Li3/c;

    .line 80
    iget-object v6, v13, Li3/k;->c:Ljava/util/ArrayList;

    new-instance v7, Lcom/k4/homeclock/HomeClockPresenter$InPlace;

    iget-object v8, v1, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    invoke-direct {v7, v1, v8}, Lcom/k4/homeclock/HomeClockPresenter$InPlace;-><init>(Lcom/k4/homeclock/HomeClockPresenter;Landroid/content/Context;)V

    invoke-virtual {v6, v7}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 81
    invoke-virtual/range {v17 .. v17}, Lh3/f;->d()V

    .line 82
    invoke-virtual/range {v16 .. v16}, Ljava/util/ArrayList;->size()I

    move-result v6

    .line 83
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

    .line 82
    invoke-static {v14, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_17e
    .catchall {:try_start_e0 .. :try_end_17e} :catchall_17f

    .line 95
    goto :goto_1b2

    .line 84
    :catchall_17f
    move-exception v0

    goto :goto_184

    :catchall_181
    move-exception v0

    move-object/from16 v16, v15

    .line 86
    :goto_184
    const-string v2, "build failed, showing the layers without a clock"

    invoke-static {v14, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 87
    const/4 v15, 0x0

    invoke-static {v1, v15}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 88
    iget-object v0, v13, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    .line 89
    invoke-virtual/range {v16 .. v16}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_196
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1a6

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    .line 90
    iget-object v2, v13, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v2, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 91
    goto :goto_196

    .line 92
    :cond_1a6
    iget-object v0, v12, Lg0/a;->c:Ljava/lang/Object;

    iput-object v0, v9, Lg0/a;->c:Ljava/lang/Object;

    .line 93
    iget-object v0, v12, Lg0/a;->d:Ljava/lang/Object;

    iput-object v0, v9, Lg0/a;->d:Ljava/lang/Object;

    .line 94
    iget-object v0, v12, Lg0/a;->e:Ljava/io/Serializable;

    iput-object v0, v9, Lg0/a;->e:Ljava/io/Serializable;

    .line 96
    :goto_1b2
    return-void
.end method

.method public d()V
    .registers 3

    .line 100
    const/4 v0, 0x0

    invoke-static {p0, v0}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 101
    iget-object v1, p0, Lcom/k4/homeclock/HomeClockPresenter;->f:Li3/k;

    invoke-virtual {v1}, Li3/k;->b()V

    .line 102
    iput-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/DepthClock;

    .line 103
    iput-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter;->frontNode:Li3/c;

    .line 104
    return-void
.end method

.method drawAbove(Landroid/graphics/Canvas;F)V
    .registers 9

    .line 117
    iget-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/DepthClock;

    .line 118
    if-eqz v0, :cond_7

    .line 119
    invoke-virtual {v0, p1}, Lcom/k4/homeclock/DepthClock;->a(Landroid/graphics/Canvas;)V

    .line 121
    :cond_7
    iget-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter;->frontNode:Li3/c;

    .line 122
    if-eqz v0, :cond_48

    iget-object v1, v0, Li3/c;->c:Landroid/graphics/drawable/Drawable;

    if-nez v1, :cond_10

    goto :goto_48

    .line 125
    :cond_10
    const/4 v1, 0x0

    cmpl-float v1, p2, v1

    if-lez v1, :cond_33

    .line 126
    const/high16 v2, 0x3f800000    # 1.0f

    sub-float/2addr v2, p2

    const/high16 p2, 0x437f0000    # 255.0f

    mul-float/2addr v2, p2

    invoke-static {v2}, Ljava/lang/Math;->round(F)I

    move-result p2

    .line 127
    iget-object v2, v0, Li3/c;->c:Landroid/graphics/drawable/Drawable;

    new-instance v3, Landroid/graphics/LightingColorFilter;

    shl-int/lit8 v4, p2, 0x10

    const/high16 v5, -0x1000000

    or-int/2addr v4, v5

    shl-int/lit8 v5, p2, 0x8

    or-int/2addr v4, v5

    or-int/2addr p2, v4

    const/4 v4, 0x0

    invoke-direct {v3, p2, v4}, Landroid/graphics/LightingColorFilter;-><init>(II)V

    invoke-virtual {v2, v3}, Landroid/graphics/drawable/Drawable;->setColorFilter(Landroid/graphics/ColorFilter;)V

    .line 130
    :cond_33
    const/4 p2, 0x0

    :try_start_34
    invoke-virtual {v0, p1}, Li3/c;->a(Landroid/graphics/Canvas;)V
    :try_end_37
    .catchall {:try_start_34 .. :try_end_37} :catchall_3f

    .line 132
    if-lez v1, :cond_3e

    .line 133
    iget-object p1, v0, Li3/c;->c:Landroid/graphics/drawable/Drawable;

    invoke-virtual {p1, p2}, Landroid/graphics/drawable/Drawable;->setColorFilter(Landroid/graphics/ColorFilter;)V

    .line 136
    :cond_3e
    return-void

    .line 132
    :catchall_3f
    move-exception p1

    if-lez v1, :cond_47

    .line 133
    iget-object v0, v0, Li3/c;->c:Landroid/graphics/drawable/Drawable;

    invoke-virtual {v0, p2}, Landroid/graphics/drawable/Drawable;->setColorFilter(Landroid/graphics/ColorFilter;)V

    .line 135
    :cond_47
    throw p1

    .line 123
    :cond_48
    :goto_48
    return-void
.end method
