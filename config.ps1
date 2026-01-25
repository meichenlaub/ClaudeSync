# ClaudeSync Configuration
# This file defines paths used by all ClaudeSync scripts

# Sync folder paths (auto-detected) - Google Drive preferred, Dropbox as fallback
$SyncPaths = @(
    "$env:USERPROFILE\My Drive\ClaudeSync",
    "$env:USERPROFILE\Google Drive\ClaudeSync",
    "G:\My Drive\ClaudeSync",
    "$env:USERPROFILE\Dropbox (Personal)\ClaudeSync",
    "$env:USERPROFILE\Dropbox\ClaudeSync",
    "$env:USERPROFILE\Dropbox\claudesync"
)

$Global:SyncDir = $null
foreach ($path in $SyncPaths) {
    if (Test-Path $path) {
        $Global:SyncDir = $path
        break
    }
}

if (-not $Global:SyncDir) {
    Write-Error "Could not find ClaudeSync folder. Checked: $($SyncPaths -join ', ')"
    exit 1
}

# Keep old variable name for compatibility
$Global:DropboxSyncDir = $Global:SyncDir

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
