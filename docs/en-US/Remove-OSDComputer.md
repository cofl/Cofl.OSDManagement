---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Remove-OSDComputer

## SYNOPSIS
Removes a computer from the MDT Database and destages it.

## SYNTAX

```
Remove-OSDComputer [-Identity] <OSDComputerBinding[]> [-DeleteADComputer] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Remove-OSDComputer cmdlet deletes a computer from the MDT Database.
If the computer was staged, it is destaged.

If the DeleteADComputer parameter is supplied, and the computer was present in Active Directory, the computer is also deleted from ActiveDirectory.

## EXAMPLES

### EXAMPLE 1
```
Remove-OSDComputer 1234
```

Removes computer 1234 from the MDT database and destages it if it was staged.

### EXAMPLE 2
```
Remove-OSDComputer 1234 -DeleteADComputer
```

Removes computer 1234 from the MDT database and deletes it from ActiveDirectory.

## PARAMETERS

### -Identity
One or more computer identities, such as the name, asset tag, MAC address, GUID, or OSDComputer object.

```yaml
Type: OSDComputerBinding[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DeleteADComputer
Notes that the listed computers should also be removed from Active Directory if they exist.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
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

## NOTES

## RELATED LINKS
