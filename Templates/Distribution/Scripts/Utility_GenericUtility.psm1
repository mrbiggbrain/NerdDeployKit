# -----------------------------------------------------------
# Utility_GenericUtility.psm1 - Generic Utility Scripts
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

class Logger
{
    static WriteError($err)
    {
        Write-Error $err
    }
}
