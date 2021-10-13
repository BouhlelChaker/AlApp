$settings = (Get-Content (Join-Path $PSScriptRoot "..\app\.vscode\launch.json") | ConvertFrom-Json).configurations
$ContainerName = ($settings.server).Remove(0,7)

if($(docker inspect -f '{{.State.Running}}' $ContainerName) -eq "true"){
$appName = (Get-Content (Join-Path $PSScriptRoot "..\app\app.json") | ConvertFrom-Json).name

$testAppName = (Get-Content (Join-Path $PSScriptRoot "..\test\app.json") | ConvertFrom-Json).name

UnPublish-BCContainerApp -containerName $ContainerName -appName "$testAppName" -unInstall -doNotSaveData -ErrorAction SilentlyContinue
UnPublish-BCContainerApp -containerName $ContainerName -appName "$appName" -unInstall -doNotSaveData -ErrorAction SilentlyContinue
}else{
    Write-Host "Container $ContainerName not running"
}