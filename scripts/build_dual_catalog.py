import subprocess
import json
from collections import defaultdict
from pathlib import Path

repo_dir = Path(__file__).resolve().parent.parent

# 1. Obtener archivos de ambas ramas en Git
res_dev = subprocess.run(['git', 'ls-tree', '-r', '--name-only', 'desarrollo', 'schema_objects', 'schema_objects_borrados'], cwd=repo_dir, capture_output=True, text=True)
res_prod = subprocess.run(['git', 'ls-tree', '-r', '--name-only', 'produccion', 'schema_objects', 'schema_objects_borrados'], cwd=repo_dir, capture_output=True, text=True)

dev_set = set(res_dev.stdout.strip().splitlines())
prod_set = set(res_prod.stdout.strip().splitlines())

# 2. Obtener fechas de commits para cada archivo desde git log
cmd_log = ['git', 'log', '--name-only', '--format=COMMIT:%ci', 'HEAD', 'origin/produccion']
out_log = subprocess.check_output(cmd_log, cwd=repo_dir, text=True, encoding='utf-8', errors='ignore')

file_dates = defaultdict(list)
current_date = None

for line in out_log.splitlines():
    line = line.strip()
    if not line:
        continue
    if line.startswith('COMMIT:'):
        raw_dt = line.split('COMMIT:')[1].strip()
        current_date = raw_dt[:16] # 'YYYY-MM-DD HH:MM'
    elif current_date:
        file_dates[line.replace('\\', '/')].append(current_date)

# 3. Obtener fechas de último DDL en Oracle desde los estados de los ambientes
oracle_dates = {}
for sf in ['config/.state_desarrollo.json', 'config/.state_produccion.json']:
    p = repo_dir / sf
    if p.exists():
        try:
            st = json.loads(p.read_text(encoding='utf-8'))
            for k, v in st.items():
                parts = k.split(':', 1)
                if len(parts) == 2:
                    name = parts[1].upper()
                    oracle_dates[name] = str(v)[:16]
        except Exception:
            pass

all_paths = sorted(dev_set | prod_set)
entries_compact = []
objects_rich = []

for p in all_paths:
    clean_p = p.replace('\\', '/')
    parts = clean_p.split('/')
    is_deleted = parts[0] == 'schema_objects_borrados'
    type_folder = parts[1] if len(parts) > 1 else 'otros'
    file_name = parts[2] if len(parts) > 2 else parts[-1]
    name = file_name.rsplit('.', 1)[0].upper()
    
    envs = []
    if p in dev_set:
        envs.append('desarrollo')
    if p in prod_set:
        envs.append('produccion')
        
    flag = 'B' if ('desarrollo' in envs and 'produccion' in envs) else ('D' if 'desarrollo' in envs else 'P')
    
    # Extraer fechas de Git para este archivo
    d_list = file_dates.get(clean_p, [])
    # d_list viene ordenado de más reciente a más antiguo
    if d_list:
        first_commit = d_list[-1]
        last_commit = d_list[0]
        commits_count = len(d_list)
        # Si tiene más de 1 commit o fechas distintas, ha tenido actualizaciones
        has_updates = len(set(d_list)) > 1 or commits_count > 1
        updated_at = last_commit if has_updates else None
    else:
        first_commit = '2026-10-16 22:06'
        last_commit = first_commit
        commits_count = 1
        has_updates = False
        updated_at = None

    oracle_dt = oracle_dates.get(name, '')

    # Formato compacto: path:FLAG:CREATED_AT:UPDATED_AT:ORACLE_DATE
    # Si no tiene actualización, UPDATED_AT va vacío
    up_str = updated_at if updated_at else ''
    entries_compact.append(f"{clean_p}~{flag}~{first_commit}~{up_str}~{oracle_dt}")
    
    objects_rich.append({
        'name': name,
        'file': file_name,
        'type': type_folder,
        'status': 'deleted' if is_deleted else 'active',
        'path': clean_p,
        'envs': envs,
        'created_at': first_commit,
        'updated_at': updated_at,
        'has_updates': has_updates,
        'commits_count': commits_count,
        'oracle_date': oracle_dt
    })

# Guardar objects_index.json con metadatos completos de fechas y ambientes
(repo_dir / 'objects_index.json').write_text(json.dumps(objects_rich, indent=2, ensure_ascii=False), encoding='utf-8')
(repo_dir / 'embedded_catalog_dual.txt').write_text('|'.join(entries_compact), encoding='utf-8')

print(f"Catálogo dual con fechas generado con éxito:")
print(f"  - Total objetos únicos: {len(objects_rich)}")
print(f"  - En Desarrollo: {len(dev_set)}")
print(f"  - En Producción: {len(prod_set)}")
print(f"  - Objetos con actualizaciones registradas: {sum(1 for o in objects_rich if o['has_updates'])}")
print(f"  - Objetos sin actualizaciones (versión inicial): {sum(1 for o in objects_rich if not o['has_updates'])}")
