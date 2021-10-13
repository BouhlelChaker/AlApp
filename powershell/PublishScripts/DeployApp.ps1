Param(
    [string] $serviceTier = 'BC140',
    [string] $RoleTailoredPath = "C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\",
    [string] $DeveloperLicensePath = "C:\Documents\Licens\4863241.flf",
    [string] $CustomerLicensePath = "C:\Documents\Licens\4863241.flf"
)

$appPath = Get-ChildItem -Path "$env:System_ArtifactsDirectory\*.app" -Recurse

Import-Module $RoleTailoredPath"Microsoft.Dynamics.Nav.Apps.Management.psd1"
Import-Module $RoleTailoredPath"Microsoft.Dynamics.Nav.Management.dll"
#Import-NAVServerLicense $serviceTier -LicenseData ([Byte[]]$(Get-Content -Path $DeveloperLicensePath -Encoding Byte))

$Instance = Get-NAVServerInstance $serviceTier -Force
if($Instance.State -eq 'Stopped'){
    Start-NAVServerInstance -ServerInstance $serviceTier -Force
}

$appPath | ForEach-Object {
    $version = (Get-NAVAppInfo -Path $_).Version
    $appName = (Get-NAVAppInfo -Path $_).Name

    $oldappName = (Get-NAVAppInfo -ServerInstance $serviceTier -Name "$appName").Name
    if ($oldappName){
        $oldVersion = (Get-NAVAppInfo -ServerInstance $serviceTier -Name "$appName").Version
        $oldVersion = $oldVersion[0].ToString()
    }



    Publish-NAVApp -ServerInstance $serviceTier -Path $_ -SkipVerification
    Sync-NAVTenant $serviceTier -Mode Sync -Force
    Sync-NAVApp -ServerInstance $serviceTier -Name $appName -Version $version -Force

    if (!$oldappName){
        Install-NAVApp -ServerInstance $serviceTier -Name $appName -Version $version 
    }else{
        Start-NAVAppDataUpgrade -ServerInstance $serviceTier -Name $appName -Version $version
        Unpublish-NAVApp -ServerInstance $serviceTier -Name $appName -Version $oldVersion
    }
}
#Import-NAVServerLicense $serviceTier -LicenseData ([Byte[]]$(Get-Content -Path $CustomerLicensePath -Encoding Byte)) 