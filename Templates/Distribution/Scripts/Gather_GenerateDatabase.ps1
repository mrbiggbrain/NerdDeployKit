# -----------------------------------------------------------
# Gather_GenerateDatabase.ps1 - Generates an SQLite DB
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

# -----------------------------------------------------------
# Add external librarys
# -----------------------------------------------------------
using module .\Database_DataAccess.psm1

# -----------------------------------------------------------
# Load SQLite DLL
# -----------------------------------------------------------
Write-Host "[I] Loading SQLite Assembly." -ForegroundColor Yellow
SQLiteDB.LoadModule;

# -----------------------------------------------------------
# Create the DB
# -----------------------------------------------------------
Write-Host "[I] Generating Database File." -ForegroundColor Yellow
$DBFile = SQLiteDB.CreateDB

# -----------------------------------------------------------
# Connect to database
# -----------------------------------------------------------
Write-Host "[I] Connecting to newly created database." -ForegroundColor Yellow
$DBConnection = SQLiteDB.ConnectDB($DBFile)

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