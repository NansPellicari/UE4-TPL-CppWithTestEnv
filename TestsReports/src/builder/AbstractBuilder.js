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

class AbstractBuilder {
    constructor(globalReportFile, reportsDirectory) {
        if (this.constructor === AbstractBuilder) {
            throw new TypeError(
                'Abstract class "AbstractBuilder" cannot be instantiated directly'
            );
        }

        this.globalReportFile = globalReportFile;
        this.reportsDirectory = reportsDirectory;

        if (!fs.existsSync(this.globalReportFile)) {
            try {
                fs.writeFileSync(this.globalReportFile, "{}");
            } catch (e) {
                throw new Error(`Can not write file ${this.globalReportFile}`);
            }
        }

        this.globalData = require(globalReportFile);

        if (!fs.existsSync(this.reportsDirectory)) {
            throw new Error(`
            directory ${this.reportsDirectory} not found\n
            You should run test before, or your last tests contains errors
            `);
            return;
        }
    }

    async getReportFile() {
        throw new Error("not implemented");
    }

    async build() {
        throw new Error("not implemented");
    }

    writeGlobalData() {
        fs.writeFileSync(
            this.globalReportFile,
            JSON.stringify(this.globalData)
        );
    }
}

module.exports = AbstractBuilder;
