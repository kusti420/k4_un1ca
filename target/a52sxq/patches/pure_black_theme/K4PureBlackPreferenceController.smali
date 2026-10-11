.class public Lcom/k4/settings/display/K4PureBlackPreferenceController;
.super Lcom/android/settings/display/HdrBrightnessPreferenceController;
.source "K4PureBlackPreferenceController.java"

# interfaces
.implements Ljava/lang/Runnable;


# Settings > Display > "Pure black dark mode" (a52sxq pure_black_theme patch): enables or disables the runtime resource
# overlay com.k4.overlay.pureblack (target "android") for the current user through OverlayManager; the overlay
# manager persists the state, so it survives a reboot. Settings runs as android.uid.system, which may switch any
# mutable overlay. The switch is hidden when the overlay package is not installed.
#
# The parent is only borrowed as a complete, concrete TogglePreferenceController: this R8-processed SecSettings
# leaves several BasePreferenceController / Sliceable methods abstract and gives every controller its own copies
# (see the hfr patch). Everything the parent does itself (availability, isChecked, setChecked) is overridden here.
#
# setEnabled() on an overlay for "android" rebuilds the idmap and pushes a configuration change to every process, so
# it runs on a worker thread; until it returns isChecked() reports the requested state, not the old one.

# instance fields
.field private volatile mPending:Z

.field private volatile mWant:Z


# direct methods
.method public constructor <init>(Landroid/content/Context;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lcom/android/settings/display/HdrBrightnessPreferenceController;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    return-void
.end method

# OverlayInfo of the overlay for the current user; null when it is not installed or the overlay service is missing
.method private info()Landroid/content/om/OverlayInfo;
    .locals 3

    :try_start_0
    iget-object v0, p0, Lcom/android/settingslib/core/AbstractPreferenceController;->mContext:Landroid/content/Context;

    const-class v1, Landroid/content/om/OverlayManager;

    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/om/OverlayManager;

    if-eqz v0, :cond_none

    const-string v1, "com.k4.overlay.pureblack"

    invoke-static {}, Landroid/os/Process;->myUserHandle()Landroid/os/UserHandle;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Landroid/content/om/OverlayManager;->getOverlayInfo(Ljava/lang/String;Landroid/os/UserHandle;)Landroid/content/om/OverlayInfo;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_0} :catch_0

    return-object v0

    :cond_none
    :catch_0
    const/4 v0, 0x0

    return-object v0
.end method


# virtual methods
.method public getAvailabilityStatus()I
    .locals 1

    invoke-direct {p0}, Lcom/k4/settings/display/K4PureBlackPreferenceController;->info()Landroid/content/om/OverlayInfo;

    move-result-object v0

    if-eqz v0, :cond_unsupported

    const/4 v0, 0x0

    return v0

    :cond_unsupported
    const/4 v0, 0x3

    return v0
.end method

.method public isChecked()Z
    .locals 1

    iget-boolean v0, p0, Lcom/k4/settings/display/K4PureBlackPreferenceController;->mPending:Z

    if-eqz v0, :cond_actual

    iget-boolean v0, p0, Lcom/k4/settings/display/K4PureBlackPreferenceController;->mWant:Z

    return v0

    :cond_actual
    invoke-direct {p0}, Lcom/k4/settings/display/K4PureBlackPreferenceController;->info()Landroid/content/om/OverlayInfo;

    move-result-object v0

    if-eqz v0, :cond_off

    invoke-virtual {v0}, Landroid/content/om/OverlayInfo;->isEnabled()Z

    move-result v0

    return v0

    :cond_off
    const/4 v0, 0x0

    return v0
.end method

# Worker thread: apply the requested state
.method public run()V
    .locals 4

    :try_start_0
    iget-object v0, p0, Lcom/android/settingslib/core/AbstractPreferenceController;->mContext:Landroid/content/Context;

    const-class v1, Landroid/content/om/OverlayManager;

    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/om/OverlayManager;

    const-string v1, "com.k4.overlay.pureblack"

    iget-boolean v2, p0, Lcom/k4/settings/display/K4PureBlackPreferenceController;->mWant:Z

    invoke-static {}, Landroid/os/Process;->myUserHandle()Landroid/os/UserHandle;

    move-result-object v3

    invoke-virtual {v0, v1, v2, v3}, Landroid/content/om/OverlayManager;->setEnabled(Ljava/lang/String;ZLandroid/os/UserHandle;)V
    :try_end_0
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_done

    :catch_0
    move-exception v0

    const-string v1, "K4PureBlack"

    const-string v2, "Could not switch the pure black overlay"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :goto_done
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/k4/settings/display/K4PureBlackPreferenceController;->mPending:Z

    return-void
.end method

.method public setChecked(Z)Z
    .locals 2

    iput-boolean p1, p0, Lcom/k4/settings/display/K4PureBlackPreferenceController;->mWant:Z

    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/k4/settings/display/K4PureBlackPreferenceController;->mPending:Z

    new-instance v0, Ljava/lang/Thread;

    const-string v1, "K4PureBlack"

    invoke-direct {v0, p0, v1}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/lang/Thread;->start()V

    const/4 v0, 0x1

    return v0
.end method
