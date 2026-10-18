.class Lcom/k4/homeclock/AodHost$3;
.super Ljava/lang/Object;
.source "AodHost.java"

# interfaces
.implements Ljava/lang/reflect/InvocationHandler;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/homeclock/AodHost;->startWeather()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/k4/homeclock/AodHost;


# direct methods
.method constructor <init>(Lcom/k4/homeclock/AodHost;)V
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    .line 241
    iput-object p1, p0, Lcom/k4/homeclock/AodHost$3;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public invoke(Ljava/lang/Object;Ljava/lang/reflect/Method;[Ljava/lang/Object;)Ljava/lang/Object;
    .registers 7

    .line 244
    invoke-virtual {p2}, Ljava/lang/reflect/Method;->getName()Ljava/lang/String;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/String;->hashCode()I

    move-result v0

    const/4 v1, 0x1

    const/4 v2, 0x0

    sparse-switch v0, :sswitch_data_7e

    :cond_d
    goto :goto_36

    :sswitch_e
    const-string v0, "hashCode"

    invoke-virtual {p2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p2

    if-eqz p2, :cond_d

    const/4 p2, 0x2

    goto :goto_37

    :sswitch_18
    const-string v0, "onWeatherInfoUpdated"

    invoke-virtual {p2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p2

    if-eqz p2, :cond_d

    move p2, v2

    goto :goto_37

    :sswitch_22
    const-string v0, "equals"

    invoke-virtual {p2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p2

    if-eqz p2, :cond_d

    move p2, v1

    goto :goto_37

    :sswitch_2c
    const-string v0, "toString"

    invoke-virtual {p2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p2

    if-eqz p2, :cond_d

    const/4 p2, 0x3

    goto :goto_37

    :goto_36
    const/4 p2, -0x1

    :goto_37
    const/4 v0, 0x0

    packed-switch p2, :pswitch_data_90

    .line 265
    return-object v0

    .line 263
    :pswitch_3c
    const-string p1, "K4HomeClockWeatherListener"

    return-object p1

    .line 261
    :pswitch_3f
    invoke-static {p1}, Ljava/lang/System;->identityHashCode(Ljava/lang/Object;)I

    move-result p1

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    return-object p1

    .line 259
    :pswitch_48
    if-eqz p3, :cond_52

    array-length p2, p3

    if-ne p2, v1, :cond_52

    aget-object p2, p3, v2

    if-ne p1, p2, :cond_52

    goto :goto_53

    :cond_52
    move v1, v2

    :goto_53
    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p1

    return-object p1

    .line 246
    :pswitch_58
    if-eqz p3, :cond_60

    array-length p1, p3

    if-lez p1, :cond_60

    aget-object p1, p3, v2

    goto :goto_61

    :cond_60
    move-object p1, v0

    .line 247
    :goto_61
    invoke-static {}, Landroid/os/Looper;->myLooper()Landroid/os/Looper;

    move-result-object p2

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object p3

    if-ne p2, p3, :cond_71

    .line 248
    iget-object p2, p0, Lcom/k4/homeclock/AodHost$3;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-static {p2, p1}, Lcom/k4/homeclock/AodHost;->-$$Nest$monWeather(Lcom/k4/homeclock/AodHost;Ljava/lang/Object;)V

    goto :goto_7d

    .line 250
    :cond_71
    invoke-static {}, Lcom/k4/homeclock/AodHost;->-$$Nest$smmain()Landroid/os/Handler;

    move-result-object p2

    new-instance p3, Lcom/k4/homeclock/AodHost$3$1;

    invoke-direct {p3, p0, p1}, Lcom/k4/homeclock/AodHost$3$1;-><init>(Lcom/k4/homeclock/AodHost$3;Ljava/lang/Object;)V

    invoke-virtual {p2, p3}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 257
    :goto_7d
    return-object v0

    :sswitch_data_7e
    .sparse-switch
        -0x69e9ad94 -> :sswitch_2c
        -0x4d378041 -> :sswitch_22
        -0x38818c28 -> :sswitch_18
        0x8cdac1b -> :sswitch_e
    .end sparse-switch

    :pswitch_data_90
    .packed-switch 0x0
        :pswitch_58
        :pswitch_48
        :pswitch_3f
        :pswitch_3c
    .end packed-switch
.end method
