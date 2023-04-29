# -----------------------------------------------------------
# Utility_DiskUtility.psm1 - Utilities used for disk management
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Include Librarys
# -----------------------------------------------------------
using module .\Config_NDKConfig.psm1

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
        return PartitionDiskUEFI -DiskNumber $DiskNumber   
    }
    elseif($FirmwareType -eq "BIOS") {
        return PartitionDiskBIOS -DiskNumber $DiskNumber
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

    # Generate a class instance to hold our returned data
    $details = [PartitionDetails]::new()

    # Grab some disk details
    $disk = Get-Disk -Number $DiskNumber

    # Determine size of OS drive
    $osDiskSize = $disk.Size - 1024MB

    # Clear the Disk
    Clear-Disk -Number $DiskNumber -Removedata -Confirm:$false

    # Generate EFI partition
    $details.SystemPartition = New-Partition -DiskNumber $DiskNumber -Size 499MB -DriveLetter ([NDKConfig]::SystemDriveLetter)

    # Generate reserved partition
    $details.ReservedPartition = New-Partition -DiskNumber $DiskNumber -Size 16MB

    # Generate OS Partition
    $details.OSPartition = New-Partition -DiskNumber $DiskNumber -DriveLetter ([NDKConfig]::OSDriveLetter) -Size $osDiskSize

    # Generate recovery partition
    $details.RecoveryPartition = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -DriveLetter ([NDKConfig]::RecoveryDriveLetter)

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

    $PartitionDetails.RecoveryPartition.DriveLetter

    # Recovery 
    $volumes.RecoveryVolume = $PartitionDetails.RecoveryPartition | Format-Volume -FileSystem NTFS
    #$volumes.RecoveryVolume = Format-Volume -FileSystem NTFS -FileSystemLabel "Recovery" -DriveLetter ($PartitionDetails.RecoveryPartition.DriveLetter)
    

    # Boot
    $volumes.SystemVolume = $PartitionDetails.SystemPartition | Format-Volume -FileSystem FAT32
    
    # OS
    $volumes.OSVolume = $PartitionDetails.OSPartition | Format-Volume -FileSystem NTFS
    
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

# -----------------------------------------------------------
# Check Disk Requirments
# -----------------------------------------------------------
function CheckDiskRequirements
{
    param(
        [Parameter(Mandatory=$true)] $DiskDetails
    )

    [int] $returnCode = 0

    # Check if the disk is a Fixed Disk. 
    if($DiskDetails.ProvisioningType -ne "Fixed")
    {
        $returnCode += 1
    }

    # Check if Disk is Healthy
    if($DiskDetails.HealthStatus -ne "Healthy")
    {
        $returnCode += 2
    }

    # Check if Disk is Online
    # if($ChosenDisk.OperationalStatus -ne "Online")
    # {
    #     $returnCode += 4
    # }

    return $returnCode
}