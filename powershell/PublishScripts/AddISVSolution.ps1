Param(
    [string] $masterRepoPath,
    [string] $masterRepo,
    [string] $RoleTailoredPath = "C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\"
)



$MP = (Join-Path "$env:System_ArtifactsDirectory" "temp")

if(Test-Path $MP){
    Remove-Item $MP -Recurse -Force
}
New-Item $MP -ItemType Directory

$appFolder = Get-ChildItem -Path "$env:System_ArtifactsDirectory\" -Name "app" -Directory -Recurse

$appFolder = (Join-Path "$env:System_ArtifactsDirectory\" $appFolder)

$appPath = Get-ChildItem -Path "$env:System_ArtifactsDirectory\*.app" -Recurse

Import-Module (Join-Path $RoleTailoredPath "Microsoft.Dynamics.Nav.Apps.Management.psd1")
Import-Module (Join-Path $RoleTailoredPath "Microsoft.Dynamics.Nav.Management.dll")

$appPath | ForEach-Object {
    $appName = (Get-NAVAppInfo -Path $appPath).Name
    $version = (Get-NAVAppInfo -Path $appPath).Version
}

cd $MP

git clone -q $masterRepoPath

if(Test-Path "$MP\$masterRepo\$appName"){
    Remove-Item "$MP\$masterRepo\$appName" -Recurse -Force
}
New-Item -ItemType Directory (Join-Path "$env:System_ArtifactsDirectory" "\temp\$masterRepo\$appName")
Copy-Item  $appFolder -Destination (Join-Path "$env:System_ArtifactsDirectory" "\temp\$masterRepo\$appName\app") -Recurse -Force

cd (Join-Path $MP $MasterRepo)

git add --all
git commit -m "Add ISV $version"
git push -q ($maRepoURI)  

#Import-NAVServerLicense $serviceTier -LicenseData ([Byte[]]$(Get-Content -Path $CustomerLicensePath -Encoding Byte)) 