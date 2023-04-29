# -----------------------------------------------------------
# Database_DataAccess.psm1 - Utility classes for managing data
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

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
class PartitionsTable
{
    static Init($DBConnection)
    {
        # Drop the table if it already exists
        [SQLiteDB]::DropTable($DBConnection, "partitions")

        # Setup new table if it does not exist. 
        [SQLiteDB]::ExecuteNonQuery($DBConnection, "create table if not exists partitions (DiskNumber int, DriveLetter varchar(1), Size int, Type varchar(100), TargetType varchar(100));")
    }
}