# -----------------------------------------------------------
# Utility_DiskUtility.psm1 - Utilities used for disk management
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Include Librarys
# -----------------------------------------------------------


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
    # -----------------------------------------------------------
    # Load chosen settings from JSON file
    # -----------------------------------------------------------
    #[Logging]::Informational("Loading deployment options.")
    $JsonData = Get-Content $ENV:SystemDrive\NDK\Deploy.json | ConvertFrom-Json
    $FirmwareType = $JsonData.Partitioning.FirmwareType

    if($FirmwareType -eq "UEFI") { 
        PartitionDiskUEFI 
    }
    elseif($FirmwareType -eq "BIOS") {
        PartitionDiskBIOS
    }
    else {
        throw "BadPartStyle"
    }
}

# -----------------------------------------------------------
# Partition UEFI Disks
# -----------------------------------------------------------
function PartitionDiskUEFI
{
    # -----------------------------------------------------------
    # Load chosen settings from JSON file
    # -----------------------------------------------------------
    #[Logging]::Informational("Loading deployment options.")
    $JsonData = Get-Content $ENV:SystemDrive\NDK\Deploy.json | ConvertFrom-Json
    $DiskNumber = $JsonData.Partitioning.Disk

    # Grab some disk details
    $disk = Get-Disk -Number $DiskNumber

    # Determine size of OS drive
    $osDiskSize = $disk.Size - 1024MB

    # Clear the disk if the partition style is not raw.
    if($disk.PartitionStyle -ne "RAW")
    {
        # Clear the Disk
        Clear-Disk -Number $DiskNumber -Removedata -Confirm:$false
    }
    
    # Refresh the disk object.
    $disk = Get-Disk -Number $DiskNumber

    # Initilize disk if it's now RAW after clearing.
    if($disk.PartitionStyle -eq "RAW")
    {
        Write-Host "Init happening"
        Initialize-Disk -Number $DiskNumber -PartitionStyle GPT
    }

    # Generate EFI partition
    New-Partition -DiskNumber $DiskNumber -Size 499MB -DriveLetter ($JsonData.Partitioning.DriveLetters.System) -GptType "{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}"

    # Generate reserved partition
    #$details.ReservedPartition = New-Partition -DiskNumber $DiskNumber -Size 16MB -GptType "{E3C9E316-0B5C-4DB8-817D-F92DF00215AE}"

    # Generate OS Partition
    New-Partition -DiskNumber $DiskNumber -DriveLetter ($JsonData.Partitioning.DriveLetters.OS) -Size $osDiskSize

    # Generate recovery partition
    New-Partition -DiskNumber $DiskNumber -UseMaximumSize -DriveLetter ($JsonData.Partitioning.DriveLetters.Recovery) -GptType "{de94bba4-06d1-4d40-a16a-bfd50179d6ac}"

    # Return details on the partitions
    return
}

# -----------------------------------------------------------
# Partition BIOS Disks
# -----------------------------------------------------------
function PartitionDiskBIOS
{
    throw "NDK Does not currently support deploying to BIOS firmware."
}

# -----------------------------------------------------------
# Format Partitions
# -----------------------------------------------------------
function FormatPartitions
{
    # -----------------------------------------------------------
    # Load chosen settings from JSON file
    # -----------------------------------------------------------
    #[Logging]::Informational("Loading deployment options.")
    $JsonData = Get-Content $ENV:SystemDrive\NDK\Deploy.json | ConvertFrom-Json
    $FirmwareType = $JsonData.Partitioning.FirmwareType

    if($FirmwareType -eq "UEFI") { 
        FormatPartitionsUEFI
    }
    elseif($FirmwareType -eq "BIOS") {
        FormatPartitionsBIOS
    }
    else {
        Throw "BadPartStyle"
    }
}

# -----------------------------------------------------------
# Format Partitions (UEFI)
# -----------------------------------------------------------
function FormatPartitionsUEFI
{
    # -----------------------------------------------------------
    # Load chosen settings from JSON file
    # -----------------------------------------------------------
    #[Logging]::Informational("Loading deployment options.")
    $JsonData = Get-Content $ENV:SystemDrive\NDK\Deploy.json | ConvertFrom-Json

    # Recovery 
    Get-Partition -DriveLetter ($JsonData.Partitioning.DriveLetters.Recovery) | Format-Volume -FileSystem NTFS

    # System
    Get-Partition -DriveLetter ($JsonData.Partitioning.DriveLetters.System) | Format-Volume -FileSystem FAT32
    
    # OS
    Get-Partition -DriveLetter ($JsonData.Partitioning.DriveLetters.OS) | Format-Volume -FileSystem NTFS
}

# -----------------------------------------------------------
# Format Partitions (BIOS)
# -----------------------------------------------------------
function FormatPartitionsBIOS
{
    throw "NDK Does not currently support deploying to BIOS firmware."
}

# -----------------------------------------------------------
# Check Disk Requirments
# -----------------------------------------------------------
function CheckDiskRequirements
{
    # -----------------------------------------------------------
    # Load chosen settings from JSON file
    # -----------------------------------------------------------
    #[Logging]::Informational("Loading deployment options.")
    $JsonData = Get-Content $ENV:SystemDrive\NDK\Deploy.json | ConvertFrom-Json

    $DiskDetails = Get-Disk -Number ($JsonData.Partitioning.Disk)

    [int] $returnCode = 0

    # Check if the disk is a Fixed Disk. 
    if(($DiskDetails.ProvisioningType -ne "Fixed") -and ($DiskDetails.ProvisioningType -ne "Thin"))
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