# XMPP Plugin Test Plan

Comprehensive test plan for validating all XMPP plugin functionality.

## Prerequisites

- XMPP server running (kazakhan.com)
- OpenClaw gateway running
- Test accounts: bot@kazakhan.com, abot@kazakhan.com, clawdbothome@kazakhan.com, jamie@kazakhan.com
- Test room: general@conference.kazakhan.com
- Admin JID configured in openclaw.json

---

## 1. Core XMPP Connection

### 1.1 Gateway Status
**Verify:** Gateway responds to status command

### 1.2 XMPP Connection Established
**Verify:** XMPP client connected to server
**Log Check:** `XMPP client connected` message

### 1.3 TLS Certificate Verification
**Verify:** TLS handshake successful
**Log Check:** No certificate errors

### 1.4 Auto-Reconnection
**Action:** Simulate network disconnect
**Verify:** Auto-reconnect within 5 seconds

---

## 2. Direct Messages

### 2.1 Bot -> User Message
**Command:** `openclaw xmpp msg <jid> <message>`
**Verify:** Message delivered to recipient's XMPP client

### 2.2 User -> Bot Message
**Action:** Send message from XMPP client to bot
**Verify:** Message queued in message store

### 2.3 Message from Contact
**Action:** Send message from whitelisted contact
**Verify:** Message forwarded to agent, response sent back

### 2.4 Message from Non-Contact
**Action:** Send message from unknown JID
**Verify:** Message ignored (no forwarding to agent)

### 2.5 Message Queue Processing
**Command:** `openclaw xmpp poll`
**Verify:** Queued messages displayed

### 2.6 Queue Statistics
**Command:** `openclaw xmpp queue`
**Verify:** Shows total messages, unprocessed count

### 2.7 Queue Clearance
**Command:** `openclaw xmpp clear`
**Verify:** Old messages cleared, confirmation shown

---

## 3. Multi-User Chat (MUC)

### 3.1 Join Room via CLI
**Command:** `openclaw xmpp join <room>`
**Verify:** Bot joins room with configured/default nick

### 3.2 Join Room via Slash Command
**Command:** `/join <room>` in direct message
**Verify:** Bot joins specified room

### 3.3 Room Join Confirmation
**Verify:** `Joined room: <room> as <nick>` message sent

### 3.4 Receive Group Message
**Action:** User sends message in room while bot is joined
**Verify:** Message queued with room JID

### 3.5 Bot Sends to Room
**Action:** Agent sends response to room
**Verify:** Message visible to all room occupants

### 3.6 Leave Room via CLI
**Command:** `openclaw xmpp leave <room>`
**Verify:** Bot leaves room, confirmation shown

### 3.7 Leave Room via Slash Command
**Command:** `/leave <room>` in room
**Verify:** Bot leaves specified room

### 3.8 Auto-Join Rooms on Startup
**Verify:** Configured rooms joined on gateway start

### 3.9 Room Nickname Tracking
**Verify:** Bot's nick in each room stored and retrievable

---

## 4. Contact & Roster Management

### 4.1 Add Contact via CLI
**Command:** `openclaw xmpp add <jid>`
**Verify:** Contact added to roster

### 4.2 Add Contact via Slash Command
**Command:** `/add <jid>` in direct message
**Verify:** Contact added, subscription request sent

### 4.3 Add Contact with Nickname
**Command:** `openclaw xmpp add <jid> <name>`
**Verify:** Contact added with nickname

### 4.4 Remove Contact
**Command:** `openclaw xmpp remove <jid>`
**Verify:** Contact removed from roster

### 4.5 List Contacts
**Command:** `openclaw xmpp roster`
**Verify:** All contacts displayed with nicknames

### 4.6 Set Nickname
**Command:** `openclaw xmpp nick <jid> <name>`
**Verify:** Nickname updated for contact

### 4.7 Subscription Auto-Approve (Existing Contacts)
**Action:** Existing contact requests subscription
**Verify:** Auto-approved, mutual subscription established

### 4.8 Subscription Pending (New Requests)
**Action:** New JID requests subscription
**Verify:** Added to pending subscriptions queue

### 4.9 Approve Subscription
**Command:** `openclaw xmpp subscriptions approve <jid>`
**Verify:** Subscription approved, contact added

### 4.10 Deny Subscription
**Command:** `openclaw xmpp subscriptions deny <jid>`
**Verify:** Subscription denied, contact not added

### 4.11 List Pending Subscriptions
**Command:** `openclaw xmpp subscriptions pending`
**Verify:** Pending requests displayed

---

## 5. MUC Invites (Auto-Accept)

### 5.1 Invite Contact via Slash Command
**Command:** `/invite <jid> <room>`
**Verify:** XMPP MUC invite sent to contact

### 5.2 Invite Auto-Accept
**Action:** Bot receives MUC invite
**Verify:** Bot auto-joins room immediately

### 5.3 Invite Confirmation
**Verify:** `🤝 Received MUC invite...` then `✅ Auto-accepted invite...` in logs

### 5.4 Invite from Room
**Action:** Room sends invite to bot
**Verify:** Bot auto-joins room

---

## 6. vCard Profile

### 6.1 View Current vCard
**Command:** `openclaw xmpp vcard get`
**Verify:** Current vCard fields displayed

### 6.2 View Any User's vCard
**Command:** `openclaw xmpp vcard get <jid>`
**Verify:** Specified user's vCard retrieved from server

### 6.3 Set Full Name
**Command:** `openclaw xmpp vcard set fn <value>`
**Verify:** Full Name updated on server

### 6.4 Set Nickname
**Command:** `openclaw xmpp vcard set nickname <value>`
**Verify:** Nickname updated on server

### 6.5 Set URL
**Command:** `openclaw xmpp vcard set url <value>`
**Verify:** URL updated on server

### 6.6 Set Description
**Command:** `openclaw xmpp vcard set desc <value>`
**Verify:** Description updated on server

### 6.7 Set Avatar URL
**Command:** `openclaw xmpp vcard set avatarurl <value>`
**Verify:** Avatar URL updated on server

### 6.8 vCard Help
**Command:** `openclaw xmpp vcard help`
**Verify:** All vCard subcommands displayed

---

## 7. SFTP File Management

### 7.1 SFTP Connection
**Command:** `openclaw xmpp sftp ls`
**Verify:** Connected to SFTP server (kazakhan.com:2211)

### 7.2 List Files
**Command:** `openclaw xmpp sftp ls`
**Verify:** Files listed from home directory

### 7.3 Upload File
**Command:** `openclaw xmpp sftp upload <local-path>`
**Verify:** File uploaded, confirmation shown

### 7.4 Upload with Custom Name
**Command:** `openclaw xmpp sftp upload <local-path> <remote-name>`
**Verify:** File uploaded with specified name

### 7.5 Download File
**Command:** `openclaw xmpp sftp download <remote-name>`
**Verify:** File downloaded to downloads folder

### 7.6 Download to Custom Path
**Command:** `openclaw xmpp sftp download <remote-name> <local-path>`
**Verify:** File downloaded to specified path

### 7.7 Delete File
**Command:** `openclaw xmpp sftp rm <remote-name>`
**Verify:** File deleted from server

### 7.8 SFTP Help
**Command:** `openclaw xmpp sftp help`
**Verify:** All SFTP commands displayed

### 7.9 SFTP with Encrypted Password
**Verify:** SFTP works after password encryption

---

## 8. File Transfer Security

### 8.1 File Size Validation
**Action:** Upload/download file > 10MB
**Verify:** Rejected with size limit error

### 8.2 MIME Type Detection
**Verify:** Files validated by magic bytes/extension

### 8.3 Blocked File Types
**Action:** Try to upload/download: .exe, .bat, .cmd, .sh, .php, .js, .py, .dll, .scr, .jar
**Verify:** Blocked with appropriate error

### 8.4 Allowed File Types
**Action:** Upload valid file (PDF, image, text, etc.)
**Verify:** File accepted and processed

### 8.5 Per-User Quota
**Command:** `openclaw xmpp file-transfer-security quota <jid>`
**Verify:** Quota usage displayed

### 8.6 Quota Enforcement
**Action:** User exceeds 100MB quota
**Verify:** Upload rejected, quota exceeded message

### 8.7 Concurrent Download Limit
**Action:** Start 4+ downloads for same user
**Verify:** 4th download rejected (max 3 concurrent)

### 8.8 File Hash Calculation
**Verify:** SHA-256 hash computed for all files

### 8.9 Suspicious File Quarantine
**Action:** Receive file with malware signature
**Verify:** File moved to quarantine directory

### 8.10 Security Status
**Command:** `openclaw xmpp file-transfer-security status`
**Verify:** Security settings displayed

### 8.11 List Quarantined Files
**Command:** `openclaw xmpp file-transfer-security quarantine`
**Verify:** Quarantined files listed

### 8.12 Temp File Cleanup
**Command:** `openclaw xmpp file-transfer-security cleanup`
**Verify:** Old temp files removed

---

## 9. Password Encryption

### 9.1 Check Encryption Status
**Verify:** Password stored in `ENC:<hex>` format

### 9.2 Encrypt Plaintext Password
**Command:** `openclaw xmpp encrypt-password`
**Verify:** Password encrypted, encryptionKey generated

### 9.3 Connection with Encrypted Password
**Action:** Restart gateway after encryption
**Verify:** XMPP connects successfully

### 9.4 Decryption Works
**Verify:** Password decrypted automatically on connection

---

## 10. Audit Logging

### 10.1 Audit Logging Enabled
**Verify:** Audit logs written to ./logs/audit-*.log

### 10.2 Audit Event Types Logged
**Verify:** Events include:
- Authentication: login_success, login_failure
- Authorization: permission_granted, permission_denied
- Commands: command_executed, command_failed
- File Operations: file_upload, file_download, file_delete
- Security: suspicious_activity, rate_limit_exceeded
- Admin Actions: subscription_approved, subscription_denied
- Connections: xmpp_connected, xmpp_disconnected

### 10.3 Sensitive Data Redaction
**Verify:** Passwords, tokens, API keys redacted in logs

### 10.4 Audit Status
**Command:** `openclaw xmpp audit status`
**Verify:** Audit logging status displayed

### 10.5 List Audit Events
**Command:** `openclaw xmpp audit list [limit]`
**Verify:** Recent audit events displayed

### 10.6 Export Audit Log
**Command:** `openclaw xmpp audit export [days]`
**Verify:** Events exported to JSON file

### 10.7 Log Rotation
**Verify:** New log file created when > 10MB

### 10.8 Log Retention
**Verify:** Logs older than 30 days cleaned up

---

## 11. Input Validation

### 11.1 JID Validation
**Action:** Process messages/invites with various JID formats
**Verify:** JIDs sanitized and validated

### 11.2 JID Sanitization
**Verify:** Localpart lowercased, format validated

### 11.3 Filename Sanitization
**Action:** Upload/download with special characters
**Verify:** Illegal chars replaced with `_`

### 11.4 Path Traversal Prevention
**Action:** Try `../../../etc/passwd` in filename
**Verify:** Path traversal blocked

### 11.5 URL Validation
**Action:** Try to download from various URLs
**Verify:** Valid URLs accepted, localhost/private IPs blocked

### 11.6 Message Body Sanitization
**Action:** Send message with control characters
**Verify:** Control characters removed

### 11.7 Room Name Validation
**Action:** Join/create room with various names
**Verify:** Room names sanitized

### 11.8 Nickname Sanitization
**Action:** Set nickname with special characters
**Verify:** Invalid characters removed

---

## 12. Rate Limiting

### 12.1 Per-JID Rate Limit
**Action:** Send 10+ commands in 1 minute from same JID
**Verify:** After 10 commands: rate limited

### 12.2 Rate Limit Message
**Verify:** `Too many commands. Please wait.` message

### 12.3 IP-Based Rate Limiting
**Action:** Multiple JIDs from same IP send commands
**Verify:** Additional IP-based limits applied

### 12.4 Remaining Requests
**Action:** Check rate limit status
**Verify:** Remaining request count shown

### 12.5 Retry-After Header
**Verify:** `retryAfter` seconds provided when blocked

### 12.6 Temporary Block
**Action:** Continue violating after rate limit
**Verify:** Blocked for 5 minutes after 3 violations

### 12.7 Unblock User
**Action:** Manual unblock
**Verify:** User can send commands again

---

## 13. Security Logging

### 13.1 Secure Logging Module
**Verify:** `secureLog` module used for sensitive operations

### 13.2 Password Redaction
**Verify:** Passwords not visible in debug logs

### 13.3 Token/API Key Redaction
**Verify:** Credentials not in logs

### 13.4 JID/IP Redaction
**Verify:** Optional JID/IP redaction in logs

### 13.5 Security Events Logged
**Verify:** Security events logged separately

---

## 14. In-Chat Slash Commands

### 14.1 /help
**Action:** Send `/help` to bot
**Verify:** Available commands listed

### 14.2 /whoami
**Action:** Send `/whoami` to bot
**Verify:** User's JID and status shown

### 14.3 /list (Admin)
**Action:** Send `/list` to bot
**Verify:** Contacts listed

### 14.4 /add (Admin)
**Action:** Send `/add <jid>` to bot
**Verify:** Contact added

### 14.5 /remove (Admin)
**Action:** Send `/remove <jid>` to bot
**Verify:** Contact removed

### 14.6 /admins
**Action:** Send `/admins` to bot
**Verify:** Admin JIDs listed

### 14.7 /join (Admin)
**Action:** Send `/join <room>` to bot
**Verify:** Bot joins room

### 14.8 /rooms
**Action:** Send `/rooms` to bot
**Verify:** Joined rooms listed

### 14.9 /leave (Admin)
**Action:** Send `/leave <room>` to bot
**Verify:** Bot leaves room

### 14.10 /invite (Admin)
**Action:** Send `/invite <jid> <room>` to bot
**Verify:** Invite sent, contact auto-joins

### 14.11 /vcard (Admin)
**Action:** Send `/vcard help|get|set` to bot
**Verify:** vCard management works

### 14.12 /whiteboard
**Action:** Send `/whiteboard draw <prompt>` to bot
**Verify:** Image generation request queued

### 14.13 /whiteboard send
**Action:** Send `/whiteboard send <url>` to bot
**Verify:** Image URL shared via file transfer

### 14.14 Groupchat Slash Commands
**Action:** Send slash commands in room
**Verify:** Only plugin commands processed locally

### 14.15 Non-Plugin Commands in Groupchat
**Action:** Send non-plugin slash command in room
**Verify:** Ignored, not forwarded to agent

---

## 15. Session Management

### 15.1 Direct Chat Session
**Verify:** Messages in 1:1 chat share session

### 15.2 Groupchat Session
**Verify:** Messages in room use room-based session

### 15.3 Session Continuity
**Verify:** Session persists across messages

### 15.4 Session Key Format
**Verify:** Keys use `xmpp:<jid>` format

---

## 16. Whiteboard Commands

### 16.1 Whiteboard Draw Request
**Action:** `/whiteboard draw <prompt>`
**Verify:** Request queued, agent processes

### 16.2 Whiteboard Image Share
**Action:** `/whiteboard send <url>`
**Verify:** Image shared via file transfer

### 16.3 Whiteboard Status
**Verify:** Command help displayed

---

## 17. Message Persistence

### 17.1 Save Outbound Messages
**Verify:** Messages saved to `data/messages/`

### 17.2 Save Inbound Messages
**Verify:** Received messages saved

### 17.3 Message Archive Structure
**Verify:** Files organized by conversation

### 17.4 Max Messages Per File
**Verify:** 256 messages per file limit

---

## 18. Data Directory Structure

### 18.1 Contacts Storage
**Verify:** `data/xmpp-contacts.json` exists

### 18.2 Admins Storage
**Verify:** `data/xmpp-admins.json` exists

### 18.3 vCard Storage
**Verify:** `data/xmpp-vcard.json` exists

### 18.4 Messages Storage
**Verify:** `data/messages/` directory exists

### 18.5 Logs Storage
**Verify:** `logs/` directory exists

### 18.6 Temp Files
**Verify:** `temp/` directory exists

### 18.7 Quarantine Directory
**Verify:** `quarantine/` directory exists

---

## 19. Error Handling

### 19.1 Connection Errors
**Verify:** Errors logged, auto-reconnect attempted

### 19.2 Message Delivery Errors
**Verify:** Failed sends logged, no crash

### 19.3 Invalid Input Handling
**Verify:** Invalid commands return helpful error

### 19.4 File Operation Errors
**Verify:** Upload/download errors handled gracefully

---

## 20. Configuration

### 20.1 Account Configuration
**Verify:** XMPP account loads from openclaw.json

### 20.2 Admin Configuration
**Verify:** Admin JIDs loaded

### 20.3 Room Configuration
**Verify:** Auto-join rooms loaded

### 20.4 Data Directory Configuration
**Verify:** Data path loaded from config

---

## Test Results Template

| Category | Test | Expected | Actual | Status |
|----------|------|----------|--------|---------|
| Connection | Gateway status | Responds | | |
| Connection | XMPP connected | Connected | | |
| Direct Messages | Bot -> User | Delivered | | |
| Direct Messages | User -> Bot | Queued | | |
| MUC | Join room | Joined | | |
| MUC | Receive message | Queued | | |
| Contacts | Add contact | Added | | |
| Contacts | List contacts | Listed | | |
| SFTP | Upload file | Uploaded | | |
| SFTP | Download file | Downloaded | | |
| Security | Encrypt password | Encrypted | | |
| Rate Limit | 10 commands/min | Limited | | |
| Audit | Event logged | Logged | | |
| ... | | | | |

---

## Test Execution Order

1. Verify prerequisites
2. Core connection tests
3. Direct messaging tests
4. MUC tests
5. Contact management tests
6. MUC invite tests
7. vCard tests
8. SFTP tests
9. File transfer security tests
10. Password encryption tests
11. Audit logging tests
12. Input validation tests
13. Rate limiting tests
14. Slash command tests
15. Session management tests
16. Error handling tests
17. Configuration verification

---

## Notes

- Run tests in order listed above
- Check gateway logs for detailed results
- Some tests require manual verification
- Document any failures with steps to reproduce
- Re-test after any code changes
