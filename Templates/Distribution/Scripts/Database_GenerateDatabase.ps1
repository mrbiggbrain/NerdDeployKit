# -----------------------------------------------------------
# Gather_GenerateDatabase.ps1 - Generates an SQLite DB
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Add external librarys
# -----------------------------------------------------------
using module ..\Bin\AMD64\sqlite\System.Data.SQLite.dll
using module .\Database_DataAccess.psm1
using module .\Config_NDKConfig.psm1
using module .\Logging_Logging.psm1

# -----------------------------------------------------------
# Load SQLite DLL
# -----------------------------------------------------------
[Logging]::Informational("Loading SQLite Assembly.")
[SQLiteDB]::LoadModule();

# -----------------------------------------------------------
# Remove any existing database
# -----------------------------------------------------------
if(Test-Path ([NDKConfig]::DeployDBFilePath))
{
    [Logging]::Warning("Found existing DB file, removing (Possible unstable state?)")
    Remove-Item ([NDKConfig]::DeployDBFilePath) -Force
}

# -----------------------------------------------------------
# Create the DB
# -----------------------------------------------------------
[Logging]::Informational("Generating Database File.")
$DBFile = [SQLiteDB]::CreateDB([NDKConfig]::DeployDBFilePath);

# -----------------------------------------------------------
# Connect to database
# -----------------------------------------------------------
[Logging]::Informational("Connecting to newly created database.")
$DBConnection = [SQLiteDB]::ConnectDB($DBFile);

# -----------------------------------------------------------
# Create Disks Table
# -----------------------------------------------------------
[Logging]::Informational("Generating Disks Database Table.")
[DisksTable]::Init($DBConnection)

# -----------------------------------------------------------
# Create Partitions Table
# -----------------------------------------------------------
[Logging]::Informational("Generating Partitions Database Table.")
[PartitionsTable]::Init($DBConnection)

# -----------------------------------------------------------
# Close the DB Connection.
# -----------------------------------------------------------
Write-Host "[I] Closing DB connection." -ForegroundColor Blue
[Logging]::Informational("Closing DB connection.")
[SQLiteDB]::CloseDB($DBConnection)