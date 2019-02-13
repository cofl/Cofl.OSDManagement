using namespace Microsoft.ActiveDirectory.Management;
using namespace System.Collections.Generic;
using namespace System.Data;
using namespace System.Xml;

#region TaskSequence
class OSDTaskSequence
{
    [ValidateNotNullOrEmpty()][string]$ID
    [ValidateNotNullOrEmpty()][string]$Name
    [OSDTaskSequenceGroup[]]$Group
    [ValidateNotNull()][guid]$GUID
    [datetime]$CreatedTime
    [string]$CreatedBy
    [datetime]$LastModifiedTime
    [string]$LastModifiedBy

    OSDTaskSequence([XMLElement]$TaskSequenceElement, [XmlElement[]]$TaskSequences, [xml]$Groups)
    {
        $this.InitObject($TaskSequenceElement, $TaskSequences, $Groups, $null)
    }

    OSDTaskSequence([XMLElement]$TaskSequenceElement, [OSDTaskSequenceGroup]$Group)
    {
        $this.InitObject($TaskSequenceElement, $null, $null, $Group)
    }

    hidden OSDTaskSequence([string]$ID, [guid]$guid)
    {
        $this.ID = if($ID){ $ID } else { "INVALID-$guid" }
        $this.Name = "INVALID: $ID"
        $this.GUID = $guid
    }

    hidden [void] InitObject([XMLElement]$TaskSequenceElement, [XmlElement[]]$TaskSequences, [xml]$Groups, [OSDTaskSequenceGroup]$Group)
    {
        $this.ID = $TaskSequenceElement.ID
        $this.Name = $TaskSequenceElement.Name
        $this.CreatedTime = [datetime]$TaskSequenceElement.CreatedTime
        $this.LastModifiedTime = [datetime]$TaskSequenceElement.LastModifiedTime
        $this.CreatedBy = $TaskSequenceElement.CreatedBy
        $this.LastModifiedBy = $TaskSequenceElement.LastModifiedBy
        $this.GUID = [guid]$TaskSequenceElement.guid

        if($null -eq $Group)
        {
            $ContainingGroups = $Groups.groups.group | Where-Object {$_.Member -contains $TaskSequenceElement.guid}
            $this.Group = foreach($Item in $ContainingGroups)
            {
                [OSDTaskSequenceGroup]::new($Item, $TaskSequences)
            }
        } else
        {
            $this.Group = @( $Group )
        }
    }

    hidden static [OSDTaskSequence] Dummy([string]$ID)
    {
        return ([OSDTaskSequence]::new($ID, [guid]::Empty))
    }

    [string] ToString()
    {
        return $this.ID
    }
}

class OSDTaskSequenceGroup
{
    [ValidateNotNullOrEmpty()][string]$Name
    [string]$Comments
    [ValidateNotNull()][guid]$GUID
    [boolean]$Enabled
    [datetime]$CreatedTime
    [string]$CreatedBy
    [datetime]$LastModifiedTime
    [string]$LastModifiedBy
    [OSDTaskSequence[]]$Members

    OSDTaskSequenceGroup([XMLElement]$Group, [XmlElement[]]$TaskSequences)
    {
        $this.Name = $Group.Name
        $this.GUID = [guid]$Group.guid
        $this.Comments = $Group.Comments

        [datetime]$Time = [datetime]::MinValue
        if([datetime]::TryParse($Group.CreatedTime, [ref]$Time))
        {
            $this.CreatedTime = $Time
        }
        if([datetime]::TryParse($Group.LastModifiedTime, [ref]$Time))
        {
            $this.LastModifiedTime = $Time
        }
        $this.CreatedBy = $Group.CreatedBy
        $this.LastModifiedBy = $Group.LastModifiedBy
        $this.Enabled = $Group.enable

        $this.Members = foreach($member in $Group.Member)
        {
            [OSDTasksequence]::new(($TaskSequences | Where-Object {$_.guid -eq $member}), $this)
        }
    }

    [string] ToString()
    {
        return $this.Name
    }
}
#endregion

#region MakeModel
class OSDMakeModel
{
    [int]$InternalID
    hidden [Dictionary[string, object]]$AllAttributes
    [ValidateNotNullOrEmpty()][string]$Make
    [ValidateNotNullOrEmpty()][string]$Model
    [ValidateNotNullOrEmpty()][string]$DriverGroup
    [OSDTaskSequence]$TaskSequence

    OSDMakeModel([Dictionary[string, object]]$AllAttributes, [OSDTaskSequence]$TaskSequence)
    {
        $this.AllAttributes = $AllAttributes
        $this.InternalID = $this.AllAttributes.ID
        $this.Make = $this.AllAttributes.Make
        $this.Model = $this.AllAttributes.Model
        $this.DriverGroup = $this.AllAttributes.DriverGroup
        $this.TaskSequence = $TaskSequence
    }

    [string] ToString()
    {
        if([string]::IsNullOrWhiteSpace($this.Make))
        {
            return $this.Model
        } else
        {
            return "$($this.Make) $($this.Model)"
        }
    }
}
#endregion

#region Computer
class OSDComputer
{
    [int]$AssetTag
    hidden [Dictionary[string, object]]$AllAttributes
    [string]$ComputerName
    [string]$Description
    [string]$SerialNumber
    [OSDTaskSequence]$TaskSequence
    [PhysicalAddress]$MacAddress
    [guid]$UUID
    [int]$InternalID
    [string]$DriverGroup
    [string]$DistinguishedName
    [boolean]$IsADComputerPresent
    [boolean]$IsInDefaultOU
    [boolean]$IsStaged

    OSDComputer([Dictionary[string, object]]$AllAttributes, [OSDTaskSequence]$TaskSequence, [PhysicalAddress]$MacAddress, [ADComputer]$ComputerObject)
    {
        $this.AllAttributes = $AllAttributes
        $this.AssetTag = $AllAttributes.AssetTag
        $this.ComputerName = $this.AllAttributes.OSDComputerName
        $this.TaskSequence = $TaskSequence
        $this.MacAddress = $MacAddress
        $this.Description = $this.AllAttributes.Description
        $this.SerialNumber = $this.AllAttributes.SerialNumber

        [guid]$Guid = [guid]::Empty
        if([guid]::TryParse($this.AllAttributes.UUID, [ref] $Guid))
        {
            $this.UUID = $Guid
        }
        $this.InternalID = $this.AllAttributes.ID
        $this.DriverGroup = $this.AllAttributes.DriverGroup

        if($ComputerObject)
        {
            $this.IsADComputerPresent = $true
            $this.DistinguishedName = $ComputerObject.DistinguishedName
            $this.IsInDefaultOU = $ComputerObject.DistinguishedName.EndsWith($Script:OSDDefaultOU)
            $this.IsStaged = ($null -ne $ComputerObject.netbootGUID) -and ($this.GetValidNetbootGUID() -eq [guid][byte[]]($ComputerObject.netbootGUID))
        } else
        {
            $this.IsADComputerPresent = $false
            $this.DistinguishedName = $null
            $this.IsInDefaultOU = $false
            $this.IsStaged = $false
        }
    }

    [guid] GetValidNetbootGUID()
    {
        if($this.UUID -ne [guid]::Empty)
        {
            return $this.UUID
        } else
        {
            return ([guid]"00000000-0000-0000-0000-$($this.MacAddress)")
        }
    }

    [string] ToString()
    {
        return $this.ComputerName
    }
}
#endregion
