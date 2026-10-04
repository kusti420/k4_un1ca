# The source (Fold8) services.jar hardcodes Samsung's foldable device-state machine: the DeviceStateManagerService
# constructor always builds FlexibleDeviceStatePolicy/FlexibleDeviceStateProvider with the six fold states
# (CLOSED/TENT/HALF_OPENED/OPENED/CONCURRENT_INNER/OUTER_DEFAULT), and the AOSP DeviceStateProviderImpl/
# DeviceStatePolicyImpl fallback was stripped by R8. Without the folding sensor (type 65695) the provider settles
# on CLOSED, whose properties (FEATURE_REAR_DISPLAY, FOLD_IN_CLOSED, OUTER_PRIMARY, ...) make WindowManager
# (FoldController mDeviceState=REAR), CameraServiceProxy (FRONT_FOLDED), AOD and every DeviceStateManager client
# treat the phone as a folded foldable. The framework-res overlay (config_*DeviceStates) is ignored by this
# property-based code. Hand the provider a single property-less DEFAULT state (identifier 0, exactly what AOSP's
# default provider creates on non-foldables) through a small helper class, right before the provider is built.
SVC="system/framework/services.jar"
DECODE_APK "system" "$SVC" || ABORT "Failed to decode $SVC"
DIR="$APKTOOL_DIR/system/${SVC//system\//}"
DSMS="$DIR/smali/com/android/server/devicestate/DeviceStateManagerService.smali"
[ -f "$DSMS" ] || ABORT "DeviceStateManagerService.smali not found in $SVC"

if grep -q "Lcom/android/server/policy/FlexibleDeviceStateProvider;-><init>(Landroid/content/Context;Lcom/android/server/policy/FlexibleDeviceStatePolicy;Ljava/util/List;)V" "$DSMS"; then
    LOG "- Replacing the foldable device states with a single DEFAULT state"
    mkdir -p "$DIR/smali_classes2/com/android/server/devicestate"
    cat > "$DIR/smali_classes2/com/android/server/devicestate/K4DeviceStates.smali" << 'EOF'
.class public final Lcom/android/server/devicestate/K4DeviceStates;
.super Ljava/lang/Object;
.source "K4DeviceStates.java"


# direct methods
.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

# Returns a list holding one DeviceStatePredicateWrapper: DeviceState(3, "DEFAULT") with no system/physical
# properties and always-true condition/availability predicates. The incoming foldable list is discarded.
# Identifier 3, not AOSP's 0: Samsung's fold code compares raw identifiers (FoldDisplayController treats
# 0/1/5 as folded, CameraServiceWorker 0/1 as folded and 2/3/6 as open), so 0 ("CLOSED" on the Fold) would keep
# WindowManager.isFolded(), TspStateManager, mDNIe, NotificationService and the camera in the folded state.
.method public static single(Ljava/util/List;)Ljava/util/List;
    .locals 4

    const-string v0, "K4DeviceStates"

    const-string v1, "Replacing the foldable device states with a single DEFAULT state (identifier 3)"

    invoke-static {v0, v1}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    new-instance v1, Landroid/hardware/devicestate/DeviceState$Configuration$Builder;

    const/4 v2, 0x3

    const-string v3, "DEFAULT"

    invoke-direct {v1, v2, v3}, Landroid/hardware/devicestate/DeviceState$Configuration$Builder;-><init>(ILjava/lang/String;)V

    invoke-virtual {v1}, Landroid/hardware/devicestate/DeviceState$Configuration$Builder;->build()Landroid/hardware/devicestate/DeviceState$Configuration;

    move-result-object v1

    new-instance v2, Landroid/hardware/devicestate/DeviceState;

    invoke-direct {v2, v1}, Landroid/hardware/devicestate/DeviceState;-><init>(Landroid/hardware/devicestate/DeviceState$Configuration;)V

    sget-object v3, Lcom/android/server/policy/FlexibleDeviceStateProvider;->ALLOWED:Lcom/android/server/policy/FlexibleDeviceStateProvider$$ExternalSyntheticLambda2;

    new-instance v1, Lcom/android/server/policy/FlexibleDeviceStateProvider$DeviceStatePredicateWrapper;

    invoke-direct {v1, v2, v3, v3}, Lcom/android/server/policy/FlexibleDeviceStateProvider$DeviceStatePredicateWrapper;-><init>(Landroid/hardware/devicestate/DeviceState;Ljava/util/function/Predicate;Ljava/util/function/Predicate;)V

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-object v0
.end method
EOF

    python3 - "$DSMS" << 'PYEOF' || ABORT "Failed to patch DeviceStateManagerService"
import re, sys
path = sys.argv[1]
src = open(path).read()
hook = "Lcom/android/server/devicestate/K4DeviceStates;->single(Ljava/util/List;)Ljava/util/List;"
if hook in src:
    print("DeviceStateManagerService already patched")
    sys.exit(0)
pat = re.compile(r"^(\s*)invoke-direct \{(v\d+), (v\d+), (v\d+), (v\d+)\}, "
                 r"Lcom/android/server/policy/FlexibleDeviceStateProvider;-><init>"
                 r"\(Landroid/content/Context;Lcom/android/server/policy/FlexibleDeviceStatePolicy;Ljava/util/List;\)V\s*$",
                 re.M)
hits = list(pat.finditer(src))
if len(hits) != 1:
    sys.exit("expected exactly one FlexibleDeviceStateProvider constructor call, found %d" % len(hits))
m = hits[0]
indent, lst = m.group(1), m.group(5)
ins = ("%sinvoke-static {%s}, %s\n\n%smove-result-object %s\n\n" % (indent, lst, hook, indent, lst))
src = src[:m.start()] + ins + src[m.start():]
open(path, "w").write(src)
print("hooked K4DeviceStates.single before the provider constructor (list register %s)" % lst)
PYEOF
else
    LOG "- FlexibleDeviceStateProvider not found in $SVC, skipping"
fi
unset SVC DIR DSMS
