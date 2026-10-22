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

chmod 0777 ‎package/network/config/netifd/files/sbin/ifdown

PATCH_FILE="$GITHUB_WORKSPACE/Tenda-BE12-Pro/diff.patch"
patch -p1 < "$PATCH_FILE"

rm -f feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css.orig
