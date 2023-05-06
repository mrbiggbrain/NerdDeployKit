# -----------------------------------------------------------
# Image_ApplyAnswerFile.ps1 - Copies answer files
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Include Librarys
# -----------------------------------------------------------
using module .\Logging_Logging.psm1

# -----------------------------------------------------------
# Load chosen settings from JSON file
# -----------------------------------------------------------
[Logging]::Informational("Loading deployment options.")
$JsonData = Get-Content $ENV:SystemDrive\NDK\Deploy.json | ConvertFrom-Json

# -----------------------------------------------------------
# Determine the correct paths
# -----------------------------------------------------------
[Logging]::Informational("Determine Paths.")
$ParentDirectory = Split-Path -Path $PSScriptRoot -Parent
$UnattendFile = "$ParentDirectory\Unattend\Unattend_x64.xml"
$OSDrive = $JsonData.Partitioning.DriveLetters.OS
$DestinationFolder = "$($OSDrive):\Windows\Panther"
$DestinationFile = "$($DestinationFolder)\Unattend.xml"

# -----------------------------------------------------------
# Create folder if needed.
# -----------------------------------------------------------
[Logging]::Informational("Checking for Panther folder.")
if(-not (Test-Path $DestinationFolder))
{
    [Logging]::Informational("Creating Panther folder.")
    New-Item -Path $DestinationFolder -ItemType Directory
}

# -----------------------------------------------------------
# Copy the Unattended.xml file.
# -----------------------------------------------------------
[Logging]::Informational("Copy unattend.xml")
Copy-Item -LiteralPath $UnattendFile -Destination $DestinationFile