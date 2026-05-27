# Codex Cursor Cleaner

[简体中文](#简体中文) | [English](#english)

---

## English

A one-click Windows maintenance script for cleaning local cache, logs, snapshots, and oversized SQLite databases created by Codex and Cursor.

It is designed for developers who use AI coding tools heavily and eventually see their disk I/O become slow because local history, logs, worktrees, snapshots, and AI state databases grow into many gigabytes.

### Features

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

### Default policy

| Target | Default behavior |
| --- | --- |
| Retention window | Keep recent 14 days |
| Codex logs DB | Delete old TRACE/DEBUG logs; if over 256MB, clear log table |
| Cursor state DB | Vacuum normally; if over 1GB, clear bulky AI history/checkpoint/composer keys |
| Codex/Cursor process running | Skip database cleanup to avoid locked/corrupted files |

### Requirements

- Windows
- PowerShell 5+ or PowerShell 7+
- Python available in `PATH` for SQLite maintenance

### Usage

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

### Safety notes

This tool deletes local caches, logs, old sessions, old worktrees, snapshots, and oversized AI history/cache data. It does not touch your project repositories.

If you rely on long-term Codex/Cursor chat history or Cursor snapshots, review the script before running it.

### Why this exists

In heavy AI-assisted development workflows, Codex and Cursor may accumulate:

- multi-GB SQLite log/state databases,
- hundreds of thousands of temporary worktree files,
- large Cursor snapshot packs,
- large Composer/AI checkpoint blobs.

These can cause disk I/O stalls and make the tools feel slow even on fast machines.

---

## 简体中文

一个 Windows 一键维护脚本，用于清理 Codex 和 Cursor 在本地累积的缓存、日志、快照、临时 worktree，以及异常膨胀的 SQLite 数据库。

它适合重度使用 AI 编程工具的开发者：当本地历史、日志、worktree、快照、AI 状态数据库膨胀到数 GB 甚至几十 GB 时，磁盘 I/O 会被拖慢，工具也会变卡。

### 功能

- 清理 Codex 本地膨胀文件：
  - `~/.codex/logs_2.sqlite`
  - `~/.codex/state_5.sqlite`
  - 旧 `worktrees`
  - 旧 `sessions` / `archived_sessions`
  - staging marketplace 临时目录
  - 普通日志文件
- 清理 Cursor 本地膨胀文件：
  - `AppData/Roaming/Cursor/User/globalStorage/state.vscdb`
  - `state.vscdb.backup`
  - snapshots
  - 缓存目录
  - process monitor 数据
  - `.cursor/worktrees`
  - 大型项目 worker 日志
  - `.cursor/ai-tracking/ai-code-tracking.db`
- 对 SQLite 数据库执行 `VACUUM` 压缩。
- 默认保留最近数据：只清理 14 天前的旧 session/worktree。
- 防止无限膨胀：当已知数据库超过安全阈值时，清理大体积 AI 历史/检查点/Composer 缓存键。
- 如果检测到 Codex 或 Cursor 正在运行，会跳过风险较高的数据库清理。
- 日志写入：`%USERPROFILE%\Documents\cleanup-codex-cursor.log`。

### 默认策略

| 目标 | 默认行为 |
| --- | --- |
| 保留窗口 | 保留最近 14 天 |
| Codex 日志库 | 删除旧 TRACE/DEBUG；如果超过 256MB，则清空日志表 |
| Cursor 状态库 | 正常 vacuum；如果超过 1GB，则清理大型 AI 历史/检查点/Composer 键 |
| Codex/Cursor 正在运行 | 跳过数据库清理，避免文件锁或损坏 |

### 运行要求

- Windows
- PowerShell 5+ 或 PowerShell 7+
- Python 已加入 `PATH`，用于 SQLite 维护

### 使用方式

1. 先关闭 Codex 和 Cursor。
2. 双击 `run-cleanup.bat`。
3. 如需查看日志：

```text
%USERPROFILE%\Documents\cleanup-codex-cursor.log
```

也可以在 PowerShell 中运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\cleanup-codex-cursor.ps1
```

### 安全说明

本工具会删除本地缓存、日志、旧会话、旧 worktree、快照，以及异常膨胀的 AI 历史/缓存数据。它不会修改你的项目代码仓库。

如果你依赖长期保存 Codex/Cursor 聊天历史或 Cursor 快照，请先阅读脚本再运行。

### 为什么需要它

在高强度 AI 辅助开发工作流中，Codex 和 Cursor 可能持续累积：

- 多 GB 的 SQLite 日志/状态数据库；
- 数十万甚至上百万个临时 worktree 文件；
- 大量 Cursor snapshot pack；
- 大体积 Composer / AI checkpoint blob。

这些文件会造成磁盘 I/O 阻塞，让工具在高性能机器上也变得卡顿。
