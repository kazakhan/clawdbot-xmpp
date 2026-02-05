#!/usr/bin/env pwsh
#
# OpenClaw CLI Plugin Fix Deployment Script
# Applies patches to enable XMPP plugin commands and JID target recognition
#

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$patchFile = Join-Path $scriptDir "openclaw-cli-fix-2026-02-05.patch"

# Find openclaw installation
$openclawPath = $null
$locations = @(
    "$env:APPDATA\npm\node_modules\openclaw",
    "$env:LOCALAPPDATA\npm\node_modules\openclaw",
    "/usr/local/lib/node_modules/openclaw",
    "/usr/lib/node_modules/openclaw"
)

foreach ($loc in $locations) {
    if (Test-Path $loc) {
        $openclawPath = $loc
        break
    }
}

if (-not $openclawPath) {
    Write-Host "ERROR: Could not find openclaw installation" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure openclaw is installed:"
    Write-Host "  npm install -g openclaw"
    Write-Host ""
    Write-Host "Checked locations:"
    foreach ($loc in $locations) {
        Write-Host "  - $loc"
    }
    exit 1
}

Write-Host "Found openclaw at: $openclawPath" -ForegroundColor Green
Write-Host ""

# Verify patch file exists
if (-not (Test-Path $patchFile)) {
    Write-Host "ERROR: Patch file not found: $patchFile" -ForegroundColor Red
    exit 1
}

# Backup function
function Backup-File {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) { return }
    $backupFile = "$FilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $FilePath $backupFile
    Write-Host "  Backed up: $(Split-Path $FilePath -Leaf) -> $(Split-Path $backupFile -Leaf)" -ForegroundColor Yellow
}

# Patch function
function Apply-Patch {
    param(
        [string]$FilePath,
        [string]$OldPattern,
        [string]$NewPattern,
        [string]$Description
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "  SKIP: $(Split-Path $FilePath -Leaf) not found" -ForegroundColor Gray
        return
    }
    
    Backup-File $FilePath
    
    $content = Get-Content $FilePath -Raw
    $newContent = $content -replace [regex]::Escape($OldPattern), $NewPattern
    
    if ($newContent -eq $content) {
        Write-Host "  ERROR: Pattern not found in $(Split-Path $FilePath -Leaf)" -ForegroundColor Red
        Write-Host "  Description: $Description"
        return
    }
    
    $newContent | Set-Content $FilePath
    Write-Host "  PATCHED: $(Split-Path $FilePath -Leaf)" -ForegroundColor Green
}

Write-Host "Applying OpenClaw CLI Plugin Fix..." -ForegroundColor Cyan
Write-Host ""

# Define patches
$registerSubclisPath = Join-Path $openclawPath "dist\cli\program\register.subclis.js"
$targetResolverPath = Join-Path $openclawPath "dist\infra\outbound\target-resolver.js"

# PATCH 1: Add plugin registration for channels
$oldPattern1 = @'
  {
    name: "channels",
    description: "Channel management",
    register: async (program) => {
      const mod = await import("../channels-cli.js");
      mod.registerChannelsCli(program);
    },
  },
'@

$newPattern1 = @'
  {
    name: "channels",
    description: "Channel management",
    register: async (program) => {
      const mod = await import("../channels-cli.js");
      mod.registerChannelsCli(program);
      // Register plugin CLI commands so channels like 'xmpp' work
      const { registerPluginCliCommands } = await import("../../plugins/cli.js");
      registerPluginCliCommands(program, await loadConfig());
    },
  },
'@

Write-Host "Patch 1: Register plugins for channels subcommand"
Apply-Patch -FilePath $registerSubclisPath -OldPattern $oldPattern1 -NewPattern $newPattern1 -Description "Add registerPluginCliCommands to channels"

# PATCH 2: Make async and call registerPluginCliCommands at end
$oldPattern2 = @'
export function registerSubCliCommands(program: Command, argv: string[] = process.argv) {
  if (shouldEagerRegisterSubcommands(argv)) {
    for (const entry of entries) {
      void entry.register(program);
    }
    return;
  }
  const primary = getPrimaryCommand(argv);
  if (primary && shouldRegisterPrimaryOnly(argv)) {
    const entry = entries.find((candidate) => candidate.name === primary);
    if (entry) {
      registerLazyCommand(program, entry);
      return;
    }
  }
  for (const candidate of entries) {
    registerLazyCommand(program, candidate);
  }
}
'@

$newPattern2 = @'
export async function registerSubCliCommands(program: Command, argv: string[] = process.argv) {
  if (shouldEagerRegisterSubcommands(argv)) {
    for (const entry of entries) {
      void entry.register(program);
    }
    return;
  }
  const primary = getPrimaryCommand(argv);
  if (primary && shouldRegisterPrimaryOnly(argv)) {
    const entry = entries.find((candidate) => candidate.name === primary);
    if (entry) {
      registerLazyCommand(program, entry);
      return;
    }
  }
  for (const candidate of entries) {
    registerLazyCommand(program, candidate);
  }
  // Register plugin CLI commands for lazy-loaded subcommands
  const { registerPluginCliCommands } = await import("../../plugins/cli.js");
  registerPluginCliCommands(program, await loadConfig());
}
'@

Write-Host ""
Write-Host "Patch 2: Make registerSubCliCommands async and register plugins"
Apply-Patch -FilePath $registerSubclisPath -OldPattern $oldPattern2 -NewPattern $newPattern2 -Description "Make function async and add plugin registration"

# PATCH 3: Add XMPP JID pattern
$oldPattern3 = @'
    if (/^(conversation|user):/i.test(trimmed)) {
      return true;
    }
    return false;
'@

$newPattern3 = @'
    if (/^(conversation|user):/i.test(trimmed)) {
      return true;
    }
    // XMPP JID pattern: user@domain format (e.g., jamie@kazakhan.com)
    if (/^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(trimmed)) {
      return true;
    }
    return false;
'@

Write-Host ""
Write-Host "Patch 3: Add XMPP JID pattern recognition"
Apply-Patch -FilePath $targetResolverPath -OldPattern $oldPattern3 -NewPattern $newPattern3 -Description "Add XMPP JID pattern to looksLikeTargetId"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Patches applied successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To verify, run:"
Write-Host "  1. openclaw xmpp --help"
Write-Host "  2. openclaw xmpp msg <jid> 'test'"
Write-Host ""
Write-Host "To rollback:"
Write-Host "  Delete patched files and run: npm install -g openclaw@latest"
Write-Host ""
