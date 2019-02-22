using namespace System;
using namespace System.Collections.Generic;
using namespace System.IO;
using namespace System.Xml;
<#
.SYNOPSIS
Retrieves one or more task sequences from the MDT configuration.

.DESCRIPTION
When provided with a task sequence ID, retrieve that sequence from the MDT configuration.
When given a group, list the sequences in that group.

.EXAMPLE
PS C:\> Get-OSDTaskSequence
List all task sequences.

.EXAMPLE
PS C:\> Get-OSDTaskSequence SERVER2016
Get the task sequence with the ID "SERVER2016."

.EXAMPLE
PS C:\> Get-OSDTaskSequence -Group Install
Gets the task sequences that are direct children of the group "Install."
#>
function Get-OSDTaskSequence
{
    [CmdletBinding(DefaultParameterSetName='All')]
    [OutputType('OSDTaskSequence')]
    PARAM (
        [Parameter(ParameterSetName='ByID',Position=1,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
            # One or more Task Sequence IDs.
            [TaskSequenceBinding[]]$ID,
        [Parameter(ParameterSetName='ByGroup',Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
            # The MDT path to a task sequence group.
            [string[]]$Group
    )

    begin
    {
        Assert-OSDConnected
        [XMLElement[]]$TaskSequences = ([xml][File]::ReadAllText("$Script:OSDScriptsMDTRoot\Control\TaskSequences.xml")).tss.ts
        [xml]$TaskSequenceGroups = [xml][File]::ReadAllText("$Script:OSDScriptsMDTRoot\Control\TaskSequenceGroups.xml")
    }

    process
    {
        if($PSCmdlet.ParameterSetName -eq 'ByID')
        {
            Resolve-TaskSequenceBinding -Bindings $ID | Write-Output
        } else {
            [XMLElement[]]$TaskSequences = ([xml][File]::ReadAllText("$Script:OSDScriptsMDTRoot\Control\TaskSequences.xml")).tss.ts
            [xml]$TaskSequenceGroups = [xml][File]::ReadAllText("$Script:OSDScriptsMDTRoot\Control\TaskSequenceGroups.xml")

            if($PSCmdlet.ParameterSetName -eq 'ByGroup')
            {
                [HashSet[string]]$GroupMembers = [HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
                foreach($Item in ($TaskSequenceGroups.groups.group | Where-Object { $_.Name -iin $Group }))
                {
                    foreach($Member in $Item.Member)
                    {
                        $GroupMembers.Add($Member)
                    }
                }
                $TaskSequences | Where-Object { $GroupMembers.Contains($_.guid) } | ForEach-Object { [OSDTaskSequence]::new($_, $TaskSequences, $TaskSequenceGroups) }
            } else
            {
                $TaskSequences |  ForEach-Object { [OSDTaskSequence]::new($_, $TaskSequences, $TaskSequenceGroups) }
            }
        }
    }
}
