---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Get-OSDTaskSequence

## SYNOPSIS
Retrieves one or more task sequences from the MDT configuration.

## SYNTAX

### All (Default)
```
Get-OSDTaskSequence [<CommonParameters>]
```

### ByID
```
Get-OSDTaskSequence [-ID] <TaskSequenceBinding[]> [<CommonParameters>]
```

### ByGroup
```
Get-OSDTaskSequence -Group <String[]> [<CommonParameters>]
```

## DESCRIPTION
When provided with a task sequence ID, retrieve that sequence from the MDT configuration.
When given a group, list the sequences in that group.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDTaskSequence
```

List all task sequences.

### EXAMPLE 2
```
Get-OSDTaskSequence SERVER2016
```

Get the task sequence with the ID "SERVER2016."

### EXAMPLE 3
```
Get-OSDTaskSequence -Group Install
```

Gets the task sequences that are direct children of the group "Install."

## PARAMETERS

### -ID
One or more Task Sequence IDs.

```yaml
Type: TaskSequenceBinding[]
Parameter Sets: ByID
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Group
The MDT path to a task sequence group.

```yaml
Type: String[]
Parameter Sets: ByGroup
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### OSDTaskSequence

## NOTES

## RELATED LINKS
