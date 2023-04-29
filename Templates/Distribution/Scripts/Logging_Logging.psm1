class Logging
{
    static Informational($msg)
    {
        Write-Host "[I] $($msg)" -ForegroundColor Blue
    }

    static Warning($msg)
    {
        Write-Host "[W] $($msg)" -ForegroundColor Yellow
    }

    static Error($msg)
    {
        Write-Host "[E] $($msg)" -ForegroundColor Red
    }
}

class Errors
{
    [string] static $FAILED_VERIFICATION_ERROR = "FAILED_VERIFICATION_ERROR"
}