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
.field private final host:Landroid/content/Context;

.field private inflater:Landroid/view/LayoutInflater;

.field private final loader:Ljava/lang/ClassLoader;


# direct methods
.method constructor <init>(Landroid/content/Context;Ljava/lang/ClassLoader;Landroid/content/Context;)V
    .registers 4

    .line 102
    invoke-direct {p0, p1}, Landroid/content/ContextWrapper;-><init>(Landroid/content/Context;)V

    .line 103
    iput-object p2, p0, Lcom/k4/homeclock/AodHost$PluginContext;->loader:Ljava/lang/ClassLoader;

    .line 104
    iput-object p3, p0, Lcom/k4/homeclock/AodHost$PluginContext;->host:Landroid/content/Context;

    .line 105
    return-void
.end method


# virtual methods
.method public getApplicationContext()Landroid/content/Context;
    .registers 2

    .line 114
    invoke-virtual {p0}, Lcom/k4/homeclock/AodHost$PluginContext;->getBaseContext()Landroid/content/Context;

    move-result-object v0

    return-object v0
.end method

.method public getClassLoader()Ljava/lang/ClassLoader;
    .registers 2

    .line 119
    iget-object v0, p0, Lcom/k4/homeclock/AodHost$PluginContext;->loader:Ljava/lang/ClassLoader;

    return-object v0
.end method

.method public getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    .registers 6

    .line 109
    iget-object v0, p0, Lcom/k4/homeclock/AodHost$PluginContext;->host:Landroid/content/Context;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "aod_plugin_"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v0, p1, p2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object p1

    return-object p1
.end method

.method public getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    .registers 3

    .line 124
    const-string v0, "layout_inflater"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1d

    .line 125
    iget-object p1, p0, Lcom/k4/homeclock/AodHost$PluginContext;->inflater:Landroid/view/LayoutInflater;

    if-nez p1, :cond_1a

    .line 126
    invoke-virtual {p0}, Lcom/k4/homeclock/AodHost$PluginContext;->getBaseContext()Landroid/content/Context;

    move-result-object p1

    invoke-static {p1}, Landroid/view/LayoutInflater;->from(Landroid/content/Context;)Landroid/view/LayoutInflater;

    move-result-object p1

    invoke-virtual {p1, p0}, Landroid/view/LayoutInflater;->cloneInContext(Landroid/content/Context;)Landroid/view/LayoutInflater;

    move-result-object p1

    iput-object p1, p0, Lcom/k4/homeclock/AodHost$PluginContext;->inflater:Landroid/view/LayoutInflater;

    .line 128
    :cond_1a
    iget-object p1, p0, Lcom/k4/homeclock/AodHost$PluginContext;->inflater:Landroid/view/LayoutInflater;

    return-object p1

    .line 130
    :cond_1d
    invoke-virtual {p0}, Lcom/k4/homeclock/AodHost$PluginContext;->getBaseContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method
