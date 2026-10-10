.class public final Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;
.super Ljava/lang/Object;
.source "ScreenResolutionUtils.java"


# Renders the UI at a lower resolution (the display hardware upscales) while keeping every
# element the same physical size: the density is scaled together with the width
# (450 dpi @ 1080 -> 300 dpi @ 720 -> 225 dpi @ 540). Uses plain WindowManager forced
# size/density (what "wm size"/"wm density" do), never Samsung's DYN_RESOLUTION machinery.


# static fields
.field private static final CONFIRM_TIMEOUT_MS:J = 0x3a98L

.field public static final MODE_HD:I = 0x1

.field public static final MODE_LOW:I = 0x2

.field public static final MODE_NATIVE:I = 0x0

.field private static final TAG:Ljava/lang/String; = "UnicaScreenResolution"

.field private static sDeadline:J

.field private static sHandler:Landroid/os/Handler;

.field private static sPending:Z

.field private static sPrevDensity:I

.field private static sPrevHeight:I

.field private static sPrevWidth:I

.field private static sRevertRunnable:Ljava/lang/Runnable;


# direct methods
.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

# Returns {initialWidth, initialHeight, initialDensity, baseWidth, baseHeight, baseDensity}
# of the default display (natural orientation), or null if WindowManager can't be queried.
.method public static readState()[I
    .locals 7

    :try_start_0
    invoke-static {}, Landroid/view/WindowManagerGlobal;->getWindowManagerService()Landroid/view/IWindowManager;

    move-result-object v0

    new-instance v1, Landroid/graphics/Point;

    invoke-direct {v1}, Landroid/graphics/Point;-><init>()V

    new-instance v2, Landroid/graphics/Point;

    invoke-direct {v2}, Landroid/graphics/Point;-><init>()V

    const/4 v3, 0x0

    invoke-interface {v0, v3, v1}, Landroid/view/IWindowManager;->getInitialDisplaySize(ILandroid/graphics/Point;)V

    invoke-interface {v0, v3, v2}, Landroid/view/IWindowManager;->getBaseDisplaySize(ILandroid/graphics/Point;)V

    const/4 v4, 0x6

    new-array v4, v4, [I

    iget v5, v1, Landroid/graphics/Point;->x:I

    if-lez v5, :cond_0

    const/4 v6, 0x0

    aput v5, v4, v6

    iget v5, v1, Landroid/graphics/Point;->y:I

    if-lez v5, :cond_0

    const/4 v6, 0x1

    aput v5, v4, v6

    invoke-interface {v0, v3}, Landroid/view/IWindowManager;->getInitialDisplayDensity(I)I

    move-result v5

    if-lez v5, :cond_0

    const/4 v6, 0x2

    aput v5, v4, v6

    iget v5, v2, Landroid/graphics/Point;->x:I

    if-lez v5, :cond_0

    const/4 v6, 0x3

    aput v5, v4, v6

    iget v5, v2, Landroid/graphics/Point;->y:I

    if-lez v5, :cond_0

    const/4 v6, 0x4

    aput v5, v4, v6

    invoke-interface {v0, v3}, Landroid/view/IWindowManager;->getBaseDisplayDensity(I)I

    move-result v5

    if-lez v5, :cond_0

    const/4 v6, 0x5

    aput v5, v4, v6
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-object v4

    :catch_0
    move-exception v0

    const-string v1, "UnicaScreenResolution"

    const-string v2, "Failed to read the display state"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_0
    const/4 v0, 0x0

    return-object v0
.end method

.method public static getTargetWidth(II)I
    .locals 1

    if-nez p0, :cond_0

    return p1

    :cond_0
    const/4 v0, 0x1

    if-ne p0, v0, :cond_1

    const/16 v0, 0x2d0

    return v0

    :cond_1
    const/16 v0, 0x21c

    return v0
.end method

# Height keeping the panel aspect ratio: 2400 * 720 / 1080 = 1600, 2400 * 540 / 1080 = 1200
.method public static getTargetHeight([II)I
    .locals 2

    const/4 v0, 0x1

    aget v0, p0, v0

    mul-int/2addr v0, p1

    const/4 v1, 0x0

    aget v1, p0, v1

    div-int/2addr v0, v1

    return v0
.end method

# 0 = native, 1 = HD+, 2 = 540p, -1 = anything else (e.g. a size set with "wm size")
.method public static getModeIndex([I)I
    .locals 5

    const/4 v0, 0x0

    :goto_0
    const/4 v1, 0x3

    if-ge v0, v1, :cond_1

    const/4 v1, 0x0

    aget v1, p0, v1

    invoke-static {v0, v1}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getTargetWidth(II)I

    move-result v1

    invoke-static {p0, v1}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getTargetHeight([II)I

    move-result v2

    const/4 v3, 0x3

    aget v3, p0, v3

    const/4 v4, 0x4

    aget v4, p0, v4

    if-ne v3, v1, :cond_0

    if-ne v4, v2, :cond_0

    return v0

    :cond_0
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    :cond_1
    const/4 v0, -0x1

    return v0
.end method

# Scales the CURRENT density with the width, so a Screen zoom level picked by the user is kept
# (zoomed 480 @ 1080 -> 320 @ 720 -> 240 @ 540). Snaps to the unzoomed default when within 1 dpi.
.method public static computeDensity([II)I
    .locals 4

    const/4 v0, 0x5

    aget v0, p0, v0

    mul-int/2addr v0, p1

    const/4 v1, 0x3

    aget v1, p0, v1

    div-int/lit8 v2, v1, 0x2

    add-int/2addr v0, v2

    div-int/2addr v0, v1

    const/4 v1, 0x2

    aget v1, p0, v1

    mul-int/2addr v1, p1

    const/4 v2, 0x0

    aget v2, p0, v2

    div-int/lit8 v3, v2, 0x2

    add-int/2addr v1, v3

    div-int/2addr v1, v2

    sub-int v2, v0, v1

    const/4 v3, -0x1

    if-lt v2, v3, :cond_0

    const/4 v3, 0x1

    if-gt v2, v3, :cond_0

    return v1

    :cond_0
    return v0
.end method

.method private static getHandler()Landroid/os/Handler;
    .locals 2

    sget-object v0, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sHandler:Landroid/os/Handler;

    if-nez v0, :cond_0

    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    sput-object v0, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sHandler:Landroid/os/Handler;

    new-instance v1, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils$RevertRunnable;

    invoke-direct {v1}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils$RevertRunnable;-><init>()V

    sput-object v1, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sRevertRunnable:Ljava/lang/Runnable;

    :cond_0
    return-object v0
.end method

# applySize(width, height, density, initialWidth, initialHeight, initialDensity)
# Size and density are switched atomically through Samsung's setForcedDisplaySizeDensity (one
# configuration change, persisted to display_size_forced/display_density_forced, the same call
# Screen zoom uses with a -1 size); falls back to the AOSP calls "wm size"/"wm density" use.
# Going back to the panel size also clears the size override, like "wm size reset".
.method private static applySize(IIIIII)V
    .locals 9

    move/from16 v7, p0

    move/from16 v8, p1

    :try_start_0
    invoke-static {}, Landroid/view/WindowManagerGlobal;->getWindowManagerService()Landroid/view/IWindowManager;

    move-result-object v0

    const/4 v1, 0x0

    move v2, v7

    move v3, v8

    move/from16 v4, p2

    const/4 v5, 0x1

    const/4 v6, -0x1

    invoke-interface/range {v0 .. v6}, Landroid/view/IWindowManager;->setForcedDisplaySizeDensity(IIIIZI)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    :catch_0
    move-exception v0

    const-string v1, "UnicaScreenResolution"

    const-string v2, "setForcedDisplaySizeDensity failed, using setForcedDisplaySize/Density"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :try_start_1
    invoke-static {}, Landroid/view/WindowManagerGlobal;->getWindowManagerService()Landroid/view/IWindowManager;

    move-result-object v0

    const/4 v1, 0x0

    if-ne v7, p3, :cond_0

    if-ne v8, p4, :cond_0

    invoke-interface {v0, v1}, Landroid/view/IWindowManager;->clearForcedDisplaySize(I)V

    goto :goto_0

    :cond_0
    invoke-interface {v0, v1, v7, v8}, Landroid/view/IWindowManager;->setForcedDisplaySize(III)V

    :goto_0
    const/4 v2, -0x2

    move/from16 v3, p2

    move/from16 v4, p5

    if-ne v3, v4, :cond_1

    invoke-interface {v0, v1, v2}, Landroid/view/IWindowManager;->clearForcedDisplayDensityForUser(II)V

    goto :goto_1

    :cond_1
    invoke-interface {v0, v1, v3, v2}, Landroid/view/IWindowManager;->setForcedDisplayDensityForUser(III)V
    :try_end_1
    .catch Ljava/lang/Throwable; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_1

    :catch_1
    move-exception v0

    const-string v1, "UnicaScreenResolution"

    const-string v2, "Failed to apply the screen resolution"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    return-void

    :goto_1
    if-ne v7, p3, :cond_2

    if-ne v8, p4, :cond_2

    :try_start_2
    invoke-static {}, Landroid/view/WindowManagerGlobal;->getWindowManagerService()Landroid/view/IWindowManager;

    move-result-object v0

    const/4 v1, 0x0

    invoke-interface {v0, v1}, Landroid/view/IWindowManager;->clearForcedDisplaySize(I)V
    :try_end_2
    .catch Ljava/lang/Throwable; {:try_start_2 .. :try_end_2} :catch_2

    goto :goto_2

    :catch_2
    move-exception v0

    const-string v1, "UnicaScreenResolution"

    const-string v2, "clearForcedDisplaySize failed"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_2
    :goto_2
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "Applied "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, "x"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " @ "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move/from16 v1, p2

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " dpi"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "UnicaScreenResolution"

    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

# Applies the given mode and arms the 15 s auto-revert. Returns false if nothing changed.
.method public static applyMode(I)Z
    .locals 12

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->readState()[I

    move-result-object v0

    const/4 v1, 0x0

    if-nez v0, :cond_0

    return v1

    :cond_0
    const/4 v2, 0x0

    aget v6, v0, v2

    const/4 v2, 0x1

    aget v7, v0, v2

    const/4 v2, 0x2

    aget v8, v0, v2

    const/4 v2, 0x3

    aget v9, v0, v2

    const/4 v2, 0x4

    aget v10, v0, v2

    const/4 v2, 0x5

    aget v11, v0, v2

    invoke-static {p0, v6}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getTargetWidth(II)I

    move-result v3

    invoke-static {v0, v3}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getTargetHeight([II)I

    move-result v4

    invoke-static {v0, v3}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->computeDensity([II)I

    move-result v5

    if-ne v3, v9, :cond_1

    if-ne v4, v10, :cond_1

    if-ne v5, v11, :cond_1

    return v1

    :cond_1
    sget-boolean v2, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sPending:Z

    if-nez v2, :cond_2

    sput v9, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sPrevWidth:I

    sput v10, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sPrevHeight:I

    sput v11, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sPrevDensity:I

    :cond_2
    invoke-static/range {v3 .. v8}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->applySize(IIIIII)V

    const/4 v2, 0x1

    sput-boolean v2, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sPending:Z

    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v0

    const-wide/16 v3, 0x3a98

    add-long/2addr v0, v3

    sput-wide v0, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sDeadline:J

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getHandler()Landroid/os/Handler;

    move-result-object v0

    sget-object v1, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sRevertRunnable:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    invoke-virtual {v0, v1, v3, v4}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    return v2
.end method

.method public static isPending()Z
    .locals 1

    sget-boolean v0, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sPending:Z

    return v0
.end method

# Seconds left before the auto-revert, rounded up
.method public static getRemainingSeconds()I
    .locals 4

    sget-wide v0, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sDeadline:J

    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v2

    sub-long/2addr v0, v2

    const-wide/16 v2, 0x3e7

    add-long/2addr v0, v2

    const-wide/16 v2, 0x3e8

    div-long/2addr v0, v2

    long-to-int v0, v0

    if-gez v0, :cond_0

    const/4 v0, 0x0

    :cond_0
    return v0
.end method

.method private static cancelRevert()V
    .locals 2

    const/4 v0, 0x0

    sput-boolean v0, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sPending:Z

    sget-object v0, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sHandler:Landroid/os/Handler;

    if-eqz v0, :cond_0

    sget-object v1, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sRevertRunnable:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    :cond_0
    return-void
.end method

.method public static keep()V
    .locals 0

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->cancelRevert()V

    return-void
.end method

# Restores the size/density that was active before the pending change
.method public static revert()V
    .locals 8

    sget-boolean v0, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sPending:Z

    if-nez v0, :cond_0

    return-void

    :cond_0
    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->cancelRevert()V

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->readState()[I

    move-result-object v0

    if-nez v0, :cond_1

    return-void

    :cond_1
    sget v2, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sPrevWidth:I

    sget v3, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sPrevHeight:I

    sget v4, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->sPrevDensity:I

    const/4 v1, 0x0

    aget v5, v0, v1

    const/4 v1, 0x1

    aget v6, v0, v1

    const/4 v1, 0x2

    aget v7, v0, v1

    const-string v0, "UnicaScreenResolution"

    const-string v1, "Reverting to the previous screen resolution"

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    invoke-static/range {v2 .. v7}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->applySize(IIIIII)V

    return-void
.end method

# "<label> (<w> x <h>)" for a mode index (-1 = the current custom size)
.method public static getEntryLabel(Landroid/content/Context;I[I)Ljava/lang/String;
    .locals 6

    const-string v0, "string"

    if-nez p1, :cond_0

    const-string v1, "unica_screen_resolution_native"

    goto :goto_0

    :cond_0
    const/4 v1, 0x1

    if-ne p1, v1, :cond_1

    const-string v1, "unica_screen_resolution_hd"

    goto :goto_0

    :cond_1
    const/4 v1, 0x2

    if-ne p1, v1, :cond_2

    const-string v1, "unica_screen_resolution_low"

    goto :goto_0

    :cond_2
    const-string v1, "unica_screen_resolution_custom"

    :goto_0
    invoke-static {v0, v1}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result v1

    invoke-virtual {p0, v1}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    if-gez p1, :cond_3

    const/4 v2, 0x3

    aget v2, p2, v2

    const/4 v3, 0x4

    aget v3, p2, v3

    goto :goto_1

    :cond_3
    const/4 v2, 0x0

    aget v2, p2, v2

    invoke-static {p1, v2}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getTargetWidth(II)I

    move-result v2

    invoke-static {p2, v2}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getTargetHeight([II)I

    move-result v3

    :goto_1
    const-string v4, "unica_screen_resolution_entry"

    invoke-static {v0, v4}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    const/4 v4, 0x3

    new-array v4, v4, [Ljava/lang/Object;

    const/4 v5, 0x0

    aput-object v1, v4, v5

    const/4 v5, 0x1

    aput-object v2, v4, v5

    const/4 v5, 0x2

    aput-object v3, v4, v5

    invoke-virtual {p0, v0, v4}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

# Hooked at the top of SecScreenSizePreferenceController.handlePreferenceTreeClick: Samsung's
# Screen zoom only knows the WQHD/FHD/HD density ladders, so below 720 px it would offer HD+
# densities (UI 4/3 too big). Consume the click there and explain instead.
.method public static blockScreenZoomClick(Lcom/android/settings/core/BasePreferenceController;Landroidx/preference/Preference;)Z
    .locals 4

    const/4 v0, 0x0

    if-eqz p0, :cond_0

    if-nez p1, :cond_1

    :cond_0
    return v0

    :cond_1
    invoke-virtual {p1}, Landroidx/preference/Preference;->getKey()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0}, Lcom/android/settings/core/BasePreferenceController;->getPreferenceKey()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/text/TextUtils;->equals(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Z

    move-result v1

    if-nez v1, :cond_2

    return v0

    :cond_2
    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->readState()[I

    move-result-object v1

    if-nez v1, :cond_3

    return v0

    :cond_3
    const/4 v2, 0x0

    aget v2, v1, v2

    const/16 v3, 0x2d0

    if-le v2, v3, :cond_4

    const/4 v2, 0x3

    aget v2, v1, v2

    if-lt v2, v3, :cond_5

    :cond_4
    return v0

    :cond_5
    invoke-virtual {p1}, Landroidx/preference/Preference;->getContext()Landroid/content/Context;

    move-result-object p0

    const-string v1, "string"

    const-string v2, "unica_screen_resolution_zoom_unavailable"

    invoke-static {v1, v2}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result v1

    const/4 v2, 0x1

    invoke-static {p0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;II)Landroid/widget/Toast;

    move-result-object p0

    invoke-virtual {p0}, Landroid/widget/Toast;->show()V

    return v2
.end method
