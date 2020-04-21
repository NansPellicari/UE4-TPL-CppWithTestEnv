
const fs = require('fs')
const globalReportFile = './reports/global-reports.json'

if (!fs.existsSync(globalReportFile)) {
    try{
        fs.writeFileSync(globalReportFile, "{}")
    }catch (e){
        console.log(chalk.black.bgRed("Cannot write file ", e))
        return;
    }
}

module.exports = {
    file: globalReportFile,
    data: require(globalReportFile)
}