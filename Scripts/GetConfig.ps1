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
    [string] $ConfigName
)

$ConfFile = "Config\Project.ini"
$confexists = Test-Path $ConfFile
if ($confexists -eq 0) {
    Copy-Item "$ConfFile.sample" -Destination $ConfFile
}

$line = Get-Content -Path $ConfFile | Where-Object { $_ -match "$ConfigName=" }
$exists=0
$ConfigValue=0

if ($line -ne $null) {
    $ConfigValue = $line.Split('=')[1]
    
    if ($ConfigName -eq "UE4PATH") {
        $exists = Test-Path $ConfigValue/Engine
    }
}

if ($ConfigName -eq "UE4PATH") {
    if (!$exists)
    {
        Do{
            Write-Warning "Path $ConfigValue is not valid"
            $ConfigValue = Read-Host -Prompt 'Enter UE4 path: '
            $exists = Test-Path $ConfigValue/Engine
        } Until($ConfigValue -ne $null -And $ConfigValue -ne "" -And $exists -ne 0)
    }
    (Get-Content $ConfFile) -replace 'UE4PATH=.*', "UE4PATH=$ConfigValue" | Set-Content $ConfFile
}

if ($line -ne $null) {
    $ConfigValue = $line.Split('=')[1]
    
    if ($ConfigName -eq "PLUGINSPATH") {
        $exists = Test-Path $ConfigValue
    }
}

if ($ConfigName -eq "PLUGINSPATH") {
    if (!$exists)
    {
        Do{
            Write-Warning "Path $ConfigValue is not valid"
            $ConfigValue = Read-Host -Prompt 'Enter plugins compilation path: '
            $exists = Test-Path $ConfigValue
        } Until($ConfigValue -ne $null -And $ConfigValue -ne "" -And $exists -ne 0)
    }
    (Get-Content $ConfFile) -replace 'PLUGINSPATH=.*', "PLUGINSPATH=$ConfigValue" | Set-Content $ConfFile
}

Write-Host $ConfigValue