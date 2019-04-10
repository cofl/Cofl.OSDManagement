using namespace Microsoft.ActiveDirectory.Management;
using namespace System.Collections.Generic;
using namespace System.Data;
using namespace System.IO;
using namespace System.Net.NetworkInformation;
using namespace System.Xml;

#region  MacAddressBinding
class MacAddressBinding
{
    [PhysicalAddress]$Address

    MacAddressBinding([string]$AddressString)
    {
        try
        {
            $this.Address = [PhysicalAddress]::Parse($AddressString.Replace([char]':',[char]'-').Replace('.',[string]::Empty).ToUpperInvariant())
        } catch
        {
            $this.Address = $null
        }
    }

    MacAddressBinding([System.DBNull]$DBNull)
    {
        $this.Address = $null
    }

    MacAddressBinding([PhysicalAddress]$PhysicalAddress)
    {
        $this.Address = $PhysicalAddress
    }

    [string] ToString()
    {
        if($null -eq $this.Address)
        {
            return [string]::Empty
        } else
        {
            return $this.Address.ToString()
        }
    }
}
#endregion

#region TaskSequenceBinding
class TaskSequenceBinding
{
    [OSDTaskSequence]$TaskSequence = $null

    [string] $TaskSequenceID

    TaskSequenceBinding([string] $TaskSequenceID)
    {
        $this.TaskSequenceID = $TaskSequenceID
    }

    TaskSequenceBinding([OSDTaskSequence] $TaskSequence)
    {
        $this.TaskSequence = $TaskSequence
    }
}

function Resolve-TaskSequenceBinding
{
    PARAM (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)][AllowEmptyCollection()][AllowNull()][TaskSequenceBinding[]]$Bindings,
        [Parameter()][switch]$UseDummies
    )

    begin
    {
        [XMLElement[]]$TaskSequences = ([xml][File]::ReadAllText("$Script:OSDScriptsMDTRoot\Control\TaskSequences.xml")).tss.ts
        [xml]$TaskSequenceGroups = [xml][File]::ReadAllText("$Script:OSDScriptsMDTRoot\Control\TaskSequenceGroups.xml")
        [Dictionary[string, XmlElement]]$ValidTaskSequences = [Dictionary[string, XmlElement]]::new()
        foreach($Element in $TaskSequences)
        {
            $ValidTaskSequences[$Element.ID] = $Element
        }
    }

    process
    {
        foreach($Item in $Bindings)
        {
            if($null -ne $Item.TaskSequence)
            {
                # Check if not exist and not dummy
                if(!$ValidTaskSequences.ContainsKey($Item.TaskSequence.ID) -and $Item.GUID -ne [guid]::Empty)
                {
                    throw [OSDTaskSequenceNotFoundException]::new($Script:OSDScriptsMDTRoot, $Item.TaskSequence.ID)
                }
                Write-Output -InputObject $Item
            } else
            {
                # Check if not exist
                if(!$ValidTaskSequences.ContainsKey($Item.TaskSequenceID))
                {
                    if($UseDummies)
                    {
                        Write-Output -InputObject ([OSDTaskSequence]::Dummy($Item.TaskSequenceID))
                    } else
                    {
                        throw [OSDTaskSequenceNotFoundException]::new($Script:OSDScriptsMDTRoot, $Item.TaskSequence.ID)
                    }
                } else
                {
                    Write-Output -InputObject ([OSDTaskSequence]::new($ValidTaskSequences[$Item.TaskSequenceID], $TaskSequences, $TaskSequenceGroups))
                }
            }
        }
    }
}
#endregion

#region MakeModelBinding
class MakeModelBinding
{
    [OSDMakeModel]$MakeModel = $null

    [string] $ModelID

    MakeModelBinding([string] $ModelID)
    {
        $this.ModelID = $ModelID
    }

    MakeModelBinding([OSDMakeModel] $MakeModel)
    {
        $this.MakeModel = $MakeModel
    }
}

function Resolve-MakeModelBinding
{
    [CmdletBinding(DefaultParameterSetName = 'Bindings')]
    PARAM (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Bindings')][AllowEmptyCollection()][AllowNull()][MakeModelBinding[]]$Bindings,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Attributes')][AllowEmptyCollection()][AllowNull()][Dictionary[string,object][]]$Attributes
    )

    process
    {
        if($PSCmdlet.ParameterSetName -eq 'Bindings')
        {
            foreach($Item in $Bindings)
            {
                if($null -ne $Item.MakeModel)
                {
                    Write-Output -InputObject $Item.MakeModel
                } else
                {
                    if([string]::IsNullOrEmpty($Item.ModelID))
                    {
                        throw [OSDMakeModelNotFoundException]::new($Script:OSDScriptsMDTRoot, $Item.ModelID)
                    }

                    [Dictionary[string, object]]$AllAttributes = Invoke-SQLQuery -AsDictionary -Query 'SELECT * FROM MakeModelSettings WHERE Model=@Model' -Parameters @{ '@Model' = $Item.ModelID }
                    if($null -eq $AllAttributes)
                    {
                        throw [OSDMakeModelNotFoundException]::new($Script:OSDScriptsMDTRoot, $Item.ModelID)
                    }

                    if(![string]::IsNullOrEmpty($AllAttributes.TaskSequenceID))
                    {
                        [OSDTaskSequence]$TaskSequence = Resolve-TaskSequenceBinding -Binding $AllAttributes.TaskSequenceID -UseDummies
                    } else
                    {
                        [OSDTaskSequence]$TaskSequence = $null
                    }
                    Write-Output -InputObject ([OSDMakeModel]::new($AllAttributes, $TaskSequence))
                }
            }
        } else
        {
            foreach($Item in [object[]]$Attributes)
            {
                [Dictionary[string, object]]$AllAttributes = $Item
                if(![string]::IsNullOrEmpty($AllAttributes.TaskSequenceID))
                {
                    [OSDTaskSequence]$TaskSequence = Resolve-TaskSequenceBinding -Binding $AllAttributes.TaskSequenceID -UseDummies
                } else
                {
                    [OSDTaskSequence]$TaskSequence = $null
                }
                Write-Output -InputObject ([OSDMakeModel]::new($AllAttributes, $TaskSequence))
            }
        }
    }
}
#endregion

#region OSDComputerBinding
enum OSDComputerBindingType {
    Object = 1
    AssetTag = 2
    GUID = 3
    MacAddress = 4
    String = 5
}

class OSDComputerBinding
{
    [OSDComputerBindingType]$BindingType
    [OSDComputer]$ComputerObject
    [string]$String
    [int]$AssetTag
    [guid]$GUID
    [PhysicalAddress]$MacAddress

    OSDComputerBinding([string] $String)
    {
        $this.BindingType = [OSDComputerBindingType]::String
        $this.String = $String
    }

    OSDComputerBinding([int] $AssetTag)
    {
        $this.BindingType = [OSDComputerBindingType]::AssetTag
        $this.AssetTag = $AssetTag
    }

    OSDComputerBinding([guid] $GUID)
    {
        $this.BindingType = [OSDComputerBindingType]::GUID
        $this.GUID = $GUID
    }

    OSDComputerBinding([PhysicalAddress] $MacAddress)
    {
        $this.BindingType = [OSDComputerBindingType]::MacAddress
        $this.MacAddress = $MacAddress
    }

    OSDComputerBinding([OSDComputer] $ComputerObject)
    {
        $this.BindingType = [OSDComputerBindingType]::Object
        $this.ComputerObject = $ComputerObject
    }
}

function Resolve-OSDComputerBinding
{
    [CmdletBinding(DefaultParameterSetName = 'Bindings')]
    PARAM (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Bindings')][AllowEmptyCollection()][AllowNull()][OSDComputerBinding[]]$Bindings,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Attributes')][AllowEmptyCollection()][AllowNull()][Dictionary[string,object][]]$Attributes
    )

    process
    {
        if($PSCmdlet.ParameterSetName -eq 'Bindings')
        {
            foreach($Item in $Bindings)
            {
                [Dictionary[string, object]]$AllAttributes = $null
                if($Item.BindingType -eq [OSDComputerBindingType]::Object)
                {
                    Write-Output -InputObject $Item.ComputerObject
                    continue
                } elseif($Item.BindingType -eq [OSDComputerBindingType]::AssetTag)
                {
                    [string]$ParameterString = $Item.AssetTag.ToString()
                    $AllAttributes = Invoke-SQLQuery -AsDictionary -Query 'select * from ComputerIdentity inner join Settings on (ComputerIdentity.ID=Settings.ID) where Type=''C'' and AssetTag=@AssetTag' -Parameters @{ '@AssetTag' = $Item.AssetTag }
                } elseif($Item.BindingType -eq [OSDComputerBindingType]::GUID)
                {
                    [string]$ParameterString = $Item.GUID.ToString()
                    $AllAttributes = Invoke-SQLQuery -AsDictionary -Query 'select * from ComputerIdentity inner join Settings on (ComputerIdentity.ID=Settings.ID) where Type=''C'' and UUID=@GUID' -Parameters @{ '@GUID' = $ParameterString }
                } elseif($Item.BindingType -eq [OSDComputerBindingType]::MacAddress)
                {
                    [string]$ParameterString = Format-MacAddressForMDT -MacAddress $Item.MacAddress
                    $AllAttributes = Invoke-SQLQuery -AsDictionary -Query 'select * from ComputerIdentity inner join Settings on (ComputerIdentity.ID=Settings.ID) where Type=''C'' and MacAddress=@MacAddress' -Parameters @{ '@MacAddress' = $ParameterString }
                } else
                {
                    # This is a complicated one; we need to match a variety of things.
                    [string]$ParameterString = $Item.String
                    $AllAttributes = Invoke-SQLQuery -AsDictionary -Query 'select * from ComputerIdentity inner join Settings on (ComputerIdentity.ID=Settings.ID) where Type=''C'' and OSDComputerName=@Name' -Parameters @{ '@Name' = $ParameterString }
                    if($null -eq $AllAttributes)
                    {
                        # We don't have a name, let's try it as a MacAddress
                        [PhysicalAddress]$StringAsMacAddress = [MacAddressBinding]::new($Item.String).Address
                        if($null -ne $StringAsMacAddress)
                        {
                            $ParameterString = Format-MacAddressForMDT -MacAddress $StringAsMacAddress
                            $AllAttributes = Invoke-SQLQuery -AsDictionary -Query 'select * from ComputerIdentity inner join Settings on (ComputerIdentity.ID=Settings.ID) where Type=''C'' and MacAddress=@MacAddress' -Parameters @{ '@MacAddress' = $ParameterString }
                        }

                        if($null -eq $AllAttributes)
                        {
                            # We don't have a MacAddress, let's try it as a GUID
                            [guid]$StringAsGuid = [guid]::Empty
                            if([guid]::TryParse($Item.String, [ref]$StringAsGuid))
                            {
                                $ParameterString = $StringAsGuid.ToString()
                                $AllAttributes = Invoke-SQLQuery -AsDictionary -Query 'select * from ComputerIdentity inner join Settings on (ComputerIdentity.ID=Settings.ID) where Type=''C'' and UUID=@GUID' -Parameters @{ '@GUID' = $ParameterString }
                            }

                            if ($null -eq $AllAttributes)
                            {
                                # We don't have a GUID, try as an AssetTag
                                [int]$StringAsAssetTag = [int]::MinValue
                                if([int]::TryParse($Item.String, [ref] $StringAsAssetTag))
                                {
                                    $ParameterString = $StringAsAssetTag.ToString()
                                    $AllAttributes = Invoke-SQLQuery -AsDictionary -Query 'select * from ComputerIdentity inner join Settings on (ComputerIdentity.ID=Settings.ID) where Type=''C'' and AssetTag=@AssetTag' -Parameters @{ '@AssetTag' = $StringAsAssetTag }
                                }
                            }
                        }
                    }
                }

                if($null -eq $AllAttributes)
                {
                    throw [OSDComputerNotFoundException]::new($Script:OSDScriptsMDTRoot, $ParameterString)
                }

                if(![string]::IsNullOrEmpty($AllAttributes.TaskSequenceID))
                {
                    [OSDTaskSequence]$TaskSequence = Resolve-TaskSequenceBinding -Binding $AllAttributes.TaskSequenceID -UseDummies
                } else
                {
                    [OSDTaskSequence]$TaskSequence = $null
                }

                [ADComputer]$ComputerObject = Get-ADComputer -Filter "Name -eq '$($AllAttributes.OSDComputerName)'" -Properties netbootGUID
                Write-Output -InputObject ([OSDComputer]::new($AllAttributes, $TaskSequence, [MacAddressBinding]::new($AllAttributes.MacAddress).Address, $ComputerObject))
            }
        } else
        {
            foreach($Item in $Attributes)
            {
                [Dictionary[string, object]]$AllAttributes = $Item
                if(![string]::IsNullOrEmpty($AllAttributes.TaskSequenceID))
                {
                    [OSDTaskSequence]$TaskSequence = Resolve-TaskSequenceBinding -Binding $AllAttributes.TaskSequenceID -UseDummies
                } else
                {
                    [OSDTaskSequence]$TaskSequence = $null
                }

                [ADComputer]$ComputerObject = Get-ADComputer -Filter "Name -eq '$($AllAttributes.OSDComputerName)'" -Properties netbootGUID
                Write-Output -InputObject ([OSDComputer]::new($AllAttributes, $TaskSequence, [MacAddressBinding]::new($AllAttributes.MacAddress).Address, $ComputerObject))
            }
        }
    }
}
#endregion
