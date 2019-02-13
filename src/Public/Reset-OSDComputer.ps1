using namespace System.Collections.Generic;

<#
.SYNOPSIS
Clears properties for a computer in the MDT database.

.DESCRIPTION
The Reset-OSDComputer cmdlet clears a limited set of properties; it is less flexible than Set-OSDComputer, but is better for bulk processing because the set of properties changed can be verified before proceeding.

.EXAMPLE
PS C:\> Reset-OSDComputer 1234, 'test-server' -Property Name
Resets the names of the computers with the asset tag 1234 and the name 'test-server' to the defaults generated from their asset tag.

.EXAMPLE
PS C:\> Get-OSDComputer | ? {$_.TaskSequence} | Reset-OSDComputer -Property TaskSequence
Gathers all computers with a task sequence set and clears that property; in the future, if they are staged and imaged, they will use the default for their model.
#>
function Reset-OSDComputer
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('OSDComputer')]
    PARAM(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)][Alias('ComputerName')]
            # A computer object or identity, such as the name, the asset tag, the MAC address, or the object retrieved by Get-OSDComputer.
            [OSDComputerBinding[]]$Identity,
        [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
            [ValidateSet('Name', 'TaskSequence', 'DriverGroup')]
            [ValidateCount(1, 3)]
            # Specifies the properties to clear. Wildcards are not permitted.
            [string[]]$Property = @('Name', 'TaskSequence'),
        [Parameter()]
            # If present, pass the computer object through after refreshing.
            [switch]$PassThru
    )

    begin
    {
        Assert-OSDConnected
    }

    process
    {
        foreach($Computer in $Identity)
        {
            # Delegate to Set-OSDComputer because it already has the logic for guaranteeing things go well.
            Set-OSDComputer -Identity $Computer -Clear $Property -PassThru:$PassThru -Verbose:$VerbosePreference
        }
    }
}
