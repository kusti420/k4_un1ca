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

    .line 180
    const/4 v0, -0x1

    if-nez p1, :cond_5

    move p1, v0

    goto :goto_9

    :cond_5
    invoke-interface {p0, p1}, Ljava/util/List;->indexOf(Ljava/lang/Object;)I

    move-result p1

    .line 181
    :goto_9
    if-ltz p1, :cond_82

    instance-of v1, p2, Ljava/util/List;

    if-eqz v1, :cond_82

    check-cast p2, Ljava/util/List;

    invoke-interface {p2}, Ljava/util/List;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_18

    goto :goto_82

    .line 184
    :cond_18
    const/4 v1, 0x0

    invoke-interface {p2, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p2

    invoke-interface {p0, p2}, Ljava/util/List;->indexOf(Ljava/lang/Object;)I

    move-result p2

    .line 185
    const-string v1, ")"

    const-string v2, "/"

    const-string v3, "K4HomeClock"

    if-le p2, p1, :cond_59

    .line 186
    add-int/lit8 p2, p2, 0x1

    .line 187
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

    .line 188
    invoke-interface {p0}, Ljava/util/List;->size()I

    move-result p0

    if-ge p2, p0, :cond_58

    move v0, p2

    :cond_58
    return v0

    .line 190
    :cond_59
    if-ltz p2, :cond_81

    .line 191
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

    .line 193
    :cond_81
    return p1

    .line 182
    :cond_82
    :goto_82
    return p1
.end method

.method private static create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;
    .registers 5

    .line 164
    if-nez p3, :cond_7

    .line 165
    invoke-static {p0, p1, p2}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;)Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0

    .line 167
    :cond_7
    invoke-static {p0, p1, p2, p4, p3}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;ZLandroid/graphics/ColorSpace;)Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0
.end method

.method static subjectTop(Li3/c;)F
    .registers 13

    .line 198
    const/high16 v0, -0x40800000    # -1.0f

    if-nez p0, :cond_5

    .line 199
    return v0

    .line 201
    :cond_5
    iget-object p0, p0, Li3/c;->c:Landroid/graphics/drawable/Drawable;

    .line 202
    instance-of v1, p0, Landroid/graphics/drawable/BitmapDrawable;

    if-nez v1, :cond_c

    .line 203
    return v0

    .line 205
    :cond_c
    move-object v1, p0

    check-cast v1, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v1}, Landroid/graphics/drawable/BitmapDrawable;->getBitmap()Landroid/graphics/Bitmap;

    move-result-object v2

    .line 206
    invoke-virtual {p0}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object p0

    .line 207
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

    .line 210
    :cond_2e
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v5

    .line 211
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v1

    .line 212
    new-array v3, v5, [I

    .line 213
    div-int/lit8 v4, v5, 0x64

    const/4 v6, 0x3

    invoke-static {v6, v4}, Ljava/lang/Math;->max(II)I

    move-result v10

    .line 214
    const/4 v11, 0x0

    move v7, v11

    :goto_41
    if-ge v7, v1, :cond_6f

    .line 215
    const/4 v6, 0x0

    const/4 v9, 0x1

    const/4 v4, 0x0

    move v8, v5

    invoke-virtual/range {v2 .. v9}, Landroid/graphics/Bitmap;->getPixels([IIIIIII)V

    .line 216
    nop

    .line 217
    move v4, v11

    move v6, v4

    :goto_4d
    if-ge v4, v5, :cond_6c

    .line 218
    aget v8, v3, v4

    ushr-int/lit8 v8, v8, 0x18

    const/16 v9, 0xa0

    if-le v8, v9, :cond_69

    add-int/lit8 v6, v6, 0x1

    if-lt v6, v10, :cond_69

    .line 219
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

    .line 217
    :cond_69
    add-int/lit8 v4, v4, 0x2

    goto :goto_4d

    .line 214
    :cond_6c
    add-int/lit8 v7, v7, 0x2

    goto :goto_41

    .line 223
    :cond_6f
    return v0

    .line 208
    :cond_70
    :goto_70
    return v0
.end method


# virtual methods
.method public a(Lcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;IILg0/a;)V
    .registers 27

    .line 34
    move-object/from16 v6, p0

    move/from16 v1, p2

    move/from16 v2, p3

    move-object/from16 v8, p4

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v9

    .line 35
    iget-object v0, v6, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->fingerprint(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v11

    .line 36
    const/4 v12, 0x0

    invoke-static {v6, v12}, Lcom/k4/homeclock/HomeDepthClock;->built(Lh3/a;Ljava/lang/String;)V

    .line 37
    new-instance v13, Lh3/f;

    iget-object v0, v6, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    iget v3, v6, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    move-object/from16 v4, p1

    invoke-direct {v13, v0, v3, v4}, Lh3/f;-><init>(Landroid/content/Context;ILcom/samsung/android/wallpaper/live/unified/engines/layered/source/b;)V

    .line 38
    invoke-virtual {v13, v1, v2}, Lh3/f;->e(II)V

    .line 39
    iget-object v14, v13, Lh3/f;->e:Lg0/a;

    .line 40
    iget-object v0, v8, Lg0/a;->b:Ljava/lang/Object;

    move-object v15, v0

    check-cast v15, Li3/k;

    .line 41
    const-string v3, "K4HomeClock"

    if-nez v14, :cond_3f

    .line 42
    const-string v0, "build: no presenter data"

    invoke-static {v3, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 43
    invoke-static {v6, v12}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 44
    iput-object v12, v6, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/DepthClock;

    .line 45
    iput-object v12, v6, Lcom/k4/homeclock/HomeClockPresenter;->frontNode:Li3/c;

    .line 46
    invoke-virtual {v13}, Lh3/f;->d()V

    .line 47
    return-void

    .line 49
    :cond_3f
    new-instance v4, Ljava/util/ArrayList;

    iget-object v0, v13, Lh3/f;->f:Li3/k;

    iget-object v0, v0, Li3/k;->c:Ljava/util/ArrayList;

    invoke-direct {v4, v0}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    .line 50
    iget-boolean v0, v14, Lg0/a;->a:Z

    iput-boolean v0, v8, Lg0/a;->a:Z

    .line 51
    iget-object v0, v14, Lg0/a;->f:Ljava/lang/Object;

    iput-object v0, v8, Lg0/a;->f:Ljava/lang/Object;

    .line 52
    iget-object v0, v14, Lg0/a;->g:Ljava/io/Serializable;

    iput-object v0, v8, Lg0/a;->g:Ljava/io/Serializable;

    .line 54
    :try_start_54
    iget-object v0, v14, Lg0/a;->d:Ljava/lang/Object;

    iget-object v5, v14, Lg0/a;->e:Ljava/io/Serializable;

    invoke-static {v4, v0, v5}, Lcom/k4/homeclock/HomeClockPresenter;->clockSlot(Ljava/util/List;Ljava/lang/Object;Ljava/lang/Object;)I

    move-result v0

    .line 55
    iget-object v5, v14, Lg0/a;->g:Ljava/io/Serializable;

    instance-of v5, v5, Landroid/graphics/Bitmap$Config;

    if-eqz v5, :cond_67

    iget-object v5, v14, Lg0/a;->g:Ljava/io/Serializable;

    check-cast v5, Landroid/graphics/Bitmap$Config;

    goto :goto_69

    :cond_67
    sget-object v5, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    .line 56
    :goto_69
    iget-object v7, v14, Lg0/a;->f:Ljava/lang/Object;

    instance-of v7, v7, Landroid/graphics/ColorSpace;

    if-eqz v7, :cond_74

    iget-object v7, v14, Lg0/a;->f:Ljava/lang/Object;

    check-cast v7, Landroid/graphics/ColorSpace;
    :try_end_73
    .catchall {:try_start_54 .. :try_end_73} :catchall_1ac

    goto :goto_75

    :cond_74
    move-object v7, v12

    .line 57
    :goto_75
    const/4 v12, 0x0

    move-object/from16 p1, v3

    :try_start_78
    invoke-static {v1, v2, v5, v7, v12}, Lcom/k4/homeclock/HomeClockPresenter;->create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;

    move-result-object v3

    .line 58
    nop

    .line 59
    new-instance v12, Landroid/graphics/Canvas;

    invoke-direct {v12, v3}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    .line 60
    nop

    .line 61
    move-wide/from16 v17, v9

    const/4 v9, 0x0

    const/4 v10, 0x0

    const/16 v19, 0x0

    :goto_89
    move-object/from16 v20, v13

    invoke-virtual {v4}, Ljava/util/ArrayList;->size()I

    move-result v13

    if-ge v10, v13, :cond_c0

    .line 62
    invoke-virtual {v4, v10}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v13

    check-cast v13, Li3/j;

    .line 63
    if-ltz v0, :cond_b4

    if-lt v10, v0, :cond_b4

    .line 64
    if-nez v9, :cond_aa

    .line 65
    const/4 v9, 0x1

    invoke-static {v1, v2, v5, v7, v9}, Lcom/k4/homeclock/HomeClockPresenter;->create(IILandroid/graphics/Bitmap$Config;Landroid/graphics/ColorSpace;Z)Landroid/graphics/Bitmap;

    move-result-object v9

    .line 66
    move/from16 v21, v0

    new-instance v0, Landroid/graphics/Canvas;

    invoke-direct {v0, v9}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    goto :goto_ae

    .line 64
    :cond_aa
    move/from16 v21, v0

    move-object/from16 v0, v19

    .line 68
    :goto_ae
    invoke-virtual {v13, v0}, Li3/j;->a(Landroid/graphics/Canvas;)V

    move-object/from16 v19, v0

    goto :goto_b9

    .line 63
    :cond_b4
    move/from16 v21, v0

    .line 70
    invoke-virtual {v13, v12}, Li3/j;->a(Landroid/graphics/Canvas;)V

    .line 61
    :goto_b9
    add-int/lit8 v10, v10, 0x1

    move-object/from16 v13, v20

    move/from16 v0, v21

    goto :goto_89

    .line 73
    :cond_c0
    move/from16 v21, v0

    iget-object v0, v14, Lg0/a;->d:Ljava/lang/Object;

    instance-of v0, v0, Li3/c;

    if-eqz v0, :cond_cd

    iget-object v0, v14, Lg0/a;->d:Ljava/lang/Object;

    check-cast v0, Li3/c;

    goto :goto_ce

    :cond_cd
    const/4 v0, 0x0

    :goto_ce
    invoke-static {v0}, Lcom/k4/homeclock/HomeClockPresenter;->subjectTop(Li3/c;)F

    move-result v0

    .line 75
    new-instance v10, Landroid/graphics/Rect;

    const/4 v5, 0x0

    invoke-direct {v10, v5, v5, v1, v2}, Landroid/graphics/Rect;-><init>(IIII)V

    .line 76
    new-instance v12, Li3/c;

    iget-object v5, v6, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    new-instance v7, Li3/b;

    const/4 v13, 0x0

    invoke-direct {v7, v3, v10, v10, v13}, Li3/b;-><init>(Landroid/graphics/Bitmap;Landroid/graphics/Rect;Landroid/graphics/Rect;Landroid/graphics/Point;)V

    iget v13, v6, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    invoke-direct {v12, v5, v7, v13}, Li3/c;-><init>(Landroid/content/Context;Li3/b;I)V
    :try_end_e7
    .catchall {:try_start_78 .. :try_end_e7} :catchall_1a4

    .line 77
    move-object v5, v4

    move-object v4, v3

    move v3, v0

    :try_start_ea
    iget-object v0, v6, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;
    :try_end_ec
    .catchall {:try_start_ea .. :try_end_ec} :catchall_19c

    move-object v7, v5

    const/4 v5, 0x0

    move-object v13, v7

    const/4 v7, 0x0

    move-object/from16 v16, v14

    move-object/from16 v14, p1

    move-object/from16 p1, v13

    move/from16 v13, v21

    :try_start_f8
    invoke-static/range {v0 .. v7}, Lcom/k4/homeclock/HomeDepthClock;->makeClock(Landroid/content/Context;IIFLandroid/graphics/Bitmap;Li3/c;Lh3/a;Z)Lcom/k4/homeclock/DepthClock;

    move-result-object v0

    .line 78
    invoke-static {v6, v0}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 79
    invoke-static {v6, v11}, Lcom/k4/homeclock/HomeDepthClock;->built(Lh3/a;Ljava/lang/String;)V

    .line 80
    iput-object v12, v8, Lg0/a;->c:Ljava/lang/Object;

    .line 81
    iget-object v4, v15, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v4, v12}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 84
    iput-object v0, v6, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/DepthClock;

    .line 85
    if-eqz v9, :cond_11d

    new-instance v4, Li3/c;

    iget-object v5, v6, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    new-instance v7, Li3/b;

    const/4 v11, 0x0

    invoke-direct {v7, v9, v10, v10, v11}, Li3/b;-><init>(Landroid/graphics/Bitmap;Landroid/graphics/Rect;Landroid/graphics/Rect;Landroid/graphics/Point;)V

    iget v9, v6, Lcom/k4/homeclock/HomeClockPresenter;->c:I

    invoke-direct {v4, v5, v7, v9}, Li3/c;-><init>(Landroid/content/Context;Li3/b;I)V

    goto :goto_11e

    :cond_11d
    const/4 v4, 0x0

    :goto_11e
    iput-object v4, v6, Lcom/k4/homeclock/HomeClockPresenter;->frontNode:Li3/c;

    .line 86
    iget-object v4, v15, Li3/k;->c:Ljava/util/ArrayList;

    new-instance v5, Lcom/k4/homeclock/HomeClockPresenter$InPlace;

    iget-object v7, v6, Lcom/k4/homeclock/HomeClockPresenter;->a:Landroid/content/Context;

    invoke-direct {v5, v6, v7}, Lcom/k4/homeclock/HomeClockPresenter$InPlace;-><init>(Lcom/k4/homeclock/HomeClockPresenter;Landroid/content/Context;)V

    invoke-virtual {v4, v5}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 87
    invoke-virtual/range {v20 .. v20}, Lh3/f;->d()V

    .line 88
    invoke-virtual/range {p1 .. p1}, Ljava/util/ArrayList;->size()I

    move-result v4

    .line 89
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object v0

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v9

    sub-long v9, v9, v17

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "build: "

    invoke-virtual {v5, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v5, "x"

    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", layers="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", subjectAt="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v13}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", subjectTop="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", clock="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v9, v10}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " ms"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 88
    invoke-static {v14, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_199
    .catchall {:try_start_f8 .. :try_end_199} :catchall_19a

    .line 106
    goto :goto_1e9

    .line 90
    :catchall_19a
    move-exception v0

    goto :goto_1b2

    :catchall_19c
    move-exception v0

    move-object/from16 v16, v14

    move-object/from16 v14, p1

    move-object/from16 p1, v5

    goto :goto_1b2

    :catchall_1a4
    move-exception v0

    move-object/from16 v16, v14

    move-object/from16 v14, p1

    move-object/from16 p1, v4

    goto :goto_1b2

    :catchall_1ac
    move-exception v0

    move-object/from16 p1, v4

    move-object/from16 v16, v14

    move-object v14, v3

    .line 92
    :goto_1b2
    const-string v1, "build failed, showing the layers without a clock"

    invoke-static {v14, v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 93
    const/4 v11, 0x0

    invoke-static {v6, v11}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 94
    invoke-static {v6, v11}, Lcom/k4/homeclock/HomeDepthClock;->built(Lh3/a;Ljava/lang/String;)V

    .line 97
    iput-object v11, v6, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/DepthClock;

    .line 98
    iput-object v11, v6, Lcom/k4/homeclock/HomeClockPresenter;->frontNode:Li3/c;

    .line 99
    iget-object v0, v15, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    .line 100
    invoke-virtual/range {p1 .. p1}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_1cb
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1db

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    .line 101
    iget-object v2, v15, Li3/k;->c:Ljava/util/ArrayList;

    invoke-virtual {v2, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 102
    goto :goto_1cb

    .line 103
    :cond_1db
    move-object/from16 v1, v16

    iget-object v0, v1, Lg0/a;->c:Ljava/lang/Object;

    iput-object v0, v8, Lg0/a;->c:Ljava/lang/Object;

    .line 104
    iget-object v0, v1, Lg0/a;->d:Ljava/lang/Object;

    iput-object v0, v8, Lg0/a;->d:Ljava/lang/Object;

    .line 105
    iget-object v0, v1, Lg0/a;->e:Ljava/io/Serializable;

    iput-object v0, v8, Lg0/a;->e:Ljava/io/Serializable;

    .line 107
    :goto_1e9
    return-void
.end method

.method public d()V
    .registers 3

    .line 111
    const/4 v0, 0x0

    invoke-static {p0, v0}, Lcom/k4/homeclock/HomeDepthClock;->setClock(Lh3/a;Lcom/k4/homeclock/DepthClock;)V

    .line 112
    iget-object v1, p0, Lcom/k4/homeclock/HomeClockPresenter;->f:Li3/k;

    invoke-virtual {v1}, Li3/k;->b()V

    .line 113
    iput-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/DepthClock;

    .line 114
    iput-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter;->frontNode:Li3/c;

    .line 115
    return-void
.end method

.method drawAbove(Landroid/graphics/Canvas;F)V
    .registers 9

    .line 128
    iget-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter;->clock:Lcom/k4/homeclock/DepthClock;

    .line 129
    if-eqz v0, :cond_7

    .line 130
    invoke-virtual {v0, p1}, Lcom/k4/homeclock/DepthClock;->a(Landroid/graphics/Canvas;)V

    .line 132
    :cond_7
    iget-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter;->frontNode:Li3/c;

    .line 133
    if-eqz v0, :cond_48

    iget-object v1, v0, Li3/c;->c:Landroid/graphics/drawable/Drawable;

    if-nez v1, :cond_10

    goto :goto_48

    .line 136
    :cond_10
    const/4 v1, 0x0

    cmpl-float v1, p2, v1

    if-lez v1, :cond_33

    .line 137
    const/high16 v2, 0x3f800000    # 1.0f

    sub-float/2addr v2, p2

    const/high16 p2, 0x437f0000    # 255.0f

    mul-float/2addr v2, p2

    invoke-static {v2}, Ljava/lang/Math;->round(F)I

    move-result p2

    .line 138
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

    .line 141
    :cond_33
    const/4 p2, 0x0

    :try_start_34
    invoke-virtual {v0, p1}, Li3/c;->a(Landroid/graphics/Canvas;)V
    :try_end_37
    .catchall {:try_start_34 .. :try_end_37} :catchall_3f

    .line 143
    if-lez v1, :cond_3e

    .line 144
    iget-object p1, v0, Li3/c;->c:Landroid/graphics/drawable/Drawable;

    invoke-virtual {p1, p2}, Landroid/graphics/drawable/Drawable;->setColorFilter(Landroid/graphics/ColorFilter;)V

    .line 147
    :cond_3e
    return-void

    .line 143
    :catchall_3f
    move-exception p1

    if-lez v1, :cond_47

    .line 144
    iget-object v0, v0, Li3/c;->c:Landroid/graphics/drawable/Drawable;

    invoke-virtual {v0, p2}, Landroid/graphics/drawable/Drawable;->setColorFilter(Landroid/graphics/ColorFilter;)V

    .line 146
    :cond_47
    throw p1

    .line 134
    :cond_48
    :goto_48
    return-void
.end method
