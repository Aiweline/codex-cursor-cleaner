# Codex Cursor Cleaner

**Fix Codex slow startup, Cursor lag, high disk I/O, huge `state.vscdb`, huge `logs_2.sqlite`, bloated AI chat history, snapshots, worktrees, and cache files on Windows.**

## Languages

- [English](README.md)
- [简体中文](README.zh-CN.md)
- [Español](README.es.md)
- [日本語](README.ja.md)
- [한국어](README.ko.md)

---

## English

Codex Cursor Cleaner is a one-click Windows maintenance script for developers using AI coding tools heavily. It cleans local cache, logs, snapshots, temporary worktrees, and oversized SQLite databases created by **Codex** and **Cursor**.

If you searched for any of these problems, this tool is for you:

- Codex is very slow or stuck on startup.
- Codex becomes laggy after many conversations.
- Codex consumes high disk I/O.
- `.codex/logs_2.sqlite` grows to hundreds of MB or multiple GB.
- `.codex/worktrees` contains many temporary directories and hundreds of thousands of files.
- Cursor is slow, freezes, or takes a long time to open.
- Cursor uses high disk I/O even on an SSD.
- Cursor `state.vscdb` is huge, for example 1GB, 5GB, 10GB, or more.
- Cursor `state.vscdb.backup` is huge.
- Cursor `snapshots` folder is huge.
- Cursor Composer / AI chat / checkpoint history keeps growing.
- Windows feels slow because AI IDE cache files are constantly scanned or indexed.

## What causes Codex and Cursor to become slow?

Heavy AI-assisted development can create a lot of local state:

| Tool | Common bloat source | Typical symptom |
| --- | --- | --- |
| Codex | `~/.codex/logs_2.sqlite` | Slow startup, high disk writes, huge SQLite log DB |
| Codex | `~/.codex/worktrees` | Hundreds of thousands of files, slow file indexing |
| Codex | `~/.codex/sessions` and `archived_sessions` | Huge conversation history JSONL files |
| Codex | `.tmp/bundled-marketplaces/*.staging-*` | Duplicate temporary runtime copies |
| Cursor | `AppData/Roaming/Cursor/User/globalStorage/state.vscdb` | Cursor lag, large SQLite state DB |
| Cursor | `state.vscdb.backup` | Duplicate multi-GB backup file |
| Cursor | `AppData/Roaming/Cursor/snapshots` | Huge Git-like snapshot packs |
| Cursor | `composer.content.*`, `agentKv:*`, `checkpointId:*`, `bubbleId:*` | AI chat / Composer / checkpoint data bloat |
| Cursor | `.cursor/worktrees` | Temporary worktrees and many files |
| Cursor | project `worker.log` files | Large logs in `.cursor/projects` |

## Features

- Cleans Codex local bloat:
  - `~/.codex/logs_2.sqlite`
  - `~/.codex/state_5.sqlite`
  - old `worktrees`
  - old `sessions` / `archived_sessions`
  - staging marketplace temp folders
  - plain log files
- Cleans Cursor local bloat:
  - `AppData/Roaming/Cursor/User/globalStorage/state.vscdb`
  - `state.vscdb.backup`
  - snapshots
  - cache folders
  - process monitor data
  - `.cursor/worktrees`
  - large project worker logs
  - `.cursor/ai-tracking/ai-code-tracking.db`
- Runs SQLite `VACUUM` to compact databases.
- Keeps recent data by default: removes old session/worktree data older than 14 days.
- Prevents unlimited growth: if known databases exceed safety thresholds, bulky AI history/cache keys are cleared.
- Skips risky cleanup if Codex or Cursor is currently running.
- Writes a log to `%USERPROFILE%\Documents\cleanup-codex-cursor.log`.

## Default cleanup policy

| Target | Default behavior |
| --- | --- |
| Retention window | Keep recent 14 days |
| Codex logs DB | Delete old TRACE/DEBUG logs; if over 256MB, clear log table |
| Cursor state DB | Vacuum normally; if over 1GB, clear bulky AI history/checkpoint/composer keys |
| Codex/Cursor process running | Skip database cleanup to avoid locked/corrupted files |

## Requirements

- Windows
- PowerShell 5+ or PowerShell 7+
- Python available in `PATH` for SQLite maintenance

## Usage

1. Close Codex and Cursor.
2. Double-click `run-cleanup.bat`.
3. Check the log file if needed:

```text
%USERPROFILE%\Documents\cleanup-codex-cursor.log
```

You can also run it from PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\cleanup-codex-cursor.ps1
```

## Safety notes

This tool deletes local caches, logs, old sessions, old worktrees, snapshots, and oversized AI history/cache data. It does **not** modify your project repositories.

If you rely on long-term Codex/Cursor chat history or Cursor snapshots, review the script before running it.

## Keywords

Codex slow, Codex lag, Codex high disk usage, Codex logs_2.sqlite huge, Codex worktrees huge, Cursor slow, Cursor lag, Cursor freezes, Cursor high disk usage, Cursor state.vscdb huge, Cursor snapshots huge, Cursor Composer history cleanup, AI IDE cache cleaner, Windows developer cache cleaner.
