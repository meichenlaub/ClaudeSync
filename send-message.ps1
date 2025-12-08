# Send a message to the other computer via Claude Code sync
param(
    [string]$Message,

    [string]$MessageFile,

    [Parameter(Mandatory=$true)]
    [string]$Recipient,

    [string]$Sender = $null,

    [ValidateSet("task", "response")]
    [string]$Type = "task"
)

# Validate: require either -Message or -MessageFile
if (-not $Message -and -not $MessageFile) {
    Write-Error "Either -Message or -MessageFile must be provided"
    exit 1
}

# Read from file if provided
if ($MessageFile) {
    if (-not (Test-Path $MessageFile)) {
        Write-Error "Message file not found: $MessageFile"
        exit 1
    }
    $Message = Get-Content -Path $MessageFile -Raw
}

# Load configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "config.ps1")

if (-not $Sender) {
    $Sender = $Global:ComputerName
}

$SyncFilePath = $Global:MessagesFile

function Get-SyncData {
    $maxRetries = 5
    $retryDelay = 100

    for ($i = 0; $i -lt $maxRetries; $i++) {
        try {
            if (-not (Test-Path $SyncFilePath)) {
                return @{ messages = @() }
            }
            $content = Get-Content -Path $SyncFilePath -Raw -ErrorAction Stop
            if ([string]::IsNullOrWhiteSpace($content)) {
                return @{ messages = @() }
            }
            return ($content | ConvertFrom-Json)
        }
        catch {
            if ($i -eq ($maxRetries - 1)) {
                Write-Error "Failed to read sync file after $maxRetries attempts: $_"
                return $null
            }
            Start-Sleep -Milliseconds $retryDelay
        }
    }
}

function Set-SyncData {
    param($Data)

    $maxRetries = 5
    $retryDelay = 100

    for ($i = 0; $i -lt $maxRetries; $i++) {
        try {
            $json = ($Data | ConvertTo-Json -Depth 10)
            $json | Set-Content -Path $SyncFilePath -ErrorAction Stop
            return $true
        }
        catch {
            if ($i -eq ($maxRetries - 1)) {
                Write-Error "Failed to write sync file after $maxRetries attempts: $_"
                return $false
            }
            Start-Sleep -Milliseconds $retryDelay
        }
    }
}

# Read current data
$data = Get-SyncData
if (-not $data) {
    $data = @{ messages = @() }
}

# Ensure messages is an array
if (-not $data.messages) {
    $data.messages = @()
}

# Create new message
$guid = [System.Guid]::NewGuid().ToString()
$newMessage = @{
    id = $guid
    timestamp = (Get-Date -Format "o")
    sender = $Sender
    recipient = $Recipient
    message = $Message
    type = $Type
    processed = $false
}

# Add to messages array (ensure it stays an array)
$data.messages = @($data.messages) + $newMessage

# Write back
if (Set-SyncData -Data $data) {
    Write-Host "Message sent to $Recipient (type: $Type)"
    Write-Host "Message ID: $($newMessage.id)"
    Write-Host "Content: $Message"
} else {
    Write-Error "Failed to send message"
    exit 1
}