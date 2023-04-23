# -----------------------------------------------------------
# Scope_Scope.psm1 - Scope Management
# Nerd Deployment Kit
# (C) 2023 Nicholas Young
# -----------------------------------------------------------

class ProgramScope
{
    static FailProvision($sec, $err)
    {
        exit
    }

    static SavePartitions($partitionDetails)
    {
        throw("NOT IMPLIMENTED")
    }

    [CimInstance] static LoadPartitions($partitionDetails)
    {
        throw("NOT IMPLIMENTED")
    }

    static SaveVolumes($volumeDetails)
    {
        throw("NOT IMPLIMENTED")
    }

    [CimInstance] static LoadVolumes($volumeDetails)
    {
        throw("NOT IMPLIMENTED")
    }

}