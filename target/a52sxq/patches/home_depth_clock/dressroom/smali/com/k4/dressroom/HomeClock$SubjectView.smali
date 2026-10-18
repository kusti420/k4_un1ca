.class final Lcom/k4/dressroom/HomeClock$SubjectView;
.super Landroid/view/View;
.source "HomeClock.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/k4/dressroom/HomeClock;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "SubjectView"
.end annotation


# instance fields
.field final crop:Landroid/widget/ImageView;

.field private final last:[F

.field private lastFrame:[F

.field private final m9:[F

.field private final now:[F

.field subject:Landroid/graphics/drawable/BitmapDrawable;


# direct methods
.method constructor <init>(Landroid/content/Context;Landroid/widget/ImageView;)V
    .locals 1

    invoke-direct {p0, p1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    const/16 p1, 0x13

    new-array v0, p1, [F

    iput-object v0, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->last:[F

    new-array p1, p1, [F

    iput-object p1, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    const/16 p1, 0x9

    new-array p1, p1, [F

    iput-object p1, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->m9:[F

    iput-object p2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    const/4 p1, 0x0

    invoke-virtual {p0, p1}, Lcom/k4/dressroom/HomeClock$SubjectView;->setClickable(Z)V

    invoke-virtual {p0, p1}, Lcom/k4/dressroom/HomeClock$SubjectView;->setFocusable(Z)V

    const/4 p1, 0x2

    invoke-virtual {p0, p1}, Lcom/k4/dressroom/HomeClock$SubjectView;->setImportantForAccessibility(I)V

    return-void
.end method


# virtual methods
.method changed()Z
    .locals 5

    iget-object v0, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-virtual {v0}, Landroid/widget/ImageView;->getDrawable()Landroid/graphics/drawable/Drawable;

    move-result-object v0

    const/4 v1, 0x0

    if-nez v0, :cond_0

    return v1

    :cond_0
    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-virtual {v2}, Landroid/widget/ImageView;->getImageMatrix()Landroid/graphics/Matrix;

    move-result-object v2

    iget-object v3, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    invoke-virtual {v2, v3}, Landroid/graphics/Matrix;->getValues([F)V

    invoke-virtual {v0}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object v0

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    iget v3, v0, Landroid/graphics/Rect;->left:I

    int-to-float v3, v3

    const/16 v4, 0x9

    aput v3, v2, v4

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    iget v3, v0, Landroid/graphics/Rect;->top:I

    int-to-float v3, v3

    const/16 v4, 0xa

    aput v3, v2, v4

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    iget v3, v0, Landroid/graphics/Rect;->right:I

    int-to-float v3, v3

    const/16 v4, 0xb

    aput v3, v2, v4

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    iget v0, v0, Landroid/graphics/Rect;->bottom:I

    int-to-float v0, v0

    const/16 v3, 0xc

    aput v0, v2, v3

    iget-object v0, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    const/16 v2, 0xd

    invoke-static {v0, v2}, Lcom/k4/dressroom/EditXf;->state([FI)V

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->styledSubject()Landroid/graphics/Bitmap;

    move-result-object v0

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    const/4 v3, 0x0

    if-nez v0, :cond_1

    move v0, v3

    goto :goto_0

    :cond_1
    invoke-static {v0}, Ljava/lang/System;->identityHashCode(Ljava/lang/Object;)I

    move-result v0

    int-to-float v0, v0

    :goto_0
    const/16 v4, 0x11

    aput v0, v2, v4

    iget-object v0, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    sget-boolean v2, Lcom/k4/dressroom/EditXf;->sFrameLayout:Z

    if-eqz v2, :cond_2

    const/high16 v3, 0x3f800000    # 1.0f

    :cond_2
    const/16 v2, 0x12

    aput v3, v0, v2

    sget-boolean v0, Lcom/k4/dressroom/EditXf;->sFrameLayout:Z

    if-eqz v0, :cond_3

    invoke-virtual {p0}, Lcom/k4/dressroom/HomeClock$SubjectView;->frameState()[F

    move-result-object v0

    goto :goto_1

    :cond_3
    const/4 v0, 0x0

    :goto_1
    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    iget-object v3, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->last:[F

    invoke-static {v2, v3}, Ljava/util/Arrays;->equals([F[F)Z

    move-result v2

    if-eqz v2, :cond_4

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->lastFrame:[F

    invoke-static {v0, v2}, Ljava/util/Arrays;->equals([F[F)Z

    move-result v2

    if-eqz v2, :cond_4

    return v1

    :cond_4
    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    iget-object v3, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->last:[F

    array-length v4, v2

    invoke-static {v2, v1, v3, v1, v4}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    iput-object v0, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->lastFrame:[F

    const/4 p0, 0x1

    return p0
.end method

.method drawFrameFront(Landroid/graphics/Canvas;)V
    .locals 10

    invoke-virtual {p0}, Lcom/k4/dressroom/HomeClock$SubjectView;->frontViews()Ljava/util/List;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/view/View;

    invoke-virtual {p1}, Landroid/graphics/Canvas;->save()I

    move-result v2

    invoke-virtual {v1}, Landroid/view/View;->getLeft()I

    move-result v3

    iget-object v4, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-virtual {v4}, Landroid/widget/ImageView;->getLeft()I

    move-result v4

    sub-int/2addr v3, v4

    int-to-float v3, v3

    invoke-virtual {v1}, Landroid/view/View;->getTop()I

    move-result v4

    iget-object v5, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-virtual {v5}, Landroid/widget/ImageView;->getTop()I

    move-result v5

    sub-int/2addr v4, v5

    int-to-float v4, v4

    invoke-virtual {p1, v3, v4}, Landroid/graphics/Canvas;->translate(FF)V

    invoke-virtual {v1}, Landroid/view/View;->getAlpha()F

    move-result v3

    const/high16 v4, 0x3f800000    # 1.0f

    cmpg-float v3, v3, v4

    if-gez v3, :cond_0

    invoke-virtual {v1}, Landroid/view/View;->getWidth()I

    move-result v3

    int-to-float v7, v3

    invoke-virtual {v1}, Landroid/view/View;->getHeight()I

    move-result v3

    int-to-float v8, v3

    invoke-virtual {v1}, Landroid/view/View;->getAlpha()F

    move-result v3

    const/high16 v4, 0x437f0000    # 255.0f

    mul-float/2addr v3, v4

    invoke-static {v3}, Ljava/lang/Math;->round(F)I

    move-result v9

    const/4 v5, 0x0

    const/4 v6, 0x0

    move-object v4, p1

    invoke-virtual/range {v4 .. v9}, Landroid/graphics/Canvas;->saveLayerAlpha(FFFFI)I

    goto :goto_1

    :cond_0
    move-object v4, p1

    :goto_1
    invoke-virtual {v1, v4}, Landroid/view/View;->draw(Landroid/graphics/Canvas;)V

    invoke-virtual {v4, v2}, Landroid/graphics/Canvas;->restoreToCount(I)V

    move-object p1, v4

    goto :goto_0

    :cond_1
    return-void
.end method

.method frameState()[F
    .locals 21

    move-object/from16 v0, p0

    invoke-virtual {v0}, Lcom/k4/dressroom/HomeClock$SubjectView;->frameViews()Ljava/util/List;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v2

    mul-int/lit8 v2, v2, 0x10

    const/4 v3, 0x1

    add-int/2addr v2, v3

    new-array v2, v2, [F

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v4

    int-to-float v4, v4

    const/4 v5, 0x0

    aput v4, v2, v5

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    move v4, v3

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v6

    if-eqz v6, :cond_4

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Landroid/view/View;

    move-object v7, v6

    check-cast v7, Landroid/widget/ImageView;

    invoke-virtual {v7}, Landroid/widget/ImageView;->getDrawable()Landroid/graphics/drawable/Drawable;

    move-result-object v8

    add-int/lit8 v9, v4, 0x1

    invoke-static {v6}, Ljava/lang/System;->identityHashCode(Ljava/lang/Object;)I

    move-result v10

    int-to-float v10, v10

    aput v10, v2, v4

    const/4 v10, 0x2

    add-int/2addr v4, v10

    const/4 v11, 0x0

    if-nez v8, :cond_0

    move v12, v11

    goto :goto_1

    :cond_0
    invoke-static {v8}, Ljava/lang/System;->identityHashCode(Ljava/lang/Object;)I

    move-result v12

    int-to-float v12, v12

    :goto_1
    aput v12, v2, v9

    invoke-virtual {v7}, Landroid/widget/ImageView;->getImageMatrix()Landroid/graphics/Matrix;

    move-result-object v7

    iget-object v9, v0, Lcom/k4/dressroom/HomeClock$SubjectView;->m9:[F

    invoke-virtual {v7, v9}, Landroid/graphics/Matrix;->getValues([F)V

    iget-object v7, v0, Lcom/k4/dressroom/HomeClock$SubjectView;->m9:[F

    aget v9, v7, v5

    aget v12, v7, v3

    aget v13, v7, v10

    const/4 v14, 0x3

    aget v15, v7, v14

    const/16 v16, 0x4

    aget v17, v7, v16

    const/16 v18, 0x5

    aget v7, v7, v18

    move/from16 v19, v3

    const/4 v3, 0x6

    move/from16 v20, v5

    new-array v5, v3, [F

    aput v9, v5, v20

    aput v12, v5, v19

    aput v13, v5, v10

    aput v15, v5, v14

    aput v17, v5, v16

    aput v7, v5, v18

    move/from16 v7, v20

    :goto_2
    if-ge v7, v3, :cond_1

    aget v9, v5, v7

    add-int/lit8 v10, v4, 0x1

    aput v9, v2, v4

    add-int/lit8 v7, v7, 0x1

    move v4, v10

    goto :goto_2

    :cond_1
    if-nez v8, :cond_2

    new-instance v3, Landroid/graphics/Rect;

    invoke-direct {v3}, Landroid/graphics/Rect;-><init>()V

    goto :goto_3

    :cond_2
    invoke-virtual {v8}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object v3

    :goto_3
    add-int/lit8 v5, v4, 0x1

    iget v7, v3, Landroid/graphics/Rect;->left:I

    int-to-float v7, v7

    aput v7, v2, v4

    add-int/lit8 v7, v4, 0x2

    iget v9, v3, Landroid/graphics/Rect;->top:I

    int-to-float v9, v9

    aput v9, v2, v5

    add-int/lit8 v5, v4, 0x3

    iget v9, v3, Landroid/graphics/Rect;->right:I

    int-to-float v9, v9

    aput v9, v2, v7

    add-int/lit8 v7, v4, 0x4

    iget v3, v3, Landroid/graphics/Rect;->bottom:I

    int-to-float v3, v3

    aput v3, v2, v5

    add-int/lit8 v3, v4, 0x5

    invoke-virtual {v6}, Landroid/view/View;->getAlpha()F

    move-result v5

    aput v5, v2, v7

    add-int/lit8 v5, v4, 0x6

    invoke-virtual {v6}, Landroid/view/View;->getLeft()I

    move-result v7

    int-to-float v7, v7

    aput v7, v2, v3

    add-int/lit8 v3, v4, 0x7

    invoke-virtual {v6}, Landroid/view/View;->getTop()I

    move-result v6

    int-to-float v6, v6

    aput v6, v2, v5

    add-int/lit8 v4, v4, 0x8

    if-nez v8, :cond_3

    goto :goto_4

    :cond_3
    invoke-virtual {v8}, Landroid/graphics/drawable/Drawable;->getAlpha()I

    move-result v5

    int-to-float v11, v5

    :goto_4
    aput v11, v2, v3

    move/from16 v3, v19

    move/from16 v5, v20

    goto/16 :goto_0

    :cond_4
    return-object v2
.end method

.method frameViews()Ljava/util/List;
    .locals 6
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Landroid/view/View;",
            ">;"
        }
    .end annotation

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iget-object v1, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-virtual {v1}, Landroid/widget/ImageView;->getParent()Landroid/view/ViewParent;

    move-result-object v1

    instance-of v1, v1, Landroid/view/ViewGroup;

    if-nez v1, :cond_0

    goto :goto_1

    :cond_0
    iget-object v1, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-virtual {v1}, Landroid/widget/ImageView;->getParent()Landroid/view/ViewParent;

    move-result-object v1

    check-cast v1, Landroid/view/ViewGroup;

    const/4 v2, 0x0

    :goto_0
    invoke-virtual {v1}, Landroid/view/ViewGroup;->getChildCount()I

    move-result v3

    if-ge v2, v3, :cond_2

    invoke-virtual {v1, v2}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;

    move-result-object v3

    iget-object v4, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    if-eq v3, v4, :cond_1

    invoke-virtual {v3}, Landroid/view/View;->getVisibility()I

    move-result v4

    if-nez v4, :cond_1

    invoke-virtual {v3}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v4

    const-string v5, "com.samsung.android.app.dressroom.presentation.preview.widget.CropImageView"

    invoke-virtual {v5, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_1

    invoke-static {v3}, Lcom/k4/dressroom/EditXf;->isMain(Landroid/view/View;)Z

    move-result v4

    if-nez v4, :cond_1

    invoke-interface {v0, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    :cond_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    :cond_2
    :goto_1
    return-object v0
.end method

.method frontViews()Ljava/util/List;
    .locals 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Landroid/view/View;",
            ">;"
        }
    .end annotation

    invoke-virtual {p0}, Lcom/k4/dressroom/HomeClock$SubjectView;->frameViews()Ljava/util/List;

    move-result-object p0

    const/4 v0, -0x1

    const/4 v1, 0x0

    move v2, v1

    move v1, v0

    :goto_0
    invoke-interface {p0}, Ljava/util/List;->size()I

    move-result v3

    if-ge v2, v3, :cond_2

    invoke-interface {p0, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Landroid/view/View;

    invoke-static {v3}, Lcom/k4/dressroom/EditXf;->viewType(Landroid/view/View;)Ljava/lang/String;

    move-result-object v3

    const-string v4, "OBJECT"

    invoke-virtual {v4, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_0

    move v0, v2

    goto :goto_1

    :cond_0
    const-string v4, "FRAME_BASE"

    invoke-virtual {v4, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_1

    move v1, v2

    :cond_1
    :goto_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    :cond_2
    if-gez v0, :cond_3

    new-instance p0, Ljava/util/ArrayList;

    invoke-direct {p0}, Ljava/util/ArrayList;-><init>()V

    return-object p0

    :cond_3
    if-le v1, v0, :cond_4

    add-int/lit8 v0, v1, 0x1

    :cond_4
    invoke-interface {p0}, Ljava/util/List;->size()I

    move-result v1

    invoke-static {v0, v1}, Ljava/lang/Math;->min(II)I

    move-result v0

    invoke-interface {p0}, Ljava/util/List;->size()I

    move-result v1

    invoke-interface {p0, v0, v1}, Ljava/util/List;->subList(II)Ljava/util/List;

    move-result-object p0

    return-object p0
.end method

.method protected onDraw(Landroid/graphics/Canvas;)V
    .locals 4

    sget-boolean v0, Lcom/k4/dressroom/EditXf;->sFrameLayout:Z

    if-eqz v0, :cond_0

    :try_start_0
    invoke-virtual {p0, p1}, Lcom/k4/dressroom/HomeClock$SubjectView;->drawFrameFront(Landroid/graphics/Canvas;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception p0

    const-string p1, "K4HomeClock"

    const-string v0, "frame layout views"

    invoke-static {p1, v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_0

    :cond_0
    iget-object v0, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-virtual {v0}, Landroid/widget/ImageView;->getDrawable()Landroid/graphics/drawable/Drawable;

    move-result-object v0

    if-eqz v0, :cond_3

    iget-object v1, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    if-nez v1, :cond_1

    goto :goto_0

    :cond_1
    invoke-static {}, Lcom/k4/dressroom/HomeClock;->styledSubject()Landroid/graphics/Bitmap;

    move-result-object v1

    if-eqz v1, :cond_2

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v2}, Landroid/graphics/drawable/BitmapDrawable;->getBitmap()Landroid/graphics/Bitmap;

    move-result-object v2

    if-eq v1, v2, :cond_2

    new-instance v2, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {p0}, Lcom/k4/dressroom/HomeClock$SubjectView;->getResources()Landroid/content/res/Resources;

    move-result-object v3

    invoke-direct {v2, v3, v1}, Landroid/graphics/drawable/BitmapDrawable;-><init>(Landroid/content/res/Resources;Landroid/graphics/Bitmap;)V

    const/4 v1, 0x1

    invoke-virtual {v2, v1}, Landroid/graphics/drawable/BitmapDrawable;->setFilterBitmap(Z)V

    iget-object v1, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v1}, Landroid/graphics/drawable/BitmapDrawable;->getColorFilter()Landroid/graphics/ColorFilter;

    move-result-object v1

    invoke-virtual {v2, v1}, Landroid/graphics/drawable/BitmapDrawable;->setColorFilter(Landroid/graphics/ColorFilter;)V

    iput-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    :cond_2
    invoke-virtual {p1}, Landroid/graphics/Canvas;->save()I

    move-result v1

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-static {v2, p1}, Lcom/k4/dressroom/EditXf;->apply(Landroid/view/View;Landroid/graphics/Canvas;)V

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-virtual {v2}, Landroid/widget/ImageView;->getPaddingLeft()I

    move-result v2

    int-to-float v2, v2

    iget-object v3, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-virtual {v3}, Landroid/widget/ImageView;->getPaddingTop()I

    move-result v3

    int-to-float v3, v3

    invoke-virtual {p1, v2, v3}, Landroid/graphics/Canvas;->translate(FF)V

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-virtual {v2}, Landroid/widget/ImageView;->getImageMatrix()Landroid/graphics/Matrix;

    move-result-object v2

    invoke-virtual {p1, v2}, Landroid/graphics/Canvas;->concat(Landroid/graphics/Matrix;)V

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v0}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object v0

    invoke-virtual {v2, v0}, Landroid/graphics/drawable/BitmapDrawable;->setBounds(Landroid/graphics/Rect;)V

    iget-object p0, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {p0, p1}, Landroid/graphics/drawable/BitmapDrawable;->draw(Landroid/graphics/Canvas;)V

    invoke-virtual {p1, v1}, Landroid/graphics/Canvas;->restoreToCount(I)V

    :cond_3
    :goto_0
    return-void
.end method

.method public onTouchEvent(Landroid/view/MotionEvent;)Z
    .locals 0

    const/4 p0, 0x0

    return p0
.end method
