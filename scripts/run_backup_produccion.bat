@echo off
cd /d "%~dp0\.."

set "PY_CMD="
if exist "%LOCALAPPDATA%\Programs\Python\Python313\python.exe" (
    set "PY_CMD=%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
) else (
    where py >nul 2>&1 && set "PY_CMD=py" || set "PY_CMD=python"
)

"%PY_CMD%" scripts\backup_agent.py --env produccion %*
