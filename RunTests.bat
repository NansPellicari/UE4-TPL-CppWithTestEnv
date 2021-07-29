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

setlocal enableDelayedExpansion

set PROJ_DIR=%~dp0

rem ## retrieve start date to show file's execution time at the end
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

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

rem ## Check if UE4PATH setting is good
if not exist "!UE4PATH!\Engine\Build\BatchFiles\Build.bat" (
    echo !ESC![91mWrong path "!UE4PATH!" given for the engine directory, can't find the "Engine\Build\BatchFiles\Build.bat" file!ESC![0m 
    goto Exit_Failure
)


rem ## get cmd parameters
set coverage=0
set "build="

:loop1
if "%1" neq "" (
    if "%1"=="-c" (
        set coverage=1
        SHIFT
        goto :loop1
    )
    if "%1"=="-b" (
        set build=%2
        SHIFT & SHIFT
        goto :loop1
    )
)

if "!build!" == "" (
    echo !ESC![91mPlease specified a build: !ESC![36m-b gg!ESC![0m or !ESC![36m-b ue4!ESC![0m
    goto :Exit_Failure
)

:loop2
if "%1" neq "" (
    rem ## Special case for UE4 build
    rem ## this allow to format params like this: MyNewGame+MyPlugin.Spec+
    if "!build!"=="ue4" set extraParams=!extraParams!%1+
    if "!build!"=="gg" goto :after_loop
    SHIFT
    goto :loop2
)

:after_loop
rem ## Just to remove the useless "+"" at the end
if "!build!"=="ue4" (
    if "!extraParams!" neq "" (
        set extraParams=%extraParams:~0,-1%
    )
)

rem ## for google tests, every options in the cmd tail are passed to the executable
set "allParams=%*"
if "!build!"=="gg" (
    call set extraParams=!allParams:*gg=!
)

rem ## Display user choices
echo !ESC![36m
echo Will build with:
echo -------------------------------
echo with coverage : !coverage!
echo build         : !build!
echo extraParams   : !extraParams!
echo -------------------------------
echo !ESC![0m

rem ## If you use external plugins in your project, you can exlude them, just add anothers "--excluded_sources" parameters.
rem ## see https://github.com/OpenCppCoverage/OpenCppCoverage/wiki/Command-line-reference
rem ## We can't have a config files instead of this line because of the UE4's build which is run in a different path.
rem ## This is why we have to pass an absolute path depends on your system conf using %PROJ_DIR% var.
set coverageCommand=OpenCppCoverage ^
 --sources=!PROJ_DIR!* ^
 --excluded_sources="**\Plugins\GoogleTest" ^
 --excluded_sources="**\*.gen.cpp" ^
 --excluded_sources="**\Mock\**" ^
 --excluded_sources="**\Specs\**" ^
 --export_type=html:"!PROJ_DIR!\TestsReports\coverage\!build!" --export_type=cobertura:"!PROJ_DIR!\TestsReports\coverage\!build!\coverage.xml"

set "buildCommand="
set "testCommand="
set dirToRun=!PROJ_DIR!

set hh=!time:~0,2!
if "!hh:~0,1!"==" " set hh=0!hh:~1,1!
set mm=!time:~3,2!
if "!mm:~0,1!"==" " set mm=0!mm:~1,1!
set ss=!time:~6,2!
if "!ss:~0,1!"==" " set ss=0!ss:~1,1!

for /f "usebackq" %%i in (`PowerShell ^(Get-Date^).ToString^('yyyy-MM-dd'^)`) do set DTime=%%i

if "!build!"=="gg" (
    set buildCommand=!UE4PATH!\Engine\Build\BatchFiles\Build.bat GoogleTestApp Win!OSver! Development "!PROJ_DIR!\GoogleTestApp.uproject" -waitmutex
    set testCommand=.\Binaries\Win64\GoogleTestApp.exe --gtest_output=xml:!PROJ_DIR!/TestsReports/reports/gg/test-%DTime%_%hh%%mm%%ss%.xml %extraParams%
    set dirToRun="!PROJ_DIR!"
)

if "!build!"=="ue4" (
    rem ## This is my naming convention, Every *Core* module is only tested with GG tests,
    rem ## so to avoid uncovered lines which are covered elsewhere, I excluded them here.
    rem ## Change this line to adapt it on your naming convention.
    set coverageCommand=!coverageCommand! --excluded_modules=*Core*
    set buildCommand=!UE4PATH!\Engine\Build\BatchFiles\Build.bat !PROJECT!Editor Win!OSver! Development "!PROJ_DIR!\!PROJECT!.uproject" -waitmutex
    set subcommand=Automation RunAll
    if "!extraParams!" neq "" ( set subcommand=Automation RunTests !extraParams! )
    set testCommand=UE4Editor-Cmd.exe "!PROJ_DIR!\!PROJECT!.uproject" -unattended -nopause -NullRHI -ExecCmds="!subcommand!; quit" -TestExit="Automation Test Queue Empty" -log -log=RunTests.log -ReportExportPath="!PROJ_DIR!\TestsReports\reports\ue4"
    set dirToRun="!UE4PATH!/Engine/Binaries/Win!OSver!"
)

rem ## Run build
echo !ESC![36;1m-- Run build
echo !ESC![0m

echo  !ESC![36mLaunch build command !buildCommand!
echo !ESC![0m
call !buildCommand!
if not !ERRORLEVEL! == 0 goto Exit_Build_Failure

rem ## Add coverage command prefix
if !coverage! == 1 (
    set testCommand=!coverageCommand! -- !testCommand!
)

rem ## Run tests
echo !ESC![36;1m-- Run tests
echo !ESC![0m

pushd !dirToRun!
echo in !ESC![36m!dirToRun!!ESC![0m
echo will run !ESC![36m!testCommand!
echo !ESC![0m

call !testCommand!
popd

rem ## Create reports with npm in the TestsReports dir
echo !ESC![36;1m-- Create reports
echo !ESC![0m
pushd "TestsReports/"
for /f %%i in ('npm run server:id') do set serverId="%%i"
if !serverId!=="[]" ( 
    rem ## Clean and reinstall server to display tests results (npm)
    call npm install
    call npm run server:clean
    call npm run server:start
)
call npm run build:!build!
if !coverage! == 1 call npm run build:coverage

echo Your should open !ESC![92mhttp://localhost:9999 !ESC![0m to see tests results
popd

rem ## retrieve end date to show file's execution time below
for /F "tokens=1-4 delims=:.," %%a in ("!time!") do (
   set /A "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

set /a runtime = (!end! - !start!)*10
echo !ESC![36;1mrun in !runtime! ms!ESC![0m
exit /B 0

:Exit_Build_Failure
echo !ESC![101;30m -- Build failed -- !ESC![0m 

:Exit_Failure
echo !ESC![91mfailed with error level !ERRORLEVEL!!ESC![0m 
exit /B !ERRORLEVEL!
