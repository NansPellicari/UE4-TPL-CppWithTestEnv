# UE4 template for c++ project with test environment

Launch your tests and code coverage with just **1** commandline and get nice reports!

> /!\ For now it works only on Window

![Dashboard](./Docs/dashboard.png)

## Why?

My first needs were:

-   improve my process of **proof concepting**
-   try to reduce the **UE4 build** duration
-   ensure quality to avoid regressions by **running tests frequently**

Then after reading this great serie of articles, testing and guiding by its author @[ericlemes](https://github.com/ericlemes):

-   https://ericlemes.com/2018/12/12/unit-tests-in-unreal-pt-1/
-   https://ericlemes.com/2018/12/13/unit-tests-in-unreal-pt-2/
-   https://ericlemes.com/2018/12/17/unit-tests-in-unreal-pt-3/

this project came to life!

## Requirements

-   [PowerShell](https://docs.microsoft.com/en-us/powershell/)
-   [Unreal Engine](https://github.com/EpicGames/UnrealEngine)
-   [UE4-GoogleTest](https://github.com/NansPellicari/UE4-GoogleTest) (but it is embeded as a gitmodule)
-   [OpenCppCoverage](https://github.com/OpenCppCoverage/OpenCppCoverage/wiki)
-   [NodeJs](https://nodejs.org/en/download/)
-   [Pm2](https://pm2.keymetrics.io/)

## 1 - Clone to a specific dir

```powershell
git clone git@github.com:NansPellicari/UE4-TPL-CppWithTestEnv.git MyNewGame
# renaming destination folder is important, 'cause UE4 doesn't like dash in project name
cd MyNewGame
```

## 2 - Rename the project files

```powershell
.\ChangeProjectName.bat 'MyNewGame'
# and respond "y" in every prompt
# or
.\ChangeProjectName.bat -f 'MyNewGame'
# to avoid prompts
# or
.\ChangeProjectName.bat -f 'MyPreviousGameName' 'MyNewGame'
# if you've already change the name but you decide to change again
```

This will:

-   cleans all unecessary files and folders (if exists: Binaries, Saved,...)
-   prompts you to set the **UE4 root path**
-   renames all `MyProject` files & folders
-   changes all `MyProject` occurences in `./Source/`, `./Config/` and `./TestsReports/` directories.
-   generate Project Files (for VS or VScode)

## 3 - Get submodules

This repo embeds [UE4-GoogleTest](https://github.com/NansPellicari/UE4-GoogleTest) plugins which is a **UE4 plugin**, a simple adapter for the [googletest](https://github.com/google/googletest) project.

```powershell
git sumbmodule init
git submodule update --init --recursive
```

## 4 - Test

Run all tests to check if all is well configure.

```powershell
.\RunTests.bat -b gg
.\RunTests.bat -b ue4 MyNewGame
# last parameter is recommended for this one (see section 4a),
# otherwise it launches every UE4 tests
```

> Each run will **builds** using the UE4 builder. `gg`: a **program** build, `ue4`: an **editor** build.  
> It means that the first time they are launch, they'll take time to build.  
> But on next runs you'll see how fast they are, it is such a pleasure :relaxed:  
> Special winner is the `gg` build :heart_eyes:

For the both builds (`ue4` or `gg`), you can filter **tests** to run.

### 4a - Filter for UE4 build

For this build is really important to filter, otherwise it will run all Unreal Engine's tests, which is A LOT!  
You can add any filters you need as if:

```powershell
.\RunTests.bat -b ue4 MyNewGame MyPlugin.Core
```

> this will call `UE4Editor-Cmd.exe` with this parameter `-ExecCmds="Automation RunTests MyNewGame+MyPlugin.Core; quit"`

### 4b - Filters for GG build

Use params as [google test](https://github.com/google/googletest/blob/master/googletest/docs/advanced.md#selecting-tests) defined.

```powershell
.\RunTests.bat -c -b gg --gtest_filter=FirstTest.*-FirstTest.ShouldTestFalse
```

> to list test names: `.\RunTests.bat -b gg --gtest_list_tests`

## 5 - Coverage

Just add `-c` option:

```powershell
.\RunTests.bat -c -b gg
.\RunTests.bat -c -b ue4 MyNewGame
```

## 6 - Reinstall git + git modules on your new git repository

```powershell
rd .\git\
rd .\Plugins\GoogleTest
git init
git submodule add git@github.com:NansPellicari/UE4-GoogleTest.git Plugins/GoogleTest
git add .
git ci -m "Initial my UE4 project with GoogleTest + OpenCppCoverage"
git remote add origin git@github.com:MY_USER/MY_REPO.git
git push origin master
```

or my preferred choice, just change the remote repository (thanks to [this](https://gist.github.com/DianaEromosele/fa228f6f6099a8996d3cb891109ab975) gist):

```powershell
git remote rm origin
git remote add origin git@github.com:MY_USER/MY_REPO.git
git config master.remote origin
git config master.merge refs/heads/master
```

## 7 - Debug

### 7a - In VScode

First add a build conf in `.vscode/tasks.json`:

```json
{
	"label": "GoogleApp Win64 Development Build",
	"group": "build",
	"command": "Engine\\Build\\BatchFiles\\Build.bat",
	"args": [
		"GoogleTestApp",
		"Win64",
		"Development",
		"<YourProjectPath>\\GoogleTestApp.uproject",
		"-waitmutex"
	],
	"problemMatcher": "$msCompile",
	"type": "shell",
	"options": {
		"cwd": "<yourUE4Path>"
	}
}
```

and a debug config in your `.vscode/launch.js`:

```json
{
	"version": "0.2.0",
	"configurations": [
		// ...
		{
			"name": "GoogleApp (Development)",
			"request": "launch",
			"preLaunchTask": "GoogleApp Win[64 or 32] Development Build",
			"program": "<YourProjectPath>\\Binaries\\Win[64 or 32]\\GoogleTestApp.exe",
			"args": [],
			"cwd": "<yourUE4Path>",
			"stopAtEntry": false,
			"externalConsole": true,
			"type": "cppvsdbg",
			"visualizerFile": "<yourUE4Path>\\Engine\\Extras\\VisualStudioDebugging\\UE4.natvis"
		},
		{
			"name": "UE4 Light Editor (MyDebug)",
			"request": "launch",
			"preLaunchTask": "<YourProjectName>Editor Win64 Development Build",
			"program": "<yourUE4Path>\\Engine\\Binaries\\Win64\\UE4Editor-Cmd.exe",
			"args": [
				"<YourProjectPath>\\UE4Timeline.uproject",
				"-unattended",
				"-nopause",
				"-NullRHI",
				// Change here test's filter you want to run instead of MyTest
				"-ExecCmds=\"Automation RunTests MyTest; quit\"",
				"-TestExit=\"Automation Test Queue Empty\"",
				"-log",
				"-log=RunTests.log",
				"-ReportOutputPath=\"<YourProjectPath>\\TestsReports\\reports\\ue4\""
			],
			"cwd": "<yourUE4Path>",
			"stopAtEntry": false,
			"externalConsole": true,
			"type": "cppvsdbg",
			"visualizerFile": "<yourUE4Path>\\Engine\\Extras\\VisualStudioDebugging\\UE4.natvis"
		}
	]
}
```

## 8 - Go to your Dashboard

I use [node](https://nodejs.org/en/download/) and [pm2](https://pm2.keymetrics.io/) to create a simple server which display all tests reports and coverages in one **dashboard**.  
Find it at `http://localhost:9999/` to see last results in a glimpse.  
Each block is a link to the more detailed reports page (see section **What does it look like?** below).

![Dashboard](./Docs/dashboard.png)

## 9 - Shutdown server

Don't forget to shutdown server when you don't use it or if you switch to other project.

```bash
cd TestsReports/
npm run server:stop
# or to ensure to kill every server
npm run server:clean
# or
pm2 delete all
```

## What does it look like?

### Google Test App reports

I choose to use [Xunit viewer](https://www.npmjs.com/package/xunit-viewer) 'cause (at the age of this repo creation):

-   it is actively maintain
-   is the most advanced UI on npm

![Xunit viewer](./Docs/dashboard-gg-xunit-viewer.png)

### Google Test App Coverage

![OpenCppCoverage view](./Docs/dashboard-gg-open-cpp-coverage.png)

### UE4 reports

![Junit viewer](./Docs/dashboard-ue4-junit.png)

### UE4 Coverage

![OpenCppCoverage view](./Docs/dashboard-ue4-open-cpp-coverage.png)

[License Apache-2.0](./LICENSE.md)
