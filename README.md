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

Theme baseline installed on May 2, 2026:

- top floating Waybar control bar
- bottom dock-style Waybar app strip
- dynamic focused-window title in the center bar
- Firefox dock launcher
- dedicated Rofi launcher theme
- wallpaper chooser theme refresh
- installer-backed dotfile deployment

## Quick Install

From inside the VM:

```bash
git clone https://github.com/Cmella3301/ctfbox-rice.git ~/ctfbox-rice
cd ~/ctfbox-rice
bash scripts/install.sh
```

## Wallpaper Chooser

- `Super + W` opens the wallpaper chooser.
- Wallpapers are loaded from `assets/wallpapers/`.
- The current selection is stored in `~/.config/ctfbox/current-wallpaper`.
- `scripts/seed-wallpapers.sh` can populate the wallpaper folder from a local `lavarch-review` clone.

## USB Install

This repo can also generate a payload for an Arch boot USB so you can install the Nova setup onto a laptop or desktop with one installer script after boot.

- Windows packager: `scripts/build-usb-payload.ps1`
- Live installer: `usb/nova-usb-install.sh`
- Docs: `docs/usb-installer.md`
- Default payload output: sibling folder `../ctfbox-rice-dist/nova-usb`
- Optional archive: add `-CreateZip` to the Windows packager
