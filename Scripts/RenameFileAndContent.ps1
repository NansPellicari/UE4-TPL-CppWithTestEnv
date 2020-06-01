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
    [string] $Dir,
    [string] $FromName,
    [string] $ToName,
    [bool] $force
)

[string[]]$Excludes = @('*node_modules*', '*Binaries*', '*Intermediate*', '*doxygen*', 'package-lock.json', '*.git*', '*.png')

Function Get-PluginFiles($IsFile, $Filter) {

    [CmdletBinding()]
    [OutputType([string])]

    $Params = @{
        File      = $IsFile -eq 1
        Directory = $IsFile -eq 0
        Path      = $Dir
        Recurse   = $true
    }
    if ($Filter) {
        $Params["Filter"] = $Filter
    }

    $myArray = @()

    $files = Get-ChildItem @Params -Exclude $Excludes | % { 
        $allowed = $true
        foreach ($exclude in $Excludes) { 
            if ((Split-Path $_.FullName -Parent) -ilike $exclude) { 
                $allowed = $false
                break
            }
        }
        if ($allowed) {
            $myArray += $_
        }
    }

    return $myArray
}
# Get-PluginFiles 1 *$FromName* | ForEach-Object { Write-Host "1111" $_ }
# Get-PluginFiles 1 | ForEach-Object { Write-Host "2222" $_ }
# Get-PluginFiles 0 | ForEach-Object { Write-Host $_ "ddd" }
# exit


Write-Host "force? $force"

$continue = "y"
Write-Host "1- Will changes ""$FromName"" to ""$ToName"" files and directory names in $Dir." -ForegroundColor Yellow

if (!$force) {
    $continue = Read-Host -Prompt 'Are you sure to continue? [y/n]'
}

if ($continue -eq "y") {
    Write-Host "-----------------" -ForegroundColor Blue
    Write-Host "> Rename files:" -ForegroundColor Blue
    Write-Host "-----------------" -ForegroundColor Blue
    Get-PluginFiles 1 *$FromName* | ForEach-Object {
        $NewName = $_.Name -replace "$FromName", "$ToName"
        $relativePath = Get-Item $_.FullName | Resolve-Path -Relative
        Rename-Item -Path $_.FullName -NewName $NewName
        Write-Host "$relativePath > $NewName" -ForegroundColor Blue
    }
    Write-Host "-----------------" -ForegroundColor Blue
    Write-Host "> Rename folders:" -ForegroundColor Blue
    Write-Host "-----------------" -ForegroundColor Blue
    Get-PluginFiles 0 *$FromName* | ForEach-Object {
        $NewName = $_.Name -replace "$FromName", "$ToName"
        $relativePath = Get-Item $_.FullName | Resolve-Path -Relative
        Rename-Item -Path $_.FullName -NewName $NewName
        Write-Host "$relativePath > $NewName" -ForegroundColor Blue
    }
}

$continue = "y"
Write-Host "2- Will replaces ""$FromName"" occurences to ""$ToName"" in all files recursively in $Dir dir." -ForegroundColor Yellow

if (!$force) {
    $continue = Read-Host -Prompt 'Are you sure to continue? [y/n]'
}

if ($continue -eq "y") {
    Get-PluginFiles 1 | ForEach-Object {
        (Get-Content $_.FullName) |
        ForEach-Object { $_ -creplace [regex]::Escape("$FromName"), "$ToName" } |
        Set-Content $_.FullName
    }
    Get-PluginFiles 1 | ForEach-Object {
        (Get-Content $_.FullName) |
        ForEach-Object { $_ -creplace [regex]::Escape("$FromName".ToUpper()), "$ToName".ToUpper() } |
        Set-Content $_.FullName
    }
}
