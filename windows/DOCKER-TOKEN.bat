@echo off
setlocal
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0docker.ps1" token
set "result=%ERRORLEVEL%"
echo.
pause
exit /b %result%
