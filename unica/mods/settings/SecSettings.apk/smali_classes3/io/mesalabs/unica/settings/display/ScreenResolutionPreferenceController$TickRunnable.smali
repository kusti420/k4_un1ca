.class final Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$TickRunnable;
.super Ljava/lang/Object;
.source "ScreenResolutionPreferenceController.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "TickRunnable"
.end annotation


# instance fields
.field public final f$0:Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;


# direct methods
.method constructor <init>(Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$TickRunnable;->f$0:Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 0

    iget-object p0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$TickRunnable;->f$0:Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->tick()V

    return-void
.end method
