@echo off
echo ==============================================================
echo Registrando tareas en el Programador de Tareas de Windows...
echo ==============================================================

set BASE_DIR=%~dp0..
set SCRIPT_DEV=%BASE_DIR%\scripts\run_backup_desarrollo.bat
set SCRIPT_PROD=%BASE_DIR%\scripts\run_backup_produccion.bat

:: Tarea Desarrollo: todos los dias a las 04:00 AM
schtasks /create /tn "Oracle_Backup_Desarrollo" /tr "\"%SCRIPT_DEV%\"" /sc daily /st 04:00 /f

:: Tarea Produccion: todos los dias a las 04:30 AM
schtasks /create /tn "Oracle_Backup_Produccion" /tr "\"%SCRIPT_PROD%\"" /sc daily /st 04:30 /f

echo.
echo Tareas registradas con exito:
echo - Oracle_Backup_Desarrollo: 04:00 AM
echo - Oracle_Backup_Produccion: 04:30 AM
pause
