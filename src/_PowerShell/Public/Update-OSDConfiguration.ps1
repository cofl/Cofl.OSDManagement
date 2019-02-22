<#
.SYNOPSIS
Updates the connection defaults for the module.

.DESCRIPTION
The Update-OSDConfiguration cmdlet sets one or more configuration values used by cmdlets like Connect-OSD.

.EXAMPLE
PS C:\> Update-OSDConfiguration -Path '\\img-contoso-01.contoso.com\MDT_Share$'
Updates the MDT share path for the default scope.
#>
function Update-OSDConfiguration
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    PARAM (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,HelpMessage="The path to the root of the MDT deployment share.")][ValidateNotNullOrEmpty()]
            # The path to the root of the deployment share.
            [string]$Path,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,HelpMessage="The default ActiveDirectory OU where computers will be created or moved to.")][ValidateNotNullOrEmpty()]
            # The default ActiveDirectory OU where computers will be created or moved to.
            [string]$DefaultOU,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,HelpMessage="The template to use for generating default computer names.")][ValidateNotNullOrEmpty()]
            # The template to use for generating default computer names.
            [string]$ComputerNameTemplate,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,HelpMessage="Should the module automatically connect on import?")]
            # Should the module automatically connect on import?
            [bool]$AutoConnectOnImport
    )

    $Configuration = Get-Config
    if($PSBoundParameters.ContainsKey('Path'))
    {
        $Configuration.MDTSharePath = $Path
    }
    if($PSBoundParameters.ContainsKey('DefaultOU'))
    {
        $Configuration.DefaultOU = $DefaultOU
    }
    if($PSBoundParameters.ContainsKey('ComputerNameTemplate'))
    {
        $Configuration.ComputerNameTemplate = $ComputerNameTemplate
    }
    if($PSBoundParameters.ContainsKey('AutoConnectOnImport'))
    {
        $Configuration.AutoConnectOnImport = $AutoConnectOnImport
    }
    $Parameters = @{
        InputObject = $Configuration
        CompanyName = 'Cofl'
        Name = 'OSDManagement'
    }
    if($PSBoundParameters.ContainsKey('Scope'))
    {
        $Parameters.Scope = $Scope
    }

    [string]$Path = Get-ConfigurationPath -CompanyName 'Cofl' -Name 'OSDManagement' -SkipCreatingFolder
    if($PSCmdlet.ShouldProcess("OSDManagement Configuration at ""$Path""", 'Update'))
    {
        Export-Configuration @Parameters
    }
}
