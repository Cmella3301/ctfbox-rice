#!/usr/bin/env bash

# Source this from interactive bash shells. It only shows in Kitty when the
# red-moon wallpaper is the active selection.

if [[ $- != *i* ]]; then
    return 0 2>/dev/null || exit 0
fi

if [[ -n "${SSH_CONNECTION:-}" || -n "${SSH_TTY:-}" ]]; then
    return 0 2>/dev/null || exit 0
fi

if [[ "${TERM:-}" != "xterm-kitty" ]]; then
    return 0 2>/dev/null || exit 0
fi

if [[ "${NOVA_KITTY_INTRO_SHOWN:-0}" == "1" ]]; then
    return 0 2>/dev/null || exit 0
fi

config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
state_file="$config_root/ctfbox/current-wallpaper"
intro_image="$config_root/ctfbox/assets/terminal/red-moon-emblem.png"
target_wallpaper="wallhaven-kx3l21_1920x1080.png"

if [[ ! -f "$state_file" ]]; then
    return 0 2>/dev/null || exit 0
fi

current_wallpaper="$(basename "$(tr -d '\r\n' < "$state_file")")"
if [[ "$current_wallpaper" != "$target_wallpaper" ]]; then
    return 0 2>/dev/null || exit 0
fi

export NOVA_KITTY_INTRO_SHOWN=1

printf '\n'
if command -v kitten >/dev/null 2>&1 && [[ -f "$intro_image" ]]; then
    kitten icat --align left --stdin=no "$intro_image" 2>/dev/null || true
fi

printf '\n'
printf '\033[38;2;226;68;68m%s\033[0m\n' "Knowledge and awareness are vague,"
printf '\033[38;2;226;68;68m%s\033[0m\n\n' "and perhaps better called illusions."
