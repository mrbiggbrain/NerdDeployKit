# -----------------------------------------------------------
# Utility_DiskUtility.psm1 - Utilities used for disk management
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Include Librarys
# -----------------------------------------------------------
using module .\Utility_DiskUtility.psm1

# -----------------------------------------------------------
# Data Class (Partitions)
# -----------------------------------------------------------
class PartitionDetails
{
    $RecoveryPartition
    $SystemPartition
    $ReservedPartition
    $OSPartition
}

# -----------------------------------------------------------
# Data Class (Filesystems)
# -----------------------------------------------------------
class VolumneDetails
{
    $RecoveryVolume
    $SystemVolume
    $OSVolume
}

# -----------------------------------------------------------
# Partition Disks
# -----------------------------------------------------------
function PartitionDisk
{
    param(
        [Parameter(Mandatory=$true)][int] $DiskNumber,
        [Parameter(Mandatory=$true)][string] $FirmwareType
    )

    if($FirmwareType -eq "UEFI") { 
        PartitionDiskUEFI -DiskNumber $DiskNumber
        return
    }
    elseif($FirmwareType -eq "BIOS") {
        PartitionDiskBIOS -DiskNumber $DiskNumber
        return
    }
}

# -----------------------------------------------------------
# Partition UEFI Disks
# -----------------------------------------------------------
function PartitionDiskUEFI
{
    param(
        [Parameter(Mandatory=$true)][int] $DiskNumber
    )

    # Load Drive Mappings
    $driveMappings = [DriveLetterMappingConfiguration]::LoadDriveLetterMappingConfiguration()

    # Generate a class instance to hold our returned data
    $details = [PartitionDetails]::new()

    # Grab some disk details
    $disk = Get-Disk -Number $DiskNumber

    # Determine size of OS drive
    $osDiskSize = $disk.Size - $disk.AllocatedSize - 1024MB

    # Clear the Disk
    Clear-Disk -Number $DiskNumber -Removedata -Confirm:$false

    # Generate EFI partition
    $details.SystemPartition = New-Partition -DiskNumber $DiskNumber -Size 499MB -DriveLetter $driveMappings.System

    # Generate reserved partition
    $details.ReservedPartition = New-Partition -DiskNumber $DiskNumber -Size 16MB

    # Generate OS Partition
    $details.OSPartition = New-Partition -DiskNumber $DiskNumber -DriveLetter $driveMappings.OS -Size $osDiskSize

    # Generate recovery partition
    $details.RecoveryPartition = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -DriveLetter $driveMappings.Recovery

    # Return details on the partitions
    return $details
}

# -----------------------------------------------------------
# Partition BIOS Disks
# -----------------------------------------------------------
function PartitionDiskBIOS
{
    param(
        [Parameter(Mandatory=$true)][int] $DiskNumber
    )

    throw "NDK Does not currently support deploying to BIOS firmware."
}

# -----------------------------------------------------------
# Format Partitions
# -----------------------------------------------------------
function FormatPartitions
{
    param(
        [Parameter(Mandatory=$true)][PartitionDetails] $PartitionDetails,
        [Parameter(Mandatory=$true)][string] $FirmwareType
    )

    if($FirmwareType -eq "UEFI") { 
        FormatPartitionsUEFI -PartitionDetails $PartitionDetails 
        return
    }
    elseif($FirmwareType -eq "BIOS") {
        FormatPartitionsBIOS -PartitionDetails $PartitionDetails
        return
    }
}

# -----------------------------------------------------------
# Format Partitions (UEFI)
# -----------------------------------------------------------
function FormatPartitionsUEFI
{
    param(
        [Parameter(Mandatory=$true)][PartitionDetails] $PartitionDetails
    ) 

    # Generate a new class instance to store results. 
    $volumes = [VolumneDetails]::new()

    # Recovery 
    $volumes.RecoveryVolume = $PartitionDetails.RecoveryPartition | Format-Volume -FileSystem NTFS -FileSystemLabel "Recovery"

    # Boot
    $volumes.SystemVolume = $PartitionDetails.SystemPartition | Format-Volume -FileSystem FAT32 -FileSystemLabel "System"

    # OS
    $volumes.OSVolume = $PartitionDetails.OSPartition | Format-Volume -FileSystem NTFS -FileSystemLabel "OS"

    # Return results
    return $volumes
}

# -----------------------------------------------------------
# Format Partitions (BIOS)
# -----------------------------------------------------------
function FormatPartitionsBIOS
{
    param(
        [Parameter(Mandatory=$true)][PartitionDetails] $PartitionDetails
    )

    throw "NDK Does not currently support deploying to BIOS firmware."
}