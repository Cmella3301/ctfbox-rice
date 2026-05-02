#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
wallpaper_dir="$repo_root/assets/wallpapers"
apply_script="$repo_root/scripts/apply-wallpaper.sh"
theme_file="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/wallpaper.rasi"

if [[ ! -d "$wallpaper_dir" ]]; then
    notify-send "Wallpaper chooser" "No wallpaper directory found at $wallpaper_dir"
    exit 1
fi

mapfile -d '' wallpapers < <(
    find "$wallpaper_dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -print0 | sort -z
)

if (( ${#wallpapers[@]} == 0 )); then
    notify-send "Wallpaper chooser" "No wallpapers found in $wallpaper_dir"
    exit 0
fi

list_wallpapers() {
    local file

    for file in "${wallpapers[@]}"; do
        # Use a blank label so the picker reads like a gallery instead of a file browser.
        printf ' \0icon\x1f%s\n' "$file"
    done
}

selection_index="$(
    list_wallpapers | rofi -dmenu -i -show-icons -format i -theme "$theme_file"
)"

if [[ -z "$selection_index" ]]; then
    exit 0
fi

if [[ ! "$selection_index" =~ ^[0-9]+$ ]] || (( selection_index < 0 || selection_index >= ${#wallpapers[@]} )); then
    notify-send "Wallpaper chooser" "Unexpected selection returned by Rofi"
    exit 1
fi

"$apply_script" "${wallpapers[$selection_index]}"
