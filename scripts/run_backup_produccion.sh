#!/usr/bin/env bash
# =============================================================================
# Script de ejecucion para Produccion en Linux
# =============================================================================
set -e

# Posicionarse en la raiz del proyecto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Activar entorno virtual si existe, o usar python3 del sistema
if [ -d "venv" ]; then
    source venv/bin/activate
elif [ -d ".venv" ]; then
    source .venv/bin/activate
fi

python3 scripts/backup_agent.py --env produccion
