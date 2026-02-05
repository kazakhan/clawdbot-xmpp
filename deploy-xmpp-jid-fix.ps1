#!/usr/bin/env pwsh
#
# Deploy XMPP JID Target Fix
# This script patches openclaw to recognize XMPP JIDs as valid targets
#

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$patchFile = Join-Path $scriptDir "xmpp-jid-target-fix.patch"
$prFile = Join-Path $scriptDir "pr.md"

# Find openclaw installation
$openclawPath = $null

# Check common locations
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

# Backup original file
$targetFile = Join-Path $openclawPath "dist\infra\outbound\target-resolver.js"
$backupFile = "$targetFile.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "Backing up original file..." -ForegroundColor Yellow
Copy-Item $targetFile $backupFile
Write-Host "  Backup: $backupFile"
Write-Host ""

# Apply patch
Write-Host "Applying patch..." -ForegroundColor Yellow

# Try git apply first
$gitResult = git apply --ignore-whitespace $patchFile 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Patch applied successfully via git" -ForegroundColor Green
} else {
    Write-Host "  Git apply failed, applying manually..." -ForegroundColor Yellow

    # Manual patch application
    $content = Get-Content $targetFile -Raw

    # Find the looksLikeTargetId function and add JID pattern
    $pattern = 'if \(/^\(conversation\|user\):/i\.test\(trimmed\)\) \{[\s\S]*?return true;[\s\S]*?\}'
    $replacement = @'
if (/^(conversation|user):/i.test(trimmed)) {
      return true;
    }
    // XMPP JID pattern: user@domain format (e.g., jamie@kazakhan.com)
    if (/^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(trimmed)) {
      return true;
    }
'@

    $newContent = $content -replace $pattern, $replacement

    if ($newContent -eq $content) {
        Write-Host "ERROR: Could not find pattern to patch" -ForegroundColor Red
        Write-Host "Restoring backup..." -ForegroundColor Yellow
        Copy-Item $backupFile $targetFile
        exit 1
    }

    $newContent | Set-Content $targetFile
    Write-Host "  Patch applied manually" -ForegroundColor Green
}

Write-Host ""
Write-Host "Restarting gateway..." -ForegroundColor Yellow

# Try to restart the gateway
try {
    # Stop if running
    openclaw gateway stop 2>&1 | Out-Null

    # Start gateway
    Start-Process -NoNewWindow openclaw gateway

    Write-Host "  Gateway restarted" -ForegroundColor Green
} catch {
    Write-Host "  Could not restart gateway automatically" -ForegroundColor Yellow
    Write-Host "  Please run: openclaw gateway stop && openclaw gateway" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Testing fix..." -ForegroundColor Yellow

# Quick test
$testResult = openclaw xmpp status 2>&1 | Out-String
if ($testResult -match "Connected|XMPP client") {
    Write-Host "  XMPP plugin responding correctly" -ForegroundColor Green
} else {
    Write-Host "  Warning: Could not verify XMPP status" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Patch applied successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backup location: $backupFile"
Write-Host ""
Write-Host "To rollback:"
Write-Host "  Copy-Item '$backupFile' '$targetFile'"
Write-Host "  openclaw gateway restart"
Write-Host ""
