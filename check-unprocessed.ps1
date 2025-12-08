$messages = Get-Content 'C:\Users\markd\Dropbox\ClaudeSync\messages.json' -Raw | ConvertFrom-Json
$myName = hostname.exe
$unprocessed = $messages.messages | Where-Object { $_.recipient -eq $myName -and $_.processed -ne $true }
Write-Host "Unprocessed messages for $myName :"
$unprocessed | ForEach-Object {
    Write-Host "---"
    Write-Host "ID: $($_.id)"
    Write-Host "From: $($_.sender)"
    Write-Host "Time: $($_.timestamp)"
    Write-Host "Message: $($_.message.Substring(0, [Math]::Min(200, $_.message.Length)))..."
}
if (-not $unprocessed) { Write-Host "(none)" }
