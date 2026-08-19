# Plugin smoke gates (CLOVER-style: cumulative, fast, evidence-shaped)
# Each gate: {id, command, expected, observed, verdict}
# Run: pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\plugin-smoke.ps1
# Exit code: 0 = all gates pass, 1 = at least one gate failed (print gate id).
$ErrorActionPreference = 'Continue'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo   # tsx/esm --import resolves from cwd
$profileDir = Join-Path $env:USERPROFILE '.dsh\profiles\web'
$env:PATH = "$repo\.portable;$env:APPDATA\npm;" + $env:PATH
$script:failures = 0
$script:dumpOut = ''

function Run-Gate {
    param(
        [string]$Id,
        [scriptblock]$Body,
        [string]$Expected,
        [object]$Actual,
        [string]$Invariant
    )
    $pass = $false
    try {
        $pass = & $Body
    } catch {
        $pass = $false
    }
    $verdict = if ($pass) { 'PASS' } else { 'FAIL' }
    if (-not $pass) { $script:failures++ }
    Write-Host ("{0}  {1}" -f $verdict, $Id)
    Write-Host ("      invariant: {0}" -f $Invariant)
    Write-Host ("      expected : {0}" -f $Expected)
    Write-Host ("      observed : {0}" -f $Actual)
    Write-Host ''
}

# --- Gate 1: profile manifest declares both plugin bundles (schema check) ---
$manifest = Get-Content (Join-Path $profileDir 'package.json') -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
$bundles = @($manifest.dsh.profile.bundles)
Run-Gate 'plugins.bundles-declared' {
    ($bundles -contains 'dsh-context-doctor') -and ($bundles -contains 'billion-context-dsh')
} 'bundles contains dsh-context-doctor AND billion-context-dsh' `
    ($bundles -join ', ') `
    'Installed plugins must join the profile layer stack (dsh plugin reconcile).'

# --- Gate 2: node_modules links resolve into this repo folder (local-applied invariant) ---
Run-Gate 'plugins.links-into-repo' {
    (Test-Path (Join-Path $profileDir 'node_modules\dsh-context-doctor')) -and
    (Test-Path (Join-Path $profileDir 'node_modules\billion-context-dsh'))
} 'both plugin junctions exist under profile node_modules' `
    ((Get-Item (Join-Path $profileDir 'node_modules\dsh-context-doctor') -ErrorAction SilentlyContinue).Target + ' | ' +
     (Get-Item (Join-Path $profileDir 'node_modules\billion-context-dsh') -ErrorAction SilentlyContinue).Target) `
    'Plugins must be applied from the repo folder (link spec), not from an external copy.'

# --- Dump-config once, reuse for gates 3-5 (one expensive call) ---
$script:dumpOut = (& node --import tsx/esm "$repo\apps\cli\src\bin.ts" --profile web --dump-config 2>&1 | Out-String)

# --- Gate 3: composed config mounts compaction-acp (the ACP backend) ---
Run-Gate 'plugins.compaction-acp-mounted' {
    $script:dumpOut -match 'compaction-acp' -and $script:dumpOut -match 'name: billion-context-dsh'
} 'dump-config contains "compaction-acp" + "name: billion-context-dsh"' `
    ((($script:dumpOut -split "`n" | Select-String -Pattern 'compaction-acp|name: billion' | Select-Object -First 4) -join '; ').Trim()) `
    'The ACP compaction backend must mount from the inserted bundle layer.'

# --- Gate 4: composed config mounts context-doctor (audit tool layer) ---
Run-Gate 'plugins.context-doctor-mounted' {
    $script:dumpOut -match 'id: context-doctor' -and $script:dumpOut -match 'name: dsh-context-doctor'
} 'dump-config contains "id: context-doctor" + "name: dsh-context-doctor"' `
    ((($script:dumpOut -split "`n" | Select-String -Pattern 'id: context-doctor|name: dsh-context' | Select-Object -First 4) -join '; ').Trim()) `
    'The context audit layer must mount from its bundle layer.'

# --- Gate 5: compaction-basic stays disabled (no dual-backend conflict) ---
Run-Gate 'plugins.compaction-basic-disabled' {
    $script:dumpOut -match 'id: compaction-basic' -and $script:dumpOut -match 'disabled: true'
} 'dump-config shows compaction-basic with disabled: true' `
    ((($script:dumpOut -split "`n" | Select-String -Pattern 'id: compaction-basic|disabled: true' | Select-Object -First 4) -join '; ').Trim()) `
    'Two ctx.compaction backends in one realm conflict; basic must stay disabled.'

# --- Gate 6: billion-context-dsh dist is committed (new-machine reproducible) ---
Run-Gate 'plugins.dist-committed' {
    (Test-Path (Join-Path $repo 'plugins\billion-context-dsh\dist\index.js')) -and
    (& git -C $repo ls-files 'plugins/billion-context-dsh/dist/index.js' 2>$null) -ne ''
} 'dist/index.js exists on disk AND is tracked by git' `
    ("exists=" + (Test-Path (Join-Path $repo 'plugins\billion-context-dsh\dist\index.js')) + ', tracked=' +
     ((& git -C $repo ls-files 'plugins/billion-context-dsh/dist/index.js' 2>$null) -join '')) `
    'dist is gitignored upstream; a clone must not need a rebuild, so it must be force-added.'

Write-Host ('== RESULT: ' + $(if ($script:failures -eq 0) { 'ALL GATES PASS (6/6)' } else { "$($script:failures) gate(s) FAILED" }) + ' ==')
exit $(if ($script:failures -eq 0) { 0 } else { 1 })