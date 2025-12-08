$data = Get-Content 'C:\Users\markd\Dropbox\ClaudeSync\messages.json' -Raw | ConvertFrom-Json
$myName = (hostname.exe).Trim()
$recent = $data.messages | Sort-Object timestamp -Descending | Select-Object -First 5

foreach ($msg in $recent) {
    Write-Host "=== Message ===" -ForegroundColor Cyan
    Write-Host "ID: $($msg.id)"
    Write-Host "Recipient: '$($msg.recipient)' (matches '$myName': $($msg.recipient -eq $myName))"
    Write-Host "Processed: $($msg.processed) (type: $($msg.processed.GetType().Name))"
    Write-Host "Type field: '$($msg.type)'"
    Write-Host "Timestamp: $($msg.timestamp)"
    Write-Host "Message preview: $($msg.message.Substring(0, [Math]::Min(80, $msg.message.Length)))..."

    # Check watcher filter conditions
    $matchesRecipient = (($msg.recipient -eq $myName) -or ($msg.recipient -ieq $myName))
    $notProcessed = (-not $msg.processed)
    $isTask = ((-not $msg.type) -or ($msg.type -eq "task"))
    $isResponse = ($msg.type -eq "response")

    Write-Host "  → Matches recipient: $matchesRecipient"
    Write-Host "  → Not processed: $notProcessed"
    Write-Host "  → Is task (would launch Claude): $isTask"
    Write-Host "  → Is response (just log): $isResponse"
    Write-Host ""
}
