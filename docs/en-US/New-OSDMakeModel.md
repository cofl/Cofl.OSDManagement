---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# New-OSDMakeModel

## SYNOPSIS
Creates a new Make/Model in the MDT database; does not create folders in the MDT configuration.

## SYNTAX

```
New-OSDMakeModel [-Make] <String> [-Model] <String> -TaskSequence <TaskSequenceBinding> -DriverGroup <String>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new Make/Model entry in the MDT database, with the supplied Task Sequence and Driver Group; it does not create the task sequence or the driver group.

## EXAMPLES

### EXAMPLE 1
```
New-OSDMakeModel 'Dell' 'Optiplex 780' -TaskSequence 'SOME_TASK_SEQUENCE' -DriverGroup 'Windows\Optiplex 780'
```

Creates an entry for the Dell Optiplex 780 in the MDT database, and sets its default task sequence and driver group.

## PARAMETERS

### -Make
The manufacturer of the computer, as listed in the BIOS.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Manufacturer

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Model
The model of the computer, as listed in the BIOS.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TaskSequence
A task sequence, either by object or ID.

```yaml
Type: TaskSequenceBinding
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverGroup
A driver group path (in MDT).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
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

### OSDMakeModel

## NOTES

## RELATED LINKS
