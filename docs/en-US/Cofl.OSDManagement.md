---
Module Name: Cofl.OSDManagement
Module Guid: 0518c5a8-5582-4aaf-a364-19764537a443
Download Help Link: {{Please enter FwLink manually}}
Help Version: 4.0.0
Locale: en-US
---

# Cofl.OSDManagement Module
## Description
The Cofl.OSDManagement module for Windows Powershell allows the management of computers in an MDT/Active Directory system coupled with a WDS server set to use Active Directory authorization and an MSSQL server running the MDT Database. See [about_Cofl.OSDManagement](about_Cofl.OSDManagement.md) for more information.

## Cofl.OSDManagement Help Files
### [about Cofl.OSDManagement](about_Cofl.OSDManagement.md)
Explains how to use the Cofl.OSDManagement module to manage computers in an MDT/AD WDS deployment system.

### [about Cofl.OSDManagement Configuration](about_Cofl.OSDManagement_Configuration.md)
Explains how to configure the Cofl.OSDManagement module to manage computers in an MDT/AD WDS deployment system.

## Cofl.OSDManagement Cmdlets
### [Connect-OSD](Connect-OSD.md)
The Connect-OSD cmdlet initializes the environment for management of the OS Deployment back-end.
A connection to the MDT Database is created.

This command can be called with the -Force parameter to refresh all globals.
It is necessary to modify the default values of this parameter if the change is permanent.

### [Disconnect-OSD](Disconnect-OSD.md)
The Disconnect-OSD cmdlet tears down open connections and cleans up the OS Deployment script environment.
Any connections to the MDT Database are destroyed.
After calling this, Connect-OSD must be called again before other cmdlets may be used.

### [Get-OSDComputer](Get-OSDComputer.md)
When provided with a computer identity (a name, asset tag, MAC address, or GUID), retrieve
the information for the computer from the MDT Database, and from Active Directory to check if it is staged.

If given more than one identity matching the same computer, more than one entry will be returned.

If not given an identity, all computers in the database will be returned.

### [Get-OSDMakeModel](Get-OSDMakeModel.md)
When provided with a computer model, retrieve the information for that model from the MDT Database.
When given a manufacturer, list the information for all the models by that manufacturer.

This information includes the model-default TaskSequence and DriverGroup.

### [Get-OSDTaskSequence](Get-OSDTaskSequence.md)
When provided with a task sequence ID, retrieve that sequence from the MDT configuration.
When given a group, list the sequences in that group.

### [New-OSDComputer](New-OSDComputer.md)
The New-OSDComputer cmdlet creates a new computer in the MDT Database and in Active Directory, and stages it for netboot, unless the MDTOnly parameter is supplied, in which case the computer will only be created in the MDT Database.

If a computer with the supplied information is already present in the database, an error will be thrown and no computer will be created.
Similarly, if the computer will also be created in Active Directory and staged, an error will be thrown if another computer is already staged with the same Mac Address or UUID.

However, be warned that if a computer exists in Active Directory with the same name, but is not staged, that computer will receive the supplied UUID or Mac Address.

### [New-OSDMakeModel](New-OSDMakeModel.md)
Creates a new Make/Model entry in the MDT database, with the supplied Task Sequence and Driver Group; it does not create the task sequence or the driver group.

### [Remove-OSDComputer](Remove-OSDComputer.md)
The Remove-OSDComputer cmdlet deletes a computer from the MDT Database.
If the computer was staged, it is destaged.

If the DeleteADComputer parameter is supplied, and the computer was present in Active Directory, the computer is also deleted from ActiveDirectory.

### [Remove-OSDMakeModel](Remove-OSDMakeModel.md)
The Remove-OSDMakeModel cmdlet deletes a MakeModel from the MDT Database.

### [Reset-OSDComputer](Reset-OSDComputer.md)
The Reset-OSDComputer cmdlet clears a limited set of properties; it is less flexible than Set-OSDComputer, but is better for bulk processing because the set of properties changed can be verified before proceeding.

### [Set-OSDComputer](Set-OSDComputer.md)
The Set-OSDComputer cmdlet sets properties for a computer in the MDT Database.

Parameters are provided for the most common cases.
Other properties can be set via the Settings hashtable, or the Clear list.

Priority is given to the parameters for individual settings, then the -Clear list, then the -Settings table.

It is not possible to update the AssetTag, SerialNumber, Type, or ID of a computer.

### [Set-OSDComputerState](Set-OSDComputerState.md)
The Set-OSDComputerState cmdlet updates the state of one or more computers in ActiveDirectory.
The state managed by this cmdlet includes the OrganizationalUnit the computer is in and whether or not the computer is staged or unstaged.
This operation will fail if there is no corresponding ActiveDirectory object for a computer and the -CreateADComputerIfMissing switch is not provided.

At least one state change operation must be provided (create, move, or set staged state); otherwise, a warning will be displayed and no action will occur.

### [Set-OSDMakeModel](Set-OSDMakeModel.md)
The Set-OSDMakeModel cmdlet sets properties for a Make/Model in the MDT Database.

Parameters are provided for the most common cases. Other properties can be set via the Settings hashtable, or the Clear list.

Priority is given to the parameters for individual settings, then the -Clear list, then the -Settings table.

It is not possible to update the Make or Model of a Make/Model.

### [Test-OSDComputer](Test-OSDComputer.md)
When provided with a computer identity (a name, asset tag, MAC address, or GUID), check if the computer exists in MDT or is staged in ActiveDirectory.

### [Update-OSDAutoCompleteCaches](Update-OSDAutoCompleteCaches.md)
Gathers information from the MDT configuration and database to support tab completion.
Run this cmdlet if changes have been made to the database or config.

### [Update-OSDConfiguration](Update-OSDConfiguration.md)
The Update-OSDConfiguration cmdlet sets one or more configuration values used by cmdlets like Connect-OSD.

