Write-Host "
-----------------------------------------------------------
# Partition & Format Disks
-----------------------------------------------------------"
& $PSScriptRoot\Prepare_FormatDisks.ps1

Write-Host "
-----------------------------------------------------------
# Write WIM file to disk
-----------------------------------------------------------"
& $PSScriptRoot\Image_ApplyImage.ps1
