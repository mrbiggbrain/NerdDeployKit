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
using module ..\Bin\AMD64\sqlite\System.Data.SQLite.dll

# -----------------------------------------------------------
# Grab details about disks on the system
# -----------------------------------------------------------
[Logging]::Informational("Gathering details.")
$ChosenDisk = Get-Disk -Number ([NDKConfig]::InstallDisk)

# -----------------------------------------------------------
# Verify disk meets requirements
# -----------------------------------------------------------
[Logging]::Informational("Checking storage requirements.")

$diskVerificationStatus = CheckDiskRequirements -DiskDetails $ChosenDisk

if($diskVerificationStatus -ne 0)
{
    [Logging]::Error("Disk verification failed with code $($diskVerificationStatus).")
    throw([Errors]::FAILED_VERIFICATION_ERROR)
}

# -----------------------------------------------------------
# Partition Disk
# -----------------------------------------------------------
[Logging]::Informational("Partitioning Disks.")
$partitionDetails = PartitionDisk -DiskNumber $ChosenDisk.DiskNumber -FirmwareType ([NDKConfig]::FirmwareType)

# -----------------------------------------------------------
# Format Disks
# -----------------------------------------------------------
[Logging]::Informational("Formatting newly created partitions.")
$volumeDetails = FormatPartitions -PartitionDetails $partitionDetails -FirmwareType ([NDKConfig]::FirmwareType)

# -----------------------------------------------------------
# Connect to database
# -----------------------------------------------------------
[Logging]::Informational("Connecting to database.")
$DBConnection = [SQLiteDB]::ConnectDB([NDKConfig]::DeployDBFilePath);

# -----------------------------------------------------------
# Save Data to the database
# -----------------------------------------------------------
[Logging]::Informational("Saving partition details.")

# -----------------------------------------------------------
# Save recovery partition
# -----------------------------------------------------------
$Part = [Partition]::new($volumeDetails.RecoveryVolume, "Recovery")
$Part.Type = "Basic"
[PartitionsTable]::AddPartition($DBConnection, $part)

# -----------------------------------------------------------
# Save OS partition
# -----------------------------------------------------------
$Part = [Partition]::new($volumeDetails.OSVolume, "Basic")
$Part.Type = "Basic"
[PartitionsTable]::AddPartition($DBConnection, $part)

# -----------------------------------------------------------
# Save system partition
# -----------------------------------------------------------
$Part = [Partition]::new($volumeDetails.SystemVolume, "System")
$Part.Type = "Basic"
[PartitionsTable]::AddPartition($DBConnection, $part)

# -----------------------------------------------------------
# Close the DB
# -----------------------------------------------------------
[Logging]::Informational("Closing DB connection.")
[SQLiteDB]::CloseDB($DBConnection)