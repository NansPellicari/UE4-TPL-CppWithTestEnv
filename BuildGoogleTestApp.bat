@echo off

setlocal 
echo Build GoogleTestApp

set ProjDirectory=%cd%
rem ## to get the ESC caracter, used to colorized output
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"


rem ## Retrieve parameters
:continue
if "%1"=="" goto end
set UEDir=%UEDir%%1
shift
goto continue
:end

if "%UEDir%" == "" (
    echo %ESC%[91mYou have to set the Engine directory as first parameter%ESC%[0m
    set ERRORLEVEL=2
    goto Exit_Failure
)


if not exist "%UEDir%" (
    echo %ESC%[91mDirectory %UEDir% does not exists%ESC%[0m
    set ERRORLEVEL=2
    goto Exit_Failure
)

if not exist "%UEDir%\Engine\Build\BatchFiles\Build.bat" (
    echo %ESC%[91mWrong path "%UEDir%" given for the engine directory, can't find the "Engine\Build\BatchFiles\Build.bat" file%ESC%[0m 
    set ERRORLEVEL=2
    goto Exit_Failure
)

rem ## Get the OS version
rem ## thanks to https://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32 || set OS=64

rem ## Run build
echo  %ESC%[32mLaunch command %UEDir%\Engine\Build\BatchFiles\Build.bat GoogleTestApp Win%OS% Development "%ProjDirectory%\GoogleTestApp.uproject" -waitmutex%ESC%[0m
call %UEDir%\Engine\Build\BatchFiles\Build.bat GoogleTestApp Win%OS% Development "%ProjDirectory%\GoogleTestApp.uproject" -waitmutex
echo error level output: %ERRORLEVEL%
if not %ERRORLEVEL% == 0 goto Exit_Failure
rem ## Run tests
call RunTestsGG.bat

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
