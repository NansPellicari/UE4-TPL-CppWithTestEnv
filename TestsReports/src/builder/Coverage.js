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

const AbstractBuilder = require("./AbstractBuilder.js");
const parser = require("xml2json");
const fs = require("fs");

class Coverage extends AbstractBuilder {
    async build() {
        const coverageApp = ["ue4", "gg"];
        this.globalData.coverage = {};
        for (let app of coverageApp) {
            if (!fs.existsSync(`${this.reportsDirectory}/${app}/coverage.xml`))
                continue;

            const data = fs.readFileSync(
                `${this.reportsDirectory}/${app}/coverage.xml`
            );
            const coverage = JSON.parse(parser.toJson(data));

            this.globalData.coverage[app] = {
                total: parseInt(coverage.coverage["lines-valid"]),
                valid: parseInt(coverage.coverage["lines-covered"])
            };

            if (this.globalData[app].createdAt) {
                this.globalData.coverage[app].createdAt = this.globalData[
                    app
                ].createdAt;
            }
        }
        this.writeGlobalData();
    }
}

module.exports = Coverage;
