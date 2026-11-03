# See module.prop. Runs after "tethering" (modules apply in C-locale name order), so a52_netd.o and the
# a52_netd.<versionCode>.o next to it are already in place (check_netd.py finds the versioned ones by itself).
TT_NETD="$WORK_DIR/system/system/etc/bpf/a52_netd.o"
if [ ! -f "$TT_NETD" ]; then
    LOGW "tethering_trains: no system/etc/bpf/a52_netd.o (tethering patch disabled?) - skipped"
else
    if ${TARGET_TETHERING_RESIGN_APEX:-false}; then
        # Re-signed Tethering APEX: Play can never update it, only the factory userspace ever runs.
        TT_KNOWN=("$MODPATH"/known/*_factory_netd.o)   # (+ its *_factory_<obj>.o, found by check_netd.py)
    else
        TT_KNOWN=("$MODPATH"/known/*_netd.o)
    fi
    [ -f "${TT_KNOWN[0]}" ] || ABORT "tethering_trains: no known netd.o in $MODPATH/known"
    # (apply_modules.sh runs with set -e: keep the failing check inside an if)
    if TT_OUT="$(python3 "$MODPATH/check_netd.py" "$TT_NETD" "${TT_KNOWN[@]}" 2>&1)"; then TT_RC=0; else TT_RC=$?; fi
    while IFS= read -r l; do [ "$l" ] && LOG "- $l"; done <<< "$TT_OUT"
    [ "$TT_RC" = 0 ] || ABORT "tethering_trains: the netd objects or the loader no longer cover a Tethering version phones may run (see above) - a52_netd*.o map/program lines: rerun tethering/regen.py --train-progs with every train in known/; \"(load fails)\" lines: that train cannot load on 5.4 with our loader (bpfloader reboot loop), fix the ROM side first; \"pin gap\" lines: review, then fix or add the printed line to known/tolerated.txt"
    python3 "$MODPATH/check_netd.py" --list "${TT_KNOWN[@]}" > "$WORK_DIR/system/system/etc/bpf/a52_netd.known" || \
        ABORT "tethering_trains: failed to write a52_netd.known"
    SET_METADATA "system" "system/etc/bpf/a52_netd.known" 0 0 644 "u:object_r:system_file:s0"
    unset TT_KNOWN TT_OUT TT_RC

    # Runtime half, for the train nobody has seen yet (k4-tethering-gate, k4_tethering_gate.rc, see module.prop): on an
    # update boot, before the loader runs, check the activated Tethering's versionCode against a52_netd.known and its
    # netd.o map pins against the object the loader picks, and on a miss take apexd's own revert path
    # (sys.init.updatable_crashing) instead of the bpfloader / netd crash loop. Runs in the k4apexdm domain of
    # apex_dm_relabel (applied earlier: a < t), reports through sys.k4.tethering_gap (own property type).
    TT_SYS="$WORK_DIR/system/system"
    TT_CIL="$TT_SYS/etc/selinux/plat_sepolicy.cil"
    TT_PC="$TT_SYS/etc/selinux/plat_property_contexts"
    [ -f "$TT_CIL" ] && [ -f "$TT_PC" ] || ABORT "tethering_trains: plat_sepolicy.cil or plat_property_contexts not found"
    grep -q -x -F "(type k4apexdm)" "$TT_CIL" || \
        ABORT "tethering_trains: domain k4apexdm is not in plat_sepolicy.cil (patch apex_dm_relabel must be enabled; it runs before this one)"
    EVAL "cp -f \"$MODPATH/k4-tethering-gate\" \"$TT_SYS/bin/k4-tethering-gate\"" || ABORT "tethering_trains: gate copy failed"
    SET_METADATA "system" "system/bin/k4-tethering-gate" 0 2000 755 "u:object_r:system_file:s0"
    EVAL "cp -f \"$MODPATH/k4_tethering_gate.rc\" \"$TT_SYS/etc/init/k4_tethering_gate.rc\"" || ABORT "tethering_trains: rc copy failed"
    SET_METADATA "system" "system/etc/init/k4_tethering_gate.rc" 0 0 644 "u:object_r:system_file:s0"
    # init parses /system/etc/init alphabetically: evidence capture (a52sxq_mainline.rc) first, then the gate, then the
    # loader (netbpfload.rc), all on the same load-bpf-programs trigger
    [[ "a52sxq_mainline.rc" < "k4_tethering_gate.rc" && "k4_tethering_gate.rc" < "netbpfload.rc" ]] || \
        ABORT "tethering_trains: k4_tethering_gate.rc must sort between a52sxq_mainline.rc and netbpfload.rc"
    [ -f "$TT_SYS/etc/init/a52sxq_mainline.rc" ] || \
        LOGW "tethering_trains: no a52sxq_mainline.rc (play_system_updates disabled?) - the gate still runs, but a reverted boot leaves no evidence in /cache"
    grep -q "sys.init.updatable_crashing" "$TT_SYS/bin/apexd" || \
        ABORT "tethering_trains: this apexd does not watch sys.init.updatable_crashing - the gate's revert path is gone, review k4_tethering_gate.rc"
    if ! grep -q -x -F "(type k4_tethering_prop)" "$TT_CIL"; then
        for t in k4apexdm system_file apex_mnt_dir property_socket init shell; do
            grep -q -x -F "(type $t)" "$TT_CIL" || ABORT "tethering_trains: type $t not in plat_sepolicy.cil, review sepolicy.cil"
        done
        [ -z "$(tail -c 1 "$TT_CIL")" ] || echo >> "$TT_CIL"
        cat "$MODPATH/sepolicy.cil" >> "$TT_CIL"
        # A property type must be a member of property_type (and system_property_type for system-side props) or init
        # cannot label its property file: "Failed to initialize property area" -> init aborts -> bootloop (9.3.94).
        # secilc rejects a second typeattributeset for an attribute, so extend the existing ones (as ksu_metamodule).
        for n in property_type system_property_type; do
            [ "$(grep -c "^(typeattributeset $n (" "$TT_CIL")" = 1 ] || ABORT "tethering_trains: no single $n attribute set in plat_sepolicy.cil"
            sed -i "s/^(typeattributeset $n (/(typeattributeset $n (k4_tethering_prop /" "$TT_CIL"
            grep -q "^(typeattributeset $n (k4_tethering_prop " "$TT_CIL" || ABORT "tethering_trains: failed to extend $n"
        done
    fi
    grep -q -x -F "(allow k4apexdm k4_tethering_prop (property_service (set)))" "$TT_CIL" || ABORT "tethering_trains: rules missing from plat_sepolicy.cil"
    grep -q "^(typeattributeset property_type (.*k4_tethering_prop" "$TT_CIL" || ABORT "tethering_trains: k4_tethering_prop is not in property_type"
    grep -q -E "^sys\.k4\.tethering_gap" "$TT_PC" && ABORT "tethering_trains: sys.k4.tethering_gap already in plat_property_contexts"
    [ -z "$(tail -c 1 "$TT_PC")" ] || echo >> "$TT_PC"
    echo "sys.k4.tethering_gap        u:object_r:k4_tethering_prop:s0" >> "$TT_PC"
    LOG "- Tethering train gate: a train whose netd.o needs maps a52_netd.o lacks is reverted by apexd in one reboot"
    unset TT_SYS TT_CIL TT_PC t
fi
unset TT_NETD
