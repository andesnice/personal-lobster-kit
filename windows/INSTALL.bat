@echo off
setlocal
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" setup
set "result=%ERRORLEVEL%"
echo.
pause
exit /b %result%
