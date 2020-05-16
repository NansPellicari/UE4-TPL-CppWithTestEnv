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
const path = require("path");
const xunitViewer = require("xunit-viewer");
const parser = require("xml2json");
const AbstractBuilder = require("./AbstractBuilder.js");

class GGReports extends AbstractBuilder {
    async getLastFile(files, path) {
        var out = [];
        for (const file of files) {
            var stats = await fs.statSync(path + "/" + file);
            if (stats.isFile()) {
                out.push(file);
            }
        }

        out.sort(function (a, b) {
            let val = b > a ? 1 : 0;
            val = b < a ? -1 : val;
            return val;
        });
        return out.length > 0 ? out[0] : "";
    }

    async getReportFile() {
        const files = fs.readdirSync(this.reportsDirectory);
        const lastFile = await this.getLastFile(files, this.reportsDirectory);
        if (!/^test-/.test(lastFile)) {
            throw new Error(
                " No reports files for now (probably no tests implemented). "
            );
        }

        for (const file of files) {
            // do nothing for the last file
            if (lastFile === file) continue;
            if (file === ".gitkeep") continue;
            // remove file
            await fs.unlinkSync(path.join(this.reportsDirectory, file));
        }

        return this.reportsDirectory + "/" + lastFile;
    }
    async build() {
        const data = fs.readFileSync(await this.getReportFile());
        const reports = JSON.parse(parser.toJson(data));

        this.globalData.gg = {};

        if (reports) {
            let failed = reports.testsuites.failures
                ? parseInt(reports.testsuites.failures)
                : 0;
            failed += reports.testsuites.errors
                ? parseInt(reports.testsuites.errors)
                : 0;

            this.globalData.gg = {
                createdAt: reports.testsuites.timestamp,
                tests: parseInt(reports.testsuites.tests),
                failed: failed,
                disabled: parseInt(reports.testsuites.disabled),
                duration: parseFloat(reports.testsuites.time)
            };

            this.writeGlobalData();
        }

        await xunitViewer({
            server: false,
            results: this.reportsDirectory,
            ignore: ["_thingy", "invalid"],
            title: "GG Tests",
            output: "gg-index.html"
        });
    }
}

module.exports = GGReports;
