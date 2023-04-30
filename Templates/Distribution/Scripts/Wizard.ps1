# -----------------------------------------------------------
# Wizard.ps1 - Bootstraps Setup
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------
# NOTE: This component is a skeleton used for testing and
# is not the final version of the wizard
# -----------------------------------------------------------

Write-Host "
-----------------------------------------------------------
# Preparing Deployment Environment
-----------------------------------------------------------"
& $PSScriptRoot\Database_GenerateDatabase.ps1

Write-Host "
-----------------------------------------------------------
# Running Deployment Scripts
-----------------------------------------------------------"
& $PSScriptRoot\Deploy.ps1