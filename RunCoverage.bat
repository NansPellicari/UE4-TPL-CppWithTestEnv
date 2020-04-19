@echo off

setlocal

rem ## to get the ESC caracter, used to colorized output
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set ProjDirectory=%cd%

OpenCppCoverage --sources=%ProjDirectory% --excluded_sources=%ProjDirectory%\Plugins\GoogleTest  --export_type=html:%ProjDirectory%\TestsReports\coverage\gg --export_type=cobertura:%ProjDirectory%\TestsReports\coverage\gg\coverage.xml  -- %ProjDirectory%\Binaries\Win64\GoogleTestApp.exe

for /f "delims=" %%a in ('PowerShell.exe -Command "%ProjDirectory%\Scripts\GetConfig.ps1 'UE4PATH'"') do (
    echo %%a
    set "UE4PATH=%%a"
)
for /f "delims=" %%a in ('PowerShell.exe -Command "%cd%\Scripts\GetConfig.ps1 'PROJECT'"') do (
    echo %%a
    set "PROJECT=%%a"
)

pushd "%UE4PATH%/Engine/Binaries/Win64"
OpenCppCoverage --sources=%ProjDirectory% --excluded_sources=%ProjDirectory%\Plugins\GoogleTest  --export_type=html:%ProjDirectory%\TestsReports\coverage\ue4 --export_type=cobertura:%ProjDirectory%\TestsReports\coverage\ue4\coverage.xml  -- .\UE4Editor-Cmd.exe "%ProjDirectory%\%PROJECT%.uproject" -unattended -nopause -NullRHI -ExecCmds="Automation RunTests UE4Timeline; quit" -TestExit="Automation Test Queue Empty" -log -log=%ProjDirectory%\RunTests.log -ReportOutputPath="%ProjDirectory%\TestsReports\reports\ue4"
popd

pushd "TestsReports/"
for /f %%i in ('npm run server:id') do set serverId=%%i
if "%serverId%"=="[]" ( 
    rem ## Clean and reinstall server to display tests results (npm)
    call npm install
    call npm run server:start
)
call npm run test:coverage
echo Your should open %ESC%[92mhttp://localhost:9999%ESC%[0m to see tests results
popd

