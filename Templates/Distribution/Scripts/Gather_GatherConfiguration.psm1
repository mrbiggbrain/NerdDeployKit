# -----------------------------------------------------------
# Gather_GatherConfiguration.psm1 - Loads configuration for use in scripts
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------
 
# -----------------------------------------------------------
# Drive Letter Mapping Config
# -----------------------------------------------------------
class DriveLetterMappingConfiguration
{
    [DriveLetterMappingConfiguration] static LoadDriveLetterMappingConfiguration()
    {
        $mapping = [DriveLetterMappingConfiguration]::new();

        $mapping.OS = "H"
        $mapping.System = "S"
        $mapping.Recovery = "R"

        return $mapping
    }

    $OS
    $System
    $Recovery
}

# -----------------------------------------------------------
# Master Configuration Class
# -----------------------------------------------------------
 class Configuration {

    # Loads the NDK COnfiguration from the configuration files
    [Configuration] static LoadNDKConfiguration()
    {
        # Generate a new configuration object
        $config = [Configuration]::new()

        # Assign a fake index for now for testing. 
        $config.DriveIndex = 0;

        # Assign the current firmware type to $FirmwareType
        $config.FirmwareType = $env:firmware_type

        # Assign Drive Letter Mappings
        $config.DriveLetterMappings = [DriveLetterMappingConfiguration]::LoadDriveLetterMappingConfiguration()

        # Return the object
        return $config
    }

    # Which drive to format and image onto. 
    [string] $DriveIndex

    # Firmware Type
    [string] $FirmwareType

    # Drive letter mappings
    [DriveLetterMappingConfiguration] $DriveLetterMappings
}
