# XMPP Plugin Test Configuration
# Used by test.ps1 and test.sh

# Test Accounts
TESTER_JID="jamie@kazakhan.com"
BOT_JID="abot@kazakhan.com"
ROOM_JID="general@conference.kazakhan.com"

# Test Directories
TEMP_DIR="/tmp/xmpp-test"
BACKUP_DIR="$TEMP_DIR/backups"
TEST_FILES_DIR="$TEMP_DIR/test-files"

# Test File Names (NEVER use index.html)
TEST_FILE_UPLOAD="xmpp-test-upload-[TIMESTAMP].txt"
TEST_FILE_DOWNLOAD="xmpp-test-download-[TIMESTAMP].txt"

# Timeouts (in seconds)
ABOT_REPLY_TIMEOUT=120
COMMAND_TIMEOUT=30

# Colors for output (ANSI)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Original vCard backup file
VCARD_BACKUP_FILE="$BACKUP_DIR/vcard-original.json"
