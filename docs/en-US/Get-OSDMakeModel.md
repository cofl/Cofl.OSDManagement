---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Get-OSDMakeModel

## SYNOPSIS
Retrieves one or more models from the MDT database.

## SYNTAX

### All (Default)
```
Get-OSDMakeModel [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

### ByModel
```
Get-OSDMakeModel [-Model] <MakeModelBinding[]> [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>]
 [<CommonParameters>]
```

### ByInternalID
```
Get-OSDMakeModel -InternalID <Int32[]> [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>]
 [<CommonParameters>]
```

### ByMake
```
Get-OSDMakeModel -Make <String[]> [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

## DESCRIPTION
When provided with a computer model, retrieve the information for that model from the MDT Database.
When given a manufacturer, list the information for all the models by that manufacturer.

This information includes the model-default TaskSequence and DriverGroup.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDMakeModel |? {!$_.DriverGroup}
```

List all the models where the driver group has not been set.

### EXAMPLE 2
```
Get-OSDMakeModel 20HR000MUS
```

Get the information for the model "20HR000MUS."

## PARAMETERS

### -Model
One or more model IDs.

```yaml
Type: MakeModelBinding[]
Parameter Sets: ByModel
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -InternalID
One or more internal ID numbers for Make/Model objects.

```yaml
Type: Int32[]
Parameter Sets: ByInternalID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Make
One or more manufacturer names.

```yaml
Type: String[]
Parameter Sets: ByMake
Aliases: Manufacturer

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeTotalCount
Reports the number of objects in the data set (an integer) followed by the objects. If the cmdlet cannot determine the total count, it returns 'Unknown total count'.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skip
Ignores the first 'n' objects and then gets the remaining objects.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -First
Gets only the first 'n' objects.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

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
