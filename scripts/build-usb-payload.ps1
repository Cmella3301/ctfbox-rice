param(
    [string]$OutputDir = "",
    [string]$Hostname = "nova-arch",
    [string]$Username = "mella",
    [string]$Password = "ChangeMe123!",
    [string]$Timezone = "America/Toronto",
    [string]$Locale = "en_US.UTF-8",
    [string]$Keymap = "us",
    [string]$TargetDisk = "",
    [ValidateSet("YES", "NO")]
    [string]$ConfirmDestroy = "NO",
    [ValidateSet("YES", "NO")]
    [string]$AutoReboot = "YES",
    [ValidateSet("YES", "NO")]
    [string]$ForceSoftwareRendering = "NO",
    [switch]$CreateZip
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$usbRoot = Join-Path $repoRoot "usb"

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path (Split-Path -Parent $repoRoot) "ctfbox-rice-dist"
}

$repoRootFull = [System.IO.Path]::GetFullPath($repoRoot)
$outputFull = [System.IO.Path]::GetFullPath($OutputDir)
$repoRootPrefix = $repoRootFull.TrimEnd('\') + '\'
if ($outputFull.StartsWith($repoRootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "OutputDir must be outside the repo root to avoid recursive payload copies."
}

$payloadRoot = Join-Path $OutputDir "nova-usb"

if (Test-Path $payloadRoot) {
    Remove-Item -LiteralPath $payloadRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $payloadRoot | Out-Null

Copy-Item -LiteralPath (Join-Path $usbRoot "nova-usb-install.sh") -Destination $payloadRoot
Copy-Item -LiteralPath (Join-Path $usbRoot "nova-install.conf.example") -Destination $payloadRoot

$repoName = Split-Path -Leaf $repoRoot
$repoPayload = Join-Path $payloadRoot $repoName
New-Item -ItemType Directory -Path $repoPayload | Out-Null

$copyItems = @(
    "assets",
    "docs",
    "dots",
    "scripts",
    "README.md",
    "CHANGELOG.md"
)

foreach ($item in $copyItems) {
    $source = Join-Path $repoRoot $item
    $destination = Join-Path $repoPayload $item

    if (Test-Path $source -PathType Container) {
        New-Item -ItemType Directory -Force -Path $destination | Out-Null
        robocopy $source $destination /E /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -gt 3) {
            throw "robocopy failed while copying $item"
        }
    }
    else {
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }
}

$configPath = Join-Path $payloadRoot "nova-install.conf"
@"
CONFIRM_DESTROY="$ConfirmDestroy"
TARGET_DISK="$TargetDisk"
HOSTNAME="$Hostname"
USERNAME="$Username"
PASSWORD="$Password"
TIMEZONE="$Timezone"
LOCALE="$Locale"
KEYMAP="$Keymap"
USE_LOCAL_PAYLOAD="YES"
REPO_URL="https://github.com/Cmella3301/ctfbox-rice.git"
AUTO_REBOOT="$AutoReboot"
FORCE_SOFTWARE_RENDERING="$ForceSoftwareRendering"
"@ | Set-Content -Path $configPath

$startHere = Join-Path $payloadRoot "START-HERE.txt"
@"
Nova USB Installer Payload
==========================

1. Flash the official Arch ISO to a USB drive.
2. Copy this entire 'nova-usb' folder onto that USB in ISO mode, or onto a second
   readable partition on the same USB.
3. Boot the target PC or laptop from the Arch USB.
4. From the live shell, run:

   bash /run/archiso/bootmnt/nova-usb/nova-usb-install.sh /run/archiso/bootmnt/nova-usb/nova-install.conf

If your payload is mounted somewhere else, adjust the path to match that mount point.
This installer is destructive and uses the values stored in nova-install.conf.
"@ | Set-Content -Path $startHere

Write-Host "Created USB payload:"
Write-Host " - $payloadRoot"

if ($CreateZip) {
    $zipPath = Join-Path $OutputDir "nova-usb-payload.zip"
    if (Test-Path $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }
    Compress-Archive -Path $payloadRoot -DestinationPath $zipPath
    Write-Host " - $zipPath"
}
