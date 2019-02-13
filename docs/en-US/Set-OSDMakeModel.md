---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Set-OSDMakeModel

## SYNOPSIS
Sets properties for a Make/Model in the MDT database.

## SYNTAX

```
Set-OSDMakeModel [-Model] <MakeModelBinding> [-TaskSequence <TaskSequenceBinding>] [-DriverGroup <String>]
 [-Clear <String[]>] [-Settings <Hashtable>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Set-OSDMakeModel cmdlet sets properties for a Make/Model in the MDT Database.

Parameters are provided for the most common cases.
Other properties can be set via the Settings hashtable, or the Clear list.

Priority is given to the parameters for individual settings, then the -Clear list, then the -Settings table.

It is not possible to update the Make or Model of a Make/Model.

## EXAMPLES

### EXAMPLE 1
```
Set-OSDMakeModel $SomeMakeModel -TaskSequence $SomeTaskSequence
```

Updates the default task sequence for $SomeMakeModel to $SomeTaskSequence.

## PARAMETERS

### -Model
A Make/Model object or identity, such as the model name or the object retrieved by Get-OSDMakeModel.

```yaml
Type: MakeModelBinding
Parameter Sets: (All)
Aliases: MakeModel

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DriverGroup
A Driver Group for the make/model, usually specified alongside -TaskSequence when the operating system has changed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Clear
A list of field names to be emptied.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @()
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Settings
A table of other values to set.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @{}
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassThru
Re-fetch the make/model modified and spit it out.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### OSDMakeModel

## NOTES

## RELATED LINKS
