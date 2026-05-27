# Codex Cursor Cleaner

**Windows에서 Codex 시작이 느리거나 Cursor가 버벅이고, 디스크 I/O가 높거나 `state.vscdb`, `logs_2.sqlite`, snapshots, worktrees, 캐시가 과도하게 커지는 문제를 정리합니다.**

## Languages

- [English](README.md)
- [简体中文](README.zh-CN.md)
- [Español](README.es.md)
- [日本語](README.ja.md)
- [한국어](README.ko.md)

---

Codex Cursor Cleaner는 **Codex**와 **Cursor**가 생성하는 로컬 캐시, 로그, 스냅샷, 임시 worktree, 과도하게 커진 SQLite 데이터베이스를 정리하는 Windows용 원클릭 스크립트입니다.

다음 문제를 해결하기 위해 만들었습니다.

- Codex 시작이 느리거나 멈춤.
- Codex가 대화가 많아질수록 느려짐.
- Codex 디스크 I/O가 높음.
- `.codex/logs_2.sqlite`가 수백 MB 또는 여러 GB로 커짐.
- `.codex/worktrees`에 임시 파일이 너무 많음.
- Cursor가 느리거나 멈추거나 프로젝트 열기가 오래 걸림.
- SSD에서도 Cursor 디스크 사용량이 높음.
- `Cursor/User/globalStorage/state.vscdb`가 매우 큼.
- `state.vscdb.backup`가 매우 큼.
- Cursor `snapshots` 폴더가 매우 큼.
- Composer / AI 채팅 / checkpoint 기록이 계속 증가함.

## 일반적인 원인

| 도구 | 커지는 위치 | 증상 |
| --- | --- | --- |
| Codex | `~/.codex/logs_2.sqlite` | 시작 느림, SQLite 로그 DB 비대화 |
| Codex | `~/.codex/worktrees` | 임시 파일이 너무 많음 |
| Codex | `sessions` / `archived_sessions` | JSONL 대화 기록이 큼 |
| Cursor | `state.vscdb` | Cursor 느림, 상태 DB 비대화 |
| Cursor | `state.vscdb.backup` | 여러 GB 백업 파일 |
| Cursor | `snapshots` | snapshot pack 비대화 |
| Cursor | `composer.content.*`, `agentKv:*`, `checkpointId:*`, `bubbleId:*` | AI 기록 및 checkpoint 증가 |

## 사용 방법

1. Codex와 Cursor를 종료합니다.
2. `run-cleanup.bat`를 더블 클릭합니다.
3. 필요한 경우 로그를 확인합니다.

```text
%USERPROFILE%\Documents\cleanup-codex-cursor.log
```

PowerShell에서도 실행할 수 있습니다.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\cleanup-codex-cursor.ps1
```

## 기본 정책

- 최근 14일 데이터는 보존합니다.
- SQLite 데이터베이스를 `VACUUM`으로 압축합니다.
- `logs_2.sqlite`가 256MB를 넘으면 로그 테이블을 정리합니다.
- `state.vscdb`가 1GB를 넘으면 큰 AI 기록/캐시 키를 정리합니다.
- Codex 또는 Cursor가 실행 중이면 위험한 정리는 건너뜁니다.

## 안전 안내

이 스크립트는 로컬 캐시, 로그, 오래된 세션, 오래된 worktree, 스냅샷, 큰 AI 기록/캐시 데이터를 삭제합니다. 프로젝트 Git 저장소는 수정하지 않습니다.
