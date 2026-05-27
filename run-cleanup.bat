@echo off
chcp 65001 >nul
title Codex Cursor Cleaner
echo Please close Codex and Cursor before continuing.
echo.
pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0cleanup-codex-cursor.ps1"
echo.
echo Cleanup finished. Log file: %USERPROFILE%\Documents\cleanup-codex-cursor.log
pause
