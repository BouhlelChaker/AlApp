Param(
    [string] $TestSuite = 'DEFAULT', #TestRunner Codeunit
    [switch] $RunClient = $false,
    [switch] $NoTests,
    [string] $CompanyName = 'CRONUS Danmark A/S',
    [switch] $OnlyTests
)
$sw1 = [Diagnostics.Stopwatch]::StartNew()

$appName = (Get-Content (Join-Path $PSScriptRoot "..\app\app.json") | ConvertFrom-Json).name
$publisher = (Get-Content (Join-Path $PSScriptRoot "..\app\app.json") | ConvertFrom-Json).publisher
$version = (Get-Content (Join-Path $PSScriptRoot "..\app\app.json") | ConvertFrom-Json).version
$fileName = $publisher + '_' + $appName + '_' + $version

$testAppName = (Get-Content (Join-Path $PSScriptRoot "..\test\app.json") | ConvertFrom-Json).name
$testpublisher = (Get-Content (Join-Path $PSScriptRoot "..\test\app.json") | ConvertFrom-Json).publisher
$testversion = (Get-Content (Join-Path $PSScriptRoot "..\test\app.json") | ConvertFrom-Json).version
$testid = (Get-Content (Join-Path $PSScriptRoot "..\test\app.json") | ConvertFrom-Json).Id
$testfileName = $testpublisher + '_' + $testAppName + '_' + $testversion

$settings = (Get-Content (Join-Path $PSScriptRoot "..\app\.vscode\launch.json") | ConvertFrom-Json).configurations
$ContainerName = ($settings.server).Remove(0,7)
$SchemaUpdateMode = $settings.schemaUpdateMode

if($SchemaUpdateMode -eq "Synchronize"){
    $SyncMode = "Add"
}elseif($SchemaUpdateMode -eq "Recreate"){
    $SyncMode = "Clean"
}elseif($SchemaUpdateMode -eq "ForceSync"){
    $SyncMode = "Development"
}else{
    $SyncMode = "Add"
}

if($(docker inspect -f '{{.State.Running}}' $ContainerName) -eq "true"){

UnPublish-BCContainerApp -containerName $ContainerName -appName "$testAppName" -unInstall -doNotSaveData -ErrorAction SilentlyContinue
UnPublish-BCContainerApp -containerName $ContainerName -appName "$appName" -unInstall -doNotSaveData -ErrorAction SilentlyContinue

if (!(Test-Path -Path "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp")){
    New-Item -ItemType Directory -Path "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\"
}

if($OnlyTests -eq $false){

  write-host "Compiling and publishing app" -BackgroundColor Green -ForegroundColor Black
  Remove-Item -Path "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\app" -Recurse -Force -ErrorAction SilentlyContinue
  Copy-Item (Join-Path $PSScriptRoot "..\app") -Destination "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\" -Recurse -Force
  
  Compile-AppInBCContainer -containerName $ContainerName -appProjectFolder "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\app" -appOutputFolder "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\app" -appSymbolsFolder "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\app\.alpackages"
  
  Publish-BCContainerApp -containerName $ContainerName -appFile "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\app\$fileName.app" -sync -syncMode $SyncMode  -skipVerification -ErrorAction Continue
  Publish-BCContainerApp -containerName $ContainerName -appFile "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\app\$fileName.app" -sync -skipVerification -install -ErrorAction Continue
  }
  
  if($NoTests -eq $false){
    write-host "Compiling and publishing test" -BackgroundColor Green -ForegroundColor Black
    Remove-Item -Path "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\test" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item (Join-Path $PSScriptRoot "..\test") -Destination "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\" -Recurse -Force
    
    Compile-AppInBCContainer -containerName $ContainerName -appProjectFolder "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\test" -appOutputFolder "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\test" -appSymbolsFolder "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\test\.alpackages"
    
    Publish-BCContainerApp -containerName $ContainerName -appFile "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\test\$testfileName.app" -sync -skipVerification -install 
    
    write-host "Running Tests" -BackgroundColor Green -ForegroundColor Black
    
    $sw = [Diagnostics.Stopwatch]::StartNew()

    $testResultsFile = "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\Test Results.xml"
    
    $first = $true
    $rerunTests = @()
    $failedTests = @()

    $getTestsParam = @{ "ExtensionId" = "$testid" }

    $tests = Get-TestsFromBCContainer @getTestsParam `
      -containerName $containerName `
      -credential $credential `
      -ignoreGroups `
      -testSuite "$TestSuite" `
      -debugMode
      
    $azureDevOpsParam = @{ "AzureDevOps" = "Warning" }

    $tests | ForEach-Object {
      if (-not (Run-TestsInBcContainer @AzureDevOpsParam `
        -containerName $containerName `
        -credential $credential `
        -XUnitResultFileName $testResultsFile `
        -AppendToXUnitResultFile:(!$first) `
        -testSuite $testSuite `
        -testCodeunit $_.Id `
        -returnTrueIfAllPassed `
        -companyName $CompanyNane `
        -restartContainerAndRetry)){$rerunTests += $_ }
      }
          $first = $false
          if ($rerunTests.Count -gt 0 -and $reRunFailedTests) {
            Restart-BCContainer -containerName $containername
            $rerunTests | % {
                if (-not (Run-TestsInBcContainer @AzureDevOpsParam `
                    -containerName $containerName `
                    -credential $credential `
                    -XUnitResultFileName $testResultsFile `
                    -AppendToXUnitResultFile:(!$first) `
                    -testSuite $testSuite `
                    -testCodeunit $_.Id `
                    -returnTrueIfAllPassed `
                    -restartContainerAndRetry)) { $failedTests += $_ }
                $first = $false
            }
        }
        $sw.Stop()
        Write-host "Tests finished in total seconds:" 
        $sw.Elapsed.TotalSeconds

write-host "Unpublishing" -BackgroundColor Green -ForegroundColor Black

UnPublish-BCContainerApp -containerName $ContainerName -appName "$testAppName" -unInstall -doNotSaveData -ErrorAction Continue

write-host "Creating XMLs" -BackgroundColor Green -ForegroundColor Black
[xml]$xml = Get-Content "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\Test Results.xml"
#
$Tests = $xml.SelectNodes("assemblies/assembly/collection/test").Count
#
$cons = $xml.SelectNodes("assemblies/assembly/collection/test")|Where-Object {$_.result -match 'Pass'}|%{$_.ParentNode.RemoveChild($_)}

$Failed = $xml.SelectNodes("assemblies/assembly/collection/test").Count
$Tests = $Tests - $Failed

Write-Host "Number of passed tests: $Tests " -BackgroundColor Green -ForegroundColor Black
if($Failed -ne 0){
    Write-Host "The following $Failed failed: " -BackgroundColor Red -ForegroundColor Black
    $xml.SelectNodes("assemblies/assembly/collection/test") | ForEach-Object {Write-Host $_.name ": " $_.failure.message}
}

Remove-Item -Path "C:\ProgramData\NavContainerHelper\Extensions\$ContainerName\temp\" -Recurse -Force -ErrorAction SilentlyContinue
}
$sw1.Stop()
Write-host "Script finished in total seconds:" -BackgroundColor Green -ForegroundColor Black
$sw1.Elapsed.TotalSeconds

if(($RunClient) -eq $true){
    Start-Process "http://$ContainerName/bc" -ErrorAction SilentlyContinue
    }
} else {
    $sw1.Stop()
    Write-Host "$ContainerName not running"
}