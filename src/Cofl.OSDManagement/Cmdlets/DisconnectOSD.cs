using System;
using System.Management.Automation;

namespace Cofl.OSDManagement.Cmdlets
{
    [Cmdlet(VerbsCommunications.Disconnect, "OSD")]
    public class DisconnectOSD: Cmdlet
    {
        protected override void BeginProcessing()
        {
            if(!InternalState.IsConnected)
                return;

            try
            {
                InternalState.Current.Dispose();
            } catch(Exception e)
            {
                WriteWarning(e.Message);
            }

            InternalState.Current = null;
        }
    }
}
