<#
.SYNOPSIS
Tests if a computer meets certain properties.

.DESCRIPTION
When provided with a computer identity (a name, asset tag, MAC address, or GUID), check if the computer exists in MDT or is staged in ActiveDirectory.

.EXAMPLE
PS C:\> Test-OSDComputer -Exists 0000
Checks if the computer with the asset tag 0000 is in the MDT database.

.EXAMPLE
PS C:\> Test-OSDComputer -Staged 0000
Checks if the computer with the asset tag 0000 is staged in ActiveDirectory (it must exist to be staged).
#>
function Test-OSDComputer
{
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
            # A computer identity, such as an asset tag, Guid, MacAddress, or object returned by Get-OSDComputer
            [OSDComputerBinding]$Identity,
        [Parameter(Mandatory=$true, ParameterSetName='TestExists')]
            # Test if a computer exists.
            [switch]$Exists,
        [Parameter(Mandatory=$true, ParameterSetName='TestStaged')]
            # Test if a computer is staged.
            [switch]$Staged
    )

    begin
    {
        Assert-OSDConnected
    }

    process
    {
        try
        {
            [OSDComputer]$ComputerObject = Resolve-OSDComputerBinding -Bindings @($Identity) -ErrorAction Stop
            return ($PSCmdlet.ParameterSetName -eq 'TestExists') -or $ComputerObject.IsStaged
        } catch
        {
            return $false
        }
    }
}
