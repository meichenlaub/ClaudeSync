$shortcutPath = 'C:\Users\markd\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\ClaudeCodeWatcher.lnk'

if (Test-Path $shortcutPath) {
    $sh = New-Object -ComObject WScript.Shell
    $shortcut = $sh.CreateShortcut($shortcutPath)
    Write-Host "Shortcut exists at: $shortcutPath"
    Write-Host "Target: $($shortcut.TargetPath)"
    Write-Host "Arguments: $($shortcut.Arguments)"
    Write-Host "Working Dir: $($shortcut.WorkingDirectory)"

    if ($shortcut.Arguments -like "*Dropbox*") {
        Write-Host "`nWARNING: Shortcut still points to Dropbox!" -ForegroundColor Red
    } elseif ($shortcut.Arguments -like "*github*") {
        Write-Host "`nOK: Shortcut points to GitHub location" -ForegroundColor Green
    }
} else {
    Write-Host "Shortcut does not exist at: $shortcutPath" -ForegroundColor Yellow

    # Check for other startup items
    Write-Host "`nOther startup items:"
    Get-ChildItem 'C:\Users\markd\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup' | ForEach-Object {
        Write-Host "  $($_.Name)"
    }
}
