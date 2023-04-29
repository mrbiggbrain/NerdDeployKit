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

# -----------------------------------------------------------
# Load SQLite DLL
# -----------------------------------------------------------
Write-Host "[I] Loading SQLite Assembly." -ForegroundColor Blue
[SQLiteDB]::LoadModule();

# -----------------------------------------------------------
# Remove any existing database
# -----------------------------------------------------------
if(Test-Path ([NDKConfig]::DeployDBFilePath))
{
    Write-Host "[W] Found existing DB file, removing (Possible unstable state?)" -ForegroundColor DarkYellow
    #Remove-Item ([NDKConfig]::DeployDBFilePath) -Force
}

# -----------------------------------------------------------
# Create the DB
# -----------------------------------------------------------
Write-Host "[I] Generating Database File." -ForegroundColor Blue
$DBFile = [SQLiteDB]::CreateDB([NDKConfig]::DeployDBFilePath);

# -----------------------------------------------------------
# Connect to database
# -----------------------------------------------------------
Write-Host "[I] Connecting to newly created database." -ForegroundColor Blue
$DBConnection = [SQLiteDB]::ConnectDB($DBFile);

# -----------------------------------------------------------
# Create Disks Table
# -----------------------------------------------------------
Write-Host "[I] Generating Disks Table" -ForegroundColor Blue
[DisksTable]::Init($DBConnection)

# -----------------------------------------------------------
# Create Partitions Table
# -----------------------------------------------------------
Write-Host "[I] Generating Partitions Table" -ForegroundColor Blue
[PartitionsTable]::Init($DBConnection)

# -----------------------------------------------------------
# Close the DB Connection.
# -----------------------------------------------------------
Write-Host "[I] Closing DB connection." -ForegroundColor Blue
[SQLiteDB]::CloseDB($DBConnection)