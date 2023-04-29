# -----------------------------------------------------------
# Database_DataAccess.psm1 - Utility classes for managing data
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------
using module ..\Bin\AMD64\sqlite\System.Data.SQLite.dll

# -----------------------------------------------------------
# Utility class for working with SQLite Databases
# -----------------------------------------------------------
Class SQLiteDB
{

    # -----------------------------------------------------------
    # Loads the Module
    # -----------------------------------------------------------
    static LoadModule()
    {
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
        [Reflection.Assembly]::LoadFile($DLLPath) | Out-Null

        # -----------------------------------------------------------
        # Return true if the DLL loaded correctly.
        # -----------------------------------------------------------
        
        if(-not (([System.AppDomain]::CurrentDomain.GetAssemblies()).Location -contains $DLLPath)){
            throw "Assembly Not Loaded"
        }

    }  

    # -----------------------------------------------------------
    # Creates a DB file
    # -----------------------------------------------------------
    [string] static CreateDB($DBPath)
    {
        [SQLiteDB]::LoadModule()

        # -----------------------------------------------------------
        # Get proposed database folder
        # -----------------------------------------------------------
        $DBFolder = Split-Path -Parent $DBPath

        # -----------------------------------------------------------
        # Get proposed database file
        # -----------------------------------------------------------
        $DBFile = $DBPath

        # -----------------------------------------------------------
        # Generate Database Folder
        # -----------------------------------------------------------
        New-Item -ItemType Directory -Path $DBFolder -Force

        # -----------------------------------------------------------
        # Generate Database File
        # -----------------------------------------------------------
        [System.Data.SQLite.SQLiteConnection]::CreateFile($DBFile)

        # -----------------------------------------------------------
        # Return if the file was generated or not. 
        # -----------------------------------------------------------
        if(Test-Path $DBFile)
        {
            return $DBFile
        }
        else {
            throw "Failed to create DB file."
        }
    }

    # -----------------------------------------------------------
    # Connects to a DB
    # -----------------------------------------------------------
    [System.Data.SQLite.SQLiteConnection] static ConnectDB($DBFile)
    {
        $DBConnectionString = [string]::Format("data source={0}",$DBFile)
        $DBConnection = New-Object System.Data.SQLite.SQLiteConnection
        $DBConnection.ConnectionString = $DBConnectionString
        $DBConnection.open()

        return $DBConnection
    }

    # -----------------------------------------------------------
    # Perform Non-Query command
    # -----------------------------------------------------------
    static ExecuteNonQuery($DBConnection, $Command)
    {
        $DBCommand=$DBConnection.CreateCommand()
        $DBCommand.Commandtext=$Command
        $DBCommand.CommandType = [System.Data.CommandType]::Text
        $DBCommand.ExecuteNonQuery()
        $DBCommand.Dispose()
    }

    # -----------------------------------------------------------
    # Perform Query command
    # -----------------------------------------------------------
    [System.Data.DataSet] static ExecuteQuery($DBConnection, $Command)
    {
        $DBCommand=$DBConnection.CreateCommand()
        $DBCommand.Commandtext=$Command
        $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $DBCommand
        $data = New-Object System.Data.DataSet
        [void]$adapter.Fill($data)

        return $data
    }

    # -----------------------------------------------------------
    # Drops a table
    # -----------------------------------------------------------
    static DropTable($DBConnection, $TableName)
    {
        $DBCommand = [string]::Format("DROP TABLE IF EXISTS {0};",$TableName)
        [SQLiteDB]::ExecuteNonQuery($DBConnection, $DBCommand)
    }

    # -----------------------------------------------------------
    # Closes the DB file
    # -----------------------------------------------------------
    static CloseDB($DBConnection)
    {
        $DBConnection.Close()
        $DBConnection.Dispose()
        [System.GC]::Collect()
    }

}

# -----------------------------------------------------------
# Represents data about disks
# -----------------------------------------------------------
class DisksTable
{
    static Init($DBConnection)
    {
        # Drop the table if it already exists
        [SQLiteDB]::DropTable($DBConnection, "disks")

        # Setup new table if it does not exist. 
        [SQLiteDB]::ExecuteNonQuery($DBConnection, "create table if not exists disks (DiskNumber int, PartitionStyle varchar(3), ProvisioningType varchar(32), UniqueId varchar(100), Size int);")
    }
}

# -----------------------------------------------------------
# Represents data about partitions
# -----------------------------------------------------------
class Partition
{
    [uint64] $DiskNumber
    [string] $DriveLetter
    [uint64] $Size
    [string] $Type
    [string] $TargetType
    [string] $UniqueId

    Partition(
        [uint64] $DiskNumber,
        [string] $DriveLetter,
        [uint64] $Size,
        [string] $Type,
        [string] $TargetType,
        [string] $UniqueId
    )
    {
        $this.DiskNumber = $DiskNumber
        $this.DriveLetter = $DriveLetter
        $this.Size = $Size
        $this.Type = $Type
        $this.TargetType = $TargetType;
        $this.UniqueId = $UniqueId;
    }

    Partition([CimInstance] $obj, [string] $TargetType)
    {
        $this.DiskNumber = $obj.DiskNumber
        $this.DriveLetter = $obj.DriveLetter
        $this.Size = $obj.Size
        $this.Type = $obj.Type
        $this.TargetType = $TargetType
        $this.UniqueId = $obj.UniqueId
    }
}

class PartitionsTable
{
    static Init($DBConnection)
    {
        # Drop the table if it already exists
        [SQLiteDB]::DropTable($DBConnection, "partitions")

        # Setup new table if it does not exist. 
        [SQLiteDB]::ExecuteNonQuery($DBConnection, "create table if not exists partitions (DiskNumber int, DriveLetter varchar(1), Type varchar(100), TargetType varchar(100), UniqueId varchar(100));")
    }

    static AddPartition($DBConnection, [Partition] $partition)
    {
        $DBCommand = $DBConnection.CreateCommand()
        $DBCommand.CommandText = "INSERT INTO partitions (DiskNumber, DriveLetter, Type, TargetType, UniqueId) VALUES (@DiskNumber, @DriveLetter, @Type, @TargetType, @UniqueId)"
        $DBCommand.Parameters.AddWithValue("@DiskNumber", $partition.DiskNumber);
        $DBCommand.Parameters.AddWithValue("@DriveLetter", $partition.DriveLetter);
        $DBCommand.Parameters.AddWithValue("@Type", $partition.Type);
        $DBCommand.Parameters.AddWithValue("@TargetType", $partition.TargetType);
        $DBCommand.Parameters.AddWithValue("@UniqueId", $partition.UniqueId);
        $DBCommand.ExecuteNonQuery()
    }
}