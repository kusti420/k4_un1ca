.class final Lcom/k4/homeclock/HomeDepthClock$PostDim;
.super Li3/j;
.source "HomeDepthClock.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/k4/homeclock/HomeDepthClock;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "PostDim"
.end annotation


# instance fields
.field private final engine:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Lf3/a;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method constructor <init>(Lf3/a;)V
    .registers 4

    .line 186
    invoke-virtual {p1}, Lf3/a;->getAppContext()Landroid/content/Context;

    move-result-object v0

    const-string v1, "K4ClockAboveDim"

    invoke-direct {p0, v0, v1}, Li3/j;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 187
    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, p1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    iput-object v0, p0, Lcom/k4/homeclock/HomeDepthClock$PostDim;->engine:Ljava/lang/ref/WeakReference;

    .line 188
    return-void
.end method


# virtual methods
.method public a(Landroid/graphics/Canvas;)V
    .registers 4

    .line 192
    iget-object v0, p0, Lcom/k4/homeclock/HomeDepthClock$PostDim;->engine:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lf3/a;

    .line 193
    if-eqz v0, :cond_1b

    iget-object v1, v0, Lf3/a;->g:Lh3/a;

    instance-of v1, v1, Lcom/k4/homeclock/HomeClockPresenter;

    if-eqz v1, :cond_1b

    .line 194
    iget-object v1, v0, Lf3/a;->g:Lh3/a;

    check-cast v1, Lcom/k4/homeclock/HomeClockPresenter;

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->dimOf(Lf3/a;)F

    move-result v0

    invoke-virtual {v1, p1, v0}, Lcom/k4/homeclock/HomeClockPresenter;->drawAbove(Landroid/graphics/Canvas;F)V

    .line 196
    :cond_1b
    return-void
.end method
