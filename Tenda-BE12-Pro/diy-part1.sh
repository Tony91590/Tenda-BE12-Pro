#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
#echo 'src-git messense https://github.com/messense/aliyundrive-webdav' >>feeds.conf.default


src-git packages https://git.openwrt.org/feed/packages.git^f9605a4961c577e7eac1bf019ddabae2b6e558f7
src-git luci https://git.openwrt.org/project/luci.git^1854572d9ab6af8d09b03ed6d1dbf4a42425ff1f
src-git routing https://git.openwrt.org/feed/routing.git^ea8633da9c461a9bdc62a0323439d31180762e03
src-git telephony https://git.openwrt.org/feed/telephony.git^06feffc2c154993f555b43756ef7db6dd7e58225
src-git video https://github.com/openwrt/video.git^7d3dcdebda95e50604cf068ed9b8fef29c94069e
