.class public final Lio/mesalabs/unica/KnoxPatchHooks;
.super Ljava/lang/Object;
.source "KnoxPatchHooks.java"


# static fields
.field private static volatile blacklist sPackageName:Ljava/lang/String;

.field private static volatile blacklist sSpoofBootState:Z

.field private static volatile blacklist sSpoofBuildType:Z

.field private static volatile blacklist sDisableKnoxSdk:Z

.field private static volatile blacklist sDisableSak:Z

.field private static volatile blacklist sHideRoot:Z


# direct methods
.method private constructor blacklist <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static blacklist init(Landroid/content/Context;)V
    .locals 2

    if-eqz p0, :cond_0

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_0

    sput-object v0, Lio/mesalabs/unica/KnoxPatchHooks;->sPackageName:Ljava/lang/String;

    invoke-static {v0}, Lio/mesalabs/unica/KnoxPatchHooks;->isPropertySpoofPackage(Ljava/lang/String;)Z

    move-result v1

    sput-boolean v1, Lio/mesalabs/unica/KnoxPatchHooks;->sSpoofBootState:Z

    sput-boolean v1, Lio/mesalabs/unica/KnoxPatchHooks;->sSpoofBuildType:Z

    invoke-static {v0}, Lio/mesalabs/unica/KnoxPatchHooks;->isSakDisablePackage(Ljava/lang/String;)Z

    move-result v1

    sput-boolean v1, Lio/mesalabs/unica/KnoxPatchHooks;->sDisableSak:Z

    invoke-static {v0}, Lio/mesalabs/unica/KnoxPatchHooks;->isRootDetectionPackage(Ljava/lang/String;)Z

    move-result v1

    sput-boolean v1, Lio/mesalabs/unica/KnoxPatchHooks;->sHideRoot:Z

    const-string v1, "com.sec.android.app.shealth"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    sput-boolean v0, Lio/mesalabs/unica/KnoxPatchHooks;->sDisableKnoxSdk:Z

    :cond_0
    return-void
.end method

.method private static blacklist isPropertySpoofPackage(Ljava/lang/String;)Z
    .locals 1

    const-string v0, "com.samsung.android.rampart"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "com.samsung.android.scpm"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "com.samsung.knox.securefolder"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "com.samsung.android.fast"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "com.samsung.android.oneconnect"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    return p0

    :cond_0
    const/4 p0, 0x1

    return p0
.end method

.method private static blacklist isRootDetectionPackage(Ljava/lang/String;)Z
    .locals 1

    const-string v0, "com.sec.android.app.billing"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "com.samsung.android.galaxycontinuity"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "com.samsung.android.shealthmonitor"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "com.samsung.android.oneconnect"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    return p0

    :cond_0
    const/4 p0, 0x1

    return p0
.end method

.method private static blacklist isRootPackage(Ljava/lang/String;)Z
    .locals 3

    const-string v0, ";com.noshufou.android.su;com.noshufou.android.su.elite;eu.chainfire.supersu;com.koushikdutta.superuser;com.thirdparty.superuser;com.yellowes.su;com.devadvance.rootcloak;com.devadvance.rootcloakplus;de.robv.android.xposed.installer;com.saurik.substrate;com.zachspong.temprootremovejb;com.amphoras.hidemyroot;com.amphoras.hidemyrootadfree;com.formyhm.hiderootPremium;com.formyhm.hideroot;com.koushikdutta.rommanager;com.koushikdutta.rommanager.license;com.dimonvideo.luckypatcher;com.chelpus.lackypatch;com.ramdroid.appquarantine;com.ramdroid.appquarantinepro;stericson.busybox;com.topjohnwu.magisk;me.weishu.kernelsu;com.rifsxd.ksunext;com.resukisu.resukisu;com.sukisu.ultra;"

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, ";"

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v1, ";"

    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v0, p0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result p0

    return p0
.end method

.method private static blacklist isSakDisablePackage(Ljava/lang/String;)Z
    .locals 1

    const-string v0, "com.samsung.android.fmm"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "com.samsung.android.tvplus"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    return p0

    :cond_0
    const/4 p0, 0x1

    return p0
.end method

.method public static blacklist onPackageNameQuery(Ljava/lang/String;)Ljava/lang/String;
    .locals 1

    sget-boolean v0, Lio/mesalabs/unica/KnoxPatchHooks;->sHideRoot:Z

    if-eqz v0, :cond_0

    invoke-static {p0}, Lio/mesalabs/unica/KnoxPatchHooks;->isRootPackage(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string p0, "io.fake.pkg"

    :cond_0
    return-object p0
.end method

.method public static blacklist onSystemPropertiesGet(Ljava/lang/String;)Ljava/lang/String;
    .locals 2

    const-string v0, "ro.build.official.release"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string p0, "false"

    return-object p0

    :cond_0
    sget-boolean v0, Lio/mesalabs/unica/KnoxPatchHooks;->sSpoofBuildType:Z

    if-eqz v0, :cond_1

    const-string v0, "ro.build.type"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_1

    const-string p0, "eng"

    return-object p0

    :cond_1
    const/4 p0, 0x0

    return-object p0
.end method

.method public static blacklist onSystemPropertiesGet(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .locals 2

    const-string v0, "ro.build.official.release"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_8

    sget-boolean v0, Lio/mesalabs/unica/KnoxPatchHooks;->sSpoofBuildType:Z

    if-eqz v0, :cond_0

    const-string v0, "ro.build.type"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string p0, "eng"

    return-object p0

    :cond_0
    sget-boolean v0, Lio/mesalabs/unica/KnoxPatchHooks;->sDisableSak:Z

    if-eqz v0, :cond_1

    const-string v0, "ro.security.keystore.keytype"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_8

    :cond_1
    sget-boolean v0, Lio/mesalabs/unica/KnoxPatchHooks;->sSpoofBootState:Z

    if-eqz v0, :cond_7

    const-string v0, "ro.boot.flash.locked"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_2

    const-string p0, "1"

    return-object p0

    :cond_2
    const-string v0, "ro.boot.verifiedbootstate"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_3

    const-string p0, "green"

    return-object p0

    :cond_3
    const-string v0, "ro.boot.warranty_bit"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_4

    const-string p0, "0"

    return-object p0

    :cond_4
    const-string v0, "ro.config.iccc_version"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-nez p0, :cond_8

    :cond_7
    const/4 p0, 0x0

    return-object p0

    :cond_8
    return-object p1
.end method

.method public static blacklist shouldDisableKnoxSdk()Z
    .locals 1

    sget-boolean v0, Lio/mesalabs/unica/KnoxPatchHooks;->sDisableKnoxSdk:Z

    return v0
.end method
