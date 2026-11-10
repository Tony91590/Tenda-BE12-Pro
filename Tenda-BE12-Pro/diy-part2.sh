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
# Optimized LuCI + ImmortalWrt enhancements

set -e

# ==========================================
# Custom patch directory
# ==========================================

PATCH_DIR="$GITHUB_WORKSPACE/Tenda-BE12-Pro"

# ==========================================
# Kernel vermagic override
# ==========================================

PATCH_VER="$PATCH_DIR/vermagic.patch"

echo "[0] Setting kernel vermagic"

patch -p1 < "$PATCH_VER"

echo "✓ Setting kernel vermagic applied successfully."

# ==========================================
# LuCI system status patch
# ==========================================

SYSTEM_PATCH="$PATCH_DIR/10_system.patch"

echo "[1] Applying LuCI system status patch..."

if [ ! -f "$SYSTEM_PATCH" ]; then
    echo "ERROR: System patch not found: $SYSTEM_PATCH"
    exit 1
fi

patch --batch -p1 < "$SYSTEM_PATCH"

echo "✓ LuCI system status patch applied successfully."

# ==========================================
# Tenda BE12 Pro board integration
# ==========================================

BOARD_MK="$PATCH_DIR/board-port.mk"
FLMK="target/linux/mediatek/image/filogic.mk"
MARKER="# >>> TENDA-PORT be12-pro >>>"

echo "[1.1] Integrating Tenda BE12 Pro board definition..."

if [ ! -f "$BOARD_MK" ]; then
    echo "ERROR: board-port.mk not found: $BOARD_MK"
    exit 1
fi

if [ ! -f "$FLMK" ]; then
    echo "ERROR: filogic.mk not found: $FLMK"
    exit 1
fi

if grep -qF "$MARKER" "$FLMK"; then
    echo "Tenda BE12 Pro board already integrated, skipping."
else
    {
        echo
        echo "$MARKER"
        cat "$BOARD_MK"
        echo "# <<< TENDA-PORT be12-pro <<<"
    } >> "$FLMK"

    echo "✓ Tenda BE12 Pro board definition integrated successfully."
fi

# ==========================================
# Tenda BE12 Pro DTS patch
# ==========================================

DTS_PATCH="$PATCH_DIR/dts.patch"

echo "[1.2] Applying Tenda BE12 Pro DTS patch..."

if [ ! -f "$DTS_PATCH" ]; then
    echo "ERROR: DTS patch not found: $DTS_PATCH"
    exit 1
fi

patch --batch -p1 < "$DTS_PATCH"

echo "✓ DTS patch applied successfully."

# ==========================================
# Tenda BE12 Pro Network patch
# ==========================================

NETWORK_PATCH="$PATCH_DIR/network.patch"

echo "[1.3] Applying Tenda BE12 Pro Network patch..."

if [ ! -f "$NETWORK_PATCH" ]; then
    echo "ERROR: Network patch not found: $NETWORK_PATCH"
    exit 1
fi

patch --batch -p1 < "$NETWORK_PATCH"

echo "✓ Network patch applied successfully."

# ==========================================
# LuCI RPC backend
# ==========================================

echo "[2] Patching LuCI RPC backend..."

python3 <<'PY'
from pathlib import Path

file = Path("feeds/luci/modules/luci-base/root/usr/share/rpcd/ucode/luci")

if not file.exists():
    raise SystemExit("LuCI RPC file not found")

s = file.read_text()

if "getTempInfo:" in s:
    print("Patch already applied, skipping.")
    exit(0)

block = r"""
        getTempInfo: {
            call: function() {
                if (!access('/sbin/tempinfo'))
                    return {};

                const fd = popen('/sbin/tempinfo');
                if (!fd)
                    return { tempinfo: error() };

                let tempinfo = fd.read('all') || '?';
                fd.close();

                return { tempinfo: tempinfo };
            }
        }
"""

marker_candidates = [
    "\n};\n\nreturn { luci: methods };",
    "\n}; return { luci: methods };"
]

for marker in marker_candidates:
    if marker in s:
        s = s.replace(marker, ",\n" + block.strip() + marker, 1)
        file.write_text(s)
        print("Patch applied successfully.")
        break
else:
    raise SystemExit("LuCI RPC end marker not found, aborting.")
PY

# ==========================================
# ImmortalWrt packages
# ==========================================

echo "[3] Adding ImmortalWrt packages..."

mkdir -p files/sbin

cat > files/sbin/tempinfo <<'EOF'
#!/bin/sh
#
# MediaTek Filogic platform support: CPU and WiFi temperature monitoring

IEEE_PATH="/sys/class/ieee80211"
THERMAL_PATH="/sys/class/thermal"

wifi_temp="$(awk '{printf("%.1f°C ", $0 / 1000)}' "$IEEE_PATH"/phy*/hwmon*/temp1_input 2>"/dev/null" | awk '$1=$1')"
cpu_temp="$(awk '{printf("%.1f°C", $0 / 1000)}' "$THERMAL_PATH/thermal_zone0/temp" 2>"/dev/null")"

echo -n "CPU: $cpu_temp, WiFi: $wifi_temp"
EOF

chmod +x files/sbin/tempinfo

mkdir -p files/usr/share/rpcd/acl.d

cat > files/usr/share/rpcd/acl.d/luci-mod-status-autocore.json <<'EOF'
{
    "luci-mod-status-autocore": {
        "description": "Grant access to autocore",
        "read": {
            "ubus": {
                "luci": [ "getTempInfo" ]
            }
        }
    }
}
EOF

# ==========================================
# Kernel / MT76 / MT7996E / WED
# ==========================================

WED_PATCH="$PATCH_DIR/0125-mediatek-add-MT7987-WED-support-from-MediaTek-SDK.patch"

echo "[4] Applying MediaTek MT7987 WED patch..."

if [ ! -f "$WED_PATCH" ]; then
    echo "ERROR: MT7987 WED patch not found: $WED_PATCH"
    exit 1
fi

patch --batch -p1 < "$WED_PATCH"

echo "✓ MediaTek MT7987 WED patch applied successfully."

# ------------------------------------------
# Enable WED for mt7996e
# ------------------------------------------

echo "[4.1] Enabling WED for mt7996e..."

MT76_MAKEFILE="package/kernel/mt76/Makefile"

if [ ! -f "$MT76_MAKEFILE" ]; then
    echo "ERROR: mt76 Makefile not found: $MT76_MAKEFILE"
    exit 1
fi

if grep -qF 'MODPARAMS.mt7996e:=wed_enable=Y' "$MT76_MAKEFILE"; then
    echo "mt7996e WED already enabled, skipping."
else
    sed -i '/AUTOLOAD:=$(call AutoProbe,mt7996e)/a \  MODPARAMS.mt7996e:=wed_enable=Y' "$MT76_MAKEFILE"
    echo "✓ mt7996e WED enabled successfully."
fi

# ==========================================
# LuCI theme Argon
# ==========================================

echo "[5] LuCI theme Argon..."

rm -rf package/luci-theme-argon package/luci-app-argon-config

git clone -b release/v2.4.8-hotfix https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
#git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# ==========================================
# Default WiFi
# ==========================================

echo "[6] Default WiFi"

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-default-settings <<'EOF'
#!/bin/sh

uci set wireless.@wifi-device[0].disabled='0'
uci set wireless.@wifi-iface[0].disabled='0'
uci set wireless.@wifi-iface[0].encryption='none'
uci set wireless.@wifi-iface[0].ssid="OpenWrt_2.4G"

uci set wireless.@wifi-device[1].disabled='0'
uci set wireless.@wifi-iface[1].disabled='0'
uci set wireless.@wifi-iface[1].encryption='none'
uci set wireless.@wifi-iface[1].ssid="OpenWrt_5G"

uci commit wireless

uci set firewall.@defaults[0].flow_offloading='1'
uci set firewall.@defaults[0].flow_offloading_hw='1'

uci commit firewall

# Add the MediaTek Filogic kernel modules repository if missing
echo 'https://downloads.openwrt.org/releases/25.12.5/targets/mediatek/filogic/kmods/6.12.94-1-5a6c1f71be683ae9980b15d3ce73e24d/packages.adb' >> /etc/apk/repositories.d/distfeeds.list

exit 0
EOF

chmod +x files/etc/uci-defaults/99-default-settings

# ==========================================
# Cleanup
# ==========================================

#DIFF_PATCH="$PATCH_DIR/diff.patch"
#patch -p1 < "$DIFF_PATCH"

rm -f feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js.orig
rm -f target/linux/mediatek/filogic/base-files/etc/board.d/02_network.orig
rm -f config/Config-kernel.in.orig
rm -f include/kernel-defaults.mk.orig

cp $GITHUB_WORKSPACE/Tenda-BE12-Pro/db.patch package/firmware/wireless-regdb/patches/

rm -rf package/network/services/odhcpd

git clone https://github.com/openwrt/openwrt.git tmp_imm &&
cd tmp_imm &&
git checkout 3d5a743f1f0cb77aed8ed63b2f9aa75700b4322c &&
cd .. &&
cp -r tmp_imm/package/network/services/odhcpd package/network/services/ &&
rm -rf tmp_imm

echo "Done ✔"
