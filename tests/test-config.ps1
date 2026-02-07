# XMPP Plugin Test Configuration (Windows PowerShell)

# Test Accounts
$TESTER_JID = "jamie@kazakhan.com"
$BOT_JID = "abot@kazakhan.com"
$ROOM_JID = "general@conference.kazakhan.com"

# Test Directories
$TEMP_DIR = "$env:TEMP\xmpp-test"
$BACKUP_DIR = "$TEMP_DIR\backups"
$TEST_FILES_DIR = "$TEMP_DIR\test-files"

# Test File Names (NEVER use index.html)
$TEST_FILE_PREFIX = "xmpp-test-"

# Timeouts (in seconds)
$ABOT_REPLY_TIMEOUT = 180
$COMMAND_TIMEOUT = 30

# Original vCard backup file
$VCARD_BACKUP_FILE = "$BACKUP_DIR\vcard-original.json"

# Log file
$LOG_FILE = "$TEMP_DIR\test-output.log"
