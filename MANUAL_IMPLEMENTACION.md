# Manual de Implementación y Operación - Agente de Respaldo Oracle a Git

Este manual describe el despliegue, configuración y operación del agente automatizado para la extracción y versionamiento de objetos de base de datos Oracle hacia GitHub en dos ambientes independientes: **Desarrollo** (`desarrollo`) y **Producción** (`produccion`).

---

## 1. Cómo Ocultar el Mensaje "Compare & Pull Request" en GitHub

Dado que este repositorio es un espejo de respaldo y las ramas `desarrollo` y `produccion` no deben fusionarse nunca, puedes desactivar la función de Pull Requests para que el aviso no vuelva a aparecer:

1. Entra a tu repositorio en GitHub: [https://github.com/vqorlando68/agente_backup/settings](https://github.com/vqorlando68/agente_backup/settings)
2. En la pestaña **General**, baja a la sección **Features**.
3. **Desmarca la casilla `Pull requests`**.
4. ¡Listo! Al no haber Pull Requests habilitados en el repositorio, GitHub ocultará permanentemente el banner verde de comparación.

---

## 2. Guía Paso a Paso para Generar el Token de Git (Personal Access Token)

El agente utiliza un Token de Acceso Personal (PAT) para autenticarse y realizar el `push` de forma desatendida y segura sin contraseñas interactivas.

### Pasos en GitHub:
1. Inicia sesión en GitHub y haz clic en tu avatar superior derecho > **Settings** (o entra directo a [https://github.com/settings/tokens](https://github.com/settings/tokens)).
2. En el menú lateral izquierdo, al final, haz clic en **Developer settings**.
3. Selecciona **Personal access tokens** > **Tokens (classic)**.
4. Haz clic en **Generate new token** > **Generate new token (classic)**.
5. Completa el formulario:
   * **Note**: `Agente_Backup_Oracle` (o el nombre que prefieras).
   * **Expiration**: Selecciona `No expiration` (o el periodo deseado según políticas de seguridad).
   * **Select scopes**: Marca la casilla **`repo`** (Full control of private repositories).
6. Haz clic al final en **Generate token**.
7. **Copia el token generado** (inicia con `ghp_...`).  
   *(Importante: Guárdalo de inmediato, GitHub solo lo muestra una vez).*

---

## 3. Script SQL para el Usuario de Oracle 23ai

Ejecutar con el usuario `SYS` en la PDB `orclpdb1` en cada base de datos (Desarrollo y Producción):

```sql
ALTER SESSION SET CONTAINER = orclpdb1;

CREATE USER USUARIO_BACKUP_AGENT IDENTIFIED BY "Backup_Ag3nt3_2026"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA 0 ON USERS
  ACCOUNT UNLOCK;

GRANT CREATE SESSION TO USUARIO_BACKUP_AGENT;
GRANT SELECT_CATALOG_ROLE TO USUARIO_BACKUP_AGENT;
GRANT EXECUTE ON SYS.DBMS_METADATA TO USUARIO_BACKUP_AGENT;
```

---

## 4. Implementación en Windows

### Requisitos:
* Python 3.9 o superior instalado y agregado al PATH.
* Git instalado en Windows.

### Pasos de Instalación:
1. Clonar el repositorio:
   ```cmd
   cd C:\Repositorios
   git clone https://github.com/vqorlando68/agente_backup.git Objetos_desarrollo
   cd Objetos_desarrollo
   ```
2. Instalar dependencias de Python:
   ```cmd
   py -m pip install -r requirements.txt
   ```
3. Crear los archivos de configuración dentro de la carpeta `config/`:
   * `config\.env.desarrollo`:
     ```env
     ORACLE_USER=USUARIO_BACKUP_AGENT
     ORACLE_PASSWORD=Backup_Ag3nt3_2026
     ORACLE_CONNECT_STRING=tekerapp-db.maxapex.net:1521/orclpdb1
     TARGET_SCHEMA=TEKER_DEV
     GIT_BRANCH=desarrollo
     GIT_REMOTE=origin
     GIT_REPO_URL=https://github.com/vqorlando68/agente_backup.git
     GIT_USERNAME=vqorlando68
     GIT_TOKEN=ghp_tu_token_aqui
     ```
   * `config\.env.produccion`:
     ```env
     ORACLE_USER=USUARIO_BACKUP_AGENT
     ORACLE_PASSWORD=Backup_Ag3nt3_2026
     ORACLE_CONNECT_STRING=tekerapp-db.maxapex.net:1521/orclpdb1
     TARGET_SCHEMA=TEKER_PROD
     GIT_BRANCH=produccion
     GIT_REMOTE=origin
     GIT_REPO_URL=https://github.com/vqorlando68/agente_backup.git
     GIT_USERNAME=vqorlando68
     GIT_TOKEN=ghp_tu_token_aqui
     ```
4. Programar la ejecución diaria a las 04:00 AM:
   * Haz clic derecho sobre `scripts\install_windows_tasks.bat` y selecciona **"Ejecutar como administrador"**.
   * Esto creará dos tareas en el Programador de Tareas:
     * `Oracle_Backup_Desarrollo`: corre todos los días a las 04:00 AM.
     * `Oracle_Backup_Produccion`: corre todos los días a las 04:30 AM.

---

## 5. Implementación en Linux (Ubuntu / Debian / RHEL / Rocky / Oracle Linux)

### Requisitos:
```bash
# Ubuntu / Debian
sudo apt update && sudo apt install -y python3 python3-pip python3-venv git

# RHEL / Rocky / Oracle Linux
sudo dnf install -y python3 python3-pip git
```

### Pasos de Instalación:
1. Clonar el repositorio:
   ```bash
   cd /opt
   git clone https://github.com/vqorlando68/agente_backup.git
   cd agente_backup
   ```
2. Crear y activar entorno virtual de Python:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
3. Dar permisos de ejecución a los scripts:
   ```bash
   chmod +x scripts/run_backup_desarrollo.sh
   chmod +x scripts/run_backup_produccion.sh
   ```
4. Crear la carpeta `config/` y los archivos de configuración:
   ```bash
   mkdir -p config
   ```
   Crear `config/.env.desarrollo` y `config/.env.produccion` con las mismas variables descritas en la sección de Windows.
5. Programar en el Cron de Linux (`crontab -e`):
   ```bash
   # Ejecutar crontab como el usuario que gestionará el backup
   crontab -e
   ```
   Agregar las siguientes dos líneas al final del archivo:
   ```cron
   # Respaldo de Desarrollo todos los dias a las 04:00 AM
   0 4 * * * /opt/agente_backup/scripts/run_backup_desarrollo.sh >/dev/null 2>&1

   # Respaldo de Produccion todos los dias a las 04:30 AM
   30 4 * * * /opt/agente_backup/scripts/run_backup_produccion.sh >/dev/null 2>&1
   ```

---

## 6. Características y Optimización del Agente

* **Detección Incremental (`LAST_DDL_TIME`)**:  
  El agente no vuelve a descargar los 2,400 objetos cada día. Compara la fecha de modificación en Oracle y solo genera el archivo plano si el objeto fue modificado o creado recientemente. Esto reduce el tiempo diario de **20 minutos a ~15 segundos**.
* **Gestión de Objetos Eliminados (`schema_objects_borrados/`)**:  
  Si un objeto es eliminado (`DROP`) en la base de datos, el agente no lo pierde: lo traslada a la carpeta `schema_objects_borrados/` manteniendo la misma jerarquía de carpetas (`tables/`, `packages/`, `views/`, etc.).
* **Scheduler Jobs Incluidos**:  
  Los jobs creados con `DBMS_SCHEDULER` se extraen con `PROCOBJ` y se versionan en `schema_objects/jobs/`.
* **Push 100% Desatendido**:  
  Usa `GIT_TERMINAL_PROMPT=0` y el `GIT_TOKEN` en memoria, evitando cualquier bloqueo o solicitud interactiva en pantalla.
* **Logs Diarios en Git**:  
  Cada ejecución genera su log en `logs/backup_<ambiente>_<FECHA>.log` detallando qué objetos cambiaron, y este archivo se sube automáticamente al repositorio en cada push.
