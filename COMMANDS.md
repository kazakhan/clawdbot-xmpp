# XMPP CLI Commands

## Overview
The XMPP plugin provides CLI commands for managing XMPP connections, contacts, and sending messages.

## Commands

### `openclaw xmpp`
Shows help for all XMPP commands.

```bash
openclaw xmpp
```

### `openclaw xmpp start`
Start the OpenClaw gateway in background.

```bash
openclaw xmpp start
```

### `openclaw xmpp status`
Shows the current XMPP connection status.

```bash
openclaw xmpp status
```

### `openclaw xmpp msg <jid> <message...>`
Send a direct XMPP message to a JID. Routes through the openclaw gateway to agents.

```bash
openclaw xmpp msg user@example.com "Hello, world!"
```

### `openclaw xmpp roster`
Show the contact roster (in-memory).

```bash
openclaw xmpp roster
```

### `openclaw xmpp nick <jid> <name>`
Set a nickname for a JID in the roster (in-memory).

```bash
openclaw xmpp nick user@example.com "John"
```

### `openclaw xmpp join <room> [nick]`
Join a MUC (multi-user chat) room.

```bash
openclaw xmpp join room@conference.example.com mynick
```

### `openclaw xmpp poll`
Poll and display queued unprocessed messages.

```bash
openclaw xmpp poll
```

### `openclaw xmpp clear`
Clear old messages from the queue.

```bash
openclaw xmpp clear
```

### `openclaw xmpp queue`
Show message queue statistics.

```bash
openclaw xmpp queue
```

### `openclaw xmpp vcard`
Manage vCard profile.

```bash
# Show vCard help
openclaw xmpp vcard

# View current vCard
openclaw xmpp vcard get

# Set vCard field
openclaw xmpp vcard set fn "My Bot Name"
openclaw xmpp vcard set nickname "bot"
openclaw xmpp vcard set url "https://github.com/anomalyco/openclaw"
openclaw xmpp vcard set desc "AI Assistant"
```

### `openclaw xmpp subscriptions`
Manage pending subscription requests (admin only).

Subscription requests now require admin approval for security. Users must be approved before they can interact with the bot.

```bash
# Show subscriptions help
openclaw xmpp subscriptions

# List pending subscription requests
openclaw xmpp subscriptions pending

# Approve a subscription request
openclaw xmpp subscriptions approve user@example.com

# Deny a subscription request
openclaw xmpp subscriptions deny user@example.com
```

### FTP
- **FTP File Management**: CLI commands to upload, download, list, and delete files via FTP using same credentials as XMPP server
  - `openclaw xmpp ftp upload <local-path> [remote-name]` - Upload file to FTP (overwrites existing)
  - `openclaw xmpp ftp download <remote-name> [local-path]` - Download file from FTP
  - `openclaw xmpp ftp ls` - List files in your folder
  - `openclaw xmpp ftp rm <remote-name>` - Delete file
  - `openclaw xmpp ftp help` - Show FTP help

## In-XMPP Commands

When connected via XMPP, you can also use slash commands:

- `/list` - Show contacts (admin only)
- `/add <jid> [name]` - Add contact (admin only)
- `/remove <jid>` - Remove contact (admin only)
- `/admins` - List admins (admin only)
- `/whoami` - Show your JID and admin status
- `/join <room> [nick]` - Join MUC room (admin only)
- `/rooms` - List joined rooms (admin only)
- `/leave <room>` - Leave MUC room (admin only)
- `/invite <contact> <room>` - Invite contact to room (admin only)
- `/help` - Show help

## Notes

- Gateway must be running for full functionality
- Some commands require admin privileges
