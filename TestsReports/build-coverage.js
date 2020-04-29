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

const fs = require("fs");
const chalk = require("chalk");
const parser = require("xml2json");
const directory = "./coverage/";
const globalReportFile = "./reports/global-reports.json";

if (!fs.existsSync(globalReportFile)) {
	try {
		fs.writeFileSync(globalReportFile, "{}");
	} catch (e) {
		console.log(chalk.black.bgRed("Cannot write file ", e));
		return;
	}
}

const coverageApp = ["ue4", "gg"];
let globalReport = require(globalReportFile);
globalReport.coverage = {};
for (app of coverageApp) {
	if (!fs.existsSync(`${directory}/${app}/coverage.xml`)) continue;

	const data = fs.readFileSync(`${directory}/${app}/coverage.xml`);
	const coverage = JSON.parse(parser.toJson(data));

	globalReport.coverage[app] = {
		total: parseInt(coverage.coverage["lines-valid"]),
		valid: parseInt(coverage.coverage["lines-covered"])
    };

    if (globalReport[app].createdAt) {
        globalReport.coverage[app].createdAt = globalReport[app].createdAt;
    }
}

fs.writeFileSync(globalReportFile, JSON.stringify(globalReport));
