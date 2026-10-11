.class public final Lcom/k4/devicecare/K4RestrictList;
.super Ljava/lang/Object;
.source "K4RestrictList.java"


# direct methods
.method public static canList(Lcom/samsung/android/sdhms/SemAppRestrictionManager;ILjava/lang/String;I)Z
    .locals 4

    # Offer the app in a sleeping-app Add list unless the framework's hard protections veto it.
    # canRestrictWithReason() returns 0 when nothing objects; widget (0x8) and quick panel tile (0x100000) are soft.
    invoke-virtual {p0, p1, p2, p3}, Lcom/samsung/android/sdhms/SemAppRestrictionManager;->canRestrictWithReason(ILjava/lang/String;I)J

    move-result-wide v0

    const-wide/32 v2, -0x100009

    and-long/2addr v0, v2

    const-wide/16 v2, 0x0

    cmp-long v0, v0, v2

    if-nez v0, :cond_vetoed

    const/4 v0, 0x1

    return v0

    :cond_vetoed
    const/4 v0, 0x0

    return v0
.end method
