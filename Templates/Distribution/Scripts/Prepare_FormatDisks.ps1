# -----------------------------------------------------------
# Prepare_Format.ps1 - Partition, Format, and Prepare Disks for Imaging
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
# Generate a logger to use
# -----------------------------------------------------------
$logger = [Logger]::new()

# -----------------------------------------------------------
# Generate a program scope to use
# -----------------------------------------------------------
$pscope = [ProgramScope]::new()

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

$diskVerificationStatus = CheckDiskRequirements -DiskDetails $ChosenDisk

if($diskVerificationStatus -ne 0)
{
    $logger.WriteError("Disk verification failed with code $($diskVerificationStatus).")
    $pscope.FailProvision("VERIFY_DISK", $diskVerificationStatus)
}

# -----------------------------------------------------------
# Partition Disk
# -----------------------------------------------------------
$partitionDetails = PartitionDisk -DiskNumber $ChosenDisk.DiskNumber -FirmwareType $Configuration.FirmwareType

# -----------------------------------------------------------
# Format Disks
# -----------------------------------------------------------
$volumeDetails = FormatPartitions -PartitionDetails $partitionDetails -FirmwareType $Configuration.FirmwareType

# -----------------------------------------------------------
# Save Deployment State
# -----------------------------------------------------------
$pscope.SavePartitions($partitionDetails)
$pscope.SaveVolumes($volumeDetails)