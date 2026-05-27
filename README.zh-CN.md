# Codex Cursor Cleaner

**修复 Codex 启动慢、Cursor 卡顿、磁盘 I/O 飙高、`state.vscdb` 巨大、`logs_2.sqlite` 巨大、AI 对话历史/快照/worktree/cache 无限膨胀等问题。**

## 语言

- [English](README.md)
- [简体中文](README.zh-CN.md)
- [Español](README.es.md)
- [日本語](README.ja.md)
- [한국어](README.ko.md)

---

Codex Cursor Cleaner 是一个 Windows 一键维护脚本，专门用于清理 **Codex** 和 **Cursor** 在重度 AI 编程过程中产生的本地缓存、日志、快照、临时 worktree，以及异常膨胀的 SQLite 数据库。

如果你正在搜索这些问题，这个工具就是为这些问题准备的：

- Codex 启动很慢、打开卡住。
- Codex 用久了越来越卡。
- Codex 导致磁盘 I/O 飙高。
- `.codex/logs_2.sqlite` 膨胀到几百 MB 或数 GB。
- `.codex/worktrees` 有大量临时目录和几十万/上百万文件。
- Cursor 启动慢、卡顿、冻结、打开项目很慢。
- Cursor 在 SSD 上也频繁高磁盘 I/O。
- Cursor 的 `state.vscdb` 巨大，例如 1GB、5GB、10GB 甚至更大。
- Cursor 的 `state.vscdb.backup` 巨大。
- Cursor 的 `snapshots` 目录巨大。
- Cursor Composer / AI 对话 / checkpoint 历史持续膨胀。
- Windows 因为 AI IDE 缓存文件太多而变慢。

## Codex 和 Cursor 为什么会变卡？

高强度 AI 辅助开发会产生大量本地状态：

| 工具 | 常见膨胀来源 | 典型症状 |
| --- | --- | --- |
| Codex | `~/.codex/logs_2.sqlite` | 启动慢、磁盘写入高、SQLite 日志库巨大 |
| Codex | `~/.codex/worktrees` | 数十万文件，文件索引和扫描变慢 |
| Codex | `~/.codex/sessions` 和 `archived_sessions` | 对话历史 JSONL 文件巨大 |
| Codex | `.tmp/bundled-marketplaces/*.staging-*` | 重复临时 runtime 副本 |
| Cursor | `AppData/Roaming/Cursor/User/globalStorage/state.vscdb` | Cursor 卡顿，状态库巨大 |
| Cursor | `state.vscdb.backup` | 重复的多 GB 备份文件 |
| Cursor | `AppData/Roaming/Cursor/snapshots` | Git-like snapshot pack 巨大 |
| Cursor | `composer.content.*`、`agentKv:*`、`checkpointId:*`、`bubbleId:*` | AI 对话 / Composer / checkpoint 膨胀 |
| Cursor | `.cursor/worktrees` | 临时 worktree 和大量文件 |
| Cursor | 项目 `worker.log` | `.cursor/projects` 下日志过大 |

## 功能

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

## 默认清理策略

| 目标 | 默认行为 |
| --- | --- |
| 保留窗口 | 保留最近 14 天 |
| Codex 日志库 | 删除旧 TRACE/DEBUG；如果超过 256MB，则清空日志表 |
| Cursor 状态库 | 正常 vacuum；如果超过 1GB，则清理大型 AI 历史/检查点/Composer 键 |
| Codex/Cursor 正在运行 | 跳过数据库清理，避免文件锁或损坏 |

## 运行要求

- Windows
- PowerShell 5+ 或 PowerShell 7+
- Python 已加入 `PATH`，用于 SQLite 维护

## 使用方式

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

## 安全说明

本工具会删除本地缓存、日志、旧会话、旧 worktree、快照，以及异常膨胀的 AI 历史/缓存数据。它**不会修改你的项目代码仓库**。

如果你依赖长期保存 Codex/Cursor 聊天历史或 Cursor 快照，请先阅读脚本再运行。

## 搜索关键词

Codex 卡顿、Codex 启动慢、Codex 磁盘 I/O 高、Codex logs_2.sqlite 巨大、Codex worktrees 巨大、Cursor 卡顿、Cursor 启动慢、Cursor 冻结、Cursor 磁盘占用高、Cursor state.vscdb 巨大、Cursor snapshots 巨大、Cursor Composer 历史清理、AI IDE 缓存清理、Windows 开发工具缓存清理。
