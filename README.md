# UE4 template for c++ project with test environment

## Requirements

Install [OpenCppCoverage](https://github.com/OpenCppCoverage/OpenCppCoverage/wiki)

## 1 - Clone to a specific dir

```
git clone git@github.com:NansPellicari/UE4-TPL-CppWithTestEnv.git MyNewGame
cd MyNewGame
```

## 2 - rename the project files

```
.\ChangeProjectName.bat 'MyNewGame'
# and respond "y" in every prompt
# or
.\ChangeProjectName.bat 'MyProject' 'MyNewGame' 1
# to don't have prompts
```

This will:
- rename all `MyProject` files
- change all `MyProject` occurences
- Generate project files

## 2 - get submodules

```
git sumbmodule init
git submodule update --init --recursive
```

# 4 - tests

Run all tests to check all is well configure.

```
.\RunTestsGG.bat
.\RunTestsUE4.bat MyNewGame
```

# 5 - coverage

```
 .\RunCoverage.bat
```

## 6 - Remove .git file or change remote repo
## 7 - Reinstall git modules on your new git repository