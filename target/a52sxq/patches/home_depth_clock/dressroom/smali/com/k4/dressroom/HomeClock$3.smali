.class Lcom/k4/dressroom/HomeClock$3;
.super Ljava/lang/Object;
.source "HomeClock.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/dressroom/HomeClock;->onObject(Landroid/view/View;Ljava/lang/Object;Landroid/graphics/Bitmap;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$bmp:Landroid/graphics/Bitmap;

.field final synthetic val$cropView:Landroid/view/View;

.field final synthetic val$lock:Landroid/view/ViewGroup;


# direct methods
.method constructor <init>(Landroid/view/ViewGroup;Landroid/view/View;Landroid/graphics/Bitmap;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lcom/k4/dressroom/HomeClock$3;->val$lock:Landroid/view/ViewGroup;

    iput-object p2, p0, Lcom/k4/dressroom/HomeClock$3;->val$cropView:Landroid/view/View;

    iput-object p3, p0, Lcom/k4/dressroom/HomeClock$3;->val$bmp:Landroid/graphics/Bitmap;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    iget-object v0, p0, Lcom/k4/dressroom/HomeClock$3;->val$lock:Landroid/view/ViewGroup;

    iget-object v1, p0, Lcom/k4/dressroom/HomeClock$3;->val$cropView:Landroid/view/View;

    iget-object p0, p0, Lcom/k4/dressroom/HomeClock$3;->val$bmp:Landroid/graphics/Bitmap;

    invoke-static {v0, v1, p0}, Lcom/k4/dressroom/HomeClock;->placeSubject(Landroid/view/ViewGroup;Landroid/view/View;Landroid/graphics/Bitmap;)V

    return-void
.end method
