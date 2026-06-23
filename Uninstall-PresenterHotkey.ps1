[CmdletBinding()]
param(
    # Also delete the compiled exe, config and log from the build folder.
    [switch]$DeleteFiles
)

$ErrorActionPreference = 'SilentlyContinue'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$build = Join-Path $root 'build'

# 1. Stop the running process.
Get-Process -Name 'PresenterHotkey' -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host 'Stopped PresenterHotkey.' -ForegroundColor Green

# 2. Remove the auto-start-at-login shortcut, if present.
$lnk = Join-Path ([Environment]::GetFolderPath('Startup')) 'PresenterHotkey.lnk'
if (Test-Path -LiteralPath $lnk) {
    Remove-Item -LiteralPath $lnk -Force
    Write-Host "Removed auto-start shortcut: $lnk" -ForegroundColor Green
} else {
    Write-Host 'No auto-start shortcut found.' -ForegroundColor Yellow
}

# 3. Optionally delete the build artifacts.
if ($DeleteFiles) {
    foreach ($f in @('PresenterHotkey.exe', 'presenter-hotkey.json', 'PresenterHotkey.log')) {
        $p = Join-Path $build $f
        if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Force; Write-Host "Deleted $p" }
    }
}

Write-Host 'PresenterHotkey uninstalled.' -ForegroundColor Cyan
