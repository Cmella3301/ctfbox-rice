#!/usr/bin/env bash
set -euo pipefail

backup_root="$HOME/ctfbox-rice/.backups"
timestamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$backup_root/$timestamp"

mkdir -p "$backup_dir"

copy_if_exists() {
    local path="$1"

    if [[ -e "$path" ]]; then
        cp -a "$path" "$backup_dir/"
        echo "Backed up: $path"
    else
        echo "Skipped missing: $path"
    fi
}

copy_if_exists "$HOME/.config/hypr"
copy_if_exists "$HOME/.config/waybar"
copy_if_exists "$HOME/.config/kitty"
copy_if_exists "$HOME/.config/rofi"

echo "Backup complete: $backup_dir"
