#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
state_dir="$config_root/ctfbox"
state_file="$state_dir/current-wallpaper"
default_wallpaper="$repo_root/assets/wallpaper.jpg"
bash_hook='[[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/ctfbox/kitty-intro.sh" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/ctfbox/kitty-intro.sh"'

mkdir -p "$config_root/hypr" "$config_root/waybar" "$config_root/rofi" "$config_root/kitty" "$state_dir/assets/terminal"

cp "$repo_root/dots/hypr/hyprland.conf" "$config_root/hypr/hyprland.conf"
cp "$repo_root/dots/waybar/config.jsonc" "$config_root/waybar/config.jsonc"
cp "$repo_root/dots/waybar/style.css" "$config_root/waybar/style.css"
cp "$repo_root/dots/rofi/launcher.rasi" "$config_root/rofi/launcher.rasi"
cp "$repo_root/dots/rofi/wallpaper.rasi" "$config_root/rofi/wallpaper.rasi"
cp "$repo_root/dots/kitty/kitty-intro.sh" "$state_dir/kitty-intro.sh"
cp "$repo_root/assets/terminal/red-moon-emblem.png" "$state_dir/assets/terminal/red-moon-emblem.png"
chmod +x "$state_dir/kitty-intro.sh"

if [[ -f "$HOME/.bashrc" ]]; then
    if ! grep -Fqx "$bash_hook" "$HOME/.bashrc"; then
        printf '\n%s\n' "$bash_hook" >> "$HOME/.bashrc"
    fi
else
    printf '%s\n' "$bash_hook" > "$HOME/.bashrc"
fi

if [[ ! -f "$state_file" && -f "$default_wallpaper" ]]; then
    printf '%s\n' "$default_wallpaper" > "$state_file"
fi

echo "==> Dotfiles copied to $config_root"

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    hyprctl reload >/tmp/hyprctl-reload.log 2>&1 || true
    pkill waybar 2>/dev/null || true
    nohup waybar >/tmp/waybar.log 2>&1 &
    nohup "$repo_root/scripts/launch-swaybg.sh" >/tmp/swaybg.log 2>&1 &
    echo "==> Live session refreshed"
else
    echo "==> No live Wayland session detected; log out and back in to apply the full theme"
fi
