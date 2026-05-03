# Changelog

## 2026-05-02

### Added

- top floating Waybar layout inspired by the Kronos-style screenshot
- bottom dock-style Waybar app strip for launcher, Firefox, files, terminal, and wallpapers
- dedicated `dots/rofi/launcher.rasi` for a darker searchable app launcher
- refreshed wallpaper chooser theme to match the launcher palette
- `scripts/apply-dotfiles.sh` to deploy Hyprland, Waybar, and Rofi files into `~/.config`
- local wallpaper library under `assets/wallpapers/` with Nova-ready imports
- live wallpaper apply flow backed by `swaybg`
- `usb/nova-usb-install.sh` for bare-metal Arch installs from a boot USB
- `scripts/build-usb-payload.ps1` to package the repo and installer for a USB payload

### Changed

- upgraded `dots/hypr/hyprland.conf` to use the launcher theme, wallpaper chooser binding, softer gaps, and stronger borders
- updated `scripts/install.sh` to install bar, Firefox, and launcher dependencies, run backups, and deploy the theme
- updated wallpaper scripts to resolve repo paths dynamically instead of assuming a single hardcoded layout
- expanded `scripts/backup.sh` to capture the Rofi config too
- swapped the dock browser launcher from Edge to Firefox for the Nova setup
- replaced the static center bar label with a focused-window title module
- tightened the wallpaper chooser so it behaves like a cleaner image gallery instead of a filename list

### Notes

- the repo is now the source of truth for the visual rice instead of only the live VM state
- live Wayland UI restarts still need to happen from the Hyprland session, not from plain SSH
