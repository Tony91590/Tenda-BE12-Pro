#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Custom build script - Tenda-BE12-Pro

# Fix netifd ifdown symlink
PATCH_URL="https://github.com/Tony91590/ImmortalWrt-tenda_be12-pro/commit/df7f2834742ae6850bb1a24d64ce53726c11e7fe.patch"

if wget -q -O /tmp/fix-ifdown.patch "$PATCH_URL"; then
    if git apply --check /tmp/fix-ifdown.patch 2>/dev/null; then
        git apply /tmp/fix-ifdown.patch
        echo "ifdown patch applied successfully."
    elif git apply --reverse --check /tmp/fix-ifdown.patch 2>/dev/null; then
        echo "ifdown patch is already applied."
    else
        echo "WARNING: ifdown patch cannot be applied to the current source."
    fi
else
    echo "WARNING: Failed to download ifdown patch."
fi

# Apply custom diff patch
PATCH_FILE="$GITHUB_WORKSPACE/Tenda-BE12-Pro/diff.patch"

if [ -f "$PATCH_FILE" ]; then
    patch -p1 < "$PATCH_FILE"
else
    echo "WARNING: diff.patch not found: $PATCH_FILE"
fi

# Remove Argon CSS backup file
rm -f feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css.orig
