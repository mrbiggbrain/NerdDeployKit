Write-Host "
-----------------------------------------------------------
# Preparing Deployment Environment
-----------------------------------------------------------"
& $PSScriptRoot\Database_GenerateDatabase.ps1

Write-Host "
-----------------------------------------------------------
# Partition & Format Disks
-----------------------------------------------------------"
& $PSScriptRoot\Prepare_FormatDisks.ps1



