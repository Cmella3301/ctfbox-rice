#!/usr/bin/env bash
set -euo pipefail

target_dir="$HOME/ctfbox-rice/assets/wallpapers"
source_dir="$HOME/lavarch-review/configs/.wallpapers"

mkdir -p "$target_dir"

if [[ -f "$HOME/ctfbox-rice/assets/wallpaper.jpg" ]]; then
    cp -f "$HOME/ctfbox-rice/assets/wallpaper.jpg" "$target_dir/arch-magenta-blue-1920x1080.png"
fi

if [[ -d "$source_dir" ]]; then
    for name in \
        arch-black-4k.png \
        arch-magenta-blue-1920x1080.png \
        arch-magenta-pink-1920x1080.png \
        arch-wallpaper.jpg \
        perfect-blue.jpg \
        hollow-knight-white.jpg
    do
        if [[ -f "$source_dir/$name" ]]; then
            cp -f "$source_dir/$name" "$target_dir/$name"
        fi
    done
fi

find "$target_dir" -maxdepth 1 -type f | sort
