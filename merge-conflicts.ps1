# Merge conflicted message files
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "config.ps1")

$mainFile = $Global:MessagesFile
$conflictDir = $Global:GoogleDriveSyncDir

# Load main file
$main = Get-Content $mainFile -Raw | ConvertFrom-Json
$mainIds = @{}
foreach ($msg in $main.messages) { $mainIds[$msg.id] = $true }

Write-Host "Main file has $($main.messages.Count) messages"

# Find and merge conflict files
$conflicts = Get-ChildItem $conflictDir -Filter "*conflicted*"
$newMessages = @()

foreach ($file in $conflicts) {
    Write-Host "`nProcessing: $($file.Name)" -ForegroundColor Yellow
    $data = Get-Content $file.FullName -Raw | ConvertFrom-Json

    foreach ($msg in $data.messages) {
        if (-not $mainIds[$msg.id]) {
            Write-Host "  NEW: $($msg.timestamp) | To: $($msg.recipient) | Type: $($msg.type)"
            Write-Host "       $($msg.message.Substring(0, [Math]::Min(80, $msg.message.Length)))..."
            $newMessages += $msg
            $mainIds[$msg.id] = $true
        }
    }
}

if ($newMessages.Count -gt 0) {
    Write-Host "`nAdding $($newMessages.Count) new message(s) to main file..." -ForegroundColor Green
    $main.messages += $newMessages
    $main | ConvertTo-Json -Depth 10 | Set-Content $mainFile
    Write-Host "Merged successfully"
} else {
    Write-Host "`nNo new messages to merge" -ForegroundColor Cyan
}

# Show unprocessed tasks for this computer
$myName = (hostname.exe).Trim()
Write-Host "`n=== Unprocessed TASK messages for $myName ===" -ForegroundColor Magenta
$tasks = $main.messages | Where-Object {
    $_.recipient -eq $myName -and
    (-not $_.processed) -and
    ((-not $_.type) -or ($_.type -eq "task"))
}

if ($tasks) {
    foreach ($t in $tasks) {
        Write-Host "ID: $($t.id)"
        Write-Host "From: $($t.sender) at $($t.timestamp)"
        Write-Host "Message:`n$($t.message)`n"
    }
} else {
    Write-Host "(none found)"
}

# Delete conflict files
Write-Host "`nDeleting conflict files..." -ForegroundColor Yellow
foreach ($file in $conflicts) {
    Remove-Item $file.FullName -Force
    Write-Host "  Deleted: $($file.Name)"
}
