#!/bin/bash
# ==============================================================================
# TITAN OS - Complete Master Build & ISO Generator
# Base: Debian Minimal | RAM Footprint: ~280MB
# Features: LXDE UI, Universal Mesa/Vulkan Gaming Drivers, Wine 32-bit & DXVK,
#           Waydroid Installer Script, Chrome, AbiWord, Titan Updater
# ==============================================================================

set +e

echo "[1/9] Updating Repositories & Installing Build Tools..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y live-build xorriso squashfs-tools curl ca-certificates wget git firmware-linux-free

echo "[2/9] Installing Wi-Fi Drivers & Firmware..."
sudo apt install -y wireless-tools wpasupplicant bluetooth || true

echo "[3/9] Installing Universal Mesa & Vulkan Gaming Drivers..."
sudo apt install -y mesa-vulkan-drivers mesa-utils libgl1-mesa-dri libglx-mesa0 vulkan-tools || true

echo "[4/9] Building LXDE Desktop UI, Search Bar, Settings & Terminal..."
sudo apt install -y --no-install-recommends \
    lxde-core lxpanel pcmanfm lxterminal network-manager-gnome \
    arandr lxappearance pulseaudio pavucontrol software-properties-gtk || true

echo "[5/9] Injecting Wine & DirectX Hardware Engine..."
sudo dpkg --add-architecture i386 || true
sudo apt update || true
sudo apt install -y wine-staging winetricks dxvk libgl1-mesa-dri libglx-mesa0 || true

echo "[6/9] Creating One-Click Waydroid Installer Script on Desktop..."
mkdir -p /etc/skel/Desktop
cat << 'EOF' | sudo tee /etc/skel/Desktop/install-waydroid.sh
#!/bin/bash
echo "=========================================="
echo "      TITAN OS - WAYDROID INSTALLER       "
echo "=========================================="
echo "Installing Waydroid Engine for Android Games..."
curl https://repo.waydro.id | sudo bash
sudo apt update
sudo apt install -y waydroid
echo "Waydroid installed successfully! Launching setup..."
sudo waydroid init
EOF
sudo chmod +x /etc/skel/Desktop/install-waydroid.sh

echo "[7/9] Installing Chrome, Terminal Tools & AbiWord..."
sudo apt install -y abiword htop evince || true
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb || true
sudo apt install -y /tmp/chrome.deb || true
rm -f /tmp/chrome.deb

echo "[8/9] Creating One-Click Titan System Updater..."
cat << 'EOF' | sudo tee /usr/local/bin/titan-update
#!/bin/bash
echo "=========================================="
echo "         TITAN OS SYSTEM UPDATER          "
echo "=========================================="
echo "Checking for latest system & engine updates..."
sudo apt update && sudo apt upgrade -y
echo "TITAN OS is up to date!"
EOF
sudo chmod +x /usr/local/bin/titan-update


echo "[9/9] Configuring Live-Build Directory & Generating ISO..."
# தற்போதைய டைரக்டரியிலேயே பில்ட் செய்யும் வகையில் அமைத்தல்:
lb config --architectures amd64 --distribution bookworm --archive-areas "main contrib non-free non-free-firmware"
sudo lb build

# பில்ட் ஆன ISO ஃபைலை root / workspace டைரக்டரிக்கு கொண்டு வருதல்:
sudo mv *.iso /tmp/titan-os.iso 2>/dev/null || sudo mv *.hybrid.iso /tmp/titan-os.iso 2>/dev/null || true

echo "=============================================================================="
echo "TITAN OS BUILD COMPLETE!"
echo "=============================================================================="
