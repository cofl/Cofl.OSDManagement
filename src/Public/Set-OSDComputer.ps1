using namespace System;
using namespace System.Collections.Generic;
using namespace System.Text;

<#
.SYNOPSIS
Sets properties for a computer in the MDT database.

.DESCRIPTION
The Set-OSDComputer cmdlet sets properties for a computer in the MDT Database.

Parameters are provided for the most common cases. Other properties can be set via the Settings hashtable, or the Clear list.

Priority is given to the parameters for individual settings, then the -Clear list, then the -Settings table.

It is not possible to update the AssetTag, SerialNumber, Type, or ID of a computer.

.EXAMPLE
PS C:\> Set-OSDComputer $ComputerObjectForSurfaceProWithNoStableMacAddress -UUID '00000000-0000-0000-0000-000000000000'
Sets the UUID on a computer object that didn't previously have one.

#>
function Set-OSDComputer
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('OSDComputer')]
    PARAM(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][Alias('ComputerName')]
            # A computer object or identity, such as the name, the asset tag, the MAC address, or the object retrieved by Get-OSDComputer.
            [OSDComputerBinding]$Identity,
        [Parameter()][ValidateNotNullOrEmpty()]
            # The name for a computer.
            [string]$Name,
        [Parameter()][ValidateNotNullOrEmpty()]
            # A task sequence, either a string ID or one retrieved by Get-OSDTaskSequence.
            [TaskSequenceBinding]$TaskSequence,
        [Parameter()][ValidateNotNullOrEmpty()]
            # A Driver Group for the machine, usually specified alonsgide -TaskSequence when the operating system of the override sequence is not the same as the Model default.
            [string]$DriverGroup,
        [Parameter()]
            # A MacAddress that will be used for staging the computer.
            [MacAddressBinding]$MacAddress,
        [Parameter()]
            # A UUID that will be used for staging the computer.
            [guid]$UUID,
        [Parameter()][ValidateNotNull()]
            # A list of field names to be emptied. If Name is in this list, the computer name and description will be set to the default name for the computer.
            [string[]]$Clear = @(),
        [Parameter()][ValidateNotNull()]
            # A table of other values to set. If Name is in this table, the computer name and description will be set to its value.
            [hashtable]$Settings = @{},
        [Parameter()]
            # If the computer is staged and the netboot GUID is changed by this operation, update the netboot GUID.
            [switch]$UpdateNetbootGUID,
        [Parameter()]
            # Re-fetch the computer modified and spit it out.
            [switch]$PassThru
    )

    begin
    {
        Assert-OSDConnected

        [hashset[string]]$IllegalColumns = [HashSet[string]]::new(([string[]]@('AssetTag', 'SerialNumber', 'Type', 'ID')), [StringComparer]::OrdinalIgnoreCase)
        [Dictionary[string, psobject]]$ValidColumns = [Dictionary[string, psobject]]::new([StringComparer]::OrdinalIgnoreCase)
        [psobject[]]$RawColumnData = @(Invoke-SQLQuery -Query "select COLUMN_NAME as ColumnName, IS_NULLABLE as IsNullable, DATA_TYPE as DataType, CHARACTER_MAXIMUM_LENGTH as MaxLength from INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Settings' OR TABLE_NAME = 'ComputerIdentity'" -Property 'ColumnName', 'ColumnDefault', 'IsNullable', 'DataType', 'MaxLength')
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
        [OSDComputer]$ComputerObject = Resolve-OSDComputerBinding -Bindings @($Identity)
        [string]$ComputerDefaultName = Get-DefaultComputerName -AssetTag $ComputerObject.AssetTag
        [HashSet[string]]$SetToDBNull = [HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

        # Clean up our aliases
        if($Settings.ContainsKey('Name'))
        {
            $Value = $Settings['Name']
            $Settings.Remove('Name')
            Write-Verbose 'Removed Name from Settings.'
            if(!$Settings.ContainsKey('OSDComputerName'))
            {
                $Settings['OSDComputerName'] = $Value
                Write-Verbose 'Used Name value to fill OSDComputerName.'
            }
            if(!$Settings.ContainsKey('Description'))
            {
                $Settings['Description'] = $Value
                Write-Verbose 'Used Name value to fill Description.'
            }
        }
        if($Settings.ContainsKey('GUID'))
        {
            $Value = $Settings['GUID']
            $Settings.Remove('GUID')
            Write-Verbose 'Removed GUID from Settings.'
            if(!$Settings.ContainsKey('UUID'))
            {
                $Settings['UUID'] = $Value
                Write-Verbose 'Used GUID value to fill UUID.'
            }
        }
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
            if($ClearSet.Contains('Name'))
            {
                [void]$ClearSet.Add('Name')
                [void]$ClearSet.Add('OSDComputerName')
                [void]$ClearSet.Add('Description')
                Write-Verbose 'Removed Name from Clear, added OSDComputerName and Description.'
            }
            if($ClearSet.Contains('GUID'))
            {
                [void]$ClearSet.Remove('GUID')
                [void]$ClearSet.Add('UUID')
                Write-Verbose 'Removed GUID from Clear, added UUID.'
            }
            if($ClearSet.Contains('TaskSequence'))
            {
                [void]$ClearSet.Remove('TaskSequence')
                [void]$ClearSet.Add('TaskSequenceID')
                Write-Verbose 'Removed TaskSequence from Clear, added TaskSequenceID'
            }

            # Validate/Merge Clear into Settings
            foreach($Key in $Clear)
            {
                if($Key -eq 'TaskSequence')
                {
                    $Key = 'TaskSequenceID'
                } elseif($Key -eq 'Name')
                {
                    $Settings['OSDComputerName'] = $ComputerDefaultName
                    $Settings['Description'] = $ComputerDefaultName
                    continue
                }
                if(!$ValidColumns.ContainsKey($Key) -or $IllegalColumns.Contains($Key))
                {
                    throw [ArgumentException]::new("Illegal column name ""$Key"" for table ""Settings"".", 'Clear');
                } else
                {
                    if($Key -eq 'OSDComputerName')
                    {
                        $Settings['OSDComputerName'] = $ComputerDefaultName
                    } elseif($Key -eq 'Description')
                    {
                        $Settings['Description'] = $ComputerDefaultName
                    } elseif($ValidColumns[$Key].IsNullable)
                    {
                        [void]$SetToDBNull.Add($Key)
                        $Settings[$Key] = $null
                    } else
                    {
                        $Settings[$Key] = [string]::Empty
                    }

                    if($null -eq $Settings[$Key])
                    {
                        Write-Verbose "Merged Clear key ""$Key"" into settings with value null."
                    } else
                    {
                        Write-Verbose "Merged Clear key ""$Key"" into settings with value ""$($Settings[$Key])""."
                    }
                }
            }
        }

        # Now process settings from bound parameters.
        if($PSBoundParameters.ContainsKey('Name'))
        {
            $Settings['OSDComputerName'] = $Name
            $Settings['Description'] = $Name
            [void]$SetToDBNull.Remove('OSDComputerName')
            [void]$SetToDBNull.Remove('Description')
            Write-Verbose "Used value of Name parameter to set OSDComputerName and Description."
        }

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

        if($PSBoundParameters.ContainsKey('MacAddress'))
        {
            $Settings['MacAddress'] = Format-MacAddressForMDT -MacAddress $MacAddress.Address
            [void]$SetToDBNull.Remove('MacAddress')
            Write-Verbose "Used value of MacAddress parameter to set MacAddress."
        }

        if($PSBoundParameters.ContainsKey('UUID'))
        {
            $Settings['UUID'] = $UUID
            [void]$SetToDBNull.Remove('UUID')
            Write-Verbose "USed value of UUID paramter to set UUID."
        }

        # Now that we have everything processed, validate data types for known values.
        if($Settings.ContainsKey('TaskSequenceID') -and ![string]::IsNullOrEmpty($Settings['TaskSequenceID']))
        {
            $Value = Resolve-TaskSequenceBinding -Bindings $Settings['TaskSequenceID'] -ErrorAction Stop
            $Settings['TaskSequenceID'] = $Value.ID
            Write-Verbose "Validated TaskSequenceID to ""$($Settings['TaskSequenceID'])""."
        }

        if($Settings.ContainsKey('MacAddress') -and ![string]::IsNullOrEmpty($Settings['MacAddress']))
        {
            $Value = Format-MacAddressForMDT -Address [MacAddressBinding]::new($Settings['MacAddress']).Address
            $Settings['MacAddress'] = $Value
            Write-Verbose "Validated MacAddress to ""$($Settings['MacAddress'])""."
        }

        if($Settings.ContainsKey('UUID') -and ![string]::IsNullOrEmpty($Settings['UUID']))
        {
            [guid]$Guid = [guid]::Parse($Settings['UUID'])
            $Settings['UUID'] = $Guid.ToString()
            Write-Verbose "Validated UUID to ""$($Settings['UUID'])""."
        }

        # Some values need to be set to DBNull
        foreach($Key in $SetToDBNull)
        {
            $Settings[$Key] = [DBNull]::Value
            Write-Verbose "Set ""$Key"" from null to DBNull."
        }

        # Some settings are in ComputerIdentity instead of Settings.
        [Dictionary[string, object]]$IdentitySettings = [Dictionary[string, object]]::new()
        foreach($Item in @('Description', 'AssetTag', 'UUID', 'SerialNumber', 'MacAddress'))
        {
            if($Settings.ContainsKey($Item))
            {
                $IdentitySettings[$Item] = $Settings[$Item]
                $Settings.Remove($Item)
                Write-Debug "Moved value of key ""$Item"" to IdentitySettings."
            }
        }

        # Now, set values in the database
        if($PSCmdlet.ShouldProcess($ComputerObject.ComputerName, "Update the computer's settings."))
        {
            [hashtable]$Parameters = @{ '@ID' = $ComputerObject.InternalID }
            if($IdentitySettings.Count -gt 0)
            {
                [string]$IdentityUpdate = 'update ComputerIdentity set ' + [string]::Join(', ', ($IdentitySettings.Keys | ForEach-Object {
                    $Parameters["@Identity$_"] = $IdentitySettings[$_]
                    "$_ = @Identity$_"
                })) + ' where ID=@ID;'
            }
            if($Settings.Count -gt 0)
            {
                [string]$SettingsUpdate = 'update Settings set ' + [string]::Join(', ', ($Settings.Keys | ForEach-Object {
                    $Parameters["@Settings$_"] = $Settings[$_]
                    "$_ = @Settings$_"
                })) + ' where Type=''C'' and ID=@ID'
            }

            $null = Invoke-SQLScalar -Query @"
                set XACT_ABORT ON;
                begin transaction
                    $IdentityUpdate
                    $SettingsUpdate
                commit
"@ -Parameters $Parameters

            # Check if the netboot guid has changed
            if($IdentitySettings.ContainsKey('MacAddress') -or $IdentitySettings.ContainsKey('UUID'))
            {
                $ComputerObject = Get-OSDComputer -InternalID $ComputerObject.InternalID
                if($ComputerObject.IsStaged)
                {
                    $ADGuid = (Get-ADComputer -Filter "Name -eq '$($ComputerObject.ComputerName)'" -Properties netbootGUID).netbootGUID
                    if($null -ne $ADGuid -and $ComputerObject.GetValidNetbootGUID() -ne [guid][byte[]]$ADGuid)
                    {
                        if($UpdateNetbootGUID)
                        {
                            Write-Warning "Netboot GUID for staged computer ""$object"" is not valid, updating."
                            $ComputerObject = Set-OSDComputerState -Identity $object -State Staged -PassThru
                        } else
                        {
                            Write-Warning "Netboot GUID for staged computer ""$object"" is not valid."
                        }
                    }
                }
            } elseif($PassThru)
            {
                # always fetch the updated object.
                $ComputerObject = Get-OSDComputer -InternalID $ComputerObject.InternalID
            }

            if($PassThru)
            {
                Write-Output $ComputerObject
            }
        }
    }
}
