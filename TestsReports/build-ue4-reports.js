const fs = require('fs')
const path = require('path')
const chalk = require('chalk')
const directory = './reports/ue4'
const testsuite = require(directory + '/index.json')
const globalReportFile = './reports/global-reports.json'

if (!fs.existsSync(globalReportFile)) {
    try{
        fs.writeFileSync(globalReportFile, "{}");
    }catch (e){
        console.log(chalk.black.bgRed("Cannot write file ", e));
        return;
    }
}

let globalReport = require(globalReportFile)

globalReport.ue4 = {
    succeeded: testsuite.succeeded,
    warnings: testsuite.succeededWithWarnings,
    failed: testsuite.failed,
    notRun: testsuite.notRun,
    duration: testsuite.totalDuration,
}
fs.writeFileSync(globalReportFile, JSON.stringify(globalReport));