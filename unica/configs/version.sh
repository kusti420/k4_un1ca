# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# Only the below variable(s) need to be changed!
VERSION_MAJOR=4
VERSION_MINOR=0
VERSION_PATCH=0

# The below variables will be generated automatically
#
# Version name
ROM_VERSION="${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}"
# k4: a target with its own version file (target/<codename>/version, e.g. a52sxq 9.3.10) uses that instead of the
# upstream UN1CA version, so the zip name, ro.unica.version and the installer banner show the fork's version.
# gen_config_file sources this script with the target codename as $1.
K4_TARGET_VERSION="$(tr -d '[:space:]' < "$SRC_DIR/target/${TARGET_CODENAME:-$1}/version" 2> /dev/null)"
[ "$K4_TARGET_VERSION" ] && ROM_VERSION="$K4_TARGET_VERSION"
# Append "+" to version name if commits have been added since the last tag (upstream versions only)
LATEST_TAG="$(git describe --tags --abbrev=0 2> /dev/null)"
if [ "$LATEST_TAG" ] && [ ! "$K4_TARGET_VERSION" ]; then
    if [[ "$(git rev-list --count "$LATEST_TAG...HEAD" 2> /dev/null)" =~ 0*[1-9][0-9]* ]]; then
        ROM_VERSION+="+"
    fi
fi
# Append current commit hash to version name
ROM_VERSION+="-$(git rev-parse --short HEAD 2> /dev/null || echo "null")"
# Append "-dirty" to version name if uncommitted changes are detected
if [ "$(git --no-optional-locks status -uno --porcelain 2> /dev/null)" ]; then
    ROM_VERSION+="-dirty"
fi
unset K4_TARGET_VERSION
