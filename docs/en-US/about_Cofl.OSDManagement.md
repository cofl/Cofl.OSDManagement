# Cofl.OSDManagement
## about_Cofl.OSDManagement

# SHORT DESCRIPTION
Explains how to use the Cofl.OSDManagement module to manage computers in an MDT/AD WDS deployment system.

# LONG DESCRIPTION
The Cofl.OSDManagement module for Windows Powershell allows the management of computers in an MDT/Active Directory system coupled with a WDS server set to use Active Directory authorization and an MSSQL server running the MDT Database.

Configuration is done using the Configuration module, or with the Update-OSDConfiguration cmdlet. See [about_Cofl.OSDManagement_Configuration](about_Cofl.OSDManagement_Configuration.md) for more details.

# EXAMPLES
## Connecting
When the module is first loaded, only a handful of cmdlets (Connect-OSD, Disconnect-OSD, and Update-OSDConfiguration)
will function. You must first connect to an MDT share. The module will use the settings stored in the share
to initialize its tab completion caches and connection to the SQL server. Currently, the module does not allow you
to specifiy a login credential for the SQL connection. If you wish to explore this data yourself, you may find it
under your share path at ./Control/Settings.xml and its sibling files -- we do not recommend editing this file manually,
please use the MDT MMC Snap-In for that.

```powershell
PS C:\> Connect-OSD -Path '\\img-svr-01.corp.contoso.com\MDT_Share$'
```

## Adding a new computer to the MDT Database and Active Directory

When a new computer is introduced, it is necessary to add it to both the MDT Database, so the imaging
process can pick up the necessary values, and to Active Directory, so it can be staged for your WDS
server to respond to. Both tasks can be handled by the [New-OSDComputer](New-OSDComputer) cmdlet, which
can also stage the new computer in Active Directory.

```powershell
PS C:\> New-OSDComputer 1234 '00-11-22-33-44-55'  -CreateADComputerIfMissing -MoveADComputer -Stage
PS C:\> New-OSDComputer 1234 -UUID '00000000-1111-2222-3333-444444444444' -CreateADComputerIfMissing -MoveADComputer -Stage
PS C:\> New-OSDComputer 1234 -UUID '00000000-1111-2222-3333-444444444444' -MacAddress '00-11-22-33-44-55' -CreateADComputerIfMissing -MoveADComputer -Stage
```

Do note that a name will be automatically generated from the Asset Tag. If you wish to change the name
before deployment, use [Set-OSDComputer](Set-OSDComputer.md) before staging:

```powershell
PS C:\> New-OSDComputer 1234 '00-11-22-33-44-55' | Set-OSDComputer -Name 'example-name' -PassThru | Set-OSDComputerState -State Staged -CreateADComputerIfMissing -MoveADComputer
```

In this example, [Set-OSDComputerState](Set-OSDComputerState.md) is the cmdlet that creates the Active
Directory object and stages it.

## Adding an existing computer to the MDT Database
Adding an existing computer to the deployment system is also done with the [New-OSDComputer](New-OSDComputer.md)
cmdlet, much like adding a new computer. Indeed, the only requirement is that you do NOT supply the -NoClobber
switch, so [New-OSDComputer](New-OSDComputer.md) will assume that the existing ActiveDirectory computer with the
same name is the same computer. If the name is already in the standard asset-tag-based format, the command to add the
computer to the database and stage it is as follows:

```powershell
PS C:\> New-OSDComputer 1234 '00-11-22-33-44-55' -Stage
PS C:\> New-OSDComputer 1234 -UUID '00000000-1111-2222-3333-444444444444' -Stage
PS C:\> New-OSDComputer 1234 -UUID '00000000-1111-2222-3333-444444444444' -MacAddress '00-11-22-33-44-55' -Stage
```

In this example, [New-OSDComputer](New-OSDComputer.md) will not create a new Active Directory object
for the computer, but will set the Netboot GUID on an existing Active Directory computer and move it
to the target OrganizationalUnit.

```powershell
PS C:\> New-OSDComputer 1234 '00-11-22-33-44-55' -MoveADComputer -Stage
```

A -NoClobber switch is also provided if you'd like to ensure that the new name for the computer
is unique in ActiveDirectory. If the switch is not provided, and there is already a computer
with the provided or generated name in ActiveDirectory, a warning will be generated. This is only
a check, so unless you also provide -CreateADComputerIfMissing, no ActiveDirectory computer will
be created.

```powershell
PS C:\> New-OSDComputer 1234 '00-11-22-33-44-55' -NoClobber
```

## Staging any computer for first-time deployment or for redeployment
When the time comes to image a machine, use the [Set-OSDComputerState](Set-OSDComputerState.md) cmdlet.
The cmdlet accepts any standard computer identity (Name, Asset Tag, MacAddress, UUID, or <OSDComputer>
object), and can handle more than one at a time. If the computer does not exist in Active Directory,
use can use the -CreateADComputerIfMissing switch to create it in the DefaultOU or the one provided;
if it doesn't exist, an error will be thrown..

```powershell
PS C:\> Set-OSDComputerState -Identity 1234 -State Staged -CreateADComputerIfMissing
PS C:\> Set-OSDComputerState -Identity '00-11-22-33-44-55' -State Staged 
PS C:\> Set-OSDComputerState -Identity 0a:1b:2c:3a:4b:5c -State Staged
PS C:\> Set-OSDComputerState -Identity vm4321 -State Staged
PS C:\> Get-OSDComputer 1234 | Set-OSDComputerState -State Staged
PS C:\> Set-OSDComputerState (1230..1239) -State Staged
```

If an Active Directory object already exists for the computer, you may move it to the DefaultOU or the
target OU provided by providing the -MoveADComputer switch:

```powershell
PS C:\> Set-OSDComputerState 1234 -MoveADComputer
```

## Change the name of a computer
It is not a common case the name of a computer must be changed, but in the event that it must,
use the [Set-OSDComputer](Set-OSDComputer.md) cmdlet. This will updated the name and
description of the computer in MDT ONLY, not in Active Directory.

```powershell
PS C:\> Set-OSDComputer 1234 -Name 'example-name'
```

If you wish to revert the name to the default, specify the name in the -Clear list:

```powershell
PS C:\> Set-OSDComputer 1234 -Clear Name
```

Another way to reset the name field is to use [Reset-OSDComputer](Reset-OSDComputer.md):

```powershell
PS C:\> Reset-OSDComputer 1234 -Property Name
```

Reset-OSDComputer is preferred when working with batches of computers, because it accepts lists of identities.

## Change the Task Sequence of a computer
Sometimes, in testing or production, it becomes necessary to override the Model default Task Sequence.
This can be done with the [Set-OSDComputer](Set-OSDComputer.md) cmdlet:

```powershell
PS C:\> Set-OSDComputer 1234 -TaskSequence 'SOME_TASK_SEQUENCE_ID'
```

If the OS requires a different set of drivers, the path to the driver group in MDT can also be provided:

```powershell
PS C:\> Set-OSDComputer 1234 -TaskSequence 'SOME_TASK_SEQUENCE_ID' -DriverGroup 'OS\Make\Model\ForExample'
```

To set the Task Sequence or Driver Group back to the default, use:

```powershell
PS C:\> Reset-OSDComputer 1234 -Property TaskSequence, DriverGroup
```

## Destage a computer

To destage a computer and have WDS no longer respond to it, use the [Set-OSDComputerState](Set-OSDComputerState.md) cmdlet:

```powershell
PS C:\> Set-OSDComputerState -Identity 1234 -State Unstaged
```

## Update the MAC Address of a computer

To update the MAC Address of a computer in the MDT Database, use the [Set-OSDComputer](Set-OSDComputer.md) cmdlet:

```powershell
PS C:\> Set-OSDComputer 1234 -MacAddress '55-44-33-22-11-00'
```

To then update the Active Directory object with the new MAC Address, stage the computer as normal.

## Remove a computer from the MDT Database

Should you need to remove a computer from the MDT Database, use the [Remove-OSDComputer](Remove-OSDComputer.md)
cmdlet, which will remove the computer and all associated settings from the database, and destage the
computer if it is staged, preventing WDS from responding to a client that no longer has
information associated with it:

```powershell
PS C:\> Remove-OSDComputer 1234
```

If you also wish to delete the Active Directory object for the computer, in addition to removing
it from the database, supply the -DeleteADComputer switch:

```powershell
PS C:\> Remove-OSDComputer 1234 -DeleteADComputer
```

The same could be accomplished by removing the computer from just the database, and then manually
removing the Active Directory object with either Powershell or your Active Directory Users and
Computers MMC Snap-In.

## Updating the default Task Sequence for a Computer Model

Should you need to change the default task sequence for any model of computer, such as when
switching to a new version of Windows 10, use the [Set-OSDMakeModel](Set-OSDMakeModel.md) cmdlet:

```powershell
PS C:\> Set-OSDMakeModel -Model 'Surface Pro 3' -TaskSequence 'SOME_TASK_SEQUENCE_ID'
```

Alternatively, the cmdlet also accepts OSDTaskSequence objects in the TaskSequence parameter,
and accepts OSDMakeModel objects from the pipeline.

If the driver group associated with the OS that task sequence installs changes, use the -DriverGroup
parameter:

```powershell
PS C:\> Set-OSDMakeModel -Model 'Surface Pro 3' -DriverGroup 'Windows 10\Microsoft\Surface Pro 3'
```

## Ending the session
When you are done, it is recommended to disconnect, to allow any open connections to be cleaned up.

```powershell
PS C:\> Disconnect-OSD
```
