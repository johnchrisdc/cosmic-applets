#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export PKG_CONFIG_PATH="$SCRIPT_DIR/.pkgconfig:$PKG_CONFIG_PATH"
export RUSTFLAGS="-C link-arg=-L$SCRIPT_DIR/.pkgconfig/lib -C link-arg=-ludev $RUSTFLAGS"

echo "Building release binaries..."
cargo build --release --package cosmic-applet-potato-time --package cosmic-applet-potato-battery

# 1. Build Potato Time .deb
TIME_DEB_DIR="target/deb/cosmic-applet-potato-time_1.0.15_amd64"
mkdir -p "$TIME_DEB_DIR/DEBIAN" "$TIME_DEB_DIR/usr/bin" "$TIME_DEB_DIR/usr/share/applications"

cat << 'EOF' > "$TIME_DEB_DIR/DEBIAN/control"
Package: cosmic-applet-potato-time
Version: 1.0.15
Architecture: amd64
Maintainer: System76 <info@system76.com>
Installed-Size: 26000
Section: utils
Priority: optional
Homepage: https://github.com/pop-os/cosmic-applets
Description: Potato Date, Time, & Calendar COSMIC Applet (Potato tweaks)
 Potato Date, Time, and Calendar applet for COSMIC Desktop with Word Clock,
 Rainbow Mode, and Potato tweaks support.
EOF

cp target/release/cosmic-applet-potato-time "$TIME_DEB_DIR/usr/bin/"
cp cosmic-applet-potato-time/data/com.system76.CosmicAppletPotatoTime.desktop "$TIME_DEB_DIR/usr/share/applications/"
dpkg-deb --build "$TIME_DEB_DIR"

# 2. Build Potato Battery .deb
BATTERY_DEB_DIR="target/deb/cosmic-applet-potato-battery_1.0.15_amd64"
mkdir -p "$BATTERY_DEB_DIR/DEBIAN" "$BATTERY_DEB_DIR/usr/bin" "$BATTERY_DEB_DIR/usr/share/applications"

cat << 'EOF' > "$BATTERY_DEB_DIR/DEBIAN/control"
Package: cosmic-applet-potato-battery
Version: 1.0.15
Architecture: amd64
Maintainer: System76 <info@system76.com>
Installed-Size: 26000
Section: utils
Priority: optional
Homepage: https://github.com/pop-os/cosmic-applets
Description: Potato Power & Battery COSMIC Applet (Potato tweaks)
 Potato Power and Battery applet for COSMIC Desktop with Potato tweaks support.
EOF

cp target/release/cosmic-applet-potato-battery "$BATTERY_DEB_DIR/usr/bin/"
cp cosmic-applet-potato-battery/data/com.system76.CosmicAppletPotatoBattery.desktop "$BATTERY_DEB_DIR/usr/share/applications/"
dpkg-deb --build "$BATTERY_DEB_DIR"

echo ""
echo "✅ Created deb packages with Potato tweaks description:"
echo "  - target/deb/cosmic-applet-potato-time_1.0.15_amd64.deb"
echo "  - target/deb/cosmic-applet-potato-battery_1.0.15_amd64.deb"
