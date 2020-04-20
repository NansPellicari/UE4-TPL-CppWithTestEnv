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

set ProjDirectory=%cd%
set start=%time%

rem ## to get the ESC character, used to colorized output
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

rem ## Get the OS version
rem ## thanks to https://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32 || set OS=64

rem ## due to the command above, errorlevel is set to 1, see https://support.microsoft.com/en-gb/help/556009
rem ## so just reset it here
if %ERRORLEVEL% == 1 (
    set ERRORLEVEL=0
)

rem ## retrieve project settings
for /f "delims=" %%a in ('PowerShell.exe -Command "%cd%\Scripts\GetConfig.ps1 'UE4PATH'"') do (
    set "UE4PATH=%%a"
)
for /f "delims=" %%a in ('PowerShell.exe -Command "%cd%\Scripts\GetConfig.ps1 'PROJECT'"') do (
    set "PROJECT=%%a"
)

if "%UE4PATH%" == "" (
    echo %ESC%[91mYou have to set the Engine directory in the Config/Project.ini %ESC%[0m
    set ERRORLEVEL=2
    goto Exit_Failure
)

if not exist "%UE4PATH%" (
    echo %ESC%[91mDirectory %UE4PATH% does not exists%ESC%[0m
    set ERRORLEVEL=2
    goto Exit_Failure
)

if not exist "%UE4PATH%\Engine\Build\BatchFiles\Build.bat" (
    echo %ESC%[91mWrong path "%UE4PATH%" given for the engine directory, can't find the "Engine\Build\BatchFiles\Build.bat" file%ESC%[0m 
    set ERRORLEVEL=2
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

if "%build%" == "" (
    echo %ESC%[91mPlease specified a build: %ESC%[36m-b gg%ESC%[0m or %ESC%[36m-b ue4%ESC%[0m
    goto :Exit_Failure
)

:loop2
if "%1" neq "" (
    rem ## Special case for UE4 build
    rem ## this allow to build params like this: MyNewGame+MyPlugin.Spec+
    if "%build%"=="ue4" set extraParams=%extraParams%%1+
    if "%build%"=="gg" goto :after_loop
    SHIFT
    goto :loop2
)

:after_loop
rem ## Just to remove the useless + at the end
if "%build%"=="ue4" (
    if "%extraParams%" neq "" (
        set extraParams=%extraParams:~0,-1%
    )
)

rem ## every opts int the cmd tail are passed to the executable
set allParams=%*
if "%build%"=="gg" (
    call set extraParams=%allParams:*gg=%
)

rem ## Display user choices
echo %ESC%[36m
echo Will build with:
echo -------------------------------
echo with coverage : %coverage%
echo build         : %build%
echo extraParams   : %extraParams%
echo -------------------------------
echo %ESC%[0m

set coverageCommand=OpenCppCoverage --sources=%ProjDirectory% --excluded_sources=%ProjDirectory%\Plugins\GoogleTest  --export_type=html:%ProjDirectory%\TestsReports\coverage\%build% --export_type=cobertura:%ProjDirectory%\TestsReports\coverage\%build%\coverage.xml
set "buildCommand="
set "testCommand="
set dirToRun=%ProjDirectory%

set hh=%time:~0,2%
if "%hh:~0,1%" == " " set hh=0%hh:~1,1%
set mm=%time:~3,2%
if "%mm:~0,1%" == " " set mm=0%mm:~1,1%
set ss=%time:~6,2%
if "%ss:~0,1%" == " " set ss=0%ss:~1,1%

if "%build%"=="gg" (
    set buildCommand=%UE4PATH%\Engine\Build\BatchFiles\Build.bat GoogleTestApp Win%OS% Development "%ProjDirectory%\GoogleTestApp.uproject" -waitmutex
    set testCommand=.\Binaries\Win64\GoogleTestApp.exe --gtest_output=xml:./TestsReports/reports/gg/test-%date:~6,4%%date:~3,2%%date:~0,2%-%hh%%mm%%ss%.xml %extraParams%

)
if "%build%"=="ue4" (
    set buildCommand=%UE4PATH%\Engine\Build\BatchFiles\Build.bat %PROJECT%Editor Win%OS% Development "%ProjDirectory%\%PROJECT%.uproject" -waitmutex
    set subcommand=Automation RunAll
    if "%extraParams%" neq "" ( set subcommand=Automation RunTests %extraParams% )
    set testCommand=UE4Editor-Cmd.exe "%ProjDirectory%\%PROJECT%.uproject" -unattended -nopause -NullRHI -ExecCmds="!subcommand!; quit" -TestExit="Automation Test Queue Empty" -log -log=RunTests.log -ReportOutputPath="%ProjDirectory%\TestsReports\reports\ue4"
    set dirToRun="%UE4PATH%/Engine/Binaries/Win%OS%"
)

rem ## Run build
echo %ESC%[36;1m-- Run build
echo %ESC%[0m

echo  %ESC%[36mLaunch build command %buildCommand%
echo %ESC%[0m
call %buildCommand%
echo error level output: %ERRORLEVEL%
if not %ERRORLEVEL% == 0 goto Exit_Failure

rem ## Add coverage command prefix
if %coverage% == 1 (
    set testCommand=%coverageCommand% -- %testCommand%
)

rem ## Run tests
echo %ESC%[36;1m-- Run tests
echo %ESC%[0m

pushd %dirToRun%
echo in %ESC%[36m%dirToRun%%ESC%[0m
echo will run %ESC%[36m%testCommand%
echo %ESC%[0m

call %testCommand%
popd

rem ## Create reports with npm in the TestsReports dir
echo %ESC%[36;1m-- Create reports
echo %ESC%[0m
pushd "TestsReports/"
for /f %%i in ('npm run server:id') do set serverId=%%i
if "%serverId%"=="[]" ( 
    rem ## Clean and reinstall server to display tests results (npm)
    call npm install
    call npm run server:start
)
call npm run test:%build%
if %coverage% == 1 call npm run test:coverage

echo Your should open %ESC%[92mhttp://localhost:9999%ESC%[0m to see tests results
popd

set end=%time%

rem to compute script execution time
set /a h=1%start:~0,2%-100
set /a m=1%start:~3,2%-100
set /a s=1%start:~6,2%-100
set /a c=1%start:~9,2%-100
set /a starttime = %h% * 360000 + %m% * 6000 + 100 * %s% + %c%
 
set /a h=1%end:~0,2%-100
set /a m=1%end:~3,2%-100
set /a s=1%end:~6,2%-100
set /a c=1%end:~9,2%-100
set /a endtime = %h% * 360000 + %m% * 6000 + 100 * %s% + %c%
 
rem runtime in 100ths is now just end - start
set /a runtime = %endtime% - %starttime%
set runtime = %s%.%c%
echo %ESC%[36;1mrun in %runtime%0 ms%ESC%[0m
exit /B 0

:Exit_Failure
echo %ESC%[91mfailed with error level %ERRORLEVEL%%ESC%[0m 
exit /B %ERRORLEVEL%
