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

const chalk = require("chalk");
const app = process.env.APP || "gg";

params = {
    gg: {
        classfile: "./src/builder/GGReports",
        reportDir: __dirname + "/reports/gg"
    },
    ue4: {
        classfile: "./src/builder/UE4Reports",
        reportDir: __dirname + "/reports/ue4"
    },
    cov: {
        classfile: "./src/builder/Coverage",
        reportDir: __dirname + "/coverage/"
    }
};

let BuilderClass = require(params[app].classfile);

try {
    const builder = new BuilderClass(
        __dirname + "/reports/global-reports.json",
        params[app].reportDir
    );

    builder.build();
} catch (e) {
    console.log(chalk.black.bgRed(e));
}
