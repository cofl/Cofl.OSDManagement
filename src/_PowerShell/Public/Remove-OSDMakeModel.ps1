<#
.SYNOPSIS
Removes a MakeModel from the MDT Database and destages it.

.DESCRIPTION
The Remove-OSDMakeModel cmdlet deletes a MakeModel from the MDT Database.

.EXAMPLE
PS C:\> Remove-OSDMakeModel 'Optiplex 780'
Removes the MakeModel "Optiplex 780" from the MDT Database.
#>
function Remove-OSDMakeModel
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    PARAM(
        [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
            [Alias('MakeModel')]
            # One or more MakeModel identities.
            [MakeModelBinding[]]$Model
    )

    begin
    {
        Assert-OSDConnected
    }

    process
    {
        foreach($MakeModelItem in (Resolve-MakeModelBinding -Bindings $Model))
        {
            if($PSCmdlet.ShouldProcess($MakeModelItem, "Remove from MDT and destage it in AD"))
            {
                $null = Invoke-SQLScalar -Query @'
                    set XACT_ABORT ON;
                    begin transaction
                        delete from MakeModelIdentity where ID=@ID;
                        delete from Settings where Type='M' and ID=@ID;
                    commit
'@ -Parameters @{ '@ID' = $MakeModelItem.InternalID }
                Write-Verbose "Removed MakeModel ""$MakeModelItem"" with ID $($MakeModelItem.InternalID) from the MDT Database"
            }
        }
    }

    end
    {
        # update the caches, because we removed at least one model.
        Update-OSDAutoCompleteCache
    }
}
