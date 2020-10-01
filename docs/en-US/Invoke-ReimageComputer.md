---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Invoke-ReimageComputer

## SYNOPSIS
Remotely invoke a reboot to a network adapter.

## SYNTAX

```
Invoke-ReimageComputer [-Identity] <OSDComputerBinding[]> [-CreateADComputerIfMissing]
 [-OrganizationalUnit <String>] [-MoveADComputer] [-TaskSequence <TaskSequenceBinding>] [-ForceRestart]
 [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Invoke-ReimageComputer cmdlet remotely invokes a reboot to a network adapter.

The cmdlet will stage the computer, passing the paramters -CreateADComputerIfMissing, -OrganizationalUnit, and -MoveADComputer to Set-OSDComputerState.

If -TaskSequence is provided, the task sequence will be updated before rebooting.

This cmdlet requires remoting to be enabled; you should be able to run Invoke-Command on the target machine, and you should be able to use bcdedit on the target machine.

Tested on a handful of Lenovo desktops and laptops, your mileage may vary.

## EXAMPLES

### EXAMPLE 1
```
Invoke-ReimageComputer -Identity 1234 -CreateADComputerIfMissing
```

Stage the computer 1234, creating it if it doesn't exist, then remotely invoke a reimage.

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

### -ForceRestart
Force the remote computer to restart, even if someone is logged on.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### OSDComputer
## NOTES

## RELATED LINKS
