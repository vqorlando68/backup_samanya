# Agente de Respaldo y Versionamiento Oracle a Git

Agente automatizado en Python para extraer DDLs de objetos Oracle y versionarlos en Git para **Desarrollo** (`desarrollo`) y **Producción** (`produccion`).

## Documentación Completa
Consulta el [MANUAL_IMPLEMENTACION.md](file:///c:/Repositorios/Objetos_desarrollo/MANUAL_IMPLEMENTACION.md) para:
- Despliegue paso a paso en Windows y Linux.
- Generación y configuración del Personal Access Token de GitHub.
- Script SQL de creación de usuario en Oracle 23ai.

---

## Cómo Desactivar el Aviso "Compare & Pull Request" en GitHub
Las ramas `desarrollo` y `produccion` son espejos independientes de sus respectivas bases de datos (`TEKER_DEV` y `TEKER_PROD`) y **nunca deben fusionarse**. Para que GitHub no muestre el banner verde sugiriendo Pull Requests:
1. Ve a **Settings** de tu repositorio: [https://github.com/vqorlando68/agente_backup/settings](https://github.com/vqorlando68/agente_backup/settings).
2. En la sección **General**, localiza el apartado **Features**.
3. **Desmarca la casilla `Pull requests`**.
4. Listo, el aviso no volverá a aparecer en este repositorio.

---

## Estructura del Proyecto
- `config/.env.desarrollo` / `config/.env.produccion`: Variables de conexión, esquema y token (excluidos en git).
- `scripts/backup_agent.py`: Agente extractor inteligente y sincronizador con Git.
- `scripts/run_backup_desarrollo.bat` / `.sh`: Ejecutores para Desarrollo (Windows / Linux).
- `scripts/run_backup_produccion.bat` / `.sh`: Ejecutores para Producción (Windows / Linux).
- `scripts/install_windows_tasks.bat`: Registra la ejecución automática diaria a las 04:00 AM en Windows.
- `schema_objects/`: Objetos activos de la base de datos (`tables/`, `views/`, `packages/`, `jobs/`, etc.).
- `schema_objects_borrados/`: Objetos eliminados en BD conservados con su histórico.
- `dashboard.html`: Panel visual interactivo con diseño iOS Frosted Glass (Glassmorphism), visor de commits, métricas, logs y manual integrado.
- `status.json`: Registro JSON de la última sincronización, commit hash, métricas y cambios por ambiente.
- `logs/`: Registros diarios detallados de ejecución sincronizados en Git.

---

## Ejecución Manual

```bash
# Desarrollo
py scripts/backup_agent.py --env desarrollo

# Producción
py scripts/backup_agent.py --env produccion

# Modo prueba (solo extrae, sin git commit/push)
py scripts/backup_agent.py --env desarrollo --no-git
```

## Programación Diaria (04:00 AM)
* **Windows**: Ejecutar `scripts\install_windows_tasks.bat` como Administrador.
* **Linux**: Configurar en `crontab -e` según se detalla en el manual.
