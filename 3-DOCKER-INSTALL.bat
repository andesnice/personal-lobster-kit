@echo off
setlocal
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0windows\docker.ps1" setup
set "result=%ERRORLEVEL%"
echo.
pause
exit /b %result%
