# Mark all unprocessed response messages as processed
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "config.ps1")

$myName = (hostname.exe).Trim()
$data = Get-Content $Global:MessagesFile -Raw | ConvertFrom-Json

$responses = $data.messages | Where-Object {
    $_.recipient -eq $myName -and
    (-not $_.processed) -and
    $_.type -eq "response"
}

if ($responses.Count -eq 0) {
    Write-Host "No unprocessed responses to mark"
    exit 0
}

Write-Host "Found $($responses.Count) unprocessed response(s) to mark as processed:"
foreach ($resp in $responses) {
    Write-Host "  - From: $($resp.sender) | $($resp.message.Substring(0, [Math]::Min(60, $resp.message.Length)))..."
    $resp.processed = $true
    $resp | Add-Member -NotePropertyName "processed_at" -NotePropertyValue (Get-Date -Format "o") -Force
    $resp | Add-Member -NotePropertyName "processed_by" -NotePropertyValue $myName -Force
}

$data | ConvertTo-Json -Depth 10 | Set-Content $Global:MessagesFile
Write-Host "Done - marked $($responses.Count) response(s) as processed"
