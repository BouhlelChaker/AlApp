$settings = (Get-Content (Join-Path $PSScriptRoot "..\app\.vscode\launch.json") | ConvertFrom-Json).configurations
$ContainerName = ($settings.server).Remove(0,7)

Get-ChildItem -Path (Join-Path $PSScriptRoot "..\CSideObjects" ) -filter "*.fob" | ForEach-Object {
    Import-ObjectsToNavContainer -containerName $containerName -objectsFile $_.FullName
}

Generate-SymbolsInNavContainer -containerName $containerName