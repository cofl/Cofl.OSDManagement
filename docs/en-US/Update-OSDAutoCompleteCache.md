---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Update-OSDAutoCompleteCache

## SYNOPSIS
Rebuilds the caches used for tab completion.

## SYNTAX

```
Update-OSDAutoCompleteCache [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Gathers information from the MDT configuration and database to support tab completion.
Run this cmdlet if changes have been made to the database or config.

## EXAMPLES

### EXAMPLE 1
```
Update-OSDAutoCompleteCaches
```

There isn't really anything else this does.

## PARAMETERS

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

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
