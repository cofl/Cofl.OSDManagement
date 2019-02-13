---
external help file: Cofl.OSDManagement-help.xml
Module Name: Cofl.OSDManagement
online version:
schema: 2.0.0
---

# Disconnect-OSD

## SYNOPSIS
Tears down the OSD Script environment.

## SYNTAX

```
Disconnect-OSD [<CommonParameters>]
```

## DESCRIPTION
The Disconnect-OSD cmdlet tears down open connections and cleans up the OS Deployment script environment.
Any connections to the MDT Database are destroyed.
After calling this, Connect-OSD must be called again before other cmdlets may be used.

## EXAMPLES

### EXAMPLE 1
```
Disconnect-OSD
```

Closes any open connections and cleans up.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
