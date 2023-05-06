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
# Encrypt the password
# -----------------------------------------------------------
$PTPassword = $JsonData.Credentials.Administrator.Password
$PasswordHash = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($PTPassword))

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
#[Logging]::Informational("Copy unattend.xml")
#Copy-Item -LiteralPath $UnattendFile -Destination $DestinationFile

# -----------------------------------------------------------
# Load XML File
# -----------------------------------------------------------
[Logging]::Informational("Loading unattended.xml template")
$xml = [xml](Get-Content -Path $UnattendFile)



# -----------------------------------------------------------
# Deployment Stages
# -----------------------------------------------------------
$OOBE = $XML.unattend.settings | Where-Object {$_.Pass -eq "oobeSystem"}
$Specialize = $XML.unattend.settings | Where-Object {$_.Pass -eq "specialize"}

# -----------------------------------------------------------
# OOBE COmponents
# -----------------------------------------------------------
$ShellSetup_OOBE = $OOBE.component | Where-Object {$_.name -eq "Microsoft-Windows-Shell-Setup"}

# -----------------------------------------------------------
# Specialize COmponents
# -----------------------------------------------------------
$ShellSetup_Specialize = $Specialize.component | Where-Object {$_.name -eq "Microsoft-Windows-Shell-Setup"}

# -----------------------------------------------------------
# Modify Administrator Password
# -----------------------------------------------------------
[Logging]::Informational("Injecting administrator password")
$ShellSetup_OOBE.UserAccounts.AdministratorPassword.Value = $PasswordHash
$ShellSetup_OOBE.UserAccounts.AdministratorPassword.PlainText = "true"


# -----------------------------------------------------------
# Modify Autologon
# -----------------------------------------------------------
[Logging]::Informational("Injecting Autologon")
$ShellSetup_OOBE.AutoLogon.Password.Value = $PasswordHash
$ShellSetup_OOBE.AutoLogon.Password.PlainText = "true"

# -----------------------------------------------------------
# Modify TimeZone
# -----------------------------------------------------------
$ShellSetup_Specialize.TimeZone = $JsonData.TimeZone

# -----------------------------------------------------------
# Modify Product Key
# -----------------------------------------------------------
$ShellSetup_Specialize.ProductKey = $JsonData.ProductKey

# -----------------------------------------------------------
# Copy to Destination
# -----------------------------------------------------------
[Logging]::Informational("Saving unattend.xml")
$XML.Save($DestinationFile)