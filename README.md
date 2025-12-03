# ClaudeSync - Cross-Computer Claude Code Messaging

This system allows Claude Code instances on different computers to communicate with each other.

## Architecture

- **Scripts**: Stored in this GitHub repo for version control
- **messages.json**: Stored in Dropbox for real-time sync between computers
- **Log files**: Per-computer (e.g., `watcher-COMPUTERNAME.log`) to avoid conflicts

## Setup

### 1. Clone this repo
```bash
cd ~/github
git clone https://github.com/meichenlaub/ClaudeSync.git
```

### 2. Ensure Dropbox folder exists
The scripts auto-detect Dropbox at:
- `~/Dropbox (Personal)/ClaudeSync`
- `~/Dropbox/ClaudeSync`

Create the folder and `messages.json` if needed:
```powershell
mkdir "$env:USERPROFILE\Dropbox (Personal)\ClaudeSync"
'{"messages":[]}' | Set-Content "$env:USERPROFILE\Dropbox (Personal)\ClaudeSync\messages.json"
```

### 3. Set up scheduled task (keeps watcher running)
```powershell
cd ~/github/ClaudeSync
powershell -ExecutionPolicy Bypass -File setup-scheduled-task.ps1
```

### 4. Start the watcher manually (or wait for scheduled task)
```powershell
powershell -ExecutionPolicy Bypass -File start-watcher.ps1
```

## Usage

### Send a message to another computer
From Claude Code, use:
```powershell
cd ~/github/ClaudeSync
powershell -ExecutionPolicy Bypass -File send-message.ps1 -Message "your message" -Recipient "COMPUTER-NAME"
```

### Computer Names
- `AoPS-HQ-BAProd-MEichenlaub`
- `DESKTOP-P2NCMJT`

## Files

| File | Location | Purpose |
|------|----------|---------|
| `messages.json` | Dropbox | Message queue (real-time sync) |
| `*.ps1` | GitHub | Scripts (version controlled) |
| `logs/*.log` | GitHub (gitignored) | Per-computer logs |

## Troubleshooting

**Watcher not starting?**
- Check logs: `logs/watcher-COMPUTERNAME.log`
- Verify Dropbox path in `config.ps1`

**Messages not syncing?**
- Ensure Dropbox is running
- Check `messages.json` exists in Dropbox

**Duplicate messages?**
- Old issue with Dropbox conflicts - now using GitHub for scripts
