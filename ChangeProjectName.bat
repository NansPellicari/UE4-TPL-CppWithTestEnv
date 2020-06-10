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

for /f "delims=" %%a in ('PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PROJ_DIR%\Scripts\GetConfig.ps1' 'UE4PATH'"') do (
    set UE4PATH=%%a
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
            set p1="%p2%"
            set p2=%1
        )
    )
)

call "%PROJ_DIR%\Clean.bat"

echo Rename all project files and dir
PowerShell.exe -Command "& '%PROJ_DIR%\Scripts\RenameProject.ps1' '%p1%' '%p2%' %p3%"

call "%PROJ_DIR%\GenerateProjectFiles.bat"

:fail
exit /B 3
