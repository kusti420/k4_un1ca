.class Lcom/k4/dressroom/HomeClock$2;
.super Ljava/lang/Object;
.source "HomeClock.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/dressroom/HomeClock;->addMenu(Lo6/e0;[Lk6/m;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$controller:Lo6/e0;


# direct methods
.method constructor <init>(Lo6/e0;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lcom/k4/dressroom/HomeClock$2;->val$controller:Lo6/e0;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 0

    iget-object p0, p0, Lcom/k4/dressroom/HomeClock$2;->val$controller:Lo6/e0;

    invoke-static {p0}, Lcom/k4/dressroom/HomeClock;->toggle(Lo6/e0;)V

    return-void
.end method
