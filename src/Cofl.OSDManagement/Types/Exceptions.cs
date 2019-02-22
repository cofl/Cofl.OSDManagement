using System;

namespace Cofl.OSDManagement
{
    public class OSDNotConnectedException: Exception
    {
        internal OSDNotConnectedException(): base("You must call the Connect-OSD cmdlet before calling any other cmdlets.")
        {
        }
    }

    public class OSDAlreadyConnectedException: Exception
    {
        internal OSDAlreadyConnectedException(): base("Already connected. First use Disconnect-OSD, or use the -Force parameter.")
        {
        }
    }

    public class OSDTaskSequenceNotFoundException: Exception
    {
        public OSDTaskSequenceNotFoundException(string share, string taskSequenceID): base($"A task sequence with the ID \"{taskSequenceID}\" was not found in the share \"{share}\".")
        {
        }
    }

    public class OSDMakeModelNotFoundException: Exception
    {
        public OSDMakeModelNotFoundException(string share, string modelID): base($"A model with the ID \"{modelID}\" was not found in the share \"{share}\".")
        {
        }
    }

    public class OSDComputerNotFoundException: Exception
    {
        public OSDComputerNotFoundException(string share, string computerID): base($"A computer with the ID \"{computerID}\" was not found in the share \"{share}\".")
        {
        }
    }
}
