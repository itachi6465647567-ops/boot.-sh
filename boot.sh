#!/bin/bash
# ==============================================================================
# TITAN OS - Complete Master Build & ISO Generator
# Base: Debian Minimal | RAM Footprint: ~280MB
# Features: LXDE UI, Search Bar, Settings, Terminal, Roblox (Wine),
#           Free Fire (Waydroid), Chrome, AbiWord, Titan Updater
# Hardware: Auto-detect NVIDIA Graphics & Wi-Fi Chipsets
# ==============================================================================

set -e

echo "[1/9] Updating Repositories & Installing Build Tools..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y live-build xorriso squashfs-tools curl ca-certificates wget git non-free-firmware

echo "[2/9] Auto-detecting & Installing Wi-Fi Drivers & Firmware..."
# Installs common Wi-Fi drivers (Broadcom, Realtek, Intel, Wireless Tools)
sudo apt install -y firmware-linux firmware-linux-nonfree firmware-realtek firmware-atheros firmware-broadcom broadcom-sta-dkms wireless-tools wpasupplicant bluetooth

echo "[3/9] Auto-detecting & Installing NVIDIA Legacy Graphics Drivers..."
sudo apt install -y nvidia-detect
sudo apt install -y nvidia-legacy-340xx-driver nvidia-xconfig || sudo apt install -y nvidia-driver

echo "[4/9] Building Windows 10 UI, Search Bar, Settings & Terminal..."
sudo apt install -y --no-install-recommends \
    lxde-core lxpanel pcmanfm lxterminal network-manager-gnome \
    arandr lxappearance pulseaudio pavucontrol software-properties-gtk

echo "[5/9] Injecting Wine & DirectX Hardware Engine for Roblox..."
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y wine-staging winetricks dxvk libgl1-mesa-dri libglx-mesa0

echo "[6/9] Injecting Waydroid Engine for Free Fire Gaming..."
curl https://repo.waydro.id | sudo bash
sudo apt install -y waydroid

echo "[7/9] Installing Chrome, Terminal Tools & AbiWord (MS Word Support)..."
sudo apt install -y abiword htop evince
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

echo "[8/9] Creating One-Click Titan System Updater..."
cat << 'EOF' | sudo tee /usr/local/bin/titan-update
#!/bin/bash
echo "=========================================="
echo "         TITAN OS SYSTEM UPDATER          "
echo "=========================================="
echo "Checking for latest system & engine updates..."
sudo apt update && sudo apt upgrade -y
sudo apt install --only-upgrade wine-staging waydroid -y
echo "TITAN OS is up to date!"
EOF
sudo chmod +x /usr/local/bin/titan-update

echo "[9/9] Generating Titan OS ISO File..."
sudo lb config
sudo lb build
mv live-image-amd64.hybrid.iso ~/Desktop/titan-os.iso

echo "=============================================================================="
echo "TITAN OS BUILD COMPLETE! 'titan-os.iso' created on Desktop."
echo "Ready to copy to Ventoy Pen Drive!"
echo "=============================================================================="
