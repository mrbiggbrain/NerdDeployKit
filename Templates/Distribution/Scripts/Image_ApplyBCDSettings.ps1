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
$RecoveryDrive = "$([NDKConfig]::RecoveryDriveLetter):"

# -----------------------------------------------------------
# Apply BCD Settings
# -----------------------------------------------------------
[Logging]::Informational("Applying boot files.")
bcdboot.exe "$OfflineWinDir" /s "$RecoveryDrive"