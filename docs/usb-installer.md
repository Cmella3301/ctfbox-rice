# Nova USB Installer

This repo now includes a bare-metal Arch installer flow for laptops and PCs.

## What It Does

- boots from the official Arch ISO
- partitions a target disk for UEFI + Btrfs
- installs Arch, Hyprland, Waybar, Rofi, Firefox, and the current Nova rice
- copies the repo payload onto the installed machine
- seeds the default wallpaper and wallpaper chooser
- lands at a `greetd` login that starts Hyprland

## Important Safety Rule

The installer is destructive. It will repartition the target disk.

It will only run when `CONFIRM_DESTROY="YES"` is set in the config.

## Files

- `usb/nova-usb-install.sh`
  Main installer to run from the Arch live environment.
- `usb/nova-install.conf.example`
  Example config for hostname, username, password, timezone, and disk selection.
- `scripts/build-usb-payload.ps1`
  Windows helper that packages the repo and installer into a `nova-usb` payload folder.

## Build The Payload On Windows

From the repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-usb-payload.ps1 `
  -Hostname nova-arch `
  -Username mella `
  -Password "ChangeMe123!" `
  -Timezone "America/Toronto"
```

By default, that creates a payload in a sibling folder outside the repo:

- `..\ctfbox-rice-dist\nova-usb\`

If you want a zip too, add `-CreateZip`.

If you want a different output folder, pass `-OutputDir` explicitly.

## Put It On A Bootable USB

1. Flash the official Arch ISO to a USB drive.
2. Copy the generated `nova-usb` folder onto the readable filesystem of that USB.
   If your USB tool makes the ISO partition read-only, put `nova-usb` on a second FAT32 partition instead.

## Run The Install

Boot the target machine from the Arch USB, then run:

```bash
bash /run/archiso/bootmnt/nova-usb/nova-usb-install.sh /run/archiso/bootmnt/nova-usb/nova-install.conf
```

If the payload is mounted at a different path, adjust the path accordingly.

This is a one-command install after boot, not a remastered custom ISO. The Arch live system boots first, then the Nova installer takes over.

## Disk Selection

- If `TARGET_DISK` is blank and the machine has exactly one internal non-USB disk, the installer uses it automatically.
- If there is more than one internal disk, the installer stops and asks you to set `TARGET_DISK` explicitly in the config.

## Output

After install, the machine has:

- Arch Linux on Btrfs
- `greetd` + Hyprland
- Nova top bar + dock
- Rofi launcher
- wallpaper chooser
- Firefox
- the `ctfbox-rice` repo under `/home/<user>/ctfbox-rice`
