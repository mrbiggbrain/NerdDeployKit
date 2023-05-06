# -----------------------------------------------------------
# Image_ApplyImage.ps1 - Applies WIM images
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Add external librarys
# -----------------------------------------------------------
using module .\Config_NDKConfig.psm1
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

# -----------------------------------------------------------
# Write WIM
# -----------------------------------------------------------
[Logging]::Informational("Write WIM file to OS drive.")
Expand-WindowsImage -ImagePath $JsonData.Image.File -Index $JsonData.Image.Index -ApplyPath "$($OSDrive):\"