for f in "$WORK_DIR/vendor/etc/seccomp_policy/"*; do
    if grep -q "^mremap:" "$f"; then
        LOG "- Allowing mremap in /vendor/etc/seccomp_policy/$(basename "$f")"
        EVAL "sed -i 's/^mremap:.*/mremap: 1/' \"$f\""
    fi
done
