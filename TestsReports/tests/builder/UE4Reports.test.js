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

const Builder = require("../../src/builder/UE4Reports.js");
const jmod = require("jest-when");
const fs = require("fs");

jest.mock("fs");
const reportFile = "test/index.json";
let fakeGlobData = {
    createdAt: "2020.05.16-20.18.31",
    tests: 2,
    warnings: 0,
    failed: 0,
    disabled: 0,
    duration: 1.334118127822876
};
jest.mock(
    "test/index.json",
    () => ({
        reportCreatedOn: "2020.05.16-20.18.31",
        succeeded: 2,
        succeededWithWarnings: 0,
        failed: 0,
        notRun: 0,
        totalDuration: 1.334118127822876
    }),
    { virtual: true }
);

const fakeGlobFile = __dirname + "/mocks/my-fake-global-file.json";

beforeEach(() => {
    jmod.resetAllWhenMocks();
    jest.clearAllMocks();
});

it("Should implements getReportFile", async () => {
    fs.existsSync.mockReturnValue(true);

    const builder = new Builder(fakeGlobFile, "test");
    expect(await builder.getReportFile()).toEqual(reportFile);
});

it("Building should write global file with good data", async () => {
    fs.existsSync.mockReturnValue(true);

    const builder = new Builder(fakeGlobFile, "test");
    await builder.build();
    expect(fs.writeFileSync).toHaveBeenCalledWith(
        fakeGlobFile,
        expect.stringMatching(JSON.stringify(fakeGlobData))
    );
});
