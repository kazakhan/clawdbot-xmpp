# Pull Request: XMPP Plugin CLI Fix and Roster Persistence

## Summary

This PR fixes critical CLI command registration issues in OpenClaw that prevented XMPP plugin commands from working, and adds persistent roster storage to the XMPP plugin.

## Changes

### Core OpenClaw Fixes

#### 1. CLI Registration Bug Fix (`dist/cli/program/register.subclis.js`)
**Problem**: `registerPluginCliCommands()` was only called when the `plugins` subcommand was registered, not for lazy-loaded subcommands like `xmpp`.

**Solution**: Added `registerPluginCliCommands()` calls for ALL subcommand registration paths to ensure plugin CLI commands are registered regardless of how the CLI is invoked.

#### 2. XMPP Target Resolver Fix (`dist/cli/infra/outbound/target-resolver.js`)
**Problem**: The target resolver only accepted phone numbers for iMessage/BlueBubbles, not XMPP JIDs (user@domain.com).

**Solution**: Added JID pattern validation and XMPP channel support to the target resolver.

#### 3. Async Program Build (`dist/cli/program/command-registry.js`, `dist/cli/program/build-program.js`)
**Problem**: `registerProgramCommands()` and `buildProgram()` were synchronous but needed to be async for proper initialization.

**Solution**: Made these functions async and updated callers to await them.

#### 4. Gateway Message Routing
**Problem**: CLI and gateway are separate processes, so CLI couldn't access XMPP client directly.

**Solution**: Set `deliveryMode: "gateway"` and implemented `sendViaGateway()` function to route messages through the gateway's WebSocket API.

### XMPP Plugin Changes

#### 5. Roster Persistence (`extensions/xmpp/data/commands.ts`)
**Added**: Persistent storage for roster using `xmpp-roster.json` file.

- Roster saves to `~/.openclaw/extensions/xmpp/xmpp-roster.json`
- Nicknames persist across restarts
- Compatible with existing in-memory roster

#### 6. CLI Integration (`extensions/xmpp/index.ts`, `extensions/xmpp/openclaw.plugin.json`)
**Changed**: Switched from `registerCommands()` to `registerCli()` for proper CLI integration.

Added `"cli": ["xmpp"]` to plugin metadata.

#### 7. Debug Logging Cleanup (`extensions/xmpp/index.ts`)
**Removed**: Excessive console.log statements for cleaner CLI output.

## Files Modified

### OpenClaw Core (in `node_modules/openclaw/`):
```
dist/cli/program/register.subclis.js
dist/cli/program/command-registry.js
dist/cli/program/build-program.js
dist/cli/run-main.js
dist/index.js
dist/infra/outbound/target-resolver.js
```

### XMPP Plugin:
```
extensions/xmpp/index.ts
extensions/xmpp/data/commands.ts
extensions/xmpp/openclaw.plugin.json
```

### Distribution Patch:
```
openclaw-cli-fix.zip (14KB)
```

## Testing

### Before Fix
```
$ openclaw xmpp --help
error: unknown command 'xmpp'
```

### After Fix
```
$ openclaw xmpp --help
Usage: openclaw xmpp [options] [command]

XMPP channel plugin commands

Options:
  -h, --help  display help for command

Commands:
  start       Start the OpenClaw gateway in background
  status      Show XMPP connection status
  msg         Send direct XMPP message (routes through gateway)
  roster      Show roster (in-memory)
  nick        Set roster nickname (in-memory)
  join        Join MUC room
  poll        Poll queued messages
  clear       Clear old messages from queue
  queue       Show message queue status
  help        display help for command
```

## Installation

### For Users
The CLI fix is distributed as `openclaw-cli-fix.zip`. Apply with:
```bash
cd "C:\Users\<username>\AppData\Roaming\npm\node_modules\openclaw"
unzip -o path/to/openclaw-cli-fix.zip
```

### For Developers
The XMPP plugin changes are in `extensions/xmpp/`. No additional installation needed.

## Breaking Changes
None. This PR is fully backward compatible.

## Migration Steps
1. Apply `openclaw-cli-fix.zip` to OpenClaw installation
2. Restart OpenClaw
3. Roster will persist to `xmpp-roster.json` automatically

## Related Issues
- CLI commands not registered for lazy-loaded subcommands
- XMPP JID not recognized as valid target
- Roster not persisting across restarts

## Checklist
- [x] CLI commands register properly
- [x] XMPP JIDs accepted as valid targets
- [x] Messages route through gateway when needed
- [x] Roster persists to file
- [x] All existing functionality preserved
- [x] Debug logging cleaned up
- [x] Tests pass (manual testing completed)

## Additional Notes
The CLI fix is critical for any plugin that provides CLI commands. The pattern used here (`registerPluginCliCommands()` called for all subcommand paths) should be applied to ensure all plugin CLI commands work correctly.
