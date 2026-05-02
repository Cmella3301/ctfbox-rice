#!/usr/bin/env bash
set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ctfbox"
state_file="$config_dir/current-wallpaper"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
default_wallpaper="$repo_root/assets/wallpaper.jpg"
selected_wallpaper="$default_wallpaper"

if [[ -f "$state_file" ]]; then
    candidate="$(<"$state_file")"
    if [[ -f "$candidate" ]]; then
        selected_wallpaper="$candidate"
    fi
fi

pkill swaybg 2>/dev/null || true
exec swaybg -i "$selected_wallpaper" -m fill
