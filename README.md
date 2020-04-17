# UE4 template for c++ project with test environment

## 1 - rename the project files

```
Get-ChildItem -recurse MyProject* | Rename-Item -NewName { $_.Name -replace 'MyProject','NewProjectName' }

Get-ChildItem -Path "./Source/" -Recurse | ForEach-Object {
    (Get-Content $_.FullName) |
        ForEach-Object { $_ -replace [regex]::Escape("MyProject"), "NewProjectName" } |
        Set-Content $_.FullName
}
Get-ChildItem -Exclude README.md| ForEach-Object {
    (Get-Content $_.FullName) |
        ForEach-Object { $_ -replace [regex]::Escape("MyProject"), "NewProjectName" } |
        Set-Content $_.FullName
}
```

## 2 - Remove .git file or change remote repo