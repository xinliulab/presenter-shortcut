$ErrorActionPreference = 'SilentlyContinue'
$stopped = Get-Process -Name 'PresenterHotkey' -ErrorAction SilentlyContinue
$stopped | Stop-Process -Force
if ($stopped) {
    Write-Host 'PresenterHotkey stopped.' -ForegroundColor Green
} else {
    Write-Host 'PresenterHotkey was not running.' -ForegroundColor Yellow
}
