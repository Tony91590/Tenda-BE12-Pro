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

wget -O fix-ifdown.patch \
"https://github.com/Tony91590/ImmortalWrt-tenda_be12-pro/commit/df7f2834742ae6850bb1a24d64ce53726c11e7fe.patch"

git apply --check fix-ifdown.patch
git apply fix-ifdown.patch

PATCH_FILE="$GITHUB_WORKSPACE/Tenda-BE12-Pro/diff.patch"
patch -p1 < "$PATCH_FILE"

rm -f feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css.orig
