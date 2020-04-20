// Copyright 2020-present Nans Pellicari (nans.pellicari@gmail.com).
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const fs = require('fs')
const path = require('path')
const chalk = require('chalk')
const directory = './reports/ue4'
const testsuite = require(directory + '/index.json')
const globalReportFile = './reports/global-reports.json'

if (!fs.existsSync(globalReportFile)) {
    try{
        fs.writeFileSync(globalReportFile, "{}")
    }catch (e){
        console.log(chalk.black.bgRed("Cannot write file ", e))
        return;
    }
}

let globalReport = require(globalReportFile)

globalReport.ue4 = {
    tests: testsuite.succeeded,
    warnings: testsuite.succeededWithWarnings,
    failed: testsuite.failed,
    disabled: testsuite.notRun,
    duration: testsuite.totalDuration,
}
fs.writeFileSync(globalReportFile, JSON.stringify(globalReport));
