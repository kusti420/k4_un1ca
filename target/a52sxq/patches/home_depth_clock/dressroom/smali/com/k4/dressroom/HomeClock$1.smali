.class Lcom/k4/dressroom/HomeClock$1;
.super Ljava/lang/Object;
.source "HomeClock.java"

# interfaces
.implements Landroid/view/ViewTreeObserver$OnPreDrawListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/dressroom/HomeClock;->applyVisibility(Lp8/a;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$clock:I

.field final synthetic val$g:Landroid/view/ViewGroup;

.field final synthetic val$star:I


# direct methods
.method constructor <init>(Landroid/view/ViewGroup;II)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lcom/k4/dressroom/HomeClock$1;->val$g:Landroid/view/ViewGroup;

    iput p2, p0, Lcom/k4/dressroom/HomeClock$1;->val$star:I

    iput p3, p0, Lcom/k4/dressroom/HomeClock$1;->val$clock:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onPreDraw()Z
    .locals 3

    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->active:Z

    const/4 v1, 0x1

    if-eqz v0, :cond_2

    iget-object v0, p0, Lcom/k4/dressroom/HomeClock$1;->val$g:Landroid/view/ViewGroup;

    invoke-virtual {v0}, Landroid/view/ViewGroup;->getParent()Landroid/view/ViewParent;

    move-result-object v0

    if-eqz v0, :cond_2

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->-$$Nest$sfgetsEnforced()Ljava/lang/ref/WeakReference;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    iget-object v2, p0, Lcom/k4/dressroom/HomeClock$1;->val$g:Landroid/view/ViewGroup;

    if-eq v0, v2, :cond_0

    goto :goto_0

    :cond_0
    iget v0, p0, Lcom/k4/dressroom/HomeClock$1;->val$star:I

    iget p0, p0, Lcom/k4/dressroom/HomeClock$1;->val$clock:I

    invoke-static {v2, v0, p0}, Lcom/k4/dressroom/HomeClock;->clockOnly(Landroid/view/ViewGroup;II)V

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->-$$Nest$sfgetsMediator()Ljava/lang/ref/WeakReference;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lp8/a;

    if-eqz p0, :cond_1

    invoke-static {p0}, Lcom/k4/dressroom/HomeClock;->hideLauncher(Lp8/a;)V

    :cond_1
    return v1

    :cond_2
    :goto_0
    iget-object v0, p0, Lcom/k4/dressroom/HomeClock$1;->val$g:Landroid/view/ViewGroup;

    invoke-virtual {v0}, Landroid/view/ViewGroup;->getViewTreeObserver()Landroid/view/ViewTreeObserver;

    move-result-object v0

    invoke-virtual {v0, p0}, Landroid/view/ViewTreeObserver;->removeOnPreDrawListener(Landroid/view/ViewTreeObserver$OnPreDrawListener;)V

    return v1
.end method
