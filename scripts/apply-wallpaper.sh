#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "usage: $0 /full/path/to/wallpaper" >&2
    exit 2
fi

wallpaper="$1"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ctfbox"
state_file="$config_dir/current-wallpaper"

if [[ ! -f "$wallpaper" ]]; then
    echo "Wallpaper not found: $wallpaper" >&2
    exit 1
fi

mkdir -p "$config_dir"
printf '%s\n' "$wallpaper" > "$state_file"

pkill swaybg 2>/dev/null || true
nohup swaybg -i "$wallpaper" -m fill >/tmp/swaybg-live.log 2>&1 &
