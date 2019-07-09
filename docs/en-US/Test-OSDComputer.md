---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Test-OSDComputer

## SYNOPSIS
Tests if a computer meets certain properties.

## SYNTAX

### TestExists
```
Test-OSDComputer [-Identity] <OSDComputerBinding> [-Exists] [<CommonParameters>]
```

### TestStaged
```
Test-OSDComputer [-Identity] <OSDComputerBinding> [-Staged] [<CommonParameters>]
```

## DESCRIPTION
When provided with a computer identity (a name, asset tag, MAC address, or GUID), check if the computer exists in MDT or is staged in ActiveDirectory.

## EXAMPLES

### EXAMPLE 1
```
Test-OSDComputer -Exists 0000
```

Checks if the computer with the asset tag 0000 is in the MDT database.

### EXAMPLE 2
```
Test-OSDComputer -Staged 0000
```

Checks if the computer with the asset tag 0000 is staged in ActiveDirectory (it must exist to be staged).

## PARAMETERS

### -Identity
A computer identity, such as an asset tag, Guid, MacAddress, or object returned by Get-OSDComputer

```yaml
Type: OSDComputerBinding
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Exists
Test if a computer exists.

```yaml
Type: SwitchParameter
Parameter Sets: TestExists
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Staged
Test if a computer is staged.

```yaml
Type: SwitchParameter
Parameter Sets: TestStaged
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
