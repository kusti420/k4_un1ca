.class Lcom/k4/dressroom/HomeClock$4;
.super Ljava/lang/Object;
.source "HomeClock.java"

# interfaces
.implements Landroid/view/ViewTreeObserver$OnPreDrawListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/dressroom/HomeClock;->placeSubject(Landroid/view/ViewGroup;Landroid/view/View;Landroid/graphics/Bitmap;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$crop:Landroid/widget/ImageView;

.field final synthetic val$ref:Ljava/lang/ref/WeakReference;


# direct methods
.method constructor <init>(Ljava/lang/ref/WeakReference;Landroid/widget/ImageView;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lcom/k4/dressroom/HomeClock$4;->val$ref:Ljava/lang/ref/WeakReference;

    iput-object p2, p0, Lcom/k4/dressroom/HomeClock$4;->val$crop:Landroid/widget/ImageView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onPreDraw()Z
    .locals 5

    iget-object v0, p0, Lcom/k4/dressroom/HomeClock$4;->val$ref:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/k4/dressroom/HomeClock$SubjectView;

    const/4 v1, 0x1

    if-eqz v0, :cond_4

    invoke-virtual {v0}, Lcom/k4/dressroom/HomeClock$SubjectView;->getParent()Landroid/view/ViewParent;

    move-result-object v2

    if-nez v2, :cond_0

    goto :goto_0

    :cond_0
    invoke-virtual {v0}, Lcom/k4/dressroom/HomeClock$SubjectView;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;

    move-result-object v2

    check-cast v2, Landroid/widget/FrameLayout$LayoutParams;

    iget v3, v2, Landroid/widget/FrameLayout$LayoutParams;->leftMargin:I

    iget-object v4, p0, Lcom/k4/dressroom/HomeClock$4;->val$crop:Landroid/widget/ImageView;

    invoke-virtual {v4}, Landroid/widget/ImageView;->getLeft()I

    move-result v4

    if-ne v3, v4, :cond_1

    iget v3, v2, Landroid/widget/FrameLayout$LayoutParams;->topMargin:I

    iget-object v4, p0, Lcom/k4/dressroom/HomeClock$4;->val$crop:Landroid/widget/ImageView;

    invoke-virtual {v4}, Landroid/widget/ImageView;->getTop()I

    move-result v4

    if-ne v3, v4, :cond_1

    iget v3, v2, Landroid/widget/FrameLayout$LayoutParams;->width:I

    iget-object v4, p0, Lcom/k4/dressroom/HomeClock$4;->val$crop:Landroid/widget/ImageView;

    invoke-virtual {v4}, Landroid/widget/ImageView;->getWidth()I

    move-result v4

    if-ne v3, v4, :cond_1

    iget v3, v2, Landroid/widget/FrameLayout$LayoutParams;->height:I

    iget-object v4, p0, Lcom/k4/dressroom/HomeClock$4;->val$crop:Landroid/widget/ImageView;

    invoke-virtual {v4}, Landroid/widget/ImageView;->getHeight()I

    move-result v4

    if-eq v3, v4, :cond_2

    :cond_1
    iget-object v3, p0, Lcom/k4/dressroom/HomeClock$4;->val$crop:Landroid/widget/ImageView;

    invoke-virtual {v3}, Landroid/widget/ImageView;->getLeft()I

    move-result v3

    iput v3, v2, Landroid/widget/FrameLayout$LayoutParams;->leftMargin:I

    iget-object v3, p0, Lcom/k4/dressroom/HomeClock$4;->val$crop:Landroid/widget/ImageView;

    invoke-virtual {v3}, Landroid/widget/ImageView;->getTop()I

    move-result v3

    iput v3, v2, Landroid/widget/FrameLayout$LayoutParams;->topMargin:I

    iget-object v3, p0, Lcom/k4/dressroom/HomeClock$4;->val$crop:Landroid/widget/ImageView;

    invoke-virtual {v3}, Landroid/widget/ImageView;->getWidth()I

    move-result v3

    iput v3, v2, Landroid/widget/FrameLayout$LayoutParams;->width:I

    iget-object p0, p0, Lcom/k4/dressroom/HomeClock$4;->val$crop:Landroid/widget/ImageView;

    invoke-virtual {p0}, Landroid/widget/ImageView;->getHeight()I

    move-result p0

    iput p0, v2, Landroid/widget/FrameLayout$LayoutParams;->height:I

    invoke-virtual {v0, v2}, Lcom/k4/dressroom/HomeClock$SubjectView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    :cond_2
    invoke-virtual {v0}, Lcom/k4/dressroom/HomeClock$SubjectView;->changed()Z

    move-result p0

    if-eqz p0, :cond_3

    invoke-virtual {v0}, Lcom/k4/dressroom/HomeClock$SubjectView;->invalidate()V

    :cond_3
    return v1

    :cond_4
    :goto_0
    iget-object v0, p0, Lcom/k4/dressroom/HomeClock$4;->val$crop:Landroid/widget/ImageView;

    invoke-virtual {v0}, Landroid/widget/ImageView;->getViewTreeObserver()Landroid/view/ViewTreeObserver;

    move-result-object v0

    invoke-virtual {v0, p0}, Landroid/view/ViewTreeObserver;->removeOnPreDrawListener(Landroid/view/ViewTreeObserver$OnPreDrawListener;)V

    return v1
.end method
