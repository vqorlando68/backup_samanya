"""
Agente de Backup y Versionamiento de Objetos Oracle a Git
Ambientes soportados: desarrollo y produccion
"""

import os
import sys
import argparse
import datetime
import logging
import subprocess
import re
import json
from pathlib import Path
from dotenv import load_dotenv
import oracledb

# Mapeo de tipos de objetos de Oracle a tipo DBMS_METADATA y subcarpetas
OBJECT_TYPE_MAPPING = {
    'TABLE': {
        'dbms_type': 'TABLE',
        'folder': 'tables',
        'ext': '.sql'
    },
    'VIEW': {
        'dbms_type': 'VIEW',
        'folder': 'views',
        'ext': '.sql'
    },
    'MATERIALIZED VIEW': {
        'dbms_type': 'MATERIALIZED_VIEW',
        'folder': 'views',
        'ext': '_mv.sql'
    },
    'PACKAGE': {
        'dbms_type': 'PACKAGE_SPEC',
        'folder': 'packages',
        'ext': '.pks'
    },
    'PACKAGE BODY': {
        'dbms_type': 'PACKAGE_BODY',
        'folder': 'packages',
        'ext': '.pkb'
    },
    'PROCEDURE': {
        'dbms_type': 'PROCEDURE',
        'folder': 'procedures',
        'ext': '.sql'
    },
    'FUNCTION': {
        'dbms_type': 'FUNCTION',
        'folder': 'functions',
        'ext': '.sql'
    },
    'TRIGGER': {
        'dbms_type': 'TRIGGER',
        'folder': 'triggers',
        'ext': '.sql'
    },
    'SEQUENCE': {
        'dbms_type': 'SEQUENCE',
        'folder': 'sequences',
        'ext': '.sql'
    },
    'TYPE': {
        'dbms_type': 'TYPE_SPEC',
        'folder': 'types',
        'ext': '.tps'
    },
    'TYPE BODY': {
        'dbms_type': 'TYPE_BODY',
        'folder': 'types',
        'ext': '.tpb'
    },
    'SYNONYM': {
        'dbms_type': 'SYNONYM',
        'folder': 'synonyms',
        'ext': '.sql'
    },
    'JOB': {
        'dbms_type': 'PROCOBJ',
        'folder': 'jobs',
        'ext': '.sql'
    },
    'SCHEDULE': {
        'dbms_type': 'PROCOBJ',
        'folder': 'jobs',
        'ext': '_schedule.sql'
    },
    'PROGRAM': {
        'dbms_type': 'PROCOBJ',
        'folder': 'jobs',
        'ext': '_program.sql'
    }
}


def setup_logger(base_dir: Path, env_name: str) -> logging.Logger:
    """Configura logger con salida a consola y a archivo diario"""
    logs_dir = base_dir / 'logs'
    logs_dir.mkdir(parents=True, exist_ok=True)
    today_str = datetime.datetime.now().strftime('%Y%m%d')
    log_file = logs_dir / f"backup_{env_name}_{today_str}.log"

    logger = logging.getLogger(f"backup_{env_name}")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()

    formatter = logging.Formatter(
        '[%(asctime)s] [%(levelname)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    fh = logging.FileHandler(log_file, encoding='utf-8')
    fh.setFormatter(formatter)
    logger.addHandler(fh)

    ch = logging.StreamHandler(sys.stdout)
    ch.setFormatter(formatter)
    logger.addHandler(ch)

    return logger


def run_cmd(cmd: list, cwd: Path, logger: logging.Logger) -> tuple[int, str]:
    """Ejecuta un comando en el sistema y retorna codigo y salida"""
    try:
        res = subprocess.run(
            cmd,
            cwd=str(cwd),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=False,
            encoding='utf-8',
            errors='replace',
            env={**os.environ, 'GIT_TERMINAL_PROMPT': '0'}
        )
        return res.returncode, res.stdout.strip()
    except Exception as e:
        logger.error(f"Fallo al ejecutar {' '.join(cmd)}: {e}")
        return -1, str(e)


def clean_ddl(ddl: str, schema: str = None) -> str:
    """
    Limpia el DDL generado por Oracle DBMS_METADATA:
    - Remueve la palabra EDITIONABLE y NONEDITIONABLE
    - Remueve el propietario del objeto ("TEKER_DEV"., "TEKER_PROD"., SCHEMA.)
    - Remueve las comillas dobles alrededor del nombre del objeto en el encabezado CREATE
      Ejemplo: CREATE OR REPLACE EDITIONABLE PACKAGE BODY "TEKER_DEV"."PKGLN_BIG_QUERY"
      Se convierte en: CREATE OR REPLACE PACKAGE BODY PKGLN_BIG_QUERY
    """
    if not ddl:
        return ddl

    # 1. Eliminar EDITIONABLE o NONEDITIONABLE
    ddl = re.sub(r'\b(EDITIONABLE|NONEDITIONABLE)\s+', '', ddl, flags=re.IGNORECASE)

    # 2. Quitar el propietario con o sin comillas (ej: "TEKER_DEV". o TEKER_DEV.)
    if schema:
        ddl = re.sub(rf'"{re.escape(schema)}"\.|\b{re.escape(schema)}\.', '', ddl, flags=re.IGNORECASE)

    # Quitar cualquier otro "OWNER". antes del nombre del objeto
    ddl = re.sub(r'("[A-Za-z0-9_#$]+")\s*\.\s*', '', ddl)

    # 3. Quitar comillas del nombre del objeto en el encabezado de creacion CREATE
    pattern = r'(\bCREATE\s+(?:OR\s+REPLACE\s+)?(?:FORCE\s+)?(?:PACKAGE(?:\s+BODY)?|PROCEDURE|FUNCTION|TRIGGER|VIEW|TABLE|SEQUENCE|TYPE(?:\s+BODY)?|SYNONYM)\s+)"([A-Za-z0-9_#$]+)"'
    ddl = re.sub(pattern, r'\1\2', ddl, flags=re.IGNORECASE)

    return ddl


def extract_objects(schema: str, conn: oracledb.Connection, output_base: Path, deleted_base: Path,
                    state_file: Path, logger: logging.Logger):
    """Extrae incrementalmente DDLs basandose en LAST_DDL_TIME y mueve objetos eliminados a schema_objects_borrados"""
    written_files = set()
    cursor = conn.cursor()

    # Cargar estado previo de DDL para deteccion incremental
    state = {}
    if state_file.exists():
        try:
            state = json.loads(state_file.read_text(encoding='utf-8'))
        except Exception:
            state = {}

    new_state = {}
    skipped_count = 0
    extracted_count = 0

    # Configuracion de transformaciones limpias en DBMS_METADATA
    transforms = [
        "BEGIN DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true); END;",
        "BEGIN DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true); END;",
        "BEGIN DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false); END;",
        "BEGIN DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false); END;",
        "BEGIN DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', false); END;",
        "BEGIN DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'EMIT_SCHEMA', false); END;"
    ]
    for sql in transforms:
        cursor.execute(sql)

    # Determinar si el usuario tiene acceso a DBA_OBJECTS o a ALL_OBJECTS
    obj_table = 'DBA_OBJECTS'
    try:
        cursor.execute("SELECT 1 FROM DBA_OBJECTS WHERE ROWNUM = 1")
    except Exception:
        obj_table = 'ALL_OBJECTS'
        logger.info("Vistas DBA_OBJECTS no accesibles. Utilizando catalogo ALL_OBJECTS...")

    query = f"""
        SELECT OBJECT_NAME, OBJECT_TYPE, LAST_DDL_TIME
        FROM {obj_table}
        WHERE OWNER = :schema_name
          AND OBJECT_TYPE IN (
            'TABLE', 'VIEW', 'MATERIALIZED VIEW', 'PACKAGE', 'PACKAGE BODY',
            'PROCEDURE', 'FUNCTION', 'TRIGGER', 'SEQUENCE', 'TYPE', 'TYPE BODY',
            'SYNONYM', 'JOB', 'SCHEDULE', 'PROGRAM'
          )
          AND OBJECT_NAME NOT LIKE 'BIN$%'
          AND GENERATED = 'N'
        ORDER BY OBJECT_TYPE, OBJECT_NAME
    """

    cursor.execute(query, schema_name=schema.upper())
    objects = cursor.fetchall()
    logger.info(f"Encontrados {len(objects)} objetos en el esquema {schema.upper()}")

    # Cargar comentarios de tablas y columnas en bloque
    comments_by_table = {}
    tab_comm_table = 'DBA_TAB_COMMENTS' if obj_table == 'DBA_OBJECTS' else 'ALL_TAB_COMMENTS'
    col_comm_table = 'DBA_COL_COMMENTS' if obj_table == 'DBA_OBJECTS' else 'ALL_COL_COMMENTS'
    try:
        cursor.execute(f"""
            SELECT TABLE_NAME, 'TABLE' AS TIPO, NULL AS COLUMN_NAME, COMMENTS 
            FROM {tab_comm_table} 
            WHERE OWNER = :schema AND COMMENTS IS NOT NULL
            UNION ALL
            SELECT TABLE_NAME, 'COLUMN' AS TIPO, COLUMN_NAME, COMMENTS 
            FROM {col_comm_table} 
            WHERE OWNER = :schema AND COMMENTS IS NOT NULL
            ORDER BY TABLE_NAME, TIPO DESC, COLUMN_NAME
        """, schema=schema.upper())
        for t_name, c_tipo, col_name, comm_text in cursor.fetchall():
            if t_name not in comments_by_table:
                comments_by_table[t_name] = []
            comm_clean = str(comm_text).replace("'", "''")
            if c_tipo == 'TABLE':
                comments_by_table[t_name].append(f"COMMENT ON TABLE {t_name} IS '{comm_clean}';")
            else:
                comments_by_table[t_name].append(f"COMMENT ON COLUMN {t_name}.{col_name} IS '{comm_clean}';")
        logger.info(f"Cargados comentarios para {len(comments_by_table)} tablas.")
    except Exception as e:
        logger.warning(f"No se pudieron consultar comentarios de tablas: {e}")

    ddl_query = "SELECT DBMS_METADATA.GET_DDL(:dbms_type, :obj_name, :schema_name) FROM DUAL"

    for obj_name, obj_type, last_ddl_time in objects:
        mapping = OBJECT_TYPE_MAPPING.get(obj_type)
        if not mapping:
            continue

        target_dir = output_base / mapping['folder']
        target_dir.mkdir(parents=True, exist_ok=True)
        file_path = target_dir / f"{obj_name.lower()}{mapping['ext']}"
        obj_key = f"{obj_type}:{obj_name}"
        ddl_ts = last_ddl_time.strftime('%Y-%m-%d %H:%M:%S') if last_ddl_time else None

        # Si el archivo ya existe y LAST_DDL_TIME no ha cambiado, omitir extraccion pesada
        if file_path.exists() and ddl_ts and state.get(obj_key) == ddl_ts:
            written_files.add(file_path.resolve())
            new_state[obj_key] = ddl_ts
            skipped_count += 1
            continue

        try:
            cursor.execute(ddl_query, dbms_type=mapping['dbms_type'], obj_name=obj_name, schema_name=schema.upper())
            row = cursor.fetchone()
            if row and row[0]:
                ddl_content = str(row[0]).strip()
                # Anexar comentarios si es tabla
                if obj_type == 'TABLE' and obj_name in comments_by_table:
                    comm_block = "\n".join(comments_by_table[obj_name])
                    ddl_content = ddl_content.rstrip() + "\n\n" + comm_block

                ddl_content = clean_ddl(ddl_content, schema)
                # Normalizar saltos de linea
                ddl_content = ddl_content.replace('\r\n', '\n') + '\n'
                
                file_path.write_text(ddl_content, encoding='utf-8')
                written_files.add(file_path.resolve())
                new_state[obj_key] = ddl_ts
                extracted_count += 1
        except Exception as e:
            logger.warning(f"No se pudo extraer DDL para {obj_type} {obj_name}: {e}")

    # Mover objetos que fueron eliminados de la BD a schema_objects_borrados
    moved_count = 0
    for existing_file in output_base.glob('**/*'):
        if existing_file.is_file() and existing_file.resolve() not in written_files:
            rel_path = existing_file.relative_to(output_base)
            target_deleted = deleted_base / rel_path
            target_deleted.parent.mkdir(parents=True, exist_ok=True)
            
            target_deleted.write_text(existing_file.read_text(encoding='utf-8', errors='replace'), encoding='utf-8')
            existing_file.unlink()
            moved_count += 1
            logger.info(f"Objeto borrado en BD detectado: {rel_path} -> movido a {deleted_base.name}/{rel_path}")

    # Guardar nuevo estado
    try:
        state_file.write_text(json.dumps(new_state, indent=2), encoding='utf-8')
    except Exception as e:
        logger.warning(f"No se pudo guardar archivo de estado {state_file}: {e}")

    logger.info(f"Resumen extraccion: {extracted_count} extraidos/actualizados, {skipped_count} sin cambios (omitidos), {moved_count} movidos a borrados.")
    stats = {
        'total': len(objects),
        'extracted': extracted_count,
        'skipped': skipped_count,
        'moved': moved_count
    }
    return written_files, stats


def generate_objects_index(repo_dir: Path, env_name: str = 'desarrollo', logger: logging.Logger = None):
    """Genera objects_index.json con todos los objetos activos y borrados preservando metadatos de ambientes y fechas"""
    try:
        idx_file = repo_dir / 'objects_index.json'
        prev_data = {}
        if idx_file.exists():
            try:
                for item in json.loads(idx_file.read_text(encoding='utf-8')):
                    prev_data[item['path']] = item
            except Exception:
                prev_data = {}

        objs = []
        for f in sorted(repo_dir.glob('schema_objects*/**/*')):
            if f.is_file():
                rel = str(f.relative_to(repo_dir)).replace('\\', '/')
                is_del = 'borrados' in f.parts[0]
                obj_type = f.parent.name
                
                prev_item = prev_data.get(rel, {})
                envs = set(prev_item.get('envs', []))
                envs.add(env_name)
                
                objs.append({
                    'name': f.stem.upper(),
                    'file': f.name,
                    'type': obj_type,
                    'status': 'deleted' if is_del else 'active',
                    'path': rel,
                    'size': f.stat().st_size,
                    'envs': sorted(list(envs)),
                    'created_at': prev_item.get('created_at', '2026-10-16 22:06'),
                    'updated_at': prev_item.get('updated_at'),
                    'has_updates': prev_item.get('has_updates', False),
                    'commits_count': prev_item.get('commits_count', 1),
                    'oracle_date': prev_item.get('oracle_date', '')
                })
        idx_file.write_text(json.dumps(objs, indent=2, ensure_ascii=False), encoding='utf-8')
        if logger:
            logger.info(f"Catalogo de buscador actualizado en objects_index.json ({len(objs)} objetos indexados para {env_name}).")
    except Exception as e:
        if logger:
            logger.warning(f"No se pudo generar objects_index.json: {e}")


def sync_git(repo_dir: Path, branch: str, remote: str, env_name: str, logger: logging.Logger,
             repo_url: str = None, git_user: str = None, git_token: str = None,
             stats: dict = None, start_time: datetime.datetime = None):
    """Maneja checkout, add, commit y push a Git con soporte para URL y Token autenticado"""
    logger.info(f"Iniciando sincronizacion con Git en la rama '{branch}'...")

    # Inicializar git si no existe el repositorio local
    if not (repo_dir / '.git').exists():
        logger.info("Repositorio Git local no detectado. Inicializando repositorio...")
        run_cmd(['git', 'init'], repo_dir, logger)
        if repo_url:
            run_cmd(['git', 'remote', 'add', remote, repo_url], repo_dir, logger)

    # Checkout a la rama de destino
    code, out = run_cmd(['git', 'checkout', branch], repo_dir, logger)
    if code != 0:
        logger.info(f"Creando rama local '{branch}'...")
        code, out = run_cmd(['git', 'checkout', '-B', branch], repo_dir, logger)
        if code != 0:
            logger.error(f"Error al cambiar a la rama {branch}: {out}")
            return

    # Verificar cambios en el repositorio
    run_cmd(['git', 'add', '-A'], repo_dir, logger)
    code, status_out = run_cmd(['git', 'status', '--porcelain', 'schema_objects', 'schema_objects_borrados'], repo_dir, logger)
    
    status_map = {'A': 'NUEVO', 'M': 'MODIFICADO', 'D': 'ELIMINADO', 'R': 'RENOMBRADO'}
    changed_lines = [line.strip() for line in status_out.splitlines() if line.strip()]

    if changed_lines:
        logger.info(f"Se detectaron {len(changed_lines)} archivo(s) de objetos para subir a Git:")
        for line in changed_lines:
            parts = line.split(maxsplit=1)
            action_code = parts[0] if len(parts) > 0 else '?'
            file_name = parts[1] if len(parts) > 1 else line
            action_desc = status_map.get(action_code, action_code)
            logger.info(f"  [{action_desc}] {file_name}")
    else:
        logger.info(f"No se detectaron cambios en los objetos de {env_name}.")

    # Forzar volcado del log a disco antes de agregarlo a Git
    for handler in logger.handlers:
        handler.flush()

    # Agregar todos los cambios a Git
    run_cmd(['git', 'add', '-A'], repo_dir, logger)

    # Verificar si hay cambios para commitear
    code, all_status = run_cmd(['git', 'status', '--porcelain'], repo_dir, logger)
    if not all_status.strip():
        logger.info("No hay cambios nuevos ni en objetos ni en logs. Nada que commitear.")
        return

    # Commit
    now_str = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    if changed_lines:
        commit_msg = f"chore(sync): backup objetos {env_name} [{now_str}]"
    else:
        commit_msg = f"chore(sync): log ejecucion {env_name} sin cambios en objetos [{now_str}]"

    code, commit_out = run_cmd(['git', 'commit', '-m', commit_msg], repo_dir, logger)
    if code != 0:
        logger.error(f"Error en git commit: {commit_out}")
        return
    logger.info(f"Commit realizado: {commit_msg}")

    # Obtener hash del commit y actualizar status.json
    code, hash_out = run_cmd(['git', 'rev-parse', '--short', 'HEAD'], repo_dir, logger)
    commit_hash = hash_out.strip() if code == 0 else ""

    status_file = repo_dir / 'status.json'
    try:
        st_data = {}
        if status_file.exists():
            try:
                st_data = json.loads(status_file.read_text(encoding='utf-8'))
            except Exception:
                st_data = {}

        dur_sec = round((datetime.datetime.now() - start_time).total_seconds()) if start_time else 0
        raw_url = repo_url or "https://github.com/vqorlando68/agente_backup.git"
        clean_repo_url = raw_url[:-4] if raw_url.endswith('.git') else raw_url
        today_str = datetime.datetime.now().strftime('%Y%m%d')
        log_rel = f"logs/backup_{env_name}_{today_str}.log"

        st_data[env_name] = {
            "ambiente": "Desarrollo" if env_name == 'desarrollo' else "Producción",
            "esquema": os.getenv('TARGET_SCHEMA', ''),
            "rama": branch,
            "ultima_ejecucion": now_str,
            "commit_hash": commit_hash,
            "commit_mensaje": commit_msg,
            "commit_url": f"{clean_repo_url}/commit/{commit_hash}" if commit_hash else "",
            "objetos_totales": stats.get('total', 0) if stats else 0,
            "objetos_actualizados": stats.get('extracted', 0) if stats else 0,
            "objetos_omitidos": stats.get('skipped', 0) if stats else 0,
            "objetos_borrados": stats.get('moved', 0) if stats else 0,
            "estado": "EXITOSO",
            "duracion_segundos": dur_sec,
            "archivo_log": log_rel,
            "archivos_cambiados": changed_lines
        }
        status_file.write_text(json.dumps(st_data, indent=2, ensure_ascii=False), encoding='utf-8')
        run_cmd(['git', 'add', 'status.json'], repo_dir, logger)
        run_cmd(['git', 'commit', '--amend', '--no-edit'], repo_dir, logger)
        code, final_hash_out = run_cmd(['git', 'rev-parse', '--short', 'HEAD'], repo_dir, logger)
        if code == 0 and final_hash_out.strip():
            final_hash = final_hash_out.strip()
            st_data[env_name]['commit_hash'] = final_hash
            st_data[env_name]['commit_url'] = f"{clean_repo_url}/commit/{final_hash}"
            status_file.write_text(json.dumps(st_data, indent=2, ensure_ascii=False), encoding='utf-8')
            run_cmd(['git', 'add', 'status.json'], repo_dir, logger)
            run_cmd(['git', 'commit', '--amend', '--no-edit'], repo_dir, logger)
    except Exception as e:
        logger.warning(f"No se pudo actualizar status.json: {e}")

    # Determinar destino y credenciales de push
    push_target = remote
    display_target = remote

    if repo_url:
        if git_token:
            if repo_url.startswith("https://"):
                prefix = f"{git_user}:{git_token}@" if git_user else f"{git_token}@"
                push_target = "https://" + prefix + repo_url[8:]
                display_target = f"https://***@{repo_url[8:]}"
            else:
                push_target = repo_url
                display_target = repo_url
        else:
            push_target = repo_url
            display_target = repo_url

    # Push
    code, push_out = run_cmd(['git', 'push', '-u', push_target, branch], repo_dir, logger)
    if code != 0:
        # Enmascarar token si apareciera en el error
        if git_token and git_token in push_out:
            push_out = push_out.replace(git_token, '***')
        logger.error(f"Error en git push: {push_out}")
        logger.warning("Verifica credenciales o conexion al repositorio remoto.")
    else:
        logger.info(f"Push completado exitosamente a {display_target} (rama {branch}).")


def main():
    parser = argparse.ArgumentParser(description="Agente de Backup Oracle a Git")
    parser.add_argument('--env', default='desarrollo',
                        help="Ambiente o nombre del archivo de configuracion (ej: desarrollo, produccion, samanya)")
    parser.add_argument('--no-git', action='store_true',
                        help="Extraer objetos sin ejecutar operaciones de Git")
    args = parser.parse_args()

    project_dir = Path(__file__).resolve().parent.parent

    # Resolucion inteligente del archivo de configuracion
    env_file = project_dir / 'config' / f".env.{args.env}"
    if not env_file.exists():
        fallback_samanya = project_dir / 'config' / '.env.samanya'
        fallback_default = project_dir / 'config' / '.env'
        if fallback_samanya.exists():
            env_file = fallback_samanya
        elif fallback_default.exists():
            env_file = fallback_default
        else:
            print(f"Error: No existe el archivo de configuracion: {env_file}")
            sys.exit(1)

    load_dotenv(dotenv_path=env_file, override=True)
    logger = setup_logger(project_dir, args.env)

    oracle_user = os.getenv('ORACLE_USER')
    oracle_pass = os.getenv('ORACLE_PASSWORD')
    oracle_dsn = os.getenv('ORACLE_CONNECT_STRING')
    target_schema = os.getenv('TARGET_SCHEMA', oracle_user)

    # Parametros de Oracle Wallet si existen
    wallet_dir_env = os.getenv('ORACLE_WALLET_DIR') or os.getenv('ORACLE_WALLET_LOCATION') or os.getenv('TNS_ADMIN')
    wallet_pass = os.getenv('ORACLE_WALLET_PASSWORD')

    wallet_dir = None
    if wallet_dir_env:
        w_path = Path(wallet_dir_env)
        if not w_path.is_absolute():
            w_path = (project_dir / w_path).resolve()
        if w_path.exists():
            wallet_dir = w_path
    elif (project_dir / 'wallet').exists():
        wallet_dir = (project_dir / 'wallet').resolve()

    git_branch = os.getenv('GIT_BRANCH', args.env)
    git_remote = os.getenv('GIT_REMOTE', 'origin')
    git_repo_url = os.getenv('GIT_REPO_URL')
    git_username = os.getenv('GIT_USERNAME')
    git_token = os.getenv('GIT_TOKEN')

    start_time = datetime.datetime.now()
    logger.info("=" * 60)
    logger.info(f"INICIANDO AGENTE BACKUP - AMBIENTE: {args.env.upper()}")
    logger.info(f"Conectando a {oracle_dsn} con usuario {oracle_user}...")
    if wallet_dir:
        logger.info(f"Utilizando Oracle Wallet en: {wallet_dir}")
    logger.info(f"Esquema objetivo: {target_schema}")

    try:
        conn_kwargs = {
            'user': oracle_user,
            'password': oracle_pass,
            'dsn': oracle_dsn
        }
        if wallet_dir:
            conn_kwargs['config_dir'] = str(wallet_dir)
            conn_kwargs['wallet_location'] = str(wallet_dir)
            if wallet_pass:
                conn_kwargs['wallet_password'] = wallet_pass

        conn = oracledb.connect(**conn_kwargs)
        logger.info("Conexion a Oracle establecida con exito.")
    except Exception as e:
        logger.error(f"Error critico de conexion a Oracle: {e}")
        sys.exit(1)

    # Cambiar a la rama de destino antes de extraer para tener los archivos correctos en disco
    if not args.no_git:
        logger.info(f"Posicionando repositorio en la rama '{git_branch}'...")
        code, out = run_cmd(['git', 'checkout', git_branch], project_dir, logger)
        if code != 0:
            code, out = run_cmd(['git', 'checkout', '-B', git_branch], project_dir, logger)

    schema_dir = project_dir / 'schema_objects'
    schema_dir.mkdir(parents=True, exist_ok=True)
    deleted_dir = project_dir / 'schema_objects_borrados'
    deleted_dir.mkdir(parents=True, exist_ok=True)
    state_file = project_dir / 'config' / f".state_{args.env}.json"

    stats = None
    try:
        written_files, stats = extract_objects(target_schema, conn, schema_dir, deleted_dir, state_file, logger)
    finally:
        conn.close()
        logger.info("Conexion a Oracle cerrada.")

    generate_objects_index(project_dir, args.env, logger)

    if not args.no_git:
        sync_git(
            project_dir, git_branch, git_remote, args.env, logger,
            repo_url=git_repo_url, git_user=git_username, git_token=git_token,
            stats=stats, start_time=start_time
        )
    else:
        logger.info("Opcion --no-git activada. Se omite commit y push.")

    logger.info(f"FIN DE PROCESO - {args.env.upper()}")
    logger.info("=" * 60)


if __name__ == '__main__':
    main()
