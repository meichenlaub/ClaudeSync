# Search for startup-related messages
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "config.ps1")

$data = Get-Content $Global:MessagesFile -Raw | ConvertFrom-Json
$myName = (hostname.exe).Trim()

# Look for messages about startup, shortcut, watcher, path
$keywords = @('startup', 'shortcut', 'watcher', 'Google.*Drive', 'start menu', 'autostart')

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
