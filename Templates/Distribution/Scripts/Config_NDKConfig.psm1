
class NDKConfig
{
    # -----------------------------------------------------------
    # Deployment Database Settings
    # -----------------------------------------------------------
    static [string] $DeployDBFilePath = "$($env:SystemDrive)\NDK\Deploy.sqlite"

    # -----------------------------------------------------------
    # Partitioning Details
    # -----------------------------------------------------------
    static [int] $InstallDisk = 0

    # -----------------------------------------------------------
    # Firmware Details
    # -----------------------------------------------------------
    static [string] $FirmwareType = $env:firmware_type
}