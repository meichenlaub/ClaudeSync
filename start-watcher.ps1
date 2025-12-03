# Start the Claude Code Message Watcher in the background

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WatcherScript = Join-Path $ScriptDir "claude-watcher.ps1"

# Check if already running
$existing = Get-Process -Name powershell -ErrorAction SilentlyContinue |
    Where-Object {
        try { $_.CommandLine -like "*claude-watcher.ps1*" } catch { $false }
    }

if ($existing) {
    Write-Host "Watcher is already running (PID: $($existing.Id))"
    exit 0
}

# Start the watcher in a hidden window
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "powershell.exe"
$psi.Arguments = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$WatcherScript`""
$psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
$psi.CreateNoWindow = $true

$process = [System.Diagnostics.Process]::Start($psi)

# Load config to get log path
. (Join-Path $ScriptDir "config.ps1")

Write-Host "Claude Code Message Watcher started (PID: $($process.Id))"
Write-Host "Logs: $Global:WatcherLogPath"
