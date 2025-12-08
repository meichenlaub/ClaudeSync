# Check conflicted copies for unprocessed messages
$myName = (hostname.exe).Trim()
$conflictFiles = Get-ChildItem 'C:\Users\markd\Dropbox\ClaudeSync' -Filter "*conflicted*"

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
$main = Get-Content 'C:\Users\markd\Dropbox\ClaudeSync\messages.json' -Raw | ConvertFrom-Json
$recentMain = $main.messages | Sort-Object timestamp -Descending | Select-Object -First 3
foreach ($msg in $recentMain) {
    $processed = if ($msg.processed) { "PROCESSED" } else { "UNPROCESSED" }
    Write-Host "$processed | $($msg.timestamp) | To: $($msg.recipient) | From: $($msg.sender)"
    Write-Host "   $($msg.message.Substring(0, [Math]::Min(100, $msg.message.Length)))..."
}
