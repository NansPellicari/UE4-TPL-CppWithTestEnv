@echo off

setlocal
echo Build GoogleTestApp

set ProjDirectory=%cd%
rem ## to get the ESC caracter, used to colorized output
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

for /f "delims=" %%a in ('PowerShell.exe -Command "%cd%\Scripts\GetConfig.ps1 'UE4PATH'"') do (
    echo %%a
    set "UE4PATH=%%a"
)

if "%UE4PATH%" == "" (
    echo %ESC%[91mYou have to set the Engine directory as first parameter%ESC%[0m
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

rem ## Get the OS version
rem ## thanks to https://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32 || set OS=64

rem ## Run build
echo  %ESC%[32mLaunch command %UE4PATH%\Engine\Build\BatchFiles\Build.bat GoogleTestApp Win%OS% Development "%ProjDirectory%\GoogleTestApp.uproject" -waitmutex%ESC%[0m
call %UE4PATH%\Engine\Build\BatchFiles\Build.bat GoogleTestApp Win%OS% Development "%ProjDirectory%\GoogleTestApp.uproject" -waitmutex
echo error level output: %ERRORLEVEL%
if not %ERRORLEVEL% == 0 goto Exit_Failure

rem ## Run tests
set hh=%time:~0,2%
if "%hh:~0,1%" == " " set hh=0%hh:~1,1%
set mm=%time:~3,2%
if "%mm:~0,1%" == " " set mm=0%mm:~1,1%
set ss=%time:~6,2%
if "%ss:~0,1%" == " " set ss=0%ss:~1,1%

echo .\Binaries\Win64\GoogleTestApp.exe --gtest_output=xml:./TestsReports/reports/gg/test-%date:~6,4%%date:~3,2%%date:~0,2%-%hh%%mm%%ss%.xml %*

.\Binaries\Win64\GoogleTestApp.exe --gtest_output=xml:./TestsReports/reports/gg/test-%date:~6,4%%date:~3,2%%date:~0,2%-%hh%%mm%%ss%.xml %*

pushd "TestsReports/"
rem ## srmdir test
for /f %%i in ('npm run server:id') do set serverId=%%i
if "%serverId%"=="[]" ( 
    rem ## Clean and reinstall server to display tests results (npm)
    call npm install
    call npm run server:start
)
call npm run test:gg
echo Your should open %ESC%[92mhttp://localhost:9999%ESC%[0m to see tests results
popd

rem ## Success!
goto Final

:Exit_Failure
echo %ESC%[91mfailed%ESC%[0m 
exit /B %ERRORLEVEL%

:Final
rem ## Restore original CWD in case we change it
popd
echo %ESC%[32mTests build and Run sucessfully%ESC%[0m
exit /B 0
