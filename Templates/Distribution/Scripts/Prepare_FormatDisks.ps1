# -----------------------------------------------------------
# Prepare_Format.ps1 - Format and Prepare Disks for Imaging
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Import Libraries
# -----------------------------------------------------------
using module .\Gather_GatherConfiguration.psm1
using module .\Utility_GenericUtility.psm1
using module .\Utility_DiskUtility.psm1

# -----------------------------------------------------------
# Generate a Configuration Object
# -----------------------------------------------------------
$Configuration = [Configuration]::LoadNDKConfiguration()

# -----------------------------------------------------------
# Grab details about disks on the system
# -----------------------------------------------------------
$DiskDetails = Get-Disk

# -----------------------------------------------------------
# Get the correct disk. 
# -----------------------------------------------------------
$ChosenDisk = $DiskDetails | Where-Object {$_.Number -eq $Configuration.DriveIndex}

# -----------------------------------------------------------
# Verify disk meets requirements
# -----------------------------------------------------------

# Check if the disk is a Fixed Disk. 
if($ChosenDisk.ProvisioningType -ne "Fixed")
{
    # Log the failure and properly fail the provisioning.
    $err = "Requested Disk: {Disk Number: $($ChosenDisk.DiskNumber), Model: $($ChosenDisk.Model)} is of type $($ChosenDisk.ProvisioningType) but type FIXED is required."
    [Logger]::WriteError($err)
    [ProgramScope]::FailProvision($err)
}

# Check if Disk is Healthy
if($ChosenDisk.HealthStatus -ne "Healthy")
{
    # Log the failure and properly fail the provisioning.
    $err = "Requested Disk: {Disk Number: $($ChosenDisk.DiskNumber), Model: $($ChosenDisk.Model)} is not marked as healthy."
    [Logger]::WriteError($err)
    [ProgramScope]::FailProvision($err)
}

# Check if Disk is Online
if($ChosenDisk.OperationalStatus -ne "Online")
{
    # Log the failure and properly fail the provisioning.
    $err = "Requested Disk: {Disk Number: $($ChosenDisk.DiskNumber), Model: $($ChosenDisk.Model)} is not online."
    [Logger]::WriteError($err)
    [ProgramScope]::FailProvision($err)
}

# -----------------------------------------------------------
# Clear Disk
# -----------------------------------------------------------
Clear-Disk -Number $ChosenDisk.DiskNumber -Removedata -Confirm:$false

# -----------------------------------------------------------
# Partition Disk
# -----------------------------------------------------------

# Recovery
$RecoveryPartition = New-Partition -DiskNumber $ChosenDisk.DiskNumber -Size 499MB -DriveLetter R -IsHidden $true -GptType "{de94bba4-06d1-4d40-a16a-bfd50179d6ac}"

# EFI
$BootPartition = New-Partition -DiskNumber $ChosenDisk.DiskNumber -Size 499MB -DriveLetter E -IsHidden $true -GptType "{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"

# Reserved
$ReservedPartition = New-Partition -DiskNumber $ChosenDisk.DiskNumber -Size 16MB -IsHidden $true -GptType "{e3c9e316-0b5c-4db8-817d-f92df00215ae}"

# OS
$OSPartition = New-Partition -DiskNumber $ChosenDisk.DiskNumber -DriveLetter C -UseMaximumSize


# -----------------------------------------------------------
# Format Disks
# -----------------------------------------------------------

# Recovery 
Format-Volume –DriveLetter R -FileSystem NTFS -FileSystemLabel "Recovery"

# Boot
Format-Volume –DriveLetter E -FileSystem FAT32 -FileSystemLabel "Boot"

# OS
Format-Volume –DriveLetter C -FileSystem NTFS -FileSystemLabel "OS"