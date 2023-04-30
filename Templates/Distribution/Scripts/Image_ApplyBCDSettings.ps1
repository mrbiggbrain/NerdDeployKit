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
# Determine a few paths
# -----------------------------------------------------------
$OfflineWinDir = "$([NDKConfig]::OSDriveLetter):\Windows"
$SystemDrive = "$([NDKConfig]::SystemDriveLetter):"

# -----------------------------------------------------------
# Apply BCD Settings
# -----------------------------------------------------------
[Logging]::Informational("Applying boot files to system drive.")
bcdboot.exe "$OfflineWinDir" /s "$SystemDrive"