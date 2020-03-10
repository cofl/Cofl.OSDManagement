<#
.SYNOPSIS
Remotely invoke a reboot to a network adapter.

.DESCRIPTION
The Invoke-ReimageComputer cmdlet remotely invokes a reboot to a network adapter.

The cmdlet will stage the computer, passing the paramters -CreateADComputerIfMissing, -OrganizationalUnit, and -MoveADComputer to Set-OSDComputerState.

If -TaskSequence is provided, the task sequence will be updated before rebooting.

This cmdlet requires remoting to be enabled; you should be able to run Invoke-Command on the target machine, and you should be able to use bcdedit on the target machine.

Tested on a handful of Lenovo desktops and laptops, your mileage may vary.

.EXAMPLE
PS C:\> Invoke-ReimageComputer -Identity 1234 -CreateADComputerIfMissing
Stage the computer 1234, creating it if it doesn't exist, then remotely invoke a reimage.
#>
function Invoke-ReimageComputer
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('OSDComputer')]
    PARAM(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
            # A computer object or identity, such as the name, the asset tag, the MAC address, or the object retrieved by Get-OSDComputer.
            [OSDComputerBinding[]]$Identity,
        [Parameter()]
            # If a computer object does not exist in ActiveDirectory, create it.
            [switch]$CreateADComputerIfMissing,
        [Parameter()][Alias('OU')]
            # The computer will be created or moved to this OU.
            [string]$OrganizationalUnit,
        [Parameter()]
            # If a computer is not the OU (default in the module private data), move it there.
            [switch]$MoveADComputer,
        [Parameter()][ValidateNotNullOrEmpty()]
            # A task sequence, either a string ID or one retrieved by Get-OSDTaskSequence.
            [TaskSequenceBinding]$TaskSequence,
        [Parameter()]
            # Pass through an updated copy of the computer.
            [switch]$PassThru
    )

    begin
    {
        Assert-OSDConnected
    }

    process
    {
        [OSDComputer[]]$ComputerObjects = Resolve-OSDComputerBinding -Bindings $Identity
        foreach($ComputerItem in $ComputerObjects)
        {
            if([string]::IsNullOrEmpty($OrganizationalUnit))
            {
                $OrganizationalUnit = $Script:OSDDefaultOU
            }
            if($PSCmdlet.ShouldProcess($ComputerItem.ComputerName))
            {
                $BootDevice = Invoke-Command -ComputerName $ComputerItem.ComputerName -ScriptBlock {
                    # Matches the guid of the LAN device: this is either "UEFI: IP(V)4" something-or-other, or "PCI LAN", or
                    # IP4 or IPv4 on the description line
                    if("$(bcdedit /enum ALL)" -match '({[^}]+})\s*description\s+(?:UEFI:\s+IP\S*4|PCI LAN\b|[^\r\n]*IPv?4)')
                    {
                        $Matches[1]
                    } else
                    {
                        $null
                    }
                }
                if(!$BootDevice)
                {
                    Write-Error -Message "Could not identify network boot device for $ComputerItem" -ErrorAction $ErrorActionPreference
                } else
                {
                    if($PSBoundParameters.ContainsKey('TaskSequence'))
                    {
                        Set-OSDComputer -Identity $ComputerItem -TaskSequence $TaskSequence -Verbose:$VerbosePreference
                    }
                    Set-OSDComputerState -State Staged -Identity $ComputerItem -Verbose:$VerbosePreference -CreateADComputerIfMissing

                    Invoke-Command -ComputerName $ComputerItem.ComputerName -ScriptBlock {
                        bcdedit /default $args[0]
                        bcdedit /set '{fwbootmgr}' BOOTSEQUENCE '{default}'
                    } -Verbose:$VerbosePreference -ArgumentList $BootDevice | Write-Verbose
                    $null = Restart-Computer -ComputerName $ComputerItem.ComputerName -Verbose:$VerbosePreference
                    if($PassThru)
                    {
                        Get-OSDComputer -InternalID $ComputerItem.InternalID
                    }
                }
            }
        }
    }
}
