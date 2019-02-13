# Cofl.OSDManagement
## about_Cofl.OSDManagement_Configuration

# SHORT DESCRIPTION
Explains how to configure the Cofl.OSDManagement module to manage computers in an MDT/AD WDS deployment system.

# LONG DESCRIPTION
The Cofl.OSDManagement module for Windows Powershell is configured using the Configuration module, or with the Update-OSDConfiguration cmdlet. Configuration changes require re-connecting the module. There are a number of options that may be configured, which are listed here.

## AutoConnectOnImport
The AutoConnectOnImport option governs if [Connect-OSD](Connect-OSD.md) will be automatically called during module import using the configuration options described here and loaded from the default Configuration scope.

The default value is 'false': [Connect-OSD](Connect-OSD.md) will not be automatically called, and must be called manually for other cmdlets to function.

## ComputerNameTemplate
The ComputerNameTemplate option is a C# format string accepting one value, the asset tag number of the computer. It is used to generate default names for computers in the MDT database created with New-OSDComputer if a name is not provided.

If the string does not contain the substring "{0}", the asset tag will be appended to the end of the template. If the template is empty or null, the value "MDT-Computer-{0}" will be used.

The default value is 'MDT-Computer-{0}'.

## DefaultOU
The DefaultOU option governs two things: the OrganizationalUnit new computers will be created in in ActiveDirectory, and the OrganizationalUnit computers will be moved to in ActiveDirectory if the -MoveADComputer parameter is supplied to New-OSDComputer or Set-OSDComputerState. This option must be configured for the module to do anything useful without breaking horribly.

The default value is 'OU=Setup,OU=Computers,DC=corp,DC=contoso,DC=com'.

## MDTSharePath
The MDTSharePath option is an absolute local or UNC path to the root directory of an MDT Deployment Share. Vital information, such as SQL Server connection data, is pulled directly from the MDT share's configuration.

The default value is '\\\\img-svr-01.corp.contoso.com\\MDT_Share$'.

# Examples
## Example 1: Using Update-OSDConfiguration to set up configuration and auto-connect.
```powershell
PS C:\> Update-OSDConfiguration -MDTSharePath '\\img-svr-01.corp.contoso.com\MDT_Share$' -DefaultOU 'OU=Setup,OU=Computers,DC=corp,DC=contoso,DC=com' -ComputerNamTemplate 'Computer{0}' -AutoConnectOnImport $true
```

## Example 2: Updating configuration for an already-connected session.
```powershell
PS C:\> Update-OSDConfiguration @Options
PS C:\> Disconnect-OSD
PS C:\> Connect-OSD -UseConfiguredPath
```
