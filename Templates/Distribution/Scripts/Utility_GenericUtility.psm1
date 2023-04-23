
class Logger
{
    static WriteError($err)
    {
        Write-Error $err
    }
}

class ProgramScope
{
    static FailProvision($err)
    {
        exit
    }
}