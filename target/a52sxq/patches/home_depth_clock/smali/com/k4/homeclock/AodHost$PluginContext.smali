.class final Lcom/k4/homeclock/AodHost$PluginContext;
.super Landroid/content/ContextWrapper;
.source "AodHost.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/k4/homeclock/AodHost;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "PluginContext"
.end annotation


# instance fields
.field private inflater:Landroid/view/LayoutInflater;

.field private final loader:Ljava/lang/ClassLoader;


# direct methods
.method constructor <init>(Landroid/content/Context;Ljava/lang/ClassLoader;)V
    .registers 3

    .line 57
    invoke-direct {p0, p1}, Landroid/content/ContextWrapper;-><init>(Landroid/content/Context;)V

    .line 58
    iput-object p2, p0, Lcom/k4/homeclock/AodHost$PluginContext;->loader:Ljava/lang/ClassLoader;

    .line 59
    return-void
.end method


# virtual methods
.method public getApplicationContext()Landroid/content/Context;
    .registers 2

    .line 63
    invoke-virtual {p0}, Lcom/k4/homeclock/AodHost$PluginContext;->getBaseContext()Landroid/content/Context;

    move-result-object v0

    return-object v0
.end method

.method public getClassLoader()Ljava/lang/ClassLoader;
    .registers 2

    .line 68
    iget-object v0, p0, Lcom/k4/homeclock/AodHost$PluginContext;->loader:Ljava/lang/ClassLoader;

    return-object v0
.end method

.method public getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    .registers 3

    .line 73
    const-string v0, "layout_inflater"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1d

    .line 74
    iget-object p1, p0, Lcom/k4/homeclock/AodHost$PluginContext;->inflater:Landroid/view/LayoutInflater;

    if-nez p1, :cond_1a

    .line 75
    invoke-virtual {p0}, Lcom/k4/homeclock/AodHost$PluginContext;->getBaseContext()Landroid/content/Context;

    move-result-object p1

    invoke-static {p1}, Landroid/view/LayoutInflater;->from(Landroid/content/Context;)Landroid/view/LayoutInflater;

    move-result-object p1

    invoke-virtual {p1, p0}, Landroid/view/LayoutInflater;->cloneInContext(Landroid/content/Context;)Landroid/view/LayoutInflater;

    move-result-object p1

    iput-object p1, p0, Lcom/k4/homeclock/AodHost$PluginContext;->inflater:Landroid/view/LayoutInflater;

    .line 77
    :cond_1a
    iget-object p1, p0, Lcom/k4/homeclock/AodHost$PluginContext;->inflater:Landroid/view/LayoutInflater;

    return-object p1

    .line 79
    :cond_1d
    invoke-virtual {p0}, Lcom/k4/homeclock/AodHost$PluginContext;->getBaseContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method
