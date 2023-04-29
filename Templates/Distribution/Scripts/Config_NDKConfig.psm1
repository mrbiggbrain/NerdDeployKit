
class NDKConfig
{
    # -----------------------------------------------------------
    # Deployment Database Settings
    # -----------------------------------------------------------
    static [string] $DeployDBFilePath = "$($env:SystemDrive)\NDK\Deploy.sqlite"

    # -----------------------------------------------------------
    # Partitioning Details
    # -----------------------------------------------------------
    static [int] $InstallDisk = 1
    static [string] $OSDriveLetter = "W"
    static [string] $RecoveryDriveLetter = "R"
    static [string] $SystemDriveLetter = "S"

    # -----------------------------------------------------------
    # Firmware Details
    # -----------------------------------------------------------
    static [string] $FirmwareType = $env:firmware_type
}