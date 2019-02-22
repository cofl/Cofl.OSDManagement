using System.Management.Automation;

namespace Cofl.OSDManagement.Cmdlets
{
    [Cmdlet(VerbsCommunications.Connect, "OSD", DefaultParameterSetName = nameof(ConnectOSD.ParameterSets.ByPath))]
    public class ConnectOSD: Cmdlet
    {
        internal enum ParameterSets
        {
            ByPath,
            ByDrive,
            ByConfiguration
        }

        [Parameter(Mandatory = false, ParameterSetName = nameof(ParameterSets.ByDrive), ValueFromPipelineByPropertyName = true)]
        [Alias("PersistentDrive")]
        public string DriveName { get; set; } = "DS001";

        [Parameter(
            Mandatory = true, Position = 1, ValueFromPipelineByPropertyName = true,
            ParameterSetName = nameof(ParameterSets.ByPath),
            HelpMessage = "The path to the root of the MDT deployment share."
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("MDTSharePath")]
        public string Path { get; set; }

        [Parameter(Mandatory = true, ParameterSetName = nameof(ParameterSets.ByConfiguration), ValueFromPipelineByPropertyName = true, HelpMessage = "Use the MDT share path specified in the configuration.")]
        public SwitchParameter UseConfiguredPath { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, HelpMessage = "The default ActiveDirectory OU where computers will be created or moved to.")]
        [ValidateNotNullOrEmpty()]
        public string DefaultOU { get; set; }

        [Parameter(Mandatory = false, ValueFromPipelineByPropertyName = true, HelpMessage = "The template to use for generating default computer names.")]
        [AllowEmptyString()]
        public string ComputerNameTemplate { get; set; }

        [Parameter(Mandatory = false, ValueFromPipelineByPropertyName = true)]
        public SwitchParameter Force { get; set; }

        protected override void BeginProcessing()
        {
            if(InternalState.IsConnected && !Force)
                throw new OSDAlreadyConnectedException();

            try
            {
                // TODO: load configuration
                var config = new Configuration();
                if(UseConfiguredPath)
                {
                    // TODO
                } else if(!string.IsNullOrEmpty(Path))
                {
                    // TODO
                } else
                {
                    // TODO: can we still support this?
                }

                InternalState.Current = new InternalState
                {
                    Configuration = config,
                    // TODO
                };

                InternalState.Current.Cache.Refresh();
            } catch
            {
                InternalState.Current = null;
                throw;
            }
        }
    }
}
