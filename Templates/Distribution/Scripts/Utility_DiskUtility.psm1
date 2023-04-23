# -----------------------------------------------------------
# Utility_DiskUtility.psm1 - Utilities used for disk management
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Data Class
# -----------------------------------------------------------
class PartitionDetails
{
    $RecoveryPartition
    $BootPartition
    $ReservedPartition
    $OSPartition
}

# -----------------------------------------------------------
# Partition Disks
# -----------------------------------------------------------
function PartitionDisk
{
    param(
        [int] $DiskNumber,
        [string] $FirmwareType
    )

    if($FirmwareType -eq "UEFI") { 
        PartitionDiskUEFI($DiskNumber) 
        return
    }
    elseif($FirmwareType -eq "BIOS") {
        PartitionDiskBIOS($DiskNumber)
    }
}

# -----------------------------------------------------------
# Partition UEFI Disks
# -----------------------------------------------------------
function PartitionDiskUEFI
{
    param(
        [int] $DiskNumber
    )

    # Generate a class instance to hold our returned data
    $details = [PartitionDetails]::new()

    # Grab some disk details
    $disk = Get-Disk -Number $DiskNumber

    # Determine size of OS drive
    $osDiskSize = $disk.Size - $disk.AllocatedSize - 1024MB

    # Clear the Disk
    Clear-Disk -Number $DiskNumber -Removedata -Confirm:$false

    # Generate EFI partition
    $details.$BootPartition = New-Partition -DiskNumber $DiskNumber -Size 499MB -DriveLetter E -IsHidden $true -GptType "{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"

    # Generate reserved partition
    $details.$ReservedPartition = New-Partition -DiskNumber $DiskNumber -Size 16MB -IsHidden $true -GptType "{e3c9e316-0b5c-4db8-817d-f92df00215ae}"

    # Generate OS Partition
    $details.$OSPartition = New-Partition -DiskNumber $DiskNumber -DriveLetter C -Size $osDiskSize

    # Generate recovery partition
    $details.$RecoveryPartition = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -DriveLetter R -IsHidden $true -GptType "{de94bba4-06d1-4d40-a16a-bfd50179d6ac}"

    # Return details on the partitions
    return $details
}

# -----------------------------------------------------------
# Partition BIOS Disks
# -----------------------------------------------------------
function PartitionDiskBIOS
{
    throw "NDK Does not currently support deploying to BIOS firmware."
}