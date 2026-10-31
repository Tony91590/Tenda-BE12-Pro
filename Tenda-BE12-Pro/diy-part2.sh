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

rm -rf package/mtk/applications/luci-app-turboacc-mtk

git clone -b Vvvvv2232 https://github.com/Tony91590/ImmortalWrt-tenda_be12-pro.git tmp_imm

cp -r tmp_imm/package/mtk/applications/luci-app-turboacc-mtk package/mtk/applications/
rm -rf tmp_imm
