using namespace System;
using namespace System.Collections.Generic;
using namespace System.Text;

<#
.SYNOPSIS
Sets properties for a Make/Model in the MDT database.

.DESCRIPTION
The Set-OSDMakeModel cmdlet sets properties for a Make/Model in the MDT Database.

Parameters are provided for the most common cases. Other properties can be set via the Settings hashtable, or the Clear list.

Priority is given to the parameters for individual settings, then the -Clear list, then the -Settings table.

It is not possible to update the Make or Model of a Make/Model.

.EXAMPLE
PS C:\> Set-OSDMakeModel $SomeMakeModel -TaskSequence $SomeTaskSequence
Updates the default task sequence for $SomeMakeModel to $SomeTaskSequence.

#>
function Set-OSDMakeModel
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('OSDMakeModel')]
    PARAM(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][Alias('MakeModel')]
            # A Make/Model object or identity, such as the model name or the object retrieved by Get-OSDMakeModel.
            [MakeModelBinding]$Model,
        [Parameter()][ValidateNotNullOrEmpty()]
            # A task sequence, either a string ID or one retrieved by Get-OSDTaskSequence.
            [TaskSequenceBinding]$TaskSequence,
        [Parameter()][ValidateNotNullOrEmpty()]
            # A Driver Group for the make/model, usually specified alongside -TaskSequence when the operating system has changed.
            [string]$DriverGroup,
        [Parameter()][ValidateNotNull()]
            # A list of field names to be emptied.
            [string[]]$Clear = @(),
        [Parameter()][ValidateNotNull()]
            # A table of other values to set.
            [hashtable]$Settings = @{},
        [Parameter()]
            # Re-fetch the make/model modified and spit it out.
            [switch]$PassThru
    )

    begin
    {
        Assert-OSDConnected

        [hashset[string]]$IllegalColumns = [HashSet[string]]::new(([string[]]@('Make', 'Model')), [StringComparer]::OrdinalIgnoreCase)
        [Dictionary[string, psobject]]$ValidColumns = [Dictionary[string, psobject]]::new([StringComparer]::OrdinalIgnoreCase)
        [psobject[]]$RawColumnData = @(Invoke-SQLQuery -Query "select COLUMN_NAME as ColumnName, IS_NULLABLE as IsNullable, DATA_TYPE as DataType, CHARACTER_MAXIMUM_LENGTH as MaxLength from INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Settings' or TABLE_NAME = 'MakeModelIdentity'" -Property 'ColumnName', 'ColumnDefault', 'IsNullable', 'DataType', 'MaxLength')
        foreach($Column in $RawColumnData)
        {
            if($Column.MaxLength -eq [DBNull]::Value)
            {
                $Column.MaxLength = 0
            }
            $ValidColumns[$Column.ColumnName] = [psobject]@{
                IsNullable = $Column.IsNullable -eq 'YES'
                DataType = switch($Column.DataType)
                {
                    'int' { [int] }
                    default { [string] }
                }
                MaxLength = [int]$Column.MaxLength
            }
        }
    }

    process
    {
        [OSDMakeModel]$MakeModelObject = Resolve-MakeModelBinding -Bindings $Model
        [HashSet[string]]$SetToDBNull = [HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

        # Clean up our aliases
        if($Settings.ContainsKey('TaskSequence'))
        {
            $Value = $Settings['TaskSequence']
            $Settings.Remove('TaskSequence')
            Write-Verbose 'Removed TaskSequence from Settings.'
            if(!$Settings.ContainsKey('TaskSequenceID'))
            {
                $Settings['TaskSequenceID'] = $Value
                Write-Verbose 'Used TaskSequence value to fill TaskSequenceID'
            }
        }

        # Validate Settings
        foreach($Key in $Settings.Keys)
        {
            if(!$ValidColumns.ContainsKey($Key) -or $IllegalColumns.Contains($Key))
            {
                throw [ArgumentException]::new("Illegal column name ""$Key"" for table ""Settings"".", 'Settings');
            } else
            {
                if($null -eq $Settings[$Key])
                {
                    if(!$ValidColumns[$Key].IsNullable)
                    {
                        throw [ArgumentException]::new("Illegal null value for ""$Key"" in table ""Settings"".", 'Settings');
                    } else
                    {
                        [void]$SetToDBNull.Add($Key)
                    }
                }
                if($Settings[$Key] -isnot $ValidColumns[$Key].DataType)
                {
                    Write-Verbose "Warning: Type ""$($Settings[$Key].GetType().FullName)"" of value for key ""$Key"" does not match type ""$($ValidColumns[$Key].DataType.FullName)"" detected from table ""Settings""."
                }
            }
        }

        # Validate Clear
        if($null -ne $Clear -and $Clear.Count -gt 0)
        {
            [HashSet[string]]$ClearSet = [HashSet[string]]::new($Clear, [StringComparer]::OrdinalIgnoreCase)

            # Clean up aliases
            if($ClearSet.Contains('TaskSequence'))
            {
                [void]$ClearSet.Remove('TaskSequence')
                [void]$ClearSet.Add('TaskSequenceID')
                Write-Verbose 'Removed TaskSequence from Clear, added TaskSequenceID'
            }

            # Validate/Merge Clear into Settings
            foreach($Key in $Clear)
            {
                if(!$ValidColumns.ContainsKey($Key) -or $IllegalColumns.Contains($Key))
                {
                    throw [ArgumentException]::new("Illegal column name ""$Key"" for table ""Settings"".", 'Clear');
                } else
                {
                    if($ValidColumns[$Key].IsNullable)
                    {
                        [void]$SetToDBNull.Add($Key)
                        $Settings[$Key] = $null
                        Write-Verbose "Merged Clear key ""$Key"" into settings with value null."
                    } else
                    {
                        $Settings[$Key] = [string]::Empty
                        Write-Verbose "Merged Clear key ""$Key"" into settings with value ''."
                    }
                }
            }
        }

        # Now process settings from bound parameters.
        if($PSBoundParameters.ContainsKey('TaskSequence'))
        {
            $Settings['TaskSequenceID'] = (Resolve-TaskSequenceBinding -Bindings $TaskSequence).ID
            [void]$SetToDBNull.Remove('TaskSequenceID')
            Write-Verbose "Used value of TaskSequence parameter to set TaskSequenceID."
        }

        if($PSBoundParameters.ContainsKey('DriverGroup'))
        {
            $Settings['DriverGroup'] = $DriverGroup
            [void]$SetToDBNull.Remove('DriverGroup')
            Write-Verbose "Used value of DriverGroup parameter to set DriverGroup."
        }

        # Now that we have everything processed, validate data types for known values.
        if($Settings.ContainsKey('TaskSequenceID') -and ![string]::IsNullOrEmpty($Settings['TaskSequenceID']))
        {
            $Value = Resolve-TaskSequenceBinding -Bindings $Settings['TaskSequenceID'] -ErrorAction Stop
            $Settings['TaskSequenceID'] = $Value.ID
            Write-Verbose "Validated TaskSequenceID to ""$($Settings['TaskSequenceID'])""."
        }

        # Some values need to be set to DBNull
        foreach($Key in $SetToDBNull)
        {
            $Settings[$Key] = [DBNull]::Value
            Write-Verbose "Set ""$Key"" from null to DBNull."
        }

        # Everything in MakeModelIdentity is in the IllegalKey set, so we don't need to update it like we do in Set-OSDComputer
        # Now, set values in the database
        if($PSCmdlet.ShouldProcess($ComputerObject.ComputerName, "Update the computer's settings."))
        {
            # Update the settings table.
            if($Settings.Count -gt 0)
            {
                [hashtable]$Parameters = @{ '@ID' = $MakeModelObject.InternalID }
                [string]$Query = 'UPDATE Settings SET ' + [string]::Join(', ', (
                    $Settings.Keys | ForEach-Object {
                        $Parameters["@$_"] = $Settings[$_]
                        "$_ = @$_"
                    }
                )) + ' WHERE ID = @ID AND TYPE = ''M'''
                $null = Invoke-SQLScalar -Query $Query -Parameters $Parameters
            }

            if($PassThru)
            {
                Write-Output -InputObject (Get-OSDMakeModel -InternalID $MakeModelObject.InternalID)
            }
        }
    }
}
