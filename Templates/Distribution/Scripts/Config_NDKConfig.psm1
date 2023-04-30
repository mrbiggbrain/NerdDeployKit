
class NDKConfig
{
    # -----------------------------------------------------------
    # Deployment Database Settings
    # -----------------------------------------------------------
    static [string] $DeployDBFilePath = "$($env:SystemDrive)\NDK\Deploy.sqlite"

    # -----------------------------------------------------------
    # Zero Touch Configs
    # -----------------------------------------------------------
    static [string] $ZTIScriptFilePath = "$PSScriptRoot\ZTI.ps1"

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