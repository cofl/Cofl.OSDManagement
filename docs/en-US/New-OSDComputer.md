---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# New-OSDComputer

## SYNOPSIS
Adds a new computer to the MDT Database and returns it for further processing.

## SYNTAX

### ByMacAddress (Default)
```
New-OSDComputer [-AssetTag] <Int32> [-MacAddress] <MacAddressBinding> [-UUID <Guid>] [-Name <String>] [-Stage]
 [-CreateADComputerIfMissing] [-BypassNetbootGUIDCheck] [-MoveADComputer] [-OrganizationalUnit <String>]
 [-NoClobber] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByUUID
```
New-OSDComputer [-AssetTag] <Int32> [[-MacAddress] <MacAddressBinding>] -UUID <Guid> [-Name <String>] [-Stage]
 [-CreateADComputerIfMissing] [-BypassNetbootGUIDCheck] [-MoveADComputer] [-OrganizationalUnit <String>]
 [-NoClobber] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The New-OSDComputer cmdlet creates a new computer in the MDT Database and in Active Directory, and stages it for netboot, unless the MDTOnly parameter is supplied, in which case the computer will only be created in the MDT Database.

If a computer with the supplied information is already present in the database, an error will be thrown and no computer will be created.
Similarly, if the computer will also be created in Active Directory and staged, an error will be thrown if another computer is already staged with the same Mac Address or UUID.

However, be warned that if a computer exists in Active Directory with the same name, but is not staged, that computer will receive the supplied UUID or Mac Address.

## EXAMPLES

### EXAMPLE 1
```
New-OSDComputer 0000 00-00-00-00-00-00
```

Add a computer with the asset tag 0000 and the MAC address 00-00-00-00-00-00.

### EXAMPLE 2
```
New-OSDComputer 0000 -UUID '00000000-1111-2222-3333-444444444444'
```

Add a computer with the asset tag 0000 and the boot GUID 00000000-1111-2222-3333-444444444444.

## PARAMETERS

### -AssetTag
The Asset Tag of the new computer.
The name will be generated from this if one is not provided.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MacAddress
The physical, unchanging Mac Address of the computer.

```yaml
Type: MacAddressBinding
Parameter Sets: ByMacAddress
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: MacAddressBinding
Parameter Sets: ByUUID
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UUID
The UUID of the new computer.

```yaml
Type: Guid
Parameter Sets: ByMacAddress
Aliases: GUID

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: Guid
Parameter Sets: ByUUID
Aliases: GUID

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Provide a name for the computer, rather than using the generated one.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Stage
Specifies that this computer should be staged in ActiveDirectory

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreateADComputerIfMissing
Specifies that this computer should be created in ActiveDirectory if missing.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -BypassNetbootGUIDCheck
Specify that the duplicate netboot guid check should not be performed. Normally, the operation will fail if a computer with the supplied netboot guid is present in ActiveDirectory.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MoveADComputer
Specifies that, if the computer already exists in Active Directory, it should be moved to the OU provided or listed in the module data.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrganizationalUnit
Specifies an OU for the computer to be created in or moved to.

```yaml
Type: String
Parameter Sets: (All)
Aliases: OU

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoClobber
Don't create or update computers that already exist in ActiveDirectory.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### OSDComputer

## NOTES

## RELATED LINKS
