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

set PROJ_DIR=%~dp0

rem ## to get the ESC character, used to colorized output
for /F %%a in ('echo prompt $E ^| cmd') do set ESC=%%a


rem ## Get the OS version
for /f "delims=" %%a in ('PowerShell.exe -Command "(Get-WmiObject Win32_OperatingSystem).OSArchitecture"') do (
    set OSver=%%a
)
set OSver=%OSver:~0,2%

rem ## retrieve project settings
for /f "delims=" %%a in ('PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PROJ_DIR%\Scripts\GetConfig.ps1' 'UE4PATH'"') do (
    set UE4PATH=%%a
)

for /f "delims=" %%a in ('PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PROJ_DIR%\Scripts\GetConfig.ps1' 'PROJECT'"') do (
    set PROJECT=%%a
)

if not exist "%UE4PATH%\Engine\Build\BatchFiles\Build.bat" (
    echo %ESC%[91mWrong path "%UE4PATH%" given for the engine directory, can't find the "Engine\Build\BatchFiles\Build.bat" file%ESC%[0m 
    goto Exit_Failure
)

set pluginPath="%PROJ_DIR%\Plugins"
set projectFile=%PROJ_DIR%%PROJECT%.uproject

if not exist "%projectFile%" (
    echo %ESC%[91mProject does not exists here: "%projectFile%"%ESC%[0m 
    goto Exit_Failure
)

set name=%~1
set template=BlankPlugin
if "%name%"=="-h" goto choices
if "%name%"=="" goto choices

rem ## Display user choices
echo %ESC%[36m
echo Will generate plugin with:
echo -------------------------------
echo "name: %name%"
echo "template: %template%"
echo "project: %projectFile%"
echo "your OS version: %OSVer%"
echo -------------------------------
echo %ESC%[0m

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PROJ_DIR%\Scripts\GeneratePlugin.ps1' '%UE4PATH%/Engine/Plugins/Developer' '%template%' '%PROJ_DIR%' '%name%'"

pushd "%UE4PATH%\Engine\Binaries\DotNET\"
UnrealBuildTool.exe Development Win%OSVer% -TargetType=Editor -Plugin="%PROJ_DIR%\Plugins\%name%\%name%.uplugin" -Project="%projectFile%" -Progress -NoHotReloadFromIDE
popd

exit /b 0

:Exit_Failure
exit /b 3

:choices
echo %ESC%[36m
echo usage: .\GeneratePlugins.bat [-h] 'MyPluginName'
echo %ESC%[0m
:end
