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
    [string] $tplPath,
    [string] $tplName,
    [string] $projectPath,
    [string] $name
)

$destination="$projectPath/Plugins/$name"
Write-Host "1- copy $tplPath/$tplName" to "$destination" -ForegroundColor Cyan
if (Test-Path -Path "$destination") {
    Copy-Item -recurse "$tplPath/$tplName/*" -Destination "$destination/"
} else {
    Copy-Item -recurse "$tplPath/$tplName" -Destination "$destination"
}

if (Test-Path -Path "$destination/Binaries") {
    Write-Host "2- remove $destination/Binaries and $destination/Intermediate folders" -ForegroundColor Cyan
    Remove-Item -Path "$destination/Binaries","$destination/Intermediate" -Recurse -Force
}

Write-Host "3- replace all files and folders which contains $tplName name" -ForegroundColor Cyan
# replace all files first which contains $tplName in their name
Get-ChildItem -Path $destination -recurse -Include *$tplName* -File | Rename-Item -NewName { $_.Name -replace "$tplName","$name" }
# and directories which contains $tplName in their name
Get-ChildItem -Path $destination -recurse -Include *$tplName* -Directory | Rename-Item -NewName { $_.Name -replace "$tplName","$name" }

Write-Host "4- replace in each files the string $tplName > $name" -ForegroundColor Cyan
# To replace all text $tplName > MyPlugin
Get-ChildItem -File -Path $destination -Recurse | ForEach-Object {
    (Get-Content $_.FullName) |
    ForEach-Object { $_ -creplace [regex]::Escape("$tplName"), "$name" } |
    Set-Content $_.FullName
}

Write-Host "5- replace in each files the string "$tplName.ToUpper()" > "$name.ToUpper() -ForegroundColor Cyan
# To replace class macro as MYPLUGIN_API
Get-ChildItem -File -Path $destination -Recurse | ForEach-Object {
    (Get-Content $_.FullName) |
    ForEach-Object { $_ -creplace [regex]::Escape("$tplName".ToUpper()), "$name".ToUpper() } |
    Set-Content $_.FullName
}

if (-not (Test-Path -Path "$destination")) {
    throw 'The plugin creation failed'
}

Write-Host "You should add these lines in your .uproject or .uplugin file:" -ForegroundColor Green

Write-Host "`"Plugins`": [" -ForegroundColor Green
Write-Host "		{" -ForegroundColor Green
Write-Host "			`"Name`": `"$name`"," -ForegroundColor Green
Write-Host "			`"Enabled`": true" -ForegroundColor Green
Write-Host "		}" -ForegroundColor Green
Write-Host "	]" -ForegroundColor Green
