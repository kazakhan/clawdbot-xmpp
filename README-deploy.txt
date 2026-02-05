XMPP JID Target Support Fix
============================

This patch fixes the "Unknown target" error when sending XMPP messages via the CLI.

Problem
-------
Running: openclaw xmpp msg jamie@kazakhan.com "Hello"
Results in: Failed to send message: Error: Unknown target "jamie@kazakhan.com" for XMPP.

Solution
--------
Apply the patch to recognize XMPP JIDs (user@domain format) as valid targets.

Files
-----
- xmpp-jid-target-fix.patch  : The actual patch file
- deploy-xmpp-jid-fix.ps1    : PowerShell deployment script
- pr.md                      : Full documentation
- README.txt                 : This file

Deployment
----------

Windows (PowerShell):
  1. Open PowerShell as Administrator
  2. Navigate to this directory
  3. Run: powershell -ExecutionPolicy Bypass -File deploy-xmpp-jid-fix.ps1

Manual Deployment (Windows):
  1. Open: %APPDATA%\npm\node_modules\openclaw\dist\infra\outbound\target-resolver.js
  2. Find the looksLikeTargetId() function (around line 349)
  3. Add this pattern before the final "return false;":
  
     // XMPP JID pattern: user@domain format (e.g., jamie@kazakhan.com)
     if (/^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(trimmed)) {
       return true;
     }
  
  4. Save the file
  5. Restart the gateway: openclaw gateway stop && openclaw gateway

Manual Deployment (Linux/Mac):
  1. Open: /usr/local/lib/node_modules/openclaw/dist/infra/outbound/target-resolver.js
  2. Find the looksLikeTargetId() function
  3. Add the same pattern before "return false;"
  4. Save and restart gateway

Rollback
--------
Windows:
  Copy-Item target-resolver.js.backup.YYYYMMDD-HHMMSS target-resolver.js
  openclaw gateway restart

Linux/Mac:
  sudo cp target-resolver.js.backup target-resolver.js
  openclaw gateway restart

Verification
------------
After applying the patch:
  1. Start gateway: openclaw gateway
  2. Wait for XMPP connection (check logs for "online as")
  3. Send test message: openclaw xmpp msg jamie@kazakhan.com "Test"
  4. Should deliver without "Unknown target" error

Support
-------
See pr.md for full documentation and testing procedures.

Version: 2026-02-05
For: openclaw 2026.2.2-3+
