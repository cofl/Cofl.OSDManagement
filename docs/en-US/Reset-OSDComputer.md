---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Reset-OSDComputer

## SYNOPSIS
Clears properties for a computer in the MDT database.

## SYNTAX

```
Reset-OSDComputer [-Identity] <OSDComputerBinding[]> [[-Property] <String[]>] [-PassThru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Reset-OSDComputer cmdlet clears a limited set of properties; it is less flexible than Set-OSDComputer, but is better for bulk processing because the set of properties changed can be verified before proceeding.

## EXAMPLES

### EXAMPLE 1
```
Reset-OSDComputer 1234, 'test-server' -Property Name
```

Resets the names of the computers with the asset tag 1234 and the name 'test-server' to the defaults generated from their asset tag.

### EXAMPLE 2
```
Get-OSDComputer | ? {$_.TaskSequence} | Reset-OSDComputer -Property TaskSequence
```

Gathers all computers with a task sequence set and clears that property; in the future, if they are staged and imaged, they will use the default for their model.

## PARAMETERS

### -Identity
A computer object or identity, such as the name, the asset tag, the MAC address, or the object retrieved by Get-OSDComputer.

```yaml
Type: OSDComputerBinding[]
Parameter Sets: (All)
Aliases: ComputerName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Property
Specifies the properties to clear.
Wildcards are not permitted.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @('Name', 'TaskSequence')
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassThru
If present, pass the computer object through after refreshing.

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
