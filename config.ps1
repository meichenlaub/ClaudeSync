# ClaudeSync Configuration
# This file defines paths used by all ClaudeSync scripts

# Google Drive path for messages.json (auto-detected)
$GoogleDrivePaths = @(
    "$env:USERPROFILE\My Drive\ClaudeSync",
    "$env:USERPROFILE\Google Drive\ClaudeSync"
)

$Global:GoogleDriveSyncDir = $null
foreach ($path in $GoogleDrivePaths) {
    if (Test-Path $path) {
        $Global:GoogleDriveSyncDir = $path
        break
    }
}

if (-not $Global:GoogleDriveSyncDir) {
    Write-Error "Could not find ClaudeSync folder in Google Drive. Checked: $($GoogleDrivePaths -join ', ')"
    exit 1
}

# Messages file lives in Google Drive for real-time sync
$Global:MessagesFile = Join-Path $Global:GoogleDriveSyncDir "messages.json"

# Scripts live in GitHub repo
$Global:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Per-computer log files (in GitHub repo, gitignored)
$Global:ComputerName = (hostname.exe).Trim()
$Global:WatcherLogPath = Join-Path $Global:ScriptDir "logs\watcher-$Global:ComputerName.log"
$Global:WatchdogLogPath = Join-Path $Global:ScriptDir "logs\watchdog-$Global:ComputerName.log"

# Ensure logs directory exists
$LogsDir = Join-Path $Global:ScriptDir "logs"
if (-not (Test-Path $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
}
