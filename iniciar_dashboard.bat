@echo off
title Servidor Local Dashboard - Agente Backup Oracle
cd /d "%~dp0"
echo ========================================================
echo   Iniciando Dashboard con visualizador de codigo DDL
echo   Acceso: http://localhost:8080/dashboard.html
echo ========================================================
echo Abriendo navegador por defecto...
start http://localhost:8080/dashboard.html

set "PY_CMD="
if exist "%LOCALAPPDATA%\Programs\Python\Python313\python.exe" (
    set "PY_CMD=%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
) else (
    where py >nul 2>&1 && set "PY_CMD=py" || set "PY_CMD=python"
)

"%PY_CMD%" -m http.server 8080
pause
