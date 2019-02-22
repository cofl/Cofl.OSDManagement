using System;
using System.Data.SqlClient;

namespace Cofl.OSDManagement
{
    internal class InternalState: IDisposable
    {
        private static InternalState _current = null;
        internal static InternalState Current {
            get => _current;
            set
            {
                if(null != value && null != _current)
                {
                    throw new OSDAlreadyConnectedException();
                }

                _current = value;
            }
        }
        internal static bool IsConnected => Current != null;

        public void Dispose()
        {
            if(null != _current.SqlConnection)
                _current.SqlConnection.Dispose();
        }

        internal Configuration Configuration { get; set; }

        internal string MDTRootPath { get; set; }
        internal string SQLConnectionString { get; set; }
        internal string ComputerNameTemplate { get; set; } = string.Empty;
        internal SqlConnection SqlConnection { get; set; } = null;

        internal readonly ArgumentCompleterCache Cache;

        internal InternalState()
        {
            Cache = new ArgumentCompleterCache(this);
        }
    }
}
