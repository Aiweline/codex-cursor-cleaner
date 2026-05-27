# Codex Cursor Cleaner

**Fix Codex slow startup, Cursor lag, high disk I/O, huge `state.vscdb`, huge `logs_2.sqlite`, bloated AI chat history, snapshots, worktrees, and cache files on Windows.**

**修复 Codex 启动慢、Cursor 卡顿、磁盘 I/O 飙高、`state.vscdb` 巨大、`logs_2.sqlite` 巨大、AI 对话历史/快照/worktree/cache 无限膨胀等问题。**

[English](#english) | [简体中文](#简体中文) | [Español](#español) | [日本語](#日本語) | [한국어](#한국어)

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

### What causes Codex and Cursor to become slow?

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

### Default cleanup policy

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

This tool deletes local caches, logs, old sessions, old worktrees, snapshots, and oversized AI history/cache data. It does **not** modify your project repositories.

If you rely on long-term Codex/Cursor chat history or Cursor snapshots, review the script before running it.

### Keywords

Codex slow, Codex lag, Codex high disk usage, Codex logs_2.sqlite huge, Codex worktrees huge, Cursor slow, Cursor lag, Cursor freezes, Cursor high disk usage, Cursor state.vscdb huge, Cursor snapshots huge, Cursor Composer history cleanup, AI IDE cache cleaner, Windows developer cache cleaner.

---

## 简体中文

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

### Codex 和 Cursor 为什么会变卡？

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

### 默认清理策略

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

本工具会删除本地缓存、日志、旧会话、旧 worktree、快照，以及异常膨胀的 AI 历史/缓存数据。它**不会修改你的项目代码仓库**。

如果你依赖长期保存 Codex/Cursor 聊天历史或 Cursor 快照，请先阅读脚本再运行。

### 搜索关键词

Codex 卡顿、Codex 启动慢、Codex 磁盘 I/O 高、Codex logs_2.sqlite 巨大、Codex worktrees 巨大、Cursor 卡顿、Cursor 启动慢、Cursor 冻结、Cursor 磁盘占用高、Cursor state.vscdb 巨大、Cursor snapshots 巨大、Cursor Composer 历史清理、AI IDE 缓存清理、Windows 开发工具缓存清理。

---

## Español

Codex Cursor Cleaner es un script de mantenimiento para Windows que limpia cachés, logs, snapshots, worktrees temporales y bases SQLite demasiado grandes creadas por Codex y Cursor.

Úsalo si Codex o Cursor se vuelven lentos, si `logs_2.sqlite` o `state.vscdb` crecen demasiado, o si el disco muestra I/O alto por archivos locales de herramientas de IA.

### Problemas que ayuda a resolver

- Codex lento al iniciar.
- Codex con alto uso de disco.
- `.codex/logs_2.sqlite` demasiado grande.
- `.codex/worktrees` con demasiados archivos.
- Cursor lento, congelado o tardando mucho al abrir proyectos.
- `Cursor/User/globalStorage/state.vscdb` demasiado grande.
- `state.vscdb.backup` y `snapshots` demasiado grandes.
- Historial de Composer, chat de IA y checkpoints creciendo sin límite.

### Uso

1. Cierra Codex y Cursor.
2. Haz doble clic en `run-cleanup.bat`.
3. Revisa el log en:

```text
%USERPROFILE%\Documents\cleanup-codex-cursor.log
```

La política predeterminada conserva los últimos 14 días y compacta las bases SQLite. Si una base conocida supera el umbral de seguridad, se limpian claves grandes de historial/caché de IA.

---

## 日本語

Codex Cursor Cleaner は、Codex と Cursor が作成するローカルキャッシュ、ログ、スナップショット、一時 worktree、肥大化した SQLite データベースを整理する Windows 用ワンクリックスクリプトです。

Codex の起動が遅い、Cursor が重い、`logs_2.sqlite` や `state.vscdb` が巨大化している、ディスク I/O が高い、という問題に対応します。

### 対応する症状

- Codex の起動が遅い。
- Codex のディスク使用率が高い。
- `.codex/logs_2.sqlite` が巨大化している。
- `.codex/worktrees` に大量のファイルがある。
- Cursor が重い、固まる、プロジェクトを開くのが遅い。
- `Cursor/User/globalStorage/state.vscdb` が巨大化している。
- `state.vscdb.backup` や `snapshots` が大きすぎる。
- Composer / AI チャット / checkpoint 履歴が増え続ける。

### 使い方

1. Codex と Cursor を終了します。
2. `run-cleanup.bat` をダブルクリックします。
3. ログは以下に出力されます。

```text
%USERPROFILE%\Documents\cleanup-codex-cursor.log
```

デフォルトでは直近 14 日分を保持し、SQLite データベースを `VACUUM` で圧縮します。既知のデータベースが安全しきい値を超えた場合、大きな AI 履歴/キャッシュキーを削除します。

---

## 한국어

Codex Cursor Cleaner는 Codex와 Cursor가 생성하는 로컬 캐시, 로그, 스냅샷, 임시 worktree, 과도하게 커진 SQLite 데이터베이스를 정리하는 Windows용 원클릭 스크립트입니다.

Codex 시작이 느리거나 Cursor가 버벅이거나, `logs_2.sqlite` / `state.vscdb`가 너무 커졌거나, AI 개발 도구 때문에 디스크 I/O가 높아지는 경우에 사용할 수 있습니다.

### 해결하는 문제

- Codex 시작이 느림.
- Codex 디스크 I/O가 높음.
- `.codex/logs_2.sqlite`가 매우 큼.
- `.codex/worktrees`에 파일이 너무 많음.
- Cursor가 느리거나 멈춤.
- `Cursor/User/globalStorage/state.vscdb`가 매우 큼.
- `state.vscdb.backup` 및 `snapshots`가 너무 큼.
- Composer / AI 채팅 / checkpoint 기록이 계속 증가함.

### 사용 방법

1. Codex와 Cursor를 종료합니다.
2. `run-cleanup.bat`를 더블 클릭합니다.
3. 로그 파일 위치:

```text
%USERPROFILE%\Documents\cleanup-codex-cursor.log
```

기본 정책은 최근 14일 데이터를 보존하고 SQLite 데이터베이스를 `VACUUM`으로 압축합니다. 알려진 데이터베이스가 안전 임계값을 넘으면 큰 AI 기록/캐시 키를 정리합니다.
