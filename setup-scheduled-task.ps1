# Setup a Windows Scheduled Task to keep the watcher running
# This creates a task that runs every 5 minutes to check if the watcher is alive

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WatchdogScript = Join-Path $ScriptDir "watchdog.ps1"

# Task name
$TaskName = "ClaudeCodeWatcherWatchdog"

# Check if task already exists
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "Scheduled task already exists. Removing it first..."
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Create the VBS wrapper for hidden execution
$vbsPath = Join-Path $ScriptDir "watchdog-runner.vbs"
$vbsContent = "Set objShell = CreateObject(`"WScript.Shell`")`r`nobjShell.Run `"powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"`"$WatchdogScript`"`"`", 0, False"
$vbsContent | Set-Content -Path $vbsPath -Encoding ASCII

$action = New-ScheduledTaskAction `
    -Execute "wscript.exe" `
    -Argument "`"$vbsPath`""

# Create the trigger (every 5 minutes, indefinitely)
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)

# Create settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable:$false `
    -DontStopOnIdleEnd `
    -MultipleInstances IgnoreNew

# Create principal (run as current user when logged on)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

# Register the task
Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Keeps the Claude Code message watcher running by checking every 5 minutes" | Out-Null

Write-Host "Scheduled task created successfully!"
Write-Host "Task name: $TaskName"
Write-Host "Schedule: Every 5 minutes"
Write-Host "Watchdog script: $WatchdogScript"
