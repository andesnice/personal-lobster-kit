@echo off
setlocal
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-docker-desktop.ps1"
set "result=%ERRORLEVEL%"
echo.
pause
exit /b %result%
