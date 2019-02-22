using namespace System.Data.SqlClient;
using namespace System.IO;
using namespace System.Management.Automation;

<#
.SYNOPSIS
Initializes the OSD Script environment.

.DESCRIPTION
The Connect-OSD cmdlet initializes the environment for management of the OS Deployment back-end.
A connection to the MDT Database is created.

This command can be called with the -Force parameter to refresh all globals.
It is necessary to modify the default values of this parameter if the change is permanent.

.EXAMPLE
PS C:\> Connect-OSD '\\img-contoso-01.contoso.com\MDT_Share$'
Opens a connection to the share at the listed address, using its share details to connect to the SQL database.
#>
function Connect-OSD
{
    [CmdletBinding(DefaultParameterSetName='ByPath')]
    PARAM(
        [Parameter(Mandatory=$false,ParameterSetName='ByDrive',ValueFromPipelineByPropertyName=$true)][Alias('PersistentDrive')]
            # The name of the PSDrive for the share (see Get-MDTPersistentDrive)
            [string]$DriveName='DS001',
        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ByPath',ValueFromPipelineByPropertyName=$true,HelpMessage="The path to the root of the MDT deployment share.")][ValidateNotNullOrEmpty()]
            [Alias('MDTSharePath')]
            # The path to the root of the deployment share.
            [string]$Path,
        [Parameter(Mandatory=$true,ParameterSetName='ByConfiguredPath',ValueFromPipelineByPropertyName=$true,HelpMessage="Use the MDT share path specified in the configuration.")]
            # Use the MDT share path specified in the configuration.
            [switch]$UseConfiguredPath,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,HelpMessage="The default ActiveDirectory OU where computers will be created or moved to.")][ValidateNotNullOrEmpty()]
            # The default ActiveDirectory OU where computers will be created or moved to.
            [string]$DefaultOU,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,HelpMessage="The template to use for generating default computer names.")][AllowEmptyString()]
            # The template to use for generating default computer names.
            [string]$ComputerNameTemplate,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            # Refresh all globals and reconnect.
            [switch]$Force
    )

    if($Script:OSDIsConnected -and !$Force)
    {
        throw [OSDAlreadyConnectedException]::new()
    }

    try
    {
        $Config = Get-Config
        # Fix and provide default parameters.
        if($PSCmdlet.ParameterSetName -eq 'ByConfiguredPath')
        {
            $Path = $Config.MDTSharePath
        }

        if(!$PSBoundParameters.ContainsKey('DefaultOU'))
        {
            $DefaultOU = $Config.DefaultOU
        }

        if(!$PSBoundParameters.ContainsKey('ComputerNameTemplate'))
        {
            $ComputerNameTemplate = $Config.ComputerNameTemplate
        }

        $Script:OSDDefaultOU = $DefaultOU
        $Script:OSDComputerNameTemplate = $ComputerNameTemplate
        if([string]::IsNullOrEmpty($Script:OSDComputerNameTemplate))
        {
            $Script:OSDComputerNameTemplate = "MDT-Computer-{0}"
        }
        if($Script:OSDComputerNameTemplate.IndexOf('{0}') -lt 0)
        {
            $Script:OSDComputerNameTemplate = "$Script:OSDComputerNameTemplate{0}"
        }

        # If we're using a drive, load properties from there directly. Otherwise, look in the MDT path.
        if($PSCmdlet.ParameterSetName -eq 'ByDrive')
        {
            if(!(Get-Command -Name 'Restore-MDTPersistentDrive'))
            {
                throw [CommandNotFoundException]::new("Restore-MDTPersistentDrive is not available. Do you have the MDT module loaded?")
            }
            Restore-MDTPersistentDrive -Force | Out-Null
            if(!$DriveName.EndsWith(':'))
            {
                $DriveName = "${DriveName}:"
            }
            if(!(Test-Path -Path $DriveName))
            {
                throw [FileNotFoundException]::new("The MDT persistent drive does not exist.", $DriveName)
            }
            $props = Get-ItemProperty $DriveName
        } else
        {
            $SettingsPath = Join-Path $Path 'Control\Settings.xml'
            if(!(Test-Path -Path $SettingsPath))
            {
                throw [FileNotFoundException]::new("Could not find the settings file.", $SettingsPath)
            }
            $props = ([xml](Get-Content $SettingsPath)).Settings
            Write-Verbose "Loading settings (Name is $($props.Description))"
        }

        if(![string]::IsNullOrEmpty($props.'Database.Instance'))
        {
            $Script:OSDScriptsSQLConnectString = "Server=$($props.'Database.SQLServer')\$($props.'Database.Instance'); Database='$($props.'Database.Name')'; Integrated Security=true;"
        } else
        {
            $Script:OSDScriptsSQLConnectString = "Server=$($props.'Database.SQLServer'); Database='$($props.'Database.Name')'; Integrated Security=true;"
        }
        $Script:OSDScriptsMDTRoot = $props.UNCPath
        Write-Verbose "MDTRoot is: '$Script:OSDScriptsMDTRoot'"

        Write-Verbose "Connection string is: '$Script:OSDScriptsSQLConnectString'"
        try
        {
            if($null -ne $Script:OSDScriptsSQLConnection)
            {
                $Script:OSDScriptsSQLConnection.Dispose()
            }
        } catch
        {
            Write-Debug $_
        }
        $Script:OSDScriptsSQLConnection = [SqlConnection]::new($Script:OSDScriptsSQLConnectString)
        $Script:OSDScriptsSQLConnection.Open()

        # Now refresh the auto-complete caches; the data may have changed.
        $Script:OSDIsConnected = $true
        Update-OSDAutoCompleteCache
    } catch
    {
        # Rely on Disconnect-OSD to reset values to null/empty.
        Disconnect-OSD
        throw $_
    }
}
