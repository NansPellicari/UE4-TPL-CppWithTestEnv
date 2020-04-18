@echo off

REM @see https://adamrehn.com/docs/ue4-docker/use-cases/continuous-integration

setlocal 
echo Running test
rem ## to get the ESC caracter, used to colorized output
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set ProjDirectory=%cd%

for /f "delims=" %%a in ('PowerShell.exe -Command "%cd%\Scripts\GetConfig.ps1 'UE4PATH'"') do (
    echo %%a
    set "UE4PATH=%%a"
)
for /f "delims=" %%a in ('PowerShell.exe -Command "%cd%\Scripts\GetConfig.ps1 'PROJECT'"') do (
    echo %%a
    set "PROJECT=%%a"
)

rem ## Get the OS version
rem ## thanks to https://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32 || set OS=64

rem ## Retrieve parameters
:continue
if "%1"=="" goto end
set testSuite=%testSuite%%1+
shift
goto continue
:end

set command=Automation RunAll
if "%testSuite%" neq "" ( set command=Automation RunTests %testSuite% )

rem ## Run build
echo  %ESC%[32mLaunch command %UE4PATH%\Engine\Build\BatchFiles\Build.bat %PROJECT%Editor Win%OS% Development "%ProjDirectory%\%PROJECT%.uproject" -waitmutex%ESC%[0m
call %UE4PATH%\Engine\Build\BatchFiles\Build.bat %PROJECT%Editor Win%OS% Development "%ProjDirectory%\%PROJECT%.uproject" -waitmutex
echo error level output: %ERRORLEVEL%
if not %ERRORLEVEL% == 0 goto Exit_Failure

rem ## Run Test
pushd "%UE4PATH%/Engine/Binaries/Win64"
UE4Editor-Cmd.exe "%ProjDirectory%\%PROJECT%.uproject" -unattended -nopause -NullRHI -ExecCmds="%command%; quit" -TestExit="Automation Test Queue Empty" -log -log=RunTests.log -ReportOutputPath="%ProjDirectory%\TestsReports\reports\ue4"
echo %ProjDirectory%\%PROJECT%.uproject
echo error level output: %ERRORLEVEL%
REM if not %ERRORLEVEL% == 0 goto Exit_Failure
popd

rem ## Success!
rem ## Clean test environment

pushd "TestsReports/"
rem ## srmdir test
echo Clean and reinstall server to display tests results (npm)
for /f %%i in ('npm run server:id') do set serverId=%%i
if "%serverId%" neq "[]" ( call npm run server:clean )
call npm install
call npm run test:ue4
call npm run server:start
echo Your should open http://localhost:9999 to see tests results
popd

rem ## Restore original CWD in case we change it
popd
exit /B %ERRORLEVEL%

