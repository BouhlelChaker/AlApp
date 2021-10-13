Param(
    [string] $serviceTier = 'BC140',
    [string] $appPath,
    [string] $RoleTailoredPath = "C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\",
    [string] $DeveloperLicensePath = "C:\Documents\Licens\4863241.flf",
    [string] $CustomerLicensePath = "C:\Documents\Licens\4863241.flf"
)

Import-Module $RoleTailoredPath"Microsoft.Dynamics.Nav.Apps.Management.psd1"
Import-Module $RoleTailoredPath"Microsoft.Dynamics.Nav.Management.dll"

Import-NAVServerLicense $serviceTier -LicenseData ([Byte[]]$(Get-Content -Path $DeveloperLicensePath -Encoding Byte))

if($appPath -eq ''){
    $version = '1.0.0.0'
    $publisher = 'Publisher'
    $appName = 'App Name'
    $path = "D:\CustomerFiles\Extensions\" + $appName + "\"
    $appPath = $path + $publisher + '_' + $appName + '_' + $version + '.app'
}else{
    $appName = (Get-NAVAppInfo -Path $appPath).Name
    $version = (Get-NAVAppInfo -Path $appPath).Version
    $version = $version[0].ToString()
}

$oldappName = (Get-NAVAppInfo -ServerInstance $serviceTier -Name "$appName").Name
if ($oldappName){
    $oldVersion = (Get-NAVAppInfo -ServerInstance $serviceTier -Name "$appName").Version
    $oldVersion = $oldVersion[0].ToString()
}

Publish-NAVApp -ServerInstance $serviceTier -Path $appPath -SkipVerification
Sync-NAVTenant $serviceTier -Mode Sync -Force
Sync-NAVApp -ServerInstance $serviceTier -Name $appName -Version $version -Force

if (!$oldappName){
    Install-NAVApp -ServerInstance $serviceTier -Name $appName -Version $version 
}else{
    Start-NAVAppDataUpgrade -ServerInstance $serviceTier -Name $appName -Version $version
    Unpublish-NAVApp -ServerInstance $serviceTier -Name $appName -Version $oldVersion
}
Import-NAVServerLicense $serviceTier -LicenseData ([Byte[]]$(Get-Content -Path $CustomerLicensePath -Encoding Byte)) 