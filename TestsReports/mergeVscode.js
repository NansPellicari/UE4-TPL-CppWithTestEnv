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

var chalk = require("chalk");
var merge = require("merge-deep");
const fs = require("fs");

if (!fs.existsSync(`${process.argv[2]}`)) {
    console.log(chalk.black.bgRed(`File ${process.argv[2]} doesn't exists`));
    return;
}
if (!fs.existsSync(`${process.argv[3]}`)) {
    console.log(chalk.black.bgRed(`File ${process.argv[3]} doesn't exists`));
    return;
}

const data1 = JSON.parse(fs.readFileSync(process.argv[2]));
const data2 = JSON.parse(fs.readFileSync(process.argv[3]));
const mergedData = merge(data1, data2);

fs.writeFileSync(
    `${process.argv[2]}`,
    JSON.stringify(mergedData, null, "\t")
);
