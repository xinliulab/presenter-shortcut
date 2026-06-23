[CmdletBinding()]
param(
    # Run a 1-time device discovery build instead (logs the device id of every
    # key you press; sends no shortcuts). Use this if the INPHIC device id ever
    # changes and gestures stop working.
    [switch]$Devices,
    # Also start the tool automatically every time you log in to Windows.
    [switch]$AtLogin
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$build = Join-Path $root 'build'
$source = Join-Path $root 'tools\PresenterHotkey.cs'
$exe = Join-Path $build 'PresenterHotkey.exe'
$config = Join-Path $build 'presenter-hotkey.json'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$referenceRoot = Join-Path ${env:ProgramFiles(x86)} 'Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0'
$uiaClient = Join-Path $referenceRoot 'UIAutomationClient.dll'
$uiaTypes = Join-Path $referenceRoot 'UIAutomationTypes.dll'
$windowsBase = Join-Path $referenceRoot 'WindowsBase.dll'

if (-not (Test-Path -LiteralPath $compiler)) {
    throw "Windows C# compiler not found: $compiler"
}

foreach ($ref in @($uiaClient, $uiaTypes, $windowsBase)) {
    if (-not (Test-Path -LiteralPath $ref)) {
        throw "Required .NET reference not found: $ref"
    }
}

New-Item -ItemType Directory -Path $build -Force | Out-Null

# Default config (only created if missing, so your edits are preserved).
if (-not (Test-Path -LiteralPath $config)) {
@'
{
  "TargetDeviceIdContains": "VID_1EA7&PID_0066",
  "UpVk": "0x26",
  "DownVk": "0x28",
  "UpAction": "Ctrl+Shift+D",
  "CodexUpAction": "Ctrl+Shift+D",
  "DownAction": "Enter",
  "PrismWindowTitleContains": ["prism"],
  "PrismInputNameContains": ["ask anything", "message", "prompt", "ask"],
  "PrismUpAction": "Win+H",
  "PrismDownAction": "Enter",
  "PrismFocusDelayMs": 150,
  "DoublePressMs": 900,
  "ActionCooldownMs": 800,
  "RepeatResetMs": 900
}
'@ | Set-Content -LiteralPath $config -Encoding UTF8
}

# Stop any running instance before recompiling.
Get-Process -Name 'PresenterHotkey' -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300

& $compiler /nologo /target:winexe "/out:$exe" `
    /reference:System.dll `
    /reference:System.Core.dll `
    /reference:System.Drawing.dll `
    /reference:System.Windows.Forms.dll `
    /reference:System.Web.Extensions.dll `
    "/reference:$uiaClient" `
    "/reference:$uiaTypes" `
    "/reference:$windowsBase" `
    $source
if ($LASTEXITCODE -ne 0) {
    throw 'PresenterHotkey compilation failed.'
}

if ($AtLogin) {
    $startup = [Environment]::GetFolderPath('Startup')
    $lnk = Join-Path $startup 'PresenterHotkey.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($lnk)
    $shortcut.TargetPath = $exe
    $shortcut.WorkingDirectory = $build
    $shortcut.WindowStyle = 7
    $shortcut.Description = 'INPHIC presenter -> ChatGPT voice shortcuts'
    $shortcut.Save()
    Write-Host "Auto-start at login enabled: $lnk" -ForegroundColor Green
}

if ($Devices) {
    Start-Process -FilePath $exe -ArgumentList '--devices'
    Write-Host 'Device discovery running. Press the INPHIC buttons, then open the log:' -ForegroundColor Cyan
    Write-Host "  $build\PresenterHotkey.log"
    Write-Host 'Find the device= value for the Up/Down buttons and put its VID_xxxx&PID_xxxx'
    Write-Host "into TargetDeviceIdContains in:`n  $config"
} else {
    Start-Process -FilePath $exe -WindowStyle Hidden
    Write-Host 'PresenterHotkey is running (look for the tray icon).' -ForegroundColor Green
    Write-Host 'Double-press INPHIC Up  => Ctrl+Shift+D toggle in ChatGPT; hold/release Ctrl+Shift+D in Codex' -ForegroundColor Cyan
    Write-Host '                            PRISM tab: focus Ask anything, then Win+H voice typing' -ForegroundColor Cyan
    Write-Host 'Double-press INPHIC Down => Enter (submit)' -ForegroundColor Cyan
    Write-Host 'ArrowUp/ArrowDown are intercepted; single presses are ignored.' -ForegroundColor Yellow
    Write-Host 'To stop: right-click the tray icon -> Exit, or run Stop-PresenterHotkey.ps1' -ForegroundColor Yellow
}
