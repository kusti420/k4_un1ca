.class public Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;
.super Lcom/android/settings/core/BasePreferenceController;
.source "ScreenResolutionPreferenceController.java"

# interfaces
.implements Lcom/android/settingslib/core/lifecycle/LifecycleObserver;
.implements Lcom/android/settingslib/core/lifecycle/events/OnResume;
.implements Lcom/android/settingslib/core/lifecycle/events/OnPause;


# Settings > Display > Screen resolution (key "unica_screen_resolution").
# Changing the resolution changes the density, which recreates the Settings activity: the
# pending auto-revert lives in ScreenResolutionUtils (process-wide), and the "Keep this
# resolution?" dialog is re-shown by whichever controller instance is resumed next.


# instance fields
.field public mChooserDialog:Landroidx/appcompat/app/AlertDialog;

.field public mConfirmDialog:Landroidx/appcompat/app/AlertDialog;

.field public final mHandler:Landroid/os/Handler;

.field public mPreference:Landroidx/preference/Preference;

.field public final mTickRunnable:Ljava/lang/Runnable;


# direct methods
.method public constructor <init>(Landroid/content/Context;Ljava/lang/String;)V
    .locals 2

    invoke-direct {p0, p1, p2}, Lcom/android/settings/core/BasePreferenceController;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mHandler:Landroid/os/Handler;

    new-instance v0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$TickRunnable;

    invoke-direct {v0, p0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$TickRunnable;-><init>(Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;)V

    iput-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mTickRunnable:Ljava/lang/Runnable;

    return-void
.end method


# virtual methods
.method public displayPreference(Landroidx/preference/PreferenceScreen;)V
    .locals 1

    invoke-super {p0, p1}, Lcom/android/settings/core/BasePreferenceController;->displayPreference(Landroidx/preference/PreferenceScreen;)V

    invoke-virtual {p0}, Lcom/android/settings/core/BasePreferenceController;->getPreferenceKey()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroidx/preference/PreferenceGroup;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object p1

    iput-object p1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mPreference:Landroidx/preference/Preference;

    return-void
.end method

# Only on fixed-resolution panels wider than 720 px: targets that keep Samsung's own
# DYN_RESOLUTION_CONTROL (WQHD,FHD,HD) already have Settings > Display > Screen resolution.
.method public getAvailabilityStatus()I
    .locals 2

    invoke-static {}, Lcom/samsung/android/feature/SemFloatingFeature;->getInstance()Lcom/samsung/android/feature/SemFloatingFeature;

    move-result-object v0

    const-string v1, "SEC_FLOATING_FEATURE_COMMON_CONFIG_DYN_RESOLUTION_CONTROL"

    invoke-virtual {v0, v1}, Lcom/samsung/android/feature/SemFloatingFeature;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->readState()[I

    move-result-object v0

    if-eqz v0, :cond_0

    const/4 v1, 0x0

    aget v0, v0, v1

    const/16 v1, 0x2d0

    if-le v0, v1, :cond_0

    const/4 v0, 0x0

    return v0

    :cond_0
    const/4 v0, 0x3

    return v0
.end method

.method public getSummary()Ljava/lang/CharSequence;
    .locals 2

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->readState()[I

    move-result-object v0

    if-nez v0, :cond_0

    const/4 p0, 0x0

    return-object p0

    :cond_0
    invoke-static {v0}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getModeIndex([I)I

    move-result v1

    iget-object p0, p0, Lcom/android/settingslib/core/AbstractPreferenceController;->mContext:Landroid/content/Context;

    invoke-static {p0, v1, v0}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getEntryLabel(Landroid/content/Context;I[I)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method public handlePreferenceTreeClick(Landroidx/preference/Preference;)Z
    .locals 1

    invoke-virtual {p1}, Landroidx/preference/Preference;->getKey()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p0}, Lcom/android/settings/core/BasePreferenceController;->getPreferenceKey()Ljava/lang/String;

    move-result-object v0

    invoke-static {p1, v0}, Landroid/text/TextUtils;->equals(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Z

    move-result p1

    if-eqz p1, :cond_0

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->showChooser()V

    const/4 p0, 0x1

    return p0

    :cond_0
    const/4 p0, 0x0

    return p0
.end method

.method public showChooser()V
    .locals 7

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->readState()[I

    move-result-object v0

    if-nez v0, :cond_0

    return-void

    :cond_0
    invoke-static {v0}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getModeIndex([I)I

    move-result v1

    const/4 v2, 0x3

    new-array v2, v2, [Ljava/lang/CharSequence;

    iget-object v3, p0, Lcom/android/settingslib/core/AbstractPreferenceController;->mContext:Landroid/content/Context;

    const/4 v4, 0x0

    :goto_0
    const/4 v5, 0x3

    if-ge v4, v5, :cond_1

    invoke-static {v3, v4, v0}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getEntryLabel(Landroid/content/Context;I[I)Ljava/lang/String;

    move-result-object v5

    aput-object v5, v2, v4

    add-int/lit8 v4, v4, 0x1

    goto :goto_0

    :cond_1
    # One UI 9 SecSettings ships an R8-shrunk androidx where the Builder setters return void (setTitle(I)V ...)
    new-instance v4, Landroidx/appcompat/app/AlertDialog$Builder;

    invoke-direct {v4, v3}, Landroidx/appcompat/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const-string v5, "string"

    const-string v6, "unica_screen_resolution_title"

    invoke-static {v5, v6}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result v5

    invoke-virtual {v4, v5}, Landroidx/appcompat/app/AlertDialog$Builder;->setTitle(I)V

    new-instance v5, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$DialogListener;

    const/4 v6, 0x0

    invoke-direct {v5, p0, v6}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$DialogListener;-><init>(Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;I)V

    invoke-virtual {v4, v2, v1, v5}, Landroidx/appcompat/app/AlertDialog$Builder;->setSingleChoiceItems([Ljava/lang/CharSequence;ILandroid/content/DialogInterface$OnClickListener;)V

    # android.R.string.cancel
    const/high16 v5, 0x1040000

    const/4 v6, 0x0

    invoke-virtual {v4, v5, v6}, Landroidx/appcompat/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)V

    invoke-virtual {v4}, Landroidx/appcompat/app/AlertDialog$Builder;->create()Landroidx/appcompat/app/AlertDialog;

    move-result-object v4

    iput-object v4, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mChooserDialog:Landroidx/appcompat/app/AlertDialog;

    invoke-virtual {v4}, Landroid/app/Dialog;->show()V

    return-void
.end method

.method public onModeSelected(I)V
    .locals 1

    const/4 v0, 0x0

    iput-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mChooserDialog:Landroidx/appcompat/app/AlertDialog;

    invoke-static {p1}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->applyMode(I)Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->showConfirmDialog()V

    :cond_0
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->refreshPreference()V

    return-void
.end method

.method public refreshPreference()V
    .locals 1

    iget-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mPreference:Landroidx/preference/Preference;

    if-eqz v0, :cond_0

    invoke-virtual {p0, v0}, Lcom/android/settingslib/core/AbstractPreferenceController;->updateState(Landroidx/preference/Preference;)V

    :cond_0
    return-void
.end method

.method public getConfirmMessage()Ljava/lang/String;
    .locals 4

    iget-object v0, p0, Lcom/android/settingslib/core/AbstractPreferenceController;->mContext:Landroid/content/Context;

    const-string v1, "string"

    const-string v2, "unica_screen_resolution_confirm_msg"

    invoke-static {v1, v2}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result v1

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->getRemainingSeconds()I

    move-result v2

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    const/4 v3, 0x1

    new-array v3, v3, [Ljava/lang/Object;

    const/4 p0, 0x0

    aput-object v2, v3, p0

    invoke-virtual {v0, v1, v3}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method public showConfirmDialog()V
    .locals 6

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->isPending()Z

    move-result v0

    if-nez v0, :cond_0

    return-void

    :cond_0
    iget-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mConfirmDialog:Landroidx/appcompat/app/AlertDialog;

    if-eqz v0, :cond_1

    invoke-virtual {v0}, Landroid/app/Dialog;->isShowing()Z

    move-result v0

    if-eqz v0, :cond_1

    return-void

    :cond_1
    iget-object v0, p0, Lcom/android/settingslib/core/AbstractPreferenceController;->mContext:Landroid/content/Context;

    new-instance v1, Landroidx/appcompat/app/AlertDialog$Builder;

    invoke-direct {v1, v0}, Landroidx/appcompat/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const-string v2, "string"

    const-string v3, "unica_screen_resolution_confirm_title"

    invoke-static {v2, v3}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result v3

    invoke-virtual {v1, v3}, Landroidx/appcompat/app/AlertDialog$Builder;->setTitle(I)V

    const-string v3, "unica_screen_resolution_keep"

    invoke-static {v2, v3}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result v3

    new-instance v4, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$DialogListener;

    const/4 v5, 0x1

    invoke-direct {v4, p0, v5}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$DialogListener;-><init>(Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;I)V

    invoke-virtual {v1, v3, v4}, Landroidx/appcompat/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)V

    const-string v3, "unica_screen_resolution_revert"

    invoke-static {v2, v3}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result v3

    new-instance v4, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$DialogListener;

    const/4 v5, 0x2

    invoke-direct {v4, p0, v5}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$DialogListener;-><init>(Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;I)V

    invoke-virtual {v1, v3, v4}, Landroidx/appcompat/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)V

    invoke-virtual {v1}, Landroidx/appcompat/app/AlertDialog$Builder;->create()Landroidx/appcompat/app/AlertDialog;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {v1, v2}, Landroid/app/Dialog;->setCancelable(Z)V

    invoke-virtual {v1, v2}, Landroid/app/Dialog;->setCanceledOnTouchOutside(Z)V

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->getConfirmMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroidx/appcompat/app/AlertDialog;->setMessage(Ljava/lang/CharSequence;)V

    iput-object v1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mConfirmDialog:Landroidx/appcompat/app/AlertDialog;

    invoke-virtual {v1}, Landroid/app/Dialog;->show()V

    iget-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mHandler:Landroid/os/Handler;

    iget-object v1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mTickRunnable:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    const-wide/16 v2, 0x3e8

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    return-void
.end method

# Updates the countdown once a second; closes the dialog once the auto-revert has run
.method public tick()V
    .locals 4

    iget-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mConfirmDialog:Landroidx/appcompat/app/AlertDialog;

    if-nez v0, :cond_0

    return-void

    :cond_0
    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->isPending()Z

    move-result v1

    if-nez v1, :cond_1

    invoke-virtual {v0}, Landroid/app/Dialog;->dismiss()V

    const/4 v0, 0x0

    iput-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mConfirmDialog:Landroidx/appcompat/app/AlertDialog;

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->refreshPreference()V

    return-void

    :cond_1
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->getConfirmMessage()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroidx/appcompat/app/AlertDialog;->setMessage(Ljava/lang/CharSequence;)V

    iget-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mHandler:Landroid/os/Handler;

    iget-object v1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mTickRunnable:Ljava/lang/Runnable;

    const-wide/16 v2, 0x3e8

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    return-void
.end method

.method public onKeep()V
    .locals 2

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->keep()V

    iget-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mHandler:Landroid/os/Handler;

    iget-object v1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mTickRunnable:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    const/4 v0, 0x0

    iput-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mConfirmDialog:Landroidx/appcompat/app/AlertDialog;

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->refreshPreference()V

    return-void
.end method

.method public onRevert()V
    .locals 2

    iget-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mHandler:Landroid/os/Handler;

    iget-object v1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mTickRunnable:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    const/4 v0, 0x0

    iput-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mConfirmDialog:Landroidx/appcompat/app/AlertDialog;

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->revert()V

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->refreshPreference()V

    return-void
.end method

.method public onResume()V
    .locals 0

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->showConfirmDialog()V

    return-void
.end method

# The pending auto-revert keeps running (ScreenResolutionUtils); only this activity's dialogs go
.method public onPause()V
    .locals 2

    iget-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mHandler:Landroid/os/Handler;

    iget-object v1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mTickRunnable:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    const/4 v1, 0x0

    iget-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mConfirmDialog:Landroidx/appcompat/app/AlertDialog;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Landroid/app/Dialog;->dismiss()V

    iput-object v1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mConfirmDialog:Landroidx/appcompat/app/AlertDialog;

    :cond_0
    iget-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mChooserDialog:Landroidx/appcompat/app/AlertDialog;

    if-eqz v0, :cond_1

    invoke-virtual {v0}, Landroid/app/Dialog;->dismiss()V

    iput-object v1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->mChooserDialog:Landroidx/appcompat/app/AlertDialog;

    :cond_1
    return-void
.end method

.method public bridge synthetic getBackgroundWorkerClass()Ljava/lang/Class;
    .locals 0

    const/4 p0, 0x0

    return-object p0
.end method

.method public getBackupKeys()Ljava/util/List;
    .locals 0

    new-instance p0, Ljava/util/ArrayList;

    invoke-direct {p0}, Ljava/util/ArrayList;-><init>()V

    return-object p0
.end method

.method public bridge synthetic getIntentFilter()Landroid/content/IntentFilter;
    .locals 0

    const/4 p0, 0x0

    return-object p0
.end method

.method public bridge synthetic getLaunchIntent()Landroid/content/Intent;
    .locals 0

    const/4 p0, 0x0

    return-object p0
.end method

.method public bridge synthetic getSliceHighlightMenuRes()I
    .locals 0

    const/4 p0, 0x0

    return p0
.end method

.method public bridge synthetic getStatusText()Ljava/lang/String;
    .locals 0

    const/4 p0, 0x0

    return-object p0
.end method

.method public bridge synthetic getValue()Lcom/samsung/android/settings/cube/ControlValue;
    .locals 0

    const/4 p0, 0x0

    return-object p0
.end method

.method public bridge synthetic hasAsyncUpdate()Z
    .locals 0

    const/4 p0, 0x0

    return p0
.end method

.method public bridge synthetic ignoreUserInteraction()V
    .locals 0

    return-void
.end method

.method public bridge synthetic isControllable()Z
    .locals 0

    const/4 p0, 0x0

    return p0
.end method

.method public bridge synthetic isPublicSlice()Z
    .locals 0

    const/4 p0, 0x0

    return p0
.end method

.method public bridge synthetic isSliceable()Z
    .locals 0

    const/4 p0, 0x0

    return p0
.end method

.method public bridge synthetic needUserInteraction(Ljava/lang/Object;)Lcom/samsung/android/settings/cube/Controllable$ControllableType;
    .locals 0

    sget-object p0, Lcom/samsung/android/settings/cube/Controllable$ControllableType;->NO_INTERACTION:Lcom/samsung/android/settings/cube/Controllable$ControllableType;

    return-object p0
.end method

.method public bridge synthetic runDefaultAction()Z
    .locals 0

    const/4 p0, 0x0

    return p0
.end method

.method public bridge synthetic setValue(Lcom/samsung/android/settings/cube/ControlValue;)Lcom/samsung/android/settings/cube/ControlResult;
    .locals 0

    const/4 p0, 0x0

    return-object p0
.end method

.method public bridge synthetic useDynamicSliceSummary()Z
    .locals 0

    const/4 p0, 0x0

    return p0
.end method
