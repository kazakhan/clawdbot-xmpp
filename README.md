# OpenClaw XMPP Plugin

A full-featured XMPP channel plugin for OpenClaw that enables XMPP/Jabber integration with support for 1:1 chat, multi-user chat (MUC), and CLI management.

## Status: ✅ WORKING

The XMPP plugin is now fully functional with CLI command support, shared sessions, and memory continuity!

## Security

The XMPP plugin implements multiple security measures:

### Input Validation
- **Path Traversal Protection**: File downloads and transfers sanitize filenames to prevent directory traversal attacks
- **Rate Limiting**: Command rate limiting per JID (10 commands/minute) to prevent abuse
- **Queue Enforcement**: Message queue limited to 100 messages to prevent memory exhaustion

### Rate Limiting
- Commands are rate limited per sender JID
- Users exceeding the limit receive: "Too many commands. Please wait before sending more."
- Rate limit window: 1 minute

### Path Traversal Protection
- Download filenames are sanitized: illegal characters replaced with `_`
- Paths are normalized and checked for `..` or absolute paths
- IBB file transfers also sanitize filenames on completion

## Shared Sessions & Memory

The XMPP plugin supports **shared session memory** between direct chat and groupchat:

### How It Works
1. **Direct Chat**: Messages create sessions keyed by user's bare JID (e.g., `xmpp:user@domain.com`)
2. **GroupChat**: When user is identified, uses same session key for memory continuity
3. **Memory**: Agent remembers conversation context across both conversation types

### User Identification
- **Occupant-ID (XEP-0327)**: Server provides stable occupant IDs for automatic identification
- **Known Users**: When a user messages directly first, their nick is learned for future groupchat sessions

### Session Memory Configuration
Add to `~/.openclaw/openclaw.json`:
```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": true,
        "experimental": {
          "sessionMemory": true
        }
      }
    }
  }
}
```

## Commands

```
openclaw xmpp --help
openclaw xmpp status
openclaw xmpp msg user@domain.com "Hello"
openclaw xmpp roster
openclaw xmpp nick <jid> <name>
openclaw xmpp join <room> [nick]
openclaw xmpp poll
openclaw xmpp clear
openclaw xmpp queue
```

Or use the standard OpenClaw message command:
```bash
openclaw message send --channel xmpp --target user@domain.com --message "Hello"
```

## Features

### 🚀 Core XMPP Protocol
- **Full XMPP Client**: Complete XMPP protocol implementation using `@xmpp/client`
- **Multi-User Chat (MUC)**: Join and participate in group chat rooms
- **Direct Messaging**: 1:1 chat with individual users
- **Presence Management**: Online/offline status handling
- **Auto-Reconnection**: Automatic reconnection on network issues
- **TLS Support**: Secure connections
- **Occupant-ID (XEP-0327)**: Stable user identification in MUC rooms

### 👥 Shared Sessions & Memory
- **Session Continuity**: Same session used for direct chat and groupchat when user identified
- **Automatic Learning**: Users who message directly have their nicks learned for groupchat

### 👥 Contact & Roster Management
- **Contact Storage**: In-memory roster with nickname support
- **Admin Management**: Privileged commands for configured admin JIDs
- **Roster CLI**: View and manage roster via command-line

### ⚙️ Room & Conference Management
- **Room Auto-Join**: Automatically join configured rooms on startup
- **MUC Invite Handling**: Auto-accept room invitations

### 🔧 CLI Integration
All commands work through the OpenClaw CLI:
```bash
openclaw xmpp status              # Check connection status
openclaw xmpp msg <jid> <msg>    # Send direct messages
openclaw xmpp join <room> [nick] # Join MUC rooms
openclaw xmpp roster             # View current roster
openclaw xmpp nick <jid> <name>  # Set roster nickname
openclaw xmpp poll               # Poll message queue
openclaw xmpp clear              # Clear message queue
openclaw xmpp queue              # Show queue status
```

### 🔄 Message Queue System
- **Inbound Queue**: Temporary storage for inbound messages
- **Queue Management**: Poll, clear, and monitor via CLI
- **Age-Based Cleanup**: Automatic cleanup of old messages

## Installation

### Prerequisites
- Node.js (v16 or higher)
- OpenClaw installation (2026.1.24-3 or later with CLI fixes)
- XMPP server account (Prosody, ejabberd, etc.)

### Installation
1. Plugin is located at `~/.openclaw/extensions/xmpp/`
2. Ensure OpenClaw is configured with XMPP channel enabled
3. Gateway must be running for message sending to work

## Configuration

Add to `~/.openclaw/openclaw.json`:
```json
{
  "plugins": {
    "entries": {
      "xmpp": {
        "enabled": true
      }
    }
  },
  "channels": {
    "xmpp": {
      "enabled": true,
      "accounts": {
        "default": {
          "enabled": true,
          "service": "xmpp://your-server.com:5222",
          "domain": "your-server.com",
          "jid": "bot@your-server.com",
          "password": "your-password",
          "adminJid": "admin@your-server.com",
          "rooms": ["general@conference.your-server.com"],
          "dataDir": "/path/to/data"
        }
      }
    }
  }
}
```

## Quick Start

```bash
# Check XMPP status
openclaw xmpp status

# Send a message
openclaw xmpp msg user@domain.com "Hello from OpenClaw!"

# Join a MUC room
openclaw xmpp join room@conference.domain.com

# Or use the standard message command
openclaw message send --channel xmpp --target user@domain.com --message "Hello"
```

## Architecture

The plugin consists of:
- `index.ts` - Main plugin with XMPP client, message handling, and CLI registration
- `data/commands.ts` - CLI command definitions
- `openclaw.plugin.json` - Plugin metadata with `"cli": ["xmpp"]`

## Troubleshooting

### "unknown command 'xmpp'"
- Ensure OpenClaw CLI fixes are applied (see `openclaw-cli-fix.zip`)
- Run `openclaw plugins list` to verify plugin loads

### "No XMPP client available"
- Gateway must be running: `openclaw gateway`
- Messages route through gateway when client not available locally

### Messages not sending
- Verify gateway is running: `openclaw gateway status`
- Check target JID format: `user@domain.com`

## Files

```
xmpp/
├── index.ts              # Main plugin
├── package.json          # Dependencies
├── openclaw.plugin.json  # Plugin metadata
├── data/
│   └── commands.ts       # CLI commands
├── README.md             # This file
├── CHANGELOG.md          # Change history
├── FAQ.md                # Common questions
└── ROADMAP.md            # Planned features
```

## License

Part of OpenClaw ecosystem. See main repository for license info.