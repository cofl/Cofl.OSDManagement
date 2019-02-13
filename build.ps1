#Requires -Modules psake

using namespace System.Security.Cryptography.X509Certificates;

[CmdletBinding(DefaultParameterSetName='Do')]
PARAM (
    [Parameter(Position=0,ParameterSetName='Do')][string[]]$Tasks = @('Build', 'BuildHelp', 'Catalog'),
    [Parameter(ParameterSetName='Show')][switch]$ListTasks,
    [Parameter(ParameterSetName='Do')][X509Certificate2]$Certificate
)

if($ListTasks){
    Invoke-Psake $PSScriptRoot\build.psake.ps1 -docs
} else {
    $Parameters = @{
        taskList = $Tasks
    }
    if($Certificate){
        $Parameters.parameters = @{ Certificate = $Certificate }
    }
    Invoke-Psake $PSScriptRoot\build.psake.ps1 @Parameters
}
