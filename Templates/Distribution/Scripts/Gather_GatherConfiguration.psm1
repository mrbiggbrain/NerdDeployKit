
 class Configuration {

    # Loads the NDK COnfiguration from the configuration files
    static LoadNDKConfiguration()
    {
        # Generate a new configuration object
        $config = [Configuration]::new()

        # Assign a fake index for now for testing. 
        $config.DriveIndex = 0;
    }

    # Which drive to format and image onto. 
    [string] $DriveIndex;
}
