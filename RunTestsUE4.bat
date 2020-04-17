@echo off

REM @see https://adamrehn.com/docs/ue4-docker/use-cases/continuous-integration

setlocal 
echo Running test
rem ## to get the ESC caracter, used to colorized output
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set ProjDirectory=%cd%

rem ## Retrieve parameters
:continue
if "%1"=="" goto end
set testSuite=%testSuite%%1+
shift
goto continue
:end

set command=Automation RunAll
if "%testSuite%" neq "" ( set command=Automation RunTests %testSuite% )


rem ## Run Test
pushd "C:/projects/ue4/UnrealEngine/Engine/Binaries/Win64"
UE4Editor-Cmd.exe "%ProjDirectory%\MyProject.uproject" -unattended -nopause -NullRHI -ExecCmds="%command%; quit" -TestExit="Automation Test Queue Empty" -log -log=RunTests.log -ReportOutputPath="%ProjDirectory%\TestsReports\reports\ue4"
echo %ProjDirectory%\MyProject.uproject
echo error level output: %ERRORLEVEL%
REM if not %ERRORLEVEL% == 0 goto Exit_Failure
popd

rem ## Success!
rem ## Clean test environment

pushd TestsReports
rem ## srmdir test
echo Clean and reinstall server to display tests results (npm)
for /f %%i in ('npm run server:id') do set serverId=%%i
if "%serverId%" neq "[]" ( call npm run server:clean )
call npm install
call bower install
popd

goto Create_Report

:Exit_Failure
echo %ESC%[91mTests exit with error%ESC%[0m
exit /b %ERRORLEVEL%

:Create_Report
echo Create reports
pushd TestsReports
call npm run test:ue4
call npm run server:start
echo Your should open http://localhost:9999 to see tests results
REM echo Your default brower should open http://localhost:9999/test to see tests results
REM start "" http://localhost:9999/test
popd

rem ## Restore original CWD in case we change it
popd
exit /B %ERRORLEVEL%

