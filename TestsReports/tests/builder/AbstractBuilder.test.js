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

const AbstractBuilder = require("../../src/builder/AbstractBuilder.js");
const jmod = require("jest-when");
const fs = require("fs");

jest.mock("fs");

const fakeGlobFile = __dirname + "/mocks/my-fake-global-file.json";

class FakeBuilder extends AbstractBuilder {}

beforeEach(() => {
    jmod.resetAllWhenMocks();
    jest.clearAllMocks();
});

it("Should not be directly instanciable", () => {
    expect(() => new AbstractBuilder()).toThrow(TypeError);
});

it("Should throw an error if it can't creates global report file", () => {
    fs.existsSync.mockReturnValue(false);
    fs.writeFileSync.mockImplementation(() => {
        throw new Error();
    });

    expect(() => new FakeBuilder(fakeGlobFile, "test")).toThrow();
});

it("Should create global report file if not exists", () => {
    fs.existsSync.mockReturnValue(false);
    jmod.when(fs.existsSync).calledWith("test").mockReturnValue(true);
    fs.writeFileSync.mockReturnValue(true);

    new FakeBuilder(fakeGlobFile, "test");
    expect(fs.writeFileSync).toHaveBeenCalledWith(fakeGlobFile, "{}");
    expect(fs.existsSync.mock.calls.length).toEqual(2);
});

it("Should throw an error if report's directory does not exists", () => {
    fs.existsSync.mockReturnValue(false);
    jmod.when(fs.existsSync).calledWith(fakeGlobFile).mockReturnValue(true);

    expect(() => new FakeBuilder(fakeGlobFile, "test")).toThrow();
    expect(fs.writeFileSync).not.toHaveBeenCalled();
});

it("Should throw an error if derived class not implements virtual functions", async () => {
    fs.existsSync.mockReturnValue(true);

    const builder = new FakeBuilder(fakeGlobFile, "test");
    await expect(builder.getReportFile()).rejects.toThrow("not implemented");
    await expect(builder.build()).rejects.toThrow("not implemented");
});

it("Should write global data", () => {
    fs.existsSync.mockReturnValue(true);

    const builder = new FakeBuilder(fakeGlobFile, "test");
    builder.writeGlobalData();
    expect(fs.writeFileSync).toHaveBeenCalledWith(fakeGlobFile, '{"test":0}');
});
