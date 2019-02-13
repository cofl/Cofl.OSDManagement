using namespace System.Data.SqlClient;

<#
.SYNOPSIS
Tears down the OSD Script environment.

.DESCRIPTION
The Disconnect-OSD cmdlet tears down open connections and cleans up the OS Deployment script environment.
Any connections to the MDT Database are destroyed.
After calling this, Connect-OSD must be called again before other cmdlets may be used.

.EXAMPLE
PS C:\> Disconnect-OSD
Closes any open connections and cleans up.
#>
function Disconnect-OSD
{
    [CmdletBinding()]
    PARAM ( )

    try
    {
        if($null -ne $Script:OSDScriptsSQLConnection)
        {
            $Script:OSDScriptsSQLConnection.Dispose()
            $Script:OSDScriptsSQLConnection = $null
        }
    } catch
    {
        Write-Warning $_
    }

    $Script:OSDDefaultOU = $null
    $Script:OSDComputerNameTemplate = [string]::Empty
    $Script:OSDScriptsSQLConnection = $null
    $Script:OSDScriptsSQLConnectString = $null
    $Script:OSDScriptsMDTRoot = $null
    $Script:CacheTaskSequenceID = @()
    $Script:CacheTaskSequenceGroups = @()
    $Script:CacheDriverGroups = @()
    $Script:CacheMakes = @()
    $Script:CacheModels = @()
    $Script:OSDIsConnected = $false
}
