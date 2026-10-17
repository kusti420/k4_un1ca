.class public Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;
.super Lcom/android/settings/core/BasePreferenceController;
.source "HomeDepthClockChoiceController.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# static fields
.field static final KEY_ITEM:Ljava/lang/String; = "k4_home_clock_item"

.field static final WALLPAPER_SETTING:Ljava/lang/String; = "com.samsung.intent.action.WALLPAPER_SETTING"


# instance fields
.field private mDialog:Landroidx/appcompat/app/AlertDialog;

.field private mPreference:Landroidx/preference/Preference;


# direct methods
.method public constructor <init>(Landroid/content/Context;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lcom/android/settings/core/BasePreferenceController;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    return-void
.end method

.method private array(Ljava/lang/String;)[Ljava/lang/String;
    .locals 4

    iget-object v0, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    invoke-direct {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->kind()Ljava/lang/String;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "k4_home_depth_clock_"

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    iget-object v1, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    invoke-virtual {v1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "array"

    invoke-virtual {v0, p1, v2, v1}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result p1

    if-eqz p1, :cond_0

    iget-object p0, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object p0

    invoke-virtual {p0, p1}, Landroid/content/res/Resources;->getStringArray(I)[Ljava/lang/String;

    move-result-object p0

    goto :goto_0

    :cond_0
    const/4 p0, 0x0

    :goto_0
    if-eqz p0, :cond_1

    return-object p0

    :cond_1
    const/4 p0, 0x0

    new-array p0, p0, [Ljava/lang/String;

    return-object p0
.end method

.method private currentIndex([Ljava/lang/String;)I
    .locals 2

    invoke-direct {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->prop()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Landroid/os/SemSystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    const/4 v1, 0x0

    if-eqz v0, :cond_0

    return v1

    :cond_0
    :goto_0
    array-length v0, p1

    if-ge v1, v0, :cond_2

    aget-object v0, p1, v1

    invoke-virtual {v0, p0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_1

    return v1

    :cond_1
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    :cond_2
    const/4 p0, -0x1

    return p0
.end method

.method private editorClock()Z
    .locals 1

    :try_start_0
    iget-object p0, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object p0

    const-string v0, "k4_home_clock_item"

    invoke-static {p0, v0}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result p0
    :try_end_0
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_0} :catch_0

    xor-int/lit8 p0, p0, 0x1

    return p0

    :catch_0
    const/4 p0, 0x0

    return p0
.end method

.method private kind()Ljava/lang/String;
    .locals 1

    invoke-virtual {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->getPreferenceKey()Ljava/lang/String;

    move-result-object p0

    if-eqz p0, :cond_0

    const-string v0, "_color"

    invoke-virtual {p0, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string p0, "color"

    return-object p0

    :cond_0
    if-eqz p0, :cond_1

    const-string v0, "_style"

    invoke-virtual {p0, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p0

    if-eqz p0, :cond_1

    const-string p0, "style"

    return-object p0

    :cond_1
    const-string p0, "position"

    return-object p0
.end method

.method private prop()Ljava/lang/String;
    .locals 1

    const-string v0, "color"

    invoke-direct {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->kind()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_0

    const-string p0, "_color"

    goto :goto_0

    :cond_0
    const-string p0, "_y"

    :goto_0
    const-string v0, "persist.sys.k4.home_depth_clock"

    invoke-virtual {v0, p0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private string(Ljava/lang/String;)I
    .locals 2

    iget-object v0, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    iget-object p0, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object p0

    const-string v1, "string"

    invoke-virtual {v0, p1, v1, p0}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result p0

    return p0
.end method


# virtual methods
.method public displayPreference(Landroidx/preference/PreferenceScreen;)V
    .locals 1

    invoke-super {p0, p1}, Lcom/android/settings/core/BasePreferenceController;->displayPreference(Landroidx/preference/PreferenceScreen;)V

    invoke-virtual {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->getPreferenceKey()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroidx/preference/PreferenceScreen;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object p1

    iput-object p1, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mPreference:Landroidx/preference/Preference;

    return-void
.end method

.method public getAvailabilityStatus()I
    .locals 3

    const-string v0, "style"

    invoke-direct {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->kind()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    const/4 v1, 0x0

    const/4 v2, 0x2

    if-eqz v0, :cond_1

    invoke-direct {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->editorClock()Z

    move-result p0

    if-eqz p0, :cond_0

    return v1

    :cond_0
    return v2

    :cond_1
    const-string v0, "_values"

    invoke-direct {p0, v0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->array(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    array-length v0, v0

    if-nez v0, :cond_2

    const/4 p0, 0x3

    return p0

    :cond_2
    invoke-direct {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->editorClock()Z

    move-result p0

    if-eqz p0, :cond_3

    return v2

    :cond_3
    return v1
.end method

.method public getLaunchIntent()Landroid/content/Intent;
    .locals 0

    const/4 p0, 0x0

    return-object p0
.end method

.method public getSliceHighlightMenuRes()I
    .locals 0

    const/4 p0, 0x0

    return p0
.end method

.method public getStatusText()Ljava/lang/String;
    .locals 0

    const/4 p0, 0x0

    return-object p0
.end method

.method public getSummary()Ljava/lang/CharSequence;
    .locals 3

    const-string v0, "style"

    invoke-direct {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->kind()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v0, "k4_home_depth_clock_style_summary"

    invoke-direct {p0, v0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->string(Ljava/lang/String;)I

    move-result v0

    if-eqz v0, :cond_0

    iget-object p0, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    invoke-virtual {p0, v0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    :cond_0
    const/4 p0, 0x0

    return-object p0

    :cond_1
    const-string v0, "_values"

    invoke-direct {p0, v0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->array(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    const-string v1, "_entries"

    invoke-direct {p0, v1}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->array(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v1

    invoke-direct {p0, v0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->currentIndex([Ljava/lang/String;)I

    move-result v0

    if-ltz v0, :cond_2

    array-length v2, v1

    if-ge v0, v2, :cond_2

    aget-object p0, v1, v0

    return-object p0

    :cond_2
    invoke-direct {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->prop()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Landroid/os/SemSystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method public getValue()Lcom/samsung/android/settings/cube/ControlValue;
    .locals 0

    const/4 p0, 0x0

    return-object p0
.end method

.method public handlePreferenceTreeClick(Landroidx/preference/Preference;)Z
    .locals 6

    if-eqz p1, :cond_4

    invoke-virtual {p1}, Landroidx/preference/Preference;->getKey()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->getPreferenceKey()Ljava/lang/String;

    move-result-object v0

    invoke-static {p1, v0}, Landroid/text/TextUtils;->equals(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Z

    move-result p1

    if-nez p1, :cond_0

    goto/16 :goto_1

    :cond_0
    const-string p1, "style"

    invoke-direct {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->kind()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    const/4 v0, 0x1

    if-eqz p1, :cond_1

    :try_start_0
    iget-object p0, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    new-instance p1, Landroid/content/Intent;

    const-string v1, "com.samsung.intent.action.WALLPAPER_SETTING"

    invoke-direct {p1, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    const-string v1, "com.samsung.android.app.dressroom"

    invoke-virtual {p1, v1}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object p1

    const/high16 v1, 0x10000000

    invoke-virtual {p1, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    move-result-object p1

    invoke-virtual {p0, p1}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V
    :try_end_0
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception p0

    const-string p1, "K4HomeClockSettings"

    const-string v1, "Wallpaper and style"

    invoke-static {p1, v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :goto_0
    return v0

    :cond_1
    const-string p1, "_entries"

    invoke-direct {p0, p1}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->array(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object p1

    array-length v1, p1

    if-nez v1, :cond_2

    return v0

    :cond_2
    new-instance v1, Landroidx/appcompat/app/AlertDialog$Builder;

    iget-object v2, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    invoke-direct {v1, v2}, Landroidx/appcompat/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v2, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    invoke-direct {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->kind()Ljava/lang/String;

    move-result-object v3

    new-instance v4, Ljava/lang/StringBuilder;

    const-string v5, "k4_home_depth_clock_"

    invoke-direct {v4, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v3, "_title"

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    iget-object v4, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    invoke-virtual {v4}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v4

    const-string v5, "string"

    invoke-virtual {v2, v3, v5, v4}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v2

    if-eqz v2, :cond_3

    invoke-virtual {v1, v2}, Landroidx/appcompat/app/AlertDialog$Builder;->setTitle(I)V

    :cond_3
    const-string v2, "_values"

    invoke-direct {p0, v2}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->array(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v2

    invoke-direct {p0, v2}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->currentIndex([Ljava/lang/String;)I

    move-result v2

    invoke-virtual {v1, p1, v2, p0}, Landroidx/appcompat/app/AlertDialog$Builder;->setSingleChoiceItems([Ljava/lang/CharSequence;ILandroid/content/DialogInterface$OnClickListener;)V

    const/high16 p1, 0x1040000

    const/4 v2, 0x0

    invoke-virtual {v1, p1, v2}, Landroidx/appcompat/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)V

    invoke-virtual {v1}, Landroidx/appcompat/app/AlertDialog$Builder;->create()Landroidx/appcompat/app/AlertDialog;

    move-result-object p1

    iput-object p1, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mDialog:Landroidx/appcompat/app/AlertDialog;

    invoke-virtual {p1}, Landroidx/appcompat/app/AlertDialog;->show()V

    return v0

    :cond_4
    :goto_1
    const/4 p0, 0x0

    return p0
.end method

.method public isControllable()Z
    .locals 0

    const/4 p0, 0x0

    return p0
.end method

.method public needUserInteraction(Ljava/lang/Object;)Lcom/samsung/android/settings/cube/Controllable$ControllableType;
    .locals 0

    sget-object p0, Lcom/samsung/android/settings/cube/Controllable$ControllableType;->NO_INTERACTION:Lcom/samsung/android/settings/cube/Controllable$ControllableType;

    return-object p0
.end method

.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 2

    const-string v0, "_values"

    invoke-direct {p0, v0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->array(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    if-ltz p2, :cond_0

    array-length v1, v0

    if-ge p2, v1, :cond_0

    invoke-direct {p0}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->prop()Ljava/lang/String;

    move-result-object v1

    aget-object p2, v0, p2

    invoke-static {v1, p2}, Lcom/k4/settings/homeclock/HomeDepthClockSwitchController;->set(Ljava/lang/String;Ljava/lang/String;)V

    iget-object p2, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mContext:Landroid/content/Context;

    invoke-static {p2}, Lcom/k4/settings/homeclock/HomeDepthClockSwitchController;->reload(Landroid/content/Context;)V

    :cond_0
    if-eqz p1, :cond_1

    invoke-interface {p1}, Landroid/content/DialogInterface;->dismiss()V

    :cond_1
    const/4 p1, 0x0

    iput-object p1, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mDialog:Landroidx/appcompat/app/AlertDialog;

    iget-object p1, p0, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->mPreference:Landroidx/preference/Preference;

    if-eqz p1, :cond_2

    invoke-virtual {p0, p1}, Lcom/k4/settings/homeclock/HomeDepthClockChoiceController;->updateState(Landroidx/preference/Preference;)V

    :cond_2
    return-void
.end method

.method public runDefaultAction()Z
    .locals 0

    const/4 p0, 0x0

    return p0
.end method

.method public setValue(Lcom/samsung/android/settings/cube/ControlValue;)Lcom/samsung/android/settings/cube/ControlResult;
    .locals 0

    const/4 p0, 0x0

    return-object p0
.end method
