---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Set-OSDComputerState

## SYNOPSIS
Updates the ActiveDirectory state of one or more computers, including whether the computer is staged or unstaged.

## SYNTAX

### ByState (Default)
```
Set-OSDComputerState [-Identity] <OSDComputerBinding[]> [-State <String>] [-CreateADComputerIfMissing]
 [-OrganizationalUnit <String>] [-MoveADComputer] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByStagedSwitch
```
Set-OSDComputerState [-Identity] <OSDComputerBinding[]> [-Staged] [-CreateADComputerIfMissing]
 [-OrganizationalUnit <String>] [-MoveADComputer] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByUnstagedSwitch
```
Set-OSDComputerState [-Identity] <OSDComputerBinding[]> [-Unstaged] [-CreateADComputerIfMissing]
 [-OrganizationalUnit <String>] [-MoveADComputer] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Set-OSDComputerState cmdlet updates the state of one or more computers in ActiveDirectory.
The state managed by this cmdlet
includes the OrganizationalUnit the computer is in and whether or not the computer is staged or unstaged.
This operation will
fail if there is no corresponding ActiveDirectory object for a computer and the -CreateADComputerIfMissing switch is not provided.

At least one state change operation must be provided (create, move, or set staged state); otherwise, a warning will be displayed and no action will occur.

## EXAMPLES

### EXAMPLE 1
```
Set-OSDComputerState -Identity 1234 -State Staged -CreateADComputerIfMissing
```

Stage the computer 1234, creating it if it doesn't exist.

### EXAMPLE 2
```
Get-OSDComputer | Set-OSDComputerState -CreateADComputerIfMissing
```

Create ActiveDirectory objects for all computers in the MDT database if they don't exist.

### EXAMPLE 3
```
Set-OSDComputerState -Identity 1234 -State Unstaged
```

Unstage the computer 1234.

### EXAMPLE 4
```
Set-OSDComputerState -Identity 1234 -Staged
```

Stage the computer 1234.

### EXAMPLE 5
```
Set-OSDComputerState -Identity 1234 -Unstaged
```

Unstage the computer 1234.

## PARAMETERS

### -Identity
A computer object or identity, such as the name, the asset tag, the MAC address, or the object retrieved by Get-OSDComputer.

```yaml
Type: OSDComputerBinding[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -State
A task sequence, either a string ID or one retrieved by Get-OSDTaskSequence.

```yaml
Type: String
Parameter Sets: ByState
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Staged
If the computer should be able to PXE boot.

```yaml
Type: SwitchParameter
Parameter Sets: ByStagedSwitch
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Unstaged
If the computer should not be able to PXE boot.

```yaml
Type: SwitchParameter
Parameter Sets: ByUnstagedSwitch
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreateADComputerIfMissing
If a computer object does not exist in ActiveDirectory, create it.

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
The computer will be created or moved to this OU.

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

### -MoveADComputer
If a computer is not the OU (default in the module private data), move it there.

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
Pass through an updated copy of the computer.

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

### OSDComputer
## NOTES

## RELATED LINKS
