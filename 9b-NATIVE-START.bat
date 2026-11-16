@echo off
setlocal
chcp 65001 >nul
set "action=start"
if not "%~1"=="" set "action=%~1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0windows\install.ps1" "%action%"
set "result=%ERRORLEVEL%"
echo.
pause
exit /b %result%
