param(
   [string] $FromName,
   [string] $ToName,
   [bool] $force
)

Write-Host "force? $force"

$continue = "y"
Write-Host "Will changes ""$FromName"" to ""$ToName"" files and directory names." -ForegroundColor Yellow

if (!$force) {
    $continue = Read-Host -Prompt 'Are you sure to continue? [y/n]'
}

if ($continue -eq "y") {
    Get-ChildItem -recurse $FromName* -File | Rename-Item -NewName { $_.Name -replace "$FromName","$ToName" }
    Get-ChildItem -recurse $FromName* -Directory | Rename-Item -NewName { $_.Name -replace "$FromName","$ToName" }
}


$continue = "y"
Write-Host "Will replace ""$FromName"" occurences to ""$ToName"" in all files recursively in ./Source/ ./Config/ dir." -ForegroundColor Yellow

if (!$force) {
    $continue = Read-Host -Prompt 'Are you sure to continue? [y/n]'
}

if ($continue -eq "y") {
    Get-ChildItem -File -Path "./Source/","./Config/" -Recurse -Exclude *.sample | ForEach-Object {
        (Get-Content $_.FullName) |
        ForEach-Object { $_ -creplace [regex]::Escape("$FromName"), "$ToName" } |
        Set-Content $_.FullName
    }
    Get-ChildItem -File -Path "./Source/","./Config/" -Recurse -Exclude *.sample | ForEach-Object {
        (Get-Content $_.FullName) |
        ForEach-Object { $_ -creplace [regex]::Escape("$FromName".ToUpper()), "$ToName".ToUpper() } |
        Set-Content $_.FullName
    }
}

$continue = "y"
Write-Host "Will replace ""$FromName"" occurences to ""$ToName"" in all files at the root dir & TestsReports/ (not recursive)." -ForegroundColor Yellow

if (!$force) {
    $continue = Read-Host -Prompt 'Are you sure to continue? [y/n]'
}

if ($continue -eq "y") {
    Get-ChildItem -File -Path ".","./TestsReports/" | ForEach-Object {
        if ($_.Name -ne "README.md" -And $_.Name -ne "ChangeProjectName.bat") {
            (Get-Content $_.FullName) |
            ForEach-Object { $_ -replace [regex]::Escape("$FromName"), "$ToName" } |
            Set-Content $_.FullName
        }
    }
}
