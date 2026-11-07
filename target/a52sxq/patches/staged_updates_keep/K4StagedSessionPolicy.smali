.class public final Lcom/android/server/pm/K4StagedSessionPolicy;
.super Ljava/lang/Object;
.source "K4StagedSessionPolicy.java"

# target/a52sxq/patches/staged_updates_keep (see module.prop)

.method public static failStagedOnUpgrade(Z)Z
    .locals 4

    const-string v0, "persist.sys.k4.base_fp"

    invoke-static {v0}, Landroid/os/SystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    sget-object v2, Landroid/os/Build;->FINGERPRINT:Ljava/lang/String;

    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_same

    # base unknown or changed: record it, keep the stock decision
    :try_start_0
    invoke-static {v0, v2}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    return p0

    :cond_same
    if-eqz p0, :cond_keep

    const-string v0, "PackageInstaller"

    const-string v1, "k4: only the ROM build changed (same ro.build.fingerprint), staged sessions are kept"

    invoke-static {v0, v1}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I

    :cond_keep
    const/4 v0, 0x0

    return v0
.end method
