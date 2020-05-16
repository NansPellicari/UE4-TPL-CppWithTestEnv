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

const Builder = require("../../src/builder/GGReports.js");
const jmod = require("jest-when");
jest.unmock("fs");
jest.mock("xunit-viewer");

const fs = require("fs");
const xunitViewer = require("xunit-viewer");

const fakeReportsResult = {
    createdAt: "2020-05-17T15:34:50",
    tests: 2,
    failed: 0,
    disabled: 0,
    duration: 0.013
};

const fakeGlobFile = __dirname + "/mocks/my-fake-global-file.json";
const mockReportsDir = __dirname + "/mocks/gg-reports";

beforeEach(() => {
    jmod.resetAllWhenMocks();
    jest.clearAllMocks();
    fs.unlinkSync = jest.fn();
    fs.unlinkSync.mockReturnValue(true);
    fs.writeFileSync = jest.fn();
    fs.writeFileSync.mockReturnValue(true);
});

it("Should retrieve last test file", async () => {
    const builder = new Builder(fakeGlobFile, mockReportsDir);
    expect(await builder.getReportFile()).toEqual(
        mockReportsDir + "/test-20200517-153447.xml"
    );
});

it("Building should write global file with good data", async () => {
    const builder = new Builder(fakeGlobFile, mockReportsDir);
    await builder.build();
    expect(fs.writeFileSync).toHaveBeenCalledWith(
        fakeGlobFile,
        expect.stringMatching(JSON.stringify(fakeReportsResult))
    );
});
