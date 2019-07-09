---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Remove-OSDMakeModel

## SYNOPSIS
Removes a MakeModel from the MDT Database and destages it.

## SYNTAX

```
Remove-OSDMakeModel [-Model] <MakeModelBinding[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Remove-OSDMakeModel cmdlet deletes a MakeModel from the MDT Database.

## EXAMPLES

### EXAMPLE 1
```
Remove-OSDMakeModel 'Optiplex 780'
```

Removes the MakeModel "Optiplex 780" from the MDT Database.

## PARAMETERS

### -Model
One or more MakeModel identities.

```yaml
Type: MakeModelBinding[]
Parameter Sets: (All)
Aliases: MakeModel

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

## NOTES

## RELATED LINKS
