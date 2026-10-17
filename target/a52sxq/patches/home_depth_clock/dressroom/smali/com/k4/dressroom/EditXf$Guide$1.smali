.class Lcom/k4/dressroom/EditXf$Guide$1;
.super Ljava/lang/Object;
.source "EditXf.java"

# interfaces
.implements Landroid/animation/ValueAnimator$AnimatorUpdateListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/dressroom/EditXf$Guide;->fade(Z)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/k4/dressroom/EditXf$Guide;


# direct methods
.method constructor <init>(Lcom/k4/dressroom/EditXf$Guide;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    iput-object p1, p0, Lcom/k4/dressroom/EditXf$Guide$1;->this$0:Lcom/k4/dressroom/EditXf$Guide;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onAnimationUpdate(Landroid/animation/ValueAnimator;)V
    .locals 1

    iget-object v0, p0, Lcom/k4/dressroom/EditXf$Guide$1;->this$0:Lcom/k4/dressroom/EditXf$Guide;

    invoke-virtual {p1}, Landroid/animation/ValueAnimator;->getAnimatedValue()Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Float;

    invoke-virtual {p1}, Ljava/lang/Float;->floatValue()F

    move-result p1

    iput p1, v0, Lcom/k4/dressroom/EditXf$Guide;->alpha:F

    iget-object p0, p0, Lcom/k4/dressroom/EditXf$Guide$1;->this$0:Lcom/k4/dressroom/EditXf$Guide;

    invoke-virtual {p0}, Lcom/k4/dressroom/EditXf$Guide;->invalidateSelf()V

    return-void
.end method
