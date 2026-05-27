# Codex Cursor Cleaner

**Windows で Codex の起動が遅い、Cursor が重い、ディスク I/O が高い、`state.vscdb` や `logs_2.sqlite` が巨大化する問題を解決するためのクリーナーです。**

## Languages

- [English](README.md)
- [简体中文](README.zh-CN.md)
- [Español](README.es.md)
- [日本語](README.ja.md)
- [한국어](README.ko.md)

---

Codex Cursor Cleaner は、**Codex** と **Cursor** が作成するローカルキャッシュ、ログ、スナップショット、一時 worktree、肥大化した SQLite データベースを整理する Windows 用ワンクリックスクリプトです。

次のような問題を解決するために作られています。

- Codex の起動が遅い、または固まる。
- Codex が会話を重ねるほど重くなる。
- Codex のディスク I/O が高い。
- `.codex/logs_2.sqlite` が数百 MB または数 GB に膨らむ。
- `.codex/worktrees` に大量の一時ファイルがある。
- Cursor が重い、固まる、プロジェクトを開くのが遅い。
- SSD でも Cursor のディスク使用率が高い。
- `Cursor/User/globalStorage/state.vscdb` が巨大化している。
- `state.vscdb.backup` が巨大化している。
- Cursor の `snapshots` フォルダが巨大化している。
- Composer / AI チャット / checkpoint 履歴が増え続ける。

## 主な原因

| ツール | 肥大化しやすい場所 | 典型的な症状 |
| --- | --- | --- |
| Codex | `~/.codex/logs_2.sqlite` | 起動が遅い、SQLite ログ DB が大きい |
| Codex | `~/.codex/worktrees` | 一時ファイルが多すぎる |
| Codex | `sessions` / `archived_sessions` | JSONL 会話履歴が大きい |
| Cursor | `state.vscdb` | Cursor が重い、状態 DB が大きい |
| Cursor | `state.vscdb.backup` | マルチ GB のバックアップ |
| Cursor | `snapshots` | snapshot pack が大きい |
| Cursor | `composer.content.*`, `agentKv:*`, `checkpointId:*`, `bubbleId:*` | AI 履歴と checkpoint の肥大化 |

## 使い方

1. Codex と Cursor を終了します。
2. `run-cleanup.bat` をダブルクリックします。
3. 必要に応じてログを確認します。

```text
%USERPROFILE%\Documents\cleanup-codex-cursor.log
```

PowerShell から実行することもできます。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\cleanup-codex-cursor.ps1
```

## デフォルトポリシー

- 直近 14 日分を保持します。
- SQLite を `VACUUM` で圧縮します。
- `logs_2.sqlite` が 256MB を超える場合、ログテーブルを削除します。
- `state.vscdb` が 1GB を超える場合、大きな AI 履歴/キャッシュキーを削除します。
- Codex または Cursor が実行中の場合、危険なクリーンアップはスキップします。

## 安全上の注意

このスクリプトはローカルキャッシュ、ログ、古いセッション、古い worktree、スナップショット、大きな AI 履歴/キャッシュデータを削除します。プロジェクトの Git リポジトリは変更しません。
