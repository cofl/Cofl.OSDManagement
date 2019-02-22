using System.Collections.Generic;

namespace Cofl.OSDManagement
{
    internal readonly struct ArgumentCompleterCache
    {
        private readonly InternalState InternalState;

        internal readonly List<string> TaskSequenceID;
        internal readonly List<string> TaskSequenceGroup;
        internal readonly List<string> DriverGroupName;
        internal readonly List<string> ManufacturerName;
        internal readonly List<string> ModelName;

        internal ArgumentCompleterCache(InternalState internalState)
        {
            TaskSequenceID = new List<string>();
            TaskSequenceGroup = new List<string>();
            DriverGroupName = new List<string>();
            ManufacturerName = new List<string>();
            ModelName = new List<string>();

            InternalState = internalState;
        }

        internal void Refresh()
        {
            // TODO
        }
    }
}
