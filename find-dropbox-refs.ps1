# Find any startup items or scheduled tasks referencing old Dropbox ClaudeSync location
Write-Host "=== Startup Folder Shortcuts ===" -ForegroundColor Cyan
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$sh = New-Object -ComObject WScript.Shell

Get-ChildItem $startupPath -Filter "*.lnk" -ErrorAction SilentlyContinue | ForEach-Object {
    $shortcut = $sh.CreateShortcut($_.FullName)
    $target = "$($shortcut.TargetPath) $($shortcut.Arguments)"
    Write-Host "`n$($_.Name):"
    Write-Host "  Target: $($shortcut.TargetPath)"
    Write-Host "  Args: $($shortcut.Arguments)"
    if ($target -like "*Dropbox*ClaudeSync*" -or $target -like "*Dropbox*claudesync*") {
        Write-Host "  *** POINTS TO DROPBOX (should be Google Drive)! ***" -ForegroundColor Red
    } elseif ($target -like "*ClaudeSync*" -or $target -like "*claude-watcher*") {
        Write-Host "  OK: ClaudeSync reference (not Dropbox)" -ForegroundColor Green
    }
}

Write-Host "`n=== Scheduled Tasks with ClaudeSync ===" -ForegroundColor Cyan
Get-ScheduledTask | Where-Object { $_.TaskName -like "*Claude*" -or $_.TaskName -like "*Watcher*" -or $_.TaskName -like "*watchdog*" } | ForEach-Object {
    Write-Host "`nTask: $($_.TaskName)"
    $actions = $_.Actions
    foreach ($action in $actions) {
        Write-Host "  Execute: $($action.Execute)"
        Write-Host "  Arguments: $($action.Arguments)"
        Write-Host "  WorkingDir: $($action.WorkingDirectory)"
        $fullPath = "$($action.Execute) $($action.Arguments) $($action.WorkingDirectory)"
        if ($fullPath -like "*Dropbox*") {
            Write-Host "  *** REFERENCES DROPBOX (should be Google Drive)! ***" -ForegroundColor Red
        }
    }
}

Write-Host "`n=== Registry Run Keys ===" -ForegroundColor Cyan
$runKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)
foreach ($key in $runKeys) {
    if (Test-Path $key) {
        $entries = Get-ItemProperty $key
        $entries.PSObject.Properties | Where-Object { $_.Name -notlike "PS*" } | ForEach-Object {
            if ($_.Value -like "*Claude*" -or $_.Value -like "*watcher*") {
                Write-Host "$key\$($_.Name): $($_.Value)"
                if ($_.Value -like "*Dropbox*") {
                    Write-Host "  *** REFERENCES DROPBOX (should be Google Drive)! ***" -ForegroundColor Red
                }
            }
        }
    }
}
