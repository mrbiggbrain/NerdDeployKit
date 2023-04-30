Write-Host "
-----------------------------------------------------------
# Partition & Format Disks
-----------------------------------------------------------"
& $PSScriptRoot\Prepare_FormatDisks.ps1

Write-Host "
-----------------------------------------------------------
# Write WIM file to disk (OS)
-----------------------------------------------------------"
& $PSScriptRoot\Image_ApplyImage.ps1

Write-Host "
-----------------------------------------------------------
# Write WIM file to disk (Recovery)
-----------------------------------------------------------"
& $PSScriptRoot\Image_ApplyRecovery.ps1

Write-Host "
-----------------------------------------------------------
# Update boot details
-----------------------------------------------------------"
& $PSScriptRoot\Image_ApplyBCDSettings.ps1

