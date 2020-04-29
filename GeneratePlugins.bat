@echo off
rem # Copyright 2020-present Nans Pellicari (nans.pellicari@gmail.com).
rem #
rem # Licensed under the Apache License, Version 2.0 (the "License");
rem # you may not use this file except in compliance with the License.
rem # You may obtain a copy of the License at
rem #
rem # http://www.apache.org/licenses/LICENSE-2.0
rem #
rem # Unless required by applicable law or agreed to in writing, software
rem # distributed under the License is distributed on an "AS IS" BASIS,
rem # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem # See the License for the specific language governing permissions and
rem # limitations under the License.

setlocal

rem ## Get the OS version
for /f "delims=" %%a in ('PowerShell.exe -Command "(Get-WmiObject Win32_OperatingSystem).OSArchitecture"') do (
    set "OS=%%a"
)
set "OS=%OS:~0,2%"

rem ## to get the ESC character, used to colorized output
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

for /f "delims=" %%a in ('PowerShell.exe -Command "%cd%\Scripts\GetConfig.ps1 'UE4PATH'"') do (
    set "UE4PATH=%%a"
)

for /f "delims=" %%a in ('PowerShell.exe -Command "%cd%\Scripts\GetConfig.ps1 'PROJECT'"') do (
    set "PROJECT=%%a"
)

if not exist "%UE4PATH%\Engine\Build\BatchFiles\Build.bat" (
    echo %ESC%[91mWrong path "%UE4PATH%" given for the engine directory, can't find the "Engine\Build\BatchFiles\Build.bat" file%ESC%[0m 
    set ERRORLEVEL=2
    goto Exit_Failure
)

set projectPath=%~dp0
set pluginPath="%projectPath%\Plugins"
set projectFile=%projectPath%%PROJECT%.uproject

if not exist "%projectFile%" (
    echo %ESC%[91mProject does not exists here: "%projectFile%"%ESC%[0m 
    set ERRORLEVEL=2
    goto Exit_Failure
)

set name=%~1
set template=BlankPlugin
if "%name%"=="-h" goto choices

rem ## Display user choices
echo %ESC%[36m
echo Will generate plugin with:
echo -------------------------------
echo name: %name%
echo template: %template%
echo project: %projectFile%
echo -------------------------------
echo %ESC%[0m

PowerShell.exe -Command "%projectPath%\Scripts\GeneratePlugin.ps1 '%UE4PATH%/Engine/Plugins/Developer' '%template%' '%projectPath%' '%name%'"

pushd "%UE4PATH%\Engine\Binaries\DotNET\"
mkdir "%projectPath%\Plugins\%name%\"
UnrealBuildTool.exe Development Win%OS% -TargetType=Editor -Plugin="%projectPath%\Plugins\%name%\%name%.uplugin" -Project="%projectFile%" -Progress -NoHotReloadFromIDE
popd

exit /b 0

:Exit_Failure
exit /b 3

:choices
echo %ESC%[36m
echo usage: .\GeneratePlugins.bat [-h] 'Name'
echo %ESC%[0m
:end