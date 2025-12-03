# ClaudeSync Configuration
# This file defines paths used by all ClaudeSync scripts

# Dropbox path for messages.json (auto-detected)
$DropboxPaths = @(
    "$env:USERPROFILE\Dropbox (Personal)\ClaudeSync",
    "$env:USERPROFILE\Dropbox\ClaudeSync",
    "$env:USERPROFILE\Dropbox\claudesync"
)

$Global:DropboxSyncDir = $null
foreach ($path in $DropboxPaths) {
    if (Test-Path $path) {
        $Global:DropboxSyncDir = $path
        break
    }
}

if (-not $Global:DropboxSyncDir) {
    Write-Error "Could not find ClaudeSync folder in Dropbox. Checked: $($DropboxPaths -join ', ')"
    exit 1
}

# Messages file lives in Dropbox for real-time sync
$Global:MessagesFile = Join-Path $Global:DropboxSyncDir "messages.json"

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
