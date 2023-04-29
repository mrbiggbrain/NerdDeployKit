# -----------------------------------------------------------
# Prepare_Format.ps1 - Partition, Format, and Prepare Disks for Imaging
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Import Libraries
# -----------------------------------------------------------
using module .\Utility_DiskUtility.psm1
using module .\Logging_Logging.psm1
using module .\Config_NDKConfig.psm1
using module .\Database_DataAccess.psm1

# -----------------------------------------------------------
# Grab details about disks on the system
# -----------------------------------------------------------
$ChosenDisk = Get-Disk -Number ([NDKConfig]::InstallDisk)

# -----------------------------------------------------------
# Verify disk meets requirements
# -----------------------------------------------------------

$diskVerificationStatus = CheckDiskRequirements -DiskDetails $ChosenDisk

if($diskVerificationStatus -ne 0)
{
    [Logging]::Error("Disk verification failed with code $($diskVerificationStatus).")
    throw([Errors]::FAILED_VERIFICATION_ERROR)
}

# -----------------------------------------------------------
# Partition Disk
# -----------------------------------------------------------
$partitionDetails = PartitionDisk -DiskNumber $ChosenDisk.DiskNumber -FirmwareType ([NDKConfig]::FirmwareType)

# -----------------------------------------------------------
# Format Disks
# -----------------------------------------------------------
$volumeDetails = FormatPartitions -PartitionDetails $partitionDetails -FirmwareType ([NDKConfig]::FirmwareType)

# -----------------------------------------------------------
# Save Deployment State
# -----------------------------------------------------------
$DBConnection = [SQLiteDB]::ConnectDB($DBFile);
$Part = [Partition]::new($volumeDetails.RecoveryVolume)
[PartitionsTable]::AddPartition($DBConnection, $part)