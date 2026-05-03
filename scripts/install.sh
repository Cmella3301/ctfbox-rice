#!/usr/bin/env bash
set -euo pipefail

echo "==> ctfbox-rice package install starting"

packages=(
  git
  base-devel
  swaybg
  rofi-wayland
  waybar
  dunst
  wl-clipboard
  cliphist
  brightnessctl
  playerctl
  pavucontrol
  firefox
  ttf-jetbrains-mono-nerd
  noto-fonts-emoji
  imagemagick
)

echo "==> Installing packages:"
printf ' - %s\n' "${packages[@]}"

sudo pacman -S --needed --noconfirm "${packages[@]}"

echo "==> Package install complete"

"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/backup.sh"
"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/apply-dotfiles.sh"

echo "==> ctfbox-rice theme install complete"
