using namespace System.Diagnostics.CodeAnalysis;
using namespace System.Security.Cryptography.X509Certificates;
using namespace System.Text;

Properties {
    [SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope='Function', Target='*')]
    PARAM ()
    # -------- Directories and Basic Properties --------
    $DocsRoot = "$PSScriptRoot/docs"
    $Encoding = [Encoding]::UTF8

    $SrcRoot  = "$PSScriptRoot/src"
    $OutDir   = "$PSScriptRoot/Release"
    $Locale   = 'en-US'

    $ModulePath = Get-Item "$SrcRoot/*.psd1" | Where-Object {Test-ModuleManifest -Path $_ -ErrorAction SilentlyContinue} | Select-Object -First 1
    $ModuleName = $ModulePath.BaseName
    $ModuleManifest = Import-PowerShellDataFile -Path $ModulePath.FullName
    $ModuleVersion = $ModuleManifest.ModuleVersion

    $ModuleOutDir = "$OutDir/$ModuleName"
    $ModuleCatalogPath = "$ModuleOutDir/$ModuleName.cat"

    # Items matched by filters in the $Exclude array won't be copied to the $OutDir
    $Exclude = @('*.cs')
}

Task default -depends Build

Task Init -requiredVariables OutDir {
    if(!(Test-Path -LiteralPath $OutDir)){
        $null = mkdir $OutDir -Verbose:$VerbosePreference
    } else {
        Write-Verbose "$($psake.context.currentTaskName) - directory already exists '$OutDir'."
    }
}

Task Clean -depends Init -requiredVariables OutDir {
    # Safety to avoid nuking root.
    if($OutDir.Length -gt 3){
        Get-ChildItem $OutDir | Remove-Item -Recurse -Force -Verbose:$VerbosePreference
    } else {
        Write-Verbose "$($psake.context.currentTaskName) - `$OutDir '$OutDir' must be longer than 3 characters."
    }
}

Task Build -requiredVariables Exclude, SrcRoot, ModuleOutDir -depends Init, Clean {
    if(!(Test-Path -LiteralPath $ModuleOutDir)){
        $null = mkdir $ModuleOutDir -Verbose:$VerbosePreference
    } else {
        Write-Verbose "$($psake.context.currentTaskName) - directory already exists '$ModuleOutDir'."
    }

    Copy-Item -Recurse -Exclude $Exclude -Path "$SrcRoot/*" -Destination $ModuleOutDir
}

Task BuildHelp -depends Build, GenerateMarkdown, GenerateHelpFiles
Task GenerateMarkdown -requiredVariables Locale, DocsRoot, ModuleName, ModuleOutDir, Encoding, ModuleVersion {
    if(!(Get-Module platyPS -ListAvailable)){
        throw "$($psake.context.currentTaskName) - PlatyPS is not available, cannot generate help files."
    } else {
        Import-Module platyPS
    }

    $ModuleInfo = Import-Module "$ModuleOutDir/$ModuleName.psd1" -Global -Force -PassThru
    try {
        if($ModuleInfo.ExportedCommands.Count -eq 0){
            Write-Output "$($psake.context.currentTaskName) - No commands have been exported, skipping."
            return
        }

        if(!(Test-Path -LiteralPath $DocsRoot)){
            $null = mkdir $DocsRoot -Verbose:$VerbosePreference
        }

        if(Get-ChildItem -LiteralPath $DocsRoot -Filter *.md -Recurse -ErrorAction SilentlyContinue) {
            Get-ChildItem -LiteralPath $DocsRoot -Directory | ForEach-Object {
                $null = Update-MarkdownHelp -Path $_.FullName -Verbose:$VerbosePreference
            }
        }

        $Parameters = @{
            AlphabeticParamsOrder = $true
            Encoding = $Encoding
            # FwLink = $FwLink
            HelpVersion = $ModuleVersion
            Locale = $Locale
            Module = $ModuleName
            OutputFolder = "$DocsRoot/$Locale"
            WithModulePage = $true
        }
        $null = New-MarkdownHelp @Parameters -ErrorAction SilentlyContinue -Verbose:$VerbosePreference
    } finally {
        Remove-Module $ModuleName -Force
    }
}

Task GenerateHelpFiles -requiredVariables DocsRoot, ModuleName, ModuleOutDir, OutDir, Encoding {
    if(!(Get-Module platyPS -ListAvailable)){
        throw "$($psake.context.currentTaskName) - PlatyPS is not available, cannot generate help files."
    } else {
        Import-Module platyPS
    }

    if(!(Get-ChildItem -LiteralPath $DocsRoot -Filter *.md -Recurse -ErrorAction SilentlyContinue)){
        Write-Error "$($psake.context.currentTaskName) - No markdown help files to process, skipping."
        return
    }

    Get-ChildItem -Path $DocsRoot -Directory | Select-Object -ExpandProperty Name | ForEach-Object {
        $null = New-ExternalHelp -Path "$DocsRoot/$_" -OutputPath "$ModuleOutDir/$_" -Force -ErrorAction SilentlyContinue -Verbose:$VerbosePreference -Encoding $Encoding
    }
}

Task Analyze -depends Build -requiredVariables ModuleOutDir {
    if(!(Get-Module PSScriptAnalyzer -ListAvailable)){
        throw "$($psake.context.currentTaskName) - PSScriptAnalyzer is not availalbe, cannot analyze module."
    } else {
        Import-Module PSScriptAnalyzer
    }

    Invoke-ScriptAnalyzer -Path $ModuleOutDir -Recurse -Settings PSGallery | Tee-Object -Variable Analysis
    if($Analysis)
    {
        throw "$($psake.context.currentTaskName) - Analysis failed."
    }
}

Task Catalog -depends Build, BuildHelp -requiredVariables ModuleOutDir, ModuleCatalogPath {
    $null = New-FileCatalog -Path $ModuleOutDir -CatalogFilePath $ModuleCatalogPath -CatalogVersion 2.0
}

Task Sign -depends Catalog -requiredVariables ModuleCatalogPath, Certificate {
    Assert ($Certificate -ne $null -and $Certificate -is [X509Certificate2]) "Certificate is not valid."
    $SignStatus = Set-AuthenticodeSignature -FilePath $ModuleCatalogPath -Certificate $Certificate
    if($SignStatus.Status -ne 'Valid')
    {
        throw "$(psake.context.currentTaskName) - Failed to sign catalog file with certificate ""$($Certificate.GetCertHashString())""."
    }
}

Task Deploy -depends Build, Sign, Analyze, BuildHelp {
    if(!(Get-Module PSDeploy -ListAvailable)){
        throw "$(psake.context.currentTaskName) - PSDeploy is not available, cannot deploy."
    } else {
        Import-Module PSDeploy
    }
    Push-Location $PSScriptRoot
    Invoke-PSDeploy
    Pop-Location
}
