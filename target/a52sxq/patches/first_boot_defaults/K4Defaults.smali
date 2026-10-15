.class public final Lcom/k4/settings/K4Defaults;
.super Ljava/lang/Object;
.source "K4Defaults.java"


# static fields
.field private static final MARKER:Ljava/lang/String; = "persist.sys.k4.defaults_v1"

.field private static final TAG:Ljava/lang/String; = "K4Defaults"


# direct methods
.method private constructor <init>()V
    .registers 1

    .line 19
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static apply(Landroid/content/Context;)V
    .registers 5

    .line 23
    const-string v0, "K4Defaults"

    const-string v1, "persist.sys.k4.defaults_v1"

    if-eqz p0, :cond_2a

    const/4 v2, 0x0

    :try_start_7
    invoke-static {v1, v2}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v2

    const/4 v3, 0x1

    if-lt v2, v3, :cond_f

    goto :goto_2a

    .line 24
    :cond_f
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object p0

    const-string v2, "accessibility_reduce_transparency"

    invoke-static {p0, v2, v3}, Landroid/provider/Settings$Global;->putInt(Landroid/content/ContentResolver;Ljava/lang/String;I)Z

    .line 25
    const-string p0, "1"

    invoke-static {v1, p0}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    .line 26
    const-string p0, "defaults v1 applied: Reduce transparency and blur on"

    invoke-static {v0, p0}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_22
    .catchall {:try_start_7 .. :try_end_22} :catchall_23

    .line 29
    goto :goto_29

    .line 27
    :catchall_23
    move-exception p0

    .line 28
    const-string v1, "defaults not applied"

    invoke-static {v0, v1, p0}, Landroid/util/Slog;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 30
    :goto_29
    return-void

    .line 23
    :cond_2a
    :goto_2a
    return-void
.end method
