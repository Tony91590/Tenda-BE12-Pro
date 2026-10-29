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

PATCH_FILE="$GITHUB_WORKSPACE/Tenda-BE12-Pro/diff.patch"

if [ -f "$PATCH_FILE" ]; then
    patch -p1 < "$PATCH_FILE"
else
    echo "WARNING: diff.patch not found: $PATCH_FILE"
fi

rm -f feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css.orig

rm -rf package/mtk/applications/luci-app-turboacc-mtk

git clone https://github.com/kalicyh/ImmortalWrt-tenda_be12-pro.git tmp_imm &&
cd tmp_imm &&
git checkout 276207b223be0f61ecdacea2de1194a3f97816bb &&
cd .. &&
cp -r tmp_imm/package/mtk/applications/luci-app-turboacc-mtk package/mtk/applications/ &&
rm -rf tmp_imm
