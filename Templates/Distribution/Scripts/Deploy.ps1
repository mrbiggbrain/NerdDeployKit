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
# Update boot details
-----------------------------------------------------------"
& $PSScriptRoot\Image_ApplyBCDSettings.ps1

Write-Host "
-----------------------------------------------------------
# Inject Drivers
-----------------------------------------------------------"
& $PSScriptRoot\Drivers_InjectDrivers.ps1

Write-Host "
-----------------------------------------------------------
# Apply Unattended.xml file
-----------------------------------------------------------"
& $PSScriptRoot\Image_ApplyAnswerFile.ps1

Write-Host "
-----------------------------------------------------------
# Set proper partition types
-----------------------------------------------------------"
# & $PSScriptRoot\Prepare_SetPartitionTypes.ps1
