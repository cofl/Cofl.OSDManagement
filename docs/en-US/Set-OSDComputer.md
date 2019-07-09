---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Set-OSDComputer

## SYNOPSIS
Sets properties for a computer in the MDT database.

## SYNTAX

```
Set-OSDComputer [-Identity] <OSDComputerBinding> [-Name <String>] [-TaskSequence <TaskSequenceBinding>]
 [-DriverGroup <String>] [-MacAddress <MacAddressBinding>] [-UUID <Guid>] [-Clear <String[]>]
 [-Settings <Hashtable>] [-UpdateNetbootGUID] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Set-OSDComputer cmdlet sets properties for a computer in the MDT Database.

Parameters are provided for the most common cases.
Other properties can be set via the Settings hashtable, or the Clear list.

Priority is given to the parameters for individual settings, then the -Clear list, then the -Settings table.

It is not possible to update the AssetTag, SerialNumber, Type, or ID of a computer.

## EXAMPLES

### EXAMPLE 1
```
Set-OSDComputer $ComputerObjectForSurfaceProWithNoStableMacAddress -UUID '00000000-0000-0000-0000-000000000000'
```

Sets the UUID on a computer object that didn't previously have one.

## PARAMETERS

### -Identity
A computer object or identity, such as the name, the asset tag, the MAC address, or the object retrieved by Get-OSDComputer.

```yaml
Type: OSDComputerBinding
Parameter Sets: (All)
Aliases: ComputerName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
The name for a computer.

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

### -TaskSequence
A task sequence, either a string ID or one retrieved by Get-OSDTaskSequence.

```yaml
Type: TaskSequenceBinding
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverGroup
A Driver Group for the machine, usually specified alongside -TaskSequence when the operating system of the override sequence is not the same as the Model default.

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

### -MacAddress
A MacAddress that will be used for staging the computer.

```yaml
Type: MacAddressBinding
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UUID
A UUID that will be used for staging the computer.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Clear
A list of field names to be emptied.
If Name is in this list, the computer name will be set to the default.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -Settings
A table of other values to set.
If Name or OSDComputerName is in this table, the operation will fail.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateNetbootGUID
If the computer is staged and the netboot GUID is changed by this operation, update the netboot GUID.

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

### -PassThru
Re-fetch the computer modified and spit it out.

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
