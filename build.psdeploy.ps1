#Requires -module PSDeploy

[string]$ModuleName = Get-Item "$PSScriptRoot/src/*.psd1" | Where-Object {Test-ModuleManifest -Path $_ -ErrorAction SilentlyContinue} | Select-Object -First 1 -ExpandProperty BaseName

Deploy Public {
    # see docs for PSDeploy to put your deployment here.
    # but seriously consider not doing that and just using the official version from PSGallery instead.
    By PSGalleryModule {
        FromSource "$PSScriptRoot/Release/$ModuleName"
        To PSGallery
        WithOptions @{
            ApiKey = $env:PSGalleryKeyCoflOSDManagement
        }
    }
}
