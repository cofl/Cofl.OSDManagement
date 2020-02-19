# This is a set of cmdlets for the management of the MDT and WDS databases (MSSQL & AD).

using namespace System.Diagnostics.CodeAnalysis;
using namespace System.Collections;
using namespace System.Collections.Generic;
using namespace System.Data;
using namespace System.Data.SqlClient;
using namespace System.Net.NetworkInformation;
using namespace System.Management.Automation;

# Internal globals
[Nullable[bool]]$Script:OSDIsConnected = $false
[string]$Script:OSDScriptsMDTRoot = $null
[string]$Script:OSDScriptsSQLConnectString = $null
[string]$Script:OSDComputerNameTemplate = [string]::Empty
[SqlConnection]$Script:OSDScriptsSQLConnection = $null
[string[]]$Script:CacheTaskSequenceID = @()
[string[]]$Script:CacheTaskSequenceGroups = @()
[string[]]$Script:CacheDriverGroups = @()
[string[]]$Script:CacheMakes = @()
[string[]]$Script:CacheModels = @()

function Get-Config
{
    [CmdletBinding()] PARAM ()
    Import-Configuration -CompanyName 'Cofl' -Name 'OSDManagement'
}

function Assert-OSDConnected
{
    if(!$Script:OSDIsConnected)
    {
        throw [OSDNotConnectedException]::new()
    }
}

function Format-MacAddressForMDT
{
    PARAM (
        [Parameter(Mandatory = $true, Position = 0)][PhysicalAddress]$MacAddress
    )

    if($null -eq $MacAddress)
    {
        return [string]::Empty
    }
    return [string]::Format('{0:X2}:{1:X2}:{2:X2}:{3:X2}:{4:X2}:{5:X2}', [object[]]$MacAddress.GetAddressBytes())
}

function Format-GuidForLDAPFilter
{
    [CmdletBinding(DefaultParameterSetName='FromGuid')]
    PARAM (
        [Parameter(ParameterSetName='FromGuid')][Nullable[Guid]]$Guid = $null,
        [Parameter(ParameterSetName='FromMacAddress')][MacAddressBinding]$MacAddress = $null
    )

    if($null -ne $MacAddress.Address)
    {
        return [string]::Format('\00\00\00\00\00\00\00\00\00\00\{0:x2}\{1:x2}\{2:x2}\{3:x2}\{4:x2}\{5:x2}', [object[]]$MacAddress.Address.GetAddressBytes())
    } elseif($null -ne $Guid)
    {
        return [string]::Format('\{0:x2}\{1:x2}\{2:x2}\{3:x2}\{4:x2}\{5:x2}\{6:x2}\{7:x2}\{8:x2}\{9:x2}\{10:x2}\{11:x2}\{12:x2}\{13:x2}\{14:x2}\{15:x2}', [object[]]$Guid.ToByteArray())
    } else
    {
        return [string]::Empty
    }
}

function Get-DefaultComputerName
{
    PARAM (
        [Parameter(Mandatory = $true, Position = 0)][int]$AssetTag
    )

    return $Script:OSDComputerNameTemplate -f $AssetTag
}

# Cleanup
function Set-OnRemove {
    [SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Only used internally.')]
    [CmdletBinding()]
    PARAM (
    )

    $PSCmdlet.MyInvocation.MyCommand.Module.OnRemove = {
        Disconnect-OSD
    }
}
Set-OnRemove

# Import classes
Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 -File | ForEach-Object {
    . $_.FullName
}
$Accelerator = [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
$Accelerator::Remove('OSDComputer')
$Accelerator::Remove('OSDMakeModel')
$Accelerator::Remove('OSDTaskSequence')
$Accelerator::Remove('OSDTaskSequenceGroup')
$Accelerator::Remove('MacAddressBinding')
$Accelerator::Remove('TaskSequenceBinding')
$Accelerator::Remove('OSDComputerBinding')
$Accelerator::Add('OSDComputer', [OSDComputer])
$Accelerator::Add('OSDMakeModel', [OSDMakeModel])
$Accelerator::Add('OSDTaskSequence', [OSDTaskSequence])
$Accelerator::Add('OSDTaskSequenceGroup', [OSDTaskSequenceGroup])
$Accelerator::Add('MacAddressBinding', [MacAddressBinding])
$Accelerator::Add('TaskSequenceBinding', [TaskSequenceBinding])
$Accelerator::Add('OSDComputerBinding', [OSDComputerBinding])

# Declare private functions
function Invoke-SQLQuery
{
    [CmdletBinding(DefaultParameterSetName = 'AsDictionary')]
    PARAM
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'AsDictionary')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Properties')]
            [ValidateNotNullOrEmpty()][string]$Query,
        [Parameter(ParameterSetName = 'AsDictionary')]
        [Parameter(ParameterSetName = 'Properties')]
            [ValidateNotNullOrEmpty()][hashtable]$Parameters,
        [Parameter(Mandatory = $true, ParameterSetName = 'AsDictionary')]
            [switch]$AsDictionary,
        [Parameter(Mandatory = $true, ParameterSetName = 'Properties')]
            [ValidateNotNullOrEmpty()][string[]]$Property
    )

    Assert-OSDConnected

    try
    {
        [SqlCommand]$Command = [SqlCommand]::new($Query, $Script:OSDScriptsSQLConnection)
        if($null -ne $Parameters -and $Parameters.Count -gt 0)
        {
            foreach($Key in $Parameters.Keys)
            {
                if($null -eq $Parameters[$Key])
                {
                    [void]$Command.Parameters.AddWithValue($Key, [DBNull]::Value)
                } else
                {
                    [void]$Command.Parameters.AddWithValue($Key, $Parameters[$Key])
                }
            }
        }

        [SqlDataAdapter]$Adapter = [SqlDataAdapter]::new($Command)
        [DataSet]$DataSet = [DataSet]::new()
        [void]$Adapter.Fill($DataSet)
        foreach($Table in $DataSet.Tables)
        {
            if($null -eq $Table.Rows)
            {
                continue
            }
            foreach($Row in $Table.Rows)
            {
                if($AsDictionary)
                {
                    [Dictionary[string, object]]$Dictionary = [Dictionary[string, object]]::new()
                    foreach($Column in $Table.Columns)
                    {
                        $Dictionary[$Column.ColumnName] = $Row[$Column]
                    }
                    Write-Output -InputObject $Dictionary -NoEnumerate
                } else
                {
                    if($Property.Count -eq 1)
                    {
                        Write-Output -InputObject $Row[$Property] -NoEnumerate
                    } else
                    {
                        Write-Output -InputObject ($Row | Select-Object -Property $Property) -NoEnumerate
                    }
                }
            }
        }
    } finally
    {
        if($null -ne $DataSet)
        {
            $DataSet.Dispose()
        }

        if($null -ne $Adapter)
        {
            $Adapter.Dispose()
        }

        if($null -ne $Command)
        {
            $Command.Dispose()
        }
    }
}

function Invoke-SQLScalar
{
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory = $true)][ValidateNotNull()][string]$Query,
        [Parameter()][ValidateNotNullOrEmpty()][hashtable]$Parameters
    )

    Assert-OSDConnected

    try
    {
        [SqlCommand]$Command = [SqlCommand]::new($Query, $Script:OSDScriptsSQLConnection)
        if($null -ne $Parameters -and $Parameters.Count -gt 0)
        {
            foreach($Key in $Parameters.Keys)
            {
                if($null -eq $Parameters[$Key])
                {
                    [void]$Command.Parameters.AddWithValue($Key, [DBNull]::Value)
                } else
                {
                    [void]$Command.Parameters.AddWithValue($Key, $Parameters[$Key])
                }
            }
        }
        Write-Output $Command.ExecuteScalar()
    } finally
    {
        if ($Command)
        {
            $Command.Dispose()
        }
    }
}

# Import public functions
Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -File | ForEach-Object {
    . $_.FullName
}

####
##  Completers
####

function TaskSequenceIDCompleter {
    PARAM ($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameter)

    $Script:CacheTaskSequenceID.Where{ $_ -ilike "$WordToComplete*" }.ForEach{
        $Fill = if($_.Contains(' ')){"'$_'"} else { $_ }
        [CompletionResult]::New($Fill, $_, 'ParameterValue', $_)
    }
}
Register-ArgumentCompleter -CommandName Get-OSDTaskSequence -ParameterName ID -ScriptBlock $Function:TaskSequenceIDCompleter
Register-ArgumentCompleter -CommandName New-OSDMakeModel -ParameterName TaskSequence -ScriptBlock $Function:TaskSequenceIDCompleter
Register-ArgumentCompleter -CommandName Set-OSDComputer -ParameterName TaskSequence -ScriptBlock $Function:TaskSequenceIDCompleter
Register-ArgumentCompleter -CommandName Set-OSDMakeModel -ParameterName TaskSequence -ScriptBlock $Function:TaskSequenceIDCompleter
Register-ArgumentCompleter -CommandName Invoke-ReimageComputer -ParameterName TaskSequence -ScriptBlock $Function:TaskSequenceIDCompleter

function TaskSequenceGroupCompleter {
    PARAM ($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameter)

    $Script:CacheTaskSequenceGroups.Where({ $_ -ilike "$WordToComplete*" }).ForEach({
        $Fill = if($_.Contains(' ')){"'$_'"} else {$_}
        [CompletionResult]::New($Fill, $_, 'ParameterValue', $_)
    })
}
Register-ArgumentCompleter -CommandName Get-OSDTaskSequence -ParameterName Group -ScriptBlock $Function:TaskSequenceGroupCompleter

function DriverGroupsCompleter {
    PARAM ($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameter)

    $Script:CacheDriverGroups.Where({ $_ -ilike "$WordToComplete*" }).ForEach({
        $Fill = if($_.Contains(' ')){"'$_'"} else { $_ }
        [CompletionResult]::New($Fill, $_, 'ParameterValue', $_)
    })
}
Register-ArgumentCompleter -CommandName New-OSDMakeModel -ParameterName DriverGroup -ScriptBlock $Function:DriverGroupsCompleter
Register-ArgumentCompleter -CommandName Set-OSDComputer -ParameterName DriverGroup -ScriptBlock $Function:DriverGroupsCompleter
Register-ArgumentCompleter -CommandName Set-OSDMakeModel -ParameterName DriverGroup -ScriptBlock $Function:DriverGroupsCompleter

function MakeCompleter {
    PARAM ($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameter)

    $Script:CacheMakes.Where({ $_ -ilike "$WordToComplete*" }).ForEach({
        $Fill = if($_.Contains(' ')){"'$_'"} else { $_ }
        [CompletionResult]::New($Fill, $_, 'ParameterValue', $_)
    })
}
Register-ArgumentCompleter -CommandName Get-OSDMakeModel -ParameterName Make -ScriptBlock $Function:MakeCompleter


function ModelCompleter {
    PARAM ($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameter)


    $Script:CacheModels.Where({ $_ -ilike "$WordToComplete*" }).ForEach({
        $Fill = if($_.Contains(' ')){"'$_'"} else { $_ }
        [CompletionResult]::New($Fill, $_, 'ParameterValue', $_)
    })
}
Register-ArgumentCompleter -CommandName Get-OSDMakeModel -ParameterName Model -ScriptBlock $Function:ModelCompleter
Register-ArgumentCompleter -CommandName Set-OSDMakeModel -ParameterName Model -ScriptBlock $Function:ModelCompleter
Register-ArgumentCompleter -CommandName Remove-OSDMakeModel -ParameterName Model -ScriptBlock $Function:ModelCompleter

# Do an initial initialization once we've got all the above done.
if((Get-Config).AutoConnectOnImport)
{
    Connect-OSD -UseConfiguredPath
}
