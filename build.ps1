#Requires -Modules psake, PlatyPS

using namespace System.Security.Cryptography.X509Certificates;

[CmdletBinding(DefaultParameterSetName='Do')]
PARAM (
    [Parameter(Position=0,ParameterSetName='Do')][string[]]$Tasks = @('Build', 'BuildHelp', 'Catalog'),
    [Parameter(ParameterSetName='Show')][switch]$ListTasks,
    [Parameter(ParameterSetName='Do')][X509Certificate2]$Certificate
)

# Check Dependencies
if(!(Get-Module -ListAvailable PSDeploy))
{
    Write-Warning "Could not find module PSDeploy used for deployment; not required unless deploying."
}

if(!(Get-Module -ListAvailable ActiveDirectory))
{
    throw "Could not find required module ActiveDirectory; install or import RSAT AD Powershell module to continue."
}

if(!(Get-Module -ListAvailable Configuration))
{
    throw "Could not find required module Configuration; install or import the Configuration module to continue."
}

if($ListTasks)
{
    Invoke-Psake $PSScriptRoot\build.psake.ps1 -docs
} else
{
    $Parameters = @{
        taskList = $Tasks
    }
    if($Certificate)
    {
        $Parameters.parameters = @{ Certificate = $Certificate }
    }
    Invoke-Psake $PSScriptRoot\build.psake.ps1 @Parameters
}
