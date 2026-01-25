# Check conflicted copies for unprocessed messages
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "config.ps1")

$myName = (hostname.exe).Trim()
$conflictFiles = Get-ChildItem $Global:GoogleDriveSyncDir -Filter "*conflicted*"

foreach ($file in $conflictFiles) {
    Write-Host "=== $($file.Name) ===" -ForegroundColor Yellow
    Write-Host "Last modified: $($file.LastWriteTime)"
    try {
        $data = Get-Content $file.FullName -Raw | ConvertFrom-Json
        $recent = $data.messages | Sort-Object timestamp -Descending | Select-Object -First 3
        foreach ($msg in $recent) {
            $processed = if ($msg.processed) { "PROCESSED" } else { "UNPROCESSED" }
            Write-Host "$processed | $($msg.timestamp) | To: $($msg.recipient) | From: $($msg.sender)"
            Write-Host "   $($msg.message.Substring(0, [Math]::Min(100, $msg.message.Length)))..."
        }
    } catch {
        Write-Host "Error reading: $_"
    }
    Write-Host ""
}

Write-Host "=== Main messages.json ===" -ForegroundColor Green
$main = Get-Content $Global:MessagesFile -Raw | ConvertFrom-Json
$recentMain = $main.messages | Sort-Object timestamp -Descending | Select-Object -First 3
foreach ($msg in $recentMain) {
    $processed = if ($msg.processed) { "PROCESSED" } else { "UNPROCESSED" }
    Write-Host "$processed | $($msg.timestamp) | To: $($msg.recipient) | From: $($msg.sender)"
    Write-Host "   $($msg.message.Substring(0, [Math]::Min(100, $msg.message.Length)))..."
}
