@{
    RootModule = 'Cofl.OSDManagement.psm1'
    ModuleVersion = '4.0.0'
    GUID = '0518c5a8-5582-4aaf-a364-19764537a443'
    Author = 'Christian LaCourt'
    Copyright = '(c) 2018 Christian LaCourt.'
    Description = @'
The Cofl.OSDManagment module for Windows Powershell allows the management of computers in an MDT/Active Directory system coupled with a WDS server set to use Active Directory authorization, and an MSSQL server running the MDT Database.

For more information, please visit the README on the project page.
'@
    PowershellVersion = '5.1'
    DotNetFrameworkVersion = '3.5'
    TypesToProcess = 'Cofl.OSDManagement-Types.ps1xml'
    FormatsToProcess = 'Cofl.OSDManagement-Formats.ps1xml'
    RequiredModules = @(
        @{
            ModuleName = 'Configuration'
            ModuleVersion = '1.3'
            Guid = 'e56e5bec-4d97-4dfd-b138-abbaa14464a6'
        },
        @{
            ModuleName = 'ActiveDirectory'
            ModuleVersion = '1.0'
            Guid = '43c15630-959c-49e4-a977-758c5cc93408'
        }
    )
    FunctionsToExport = @(
        'Get-OSDComputer'
        'Get-OSDMakeModel'
        'Get-OSDTaskSequence'
        'Connect-OSD'
        'Disconnect-OSD'
        'New-OSDComputer'
        'New-OSDMakeModel'
        'Remove-OSDComputer'
        'Remove-OSDMakeModel'
        'Reset-OSDComputer'
        'Set-OSDComputer'
        'Set-OSDComputerState'
        'Set-OSDMakeModel'
        'Test-OSDComputer'
        'Update-OSDAutoCompleteCache'
        'Update-OSDConfiguration'
    )
    PrivateData = @{
        PSData = @{
            ProjectURI = 'https://github.com/cofl/Cofl.OSDManagement'
            LicenseURI = 'https://github.com/cofl/Cofl.OSDManagement/blob/master/LICENSE.md'
            Tags = @(
                'MDT'
                'MicrosoftDeploymentToolkit'
                'Utility'
                'PSEdition_Desktop'
            )
            ExternalModuleDependencies = @(
                'Configuration'
                'ActiveDirectory'
            )
            ReleaseNotes = @'
# 4.0.0
Renamed the module Cofl.OSDManagement and removed references to the old module name.
Introduced a cleaner workflow.
 - Initialize-OSD has been renamed to Connect-OSD
   - The -Path parameter is now mandatory and has the alias MDTSharePath.
   - The -UseConfiguredPath parameter has been added.
   - The -Refresh parameter has been removed.
   - The -DefaultOU and -ComputerNameTemplate parameters have been added.
   - An [OSDAlreadyConnectedException] will be thrown if already connected, and -Force is not specified.
   Default values for -Path, -DefaultOU, and -ComputerNameTemplate are configurable, see below.
 - Disconnect-OSD has been added as a counterpart to Connect-OSD.
   - Disconnect-OSD is called automatically on module remove.
 - All cmdlets except for Connect-OSD, Disconnect-OSD and Update-OSDConfiguration will now throw an [OSDNotConnectedException] if Connect-OSD has not been run or failed to connect.
Added a dependency on the Configuration module.
 - Default values can be configured using the Configuration module. See Configuration.psd1 at the module root for an example.
 - Added the Update-OSDConfiguration cmdlet for help with updating your configuration.
 - Configuration is no longer done from the module data (🎉)
 - An option is available for auto initialize on import, which is now disabled by default.
 - Added the about_Cofl.OSDManagement_Configuration help article.
Cmdlets:
 - Replaced the OSD* types with *Binding types in parameters.
 - Changed -Folder to -Group in Get-OSDTaskSequence
 - Added Set-OSDMakeModel (provides similar functionality to Set-OSDComputer for MakeModels)
 - Added Remove-OSDMakeModel (removes MakeModels like Remove-OSDComputer removes computers)
 - Added Set-OSDComputerState (unifies ActiveDirectory state cmdlets and provides more flexibility)
 - Removed Set-OSDMakeModelTaskSequence (use Set-OSDMakeModel)
 - Removed Set-OSDMakeModelDriverGroup (use Set-OSDMakeModel)
 - Removed Set-OSDComputerStaged (use Set-OSDComputerState -State Staged)
 - Removed Set-OSDComputerDestaged (use Set-OSDComputerState -State Unstaged)
 - Renamed Update-OSDAutoCompleteCaches to Update-OSDAutoCompleteCache (PSScriptAnalyzer recommendation)
 - Merged Test-OSDComputerExists and Test-OSDComputerStaged into Test-OSDComputer with either the -Exists or -Staged switch.
 - New-OSDComputer will now no longer create ADComputer objects by default (effectively, -MDTOnly is now the default.)
   - The -MDTOnly switch has been removed.
   - Added switches -CreateADComputerIfMissing, -MoveADComputer, and -Stage
 - Removed all aliases for Get-OSDComputer -Identity as they were misleading and archaic
 - Renamed Set-OSDComputer -Computer to Set-OSDComputer -Identity
 - Renamed Remove-OSDComputer -Computer to Remove-OSDComputer -Identity
Classes:
 - Removed the about_Cofl.OSDManagement_classes help article.
 - Removed OSDMacAddress. It has been replaced by MacAddressBinding.
 - Renamed OSDTaskSequenceFolder to OSDTaskSequenceGroup (this is the proper name)
Add properties:
 - OSDComputer.Description (references the identity table description)
 - OSDComputer.SerialNumber (references the identity table SerialNumber)
 - OSDMakeModel.InternalID (references the internal database ID)
Changed properties:
 - OSDComputer.OSDComputerName -> OSDComputer.ComputerName
 - OSDComputer.ID -> OSDComputer.InternalID
 - OSDComputer.InTmpSetup -> OSDComputer.IsInDefaultOU
 - OSDComputer.ADComputerPresent -> OSDComputer.IsADComputerPresent
Changed aliases:
 - OSDComputer.ComputerName -> OSDComputer.OSDComputerName (ComputerName is now the property name)
Removed aliases:
 - OSDComputer.MAC (use OSDComputer.MacAddress)
 - OSDComputer.InTempSetup (use OSDComputer.IsInDefaultOU)
 - OSDComputer.Staged (use OSDComputer.IsStaged)
 - OSDComputer.TS (use OSDComputer.TaskSequence)
 - OSDMakeModel.DG (use OSDMakeModel.DriverGroup)
 - OSDMakeModel.TS (use OSDMakeModel.TaskSequence)
Updated Type and Format data:
 - OSDComputer.Name is now OSDComputer.ComputerName in the default display property set.
'@
        }
    }
}
