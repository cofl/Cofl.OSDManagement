<#
.SYNOPSIS
Removes a computer from the MDT Database and destages it.

.DESCRIPTION
The Remove-OSDComputer cmdlet deletes a computer from the MDT Database.
If the computer was staged, it is destaged.

If the DeleteADComputer parameter is supplied, and the computer was present in Active Directory, the computer is also deleted from ActiveDirectory.

.EXAMPLE
PS C:\> Remove-OSDComputer 1234
Removes computer 1234 from the MDT database and destages it if it was staged.

.EXAMPLE
PS C:\> Remove-OSDComputer 1234 -DeleteADComputer
Removes computer 1234 from the MDT database and deletes it from ActiveDirectory.
#>
function Remove-OSDComputer
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    PARAM(
        [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
            # One or more computer identities, such as the name, asset tag, MAC address, GUID, or OSDComputer object.
            [OSDComputerBinding[]]$Identity,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            # Notes that the listed computers should also be removed from Active Directory if they exist.
            [switch]$DeleteADComputer
    )

    begin
    {
        Assert-OSDConnected
    }

    process
    {
        foreach($ComputerItem in (Resolve-OSDComputerBinding -Bindings $Identity))
        {
            if($PSCmdlet.ShouldProcess($ComputerItem, "Remove from MDT and destage it in AD"))
            {
                try
                {
                    if($ComputerItem.IsStaged)
                    {
                        $object = Get-ADComputer $ComputerItem.ComputerName -ErrorAction Stop
                        Set-ADComputer $object -Clear netbootGUID
                        Write-Verbose "Cleared the netbootGUID of $($object.DistinguishedName)"
                    }

                    if($DeleteADComputer -and $ComputerItem.IsADComputerPresent -and $PSCmdlet.ShouldProcess($ComputerItem, "Delete from AD"))
                    {
                        $object = Get-ADComputer $ComputerItem.ComputerName -ErrorAction Stop
                        Remove-ADComputer $object
                        Write-Verbose "Removed ADComputer $($object.DistinguishedName)"
                    }
                    $null = Invoke-SQLScalar -Query @'
                        set XACT_ABORT ON;
                        begin transaction
                            delete from ComputerIdentity where ID=@ID;
                            delete from Settings where Type='C' and ID=@ID;
                        commit
'@ -Parameters @{ '@ID' = $ComputerItem.InternalID }
                    Write-Verbose "Removed computer $($ComputerItem.AssetTag) with ID $($ComputerItem.InternalID) from the MDT Database"
                } catch
                {
                    throw "No such ADComputer $ComputerItem while removing"
                }
            }
        }
    }
}
