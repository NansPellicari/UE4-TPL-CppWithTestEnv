# Contributing Guide
* [Issue Reporting Guidelines](#issue-reporting-guidelines)
* [Pull Request Guidelines](#pull-request-guidelines)
* [Development Setup](#development-setup)

## Issue Reporting Guidelines

* The issue list of this repo is **exclusively** for bug reports and feature requests. Non-conforming issues will be closed immediately.

* Try to search for your issue, it may have already been answered or even fixed in the development branch.

* Check if the issue is reproducible with the latest stable version of [Unreal Engine 4](https://github.com/EpicGames/UnrealEngine). If you are using a pre-release, please indicate the specific version you are using.

* It is **required** that you clearly describe the steps necessary to reproduce the issue you are running into. Issues with no clear repro steps will not be triaged. If an issue labeled "need repro" receives no further input from the issue author for more than 5 days, it will be closed.

* For bugs that involves build setups, you can create a reproduction repository with steps in the README.

* If your issue is resolved but still open, don’t hesitate to close it. In case you found a solution by yourself, it could be helpful to explain how you fixed it.

## Pull Request Guidelines

* The `master` branch is basically just a snapshot of the latest stable release. All development should be done in dedicated branches. **Do not submit PRs against the `master` branch.**

* Checkout a topic branch from the relevant branch, e.g. `develop`, and merge back against that branch.

* It's OK to have multiple small commits as you work on the PR - we will let GitHub automatically squash it before merging.

* Make sure `npm run test` (in `TestsReports` folder) passes.

* If you modify or add `*.bat` files, please use [BatCodeCheck.exe](https://www.robvanderwoude.com/battech_batcodecheck.php) to validate it.
    (but it is in beta and it has some issues, just use it as a guidelines helper)

* If adding new feature:

    -   Add accompanying test case.
    -   Provide convincing reason to add this feature. Ideally you should open a suggestion issue first and have it greenlighted before working on it.

* If fixing a bug:
    -   Provide detailed description of the bug in the PR. Live demo preferred.
    -   Add appropriate test coverage if applicable.

### Work Step Example

* Fork the repository from [NansPellicari/UE4-TPL-CppWithTestEnv](https://github.com/NansPellicari/UE4-TPL-CppWithTestEnv) !
* Create your topic branch from `develop`: `git branch my-new-topic origin/develop`
* Add codes and pass tests !
* Commit your changes: `git commit -am 'Add some topic'`
* Push to the branch: `git push origin my-new-topic`
* Submit a pull request to `develop` branch of `NansPellicari/UE4-TPL-CppWithTestEnv` repository !

## Development Setup

You will need requirements specified in the [README](./README.md#2-requirements).

Follow steps in [README Step by step guide](./README.md#3-step-by-step-guide) to install the project.

To test `*.bat` files I downloaded [BatCodeCheck.exe](https://www.robvanderwoude.com/battech_batcodecheck.php), please use it if you make changes on bat files.

To format `*.md` files and create a automatic and proper TOC, I use VS Code plugins:
* [markdown-formatter](https://marketplace.visualstudio.com/items?itemName=mervin.markdown-formatter)
* [Auto Markdown TOC By AX1](https://marketplace.visualstudio.com/items?itemName=livepdm.auto-markdown-toc-ax1).

### Coding standard

I try to respect the [UE4 coding standard](https://docs.unrealengine.com/en-US/Programming/Development/CodingStandard/index.html). So please read it to give you an idea.

However I consider that developers should be focus on **coding smart things** instead of **obsessively look their code format**, thus I prefer using "robots" (here: **code formatter**) which are really good to make repeatitive and boring tasks :smiley:.

I use [omnisharp.json](./omnisharp.json) **(C#)**, [.clang-format](./.clang-format) **(C++)** and [.prettierrc](./.prettierrc) **(.uplugin/.uproject)** files to help configure code formatter, you should consider using their respective formatter's plugins in your code editor. I give you some tips in [README formatting](./README.md#5-formatting) section.
