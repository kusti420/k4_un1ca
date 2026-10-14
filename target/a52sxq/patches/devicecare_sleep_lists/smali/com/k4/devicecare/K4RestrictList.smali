.class public final Lcom/k4/devicecare/K4RestrictList;
.super Ljava/lang/Object;
.source "K4RestrictList.java"


# static fields
.field private static final FAS:Landroid/net/Uri;

.field private static final ROLES:[Ljava/lang/String;

.field private static final SOFT:J = 0x100008L

.field private static final TAG:Ljava/lang/String; = "K4RestrictList"

.field private static final WAIT_MS:J = 0xfa0L


# direct methods
.method static constructor <clinit>()V
    .registers 7

    .line 39
    const-string v0, "content://com.sec.android.sdhms.fasprovider/ForcedAppStandby"

    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    sput-object v0, Lcom/k4/devicecare/K4RestrictList;->FAS:Landroid/net/Uri;

    .line 41
    const-string v5, "android.app.role.WALLET"

    const-string v6, "android.app.role.SYSTEM_GALLERY"

    const-string v1, "android.app.role.DIALER"

    const-string v2, "android.app.role.SMS"

    const-string v3, "android.app.role.HOME"

    const-string v4, "android.app.role.ASSISTANT"

    filled-new-array/range {v1 .. v6}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/k4/devicecare/K4RestrictList;->ROLES:[Ljava/lang/String;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 44
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static varargs call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;
    .registers 10

    .line 269
    const/4 v0, 0x0

    if-nez p0, :cond_4

    return-object v0

    .line 271
    :cond_4
    :try_start_4
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Class;->getMethods()[Ljava/lang/reflect/Method;

    move-result-object v1

    array-length v2, v1

    const/4 v3, 0x0

    :goto_e
    if-ge v3, v2, :cond_2c

    aget-object v4, v1, v3

    .line 272
    invoke-virtual {v4}, Ljava/lang/reflect/Method;->getName()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_29

    invoke-virtual {v4}, Ljava/lang/reflect/Method;->getParameterTypes()[Ljava/lang/Class;

    move-result-object v5

    array-length v5, v5

    array-length v6, p2

    if-ne v5, v6, :cond_29

    invoke-virtual {v4, p0, p2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0
    :try_end_28
    .catchall {:try_start_4 .. :try_end_28} :catchall_2d

    return-object p0

    .line 271
    :cond_29
    add-int/lit8 v3, v3, 0x1

    goto :goto_e

    .line 276
    :cond_2c
    goto :goto_33

    .line 274
    :catchall_2d
    move-exception p0

    .line 275
    const-string p2, "K4RestrictList"

    invoke-static {p2, p1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 277
    :goto_33
    return-object v0
.end method

.method public static canList(Lcom/samsung/android/sdhms/SemAppRestrictionManager;ILjava/lang/String;I)Z
    .registers 7

    .line 48
    const/4 v0, 0x0

    if-nez p2, :cond_4

    return v0

    .line 49
    :cond_4
    invoke-static {p0, p2, p3}, Lcom/k4/devicecare/K4RestrictList;->isTracked(Lcom/samsung/android/sdhms/SemAppRestrictionManager;Ljava/lang/String;I)Z

    move-result v1

    const/4 v2, 0x1

    if-eqz v1, :cond_1b

    invoke-virtual {p0, p1, p2, p3}, Lcom/samsung/android/sdhms/SemAppRestrictionManager;->canRestrictWithReason(ILjava/lang/String;I)J

    move-result-wide p0

    const-wide/32 p2, -0x100009

    and-long/2addr p0, p2

    const-wide/16 p2, 0x0

    cmp-long p0, p0, p2

    if-nez p0, :cond_1a

    move v0, v2

    :cond_1a
    return v0

    .line 51
    :cond_1b
    if-eqz p1, :cond_20

    if-eq p1, v2, :cond_20

    return v0

    .line 53
    :cond_20
    :try_start_20
    invoke-static {p0}, Lcom/k4/devicecare/K4RestrictList;->context(Lcom/samsung/android/sdhms/SemAppRestrictionManager;)Landroid/content/Context;

    move-result-object p0

    .line 54
    if-eqz p0, :cond_37

    invoke-static {p0, p2, p3}, Lcom/k4/devicecare/K4RestrictList;->isCandidate(Landroid/content/Context;Ljava/lang/String;I)Z

    move-result v1

    if-nez v1, :cond_2d

    goto :goto_37

    .line 55
    :cond_2d
    if-eq p1, v2, :cond_35

    invoke-static {p0, p2, p3}, Lcom/k4/devicecare/K4RestrictList;->protection(Landroid/content/Context;Ljava/lang/String;I)Ljava/lang/String;

    move-result-object p0
    :try_end_33
    .catchall {:try_start_20 .. :try_end_33} :catchall_38

    if-nez p0, :cond_36

    :cond_35
    move v0, v2

    :cond_36
    return v0

    .line 54
    :cond_37
    :goto_37
    return v0

    .line 56
    :catchall_38
    move-exception p0

    .line 57
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string p3, "canList "

    invoke-virtual {p1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string p2, "K4RestrictList"

    invoke-static {p2, p1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 58
    return v0
.end method

.method public static candidates(Landroid/content/Context;)Ljava/util/List;
    .registers 16
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/Context;",
            ")",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 170
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 171
    invoke-static {}, Lcom/k4/devicecare/K4RestrictList;->deviceIdle()Ljava/lang/Object;

    move-result-object v1

    .line 172
    const/4 v2, 0x0

    new-array v3, v2, [Ljava/lang/Object;

    const-string v4, "getUserPowerWhitelist"

    invoke-static {v1, v4, v3}, Lcom/k4/devicecare/K4RestrictList;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, [Ljava/lang/String;

    .line 173
    if-eqz v3, :cond_b3

    array-length v4, v3

    if-nez v4, :cond_1b

    goto/16 :goto_b3

    .line 174
    :cond_1b
    const-string v4, "getSystemPowerWhitelist"

    new-array v5, v2, [Ljava/lang/Object;

    invoke-static {v1, v4, v5}, Lcom/k4/devicecare/K4RestrictList;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, [Ljava/lang/String;

    .line 175
    new-instance v4, Ljava/util/HashSet;

    if-nez v1, :cond_2f

    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    goto :goto_33

    :cond_2f
    invoke-static {v1}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v1

    :goto_33
    invoke-direct {v4, v1}, Ljava/util/HashSet;-><init>(Ljava/util/Collection;)V

    .line 176
    new-instance v1, Ljava/util/HashSet;

    invoke-static {v3}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v5

    invoke-direct {v1, v5}, Ljava/util/HashSet;-><init>(Ljava/util/Collection;)V

    .line 177
    const-string v5, "android.app.role.SMS"

    invoke-static {p0, v5}, Lcom/k4/devicecare/K4RestrictList;->roleHolders(Landroid/content/Context;Ljava/lang/String;)Ljava/util/List;

    move-result-object v5

    .line 178
    const-string v6, "android.app.role.DIALER"

    invoke-static {p0, v6}, Lcom/k4/devicecare/K4RestrictList;->roleHolders(Landroid/content/Context;Ljava/lang/String;)Ljava/util/List;

    move-result-object v6

    invoke-interface {v5, v6}, Ljava/util/List;->addAll(Ljava/util/Collection;)Z

    .line 179
    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object p0

    .line 180
    array-length v6, v3

    move v7, v2

    :goto_54
    if-ge v7, v6, :cond_b2

    aget-object v8, v3, v7

    .line 181
    invoke-virtual {v4, v8}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z

    move-result v9

    if-nez v9, :cond_af

    invoke-interface {v5, v8}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_65

    goto :goto_af

    .line 184
    :cond_65
    :try_start_65
    invoke-virtual {p0, v8, v2}, Landroid/content/pm/PackageManager;->getApplicationInfo(Ljava/lang/String;I)Landroid/content/pm/ApplicationInfo;

    move-result-object v9
    :try_end_69
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_65 .. :try_end_69} :catch_ad

    .line 187
    nop

    .line 188
    iget v10, v9, Landroid/content/pm/ApplicationInfo;->flags:I

    and-int/lit16 v10, v10, 0x81

    if-eqz v10, :cond_71

    goto :goto_af

    .line 189
    :cond_71
    iget-boolean v10, v9, Landroid/content/pm/ApplicationInfo;->enabled:Z

    if-eqz v10, :cond_af

    iget v10, v9, Landroid/content/pm/ApplicationInfo;->uid:I

    const v11, 0x186a0

    rem-int/2addr v10, v11

    const/16 v11, 0x2710

    if-ge v10, v11, :cond_80

    goto :goto_af

    .line 190
    :cond_80
    nop

    .line 191
    iget v9, v9, Landroid/content/pm/ApplicationInfo;->uid:I

    invoke-virtual {p0, v9}, Landroid/content/pm/PackageManager;->getPackagesForUid(I)[Ljava/lang/String;

    move-result-object v9

    .line 192
    if-eqz v9, :cond_a6

    array-length v10, v9

    move v11, v2

    move v12, v11

    :goto_8c
    if-ge v11, v10, :cond_a7

    aget-object v13, v9, v11

    invoke-virtual {v13, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-nez v14, :cond_a3

    invoke-virtual {v1, v13}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z

    move-result v14

    if-nez v14, :cond_a2

    invoke-virtual {v4, v13}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z

    move-result v13

    if-eqz v13, :cond_a3

    :cond_a2
    const/4 v12, 0x1

    :cond_a3
    add-int/lit8 v11, v11, 0x1

    goto :goto_8c

    :cond_a6
    move v12, v2

    .line 193
    :cond_a7
    if-nez v12, :cond_af

    invoke-virtual {v0, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_af

    .line 185
    :catch_ad
    move-exception v8

    .line 186
    nop

    .line 180
    :cond_af
    :goto_af
    add-int/lit8 v7, v7, 0x1

    goto :goto_54

    .line 195
    :cond_b2
    return-object v0

    .line 173
    :cond_b3
    :goto_b3
    return-object v0
.end method

.method private static context(Lcom/samsung/android/sdhms/SemAppRestrictionManager;)Landroid/content/Context;
    .registers 5

    .line 245
    :try_start_0
    const-class v0, Lcom/samsung/android/sdhms/SemAppRestrictionManager;

    const-string v1, "mContext"

    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v0

    .line 246
    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    .line 247
    invoke-virtual {v0, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    .line 248
    instance-of v0, p0, Landroid/content/Context;

    if-eqz v0, :cond_17

    check-cast p0, Landroid/content/Context;
    :try_end_16
    .catchall {:try_start_0 .. :try_end_16} :catchall_18

    return-object p0

    .line 250
    :cond_17
    goto :goto_19

    .line 249
    :catchall_18
    move-exception p0

    .line 252
    :goto_19
    const/4 p0, 0x0

    :try_start_1a
    const-string v0, "android.app.ActivityThread"

    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    const-string v1, "currentApplication"

    const/4 v2, 0x0

    new-array v3, v2, [Ljava/lang/Class;

    invoke-virtual {v0, v1, v3}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    new-array v1, v2, [Ljava/lang/Object;

    invoke-virtual {v0, p0, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/Context;
    :try_end_31
    .catchall {:try_start_1a .. :try_end_31} :catchall_32

    return-object v0

    .line 253
    :catchall_32
    move-exception v0

    .line 254
    return-object p0
.end method

.method private static deviceIdle()Ljava/lang/Object;
    .registers 6

    .line 260
    const-string v0, "deviceidle"

    const/4 v1, 0x0

    :try_start_3
    const-string v2, "android.os.ServiceManager"

    invoke-static {v2}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v2

    const-string v3, "getService"

    const-class v4, Ljava/lang/String;

    filled-new-array {v4}, [Ljava/lang/Class;

    move-result-object v4

    invoke-virtual {v2, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    filled-new-array {v0}, [Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v2, v1, v3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/os/IBinder;

    .line 261
    const-string v3, "android.os.IDeviceIdleController$Stub"

    invoke-static {v3}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v3

    const-string v4, "asInterface"

    const-class v5, Landroid/os/IBinder;

    filled-new-array {v5}, [Ljava/lang/Class;

    move-result-object v5

    invoke-virtual {v3, v4, v5}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v3

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {v3, v1, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0
    :try_end_39
    .catchall {:try_start_3 .. :try_end_39} :catchall_3a

    return-object v0

    .line 262
    :catchall_3a
    move-exception v2

    .line 263
    const-string v3, "K4RestrictList"

    invoke-static {v3, v0, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 264
    return-object v1
.end method

.method public static getAllList(Lcom/samsung/android/sdhms/SemAppRestrictionManager;)Ljava/util/List;
    .registers 10

    .line 64
    const-string v0, "K4RestrictList"

    invoke-virtual {p0}, Lcom/samsung/android/sdhms/SemAppRestrictionManager;->getAllList()Ljava/util/List;

    move-result-object v1

    .line 65
    const/4 v2, 0x0

    if-nez v1, :cond_a

    return-object v2

    .line 67
    :cond_a
    :try_start_a
    invoke-static {p0}, Lcom/k4/devicecare/K4RestrictList;->context(Lcom/samsung/android/sdhms/SemAppRestrictionManager;)Landroid/content/Context;

    move-result-object p0

    .line 68
    if-nez p0, :cond_11

    return-object v1

    .line 69
    :cond_11
    new-instance v3, Ljava/util/HashSet;

    invoke-direct {v3}, Ljava/util/HashSet;-><init>()V

    .line 70
    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v4

    :goto_1a
    invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_2e

    invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lcom/samsung/android/sdhms/SemAppRestrictionManager$AppRestrictionInfo;

    invoke-virtual {v5}, Lcom/samsung/android/sdhms/SemAppRestrictionManager$AppRestrictionInfo;->getPackageName()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    goto :goto_1a

    .line 71
    :cond_2e
    nop

    .line 72
    invoke-static {p0}, Lcom/k4/devicecare/K4RestrictList;->candidates(Landroid/content/Context;)Ljava/util/List;

    move-result-object v4

    invoke-interface {v4}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v4

    :goto_37
    invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_85

    invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/String;

    .line 73
    invoke-virtual {v3, v5}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_4a

    goto :goto_37

    .line 74
    :cond_4a
    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v6

    const/4 v7, 0x0

    invoke-virtual {v6, v5, v7}, Landroid/content/pm/PackageManager;->getApplicationInfo(Ljava/lang/String;I)Landroid/content/pm/ApplicationInfo;

    move-result-object v6

    iget v6, v6, Landroid/content/pm/ApplicationInfo;->uid:I

    .line 75
    if-nez v2, :cond_5c

    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2, v1}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    .line 76
    :cond_5c
    new-instance v7, Lcom/samsung/android/sdhms/SemAppRestrictionManager$AppRestrictionInfo;

    invoke-direct {v7, v5, v6}, Lcom/samsung/android/sdhms/SemAppRestrictionManager$AppRestrictionInfo;-><init>(Ljava/lang/String;I)V

    invoke-virtual {v2, v7}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 77
    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "offering allowlisted app "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v7, "/"

    invoke-virtual {v5, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v0, v5}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_84
    .catchall {:try_start_a .. :try_end_84} :catchall_8a

    .line 78
    goto :goto_37

    .line 79
    :cond_85
    if-nez v2, :cond_88

    goto :goto_89

    :cond_88
    move-object v1, v2

    :goto_89
    return-object v1

    .line 80
    :catchall_8a
    move-exception p0

    .line 81
    const-string v2, "getAllList"

    invoke-static {v0, v2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 82
    return-object v1
.end method

.method public static isCandidate(Landroid/content/Context;Ljava/lang/String;I)Z
    .registers 7

    .line 164
    const v0, 0x186a0

    div-int v1, p2, v0

    invoke-static {}, Landroid/os/Process;->myUid()I

    move-result v2

    div-int/2addr v2, v0

    const/4 v3, 0x0

    if-ne v1, v2, :cond_3e

    rem-int v0, p2, v0

    const/16 v1, 0x2710

    if-ge v0, v1, :cond_14

    goto :goto_3e

    .line 165
    :cond_14
    invoke-static {p0}, Lcom/k4/devicecare/K4RestrictList;->candidates(Landroid/content/Context;)Ljava/util/List;

    move-result-object v0

    invoke-interface {v0, p1}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_3c

    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    invoke-virtual {v0, p2}, Landroid/content/pm/PackageManager;->getPackagesForUid(I)[Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_3c

    .line 166
    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object p0

    invoke-virtual {p0, p2}, Landroid/content/pm/PackageManager;->getPackagesForUid(I)[Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;

    move-result-object p0

    invoke-interface {p0, p1}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_3c

    const/4 v3, 0x1

    goto :goto_3d

    :cond_3c
    nop

    .line 165
    :goto_3d
    return v3

    .line 164
    :cond_3e
    :goto_3e
    return v3
.end method

.method public static isTracked(Lcom/samsung/android/sdhms/SemAppRestrictionManager;Ljava/lang/String;I)Z
    .registers 4

    .line 156
    const/4 v0, 0x1

    :try_start_1
    invoke-virtual {p0, v0, p1, p2}, Lcom/samsung/android/sdhms/SemAppRestrictionManager;->canRestrict(ILjava/lang/String;I)Z

    move-result p0
    :try_end_5
    .catchall {:try_start_1 .. :try_end_5} :catchall_6

    return p0

    .line 157
    :catchall_6
    move-exception p0

    .line 158
    const/4 p0, 0x0

    return p0
.end method

.method public static prepare(Landroid/content/Context;Ljava/util/List;IZ)Ljava/util/List;
    .registers 15

    .line 91
    const-string v0, "K4RestrictList"

    if-eqz p3, :cond_209

    if-eqz p2, :cond_9

    const/4 p3, 0x1

    if-ne p2, p3, :cond_209

    :cond_9
    if-eqz p0, :cond_209

    if-eqz p1, :cond_209

    invoke-interface {p1}, Ljava/util/List;->isEmpty()Z

    move-result p3

    if-eqz p3, :cond_15

    goto/16 :goto_209

    .line 93
    :cond_15
    :try_start_15
    new-instance p3, Lcom/samsung/android/sdhms/SemAppRestrictionManager;

    invoke-direct {p3, p0}, Lcom/samsung/android/sdhms/SemAppRestrictionManager;-><init>(Landroid/content/Context;)V

    .line 94
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 95
    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    .line 96
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :cond_28
    :goto_28
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_128

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    .line 97
    instance-of v5, v4, Lkc/d;

    if-nez v5, :cond_37

    goto :goto_28

    .line 98
    :cond_37
    move-object v5, v4

    check-cast v5, Lkc/d;

    .line 99
    iget-object v6, v5, Lkc/d;->a:Ljava/lang/String;

    if-eqz v6, :cond_28

    iget-object v6, v5, Lkc/d;->a:Ljava/lang/String;

    iget v7, v5, Lkc/d;->c:I

    invoke-static {p3, v6, v7}, Lcom/k4/devicecare/K4RestrictList;->isTracked(Lcom/samsung/android/sdhms/SemAppRestrictionManager;Ljava/lang/String;I)Z

    move-result v6

    if-nez v6, :cond_28

    iget-object v6, v5, Lkc/d;->a:Ljava/lang/String;

    iget v7, v5, Lkc/d;->c:I

    invoke-static {p0, v6, v7}, Lcom/k4/devicecare/K4RestrictList;->isCandidate(Landroid/content/Context;Ljava/lang/String;I)Z

    move-result v6

    if-nez v6, :cond_53

    goto :goto_28

    .line 100
    :cond_53
    if-nez p2, :cond_5e

    iget-object v6, v5, Lkc/d;->a:Ljava/lang/String;

    iget v7, v5, Lkc/d;->c:I

    invoke-static {p0, v6, v7}, Lcom/k4/devicecare/K4RestrictList;->protection(Landroid/content/Context;Ljava/lang/String;I)Ljava/lang/String;

    move-result-object v6

    goto :goto_5f

    :cond_5e
    const/4 v6, 0x0

    .line 101
    :goto_5f
    if-eqz v6, :cond_87

    .line 102
    iget-object v5, v5, Lkc/d;->a:Ljava/lang/String;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "not deep sleeping "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v7, ": "

    invoke-virtual {v5, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v0, v5}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 103
    invoke-virtual {v2, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 104
    goto :goto_28

    .line 106
    :cond_87
    invoke-static {}, Lcom/k4/devicecare/K4RestrictList;->deviceIdle()Ljava/lang/Object;

    move-result-object v6

    .line 107
    const-string v7, "removePowerSaveWhitelistApp"

    iget-object v8, v5, Lkc/d;->a:Ljava/lang/String;

    filled-new-array {v8}, [Ljava/lang/Object;

    move-result-object v8

    invoke-static {v6, v7, v8}, Lcom/k4/devicecare/K4RestrictList;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 108
    sget-object v7, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v8, "isPowerSaveWhitelistApp"

    iget-object v9, v5, Lkc/d;->a:Ljava/lang/String;

    filled-new-array {v9}, [Ljava/lang/Object;

    move-result-object v9

    invoke-static {v6, v8, v9}, Lcom/k4/devicecare/K4RestrictList;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v6

    invoke-virtual {v7, v6}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_cd

    .line 109
    iget-object v5, v5, Lkc/d;->a:Ljava/lang/String;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "could not take "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, " off the doze allowlist"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v0, v5}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 110
    invoke-virtual {v2, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 111
    goto/16 :goto_28

    .line 113
    :cond_cd
    iget-object v4, v5, Lkc/d;->a:Ljava/lang/String;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v6, " taken off the doze allowlist for type "

    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v0, v4}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_e9
    .catchall {:try_start_15 .. :try_end_e9} :catchall_202

    .line 115
    :try_start_e9
    new-instance v4, Landroid/content/ContentValues;

    invoke-direct {v4}, Landroid/content/ContentValues;-><init>()V

    .line 116
    const-string v6, "package_name"

    iget-object v7, v5, Lkc/d;->a:Ljava/lang/String;

    invoke-virtual {v4, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 117
    const-string v6, "uid"

    iget v7, v5, Lkc/d;->c:I

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    invoke-virtual {v4, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 118
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v6

    sget-object v7, Lcom/k4/devicecare/K4RestrictList;->FAS:Landroid/net/Uri;

    invoke-virtual {v6, v7, v4}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;
    :try_end_109
    .catchall {:try_start_e9 .. :try_end_109} :catchall_10a

    .line 121
    goto :goto_123

    .line 119
    :catchall_10a
    move-exception v4

    .line 120
    :try_start_10b
    iget-object v6, v5, Lkc/d;->a:Ljava/lang/String;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "FAS insert "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v0, v6, v4}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 122
    :goto_123
    invoke-virtual {v1, v5}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 123
    goto/16 :goto_28

    .line 124
    :cond_128
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v3

    const-wide/16 v5, 0xfa0

    add-long/2addr v3, v5

    .line 125
    invoke-virtual {v1}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :goto_133
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1f2

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lkc/d;

    .line 126
    :goto_13f
    iget-object v5, v1, Lkc/d;->a:Ljava/lang/String;

    iget v6, v1, Lkc/d;->c:I

    invoke-static {p3, v5, v6}, Lcom/k4/devicecare/K4RestrictList;->isTracked(Lcom/samsung/android/sdhms/SemAppRestrictionManager;Ljava/lang/String;I)Z

    move-result v5

    if-nez v5, :cond_157

    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v5

    cmp-long v5, v5, v3

    if-gez v5, :cond_157

    const-wide/16 v5, 0x64

    invoke-static {v5, v6}, Landroid/os/SystemClock;->sleep(J)V

    goto :goto_13f

    .line 127
    :cond_157
    iget-object v5, v1, Lkc/d;->a:Ljava/lang/String;

    iget v6, v1, Lkc/d;->c:I

    invoke-static {p3, v5, v6}, Lcom/k4/devicecare/K4RestrictList;->isTracked(Lcom/samsung/android/sdhms/SemAppRestrictionManager;Ljava/lang/String;I)Z

    move-result v5

    if-nez v5, :cond_17d

    .line 128
    iget-object v5, v1, Lkc/d;->a:Ljava/lang/String;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, " not managed by MARs after 4000 ms, left battery-optimized"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v0, v5}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 129
    invoke-virtual {v2, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 130
    goto :goto_133

    .line 132
    :cond_17d
    const-wide/16 v5, 0x0

    if-nez p2, :cond_18f

    iget-object v7, v1, Lkc/d;->a:Ljava/lang/String;

    iget v8, v1, Lkc/d;->c:I

    const/4 v9, 0x0

    invoke-virtual {p3, v9, v7, v8}, Lcom/samsung/android/sdhms/SemAppRestrictionManager;->canRestrictWithReason(ILjava/lang/String;I)J

    move-result-wide v7

    const-wide/32 v9, -0x100009

    and-long/2addr v7, v9

    goto :goto_190

    :cond_18f
    move-wide v7, v5

    .line 133
    :goto_190
    cmp-long v5, v7, v5

    if-eqz v5, :cond_1d4

    .line 134
    iget-object v5, v1, Lkc/d;->a:Ljava/lang/String;

    invoke-static {v7, v8}, Ljava/lang/Long;->toHexString(J)Ljava/lang/String;

    move-result-object v6

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "MARs protects "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v7, " (0x"

    invoke-virtual {v5, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, "), restoring allowlist"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v0, v5}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 135
    invoke-static {}, Lcom/k4/devicecare/K4RestrictList;->deviceIdle()Ljava/lang/Object;

    move-result-object v5

    const-string v6, "addPowerSaveWhitelistApp"

    iget-object v7, v1, Lkc/d;->a:Ljava/lang/String;

    filled-new-array {v7}, [Ljava/lang/Object;

    move-result-object v7

    invoke-static {v5, v6, v7}, Lcom/k4/devicecare/K4RestrictList;->call(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 136
    invoke-virtual {v2, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 137
    goto/16 :goto_133

    .line 139
    :cond_1d4
    iget-object v1, v1, Lkc/d;->a:Ljava/lang/String;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v5, " is managed by MARs now, restricting type "

    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 140
    goto/16 :goto_133

    .line 141
    :cond_1f2
    invoke-virtual {v2}, Ljava/util/ArrayList;->isEmpty()Z

    move-result p0

    if-eqz p0, :cond_1f9

    return-object p1

    .line 142
    :cond_1f9
    new-instance p0, Ljava/util/ArrayList;

    invoke-direct {p0, p1}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    .line 143
    invoke-virtual {p0, v2}, Ljava/util/ArrayList;->removeAll(Ljava/util/Collection;)Z
    :try_end_201
    .catchall {:try_start_10b .. :try_end_201} :catchall_202

    .line 144
    return-object p0

    .line 145
    :catchall_202
    move-exception p0

    .line 146
    const-string p2, "prepare"

    invoke-static {v0, p2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 147
    return-object p1

    .line 91
    :cond_209
    :goto_209
    return-object p1
.end method

.method public static protection(Landroid/content/Context;Ljava/lang/String;I)Ljava/lang/String;
    .registers 11

    .line 200
    const v0, 0x186a0

    rem-int v1, p2, v0

    const/16 v2, 0x3e8

    if-ne v1, v2, :cond_c

    const-string p0, "system uid"

    return-object p0

    .line 202
    :cond_c
    const/4 v1, 0x0

    :try_start_d
    const-class v2, Landroid/app/admin/DevicePolicyManager;

    invoke-virtual {p0, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/app/admin/DevicePolicyManager;

    .line 203
    if-nez v2, :cond_19

    move-object v2, v1

    goto :goto_1d

    :cond_19
    invoke-virtual {v2}, Landroid/app/admin/DevicePolicyManager;->getActiveAdmins()Ljava/util/List;

    move-result-object v2

    .line 204
    :goto_1d
    if-eqz v2, :cond_3c

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :cond_23
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_3c

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Landroid/content/ComponentName;

    invoke-virtual {v3}, Landroid/content/ComponentName;->getPackageName()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p1, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_23

    const-string p0, "device admin"
    :try_end_3b
    .catchall {:try_start_d .. :try_end_3b} :catchall_3d

    return-object p0

    .line 206
    :cond_3c
    goto :goto_3e

    .line 205
    :catchall_3d
    move-exception v2

    .line 207
    :goto_3e
    sget-object v2, Lcom/k4/devicecare/K4RestrictList;->ROLES:[Ljava/lang/String;

    array-length v3, v2

    const/4 v4, 0x0

    move v5, v4

    :goto_43
    if-ge v5, v3, :cond_55

    aget-object v6, v2, v5

    invoke-static {p0, v6}, Lcom/k4/devicecare/K4RestrictList;->roleHolders(Landroid/content/Context;Ljava/lang/String;)Ljava/util/List;

    move-result-object v7

    invoke-interface {v7, p1}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_52

    return-object v6

    :cond_52
    add-int/lit8 v5, v5, 0x1

    goto :goto_43

    .line 209
    :cond_55
    :try_start_55
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    const-string v3, "default_input_method"

    invoke-static {v2, v3}, Landroid/provider/Settings$Secure;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 210
    if-nez v2, :cond_63

    move-object v2, v1

    goto :goto_67

    :cond_63
    invoke-static {v2}, Landroid/content/ComponentName;->unflattenFromString(Ljava/lang/String;)Landroid/content/ComponentName;

    move-result-object v2

    .line 211
    :goto_67
    if-eqz v2, :cond_76

    invoke-virtual {v2}, Landroid/content/ComponentName;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_76

    const-string p0, "keyboard"
    :try_end_75
    .catchall {:try_start_55 .. :try_end_75} :catchall_77

    return-object p0

    .line 213
    :cond_76
    goto :goto_78

    .line 212
    :catchall_77
    move-exception v2

    .line 215
    :goto_78
    :try_start_78
    invoke-static {p0}, Landroid/app/WallpaperManager;->getInstance(Landroid/content/Context;)Landroid/app/WallpaperManager;

    move-result-object v2

    .line 216
    const/4 v3, 0x2

    const/4 v5, 0x1

    filled-new-array {v5, v3}, [I

    move-result-object v5

    :goto_82
    if-ge v4, v3, :cond_9c

    aget v6, v5, v4

    .line 217
    invoke-virtual {v2, v6}, Landroid/app/WallpaperManager;->getWallpaperInfo(I)Landroid/app/WallpaperInfo;

    move-result-object v6

    .line 218
    if-eqz v6, :cond_99

    invoke-virtual {v6}, Landroid/app/WallpaperInfo;->getPackageName()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {p1, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_99

    const-string p0, "wallpaper"
    :try_end_98
    .catchall {:try_start_78 .. :try_end_98} :catchall_9d

    return-object p0

    .line 216
    :cond_99
    add-int/lit8 v4, v4, 0x1

    goto :goto_82

    .line 221
    :cond_9c
    goto :goto_9e

    .line 220
    :catchall_9d
    move-exception v2

    .line 223
    :goto_9e
    :try_start_9e
    const-class v2, Landroid/content/pm/PackageManager;

    const-string v3, "isPackageStateProtected"

    const-class v4, Ljava/lang/String;

    sget-object v5, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v4, v5}, [Ljava/lang/Class;

    move-result-object v4

    invoke-virtual {v2, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    .line 224
    sget-object v3, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object p0

    div-int/2addr p2, v0

    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p2

    filled-new-array {p1, p2}, [Ljava/lang/Object;

    move-result-object p1

    invoke-virtual {v2, p0, p1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    invoke-virtual {v3, p0}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_ca

    const-string p0, "protected package"
    :try_end_c9
    .catchall {:try_start_9e .. :try_end_c9} :catchall_cb

    return-object p0

    .line 226
    :cond_ca
    goto :goto_cc

    .line 225
    :catchall_cb
    move-exception p0

    .line 229
    :goto_cc
    return-object v1
.end method

.method private static roleHolders(Landroid/content/Context;Ljava/lang/String;)Ljava/util/List;
    .registers 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/Context;",
            "Ljava/lang/String;",
            ")",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 235
    :try_start_0
    const-string v0, "role"

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    .line 236
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    const-string v1, "getRoleHolders"

    const-class v2, Ljava/lang/String;

    filled-new-array {v2}, [Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    .line 237
    new-instance v1, Ljava/util/ArrayList;

    filled-new-array {p1}, [Ljava/lang/Object;

    move-result-object p1

    invoke-virtual {v0, p0, p1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/util/List;

    invoke-direct {v1, p0}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V
    :try_end_25
    .catchall {:try_start_0 .. :try_end_25} :catchall_26

    return-object v1

    .line 238
    :catchall_26
    move-exception p0

    .line 239
    new-instance p0, Ljava/util/ArrayList;

    invoke-direct {p0}, Ljava/util/ArrayList;-><init>()V

    return-object p0
.end method
