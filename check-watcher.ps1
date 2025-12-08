Get-CimInstance Win32_Process | Where-Object { $_.Name -match 'pwsh|powershell' } | ForEach-Object {
    [PSCustomObject]@{
        PID = $_.ProcessId
        Name = $_.Name
        CommandLine = $_.CommandLine
    }
} | Format-Table -Wrap -AutoSize
