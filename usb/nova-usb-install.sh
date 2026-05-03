#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${1:-$SCRIPT_DIR/nova-install.conf}"

if [[ $EUID -ne 0 ]]; then
    echo "Run this installer as root from the Arch live environment." >&2
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Missing config file: $CONFIG_FILE" >&2
    echo "Copy usb/nova-install.conf.example to usb/nova-install.conf and edit it first." >&2
    exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

: "${CONFIRM_DESTROY:=NO}"
: "${TARGET_DISK:=}"
: "${HOSTNAME:=nova-arch}"
: "${USERNAME:=mella}"
: "${PASSWORD:=ChangeMe123!}"
: "${TIMEZONE:=America/Toronto}"
: "${LOCALE:=en_US.UTF-8}"
: "${KEYMAP:=us}"
: "${USE_LOCAL_PAYLOAD:=YES}"
: "${REPO_URL:=https://github.com/Cmella3301/ctfbox-rice.git}"
: "${AUTO_REBOOT:=YES}"
: "${FORCE_SOFTWARE_RENDERING:=NO}"

if [[ "$CONFIRM_DESTROY" != "YES" ]]; then
    echo "Refusing to run until CONFIRM_DESTROY=\"YES\" is set in the config." >&2
    exit 1
fi

if [[ ! -d /sys/firmware/efi/efivars ]]; then
    echo "This installer currently supports UEFI boot only." >&2
    exit 1
fi

detect_target_disk() {
    mapfile -t disks < <(lsblk -dpno NAME,TYPE,RM,TRAN | awk '$2=="disk" && $3=="0" && $4!="usb"{print $1}')

    if (( ${#disks[@]} == 1 )); then
        printf '%s\n' "${disks[0]}"
        return 0
    fi

    echo "Unable to auto-select a single internal target disk." >&2
    lsblk -dpno NAME,SIZE,MODEL,TRAN | awk '$1 ~ /^\/dev\//'
    echo "Set TARGET_DISK in $CONFIG_FILE and try again." >&2
    return 1
}

detect_ucode_package() {
    local vendor
    vendor="$(lscpu | awk -F: '/Vendor ID/{gsub(/^[ \t]+/, "", $2); print $2}')"

    case "$vendor" in
        GenuineIntel) printf '%s\n' "intel-ucode" ;;
        AuthenticAMD) printf '%s\n' "amd-ucode" ;;
        *) printf '%s\n' "" ;;
    esac
}

TARGET_DISK="${TARGET_DISK:-$(detect_target_disk)}"

if [[ ! -b "$TARGET_DISK" ]]; then
    echo "Target disk does not exist: $TARGET_DISK" >&2
    exit 1
fi

PARTSEP=""
if [[ "$TARGET_DISK" == *"nvme"* ]] || [[ "$TARGET_DISK" == *"mmcblk"* ]]; then
    PARTSEP="p"
fi

EFI_PART="${TARGET_DISK}${PARTSEP}1"
ROOT_PART="${TARGET_DISK}${PARTSEP}2"
UCODE_PACKAGE="$(detect_ucode_package)"

printf '\n==> Nova USB installer summary\n'
printf '    Disk: %s\n' "$TARGET_DISK"
printf '    Hostname: %s\n' "$HOSTNAME"
printf '    Username: %s\n' "$USERNAME"
printf '    Timezone: %s\n' "$TIMEZONE"
printf '    Local payload: %s\n' "$USE_LOCAL_PAYLOAD"
printf '    Repo URL: %s\n\n' "$REPO_URL"

timedatectl set-ntp true

printf '==> Partitioning %s\n' "$TARGET_DISK"
wipefs -af "$TARGET_DISK"
parted -s "$TARGET_DISK" mklabel gpt
parted -s "$TARGET_DISK" mkpart ESP fat32 1MiB 1025MiB
parted -s "$TARGET_DISK" set 1 esp on
parted -s "$TARGET_DISK" mkpart primary btrfs 1025MiB 100%
partprobe "$TARGET_DISK"
udevadm settle

printf '==> Formatting filesystems\n'
mkfs.fat -F 32 "$EFI_PART"
mkfs.btrfs -f "$ROOT_PART"

mount "$ROOT_PART" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt

mount -o noatime,compress=zstd,subvol=@ "$ROOT_PART" /mnt
mkdir -p /mnt/boot /mnt/home
mount -o noatime,compress=zstd,subvol=@home "$ROOT_PART" /mnt/home
mount "$EFI_PART" /mnt/boot

packages=(
    base
    linux
    linux-firmware
    btrfs-progs
    networkmanager
    sudo
    vim
    git
    openssh
    mesa
    xorg-xwayland
    hyprland
    kitty
    waybar
    rofi-wayland
    thunar
    dunst
    pipewire
    pipewire-pulse
    wireplumber
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    greetd
    greetd-tuigreet
    polkit-gnome
    grim
    slurp
    wl-clipboard
    xdg-user-dirs
    noto-fonts
    noto-fonts-emoji
    ttf-jetbrains-mono-nerd
    dbus-broker
    cliphist
    brightnessctl
    playerctl
    pavucontrol
    firefox
    swaybg
    imagemagick
)

if [[ -n "$UCODE_PACKAGE" ]]; then
    packages+=("$UCODE_PACKAGE")
fi

printf '==> Installing base system\n'
pacstrap -K /mnt "${packages[@]}"
genfstab -U /mnt >> /mnt/etc/fstab

if [[ "$USE_LOCAL_PAYLOAD" == "YES" && -d "$SCRIPT_DIR/ctfbox-rice" ]]; then
    printf '==> Staging local repo payload from USB\n'
    cp -a "$SCRIPT_DIR/ctfbox-rice" /mnt/root/ctfbox-rice-payload
fi

arch-chroot /mnt /usr/bin/env \
    HOSTNAME="$HOSTNAME" \
    USERNAME="$USERNAME" \
    PASSWORD="$PASSWORD" \
    TIMEZONE="$TIMEZONE" \
    LOCALE="$LOCALE" \
    KEYMAP="$KEYMAP" \
    REPO_URL="$REPO_URL" \
    ROOT_PART="$ROOT_PART" \
    FORCE_SOFTWARE_RENDERING="$FORCE_SOFTWARE_RENDERING" \
    /bin/bash <<'CHROOT'
set -euo pipefail

ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

grep -q "^${LOCALE} UTF-8$" /etc/locale.gen || printf '%s UTF-8\n' "$LOCALE" >> /etc/locale.gen
sed -i "s/^#${LOCALE} UTF-8/${LOCALE} UTF-8/" /etc/locale.gen
locale-gen
printf 'LANG=%s\n' "$LOCALE" > /etc/locale.conf
printf 'KEYMAP=%s\n' "$KEYMAP" > /etc/vconsole.conf
printf '%s\n' "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1 localhost
127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

bootctl install
ROOT_UUID="$(blkid -s UUID -o value "$ROOT_PART")"

ucode_entry=""
if [[ -f /boot/intel-ucode.img ]]; then
    ucode_entry="initrd  /intel-ucode.img"
elif [[ -f /boot/amd-ucode.img ]]; then
    ucode_entry="initrd  /amd-ucode.img"
fi

cat > /boot/loader/loader.conf <<'EOF'
default arch.conf
timeout 3
editor no
EOF

cat > /boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
${ucode_entry}
initrd  /initramfs-linux.img
options root=UUID=${ROOT_UUID} rootflags=subvol=@ rw
EOF

useradd -m -G wheel,video,input,audio,storage -s /bin/bash "$USERNAME"
echo "root:${PASSWORD}" | chpasswd
echo "${USERNAME}:${PASSWORD}" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

cat > /usr/local/bin/start-hyprland <<EOF
#!/bin/sh
if [ "${FORCE_SOFTWARE_RENDERING}" = "YES" ]; then
  export LIBGL_ALWAYS_SOFTWARE=1
  export WLR_RENDERER_ALLOW_SOFTWARE=1
fi
exec dbus-run-session Hyprland
EOF
chmod +x /usr/local/bin/start-hyprland

if [[ -d /root/ctfbox-rice-payload ]]; then
    mv /root/ctfbox-rice-payload "/home/${USERNAME}/ctfbox-rice"
else
    git clone --depth 1 "$REPO_URL" "/home/${USERNAME}/ctfbox-rice"
fi

chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/ctfbox-rice"
chmod +x "/home/${USERNAME}/ctfbox-rice/scripts/"*.sh

install -d -m 755 "/home/${USERNAME}/.config"
cp -a "/home/${USERNAME}/ctfbox-rice/dots/hypr" "/home/${USERNAME}/.config/"
cp -a "/home/${USERNAME}/ctfbox-rice/dots/waybar" "/home/${USERNAME}/.config/"
cp -a "/home/${USERNAME}/ctfbox-rice/dots/rofi" "/home/${USERNAME}/.config/"

install -d -m 755 "/home/${USERNAME}/.config/ctfbox"
printf '/home/%s/ctfbox-rice/assets/wallpaper.jpg\n' "$USERNAME" > "/home/${USERNAME}/.config/ctfbox/current-wallpaper"
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/.config"

runuser -u "$USERNAME" -- xdg-user-dirs-update

cat > /etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --cmd /usr/local/bin/start-hyprland"
user = "greeter"
EOF

systemctl enable NetworkManager greetd systemd-timesyncd sshd
CHROOT

umount -R /mnt

if [[ "$AUTO_REBOOT" == "YES" ]]; then
    printf '==> Install complete, rebooting\n'
    reboot
else
    printf '==> Install complete. Reboot manually when ready.\n'
fi
