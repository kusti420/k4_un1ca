.class Lcom/k4/dressroom/EditXf$3;
.super Ljava/lang/Object;
.source "EditXf.java"

# interfaces
.implements Landroid/view/View$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/dressroom/EditXf;->label(Landroid/content/Context;ILjava/lang/String;ILandroid/view/View;)Landroid/widget/TextView;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$crop:Landroid/view/View;

.field final synthetic val$mode:I


# direct methods
.method constructor <init>(ILandroid/view/View;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput p1, p0, Lcom/k4/dressroom/EditXf$3;->val$mode:I

    iput-object p2, p0, Lcom/k4/dressroom/EditXf$3;->val$crop:Landroid/view/View;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 0

    iget p1, p0, Lcom/k4/dressroom/EditXf$3;->val$mode:I

    iget-object p0, p0, Lcom/k4/dressroom/EditXf$3;->val$crop:Landroid/view/View;

    invoke-static {p1, p0}, Lcom/k4/dressroom/EditXf;->select(ILandroid/view/View;)V

    return-void
.end method
