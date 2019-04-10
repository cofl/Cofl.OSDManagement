<#
.SYNOPSIS
Updates the ActiveDirectory state of one or more computers, including whether the computer is staged or unstaged.

.DESCRIPTION
The Set-OSDComputerState cmdlet updates the state of one or more computers in ActiveDirectory. The state managed by this cmdlet
includes the OrganizationalUnit the computer is in and whether or not the computer is staged or unstaged. This operation will
fail if there is no corresponding ActiveDirectory object for a computer and the -CreateADComputerIfMissing switch is not provided.

At least one state change operation must be provided (create, move, or set staged state); otherwise, a warning will be displayed and no action will occur.

.EXAMPLE
PS C:\> Set-OSDComputerState -Identity 1234 -State Staged -CreateADComputerIfMissing
Stage the computer 1234, creating it if it doesn't exist.

.EXAMPLE
PS C:\> Get-OSDComputer | Set-OSDComputerState -CreateADComputerIfMissing
Create ActiveDirectory objects for all computers in the MDT database if they don't exist.

.EXAMPLE
PS C:\> Set-OSDComputerState -Identity 1234 -State Unstaged
Unstage the computer 1234.

.EXAMPLE
PS C:\> Set-OSDComputerState -Identity 1234 -Staged
Stage the computer 1234.

.EXAMPLE
PS C:\> Set-OSDComputerState -Identity 1234 -Unstaged
Unstage the computer 1234.
#>
function Set-OSDComputerState
{
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName='ByState')]
    [OutputType('OSDComputer')]
    PARAM(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
            # A computer object or identity, such as the name, the asset tag, the MAC address, or the object retrieved by Get-OSDComputer.
            [OSDComputerBinding[]]$Identity,
        [Parameter(ParameterSetName='ByState')]
            # A staging state; Staged if the computer should be able to PXE boot, and unstaged if not.
            [ValidateSet('Staged', 'Unstaged')][string]$State,
        [Parameter(Mandatory=$true, ParameterSetName='ByStagedSwitch')]
            # If the computer should be able to PXE boot.
            [switch]$Staged,
        [Parameter(Mandatory=$true, ParameterSetName='ByUnstagedSwitch')]
            # If the computer should not be able to PXE boot.
            [switch]$Unstaged,
        [Parameter()]
            # If a computer object does not exist in ActiveDirectory, create it.
            [switch]$CreateADComputerIfMissing,
        [Parameter()][Alias('OU')]
            # The computer will be created or moved to this OU.
            [string]$OrganizationalUnit,
        [Parameter()]
            # If a computer is not the OU (default in the module private data), move it there.
            [switch]$MoveADComputer,
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
        if(!($PSBoundParameters.ContainsKey('State') -or $CreateADComputerIfMissing -or $MoveADComputer -or $Staged -or $Unstaged))
        {
            Write-Warning "No state change specified for target(s), skipping Set-OSDComputerState operation."
            return
        }

        [OSDComputer[]]$ComputerObjects = Resolve-OSDComputerBinding -Bindings $Identity
        foreach($ComputerItem in $ComputerObjects)
        {
            if([string]::IsNullOrEmpty($OrganizationalUnit))
            {
                $OrganizationalUnit = $Script:OSDDefaultOU
            }
            if($PSCmdlet.ShouldProcess($ComputerItem.ComputerName))
            {
                $ADComputer = $null
                if(!$ComputerItem.IsADComputerPresent)
                {
                    if($CreateADComputerIfMissing)
                    {
                        $ADComputer = New-ADComputer -Name $ComputerItem.ComputerName -SAMAccountName $ComputerItem.ComputerName -Path $OrganizationalUnit -PassThru -Verbose:$VerbosePreference
                    } else
                    {
                        throw [InvalidOperationException]::new("Cannot stage the computer $ComputerItem that does not exist.")
                    }
                } elseif($MoveADComputer)
                {
                    $ADComputer = Get-ADComputer $ComputerItem.ComputerName
                    if($ComputerItem.DistinguishedName -ne "CN=$($ComputerItem.ComputerName),$OrganizationalUnit")
                    {
                        $ADComputer = Move-ADObject -Identity $ADComputer -TargetPath $OrganizationalUnit -PassThru -Verbose:$VerbosePreference
                    } else
                    {
                        Write-Verbose "$ComputerItem is already in the target OrganizationalUnit, and so won't be moved."
                    }
                } else
                {
                    $ADComputer = Get-ADComputer $ComputerItem.ComputerName
                }

                if($PSBoundParameters.ContainsKey('State') -or $Staged -or $Unstaged)
                {
                    if($State -eq 'Staged' -or $Staged)
                    {
                        [guid]$NetbootGUID = $ComputerItem.GetValidNetbootGUID()
                        [hashtable]$Property = @{ netbootGUID = $NetbootGUID }
                        Set-ADComputer -Identity $ADComputer -Add $Property -Replace $Property -Verbose:$VerbosePreference
                        Write-Verbose "Updating netbootGUID property for ""$($ADComputer.DistinguishedName)"" with value ""$NetbootGUID""."
                    } else
                    {
                        Set-ADComputer -Identity $ADComputer -Clear netbootGUID -Verbose:$VerbosePreference
                        Write-Verbose "Cleared the netbootGUID of $($object.DistinguishedName)"
                    }
                }

                if($PassThru)
                {
                    Get-OSDComputer -InternalID $ComputerItem.InternalID
                }
            }
        }
    }
}
