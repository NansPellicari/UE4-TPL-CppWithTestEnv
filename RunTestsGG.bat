@echo off

set hh=%time:~0,2%
if "%hh:~0,1%" == " " set hh=0%hh:~1,1%
set mm=%time:~3,2%
if "%mm:~0,1%" == " " set mm=0%mm:~1,1%
set ss=%time:~6,2%
if "%ss:~0,1%" == " " set ss=0%ss:~1,1%

echo .\Binaries\Win64\GoogleTestApp.exe --gtest_output=xml:./TestsReports/reports/gg/test-%date:~6,4%%date:~3,2%%date:~0,2%-%hh%%mm%%ss%.xml %*

.\Binaries\Win64\GoogleTestApp.exe --gtest_output=xml:./TestsReports/reports/gg/test-%date:~6,4%%date:~3,2%%date:~0,2%-%hh%%mm%%ss%.xml %*

pushd "TestsReports/"
call npm run test:gg
popd
