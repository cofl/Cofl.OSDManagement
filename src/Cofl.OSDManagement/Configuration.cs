namespace Cofl.OSDManagement
{
    internal class Configuration
    {
        public bool AutoConnectOnImport { get; set; } = false;
        public string ComputerNameTemplate { get; set; } = "MDT-Computer-{0}";
        public string DefaultOU { get; set; } = "OU=Setup,OU=Computers,DC=corp,DC=contoso,DC=com";
        public string MDTSharePath { get; set; } = @"\\img-svr-01.corp.contoso.com\MDT_Share$";
    }
}
