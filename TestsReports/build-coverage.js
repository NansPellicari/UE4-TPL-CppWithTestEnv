const fs = require('fs')
const path = require('path')
const chalk = require('chalk')
var parser = require('xml2json')
const directory = './coverage/'
const globalReportFile = './reports/global-reports.json'

if (!fs.existsSync(globalReportFile)) {
    try{
        fs.writeFileSync(globalReportFile, "{}")
    }catch (e){
        console.log(chalk.black.bgRed("Cannot write file ", e))
        return;
    }
}

const coverageApp = ['ue4', 'gg'];
let globalReport = require(globalReportFile)
globalReport.coverage = {}
for (app of coverageApp) {
    const data = fs.readFileSync(`${directory}/${app}/coverage.xml`)
    const coverage = JSON.parse(parser.toJson(data))
    
    globalReport.coverage[app] = {
        total: parseInt(coverage.coverage['lines-valid']),
        valid: parseInt(coverage.coverage['lines-covered'])
    }
}

fs.writeFileSync(globalReportFile, JSON.stringify(globalReport))
