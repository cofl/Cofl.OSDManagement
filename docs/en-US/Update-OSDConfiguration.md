---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Update-OSDConfiguration

## SYNOPSIS
Updates the connection defaults for the module.

## SYNTAX

```
Update-OSDConfiguration [[-Path] <String>] [[-DefaultOU] <String>] [[-ComputerNameTemplate] <String>]
 [[-AutoConnectOnImport] <Boolean>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Update-OSDConfiguration cmdlet sets one or more configuration values used by cmdlets like Connect-OSD.

## EXAMPLES

### EXAMPLE 1
```
Update-OSDConfiguration -Path '\\img-contoso-01.contoso.com\MDT_Share$'
```

Updates the MDT share path for the default scope.

## PARAMETERS

### -Path
The path to the root of the deployment share.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
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
Position: 2
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
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AutoConnectOnImport
Should the module automatically connect on import?

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

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

[about_Cofl.OSDManagement_Configuration](about_Cofl.OSDManagement_Configuration.md)
