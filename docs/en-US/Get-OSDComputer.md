---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Get-OSDComputer

## SYNOPSIS
Retrieves one or more computers from the MDT Database.

## SYNTAX

### All (Default)
```
Get-OSDComputer [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

### ByIdentity
```
Get-OSDComputer [-Identity] <OSDComputerBinding[]> [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>]
 [<CommonParameters>]
```

### ByInternalID
```
Get-OSDComputer -InternalID <Int32[]> [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>]
 [<CommonParameters>]
```

## DESCRIPTION
When provided with a computer identity (a name, asset tag, MAC address, or GUID), retrieve
the information for the computer from the MDT Database, and from Active Directory to check if it is staged.

If given more than one identity matching the same computer, more than one entry will be returned.

If not given an identity, all computers in the database will be returned.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDComputer 0000
```

Get the computer with the asset tag 0000.

### EXAMPLE 2
```
Get-OSDComputer Desktop0000
```

Get the computer with the name Desktop0000.

### EXAMPLE 3
```
Get-OSDComputer ([mac]'00-00-00-00-00-00')
```

Gets the computer with the MAC address "00-00-00-00-00-00."

### EXAMPLE 4
```
Get-OSDComputer
```

Gets all computers in the database.

### EXAMPLE 5
```
Get-OSDComputer 0000, 0004
```

Gets the computers with the asset tags 0000 and 0004.

## PARAMETERS

### -Identity
The identity of the computer to look up in the database; can be a name, asset tag, MAC address, or GUID.

```yaml
Type: OSDComputerBinding[]
Parameter Sets: ByIdentity
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -InternalID
One or more internal ID numbers for computer objects.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### OSDComputer

## NOTES

## RELATED LINKS
