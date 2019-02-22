using namespace System.Text;

<#
.SYNOPSIS
Retrieves one or more models from the MDT database.

.DESCRIPTION
When provided with a computer model, retrieve the information for that model from the MDT Database.
When given a manufacturer, list the information for all the models by that manufacturer.

This information includes the model-default TaskSequence and DriverGroup.

.EXAMPLE
PS C:\> Get-OSDMakeModel |? {!$_.DriverGroup}
List all the models where the driver group has not been set.

.EXAMPLE
PS C:\> Get-OSDMakeModel 20HR000MUS
Get the information for the model "20HR000MUS."
#>
function Get-OSDMakeModel
{
    [CmdletBinding(DefaultParameterSetName='All', SupportsPaging=$true)]
    [OutputType('OSDMakeModel')]
    PARAM (
        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ByModel',ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
            # One or more model names.
            [MakeModelBinding[]]$Model,
        [Parameter(Mandatory=$true,ParameterSetName='ByInternalID')]
            # One or more internal ID numbers for Make/Model objects.
            [int[]]$InternalID,
        [Parameter(Mandatory=$true,ParameterSetName='ByMake')][Alias('Manufacturer')]
            # One or more manufacturer names.
            [string[]]$Make
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
        if($PSCmdlet.ParameterSetName -eq 'ByModel')
        {
            # We already have them through MakeModelBinding
            if($PSCmdlet.PagingParameters.IncludeTotalCount -and !$OutputTotalCount)
            {
                $OutputTotalCount = $true
                Write-Output 'Unknown total count'
            }
            if($Skipped -lt $PSCmdlet.PagingParameters.Skip)
            {
                if(($Skipped + $Model.Length) -gt $PSCmdlet.PagingParameters.Skip)
                {
                    # we need some of the current list.
                    if(($Skipped + $Model.Length) -ge ($PSCmdlet.PagingParameters.Skip + $PSCmdlet.PagingParameters.First))
                    {
                        # Take a chunk out of the middle of this list.
                        $ModelObjects = Resolve-MakeModelBinding -Bindings $Model[($PSCmdlet.PagingParameters.Skip - $Skipped)..($PSCmdlet.PagingParameters.Skip + $PSCmdlet.PagingParameters.First - $Skipped - 1)]
                    } else
                    {
                        # Take a chunk off the end of this list.
                        $ModelObjects = Resolve-MakeModelBinding -Bindings $Model[($PSCmdlet.PagingParameters.Skip - $Skipped)..($Model.Length - 1)]
                    }
                    $Skipped = $PSCmdlet.PagingParameters.Skip
                } else
                {
                    $Skipped += $Model.Length
                }
            } elseif($Taken -lt $PSCmdlet.PagingParameters.First)
            {
                if(($Taken + $Model.Length) -ge $PSCmdlet.PagingParameters.First)
                {
                    $ModelObjects = Resolve-MakeModelBinding -Bindings $Model[0..($PSCmdlet.PagingParameters.First - $Taken - 1)]
                } else
                {
                    $ModelObjects = Resolve-MakeModelBinding -Bindings $Model
                }
            } else
            {
                return # we're done here, already taken everything.
            }

            $Taken += $ModelObjects.Length
            Write-Output -InputObject $ModelObjects
        } elseif($PSCmdlet.ParameterSetName -eq 'ByInternalID')
        {
            if($PSCmdlet.PagingParameters.IncludeTotalCount -and !$OutputTotalCount)
            {
                $OutputTotalCount = $true
                Write-Output 'Unknown total count'
            }
            if($PSCmdlet.PagingParameters.First -gt 0)
            {
                # Fetch all and convert them
                [hashtable]$SQLParameters = @{}
                [string]$Query = 'SELECT * FROM MakeModelSettings WHERE ' + [string]::Join(' OR ', (0..$($InternalID.Length-1) | Foreach-Object -Process {
                    [string]$ParameterName = '@ID{0}' -f $_
                    $SQLParameters.Add($ParameterName, $InternalID[$_])
                    "id=$ParameterName"
                })) + ' ORDER BY id'
                $ModelDictionaries = Invoke-SQLQuery -AsDictionary -Query $Query -Parameters $SQLParameters
                if($Skipped -lt $PSCmdlet.PagingParameters.Skip)
                {
                    if(($Skipped + $InternalID.Length) -gt $PSCmdlet.PagingParameters.Skip)
                    {
                        # we need some of the current list.
                        if(($Skipped + $InternalID.Length) -ge ($PSCmdlet.PagingParameters.Skip + $PSCmdlet.PagingParameters.First))
                        {
                            # Take a chunk out of the middle of this list.
                            $ModelObjects = Resolve-MakeModelBinding -Attributes $ModelDictionaries[($PSCmdlet.PagingParameters.Skip - $Skipped)..($PSCmdlet.PagingParameters.Skip + $PSCmdlet.PagingParameters.First - $Skipped - 1)]
                        } else
                        {
                            # Take a chunk off the end of this list.
                            $ModelObjects = Resolve-MakeModelBinding -Attributes $ModelDictionaries[($PSCmdlet.PagingParameters.Skip - $Skipped)..($ModelDictionaries.Length - 1)]
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
                        $ModelObjects = Resolve-MakeModelBinding -Attributes $ModelDictionaries[0..($PSCmdlet.PagingParameters.First - $Taken - 1)]
                    } else
                    {
                        $ModelObjects = Resolve-MakeModelBinding -Attributes $ModelDictionaries
                    }
                } else
                {
                    return # we're done here, already taken everything.
                }

                $Taken += $ModelObjects.Length
                Write-Output -InputObject $ModelObjects
            }
        } else
        {
            [StringBuilder]$Query = [StringBuilder]::new().Append('SELECT * FROM MakeModelSettings')
            [string]$SQLFilter = [string]::Empty
            [hashtable]$SQLParameters = @{}
            if($PSCmdlet.ParameterSetName -eq 'ByMake')
            {
                # Filter by manufacturer
                if($Make.Count -gt 0)
                {
                    $SQLFilter = ' WHERE ' + [string]::Join(' OR ', (0..$($Make.Length-1) | Foreach-Object -Process {
                        [string]$ParameterName = '@Make{0}' -f $_
                        $SQLParameters.Add($ParameterName, $Make[$_])
                        "Make='$ParameterName'"
                    }))
                }

                $Query.Append($SQLFilter)
            }
            if($PSCmdlet.PagingParameters.IncludeTotalCount)
            {
                Write-Output -InputObject [int](Invoke-SQLQuery -Query "SELECT COUNT(id) as Amount FROM MakeModelIdentity$SQLFilter" -Property Amount -Parameters $SQLParameters)
            }
            if($PSCmdlet.PagingParameters.First -gt 0)
            {
                # Paging
                if($PSCmdlet.PagingParameters.First -lt [uint64]::MaxValue)
                {
                    [void]$Query.Append(' ORDER BY id OFFSET ').Append($PSCmdlet.PagingParameters.Skip).Append(' ROWS FETCH NEXT ').Append($PSCmdlet.PagingParameters.First).Append(' ROWS ONLY')
                } elseif($PSCmdlet.PagingParameters.Skip -gt 0)
                {
                    [void]$Query.Append(' ORDER BY id OFFSET ').Append($PSCmdlet.PagingParameters.Skip).Append(' ROWS')
                }

                Write-Output -InputObject (Resolve-MakeModelBinding -Attributes (Invoke-SQLQuery -AsDictionary -Query $Query.ToString()))
            }
        }
    }
}
