<#
One-click maintenance for Codex and Cursor local cache/database bloat.

Default policy: remove data older than 14 days and vacuum databases.
If a known database grows beyond its safety threshold, clear its bulky AI history/cache keys.

Close Codex and Cursor before running this script.

What it does when the app is NOT running:
- Codex: clears/vacuums logs DB, vacuums state DB, removes old worktrees/sessions, removes staging temp runtimes, truncates logs.
- Cursor: removes cache/log/snapshot/backup/worktree bloat, clears AI history/checkpoint KV from state.vscdb, vacuums state and tracking DBs.

Logs are written to: %USERPROFILE%\Documents\cleanup-codex-cursor.log
#>

$ErrorActionPreference = 'Continue'

$RetentionDays = 14
$LargeSessionBytes = 100MB
$CursorStateDbMaxBytes = 1GB
$CodexLogsDbMaxBytes = 256MB
$AggressiveCursorAiHistoryCleanup = $false
$AggressiveCodexLogCleanup = $false

$HomeDir = [Environment]::GetFolderPath('UserProfile')
$LogFile = Join-Path $HomeDir 'Documents\cleanup-codex-cursor.log'
$Cutoff = (Get-Date).AddDays(-$RetentionDays)

function Log([string]$Message) {
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Add-Content -LiteralPath $LogFile -Value $line -Encoding UTF8
}

function Get-PathSize([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) { return 0 }
    if (-not $item.PSIsContainer) { return [int64]$item.Length }
    $sum = 0L
    Get-ChildItem -LiteralPath $Path -Force -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $sum += [int64]$_.Length }
    return $sum
}

function Remove-PathSafe([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    $size = Get-PathSize $Path
    Remove-Item -LiteralPath $Path -Force -Recurse -ErrorAction SilentlyContinue
    if (-not (Test-Path -LiteralPath $Path)) {
        Log "removed $size bytes: $Path"
        return $size
    }
    Log "WARN failed to remove: $Path"
    return 0
}

function Truncate-FileSafe([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        $size = Get-PathSize $Path
        try {
            [System.IO.File]::WriteAllBytes($Path, [byte[]]::new(0))
            Log "truncated $size bytes: $Path"
            return $size
        } catch {
            Log "WARN failed to truncate $Path : $($_.Exception.Message)"
        }
    }
    return 0
}

function Invoke-SqliteMaintenance([string]$DbPath, [string[]]$SqlStatements) {
    if (-not (Test-Path -LiteralPath $DbPath)) { return }
    $before = Get-PathSize $DbPath
    $py = @'
import sqlite3, sys
path = sys.argv[1]
statements = sys.argv[2:]
con = sqlite3.connect(path, timeout=60)
cur = con.cursor()
for sql in statements:
    if sql.strip():
        cur.execute(sql)
con.commit()
try:
    cur.execute('pragma wal_checkpoint(truncate)')
    cur.fetchall()
except Exception:
    pass
cur.execute('vacuum')
con.close()
'@
    try {
        $tmp = [System.IO.Path]::GetTempFileName() + '.py'
        Set-Content -LiteralPath $tmp -Value $py -Encoding UTF8
        & python $tmp $DbPath @SqlStatements | Out-Null
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
        $after = Get-PathSize $DbPath
        Log "sqlite maintained: $DbPath $before -> $after bytes"
    } catch {
        Log "WARN sqlite maintenance failed $DbPath : $($_.Exception.Message)"
    }
}

function Test-AnyProcess([string[]]$Patterns) {
    try {
        $procs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue
        foreach ($p in $procs) {
            $name = ''
            $commandLine = ''
            if ($null -ne $p.Name) { $name = [string]$p.Name }
            if ($null -ne $p.CommandLine) { $commandLine = [string]$p.CommandLine }
            $text = $name + ' ' + $commandLine
            foreach ($pattern in $Patterns) {
                if ($text -match $pattern) { return $true }
            }
        }
    } catch {}
    return $false
}

function Cleanup-Codex {
    $codex = Join-Path $HomeDir '.codex'
    if (-not (Test-Path -LiteralPath $codex)) { return }

    $running = Test-AnyProcess @('\\.codex', 'OpenAI\\Codex', 'CODEX_HOME', 'codex\.exe')
    if ($running) {
        Log 'Codex appears to be running; skip SQLite/worktree/session cleanup, only truncating plain logs.'
        Truncate-FileSafe (Join-Path $codex 'log\codex-tui.log') | Out-Null
        return
    }

    Log 'Codex cleanup start'
    Truncate-FileSafe (Join-Path $codex 'log\codex-tui.log') | Out-Null

    $logsDb = Join-Path $codex 'logs_2.sqlite'
    $logsDbSize = Get-PathSize $logsDb
    if ($AggressiveCodexLogCleanup -or $logsDbSize -gt $CodexLogsDbMaxBytes) {
        Invoke-SqliteMaintenance $logsDb @('delete from logs')
    } else {
        Invoke-SqliteMaintenance $logsDb @("delete from logs where level in ('TRACE','DEBUG')", "delete from logs where ts < strftime('%s','now','-$RetentionDays days')")
    }

    Invoke-SqliteMaintenance (Join-Path $codex 'state_5.sqlite') @()
    Invoke-SqliteMaintenance (Join-Path $codex 'goals_1.sqlite') @()

    $worktrees = Join-Path $codex 'worktrees'
    if (Test-Path -LiteralPath $worktrees) {
        Get-ChildItem -LiteralPath $worktrees -Force -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $Cutoff } |
            ForEach-Object { Remove-PathSafe $_.FullName | Out-Null }
    }

    foreach ($rel in @('sessions', 'archived_sessions')) {
        $base = Join-Path $codex $rel
        if (-not (Test-Path -LiteralPath $base)) { continue }
        Get-ChildItem -LiteralPath $base -Force -Recurse -File -Filter '*.jsonl' -ErrorAction SilentlyContinue | ForEach-Object {
            $delete = $false
            if ($_.LastWriteTime -lt $Cutoff) { $delete = $true }
            if ($_.Name -match '^rollout-(\d{4})-(\d{2})-(\d{2})T') {
                try {
                    $dt = Get-Date -Year ([int]$Matches[1]) -Month ([int]$Matches[2]) -Day ([int]$Matches[3]) -Hour 0 -Minute 0 -Second 0
                    if ($dt -lt $Cutoff.Date) { $delete = $true }
                } catch {}
            }
            if ($delete) { Remove-PathSafe $_.FullName | Out-Null }
        }
    }

    $bundled = Join-Path $codex '.tmp\bundled-marketplaces'
    if (Test-Path -LiteralPath $bundled) {
        Get-ChildItem -LiteralPath $bundled -Force -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like '*.staging-*' -or $_.LastWriteTime -lt $Cutoff } |
            ForEach-Object { Remove-PathSafe $_.FullName | Out-Null }
    }

    Log 'Codex cleanup done'
}

function Cleanup-Cursor {
    $cursorHome = Join-Path $HomeDir '.cursor'
    $cursorRoaming = Join-Path $HomeDir 'AppData\Roaming\Cursor'
    if (-not (Test-Path -LiteralPath $cursorHome) -and -not (Test-Path -LiteralPath $cursorRoaming)) { return }

    $running = Test-AnyProcess @('Cursor\.exe', 'cursor\.exe', 'AppData\\Local\\Programs\\cursor')
    if ($running) {
        Log 'Cursor appears to be running; skip Cursor cleanup.'
        return
    }

    Log 'Cursor cleanup start'

    $removePaths = @(
        (Join-Path $cursorRoaming 'User\globalStorage\state.vscdb.backup'),
        (Join-Path $cursorRoaming 'snapshots'),
        (Join-Path $cursorRoaming 'CachedData'),
        (Join-Path $cursorRoaming 'CachedExtensionVSIXs'),
        (Join-Path $cursorRoaming 'Cache'),
        (Join-Path $cursorRoaming 'GPUCache'),
        (Join-Path $cursorRoaming 'DawnGraphiteCache'),
        (Join-Path $cursorRoaming 'DawnWebGPUCache'),
        (Join-Path $cursorRoaming 'Code Cache'),
        (Join-Path $cursorRoaming 'logs'),
        (Join-Path $cursorRoaming 'process-monitor'),
        (Join-Path $cursorRoaming 'Service Worker\CacheStorage'),
        (Join-Path $cursorHome 'worktrees'),
        (Join-Path $cursorHome 'browser-logs')
    )
    foreach ($p in $removePaths) { Remove-PathSafe $p | Out-Null }

    Get-ChildItem -LiteralPath (Join-Path $cursorHome 'projects') -Force -Recurse -File -Filter '*.log' -ErrorAction SilentlyContinue |
        Where-Object { $_.Length -gt 1MB } |
        ForEach-Object { Truncate-FileSafe $_.FullName | Out-Null }

    $stateDb = Join-Path $cursorRoaming 'User\globalStorage\state.vscdb'
    $stateDbSize = Get-PathSize $stateDb
    if ($AggressiveCursorAiHistoryCleanup -or $stateDbSize -gt $CursorStateDbMaxBytes) {
        Invoke-SqliteMaintenance $stateDb @(
            "delete from cursorDiskKV where key like 'agentKv:%'",
            "delete from cursorDiskKV where key like 'checkpointId:%'",
            "delete from cursorDiskKV where key like 'bubbleId:%'",
            "delete from cursorDiskKV where key like 'composer.content.%'",
            "delete from cursorDiskKV where key like 'inlineDiff:%'",
            "delete from cursorDiskKV where key like 'ofsContent:%'",
            "delete from cursorDiskKV where key like 'composerData:%'",
            "delete from cursorDiskKV where length(value) > 1048576",
            "delete from ItemTable where key in ('composer.composerHeaders','composer.planRegistry')"
        )
    } else {
        Invoke-SqliteMaintenance $stateDb @()
    }

    Invoke-SqliteMaintenance (Join-Path $cursorHome 'ai-tracking\ai-code-tracking.db') @(
        'delete from tracked_file_content',
        'delete from conversation_summaries'
    )

    Log 'Cursor cleanup done'
}

Log 'maintenance start'
Cleanup-Codex
Cleanup-Cursor
Log 'maintenance done'
