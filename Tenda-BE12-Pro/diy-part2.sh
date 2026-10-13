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
#sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate
#sed -i '/"FR"/s/\[ 1, 2 \]/[ 1, 1 ]/' package/mtk/applications/mtwifi-cfg-ucode/files/usr/share/schema/mtwifi/dat-defs.json
sed -i 's/default-settings-chn/default-settings/g' include/target.mk
#grep -n '"FR"' package/mtk/applications/mtwifi-cfg-ucode/files/usr/share/schema/mtwifi/dat-defs.json
PATCH_FILE="$GITHUB_WORKSPACE/Xiaomi-AX3000T/diff.patch"
patch -p1 < "$PATCH_FILE"
