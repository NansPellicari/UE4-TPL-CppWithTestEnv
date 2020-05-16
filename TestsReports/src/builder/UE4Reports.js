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

class UE4Reports extends AbstractBuilder {
    async getReportFile() {
        return this.reportsDirectory + "/index.json";
    }
    async build() {
        const testsuite = require(await this.getReportFile());

        this.globalData.ue4 = {
            createdAt: testsuite.reportCreatedOn,
            tests: testsuite.succeeded,
            warnings: testsuite.succeededWithWarnings,
            failed: testsuite.failed,
            disabled: testsuite.notRun,
            duration: testsuite.totalDuration
        };

        this.writeGlobalData();
    }
}

module.exports = UE4Reports;
