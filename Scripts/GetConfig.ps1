param(
    [string] $ConfigName
)

$ConfFile = "Config\Project.ini"
$confexists = Test-Path $ConfFile
if ($confexists -eq 0) {
    Copy-Item "$ConfFile.sample" -Destination $ConfFile
}

$line = Get-Content -Path $ConfFile | Where-Object { $_ -match "$ConfigName=" }
$exists=0
$ConfigValue=0

if ($line -ne $null) {
    $ConfigValue = $line.Split('=')[1]
    
    if ($ConfigName -eq "UE4PATH") {
        $exists = Test-Path $ConfigValue/Engine
    }
}

if ($ConfigName -eq "UE4PATH") {
    if (!$exists)
    {
        Do{
            Write-Warning "Path $ConfigValue is not valid"
            $ConfigValue = Read-Host -Prompt 'Enter UE4 path: '
            $exists = Test-Path $ConfigValue/Engine
        } Until($ConfigValue -ne $null -And $ConfigValue -ne "" -And $exists -ne 0)
    }
    (Get-Content $ConfFile) -replace 'UE4PATH=.*', "UE4PATH=$ConfigValue" | Set-Content $ConfFile
}


Write-Host $ConfigValue