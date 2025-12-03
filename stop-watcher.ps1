# Stop the Claude Code Message Watcher

$watcherProcesses = Get-Process -Name powershell -ErrorAction SilentlyContinue |
    Where-Object {
        try {
            $_.CommandLine -like "*claude-watcher.ps1*"
        } catch {
            $false
        }
    }

if (-not $watcherProcesses) {
    Write-Host "No watcher process found running"
    exit 0
}

foreach ($proc in $watcherProcesses) {
    Write-Host "Stopping watcher (PID: $($proc.Id))..."
    Stop-Process -Id $proc.Id -Force
    Write-Host "Watcher stopped"
}
