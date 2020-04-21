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

setlocal

echo Clean project dirs
FOR /d /r %%d IN ("Binaries","Build","Intermediate","Saved","TestsReports\node_modules","TestsReports\bower_components","TestsReports\reports\gg\","TestsReports\reports\ue4","TestsReports\coverage") DO @IF EXIST "%%d" rd /s /q "%%d"
FOR %%f IN ("*.sln", "*.code-workspace", "LastCoverageResults.log", "TestsReports\reports\global-reports.json") DO @IF EXIST "%%f" del "%%f"
