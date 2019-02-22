using namespace System;

<#
.SYNOPSIS
Adds a new computer to the MDT Database and returns it for further processing.

.DESCRIPTION
The New-OSDComputer cmdlet creates a new computer in the MDT Database, with options for also creating it in ActiveDirectory, moving it to the target OrganizationalUnit, and staging it fro netboot.

If a computer with the supplied name, asset tag, MacAddress, or UUID is already present in the database, an error will be thrown and no computer will be created.
Similarly, if the netbootGuid corresponding with the MacAddress or UUID is present on a computer object in ActiveDirectory, and the -BypassNetbootGUIDCheck switch is not provided, an error will be thrown and no computer will be created.

If a computer with the supplied name is present in ActiveDirectory, a warning will be raised, or if -NoClobber is provided, an error will be thrown and no computer will be created.
If -NoClobber is not provided, it is assumed that the computer in ActiveDirectory is intended to be the corresponding ActiveDirectory entry.

.EXAMPLE
PS C:\> New-OSDComputer 0000 00-00-00-00-00-00
Add a computer with the asset tag 0000 and the MAC address 00-00-00-00-00-00.

.EXAMPLE
PS C:\> New-OSDComputer 0000 -UUID '00000000-1111-2222-3333-444444444444'
Add a computer with the asset tag 0000 and the boot GUID 00000000-1111-2222-3333-444444444444.

.EXAMPLE
PS C:\> New-OSDComputer 0000 -MacAddress 00-11-22-33-44-55 -CreateADComputerIfMissing -MoveADComputer -Stage
Add a computer, creating it in ActiveDirectory if it doesn't exist, moving it to the default target OrganizationalUnit if it isn't present there, and staging it for netboot.
#>
function New-OSDComputer
{
    [CmdletBinding(DefaultParameterSetName='ByMacAddress', SupportsShouldProcess=$true)]
    [OutputType('OSDComputer')]
    PARAM(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
            [ValidateScript({if(Test-OSDComputer -Exists -Identity $_){ throw [ArgumentException]::new("A computer with the asset tag $_ already exists.") } else { $true }})]
            # The Asset Tag of the new computer. The name will be generated from this if one is not provided.
            [int]$AssetTag,
        [Parameter(Mandatory=$true, Position=1, ParameterSetName='ByMacAddress', ValueFromPipelineByPropertyName=$true)]
            [Parameter(ParameterSetName='ByUUID', ValueFromPipelineByPropertyName=$true)]
            [ValidateScript({if(Test-OSDComputer -Exists -Identity $_.Address){ throw [ArgumentException]::new("A computer with the MAC address $($_.Address) already exists.") } else { $true }})]
            [ValidateNotNull()]
            # The physical, unchanging Mac Address of the computer.
            [MacAddressBinding]$MacAddress,
        [Parameter(Mandatory=$true, ParameterSetName='ByUUID', ValueFromPipelineByPropertyName=$true)]
            [Parameter(ParameterSetName='ByMacAddress', ValueFromPipelineByPropertyName=$true)]
            [ValidateScript({if(Test-OSDComputer -Exists -Identity $_){ throw [ArgumentException]::new("A computer with the UUID $_ already exists.") } else { $true }})]
            [ValidateScript({if($_ -eq [guid]::Empty){ throw 'The empty GUID is not a valid GUID value.' } else { $true }})]
            [ValidateNotNull()] # Guid can't actually be null, but this just checks.
            [Alias('GUID')]
            # The UUID of the new computer.
            [guid]$UUID,
        [Parameter()]
            [ValidateScript({if(Test-OSDComputer -Exists -Identity $_){ throw [ArgumentException]::new("A computer with the name ""$_"" already exists.") } else { $true }})]
            # Provide a name for the computer, rather than using the generated one.
            [string]$Name,
        [Parameter()]
            # Specifies that this computer should be staged in ActiveDirectory
            [switch]$Stage,
        [Parameter()]
            # Specifies that this computer should be created in ActiveDirectory if missing.
            [switch]$CreateADComputerIfMissing,
        [Parameter()]
            # Specify that the duplicate netboot guid check should not be performed. Normally, the operation will fail if a computer with the supplied netboot guid is present in ActiveDirectory.
            [switch]$BypassNetbootGUIDCheck,
        [Parameter()]
            # Specifies that, if the computer already exists in Active Directory, it should be moved to the OU provided or listed in the module data.
            [switch]$MoveADComputer,
        [Parameter()][Alias('OU')]
            # Specifies an OU for the computer to be created in or moved to.
            [string]$OrganizationalUnit,
        [Parameter()]
            # Don't create or update computers that already exist in ActiveDirectory.
            [switch]$NoClobber
    )
    begin
    {
        Assert-OSDConnected
    }
    process
    {
        if([string]::IsNullOrEmpty($OrganizationalUnit))
        {
            $OrganizationalUnit = $Script:OSDDefaultOU
        }
        if(($null -eq $MacAddress.Address) -and (($null -eq $UUID) -or $UUID -eq [guid]::Empty))
        {
            throw [ArgumentException]::new("A MacAddress or UUID is required.")
        }

        if(!$PSBoundParameters.ContainsKey('Name'))
        {
            $Name = Get-DefaultComputerName -AssetTag $AssetTag
            Write-Verbose "Generated name $Name"
        }

        if(!$BypassNetbootGUIDCheck)
        {
            [string]$LDAPFilter = ''
            if($null -ne $MacAddress.Address)
            {
                $LDAPFilter += "(netbootGuid=$(Format-GUIDForLDAPFilter -MacAddress $MacAddress))"
            }
            if ($null -ne $UUID -and $UUID -ne [guid]::Empty) {
                $LDAPFilter += "(netbootGuid=$(Format-GUIDForLDAPFilter -Guid $UUID))"
            }

            # filter is 62 characters long once bytes are inserted (3*16 [bytes] + 14 [len("(netbootGuid=)")]), so this is a good check.
            if($LDAPFilter.Length -gt 64)
            {
                $LDAPFilter = "(|$LDAPFilter)"
            }

            if(Get-ADComputer -LDAPFilter $LDAPFilter)
            {
                throw [InvalidOperationException]::new("A computer with a matching netbootGuid already exists in ActiveDirectory.")
            }
        }

        [bool]$ADComputerExists = $null -ne (Get-ADComputer -LDAPFilter "(SAMAccountName=$Name)")
        if($ADComputerExists)
        {
            if($NoClobber)
            {
                throw [InvalidOperationException]::new("A computer with the name ""$Name"" already exists in ActiveDirectory and -NoClobber was specified.")
            } else
            {
                Write-Warning "A computer with the name ""$Name"" already exists in ActiveDirectory; assuming it is the same computer."
            }
        }

        if($PSCmdlet.ShouldProcess($Name, "Create"))
        {
            # Put it in the database
            $Identity = Invoke-SQLQuery -Query @'
                set XACT_ABORT ON;
                begin transaction
                    declare @Identity int;
                    insert into ComputerIdentity (AssetTag, SerialNumber, MacAddress, UUID, Description) VALUES (@AssetTag, '', @MacAddress, @GUID, @Name);
                    set @Identity = SCOPE_IDENTITY();
                    insert into Settings (Type, ID, OSDComputerName) VALUES ('C', @Identity, @Name);
                    select @Identity as ID;
                commit
'@ -Parameters @{
                '@AssetTag' = $AssetTag
                '@MacAddress' = Format-MacAddressForMDT -MacAddress $MacAddress.Address
                '@GUID' = if($PSBoundParameters.ContainsKey('UUID')){ $UUID.ToString() } else { [string]::Empty }
                '@Name' = $Name
            } -Property ID
            Write-Verbose "Created computer $AssetTag ($Name) in the MDT Database."

            if($Stage)
            {
                # we'll rely on Set-OSDComputerState to stage/create/move for us.
                Set-OSDComputerState -Identity $AssetTag -OrganizationalUnit $OrganizationalUnit -MoveADComputer:$MoveADComputer -CreateADComputerIfMissing:$CreateADComputerIfMissing -Verbose:$VerbosePreference
            } elseif($ADComputerExists -and $MoveADComputer)
            {
                $ADObject = Get-ADComputer $Name
                if($ADObject.DistinguishedName -ne "CN=$Name,$OrganizationalUnit")
                {
                    $null = Move-ADObject -Identity $ADObject -TargetPath $OrganizationalUnit -Verbose:$VerbosePreference
                } else
                {
                    Write-Verbose "Computer ""$Name"" is already present in the target OrganizationalUnit ""$OrganizationalUnit""."
                }
            } elseif(!$ADComputerExists -and $CreateADComputerIfMissing)
            {
                $null = New-ADComputer -Name $Name -SAMAccountName $Name -Path $OrganizationalUnit -Verbose:$VerbosePreference
            } else
            {
                Write-Verbose "Create, Move, and Stage skipped, as they were not requested for computer ""$Name""."
            }

            Get-OSDComputer -InternalID $Identity
        }
    }
}
