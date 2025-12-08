# Search for startup-related messages
$data = Get-Content 'C:\Users\markd\Dropbox\ClaudeSync\messages.json' -Raw | ConvertFrom-Json
$myName = (hostname.exe).Trim()

# Look for messages about startup, shortcut, watcher, dropbox path
$keywords = @('startup', 'shortcut', 'watcher', 'Dropbox.*watcher', 'start menu', 'autostart')

Write-Host "Searching for startup-related messages to $myName..." -ForegroundColor Cyan

$matches = $data.messages | Where-Object {
    $_.recipient -eq $myName
} | Where-Object {
    $found = $false
    foreach ($kw in $keywords) {
        if ($_.message -match $kw) { $found = $true; break }
    }
    $found
} | Sort-Object timestamp -Descending | Select-Object -First 10

foreach ($msg in $matches) {
    $status = if ($msg.processed) { "PROCESSED" } else { "UNPROCESSED" }
    $type = if ($msg.type) { $msg.type } else { "task" }
    Write-Host "`n=== $status ($type) - $($msg.timestamp) ===" -ForegroundColor $(if ($msg.processed) { "Gray" } else { "Green" })
    Write-Host "From: $($msg.sender)"
    Write-Host "Message:"
    Write-Host $msg.message
}
