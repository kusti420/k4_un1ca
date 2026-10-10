.class final Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$DialogListener;
.super Ljava/lang/Object;
.source "ScreenResolutionPreferenceController.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "DialogListener"
.end annotation


# Type 0: resolution chooser item, 1: "Keep", 2: "Revert"


# instance fields
.field public final f$0:Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;

.field public final mType:I


# direct methods
.method constructor <init>(Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;I)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$DialogListener;->f$0:Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;

    iput p2, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$DialogListener;->mType:I

    return-void
.end method


# virtual methods
.method public final onClick(Landroid/content/DialogInterface;I)V
    .locals 2

    iget-object v0, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$DialogListener;->f$0:Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;

    iget v1, p0, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController$DialogListener;->mType:I

    if-nez v1, :cond_0

    invoke-interface {p1}, Landroid/content/DialogInterface;->dismiss()V

    invoke-virtual {v0, p2}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->onModeSelected(I)V

    return-void

    :cond_0
    const/4 p0, 0x1

    if-ne v1, p0, :cond_1

    invoke-virtual {v0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->onKeep()V

    return-void

    :cond_1
    invoke-virtual {v0}, Lio/mesalabs/unica/settings/display/ScreenResolutionPreferenceController;->onRevert()V

    return-void
.end method
