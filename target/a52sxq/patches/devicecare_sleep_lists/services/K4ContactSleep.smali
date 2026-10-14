.class public final Lcom/k4/server/K4ContactSleep;
.super Ljava/lang/Object;
.source "K4ContactSleep.java"


# direct methods
.method private constructor <init>()V
    .registers 1

    .line 20
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static contactFilter(IILjava/lang/String;)I
    .registers 5

    .line 23
    const/4 v0, 0x7

    const/4 v1, 0x0

    if-ne p1, v0, :cond_5

    return v1

    .line 25
    :cond_5
    :try_start_5
    sget-object p1, Lcom/android/server/am/MARsPolicyManager;->MARsLock:Lcom/android/server/am/MARsPolicyManager$Lock;

    monitor-enter p1
    :try_end_8
    .catchall {:try_start_5 .. :try_end_8} :catchall_26

    .line 26
    :try_start_8
    sget-object v0, Lcom/android/server/am/MARsPolicyManager$MARsPolicyManagerHolder;->INSTANCE:Lcom/android/server/am/MARsPolicyManager;

    iget-object v0, v0, Lcom/android/server/am/MARsPolicyManager;->mMARsTargetPackages:Lcom/android/server/am/MARsPkgMap;

    invoke-static {v0, p2, p0}, Lcom/android/server/am/MARsPolicyManager;->getMARsPackageInfo(Lcom/android/server/am/MARsPkgMap;Ljava/lang/String;I)Lcom/android/server/am/MARsPackageInfo;

    move-result-object p0

    .line 28
    if-eqz p0, :cond_21

    iget p2, p0, Lcom/android/server/am/MARsPackageInfo;->maxLevel:I

    const/4 v0, 0x4

    if-ne p2, v0, :cond_21

    iget p0, p0, Lcom/android/server/am/MARsPackageInfo;->disableReason:I

    invoke-static {p0}, Lcom/android/server/am/MARsPolicyManager;->isDisabledByUser(I)Z

    move-result p0

    if-eqz p0, :cond_21

    monitor-exit p1

    return v1

    .line 29
    :cond_21
    monitor-exit p1

    .line 31
    goto :goto_27

    .line 29
    :catchall_23
    move-exception p0

    monitor-exit p1
    :try_end_25
    .catchall {:try_start_8 .. :try_end_25} :catchall_23

    :try_start_25
    throw p0
    :try_end_26
    .catchall {:try_start_25 .. :try_end_26} :catchall_26

    .line 30
    :catchall_26
    move-exception p0

    .line 32
    :goto_27
    const/16 p0, 0x16

    return p0
.end method
