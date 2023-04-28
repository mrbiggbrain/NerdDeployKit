# -----------------------------------------------------------
# Gather_GenerateDatabase.ps1 - LGenerates an SQLite DB
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Get the base folder for the install.
# -----------------------------------------------------------
$BaseDir = (Get-Item $PSScriptRoot).Parent.FullName

# -----------------------------------------------------------
# Generate a path to BIN
# -----------------------------------------------------------
$BinPath = "$($BaseDir)\Bin\$($ENV:PROCESSOR_ARCHITECTURE)"

# -----------------------------------------------------------
# Generate a path to the SQLite DLL
# -----------------------------------------------------------
$DLLPath = "$($BinPath)\sqlite\System.Data.SQLite.dll"

# -----------------------------------------------------------
# Load the DLL
# -----------------------------------------------------------
Write-Host "[I] Loading SQLite Assembly." -ForegroundColor Yellow

[Reflection.Assembly]::LoadFile($DLLPath) | Out-Null

# -----------------------------------------------------------
# Get proposed database folder
# -----------------------------------------------------------
$DBFolder = "$($env:SystemDrive)\NDK"

# -----------------------------------------------------------
# Get proposed database file
# -----------------------------------------------------------
$DBFile = "$DBFolder\Deploy.sqlite"

# -----------------------------------------------------------
# Generate Database Folder
# -----------------------------------------------------------
Write-Host "[I] Generating Database Folder." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $DBFolder -Force

# -----------------------------------------------------------
# Generate Database File
# -----------------------------------------------------------
Write-Host "[I] Generating Database File." -ForegroundColor Yellow
[System.Data.SQLite.SQLiteConnection]::CreateFile($DBFile)

# -----------------------------------------------------------
# Connect to database
# -----------------------------------------------------------
Write-Host "[I] Connecting to newly created database." -ForegroundColor Yellow
$DBConnectionString = [string]::Format("data source={0}",$DBFile)
$DBConnection = New-Object System.Data.SQLite.SQLiteConnection
$DBConnection.ConnectionString = $DBConnectionString
$DBConnection.open()

# -----------------------------------------------------------
# Create Disks Table
# -----------------------------------------------------------
Write-Host "[I] Generating Disks Table" -ForegroundColor Yellow

# Drop the table if it already exists
$DBCommand=$DBConnection.CreateCommand()
$DBCommand.Commandtext="DROP TABLE IF EXISTS disks;"
$DBCommand.CommandType = [System.Data.CommandType]::Text
$DBCommand.ExecuteNonQuery()

# Setup new table if it does not exist. 
$DBCommand=$DBConnection.CreateCommand()
$DBCommand.Commandtext="create table if not exists disks (DiskNumber int, PartitionStyle varchar(3), ProvisioningType varchar(32), UniqueId varchar(100), Size int);"
$DBCommand.CommandType = [System.Data.CommandType]::Text
$DBCommand.ExecuteNonQuery()

# -----------------------------------------------------------
# Create Partitions Table
# -----------------------------------------------------------
Write-Host "[I] Generating Partitions Table" -ForegroundColor Yellow

# Drop the table if it already exists
$DBCommand=$DBConnection.CreateCommand()
$DBCommand.Commandtext="DROP TABLE IF EXISTS partitions;"
$DBCommand.CommandType = [System.Data.CommandType]::Text
$DBCommand.ExecuteNonQuery()

# Setup new table if it does not exist. 
$DBCommand=$DBConnection.CreateCommand()
$DBCommand.Commandtext="create table if not exists partitions (DiskNumber int, DriveLetter varchar(1), Size int, Type varchar(100), TargetType varchar(100));"
$DBCommand.CommandType = [System.Data.CommandType]::Text
$DBCommand.ExecuteNonQuery()

# -----------------------------------------------------------
# Close the DB Connection.
# -----------------------------------------------------------
Write-Host "[I] Closing DB connection." -ForegroundColor Yellow
$DBConnection.Close()