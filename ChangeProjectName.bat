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
set ConfFile=Config\Project.ini

for /f "delims=" %%a in ('PowerShell.exe -Command "%cd%\Scripts\GetConfig.ps1 'UE4PATH'"') do (
    echo %%a
    set "UE4PATH=%%a"
)

set p1=MyProject
set "p2="
set p3=0

:loop1
if "%1" neq "" (
    if "%1"=="-f" (
        set p3=1
        shift
        goto :loop1
    )
    if "%1" neq "" (
        if "%p2%" == "" (
            set p2=%1
            shift
            goto :loop1
        ) else (
            set p1=%p2%
            set p2=%1
        )
    )
)

echo Clean project dirs
FOR /d /r %%d IN ("Binaries","Build","Intermediate","Saved","TestsReports\node_modules","TestsReports\bower_components","TestsReports\reports\gg\","TestsReports\reports\ue4","TestsReports\coverage") DO @IF EXIST "%%d" rd /s /q "%%d"
FOR %%f IN ("*.sln", "*.code-workspace", "LastCoverageResults.log", "TestsReports\reports\global-reports.json") DO @IF EXIST "%%f" del "%%f"

echo Rename all project files and dir
PowerShell.exe -Command "& '%cd%\Scripts\RenameProject.ps1'" '%p1%' '%p2%' %p3%

rem ## remove quotes
set p2=%p2:"=%
set projectPath="%~dp0%p2%.uproject"
echo Rebuild project "%projectPath%"
pushd "%UE4PATH%\Engine\Binaries\DotNET\"
UnrealBuildTool.exe -projectfiles -project="%projectPath%" -game -rocket -progress
popd

:fail
exit /B 3