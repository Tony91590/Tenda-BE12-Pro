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
# Kernel vermagic override
# ==========================================

#PATCH_VER="$GITHUB_WORKSPACE/Tenda-BE12-Pro/vermagic.patch"

echo "[0] Setting kernel vermagic"

#patch -p1 < "$PATCH_VER"

echo "✓ Setting kernel vermagic applied successfully."

# ==========================================
# LuCI system status patch
# ==========================================

PATCH_FILE="$GITHUB_WORKSPACE/Tenda-BE12-Pro/10_system.patch"

echo "[1] Applying LuCI system status patch..."

patch -p1 < "$PATCH_FILE"

echo "✓ LuCI system status patch applied successfully."

# ==========================================
# Tenda BE12 Pro board integration
# ==========================================

BOARD_MK="$GITHUB_WORKSPACE/Tenda-BE12-Pro/board-port.mk"
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
# Kernel tweaks
# ==========================================

echo "[4] Kernel tweak (mt76 / Tenda-BE12-Pro)..."

#sed -i '/AUTOLOAD:=$(call AutoProbe,mt7915e)/a \  MODPARAMS.mt7915e:=wed_enable=Y' package/kernel/mt76/Makefile

# ==========================================
# LuCI theme Argon
# ==========================================

echo "[5] LuCI theme Argon..."

rm -rf package/luci-theme-argon package/luci-app-argon-config

git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# ==========================================
# Default WiFi
# ==========================================

echo "[6] Default WiFi"

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-default-settings << 'EOF'
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

exit 0
EOF

chmod +x files/etc/uci-defaults/99-default-settings

# ==========================================
# Cleanup
# ==========================================

#PATCH_FILE="$GITHUB_WORKSPACE/Tenda-BE12-Pro/diff.patch"
#patch -p1 < "$PATCH_FILE"

rm -f feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js.orig

echo "Done ✔"
