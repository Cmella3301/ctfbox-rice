# ctfbox-rice

One-command Arch Linux Hyper-V Hyprland demo box and rice installer.

## Goal

This repo is for turning `Demo-CTFBox` into a showable Arch demo that can be pulled from GitHub and applied with a simple install command.

## Planned Shape

- `scripts/install.sh`
  Installer entrypoint for packages, config backup, and dotfile deployment.
- `scripts/backup.sh`
  Saves the current user config before we replace anything.
- `dots/`
  Hyprland, Waybar, Kitty, Rofi, and related config files.
- `assets/`
  Wallpapers and theme assets used by the rice.
- `docs/`
  Notes on setup, dependencies, and the demo flow.

## First Target

Recreate the Reddit-inspired Hyprland look with:

- a stronger bar style
- a launcher theme
- a dock
- polished Kitty styling
- optional live wallpaper later

## Status

Repo scaffold created on April 30, 2026.
