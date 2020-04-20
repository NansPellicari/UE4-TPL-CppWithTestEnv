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

const xunitViewer = require('xunit-viewer')
const fs = require('fs')
const path = require('path')
const chalk = require('chalk')
var parser = require('xml2json')
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

const directory = './reports/gg'

// thanks to: https://stackoverflow.com/questions/15696218/get-the-most-recent-file-in-a-directory-node-js
const getLastFile = async (files, path) => {
    var out = [];
    for (const file of files) {
        var stats = await fs.statSync(path + "/" + file)
        if (stats.isFile()) {
            out.push({ "file": file, "mtime": stats.mtime.getTime() })
        }
    }

    out.sort(function (a, b) {
        return b.mtime - a.mtime;
    })
    return (out.length > 0) ? out[0].file : ""
}

const main = async () => {
    try {
        const files = fs.readdirSync(directory);
        const lastFile = await getLastFile(files, directory)
        if (!/^test-/.test(lastFile)) {
            console.log(chalk.black.bgYellow(" No reports files for now (probably no tests implemented). "))
            return
        }
        
        for (const file of files) {
            // do nothing for the last file
            if (lastFile === file) continue;
            if (file === '.gitkeep') continue;
            // remove file
            await fs.unlinkSync(path.join(directory, file))
        }

        const data = fs.readFileSync(directory+'/'+lastFile)
        const reports = JSON.parse(parser.toJson(data));

        globalReport.gg = {};
        if (reports) {
            let failed = reports.testsuites.failures ? parseInt(reports.testsuites.failures): 0
            failed += reports.testsuites.errors ? parseInt(reports.testsuites.errors): 0

            globalReport.gg = {
                tests: parseInt(reports.testsuites.tests),
                failed: failed,
                disabled: parseInt(reports.testsuites.disabled),
                duration: parseFloat(reports.testsuites.time),
            }

        }
        fs.writeFileSync(globalReportFile, JSON.stringify(globalReport));
    } catch (err) {
        console.error(err)
    }

    await xunitViewer({
        server: false,
        results: directory,
        ignore: ['_thingy', 'invalid'],
        title: 'GG Tests',
        output: 'gg-index.html'
    })
}
main()
