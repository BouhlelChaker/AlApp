Param(
    [ValidateSet('OnPrem','Sandbox')]
    [string] $ContainerType = 'OnPrem',
    [string] $ContainerPrefix = 'Clean', #Up to seven letters (max 15 for container name?)
    [string] $Version = 'bc15', #BC version ex. bc13
    [string] $CU = 'rtm',
    [string] $Language = 'dk', #No capital letters (ex. "dk")
    [string] $LicensePath = "\\10.108.1.12\norriq\Business Central Licens\4863241_15.flf",
    [string] $ShortCutFolder = 'C:\Documents\NAVContainerShortcuts\',
    [string] $DesktopFolder = 'C:\Users\'+ $env:username + '\Desktop\',
    [string] $DockerFolders = 'C:\Documents\docker\',
    [switch] $IncludeCSide,
    [switch] $EnableSymbolLoading,
    [ValidateSet('Windows','NavUserPassword', 'UserPassword', 'AAD')]
    [string] $Auth = 'Windows'
)

$ContainerName = $ContainerPrefix + $Version + $CU + $Language

if ($ContainerType -eq 'OnPrem') {
    if($Version -eq "bc13"){
        if($CU -eq "rtm")
        {
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:13.0.24630.0"
        }elseif($CU -eq "cu1"){
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:13.1.25940.0"
        }
        elseif($CU -eq "cu2"){
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:13.2.26556.0"
        }
        elseif($CU -eq "cu3"){
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:13.3.27233.0"
        }
        elseif($CU -eq "cu4"){
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:13.4.28874.0"
        }
        elseif($CU -eq "cu5"){
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:13.5.29483.0"
        }
        elseif($CU -eq "cu6"){
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:13.6.29777.0"
        }
        elseif($CU -eq "cu7"){
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:13.7.31809.0"
        }
        elseif($CU -eq "cu8"){
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:13.8.32990.0"
        }
        elseif($CU -eq "cu9"){
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:13.9.33838.0"
        }
    }elseif($Version -eq "bc14"){
        if($CU -eq "rtm"){
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:14.0.29537.0"
        }
        elseif ($CU -eq "cu1") {
            $imageName = "mcr.microsoft.com/businesscentral/onprem:14.1.32615.0"
        }
        elseif ($CU -eq "cu2") {
            $imageName = "mcr.microsoft.com/businesscentral/onprem:14.3.34444.0"
        }
        elseif ($CU -eq "cu3") {
            $imageName = "mcr.microsoft.com/businesscentral/onprem:14.4.35602.0"
        }
        elseif ($CU -eq "cu4") {
            $imageName = "mcr.microsoft.com/businesscentral/onprem:14.5.35970.0"
        }
        elseif ($CU -eq "cu5") {
            $imageName = "mcr.microsoft.com/businesscentral/onprem:14.6.36463.0"
        }
    }elseif($Version -eq "bc15"){
        if($CU -eq "rtm"){
            $ImageName = "mcr.microsoft.com/businesscentral/onprem:15.0.36560.0"
        } 
    }
    if ($ImageName -eq ""){
        $ImageName = "mcr.microsoft.com/businesscentral/onprem"
    }
}
elseif ($ContainerType -eq 'Sandbox') {
    $ImageName = 'microsoft/bcsandbox:'
}

if ($Language -ne ""){
    $ImageName = $ImageName + "-" + $Language
}

if (!(Test-Path -Path "$DockerFolders$ContainerName")){
    New-Item -ItemType Directory -Path "$DockerFolders$ContainerName"
}

if (!(Test-Path -Path "$DockerFolders$ContainerName\Add-ins")){
    New-Item -ItemType Directory -Path "$DockerFolders$ContainerName\Add-ins"
}

if (!(Test-Path -Path "$DockerFolders$ContainerName\temp")){
    New-Item -ItemType Directory -Path "$DockerFolders$ContainerName\temp"
}

$additionalParameters = "--volume $DockerFolders$ContainerName\Add-ins:c:\run\Add-ins --volume $DockerFolders$ContainerName\temp:c:\temp"

if ($ContainerType -eq 'OnPrem') {
    if(($Version -eq "bc13") -or ($Version -eq "bc14")){
        new-navcontainer -accept_eula `
                 -memoryLimit 4g `
                 -containerName $ContainerName `
                 -includeTestToolkit `
                 -auth $Auth `
                 -includeCSide:$IncludeCSide `
                 -enableSymbolLoading:$EnableSymbolLoading `
                 -updateHosts `
                 -licenseFile $LicensePath `
                 -doNotExportObjectsToText `
                 -alwaysPull `
                 -accept_outdated `
                 -assignPremiumPlan `
                 -additionalParameters @($additionalParameters) `
                 -imagename $ImageName
    }else{
        new-bccontainer -accept_eula `
                 -memoryLimit 4g `
                 -containerName $ContainerName `
                 -includeTestToolkit -includeTestLibrariesOnly `
                 -auth $Auth `
                 -updateHosts `
                 -licenseFile $LicensePath `
                 -alwaysPull `
                 -accept_outdated `
                 -assignPremiumPlan `
                 -additionalParameters @($additionalParameters) `
                 -imagename $ImageName 
    }

}


                 
Write-Host "Moving Shortcuts"                 
if (!(Test-Path -Path "$ShortCutFolder$ContainerName")) {
    New-Item -ItemType Directory -Path "$ShortCutFolder$ContainerName"
}
if (Test-Path -Path "$DesktopFolder$ContainerName Web Client.lnk") {
    Move-Item -Path "$DesktopFolder$ContainerName Web Client.lnk" -Destination "$ShortCutFolder$ContainerName\$ContainerName Web Client.lnk" -Force
}
if (Test-Path -Path "$DesktopFolder$ContainerName CSIDE.lnk") {
    Move-Item -Path "$DesktopFolder$ContainerName CSIDE.lnk" -Destination "$ShortCutFolder$ContainerName\$ContainerName CSIDE.lnk" -Force
}
if (Test-Path -Path "$DesktopFolder$ContainerName Command Prompt.lnk") { 
    Move-Item -Path "$DesktopFolder$ContainerName Command Prompt.lnk" -Destination "$ShortCutFolder$ContainerName\$ContainerName Command Prompt.lnk" -Force
}
if (Test-Path -Path "$DesktopFolder$ContainerName PowerShell Prompt.lnk") { 
    Move-Item -Path "$DesktopFolder$ContainerName PowerShell Prompt.lnk" -Destination "$ShortCutFolder$ContainerName\$ContainerName PowerShell Prompt.lnk" -Force
}
if (Test-Path -Path "$DesktopFolder$ContainerName Windows Client.lnk") {
    Move-Item -Path "$DesktopFolder$ContainerName Windows Client.lnk" -Destination "$ShortCutFolder$ContainerName\$ContainerName Windows Client.lnk" -Force
}