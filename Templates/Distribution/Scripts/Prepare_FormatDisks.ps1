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
# Verify disk meets requirements
# -----------------------------------------------------------
[Logging]::Informational("Checking storage requirements.")

$diskVerificationStatus = CheckDiskRequirements

if($diskVerificationStatus -ne 0)
{
    [Logging]::Error("Disk verification failed with code $($diskVerificationStatus).")
    throw([Errors]::FAILED_VERIFICATION_ERROR)
}

# -----------------------------------------------------------
# Partition Disk
# -----------------------------------------------------------
[Logging]::Informational("Partitioning Disks.")
PartitionDisk

# -----------------------------------------------------------
# Format Disks
# -----------------------------------------------------------
[Logging]::Informational("Formatting newly created partitions.")
FormatPartitions