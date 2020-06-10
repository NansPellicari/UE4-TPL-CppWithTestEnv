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

set projectPath=%PROJ_DIR%%PROJECT%.uproject

if not exist "%projectPath%" (
    echo %ESC%[91mProject does not exists here: "%projectPath%"%ESC%[0m 
    goto Exit_Failure
)

pushd "TestsReports/"
rem ## Clean server and reinstall server dependencies (npm)
call npm run server:clean
call npm install
call npm run server:start
popd

echo Rebuild project "%projectPath%"
pushd "%UE4PATH%\Engine\Binaries\DotNET\"
UnrealBuildTool.exe -projectfiles -project="%projectPath%" -game -rocket -progress -engine
popd


if exist ".\.vscode\settings.json" (
    pushd "TestsReports/"
        call npm run mergevs ..\.vscode\settings.json ..\.vscode\settings.sample.json
    popd
)

if exist ".\.vscode\launch.json" (
    pushd "TestsReports/"
        call npm run mergevs ..\.vscode\launch.json ..\.vscode\launch.sample.json
    popd
)

if exist ".\.vscode\tasks.json" (
    pushd "TestsReports/"
        call npm run mergevs ..\.vscode\tasks.json ..\.vscode\tasks.sample.json
    popd
)


:Exit_Failure
exit /b 3
