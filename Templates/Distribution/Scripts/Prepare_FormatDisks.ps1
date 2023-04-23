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

# -----------------------------------------------------------
# Generate a Configuration Object
# -----------------------------------------------------------
$Configuration = [Configuration]::LoadNDKConfiguration()

# -----------------------------------------------------------
# Grab details about disks on the system
# -----------------------------------------------------------
$DiskDetails = Get-Disk

# -----------------------------------------------------------
# Verify disk meets requirements
# -----------------------------------------------------------

# Get the correct disk. 
$ChosenDisk = $DiskDetails | Where-Object {$_.Number -eq $Configuration.DriveIndex}

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
