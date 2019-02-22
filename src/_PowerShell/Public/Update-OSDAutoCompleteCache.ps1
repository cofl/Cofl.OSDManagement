using namespace System.Collections.Generic;

<#
.SYNOPSIS
Rebuilds the caches used for tab completion.

.DESCRIPTION
Gathers information from the MDT configuration and database to support tab completion. Run this cmdlet if changes have been made to the database or config.

.EXAMPLE
PS C:\> Update-OSDAutoCompleteCache
There isn't really anything else this does.
#>
function Update-OSDAutoCompleteCache
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    PARAM (
    )

    Assert-OSDConnected

    if($PSCmdlet.ShouldProcess('OSDManagement AutoComplete cache', 'Update'))
    {
        $Script:CacheTaskSequenceID = [string[]]@(([xml](Get-Content "$Script:OSDScriptsMDTRoot\Control\TaskSequences.xml")).tss.ts.ID)
        Write-Verbose "TaskSequenceID cache: $($Script:CacheTaskSequenceID -join ', ')"

        $Script:CacheTaskSequenceGroups = [string[]]@(([xml](Get-Content "$Script:OSDScriptsMDTRoot\Control\TaskSequenceGroups.xml")).groups.group.Name)
        Write-Verbose "TaskSequenceGroups cache: $($Script:CacheTaskSequenceGroups -join ', ')"

        $TempData = ([xml](Get-Content "$Script:OSDScriptsMDTRoot\Control\DriverGroups.xml")).groups.group
        $Set = [hashset[string]]::new()
        $ParentsSet = [hashset[string]]::new()
        foreach($Group in $TempData)
        {
            if($Group.Name -eq 'default' -or $Group.Name -eq 'hidden')
            {
                continue
            }
            [void]$Set.Add($Group.Name)
            $TempName = Split-Path $Group.Name
            while(![string]::IsNullOrEmpty($TempName))
            {
                [void]$ParentsSet.Add($TempName)
                $TempName = Split-Path $TempName
            }
        }
        $Set.ExceptWith($ParentsSet) # we only want the leaves
        $Script:CacheDriverGroups = [string[]]@($Set | Sort-Object)
        Write-Verbose "DriverGroups cache is: $($Script:CacheDriverGroups -join ', ')"

        $Rows = Invoke-SQLQuery -Query 'SELECT Make,Model FROM MakeModelSettings' -Property Make, Model
        $Script:CacheMakes = [hashset[string]]::new([string[]]$Rows.Make)
        $Script:CacheModels = [hashset[string]]::new([string[]]$Rows.Model)
        Write-Verbose "Make cache is: $($Script:CacheMakes -join ', ')"
        Write-Verbose "Model cache is: $($Script:CacheModels -join ', ')"
    }
}
