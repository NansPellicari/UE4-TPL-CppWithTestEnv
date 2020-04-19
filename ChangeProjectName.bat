@echo off

setlocal
set ConfFile=Config\Project.ini

for /f "delims=" %%a in ('PowerShell.exe -Command "%cd%\Scripts\GetConfig.ps1 'UE4PATH'"') do (
    echo %%a
    set "UE4PATH=%%a"
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
            set p1=%p2%
            set p2=%1
        )
    )
)

echo Clean project dirs
FOR /d /r %%d IN ("Binaries","Build","Intermediate","Saved","TestsReports\node_modules","TestsReports\bower_components","TestsReports\reports\gg\","TestsReports\reports\ue4","TestsReports\coverage") DO @IF EXIST "%%d" rd /s /q "%%d"
FOR %%f IN ("*.sln", "*.code-workspace", "LastCoverageResults.log", "TestsReports\reports\global-reports.json") DO @IF EXIST "%%f" del "%%f"

echo Rename all project files and dir
PowerShell.exe -Command "& '%cd%\Scripts\RenameProject.ps1'" '%p1%' '%p2%' %p3%

rem ## remove quotes
set p2=%p2:"=%
set projectPath="%~dp0%p2%.uproject"
echo Rebuild project "%projectPath%"
pushd "%UE4PATH%\Engine\Binaries\DotNET\"
UnrealBuildTool.exe -projectfiles -project="%projectPath%" -game -rocket -progress
popd

:fail
exit /B 3