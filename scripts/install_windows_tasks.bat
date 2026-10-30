@echo off
echo ==============================================================
echo Registrando tareas en el Programador de Tareas de Windows...
echo ==============================================================

set BASE_DIR=%~dp0..
set SCRIPT_DEV=%BASE_DIR%\scripts\run_backup_desarrollo.bat
set SCRIPT_PROD=%BASE_DIR%\scripts\run_backup_produccion.bat

:: Tarea Desarrollo: todos los dias a la 1:00 PM (13:00)
schtasks /create /tn "Oracle_Backup_Samanya_Desarrollo" /tr "\"%SCRIPT_DEV%\"" /sc daily /st 13:00 /f

echo.
echo Tarea registrada con exito:
echo - Oracle_Backup_Samanya_Desarrollo: Diariamente a la 1:00 PM (13:00)
pause
