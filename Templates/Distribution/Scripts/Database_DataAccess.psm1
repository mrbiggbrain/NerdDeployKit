Class SQLiteDB
{
    [bool] static LoadModule()
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
        
        if(([System.AppDomain]::CurrentDomain.GetAssemblies()).Location -contains $DLLPath){
            return $true
        }
        else {
            return $false
        }
    }  

    [string] static CreateDB()
    {
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

    [System.Data.SQLite.SQLiteConnection] static ConnectDB($DBFile)
    {
        $DBConnectionString = [string]::Format("data source={0}",$DBFile)
        $DBConnection = New-Object System.Data.SQLite.SQLiteConnection
        $DBConnection.ConnectionString = $DBConnectionString
        $DBConnection.open()

        return $DBConnection
    }

}