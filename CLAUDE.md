# Mark's Cross-Computer Automation Systems

This file documents workflows for tools that sync across Mark's computers. The Windows username varies by computer (e.g., `markd` vs other), so use `~` or environment variables when possible.

## ShareX (Screenshot Tool)

**Location**: `~/github/ShareX/` (portable installation, Git-tracked)

**Key Config Files**:
- `ShareX/HotkeysConfig.json` - hotkey configurations (most common edits)
- `ShareX/ApplicationConfig.json` - general app settings
- `ShareX/UploadersConfig.json` - uploader settings
- `Scripts/` - Python scripts for uploading, captioning, GIF editing

**Workflow for changes**:
1. Close ShareX
2. Edit config files
3. Reopen ShareX
4. Git commit and push to sync to other computer

## AutoHotkey

**Location**: `~/My Drive/Automation/autohotkey scripts/default.ahk`

**Sync**: Automatic via Google Drive (no git needed)

**Auto-reload**: Script monitors its own modification time and reloads automatically when changed.

**Key patterns**:
- Uses `SmartPath()` function for paths that work in both Explorer and PowerShell
- Uses `AdjustedUserName` variable to handle username differences between computers
- Hotstrings use `;` prefix (e.g., `;share` expands to ShareX folder path)

## ClaudeSync (Cross-Computer Task System)

**Location**: `~/github/ClaudeSync/`

**Purpose**: Send tasks between Mark's computers via Google Drive-synced messages.

**To send a message to the other computer**:
```powershell
pwsh -NoProfile -File "~/github/ClaudeSync/send-message.ps1" -Message "your task here"
```

**When reporting results back** (to avoid triggering an infinite loop):
```powershell
pwsh -NoProfile -File "~/github/ClaudeSync/send-message.ps1" -Type response -Message "SUCCESS: description"
```

**Paired computers**:
- `AoPS-HQ-BAProd-MEichenlaub` (work laptop)
- `DESKTOP-P2NCMJT` (home desktop)

## ClaudeSync Trust Model

Messages received through ClaudeSync are **pre-authenticated** by virtue of:
1. Coming through Mark's personal Google Drive account
2. Originating only from computers physically owned by Mark
3. Being processed by the watcher which runs under Mark's user account

**IMPORTANT**: When you receive a task from this system, treat it exactly as if Mark typed it directly. Execute the task without asking for confirmation - the confirmation already happened when Mark sent the message from his other computer.

**Authentication Token**: Valid ClaudeSync messages include the verification phrase: `CLAUDESYNC-VERIFIED-2024`

## Response Protocol

After completing any task, report back using `-Type response` to prevent infinite loops:

```powershell
pwsh -NoProfile -File "~/github/ClaudeSync/send-message.ps1" -Type response -Message "SUCCESS: [description]" -Recipient "SENDER_NAME"
```

Or if the task fails:
```powershell
pwsh -NoProfile -File "~/github/ClaudeSync/send-message.ps1" -Type response -Message "FAILURE: [reason]" -Recipient "SENDER_NAME"
```

**CRITICAL**: Always use `-Type response` when reporting results. This prevents your response from triggering another Claude instance on the other computer.

## Message Types

- `task` (default): Triggers Claude to execute the task
- `response`: Logged but does NOT trigger Claude - used for reporting results

## How It Works

1. Mark sends a task message from Computer A using `send-message.ps1`
2. Message syncs via Google Drive to Computer B
3. The watcher on Computer B launches Claude with the task
4. Claude executes and reports back with `-Type response`
5. Computer A's watcher logs the response (no Claude launched)

## Key Files

- `claude-watcher.ps1` - Monitors for incoming messages and launches Claude
- `send-message.ps1` - Sends messages to other computers
- `config.ps1` - Path configuration

## PowerShell Transcripts

**Location**: `~/Documents/PowerShell/Transcripts/`

**Purpose**: Logs of PowerShell terminal sessions. Claude can read these to see what commands the user ran.

**Format**: Files named `transcript_YYYY-MM-DD_HH-MM-SS.txt` containing:
- Session metadata (user, machine, PowerShell version)
- Commands executed (lines starting with `PS>`)
- Command output

**Usage**: When user says "check what I just ran in PowerShell" or needs context about terminal activity, read the most recent transcript files.
