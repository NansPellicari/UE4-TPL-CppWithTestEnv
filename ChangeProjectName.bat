@echo off

setlocal
set ConfFile=Config\Project.ini

for /f "delims=" %%a in ('PowerShell.exe -Command "%cd%\Scripts\GetConfig.ps1"') do (
    echo %%a
    set "UE4PATH=%%a"
)

set p1=MyProject
set p2=NewProjectName
set p3=0

if "%~1" neq "" (if "%~2" neq "" (set p1="%~1") else set p2="%~1")
if "%~2" neq "" set p2="%~2"
if "%~3" neq "" set p3="%~3"

echo Clean project dirs
FOR /d /r %%d IN ("Binaries","Build","Intermediate","Saved","TestsReports\node_modules","TestsReports\bower_components","TestsReports\reports\gg\","TestsReports\reports\ue4","TestsReports\coverage") DO @IF EXIST "%%d" rd /s /q "%%d"
FOR %%f IN ("*.sln", "*.code-workspace", "LastCoverageResults.log", "TestsReports\reports\global-reports.json") DO @IF EXIST "%%f" del "%%f"

echo Rename all project files and dir
PowerShell.exe -Command "& '%cd%\Scripts\RenameProject.ps1'" '%p1%' '%p2%' %p3%

rem ## remove quotes
set p2=%p2:"=%
echo Rebuild project "%~dp0%p2%.uproject"
pushd "%UE4PATH%\Engine\Binaries\DotNET\"
UnrealBuildTool.exe -projectfiles -project="%~dp0%p2%.uproject" -game -rocket -progress
popd

:fail
exit /B 3