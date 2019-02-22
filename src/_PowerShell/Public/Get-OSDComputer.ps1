using namespace System.Collections.Generic;

<#
.SYNOPSIS
Retrieves one or more computers from the MDT Database.

.DESCRIPTION
When provided with a computer identity (a name, asset tag, MAC address, or GUID), retrieve
the information for the computer from the MDT Database, and from Active Directory to check if it is staged.

If given more than one identity matching the same computer, more than one entry will be returned.

If not given an identity, all computers in the database will be returned.

.EXAMPLE
PS C:\> Get-OSDComputer 0000
Get the computer with the asset tag 0000.

.EXAMPLE
PS C:\> Get-OSDComputer Desktop0000
Get the computer with the name Desktop0000.

.EXAMPLE
PS C:\> Get-OSDComputer '00-00-00-00-00-00'
Gets the computer with the MAC address "00-00-00-00-00-00."

.EXAMPLE
PS C:\> Get-OSDComputer
Gets all computers in the database.

.EXAMPLE
PS C:\> Get-OSDComputer 0000, 0004
Gets the computers with the asset tags 0000 and 0004.
#>
function Get-OSDComputer
{
    [CmdletBinding(DefaultParameterSetName='All', SupportsPaging=$true)]
    [OutputType('OSDComputer')]
    PARAM (
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='ByIdentity', ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
            # The identity of the computer to look up in the database; can be a name, asset tag, MAC address, or GUID.
            [OSDComputerBinding[]]$Identity,
        [Parameter(Mandatory=$true, ParameterSetName = 'ByInternalID')]
            # One or more internal ID numbers for computer objects.
            [int[]]$InternalID
    )
    begin
    {
        Assert-OSDConnected
        [uint64]$Skipped = 0
        [uint64]$Taken = 0
        [bool]$OutputTotalCount = $false
    }

    process
    {
        if($PSCmdlet.ParameterSetName -eq 'All')
        {
            if($PSCmdlet.PagingParameters.IncludeTotalCount -and !$OutputTotalCount)
            {
                $OutputTotalCount = $true
                Write-Output -InputObject [int](Invoke-SQLQuery -Query 'select COUNT(AssetTag) as Amount from ComputerIdentity' -Property 'Amount')
            }
            if($PSCmdlet.PagingParameters.First -gt 0)
            {
                # Fetch all and convert them
                $Query = 'select * from ComputerIdentity inner join Settings on (ComputerIdentity.ID=Settings.ID) where Type=''C'' order by ID'
                if($PSCmdlet.PagingParameters.First -lt [uint64]::MaxValue)
                {
                    $Query += " offset $($PSCmdlet.PagingParameters.Skip) rows fetch next $($PSCmdlet.PagingParameters.First) rows only"
                } elseif($PSCmdlet.PagingParameters.Skip -gt 0)
                {
                    $Query += " offset $($PSCmdlet.PagingParameters.Skip) rows"
                }

                Write-Output -InputObject (Resolve-OSDComputerBinding -Attributes (Invoke-SQLQuery -AsDictionary -Query $Query))
            }
        } elseif($PSCmdlet.ParameterSetName -eq 'ByInternalID')
        {
            if($PSCmdlet.PagingParameters.IncludeTotalCount)
            {
                $OutputTotalCount = $true
                Write-Output 'Unknown total count'
            }
            if($PSCmdlet.PagingParameters.First -gt 0)
            {
                # Fetch all and convert them
                [hashtable]$SQLParameters = @{}
                [string]$Query = 'select * from ComputerIdentity inner join Settings on (ComputerIdentity.ID=Settings.ID) where Type=''C'' ' + [string]::Join(' OR ', (0..$($InternalID.Length-1) | Foreach-Object -Process {
                    [string]$ParameterName = '@ID{0}' -f $_
                    $SQLParameters.Add($ParameterName, $InternalID[$_])
                    "id=$ParameterName"
                })) + ' order by ID'
                $ComputerDictionaries = Invoke-SQLQuery -AsDictionary -Query $Query -Parameters $SQLParameters
                if($Skipped -lt $PSCmdlet.PagingParameters.Skip)
                {
                    if(($Skipped + $InternalID.Length) -gt $PSCmdlet.PagingParameters.Skip)
                    {
                        # we need some of the current list.
                        if(($Skipped + $InternalID.Length) -ge ($PSCmdlet.PagingParameters.Skip + $PSCmdlet.PagingParameters.First))
                        {
                            # Take a chunk out of the middle of this list.
                            $ComputerObjects = Resolve-OSDComputerBinding -Attributes $ComputerDictionaries[($PSCmdlet.PagingParameters.Skip - $Skipped)..($PSCmdlet.PagingParameters.Skip + $PSCmdlet.PagingParameters.First - $Skipped - 1)]
                        } else
                        {
                            # Take a chunk off the end of this list.
                            $ComputerObjects = Resolve-OSDComputerBinding -Attributes $ComputerDictionaries[($PSCmdlet.PagingParameters.Skip - $Skipped)..($ComputerDictionaries.Length - 1)]
                        }
                        $Skipped = $PSCmdlet.PagingParameters.Skip
                    } else
                    {
                        $Skipped += $InternalID.Length
                    }
                } elseif($Taken -lt $PSCmdlet.PagingParameters.First)
                {
                    if(($Taken + $InternalID.Length) -ge $PSCmdlet.PagingParameters.First)
                    {
                        $ComputerObjects = Resolve-OSDComputerBinding -Attributes $ComputerDictionaries[0..($PSCmdlet.PagingParameters.First - $Taken - 1)]
                    } else
                    {
                        $ComputerObjects = Resolve-OSDComputerBinding -Attributes $ComputerDictionaries
                    }
                } else
                {
                    return # we're done here, already taken everything.
                }

                $Taken += $ComputerObjects.Length
                Write-Output -InputObject $ComputerObjects
            }
        } else
        {
            if($PSCmdlet.PagingParameters.IncludeTotalCount -and !$OutputTotalCount)
            {
                $OutputTotalCount = $true
                Write-Output 'Unknown total count'
            }
            if($Skipped -lt $PSCmdlet.PagingParameters.Skip)
            {
                if(($Skipped + $Identity.Length) -gt $PSCmdlet.PagingParameters.Skip)
                {
                    # we need some of the current list.
                    if(($Skipped + $Identity.Length) -ge ($PSCmdlet.PagingParameters.Skip + $PSCmdlet.PagingParameters.First))
                    {
                        # Take a chunk out of the middle of this list.
                        $ComputerObjects = Resolve-OSDComputerBinding -Bindings $Identity[($PSCmdlet.PagingParameters.Skip - $Skipped)..($PSCmdlet.PagingParameters.Skip + $PSCmdlet.PagingParameters.First - $Skipped - 1)]
                    } else
                    {
                        # Take a chunk off the end of this list.
                        $ComputerObjects = Resolve-OSDComputerBinding -Bindings $Identity[($PSCmdlet.PagingParameters.Skip - $Skipped)..($Identity.Length - 1)]
                    }
                    $Skipped = $PSCmdlet.PagingParameters.Skip
                } else
                {
                    $Skipped += $Identity.Length
                }
            } elseif($Taken -lt $PSCmdlet.PagingParameters.First)
            {
                if(($Taken + $Identity.Length) -ge $PSCmdlet.PagingParameters.First)
                {
                    $ComputerObjects = Resolve-OSDComputerBinding -Bindings $Identity[0..($PSCmdlet.PagingParameters.First - $Taken - 1)]
                } else
                {
                    $ComputerObjects = Resolve-OSDComputerBinding -Bindings $Identity
                }
            } else
            {
                return # we're done here, already taken everything.
            }

            $Taken += $ComputerObjects.Length
            Write-Output -InputObject $ComputerObjects
        }
    }
}
