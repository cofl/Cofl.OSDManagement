class OSDNotConnectedException: Exception
{
    OSDNotConnectedException(): base("You must call the Connect-OSD cmdlet before calling any other cmdlets.")
    {
    }
}

class OSDAlreadyConnectedException: Exception
{
    OSDAlreadyConnectedException(): base("Already connected. First use Disconnect-OSD, or use the -Force parameter.")
    {
    }
}

class OSDTaskSequenceNotFoundException: Exception
{
    OSDTaskSequenceNotFoundException([string]$Share, [string]$TaskSequenceID) : base("A task sequence with the ID ""$TaskSequenceID"" was not found in the share ""$Share"".")
    {
    }
}

class OSDMakeModelNotFoundException : Exception
{
    OSDMakeModelNotFoundException([string]$Share, [string]$ModelID) : base("A model with the ID ""$ModelID"" was not found in the share ""$Share"".")
    {
    }
}

class OSDComputerNotFoundException : Exception
{
    OSDComputerNotFoundException([string]$Share, [string]$ComputerID) : base("A computer with the ID ""$ComputerID"" was not found in the share ""$Share"".")
    {
    }
}
