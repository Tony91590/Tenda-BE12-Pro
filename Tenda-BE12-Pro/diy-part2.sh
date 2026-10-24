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

#rm -f package/network/config/netifd/files/sbin/ifdown
#ln -s ifup package/network/config/netifd/files/sbin/ifdown

# Apply custom diff patch
PATCH_FILE="$GITHUB_WORKSPACE/Tenda-BE12-Pro/diff.patch"

if [ -f "$PATCH_FILE" ]; then
    patch -p1 < "$PATCH_FILE"
else
    echo "WARNING: diff.patch not found: $PATCH_FILE"
fi

rm -f feeds.conf.default.orig
rm -f include/target.mk.orig
rm -f package/base-files/files/bin/config_generate.orig
rm -f package/base-files/files/etc/shadow.orig
rm -f package/mtk/applications/luci-app-turboacc-mtk/Makefile.orig
rm -f package/mtk/applications/luci-app-turboacc-mtk/htdocs/luci-static/resources/view/turboacc.js.orig
rm -f package/mtk/applications/luci-app-turboacc-mtk/po/templates/turboacc.pot.orig
rm -f package/mtk/applications/luci-app-turboacc-mtk/po/zh_Hans/turboacc.po.orig
rm -f package/mtk/applications/luci-app-turboacc-mtk/root/etc/init.d/turboacc.orig
rm -f package/mtk/applications/luci-app-turboacc-mtk/root/etc/uci-defaults/turboacc.orig
rm -f package/mtk/applications/luci-app-turboacc-mtk/root/usr/libexec/rpcd/luci.turboacc.orig
rm -f package/mtk/applications/mtwifi-cfg/files/mtwifi-cfg/mtwifi_defs.lua.orig
rm -f feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css.orig
