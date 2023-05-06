# -----------------------------------------------------------
# Image_ApplyImage.ps1 - Applies WIM images
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Add external librarys
# -----------------------------------------------------------
using module .\Logging_Logging.psm1

# -----------------------------------------------------------
# Load chosen settings from JSON file
# -----------------------------------------------------------
[Logging]::Informational("Loading deployment options.")
$JsonData = Get-Content $ENV:SystemDrive\NDK\Deploy.json | ConvertFrom-Json

# -----------------------------------------------------------
# Determine a few paths
# -----------------------------------------------------------
$OSDrive = $JsonData.Partitioning.DriveLetters.OS
$SystemDrive = $JsonData.Partitioning.DriveLetters.System
$OfflineWinDir = "$($OSDrive):\Windows"
$SystemRoot = "$($SystemDrive):"

# -----------------------------------------------------------
# Apply BCD Settings
# -----------------------------------------------------------
[Logging]::Informational("Applying boot files to system drive.")
bcdboot.exe "$OfflineWinDir" /s "$SystemRoot"