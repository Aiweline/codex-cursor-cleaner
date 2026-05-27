# Codex Cursor Cleaner

**Soluciona Codex lento, Cursor con lag, alto I/O de disco, `state.vscdb` enorme, `logs_2.sqlite` enorme, historial de IA, snapshots, worktrees y cachés inflados en Windows.**

## Idiomas

- [English](README.md)
- [简体中文](README.zh-CN.md)
- [Español](README.es.md)
- [日本語](README.ja.md)
- [한국어](README.ko.md)

---

Codex Cursor Cleaner es un script de mantenimiento de un clic para Windows. Limpia cachés locales, logs, snapshots, worktrees temporales y bases SQLite demasiado grandes creadas por **Codex** y **Cursor**.

Úsalo si tienes alguno de estos problemas:

- Codex tarda mucho en iniciar o se queda bloqueado.
- Codex se vuelve lento después de muchas conversaciones.
- Codex genera alto uso de disco.
- `.codex/logs_2.sqlite` crece a cientos de MB o varios GB.
- `.codex/worktrees` contiene demasiados archivos temporales.
- Cursor va lento, se congela o tarda mucho en abrir proyectos.
- Cursor usa mucho disco incluso en SSD.
- `Cursor/User/globalStorage/state.vscdb` es enorme.
- `state.vscdb.backup` es enorme.
- La carpeta `snapshots` de Cursor es enorme.
- Composer, chat de IA y checkpoints crecen sin límite.

## Causas comunes

| Herramienta | Fuente de crecimiento | Síntoma típico |
| --- | --- | --- |
| Codex | `~/.codex/logs_2.sqlite` | Inicio lento, muchos logs SQLite |
| Codex | `~/.codex/worktrees` | Demasiados archivos temporales |
| Codex | `sessions` / `archived_sessions` | Historial JSONL grande |
| Cursor | `state.vscdb` | Cursor lento, base SQLite enorme |
| Cursor | `state.vscdb.backup` | Copia de seguridad multi-GB |
| Cursor | `snapshots` | Packs de snapshot muy grandes |
| Cursor | `composer.content.*`, `agentKv:*`, `checkpointId:*`, `bubbleId:*` | Historial de IA y checkpoints |

## Uso

1. Cierra Codex y Cursor.
2. Haz doble clic en `run-cleanup.bat`.
3. Revisa el log si es necesario:

```text
%USERPROFILE%\Documents\cleanup-codex-cursor.log
```

También puedes ejecutarlo desde PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\cleanup-codex-cursor.ps1
```

## Política predeterminada

- Conserva los últimos 14 días.
- Compacta SQLite con `VACUUM`.
- Si `logs_2.sqlite` supera 256MB, limpia la tabla de logs.
- Si `state.vscdb` supera 1GB, limpia claves grandes de historial/caché de IA.
- Si Codex o Cursor están en ejecución, evita limpiezas riesgosas.

## Nota de seguridad

El script elimina cachés locales, logs, sesiones antiguas, worktrees antiguos, snapshots y datos grandes de historial/caché de IA. No modifica tus repositorios de código.
