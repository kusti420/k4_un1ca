.class public Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;
.super Lcom/android/settings/core/BasePreferenceController;
.source "GpuDriverPreferenceController.java"

# interfaces
.implements Landroidx/preference/Preference$OnPreferenceChangeListener;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController$SystemProps;
    }
.end annotation


# static fields
.field private static final COLOR_PENDING:I

.field private static final KEY_ACTIVE:Ljava/lang/String; = "k4_gpu_driver_active"

.field private static final KEY_ADD:Ljava/lang/String; = "k4_gpu_driver_add"

.field private static final KEY_BANNER:Ljava/lang/String; = "k4_gpu_driver_restart"

.field private static final KEY_REMOVE:Ljava/lang/String; = "k4_gpu_driver_remove"


# instance fields
.field private mActive:Landroidx/preference/Preference;

.field private mAdd:Landroidx/preference/Preference;

.field private mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

.field private mBannerKind:I

.field private final mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

.field private mPref:Landroidx/preference/DropDownPreference;

.field private mRebootDialog:Landroidx/appcompat/app/AlertDialog;

.field private mRemove:Landroidx/preference/Preference;


# direct methods
.method static constructor <clinit>()V
    .registers 3

    const/16 v0, 0x7c

    const/4 v1, 0x0

    const/16 v2, 0xf5

    .line 42
    invoke-static {v2, v0, v1}, Landroid/graphics/Color;->rgb(III)I

    move-result v0

    sput v0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->COLOR_PENDING:I

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Ljava/lang/String;)V
    .registers 5

    .line 67
    invoke-direct {p0, p1, p2}, Lcom/android/settings/core/BasePreferenceController;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 57
    new-instance p1, Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    new-instance p2, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController$SystemProps;

    invoke-direct {p2}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController$SystemProps;-><init>()V

    new-instance v0, Ljava/io/File;

    const-string v1, "/data/k4gpu"

    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-direct {p1, p2, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverModel$Props;Ljava/io/File;)V

    iput-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    return-void
.end method

.method static label(Landroid/content/Context;Lio/mesalabs/unica/settings/ui/GpuDriverModel;Ljava/lang/String;)Ljava/lang/String;
    .registers 6

    .line 209
    const-string v0, "array"

    invoke-virtual {p1, p2}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->anyEntry(Ljava/lang/String;)Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;

    move-result-object v1

    if-eqz v1, :cond_f

    .line 210
    iget-object v2, v1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->label:Ljava/lang/String;

    if-eqz v2, :cond_f

    iget-object p0, v1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->label:Ljava/lang/String;

    return-object p0

    .line 211
    :cond_f
    invoke-virtual {p1}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->stockDriver()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_32

    invoke-virtual {p1}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->vendorVersion()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_32

    .line 212
    invoke-virtual {p1}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->vendorVersion()Ljava/lang/String;

    move-result-object p1

    filled-new-array {p1}, [Ljava/lang/Object;

    move-result-object p1

    const-string p2, "k4_gpu_driver_label_vendor"

    invoke-static {p0, p2, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Landroid/content/Context;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 214
    :cond_32
    const-string v1, "m_"

    invoke-virtual {p2, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_49

    invoke-virtual {p1, p2}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->moduleOf(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    filled-new-array {p1}, [Ljava/lang/Object;

    move-result-object p1

    const-string p2, "k4_gpu_driver_label_module"

    invoke-static {p0, p2, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Landroid/content/Context;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 215
    :cond_49
    const-string p1, "u_"

    invoke-virtual {p2, p1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result p1

    const/4 v1, 0x0

    if-eqz p1, :cond_5b

    const-string p1, "k4_gpu_driver_label_added"

    new-array p2, v1, [Ljava/lang/Object;

    invoke-static {p0, p1, p2}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Landroid/content/Context;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 217
    :cond_5b
    :try_start_5b
    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object p0

    .line 218
    const-string p1, "k4_gpu_driver_values"

    invoke-static {v0, p1}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result p1

    invoke-virtual {p0, p1}, Landroid/content/res/Resources;->getStringArray(I)[Ljava/lang/String;

    move-result-object p1

    .line 219
    const-string v2, "k4_gpu_driver_entries"

    invoke-static {v0, v2}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    invoke-virtual {p0, v0}, Landroid/content/res/Resources;->getStringArray(I)[Ljava/lang/String;

    move-result-object p0

    .line 220
    :goto_73
    array-length v0, p1

    if-ge v1, v0, :cond_87

    array-length v0, p0

    if-ge v1, v0, :cond_87

    .line 221
    aget-object v0, p1, v1

    invoke-virtual {v0, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_84

    aget-object p0, p0, v1
    :try_end_83
    .catch Landroid/content/res/Resources$NotFoundException; {:try_start_5b .. :try_end_83} :catch_87

    return-object p0

    :cond_84
    add-int/lit8 v1, v1, 0x1

    goto :goto_73

    :catch_87
    :cond_87
    const/16 p0, 0x5f

    const/16 p1, 0x2e

    .line 225
    invoke-virtual {p2, p0, p1}, Ljava/lang/String;->replace(CC)Ljava/lang/String;

    move-result-object p0

    new-instance p1, Ljava/lang/StringBuilder;

    const-string p2, "V@0"

    invoke-direct {p1, p2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private label(Ljava/lang/String;)Ljava/lang/String;
    .registers 3

    .line 201
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mContext:Landroid/content/Context;

    iget-object p0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-static {v0, p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Landroid/content/Context;Lio/mesalabs/unica/settings/ui/GpuDriverModel;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private lockedMessage()Ljava/lang/String;
    .registers 5

    .line 233
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->external()Ljava/lang/String;

    move-result-object v0

    .line 234
    invoke-direct {p0, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->root()Ljava/lang/String;

    move-result-object v2

    iget-object v3, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v3, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->moduleOf(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    filled-new-array {v1, v2, v0}, [Ljava/lang/Object;

    move-result-object v0

    const-string v1, "k4_gpu_driver_locked"

    invoke-direct {p0, v1, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private onBannerButton()V
    .registers 4

    .line 116
    iget v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBannerKind:I

    const/4 v1, 0x2

    const-string v2, ""

    if-eq v0, v1, :cond_27

    const/4 v1, 0x3

    if-eq v0, v1, :cond_1c

    .line 126
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mRebootDialog:Landroidx/appcompat/app/AlertDialog;

    if-nez v0, :cond_16

    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mContext:Landroid/content/Context;

    invoke-static {v0}, Lio/mesalabs/unica/utils/Utils;->createRebootDialog(Landroid/content/Context;)Landroidx/appcompat/app/AlertDialog;

    move-result-object v0

    iput-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mRebootDialog:Landroidx/appcompat/app/AlertDialog;

    .line 127
    :cond_16
    iget-object p0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mRebootDialog:Landroidx/appcompat/app/AlertDialog;

    invoke-virtual {p0}, Landroidx/appcompat/app/AlertDialog;->show()V

    return-void

    .line 122
    :cond_1c
    const-string v0, "sys.k4.gpu_missing"

    invoke-static {v0, v2}, Landroid/os/SemSystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    .line 123
    const-string v0, "sys.k4.gpu_rejected"

    invoke-static {v0, v2}, Landroid/os/SemSystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_33

    .line 118
    :cond_27
    const-string v0, "persist.sys.k4.gpu_failed"

    invoke-static {v0, v2}, Landroid/os/SemSystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    .line 119
    const-string v0, "persist.sys.k4.gpu_trial"

    const-string v1, "ok"

    invoke-static {v0, v1}, Landroid/os/SemSystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    .line 130
    :goto_33
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->refresh()V

    return-void
.end method

.method private refresh()V
    .registers 10

    .line 134
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mPref:Landroidx/preference/DropDownPreference;

    if-eqz v0, :cond_1fd

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->getAvailabilityStatus()I

    move-result v0

    if-eqz v0, :cond_c

    goto/16 :goto_1fd

    .line 135
    :cond_c
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->reload()V

    .line 136
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->entries()Ljava/util/List;

    move-result-object v0

    .line 137
    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v1

    new-array v2, v1, [Ljava/lang/CharSequence;

    .line 138
    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v3

    new-array v3, v3, [Ljava/lang/CharSequence;

    const/4 v4, 0x0

    move v5, v4

    :goto_25
    if-ge v5, v1, :cond_46

    .line 140
    invoke-interface {v0, v5}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;

    iget-object v6, v6, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->id:Ljava/lang/String;

    aput-object v6, v3, v5

    .line 141
    iget-object v6, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mContext:Landroid/content/Context;

    iget-object v7, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-interface {v0, v5}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;

    iget-object v8, v8, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->id:Ljava/lang/String;

    invoke-static {v6, v7, v8}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Landroid/content/Context;Lio/mesalabs/unica/settings/ui/GpuDriverModel;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    aput-object v6, v2, v5

    add-int/lit8 v5, v5, 0x1

    goto :goto_25

    .line 143
    :cond_46
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mPref:Landroidx/preference/DropDownPreference;

    iput-object v3, v0, Landroidx/preference/DropDownPreference;->mEntryValues:[Ljava/lang/CharSequence;

    .line 144
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mPref:Landroidx/preference/DropDownPreference;

    invoke-virtual {v0, v2}, Landroidx/preference/DropDownPreference;->setEntries([Ljava/lang/CharSequence;)V

    .line 146
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->selected()Ljava/lang/String;

    move-result-object v0

    .line 147
    iget-object v1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v1}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->active()Ljava/lang/String;

    move-result-object v1

    .line 148
    iget-object v2, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v2}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->failed()Ljava/lang/String;

    move-result-object v2

    .line 149
    iget-object v3, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v3}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->external()Ljava/lang/String;

    move-result-object v3

    .line 150
    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    .line 152
    iget-object v6, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mPref:Landroidx/preference/DropDownPreference;

    invoke-virtual {v6, v0}, Landroidx/preference/DropDownPreference;->setValue(Ljava/lang/String;)V

    if-nez v5, :cond_8d

    .line 154
    iget-object v3, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mPref:Landroidx/preference/DropDownPreference;

    invoke-direct {p0, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    filled-new-array {v6}, [Ljava/lang/Object;

    move-result-object v6

    const-string v7, "k4_gpu_driver_selected_pending"

    invoke-direct {p0, v7, v6}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v3, v6}, Landroidx/preference/DropDownPreference;->setSummary(Ljava/lang/CharSequence;)V

    .line 155
    iget-object v3, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mPref:Landroidx/preference/DropDownPreference;

    sget v6, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->COLOR_PENDING:I

    invoke-virtual {v3, v6}, Landroidx/preference/DropDownPreference;->seslSetSummaryColor(I)V

    goto :goto_bc

    .line 156
    :cond_8d
    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    move-result v3

    .line 159
    iget-object v6, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mPref:Landroidx/preference/DropDownPreference;

    if-nez v3, :cond_ab

    .line 157
    invoke-direct {p0, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->root()Ljava/lang/String;

    move-result-object v7

    filled-new-array {v3, v7}, [Ljava/lang/Object;

    move-result-object v3

    const-string v7, "k4_gpu_driver_external_summary"

    invoke-direct {p0, v7, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v6, v3}, Landroidx/preference/DropDownPreference;->setSummary(Ljava/lang/CharSequence;)V

    goto :goto_bc

    .line 159
    :cond_ab
    invoke-direct {p0, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    filled-new-array {v3}, [Ljava/lang/Object;

    move-result-object v3

    const-string v7, "k4_gpu_driver_selected_active"

    invoke-direct {p0, v7, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v6, v3}, Landroidx/preference/DropDownPreference;->setSummary(Ljava/lang/CharSequence;)V

    .line 161
    :goto_bc
    iget-object v3, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mActive:Landroidx/preference/Preference;

    if-eqz v3, :cond_c7

    invoke-direct {p0, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v3, v6}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    .line 162
    :cond_c7
    iget-object v3, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mRemove:Landroidx/preference/Preference;

    if-eqz v3, :cond_d4

    iget-object v6, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v6}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->hasUserEntries()Z

    move-result v6

    invoke-virtual {v3, v6}, Landroidx/preference/Preference;->setVisible(Z)V

    .line 164
    :cond_d4
    iget-object v3, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    if-nez v3, :cond_da

    goto/16 :goto_1fd

    .line 165
    :cond_da
    iget-object v3, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v3}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->missing()Ljava/lang/String;

    move-result-object v3

    .line 166
    iget-object v6, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v6}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->rejected()Ljava/lang/String;

    move-result-object v6

    const/4 v7, 0x1

    if-nez v5, :cond_125

    .line 168
    iput v7, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBannerKind:I

    .line 169
    iget-object v2, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    const-string v3, "k4_gpu_driver_restart_title"

    new-array v5, v4, [Ljava/lang/Object;

    invoke-direct {p0, v3, v5}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Lcom/android/settingslib/widget/BannerMessagePreference;->setTitle(Ljava/lang/CharSequence;)V

    .line 170
    iget-object v2, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    invoke-direct {p0, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-direct {p0, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    filled-new-array {v0, v1}, [Ljava/lang/Object;

    move-result-object v0

    const-string v1, "k4_gpu_driver_restart_summary"

    invoke-direct {p0, v1, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v2, v0}, Lcom/android/settingslib/widget/BannerMessagePreference;->setSummary(Ljava/lang/CharSequence;)V

    .line 171
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    sget-object v1, Lcom/android/settingslib/widget/BannerMessagePreference$AttentionLevel;->HIGH:Lcom/android/settingslib/widget/BannerMessagePreference$AttentionLevel;

    invoke-virtual {v0, v1}, Lcom/android/settingslib/widget/BannerMessagePreference;->setAttentionLevel(Lcom/android/settingslib/widget/BannerMessagePreference$AttentionLevel;)V

    .line 172
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    const-string v1, "k4_gpu_driver_restart_button"

    new-array v2, v4, [Ljava/lang/Object;

    invoke-direct {p0, v1, v2}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/android/settingslib/widget/BannerMessagePreference;->setPositiveButtonText(Ljava/lang/CharSequence;)V

    goto/16 :goto_1f3

    .line 173
    :cond_125
    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    const-string v5, "k4_gpu_driver_failed_button"

    if-nez v0, :cond_168

    const/4 v0, 0x2

    .line 174
    iput v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBannerKind:I

    .line 175
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    const-string v3, "k4_gpu_driver_failed_title"

    new-array v6, v4, [Ljava/lang/Object;

    invoke-direct {p0, v3, v6}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v3}, Lcom/android/settingslib/widget/BannerMessagePreference;->setTitle(Ljava/lang/CharSequence;)V

    .line 176
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    invoke-direct {p0, v2}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-direct {p0, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    filled-new-array {v2, v1}, [Ljava/lang/Object;

    move-result-object v1

    const-string v2, "k4_gpu_driver_failed_summary"

    invoke-direct {p0, v2, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/android/settingslib/widget/BannerMessagePreference;->setSummary(Ljava/lang/CharSequence;)V

    .line 177
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    sget-object v1, Lcom/android/settingslib/widget/BannerMessagePreference$AttentionLevel;->MEDIUM:Lcom/android/settingslib/widget/BannerMessagePreference$AttentionLevel;

    invoke-virtual {v0, v1}, Lcom/android/settingslib/widget/BannerMessagePreference;->setAttentionLevel(Lcom/android/settingslib/widget/BannerMessagePreference$AttentionLevel;)V

    .line 178
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    new-array v1, v4, [Ljava/lang/Object;

    invoke-direct {p0, v5, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/android/settingslib/widget/BannerMessagePreference;->setPositiveButtonText(Ljava/lang/CharSequence;)V

    goto/16 :goto_1f3

    .line 179
    :cond_168
    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_17d

    invoke-virtual {v6}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_175

    goto :goto_17d

    .line 192
    :cond_175
    iput v4, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBannerKind:I

    .line 193
    iget-object p0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    invoke-virtual {p0, v4}, Lcom/android/settingslib/widget/BannerMessagePreference;->setVisible(Z)V

    return-void

    :cond_17d
    :goto_17d
    const/4 v0, 0x3

    .line 180
    iput v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBannerKind:I

    .line 181
    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    .line 186
    iget-object v2, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    if-nez v0, :cond_1d1

    .line 182
    const-string v0, "k4_gpu_driver_missing_title"

    new-array v8, v4, [Ljava/lang/Object;

    invoke-direct {p0, v0, v8}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v2, v0}, Lcom/android/settingslib/widget/BannerMessagePreference;->setTitle(Ljava/lang/CharSequence;)V

    .line 183
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    invoke-direct {p0, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-direct {p0, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    filled-new-array {v2, v1}, [Ljava/lang/Object;

    move-result-object v1

    const-string v2, "k4_gpu_driver_missing_summary"

    invoke-direct {p0, v2, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    .line 184
    invoke-virtual {v6}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_1b0

    const-string v2, ""

    goto :goto_1be

    :cond_1b0
    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "\n"

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    :goto_1be
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    .line 183
    invoke-virtual {v0, v1}, Lcom/android/settingslib/widget/BannerMessagePreference;->setSummary(Ljava/lang/CharSequence;)V

    goto :goto_1e1

    .line 186
    :cond_1d1
    const-string v0, "k4_gpu_driver_rejected_title"

    new-array v1, v4, [Ljava/lang/Object;

    invoke-direct {p0, v0, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v2, v0}, Lcom/android/settingslib/widget/BannerMessagePreference;->setTitle(Ljava/lang/CharSequence;)V

    .line 187
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    invoke-virtual {v0, v6}, Lcom/android/settingslib/widget/BannerMessagePreference;->setSummary(Ljava/lang/CharSequence;)V

    .line 189
    :goto_1e1
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    sget-object v1, Lcom/android/settingslib/widget/BannerMessagePreference$AttentionLevel;->MEDIUM:Lcom/android/settingslib/widget/BannerMessagePreference$AttentionLevel;

    invoke-virtual {v0, v1}, Lcom/android/settingslib/widget/BannerMessagePreference;->setAttentionLevel(Lcom/android/settingslib/widget/BannerMessagePreference$AttentionLevel;)V

    .line 190
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    new-array v1, v4, [Ljava/lang/Object;

    invoke-direct {p0, v5, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/android/settingslib/widget/BannerMessagePreference;->setPositiveButtonText(Ljava/lang/CharSequence;)V

    .line 196
    :goto_1f3
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    invoke-virtual {v0, v7}, Lcom/android/settingslib/widget/BannerMessagePreference;->setPositiveButtonVisible(Z)V

    .line 197
    iget-object p0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    invoke-virtual {p0, v7}, Lcom/android/settingslib/widget/BannerMessagePreference;->setVisible(Z)V

    :cond_1fd
    :goto_1fd
    return-void
.end method

.method private root()Ljava/lang/String;
    .registers 3

    .line 229
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->root()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_16

    const/4 v0, 0x0

    new-array v0, v0, [Ljava/lang/Object;

    const-string v1, "k4_gpu_driver_root_unknown"

    invoke-direct {p0, v1, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0

    :cond_16
    iget-object p0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->root()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static varargs string(Landroid/content/Context;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    .registers 4

    .line 242
    const-string v0, "string"

    invoke-static {v0, p1}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result p1

    invoke-virtual {p0, p1, p2}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private varargs string(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    .registers 3

    .line 238
    iget-object p0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mContext:Landroid/content/Context;

    invoke-static {p0, p1, p2}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->string(Landroid/content/Context;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public displayPreference(Landroidx/preference/PreferenceScreen;)V
    .registers 4

    .line 77
    invoke-super {p0, p1}, Lcom/android/settings/core/BasePreferenceController;->displayPreference(Landroidx/preference/PreferenceScreen;)V

    .line 78
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->getPreferenceKey()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroidx/preference/PreferenceScreen;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v0

    check-cast v0, Landroidx/preference/DropDownPreference;

    iput-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mPref:Landroidx/preference/DropDownPreference;

    .line 79
    const-string v0, "k4_gpu_driver_active"

    invoke-virtual {p1, v0}, Landroidx/preference/PreferenceScreen;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v0

    iput-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mActive:Landroidx/preference/Preference;

    .line 80
    const-string v0, "k4_gpu_driver_add"

    invoke-virtual {p1, v0}, Landroidx/preference/PreferenceScreen;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v0

    iput-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mAdd:Landroidx/preference/Preference;

    .line 81
    const-string v0, "k4_gpu_driver_remove"

    invoke-virtual {p1, v0}, Landroidx/preference/PreferenceScreen;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v0

    iput-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mRemove:Landroidx/preference/Preference;

    .line 82
    const-string v0, "k4_gpu_driver_restart"

    invoke-virtual {p1, v0}, Landroidx/preference/PreferenceScreen;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object p1

    check-cast p1, Lcom/android/settingslib/widget/BannerMessagePreference;

    iput-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    .line 83
    iget-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mPref:Landroidx/preference/DropDownPreference;

    if-eqz p1, :cond_38

    invoke-virtual {p1, p0}, Landroidx/preference/DropDownPreference;->setOnPreferenceChangeListener(Landroidx/preference/Preference$OnPreferenceChangeListener;)V

    .line 84
    :cond_38
    iget-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    const/4 v0, 0x0

    if-eqz p1, :cond_4a

    .line 85
    invoke-virtual {p1, v0}, Lcom/android/settingslib/widget/BannerMessagePreference;->setNegativeButtonVisible(Z)V

    .line 86
    iget-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    new-instance v1, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController$$0;

    invoke-direct {v1, p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController$$0;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;)V

    invoke-virtual {p1, v1}, Lcom/android/settingslib/widget/BannerMessagePreference;->setPositiveButtonOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 88
    :cond_4a
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->getAvailabilityStatus()I

    move-result p1

    if-nez p1, :cond_52

    const/4 p1, 0x1

    goto :goto_53

    :cond_52
    move p1, v0

    .line 89
    :goto_53
    iget-object v1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mActive:Landroidx/preference/Preference;

    if-eqz v1, :cond_5a

    invoke-virtual {v1, p1}, Landroidx/preference/Preference;->setVisible(Z)V

    .line 90
    :cond_5a
    iget-object v1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mAdd:Landroidx/preference/Preference;

    if-eqz v1, :cond_61

    invoke-virtual {v1, p1}, Landroidx/preference/Preference;->setVisible(Z)V

    .line 91
    :cond_61
    iget-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mRemove:Landroidx/preference/Preference;

    if-eqz p1, :cond_68

    invoke-virtual {p1, v0}, Landroidx/preference/Preference;->setVisible(Z)V

    .line 92
    :cond_68
    iget-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mBanner:Lcom/android/settingslib/widget/BannerMessagePreference;

    if-eqz p1, :cond_6f

    invoke-virtual {p1, v0}, Lcom/android/settingslib/widget/BannerMessagePreference;->setVisible(Z)V

    .line 93
    :cond_6f
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->refresh()V

    return-void
.end method

.method public getAvailabilityStatus()I
    .registers 1

    .line 72
    iget-object p0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->available()Z

    move-result p0

    if-eqz p0, :cond_a

    const/4 p0, 0x0

    return p0

    :cond_a
    const/4 p0, 0x3

    return p0
.end method

.method public getBackgroundWorkerClass()Ljava/lang/Class;
    .registers 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/lang/Class<",
            "*>;"
        }
    .end annotation

    const/4 p0, 0x0

    return-object p0
.end method

.method public getIntentFilter()Landroid/content/IntentFilter;
    .registers 1

    const/4 p0, 0x0

    return-object p0
.end method

.method public getLaunchIntent()Landroid/content/Intent;
    .registers 1

    const/4 p0, 0x0

    return-object p0
.end method

.method public getSliceHighlightMenuRes()I
    .registers 1

    const/4 p0, 0x0

    return p0
.end method

.method public getStatusText()Ljava/lang/String;
    .registers 1

    const/4 p0, 0x0

    return-object p0
.end method

.method public getValue()Lcom/samsung/android/settings/cube/ControlValue;
    .registers 1

    const/4 p0, 0x0

    return-object p0
.end method

.method public hasAsyncUpdate()Z
    .registers 1

    const/4 p0, 0x0

    return p0
.end method

.method public ignoreUserInteraction()V
    .registers 1

    return-void
.end method

.method public isControllable()Z
    .registers 1

    const/4 p0, 0x0

    return p0
.end method

.method public isPublicSlice()Z
    .registers 1

    const/4 p0, 0x0

    return p0
.end method

.method public isSliceable()Z
    .registers 1

    const/4 p0, 0x0

    return p0
.end method

.method synthetic lambda$displayPreference$0$io-mesalabs-unica-settings-ui-GpuDriverPreferenceController(Landroid/view/View;)V
    .registers 2

    .line 86
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->onBannerButton()V

    return-void
.end method

.method public needUserInteraction(Ljava/lang/Object;)Lcom/samsung/android/settings/cube/Controllable$ControllableType;
    .registers 2

    .line 262
    sget-object p0, Lcom/samsung/android/settings/cube/Controllable$ControllableType;->NO_INTERACTION:Lcom/samsung/android/settings/cube/Controllable$ControllableType;

    return-object p0
.end method

.method public onPreferenceChange(Landroidx/preference/Preference;Ljava/lang/Object;)Z
    .registers 4

    .line 104
    invoke-static {p2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    .line 105
    iget-object p2, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {p2}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->reload()V

    .line 106
    iget-object p2, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {p2, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->select(Ljava/lang/String;)Z

    move-result p1

    const/4 p2, 0x1

    if-nez p1, :cond_30

    .line 107
    iget-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {p1}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->external()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    move-result p1

    if-nez p1, :cond_2b

    iget-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->mContext:Landroid/content/Context;

    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->lockedMessage()Ljava/lang/String;

    move-result-object v0

    invoke-static {p1, v0, p2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V

    .line 108
    :cond_2b
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->refresh()V

    const/4 p0, 0x0

    return p0

    .line 111
    :cond_30
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->refresh()V

    return p2
.end method

.method public runDefaultAction()Z
    .registers 1

    const/4 p0, 0x0

    return p0
.end method

.method public setValue(Lcom/samsung/android/settings/cube/ControlValue;)Lcom/samsung/android/settings/cube/ControlResult;
    .registers 2

    const/4 p0, 0x0

    return-object p0
.end method

.method public updateState(Landroidx/preference/Preference;)V
    .registers 2

    .line 98
    invoke-super {p0, p1}, Lcom/android/settings/core/BasePreferenceController;->updateState(Landroidx/preference/Preference;)V

    .line 99
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->refresh()V

    return-void
.end method

.method public useDynamicSliceSummary()Z
    .registers 1

    const/4 p0, 0x0

    return p0
.end method
