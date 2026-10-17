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

.field private final now:[F

.field subject:Landroid/graphics/drawable/BitmapDrawable;


# direct methods
.method constructor <init>(Landroid/content/Context;Landroid/widget/ImageView;)V
    .locals 1

    invoke-direct {p0, p1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    const/16 p1, 0xd

    new-array v0, p1, [F

    iput-object v0, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->last:[F

    new-array p1, p1, [F

    iput-object p1, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

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

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->last:[F

    invoke-static {v0, v2}, Ljava/util/Arrays;->equals([F[F)Z

    move-result v0

    if-eqz v0, :cond_1

    return v1

    :cond_1
    iget-object v0, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->now:[F

    iget-object p0, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->last:[F

    array-length v2, v0

    invoke-static {v0, v1, p0, v1, v2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    const/4 p0, 0x1

    return p0
.end method

.method protected onDraw(Landroid/graphics/Canvas;)V
    .locals 4

    iget-object v0, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    invoke-virtual {v0}, Landroid/widget/ImageView;->getDrawable()Landroid/graphics/drawable/Drawable;

    move-result-object v0

    if-eqz v0, :cond_1

    iget-object v1, p0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    if-nez v1, :cond_0

    goto :goto_0

    :cond_0
    invoke-virtual {p1}, Landroid/graphics/Canvas;->save()I

    move-result v1

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

    :cond_1
    :goto_0
    return-void
.end method

.method public onTouchEvent(Landroid/view/MotionEvent;)Z
    .locals 0

    const/4 p0, 0x0

    return p0
.end method
