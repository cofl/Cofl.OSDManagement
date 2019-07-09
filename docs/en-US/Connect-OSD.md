---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Connect-OSD

## SYNOPSIS
Initializes the OSD Script environment.

## SYNTAX

### ByPath (Default)
```
Connect-OSD [-Path] <String> [-DefaultOU <String>] [-ComputerNameTemplate <String>] [-Force]
 [<CommonParameters>]
```

### ByDrive
```
Connect-OSD [-DriveName <String>] [-DefaultOU <String>] [-ComputerNameTemplate <String>] [-Force]
 [<CommonParameters>]
```

### ByConfiguredPath
```
Connect-OSD [-UseConfiguredPath] [-DefaultOU <String>] [-ComputerNameTemplate <String>] [-Force]
 [<CommonParameters>]
```

## DESCRIPTION
The Connect-OSD cmdlet initializes the environment for management of the OS Deployment back-end.
A connection to the MDT Database is created.

This command can be called with the -Force parameter to refresh all globals.
It is necessary to modify the default values of this parameter if the change is permanent.

## EXAMPLES

### EXAMPLE 1
```
Connect-OSD '\\img-contoso-01.contoso.com\MDT_Share$'
```

Opens a connection to the share at the listed address, using its share details to connect to the SQL database.

## PARAMETERS

### -DriveName
The name of the PSDrive for the share (see Get-MDTPersistentDrive)

```yaml
Type: String
Parameter Sets: ByDrive
Aliases: PersistentDrive

Required: False
Position: Named
Default value: DS001
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
The path to the root of the deployment share.

```yaml
Type: String
Parameter Sets: ByPath
Aliases: MDTSharePath

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UseConfiguredPath
Use the MDT share path specified in the configuration.

```yaml
Type: SwitchParameter
Parameter Sets: ByConfiguredPath
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DefaultOU
The default ActiveDirectory OU where computers will be created or moved to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ComputerNameTemplate
The template to use for generating default computer names.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Force
Refresh all globals and reconnect.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
