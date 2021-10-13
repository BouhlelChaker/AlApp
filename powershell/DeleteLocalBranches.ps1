Param(
    [switch] $Force
)

$CurrentPath = Get-Location
Set-Location (Join-Path $PSScriptRoot '..')

git fetch --prune
$RegEx = (@(".*origin/.*: gone]"))
git branch -vv | Where-Object {$_ -match $RegEx} | ForEach-Object{
    $split = $_.split(" ",[System.StringSplitOptions]'RemoveEmptyEntries')
    Write-Host "$split[0]"
}

if ($Force -eq $false){
    $Confirmation = Read-Host "Delete above branches [y/n]"
}

if (($Confirmation -eq 'y') -or ($Force -eq $true)){
    $RegEx = (@(".*origin/.*: gone]"))
    git branch -vv | Where-Object {$_ -match $RegEx} | ForEach-Object{
        $split = $_.split(" ",[System.StringSplitOptions]'RemoveEmptyEntries')
        git branch -D $split[0]
    }
}else{write-host "Aborted"}

Set-Location $CurrentPath
