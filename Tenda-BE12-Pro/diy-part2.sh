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

sed -i 's/ImmortalWrt/OpenWrt/g' package/base-files/files/bin/config_generate
sed -i 's/pool.ntp.org/3.openwrt.pool.ntp.org/g' package/base-files/files/bin/config_generate
sed -i 's/time1.apple.com/0.openwrt.pool.ntp.org/g' package/base-files/files/bin/config_generate
sed -i 's/time1.google.com/1.openwrt.pool.ntp.org/g' package/base-files/files/bin/config_generate
sed -i 's/time.cloudflare.com/2.openwrt.pool.ntp.org/g' package/base-files/files/bin/config_generate
sed -i 's/default-settings-chn/default-settings/g' include/target.mk
sed -i 's/ImmortalWrt/OpenWrt/g' include/version.mk
sed -i 's,https://immortalwrt.org/,https://openwrt.org/,g' include/version.mk
sed -i 's,https://github.com/immortalwrt/immortalwrt/issues,https://bugs.openwrt.org/,g' include/version.mk
sed -i 's,https://github.com/immortalwrt/immortalwrt/discussions,https://forum.openwrt.org/,g' include/version.mk
sed -i 's,https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT,https://downloads.openwrt.org/releases/21.02-SNAPSHOT,g' include/version.mk
cat > package/base-files/files/etc/banner << EOF
  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 %D %V, %C
 -----------------------------------------------------
EOF

rm -rf package/mtk/applications/luci-app-turboacc-mtk

git clone https://github.com/kalicyh/ImmortalWrt-tenda_be12-pro.git tmp_imm &&
cd tmp_imm &&
git checkout 40c4bf56665d7c70749035762142b5a17628448a &&
cd .. &&
cp -r tmp_imm/package/mtk/applications/luci-app-turboacc-mtk package/mtk/applications/ &&
rm -rf tmp_imm

sed -i 's/\r$//' package/mtk/applications/luci-app-turboacc-mtk/htdocs/luci-static/resources/view/turboacc.js

# Apply custom diff patch
PATCH_FILE="$GITHUB_WORKSPACE/Tenda-BE12-Pro/diff.patch"

if [ -f "$PATCH_FILE" ]; then
    patch -p1 < "$PATCH_FILE"
else
    echo "WARNING: diff.patch not found: $PATCH_FILE"
fi

rm -f target/linux/mediatek/filogic/base-files/etc/init.d/bootcount.orig
rm -f package/mtk/applications/luci-app-turboacc-mtk/root/etc/init.d/turboacc.orig
rm -f package/mtk/applications/luci-app-turboacc-mtk/root/etc/uci-defaults/turboacc.orig
rm -f package/mtk/applications/luci-app-turboacc-mtk/htdocs/luci-static/resources/view/turboacc.js.orig
rm -f package/base-files/files/bin/config_generate.orig
rm -f package/base-files/files/etc/shadow.orig
rm -f package/mtk/applications/mtwifi-cfg/files/mtwifi-cfg/mtwifi_defs.lua.orig
rm -f feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css.orig

rm -f target/linux/generic/pending-6.6/650-Revert-ipv6-save-dontfrag-in-cork.patch

# rm -rf package/mtk/applications/luci-app-turboacc-mtk

# git clone -b sauvegarde https://github.com/kalicyh/ImmortalWrt-tenda_be12-pro.git tmp_imm

# cp -r tmp_imm/package/mtk/applications/luci-app-turboacc-mtk package/mtk/applications/
# rm -rf tmp_imm
