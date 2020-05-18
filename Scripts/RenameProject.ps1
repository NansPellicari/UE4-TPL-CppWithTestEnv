# Copyright 2020-present Nans Pellicari (nans.pellicari@gmail.com).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

param(
   [string] $FromName,
   [string] $ToName,
   [bool] $force
)

Write-Host "force? $force"

$continue = "y"
Write-Host "1- Will changes ""$FromName"" to ""$ToName"" files and directory names." -ForegroundColor Yellow

if (!$force) {
    $continue = Read-Host -Prompt 'Are you sure to continue? [y/n]'
}

if ($continue -eq "y") {
    Get-ChildItem -recurse $FromName* -File | Rename-Item -NewName { $_.Name -replace "$FromName","$ToName" }
    Get-ChildItem -recurse $FromName* -Directory | Rename-Item -NewName { $_.Name -replace "$FromName","$ToName" }
}


$continue = "y"
Write-Host "2- Will replaces ""$FromName"" occurences to ""$ToName"" in all files recursively in ./Source/ ./Config/ dir." -ForegroundColor Yellow

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
Write-Host "3- Will replaces ""$FromName"" occurences to ""$ToName"" in all files at the root dir & TestsReports/ (not recursive)." -ForegroundColor Yellow

if (!$force) {
    $continue = Read-Host -Prompt 'Are you sure to continue? [y/n]'
}

if ($continue -eq "y") {
    Get-ChildItem -File -Path ".","./TestsReports/" | ForEach-Object {
        if ($_.Name -ne "README.md" -And $_.Name -ne "ChangeProjectName.bat" -And $_.Name -ne "BatCodeCheck.exe") {
            (Get-Content $_.FullName) |
            ForEach-Object { $_ -replace [regex]::Escape("$FromName"), "$ToName" } |
            Set-Content $_.FullName
        }
    }
}
