# -----------------------------------------------------------
# Image_Migration.ps1 - Migrate required files
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Import Libraries
# -----------------------------------------------------------
using module .\Logging_Logging.psm1

# -----------------------------------------------------------
# Load chosen settings from JSON file
# -----------------------------------------------------------
[Logging]::Informational("Loading deployment options.")
$JsonData = Get-Content $ENV:SystemDrive\NDK\Deploy.json | ConvertFrom-Json

# -----------------------------------------------------------
# Copy the NDK Folder. 
# -----------------------------------------------------------
[Logging]::Informational("Migrating Deployment State")
$NDKFolder = "$($ENV:SystemDrive)\NDK"
$OSRoot = "$($JsonData.Partitioning.DriveLetters.OS):"
Copy-Item -LiteralPath $NDKFolder -Destination $OSRoot -Recurse -Force

# -----------------------------------------------------------
# Migrate Scripts
# -----------------------------------------------------------
[Logging]::Informational("Copying Scripts.")
$MigratedNDKFolder = "$($OSRoot)\NDK"
Copy-Item -LiteralPath $PSScriptRoot -Destination $MigratedNDKFolder -Recurse -Force