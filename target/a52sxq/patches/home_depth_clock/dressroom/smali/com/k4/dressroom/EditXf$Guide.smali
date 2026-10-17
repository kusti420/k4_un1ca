.class final Lcom/k4/dressroom/EditXf$Guide;
.super Landroid/graphics/drawable/Drawable;
.source "EditXf.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/k4/dressroom/EditXf;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "Guide"
.end annotation


# instance fields
.field alpha:F

.field anim:Landroid/animation/ValueAnimator;

.field final color:I

.field crop:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Landroid/view/View;",
            ">;"
        }
    .end annotation
.end field

.field final dp:F

.field final line:Landroid/graphics/drawable/Drawable;

.field final pill:Landroid/graphics/Paint;

.field final root:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Landroid/view/View;",
            ">;"
        }
    .end annotation
.end field

.field final text:Landroid/graphics/Paint;

.field final thick:F

.field final thin:F


# direct methods
.method constructor <init>(Landroid/view/View;Landroid/view/View;)V
    .locals 3

    invoke-direct {p0}, Landroid/graphics/drawable/Drawable;-><init>()V

    new-instance v0, Landroid/graphics/Paint;

    const/4 v1, 0x1

    invoke-direct {v0, v1}, Landroid/graphics/Paint;-><init>(I)V

    iput-object v0, p0, Lcom/k4/dressroom/EditXf$Guide;->text:Landroid/graphics/Paint;

    new-instance v0, Landroid/graphics/Paint;

    invoke-direct {v0, v1}, Landroid/graphics/Paint;-><init>(I)V

    iput-object v0, p0, Lcom/k4/dressroom/EditXf$Guide;->pill:Landroid/graphics/Paint;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, p2}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    iput-object v0, p0, Lcom/k4/dressroom/EditXf$Guide;->root:Ljava/lang/ref/WeakReference;

    new-instance p2, Ljava/lang/ref/WeakReference;

    invoke-direct {p2, p1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    iput-object p2, p0, Lcom/k4/dressroom/EditXf$Guide;->crop:Ljava/lang/ref/WeakReference;

    invoke-virtual {p1}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object p1

    invoke-virtual {p1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object p2

    invoke-virtual {p2}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object p2

    iget p2, p2, Landroid/util/DisplayMetrics;->density:F

    iput p2, p0, Lcom/k4/dressroom/EditXf$Guide;->dp:F

    const-string p2, "drawable"

    const-string v0, "align_assist_line"

    invoke-static {p1, p2, v0}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result p2

    const/4 v0, 0x0

    if-eqz p2, :cond_0

    :try_start_0
    invoke-virtual {p1, p2}, Landroid/content/Context;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object p2

    invoke-virtual {p2}, Landroid/graphics/drawable/Drawable;->mutate()Landroid/graphics/drawable/Drawable;

    move-result-object p2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-object v0, p2

    :catchall_0
    :cond_0
    iput-object v0, p0, Lcom/k4/dressroom/EditXf$Guide;->line:Landroid/graphics/drawable/Drawable;

    const-string p2, "color"

    const-string v0, "guide_box_white"

    invoke-static {p1, p2, v0}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result p2

    if-eqz p2, :cond_1

    invoke-virtual {p1, p2}, Landroid/content/Context;->getColor(I)I

    move-result p2

    goto :goto_0

    :cond_1
    const p2, -0x50506

    :goto_0
    iput p2, p0, Lcom/k4/dressroom/EditXf$Guide;->color:I

    const-string p2, "align_assist_line_width"

    const-string v0, "dimen"

    invoke-static {p1, v0, p2}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result p2

    const-string v2, "guide_box_border_stroke_width"

    invoke-static {p1, v0, v2}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    if-eqz p2, :cond_2

    invoke-virtual {p1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    invoke-virtual {v2, p2}, Landroid/content/res/Resources;->getDimension(I)F

    move-result p2

    goto :goto_1

    :cond_2
    iget p2, p0, Lcom/k4/dressroom/EditXf$Guide;->dp:F

    :goto_1
    iput p2, p0, Lcom/k4/dressroom/EditXf$Guide;->thin:F

    if-eqz v0, :cond_3

    invoke-virtual {p1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object p2

    invoke-virtual {p2, v0}, Landroid/content/res/Resources;->getDimension(I)F

    move-result p2

    goto :goto_2

    :cond_3
    const/high16 p2, 0x40000000    # 2.0f

    iget v0, p0, Lcom/k4/dressroom/EditXf$Guide;->dp:F

    mul-float/2addr p2, v0

    :goto_2
    iput p2, p0, Lcom/k4/dressroom/EditXf$Guide;->thick:F

    iget-object p2, p0, Lcom/k4/dressroom/EditXf$Guide;->text:Landroid/graphics/Paint;

    const/4 v0, -0x1

    invoke-virtual {p2, v0}, Landroid/graphics/Paint;->setColor(I)V

    iget-object p2, p0, Lcom/k4/dressroom/EditXf$Guide;->text:Landroid/graphics/Paint;

    invoke-virtual {p1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object p1

    invoke-virtual {p1}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object p1

    iget p1, p1, Landroid/util/DisplayMetrics;->scaledDensity:F

    const/high16 v0, 0x41600000    # 14.0f

    mul-float/2addr p1, v0

    invoke-virtual {p2, p1}, Landroid/graphics/Paint;->setTextSize(F)V

    iget-object p1, p0, Lcom/k4/dressroom/EditXf$Guide;->text:Landroid/graphics/Paint;

    sget-object p2, Landroid/graphics/Paint$Align;->CENTER:Landroid/graphics/Paint$Align;

    invoke-virtual {p1, p2}, Landroid/graphics/Paint;->setTextAlign(Landroid/graphics/Paint$Align;)V

    iget-object p1, p0, Lcom/k4/dressroom/EditXf$Guide;->text:Landroid/graphics/Paint;

    const-string p2, "sec"

    invoke-static {p2, v1}, Landroid/graphics/Typeface;->create(Ljava/lang/String;I)Landroid/graphics/Typeface;

    move-result-object p2

    invoke-virtual {p1, p2}, Landroid/graphics/Paint;->setTypeface(Landroid/graphics/Typeface;)Landroid/graphics/Typeface;

    iget-object p0, p0, Lcom/k4/dressroom/EditXf$Guide;->pill:Landroid/graphics/Paint;

    const/high16 p1, -0x67000000

    invoke-virtual {p0, p1}, Landroid/graphics/Paint;->setColor(I)V

    return-void
.end method


# virtual methods
.method bar(Landroid/graphics/Canvas;FFFFI)V
    .locals 2

    iget-object v0, p0, Lcom/k4/dressroom/EditXf$Guide;->line:Landroid/graphics/drawable/Drawable;

    if-eqz v0, :cond_0

    iget v1, p0, Lcom/k4/dressroom/EditXf$Guide;->color:I

    invoke-virtual {v0, v1}, Landroid/graphics/drawable/Drawable;->setTint(I)V

    iget-object v0, p0, Lcom/k4/dressroom/EditXf$Guide;->line:Landroid/graphics/drawable/Drawable;

    invoke-virtual {v0, p6}, Landroid/graphics/drawable/Drawable;->setAlpha(I)V

    iget-object p6, p0, Lcom/k4/dressroom/EditXf$Guide;->line:Landroid/graphics/drawable/Drawable;

    invoke-static {p2}, Ljava/lang/Math;->round(F)I

    move-result p2

    invoke-static {p3}, Ljava/lang/Math;->round(F)I

    move-result p3

    invoke-static {p4}, Ljava/lang/Math;->round(F)I

    move-result p4

    invoke-static {p5}, Ljava/lang/Math;->round(F)I

    move-result p5

    invoke-virtual {p6, p2, p3, p4, p5}, Landroid/graphics/drawable/Drawable;->setBounds(IIII)V

    iget-object p0, p0, Lcom/k4/dressroom/EditXf$Guide;->line:Landroid/graphics/drawable/Drawable;

    invoke-virtual {p0, p1}, Landroid/graphics/drawable/Drawable;->draw(Landroid/graphics/Canvas;)V

    return-void

    :cond_0
    move v0, p6

    new-instance p6, Landroid/graphics/Paint;

    invoke-direct {p6}, Landroid/graphics/Paint;-><init>()V

    iget p0, p0, Lcom/k4/dressroom/EditXf$Guide;->color:I

    invoke-virtual {p6, p0}, Landroid/graphics/Paint;->setColor(I)V

    invoke-virtual {p6, v0}, Landroid/graphics/Paint;->setAlpha(I)V

    invoke-virtual/range {p1 .. p6}, Landroid/graphics/Canvas;->drawRect(FFFFLandroid/graphics/Paint;)V

    return-void
.end method

.method public draw(Landroid/graphics/Canvas;)V
    .locals 16

    move-object/from16 v0, p0

    move-object/from16 v1, p1

    iget-object v2, v0, Lcom/k4/dressroom/EditXf$Guide;->crop:Ljava/lang/ref/WeakReference;

    invoke-virtual {v2}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/view/View;

    iget v3, v0, Lcom/k4/dressroom/EditXf$Guide;->alpha:F

    const/4 v4, 0x0

    cmpg-float v3, v3, v4

    if-lez v3, :cond_4

    if-eqz v2, :cond_4

    invoke-virtual {v2}, Landroid/view/View;->isAttachedToWindow()Z

    move-result v3

    if-nez v3, :cond_0

    goto/16 :goto_2

    :cond_0
    const/4 v3, 0x2

    new-array v3, v3, [I

    invoke-virtual {v2, v3}, Landroid/view/View;->getLocationInWindow([I)V

    invoke-static {v2}, Lcom/k4/dressroom/HomeClock;->scale(Landroid/view/View;)F

    move-result v5

    const/4 v6, 0x0

    aget v7, v3, v6

    int-to-float v7, v7

    const/4 v8, 0x1

    aget v3, v3, v8

    int-to-float v9, v3

    invoke-virtual {v2}, Landroid/view/View;->getWidth()I

    move-result v3

    int-to-float v3, v3

    mul-float/2addr v3, v5

    add-float/2addr v3, v7

    invoke-virtual {v2}, Landroid/view/View;->getHeight()I

    move-result v10

    int-to-float v10, v10

    mul-float/2addr v10, v5

    add-float/2addr v10, v9

    invoke-virtual {v2}, Landroid/view/View;->getWidth()I

    move-result v11

    int-to-float v11, v11

    const/high16 v12, 0x40000000    # 2.0f

    div-float/2addr v11, v12

    mul-float/2addr v11, v5

    add-float/2addr v11, v7

    invoke-virtual {v2}, Landroid/view/View;->getHeight()I

    move-result v2

    int-to-float v2, v2

    div-float/2addr v2, v12

    mul-float/2addr v2, v5

    add-float v13, v9, v2

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result v14

    cmpl-float v2, v14, v4

    if-nez v2, :cond_1

    move v6, v8

    :cond_1
    iget v2, v0, Lcom/k4/dressroom/EditXf$Guide;->alpha:F

    if-eqz v6, :cond_2

    const/16 v4, 0xff

    goto :goto_0

    :cond_2
    const/16 v4, 0x6e

    :goto_0
    int-to-float v4, v4

    mul-float/2addr v2, v4

    invoke-static {v2}, Ljava/lang/Math;->round(F)I

    move-result v2

    if-eqz v6, :cond_3

    iget v4, v0, Lcom/k4/dressroom/EditXf$Guide;->thick:F

    goto :goto_1

    :cond_3
    iget v4, v0, Lcom/k4/dressroom/EditXf$Guide;->thin:F

    :goto_1
    invoke-virtual {v1}, Landroid/graphics/Canvas;->save()I

    move-result v8

    invoke-virtual {v1, v7, v9, v3, v10}, Landroid/graphics/Canvas;->clipRect(FFFF)Z

    div-float v15, v4, v12

    move v4, v3

    sub-float v3, v13, v15

    add-float v5, v13, v15

    move v6, v2

    move v2, v7

    invoke-virtual/range {v0 .. v6}, Lcom/k4/dressroom/EditXf$Guide;->bar(Landroid/graphics/Canvas;FFFFI)V

    sub-float v2, v11, v15

    add-float v4, v11, v15

    move-object/from16 v0, p0

    move-object/from16 v1, p1

    move v3, v9

    move v5, v10

    invoke-virtual/range {v0 .. v6}, Lcom/k4/dressroom/EditXf$Guide;->bar(Landroid/graphics/Canvas;FFFFI)V

    move-object v9, v0

    invoke-static {v14}, Ljava/lang/Math;->round(F)I

    move-result v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v0, "\u00b0"

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    iget-object v0, v9, Lcom/k4/dressroom/EditXf$Guide;->text:Landroid/graphics/Paint;

    invoke-virtual {v0, v10}, Landroid/graphics/Paint;->measureText(Ljava/lang/String;)F

    move-result v0

    iget-object v1, v9, Lcom/k4/dressroom/EditXf$Guide;->text:Landroid/graphics/Paint;

    invoke-virtual {v1}, Landroid/graphics/Paint;->getFontMetrics()Landroid/graphics/Paint$FontMetrics;

    move-result-object v14

    iget v1, v14, Landroid/graphics/Paint$FontMetrics;->descent:F

    iget v2, v14, Landroid/graphics/Paint$FontMetrics;->ascent:F

    sub-float/2addr v1, v2

    iget v2, v9, Lcom/k4/dressroom/EditXf$Guide;->dp:F

    const/high16 v3, 0x41400000    # 12.0f

    mul-float/2addr v3, v2

    add-float/2addr v1, v3

    const/high16 v3, 0x41c00000    # 24.0f

    mul-float/2addr v2, v3

    add-float/2addr v0, v2

    const v2, 0x3fcccccd    # 1.6f

    mul-float/2addr v2, v1

    invoke-static {v0, v2}, Ljava/lang/Math;->max(FF)F

    move-result v0

    iget v2, v9, Lcom/k4/dressroom/EditXf$Guide;->dp:F

    mul-float/2addr v2, v3

    sub-float/2addr v13, v2

    sub-float v2, v13, v1

    iget-object v3, v9, Lcom/k4/dressroom/EditXf$Guide;->pill:Landroid/graphics/Paint;

    iget v4, v9, Lcom/k4/dressroom/EditXf$Guide;->alpha:F

    const/high16 v5, 0x43190000    # 153.0f

    mul-float/2addr v4, v5

    invoke-static {v4}, Ljava/lang/Math;->round(F)I

    move-result v4

    invoke-virtual {v3, v4}, Landroid/graphics/Paint;->setAlpha(I)V

    div-float/2addr v0, v12

    move v3, v1

    sub-float v1, v11, v0

    add-float/2addr v0, v11

    add-float v4, v2, v3

    div-float v5, v3, v12

    iget-object v7, v9, Lcom/k4/dressroom/EditXf$Guide;->pill:Landroid/graphics/Paint;

    move v6, v5

    move v3, v0

    move-object/from16 v0, p1

    invoke-virtual/range {v0 .. v7}, Landroid/graphics/Canvas;->drawRoundRect(FFFFFFLandroid/graphics/Paint;)V

    move-object v1, v0

    iget-object v0, v9, Lcom/k4/dressroom/EditXf$Guide;->text:Landroid/graphics/Paint;

    iget v3, v9, Lcom/k4/dressroom/EditXf$Guide;->alpha:F

    const/high16 v4, 0x437f0000    # 255.0f

    mul-float/2addr v3, v4

    invoke-static {v3}, Ljava/lang/Math;->round(F)I

    move-result v3

    invoke-virtual {v0, v3}, Landroid/graphics/Paint;->setAlpha(I)V

    add-float/2addr v2, v5

    iget v0, v14, Landroid/graphics/Paint$FontMetrics;->ascent:F

    iget v3, v14, Landroid/graphics/Paint$FontMetrics;->descent:F

    add-float/2addr v0, v3

    div-float/2addr v0, v12

    sub-float/2addr v2, v0

    iget-object v0, v9, Lcom/k4/dressroom/EditXf$Guide;->text:Landroid/graphics/Paint;

    invoke-virtual {v1, v10, v11, v2, v0}, Landroid/graphics/Canvas;->drawText(Ljava/lang/String;FFLandroid/graphics/Paint;)V

    invoke-virtual {v1, v8}, Landroid/graphics/Canvas;->restoreToCount(I)V

    :cond_4
    :goto_2
    return-void
.end method

.method fade(Z)V
    .locals 4

    iget-object v0, p0, Lcom/k4/dressroom/EditXf$Guide;->anim:Landroid/animation/ValueAnimator;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Landroid/animation/ValueAnimator;->cancel()V

    :cond_0
    iget v0, p0, Lcom/k4/dressroom/EditXf$Guide;->alpha:F

    if-eqz p1, :cond_1

    const/high16 v1, 0x3f800000    # 1.0f

    goto :goto_0

    :cond_1
    const/4 v1, 0x0

    :goto_0
    const/4 v2, 0x2

    new-array v2, v2, [F

    const/4 v3, 0x0

    aput v0, v2, v3

    const/4 v0, 0x1

    aput v1, v2, v0

    invoke-static {v2}, Landroid/animation/ValueAnimator;->ofFloat([F)Landroid/animation/ValueAnimator;

    move-result-object v0

    iput-object v0, p0, Lcom/k4/dressroom/EditXf$Guide;->anim:Landroid/animation/ValueAnimator;

    if-eqz p1, :cond_2

    const-wide/16 v1, 0x190

    goto :goto_1

    :cond_2
    const-wide/16 v1, 0x96

    :goto_1
    invoke-virtual {v0, v1, v2}, Landroid/animation/ValueAnimator;->setDuration(J)Landroid/animation/ValueAnimator;

    iget-object p1, p0, Lcom/k4/dressroom/EditXf$Guide;->anim:Landroid/animation/ValueAnimator;

    new-instance v0, Lcom/k4/dressroom/EditXf$Guide$1;

    invoke-direct {v0, p0}, Lcom/k4/dressroom/EditXf$Guide$1;-><init>(Lcom/k4/dressroom/EditXf$Guide;)V

    invoke-virtual {p1, v0}, Landroid/animation/ValueAnimator;->addUpdateListener(Landroid/animation/ValueAnimator$AnimatorUpdateListener;)V

    iget-object p0, p0, Lcom/k4/dressroom/EditXf$Guide;->anim:Landroid/animation/ValueAnimator;

    invoke-virtual {p0}, Landroid/animation/ValueAnimator;->start()V

    return-void
.end method

.method public getOpacity()I
    .locals 0

    const/4 p0, -0x3

    return p0
.end method

.method public setAlpha(I)V
    .locals 0

    return-void
.end method

.method public setColorFilter(Landroid/graphics/ColorFilter;)V
    .locals 0

    return-void
.end method
