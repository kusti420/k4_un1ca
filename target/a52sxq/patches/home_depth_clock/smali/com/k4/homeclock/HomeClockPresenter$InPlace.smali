.class final Lcom/k4/homeclock/HomeClockPresenter$InPlace;
.super Li3/j;
.source "HomeClockPresenter.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/k4/homeclock/HomeClockPresenter;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x12
    name = "InPlace"
.end annotation


# instance fields
.field final synthetic this$0:Lcom/k4/homeclock/HomeClockPresenter;


# direct methods
.method constructor <init>(Lcom/k4/homeclock/HomeClockPresenter;Landroid/content/Context;)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1010,
            0x0
        }
        names = {
            null,
            null
        }
    .end annotation

    .line 140
    iput-object p1, p0, Lcom/k4/homeclock/HomeClockPresenter$InPlace;->this$0:Lcom/k4/homeclock/HomeClockPresenter;

    .line 141
    const-string p1, "K4ClockInPlace"

    invoke-direct {p0, p2, p1}, Li3/j;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 142
    return-void
.end method


# virtual methods
.method public a(Landroid/graphics/Canvas;)V
    .registers 4

    .line 146
    iget-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter$InPlace;->this$0:Lcom/k4/homeclock/HomeClockPresenter;

    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->postDimInstalled(Lh3/a;)Z

    move-result v0

    if-nez v0, :cond_e

    .line 147
    iget-object v0, p0, Lcom/k4/homeclock/HomeClockPresenter$InPlace;->this$0:Lcom/k4/homeclock/HomeClockPresenter;

    const/4 v1, 0x0

    invoke-virtual {v0, p1, v1}, Lcom/k4/homeclock/HomeClockPresenter;->drawAbove(Landroid/graphics/Canvas;F)V

    .line 149
    :cond_e
    return-void
.end method
