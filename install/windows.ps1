param(
    [string]$DestDir = "$env:LOCALAPPDATA\Programs\google-api",
    [switch]$AddToPath = $false
)

$null = New-Item -ItemType Directory -Force -Path $DestDir

$script = Join-Path $DestDir "google-api"
$shim   = Join-Path $DestDir "google-api.cmd"

Copy-Item -Path "$PSScriptRoot\..\bin\google-api" -Destination $script -Force

$cmdContent = @'
@echo off
python "%~dp0\google-api" %*
'@

$cmdContent | Out-File -FilePath $shim -Encoding ASCII -Force

if ($AddToPath) {
    $path = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($path -notlike "*$DestDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$path;$DestDir", "User")
        Write-Host "Added $DestDir to user PATH. Restart your terminal."
    }
}

Write-Host "Installed to $DestDir"
Write-Host "Run: google-api --help"
