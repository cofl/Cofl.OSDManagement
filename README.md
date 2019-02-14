The Cofl.OSDManagment module for Windows Powershell allows the management of computers in an MDT/Active Directory system coupled with a WDS server set to use Active Directory authorization, and an MSSQL server running the MDT Database.

It has been (loosely) tested on MDT versions 8443 and 8450.

## Setup
1. Have a functioning MDT environment with a database configured.
2. Have an ActiveDirectory domain and access to create, read, and write in that domain or the subset of it you'll be using.
3. Have a WDS server configured to use ActiveDirectory for boot authorization.
4. Install this module from the [PowershellGallery](https://www.powershellgallery.com/packages/Cofl.OSDManagement):

   ```powershelll
   Install-Module Cofl.OSDManagement
   ```
5. Configure this module using the [Configuration](https://github.com/PoshCode/Configuration) module.  
   Options supported by this module are:
     - MDTSharePath: The path to the root MDT Deployment Share. Configuration will be loaded from this directory.
     - DefaultOU: The distinguished name of the ActiveDirectory OU computers will be created in, and maybe moved to if you ask.
     - ComputerNameTemplate: A .NET format string with one parameter (the asset tag).
   
   For Example:

   ```powershell
   @{
       DefaultOU = 'OU=Setup,OU=Computers,DC=corp,DC=contoso,DC=com'
       MDTSharePath = '\\img-svr-01.corp.contoso.com\MDT_Share$'
       ComputerNameTemplate = 'MDT-Computer-{0}'
       AutoConnectOnImport = $false
   } | Export-Configuration -CompanyName Cofl -Name OSDManagement
   ```

   Configuration is not necessary for SQL Server, as this module automatically uses the connection data configured in your MDT Share.
6. Import the module. The module will automatically initialize itself using the configuration data.

## How to Use
See [about_Cofl.OSDManagement](docs/en-US/about_Cofl.OSDManagement.md) for full documentation.

## Common Uses

## Assumptions made about the environment
### WDS
It is assumed that WDS is configured to query ActiveDirectory for authorizing netboots. The [`Set-OSDComputerState`](docs/en-US/Set-OSDComputerState.md) cmdlet updates the netbootGUID property in ActiveDirectory using the UUID of the computer stored in the MDT database, or if that is not available, the MAC Address.

### ActiveDirectory
It is assumed that the account running this module has access to create new objects in ActiveDirectory (in the DefaultOU OrganizationalUnit), as well as set their properties, and move them to the configured DefaultOU.

It is assumed that the Organizational Unit specified by DefaultOU exists, as it will not be created. Bad things may happen if this value is improperly configured.

### MDT and the MDT Database
It is assumed that most options for MDT are configured at the Make/Model level, such as `OSInstall`, and so are NOT set by this module. The options set by [New-OSDComputer](docs/en-US/New-OSDComputer.md) are: Asset Tag, Serial Number, MacAddress, UUID, Description, and OSDComputerName (of those, only one of MacAddress or UUID is required, Serial Number is not required, and the description is generated from the name).

[`Set-OSDComputer`](docs/en-US/Set-OSDComputer.md) and [`Reset-OSDComputer`](docs/en-US/Reset-OSDComputer.md) can be used to additionally override or clear overrides for Name (the Description and OSDComputerName fields), TaskSequence (the TaskSequenceID field), and DriverGroup. [`Set-OSDComputer`](docs/en-US/Set-OSDComputer.md) can also be used to set any other value, but tab completion is not supported for the `-Settings` or `-Clear` parameters.
