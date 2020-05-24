# UE4 template for c++ project with test environment

Launch your tests and code coverage with just **1** commandline + get nice reports!

> /!\ For now it works only on **Window**

![Dashboard](./Docs/dashboard.png)

|                                                                                                       <a href="https://www.buymeacoffee.com/NansUE4" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-green.png" alt="Buy Me A Coffee" height="51" width="217"></a>                                                                                                        |
| :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| I've decided to make all the code I developped for my games free to use and open source.<br> I am a true believer in the mindset that sharing and collaborating makes the world a better place.<br> The thing is: I'm fulltime dedicated to my project and these open source plugins, for coding I need a looooot of coffee, so please, help me to get my drug :stuck_out_tongue_closed_eyes: !! |

<!-- TOC -->

-   [1. Why?](#1-why)
-   [2. Requirements](#2-requirements)
-   [3. Step by step guide](#3-step-by-step-guide)
    -   [3.1. Clone to a specific dir](#31-clone-to-a-specific-dir)
    -   [3.2. Rename the project files](#32-rename-the-project-files)
    -   [3.3. Get submodules](#33-get-submodules)
    -   [3.4. Test](#34-test)
        -   [3.4.1. Filter for UE4 build](#341-filter-for-ue4-build)
        -   [3.4.2. Filters for GG build](#342-filters-for-gg-build)
    -   [3.5. Coverage](#35-coverage)
    -   [3.6. Go to your Dashboard](#36-go-to-your-dashboard)
    -   [3.7. Reinstall git + git modules on your new git repository](#37-reinstall-git--git-modules-on-your-new-git-repository)
    -   [3.8. Shutdown server](#38-shutdown-server)
-   [4. Debug](#4-debug)
    -   [4.1. In VScode](#41-in-vscode)
    -   [4.2. VS (Visual Studio)](#42-vs-visual-studio)
-   [5. Formatting](#5-formatting)
    -   [5.1. VS Code](#51-vs-code)
    -   [5.2. VS](#52-vs)
-   [6. Other scripts](#6-other-scripts)
-   [7. What does it look like?](#7-what-does-it-look-like)
    -   [7.1. Google Test App reports](#71-google-test-app-reports)
    -   [7.2. Google Test App Coverage](#72-google-test-app-coverage)
    -   [7.3. UE4 reports](#73-ue4-reports)
    -   [7.4. UE4 Coverage](#74-ue4-coverage)
-   [8. Contributing and Supporting](#8-contributing-and-supporting)

<!-- /TOC -->

<a id="markdown-1-why" name="1-why"></a>

## 1. Why?

My first needs were:

-   improve my process of **proof concepting**
-   try to reduce the **UE4 tests build** duration
-   ensure quality to avoid regressions by **running tests frequently**

Then after reading this great serie of articles, testing and guiding by its author @[ericlemes](https://github.com/ericlemes):

-   https://ericlemes.com/2018/12/12/unit-tests-in-unreal-pt-1/
-   https://ericlemes.com/2018/12/13/unit-tests-in-unreal-pt-2/
-   https://ericlemes.com/2018/12/17/unit-tests-in-unreal-pt-3/

this project came to life!

<a id="markdown-2-requirements" name="2-requirements"></a>

## 2. Requirements

-   [PowerShell](https://docs.microsoft.com/en-us/powershell/)
-   [Unreal Engine](https://github.com/EpicGames/UnrealEngine)
-   [UE4-GoogleTest](https://github.com/NansPellicari/UE4-GoogleTest) (but it is embeded as a gitmodule)
-   [OpenCppCoverage](https://github.com/OpenCppCoverage/OpenCppCoverage/wiki)
-   [NodeJs](https://nodejs.org/en/download/)
-   [Pm2](https://pm2.keymetrics.io/)
-   [jq](https://stedolan.github.io/jq/download/) (for vscode: use to merge json config files, see [GenerateProjectFiles.bat](./GenerateProjectFiles.bat))

<a id="markdown-3-step-by-step-guide" name="3-step-by-step-guide"></a>

## 3. Step by step guide

<a id="markdown-31-clone-to-a-specific-dir" name="31-clone-to-a-specific-dir"></a>

### 3.1. Clone to a specific dir

```powershell
git clone git@github.com:NansPellicari/UE4-TPL-CppWithTestEnv.git MyNewGame
# /!\ renaming destination folder is important, 'cause UE4 doesn't like dash in project name
cd MyNewGame
```

<a id="markdown-32-rename-the-project-files" name="32-rename-the-project-files"></a>

### 3.2. Rename the project files

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

<a id="markdown-33-get-submodules" name="33-get-submodules"></a>

### 3.3. Get submodules

This repo embeds [UE4-GoogleTest](https://github.com/NansPellicari/UE4-GoogleTest) plugins which is a **UE4 plugin**, a simple bridge for the [googletest](https://github.com/google/googletest) project.

```powershell
git sumbmodule init
git submodule update --init --recursive
```

<a id="markdown-34-test" name="34-test"></a>

### 3.4. Test

Run all tests to check if all is well configure.

```powershell
.\RunTests.bat -b gg
# this one failed intentionally
.\RunTests.bat -b ue4 MyNewGame
# last parameter is recommended for this one (see section 3.4.1.),
# otherwise it launches every UE4 tests
```

> Each run will **builds** using the UE4 builder. `gg`: a **program** build, `ue4`: an **editor** build.  
> It means that the first time they are launch, they'll take time to build.  
> But on next runs you'll see how fast they are, it is such a pleasure :relaxed:  
> Special winner is the `gg` build :heart_eyes:

For the both builds (`ue4` or `gg`), you can filter **tests** to run.

<a id="markdown-341-filter-for-ue4-build" name="341-filter-for-ue4-build"></a>

#### 3.4.1. Filter for UE4 build

For this build is really important to filter, otherwise it will run all Unreal Engine's tests, which is A LOT!  
You can add any filters you need as if:

```powershell
.\RunTests.bat -b ue4 MyNewGame MyPlugin.Core
```

> this will call `UE4Editor-Cmd.exe` with this parameter `-ExecCmds=" mation RunTests MyNewGame+MyPlugin.Core; quit"`

<a id="markdown-342-filters-for-gg-build" name="342-filters-for-gg-build"></a>

#### 3.4.2. Filters for GG build

Use params as [google test](https://github.com/google/googletest/blob/master/googletest/docs/advanced.md#selecting-tests) defined.

```powershell
.\RunTests.bat -c -b gg --gtest_filter=FirstTest.*-FirstTest.ShouldTestFalse
```

> to list test names: `.\RunTests.bat -b gg --gtest_list_tests`

<a id="markdown-35-coverage" name="35-coverage"></a>

### 3.5. Coverage

Just add `-c` option:

```powershell
.\RunTests.bat -c -b gg
.\RunTests.bat -c -b ue4 MyNewGame
```

<a id="markdown-36-go-to-your-dashboard" name="36-go-to-your-dashboard"></a>

### 3.6. Go to your Dashboard

I use [node](https://nodejs.org/en/download/) and [pm2](https://pm2.keymetrics.io/) to create a simple server which display all tests reports and coverages in one **dashboard**.  
Find it at `http://localhost:9999/` to see last results in a glimpse.  
Each block is a link to the more detailed reports page (see section **What does it look like?** below).

![Dashboard](./Docs/dashboard.png)

<a id="markdown-37-reinstall-git--git-modules-on-your-new-git-repository" name="37-reinstall-git--git-modules-on-your-new-git-repository"></a>

### 3.7. Reinstall git + git modules on your new git repository

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

<a id="markdown-38-shutdown-server" name="38-shutdown-server"></a>

### 3.8. Shutdown server

Don't forget to shutdown server when you don't use it or if you switch to other project.

```bash
cd TestsReports/
npm run server:stop
# or to ensure to kill every server
npm run server:clean
# or
pm2 delete all
```

<a id="markdown-4-debug" name="4-debug"></a>

## 4. Debug

<a id="markdown-41-in-vscode" name="41-in-vscode"></a>

### 4.1. In VScode

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

and debug configs in your `.vscode/launch.js`:

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
				"-ExecCmds=\"
mation RunTests MyTest; quit\"",
				"-TestExit=\"
mation Test Queue Empty\"",
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

<a id="markdown-42-vs-visual-studio" name="42-vs-visual-studio"></a>

### 4.2. VS (Visual Studio)

WIP

<a id="markdown-5-formatting" name="5-formatting"></a>

## 5. Formatting

<a id="markdown-51-vs-code" name="51-vs-code"></a>

### 5.1. VS Code

To format on save and during edition, add this in your `.vscode/settings.json`:

```json
{
	"editor.formatOnSave": true,
	"editor.formatOnType": true
}
```

To make the formatter (I use [prettier](https://github.com/prettier/prettier-vscode)) recognize the json format for `.uproject` and `.plugin` files (but It should be placed on the **user** or **workspace** `settings.json`, see [this](https://github.com/prettier/prettier-vscode/issues/606#issuecomment-578085675)):

```json
{
	"files.associations": {
		"_.uproject": "json",
		"_.uplugin": "json"
	}
}
```

<a id="markdown-52-vs" name="52-vs"></a>

### 5.2. VS

WIP

<a id="markdown-6-other-scripts" name="6-other-scripts"></a>

## 6. Other scripts

A bunch of scripts can be used to helps you during your development session:

| Script                       | Usage                                                                                                                                                                                                                  |
| :--------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `.\GeneratePlugins.bat`      | Copies files from the c++ Blank Project template in the Unreal Engine directory and rename it                                                                                                                          |
| `.\Clean.bat`                | Removes all generated files and folder                                                                                                                                                                                 |
| `.\GenerateProjectFiles.bat` | Uses `<ue4 rootpath>Engine\Binaries\DotNET\UnrealBuildTool.exe` to generate VS or VSCode files from the .uproject file + download npm dependencies in the TestsReports folder + clean and start nodejs report's server |

<a id="markdown-7-what-does-it-look-like" name="7-what-does-it-look-like"></a>

## 7. What does it look like?

<a id="markdown-71-google-test-app-reports" name="71-google-test-app-reports"></a>

### 7.1. Google Test App reports

I choose to use [Xunit viewer](https://www.npmjs.com/package/xunit-viewer) 'cause (at the age of this repo creation):

-   it is actively maintain
-   is the most advanced UI on npm

![Xunit viewer](./Docs/dashboard-gg-xunit-viewer.png)

<a id="markdown-72-google-test-app-coverage" name="72-google-test-app-coverage"></a>

### 7.2. Google Test App Coverage

![OpenCppCoverage view](./Docs/dashboard-gg-open-cpp-coverage.png)

<a id="markdown-73-ue4-reports" name="73-ue4-reports"></a>

### 7.3. UE4 reports

![Junit viewer](./Docs/dashboard-ue4-junit.png)

<a id="markdown-74-ue4-coverage" name="74-ue4-coverage"></a>

### 7.4. UE4 Coverage

![OpenCppCoverage view](./Docs/dashboard-ue4-open-cpp-coverage.png)

[License Apache-2.0](./LICENSE.md)

<a id="markdown-8-contributing-and-supporting" name="8-contributing-and-supporting"></a>

## 8. Contributing and Supporting

I've decided to make all the code I developped for my games free to use and open source.  
I am a true believer in the mindset that sharing and collaborating makes the world a better place.  
I'll be very glad if you decided to help me to follow my dream.

| How?                                                                                                                                                                            |                                                                                         With                                                                                         |
| :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| **Donating**<br> Cause I'm an independant developper/creator and for now I don't have<br> any income, I need money to support my daily needs (coffeeeeee).                      | <a href="https://www.buymeacoffee.com/NansUE4" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-green.png" alt="Buy Me A Coffee" height="51" width="217" ></a> |
| **Contributing**<br> You are very welcome if you want to contribute. I explain [here](./CONTRIBUTING.md) in details what<br> is the most comfortable way to me you can contribute. |                                                                         [CONTRIBUTING.md](./CONTRIBUTING.md)                                                                         |
