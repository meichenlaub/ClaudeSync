# Watchdog script - Ensures the Claude Code watcher is always running
# This script is run every 5 minutes by Windows Task Scheduler

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load config for log path
. (Join-Path $ScriptDir "config.ps1")
$LogPath = $Global:WatchdogLogPath

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Add-Content -Path $LogPath
}

# Check if watcher is running (use CimInstance to access CommandLine)
$watcherRunning = Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*claude-watcher.ps1*" }

if ($watcherRunning) {
    # Only log occasionally to avoid huge log files
    $lastLogCheck = Join-Path $ScriptDir "logs\.last-watchdog-log-$Global:ComputerName"
    $shouldLog = $true
    if (Test-Path $lastLogCheck) {
        $lastLog = Get-Item $lastLogCheck
        if (((Get-Date) - $lastLog.LastWriteTime).TotalMinutes -lt 60) {
            $shouldLog = $false
        }
    }
    if ($shouldLog) {
        Write-Log "Watcher is running (PID: $($watcherRunning.Id))"
        Set-Content -Path $lastLogCheck -Value (Get-Date -Format "o")
    }
    exit 0
}

# Watcher is not running - start it
Write-Log "Watcher not running - starting it now"

$StartWatcherScript = Join-Path $ScriptDir "start-watcher.ps1"
try {
    & $StartWatcherScript
    Write-Log "Watcher started successfully"
}
catch {
    Write-Log "ERROR starting watcher: $_"
    exit 1
}
