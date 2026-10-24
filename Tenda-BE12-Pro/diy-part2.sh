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

sed -i 's/default-settings-chn/default-settings/g' include/target.mk

# Apply custom diff patch
PATCH_FILE="$GITHUB_WORKSPACE/Tenda-BE12-Pro/diff.patch"

if [ -f "$PATCH_FILE" ]; then
    patch -p1 < "$PATCH_FILE"
else
    echo "WARNING: diff.patch not found: $PATCH_FILE"
fi

rm -rf package/mtk/applications/luci-app-turboacc-mtk

git clone https://github.com/kalicyh/ImmortalWrt-tenda_be12-pro.git tmp_imm &&
cd tmp_imm &&
git checkout 1b9eb1188963b7a0ef899de085fd1fde3685aefa &&
cd .. &&
cp -r tmp_imm/package/mtk/applications/luci-app-turboacc-mtk package/mtk/applications/ &&
rm -rf tmp_imm

rm -f package/base-files/files/bin/config_generate.orig
rm -f package/base-files/files/etc/shadow.orig
rm -f package/mtk/applications/mtwifi-cfg/files/mtwifi-cfg/mtwifi_defs.lua.orig
rm -f feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css.orig
rm -f feeds.conf.default.orig
