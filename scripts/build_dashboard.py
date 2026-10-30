# Script constructor para dashboard.html con soporte dual de ambientes (Desarrollo y Producción)
import json
from pathlib import Path

repo_dir = Path(__file__).resolve().parent.parent

# Leer catálogo dual generado desde Git
cat_text = (repo_dir / 'embedded_catalog_dual.txt').read_text(encoding='utf-8')
status_content = (repo_dir / 'status.json').read_text(encoding='utf-8')

html_content = f"""<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Agente Backup Oracle 23ai | Dashboard iOS Glass</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    :root {{
      --font-system: -apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Plus Jakarta Sans", system-ui, sans-serif;
      --font-mono: "JetBrains Mono", "SF Mono", Menlo, Consolas, monospace;
      
      --glass-bg: rgba(255, 255, 255, 0.08);
      --glass-bg-hover: rgba(255, 255, 255, 0.12);
      --glass-bg-active: rgba(255, 255, 255, 0.18);
      --glass-border: rgba(255, 255, 255, 0.16);
      --glass-border-bright: rgba(255, 255, 255, 0.35);
      --glass-highlight: inset 0 1px 1px 0 rgba(255, 255, 255, 0.25);
      --glass-shadow: 0 24px 60px -12px rgba(0, 0, 0, 0.45), 0 8px 24px -4px rgba(0, 0, 0, 0.3);
      
      --blur-strength: 32px;
      --blur-sat: 190%;
      
      --accent-dev: #38bdf8;
      --accent-dev-glow: rgba(56, 189, 248, 0.35);
      --accent-prod: #10b981;
      --accent-prod-glow: rgba(16, 185, 129, 0.35);
      --accent-warn: #f59e0b;
      --accent-danger: #ef4444;
      --accent-apple-blue: #007aff;
      
      --text-primary: #ffffff;
      --text-secondary: rgba(255, 255, 255, 0.72);
      --text-muted: rgba(255, 255, 255, 0.48);
    }}

    * {{
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }}

    body {{
      font-family: var(--font-system);
      background-color: #080911;
      color: var(--text-primary);
      min-height: 100vh;
      overflow-x: hidden;
      position: relative;
      padding-bottom: 60px;
    }}

    /* Fondo dinámico estilo iOS Wallpaper con esferas de luz desenfocadas */
    .ios-wallpaper {{
      position: fixed;
      inset: 0;
      z-index: 0;
      pointer-events: none;
      overflow: hidden;
    }}

    .orb {{
      position: absolute;
      border-radius: 50%;
      filter: blur(120px);
      opacity: 0.55;
      animation: floatOrb 22s ease-in-out infinite alternate;
    }}

    .orb-1 {{
      width: 550px;
      height: 550px;
      top: -10%;
      left: -5%;
      background: radial-gradient(circle, #6366f1 0%, rgba(99, 102, 241, 0) 70%);
      animation-duration: 25s;
    }}

    .orb-2 {{
      width: 650px;
      height: 650px;
      top: 15%;
      right: -10%;
      background: radial-gradient(circle, #0ea5e9 0%, rgba(14, 165, 233, 0) 70%);
      animation-duration: 28s;
      animation-delay: -5s;
    }}

    .orb-3 {{
      width: 500px;
      height: 500px;
      bottom: -10%;
      left: 30%;
      background: radial-gradient(circle, #10b981 0%, rgba(16, 185, 129, 0) 70%);
      animation-duration: 20s;
      animation-delay: -10s;
    }}

    .orb-4 {{
      width: 450px;
      height: 450px;
      top: 45%;
      left: 10%;
      background: radial-gradient(circle, #ec4899 0%, rgba(236, 72, 153, 0) 70%);
      animation-duration: 30s;
      animation-delay: -15s;
      opacity: 0.35;
    }}

    @keyframes floatOrb {{
      0% {{ transform: translate(0, 0) scale(1); }}
      50% {{ transform: translate(60px, 40px) scale(1.08); }}
      100% {{ transform: translate(-40px, 80px) scale(0.95); }}
    }}

    /* Contenedor principal */
    .app-container {{
      position: relative;
      z-index: 1;
      max-width: 1360px;
      margin: 0 auto;
      padding: 32px 24px;
    }}

    /* Barra Superior estilo Isla Dinámica / Glass iOS */
    .ios-header {{
      background: var(--glass-bg);
      backdrop-filter: blur(var(--blur-strength)) saturate(var(--blur-sat));
      -webkit-backdrop-filter: blur(var(--blur-strength)) saturate(var(--blur-sat));
      border: 1px solid var(--glass-border);
      box-shadow: var(--glass-highlight), var(--glass-shadow);
      border-radius: 28px;
      padding: 18px 28px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 20px;
      margin-bottom: 28px;
      transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
    }}

    .brand-group {{
      display: flex;
      align-items: center;
      gap: 16px;
    }}

    .apple-icon-chip {{
      width: 48px;
      height: 48px;
      border-radius: 14px;
      background: linear-gradient(135deg, rgba(255, 255, 255, 0.22), rgba(255, 255, 255, 0.05));
      border: 1px solid var(--glass-border-bright);
      box-shadow: var(--glass-highlight);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
      flex-shrink: 0;
    }}

    .brand-text h1 {{
      font-size: 20px;
      font-weight: 700;
      letter-spacing: -0.02em;
      color: #ffffff;
      display: flex;
      align-items: center;
      gap: 8px;
    }}

    .brand-text h1 span {{
      color: #38bdf8;
    }}

    .brand-text p {{
      font-size: 13px;
      color: var(--text-secondary);
      font-weight: 400;
      margin-top: 2px;
    }}

    /* Controles Superiores */
    .header-actions {{
      display: flex;
      align-items: center;
      gap: 12px;
      flex-wrap: wrap;
    }}

    .btn-glass {{
      background: var(--glass-bg);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
      border: 1px solid var(--glass-border);
      box-shadow: var(--glass-highlight);
      color: var(--text-primary);
      padding: 10px 18px;
      border-radius: 16px;
      font-family: var(--font-system);
      font-size: 13.5px;
      font-weight: 600;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
      text-decoration: none;
      user-select: none;
    }}

    .btn-glass:hover {{
      background: var(--glass-bg-hover);
      border-color: var(--glass-border-bright);
      transform: translateY(-1.5px);
    }}

    .btn-glass:active {{
      transform: translateY(1px) scale(0.98);
      background: var(--glass-bg-active);
    }}

    .btn-glass.primary {{
      background: linear-gradient(135deg, rgba(0, 122, 255, 0.75), rgba(99, 102, 241, 0.75));
      border: 1px solid rgba(255, 255, 255, 0.3);
      box-shadow: 0 4px 18px rgba(0, 122, 255, 0.4), var(--glass-highlight);
    }}

    .btn-glass.primary:hover {{
      background: linear-gradient(135deg, rgba(0, 122, 255, 0.9), rgba(99, 102, 241, 0.9));
      box-shadow: 0 6px 24px rgba(0, 122, 255, 0.55), var(--glass-highlight);
    }}

    /* Segmented Control iOS (Pestañas Flotantes) */
    .segmented-control-wrapper {{
      display: flex;
      justify-content: center;
      margin-bottom: 28px;
    }}

    .segmented-control {{
      background: rgba(20, 22, 35, 0.65);
      backdrop-filter: blur(40px) saturate(200%);
      -webkit-backdrop-filter: blur(40px) saturate(200%);
      border: 1px solid rgba(255, 255, 255, 0.14);
      box-shadow: var(--glass-highlight), 0 12px 36px rgba(0, 0, 0, 0.35);
      padding: 6px;
      border-radius: 20px;
      display: inline-flex;
      gap: 6px;
      position: relative;
      max-width: 100%;
      overflow-x: auto;
    }}

    .segment-btn {{
      background: transparent;
      border: none;
      color: var(--text-secondary);
      font-family: var(--font-system);
      font-size: 14px;
      font-weight: 600;
      padding: 10px 20px;
      border-radius: 14px;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      white-space: nowrap;
      user-select: none;
    }}

    .segment-btn:hover {{
      color: var(--text-primary);
      background: rgba(255, 255, 255, 0.05);
    }}

    .segment-btn.active {{
      color: var(--text-primary);
      background: rgba(255, 255, 255, 0.16);
      backdrop-filter: blur(20px);
      border: 1px solid rgba(255, 255, 255, 0.25);
      box-shadow: var(--glass-highlight), 0 6px 18px rgba(0, 0, 0, 0.25);
    }}

    /* Contenido de pestañas */
    .tab-content {{
      display: none;
      animation: fadeInTab 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }}

    .tab-content.active {{
      display: block;
    }}

    @keyframes fadeInTab {{
      from {{
        opacity: 0;
        transform: translateY(12px) scale(0.99);
      }}
      to {{
        opacity: 1;
        transform: translateY(0) scale(1);
      }}
    }}

    /* Grid de Ambientes */
    .environments-grid {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(480px, 1fr));
      gap: 26px;
      margin-bottom: 30px;
    }}

    @media (max-width: 640px) {{
      .environments-grid {{
        grid-template-columns: 1fr;
      }}
    }}

    /* Tarjeta de Vidrio de Ambiente */
    .glass-card {{
      background: var(--glass-bg);
      backdrop-filter: blur(var(--blur-strength)) saturate(var(--blur-sat));
      -webkit-backdrop-filter: blur(var(--blur-strength)) saturate(var(--blur-sat));
      border: 1px solid var(--glass-border);
      box-shadow: var(--glass-highlight), var(--glass-shadow);
      border-radius: 28px;
      padding: 28px;
      position: relative;
      overflow: hidden;
      transition: all 0.35s cubic-bezier(0.16, 1, 0.3, 1);
    }}

    .glass-card:hover {{
      background: var(--glass-bg-hover);
      border-color: var(--glass-border-bright);
      transform: translateY(-3px);
      box-shadow: var(--glass-highlight), 0 30px 70px -10px rgba(0, 0, 0, 0.55);
    }}

    .glass-card.dev-card::before {{
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 4px;
      background: linear-gradient(90deg, #38bdf8, #818cf8);
    }}

    .glass-card.prod-card::before {{
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 4px;
      background: linear-gradient(90deg, #10b981, #06b6d4);
    }}

    .card-header {{
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 22px;
      gap: 16px;
    }}

    .env-badge-title {{
      display: flex;
      align-items: center;
      gap: 12px;
    }}

    .env-icon-box {{
      width: 44px;
      height: 44px;
      border-radius: 14px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 22px;
      box-shadow: var(--glass-highlight);
    }}

    .dev-card .env-icon-box {{
      background: rgba(56, 189, 248, 0.15);
      border: 1px solid rgba(56, 189, 248, 0.35);
      color: var(--accent-dev);
    }}

    .prod-card .env-icon-box {{
      background: rgba(16, 185, 129, 0.15);
      border: 1px solid rgba(16, 185, 129, 0.35);
      color: var(--accent-prod);
    }}

    .env-titles h2 {{
      font-size: 20px;
      font-weight: 700;
      letter-spacing: -0.01em;
    }}

    .env-titles .schema-tag {{
      font-size: 12px;
      font-family: var(--font-mono);
      color: var(--text-secondary);
      background: rgba(255, 255, 255, 0.08);
      padding: 2px 8px;
      border-radius: 6px;
      margin-top: 4px;
      display: inline-block;
    }}

    /* Píldora de estado estilo iOS */
    .status-pill {{
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 6px 14px;
      border-radius: 30px;
      font-size: 12.5px;
      font-weight: 700;
      letter-spacing: 0.02em;
      text-transform: uppercase;
      box-shadow: var(--glass-highlight);
    }}

    .status-pill.success {{
      background: rgba(16, 185, 129, 0.16);
      border: 1px solid rgba(16, 185, 129, 0.4);
      color: #34d399;
    }}

    .status-pill.success .pulse-dot {{
      width: 8px;
      height: 8px;
      border-radius: 50%;
      background-color: #10b981;
      box-shadow: 0 0 10px #10b981;
      animation: pulseGreen 2s infinite ease-in-out;
    }}

    @keyframes pulseGreen {{
      0%, 100% {{ transform: scale(1); opacity: 1; }}
      50% {{ transform: scale(1.4); opacity: 0.5; }}
    }}

    /* Métricas Clave */
    .metrics-row {{
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 12px;
      margin-bottom: 22px;
    }}

    @media (max-width: 520px) {{
      .metrics-row {{
        grid-template-columns: repeat(2, 1fr);
      }}
    }}

    .metric-chip {{
      background: rgba(255, 255, 255, 0.04);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 18px;
      padding: 14px 12px;
      text-align: center;
      transition: background 0.2s;
    }}

    .metric-chip:hover {{
      background: rgba(255, 255, 255, 0.08);
    }}

    .metric-value {{
      font-size: 22px;
      font-weight: 700;
      letter-spacing: -0.02em;
      color: #ffffff;
      line-height: 1.1;
      margin-bottom: 4px;
    }}

    .metric-label {{
      font-size: 11px;
      font-weight: 500;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }}

    /* Widget de Commit */
    .commit-glass-widget {{
      background: rgba(0, 0, 0, 0.28);
      border: 1px solid rgba(255, 255, 255, 0.12);
      border-radius: 18px;
      padding: 16px 18px;
      margin-bottom: 18px;
    }}

    .commit-header-line {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;
    }}

    .commit-tag {{
      font-size: 12px;
      color: var(--text-muted);
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 6px;
    }}

    .commit-actions {{
      display: flex;
      align-items: center;
      gap: 8px;
    }}

    .hash-badge {{
      font-family: var(--font-mono);
      font-size: 13px;
      font-weight: 600;
      background: rgba(255, 255, 255, 0.12);
      border: 1px solid rgba(255, 255, 255, 0.2);
      padding: 3px 10px;
      border-radius: 8px;
      color: #93c5fd;
      letter-spacing: 0.02em;
    }}

    .btn-icon-tiny {{
      background: rgba(255, 255, 255, 0.08);
      border: 1px solid rgba(255, 255, 255, 0.16);
      color: var(--text-primary);
      width: 28px;
      height: 28px;
      border-radius: 8px;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      font-size: 13px;
      transition: all 0.2s;
    }}

    .btn-icon-tiny:hover {{
      background: rgba(255, 255, 255, 0.2);
      transform: scale(1.06);
    }}

    .commit-message {{
      font-family: var(--font-mono);
      font-size: 12.5px;
      color: var(--text-secondary);
      line-height: 1.4;
      background: rgba(0, 0, 0, 0.2);
      padding: 8px 12px;
      border-radius: 10px;
      word-break: break-word;
    }}

    /* Fila de Detalles Inferior */
    .card-footer-info {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 12px;
      color: var(--text-muted);
      border-top: 1px solid rgba(255, 255, 255, 0.08);
      padding-top: 14px;
      flex-wrap: wrap;
      gap: 10px;
    }}

    .card-footer-info span {{
      display: flex;
      align-items: center;
      gap: 5px;
    }}

    /* Acordeón de Cambios */
    .changed-files-box {{
      margin-top: 16px;
      background: rgba(0, 0, 0, 0.2);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 14px;
      overflow: hidden;
    }}

    .changed-files-toggle {{
      width: 100%;
      background: transparent;
      border: none;
      padding: 10px 14px;
      color: var(--text-secondary);
      font-size: 12px;
      font-weight: 600;
      display: flex;
      justify-content: space-between;
      align-items: center;
      cursor: pointer;
      text-align: left;
    }}

    .changed-files-toggle:hover {{
      color: var(--text-primary);
      background: rgba(255, 255, 255, 0.04);
    }}

    .changed-files-list {{
      display: none;
      padding: 10px 14px;
      font-family: var(--font-mono);
      font-size: 11.5px;
      color: #cbd5e1;
      max-height: 200px;
      overflow-y: auto;
      border-top: 1px solid rgba(255, 255, 255, 0.06);
    }}

    .changed-files-list.open {{
      display: block;
    }}

    .changed-file-item {{
      padding: 4px 0;
      border-bottom: 1px dashed rgba(255, 255, 255, 0.06);
      word-break: break-all;
    }}

    .changed-file-item:last-child {{
      border-bottom: none;
    }}

    .tag-rename {{ color: #f59e0b; font-weight: bold; }}
    .tag-add {{ color: #10b981; font-weight: bold; }}
    .tag-mod {{ color: #38bdf8; font-weight: bold; }}

    /* ========================================================
       ESTILOS DEL BUSCADOR DE OBJETOS (iOS SPOTLIGHT GLASS)
       ======================================================== */
    .search-section-container {{
      background: var(--glass-bg);
      backdrop-filter: blur(var(--blur-strength)) saturate(var(--blur-sat));
      -webkit-backdrop-filter: blur(var(--blur-strength)) saturate(var(--blur-sat));
      border: 1px solid var(--glass-border);
      box-shadow: var(--glass-highlight), var(--glass-shadow);
      border-radius: 28px;
      padding: 32px;
      margin-bottom: 30px;
    }}

    /* Selector de Ambiente en Buscador */
    .env-selector-row {{
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 22px;
      flex-wrap: wrap;
    }}

    .env-toggle-pill {{
      background: rgba(255, 255, 255, 0.05);
      border: 1px solid rgba(255, 255, 255, 0.14);
      color: var(--text-secondary);
      font-size: 13.5px;
      font-weight: 600;
      padding: 9px 20px;
      border-radius: 16px;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
      user-select: none;
    }}

    .env-toggle-pill:hover {{
      background: rgba(255, 255, 255, 0.12);
      color: #ffffff;
      transform: translateY(-1px);
    }}

    .env-toggle-pill.active {{
      background: linear-gradient(135deg, rgba(0, 122, 255, 0.4), rgba(99, 102, 241, 0.4));
      border-color: #007aff;
      color: #ffffff;
      box-shadow: 0 4px 16px rgba(0, 122, 255, 0.45);
    }}

    .search-box-wrapper {{
      position: relative;
      margin-bottom: 20px;
    }}

    .ios-search-input {{
      width: 100%;
      background: rgba(15, 18, 30, 0.65);
      backdrop-filter: blur(20px);
      border: 1.5px solid rgba(255, 255, 255, 0.16);
      box-shadow: var(--glass-highlight), 0 8px 30px rgba(0, 0, 0, 0.35);
      border-radius: 20px;
      padding: 16px 52px 16px 54px;
      color: #ffffff;
      font-family: var(--font-system);
      font-size: 16px;
      font-weight: 500;
      outline: none;
      transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
    }}

    .ios-search-input:focus {{
      border-color: #007aff;
      background: rgba(20, 24, 40, 0.85);
      box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.25), 0 12px 35px rgba(0, 0, 0, 0.45);
    }}

    .search-icon-left {{
      position: absolute;
      left: 20px;
      top: 50%;
      transform: translateY(-50%);
      font-size: 20px;
      color: var(--text-muted);
      pointer-events: none;
    }}

    .search-btn-clear {{
      position: absolute;
      right: 18px;
      top: 50%;
      transform: translateY(-50%);
      background: rgba(255, 255, 255, 0.12);
      border: none;
      color: var(--text-secondary);
      width: 26px;
      height: 26px;
      border-radius: 50%;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 13px;
      transition: all 0.2s;
    }}

    .search-btn-clear:hover {{
      background: rgba(255, 255, 255, 0.25);
      color: #ffffff;
    }}

    /* Categorías de Filtro (Píldoras) */
    .filter-pills-row {{
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      margin-bottom: 22px;
    }}

    .filter-pill {{
      background: rgba(255, 255, 255, 0.05);
      border: 1px solid rgba(255, 255, 255, 0.12);
      color: var(--text-secondary);
      font-size: 12.5px;
      font-weight: 600;
      padding: 6px 14px;
      border-radius: 20px;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 6px;
      transition: all 0.2s;
      user-select: none;
    }}

    .filter-pill:hover {{
      background: rgba(255, 255, 255, 0.1);
      color: #ffffff;
    }}

    .filter-pill.active {{
      background: rgba(0, 122, 255, 0.25);
      border-color: #007aff;
      color: #ffffff;
      box-shadow: 0 2px 10px rgba(0, 122, 255, 0.35);
    }}

    .filter-pill .pill-badge {{
      font-size: 11px;
      background: rgba(255, 255, 255, 0.12);
      padding: 1px 6px;
      border-radius: 10px;
    }}

    /* Barra de conteo de resultados */
    .search-stats-bar {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 13px;
      color: var(--text-muted);
      margin-bottom: 18px;
      padding-bottom: 12px;
      border-bottom: 1px solid rgba(255, 255, 255, 0.08);
      flex-wrap: wrap;
      gap: 10px;
    }}

    /* ========================================================
       FICHA DE RESULTADO EXCLUSIVA PARA UN SOLO OBJETO
       ======================================================== */
    .single-object-view {{
      display: none;
      animation: fadeInTab 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }}

    .single-object-card {{
      background: rgba(18, 22, 38, 0.88);
      backdrop-filter: blur(40px) saturate(200%);
      -webkit-backdrop-filter: blur(40px) saturate(200%);
      border: 1.5px solid rgba(255, 255, 255, 0.2);
      box-shadow: var(--glass-highlight), 0 30px 80px rgba(0, 0, 0, 0.6);
      border-radius: 24px;
      padding: 32px;
      position: relative;
    }}

    .single-object-header {{
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 20px;
      margin-bottom: 24px;
      flex-wrap: wrap;
    }}

    .single-obj-title-group {{
      display: flex;
      align-items: center;
      gap: 16px;
    }}

    .single-obj-icon-box {{
      width: 58px;
      height: 58px;
      border-radius: 18px;
      background: linear-gradient(135deg, rgba(255, 255, 255, 0.18), rgba(255, 255, 255, 0.04));
      border: 1px solid var(--glass-border-bright);
      box-shadow: var(--glass-highlight);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 28px;
      flex-shrink: 0;
    }}

    .single-obj-name-wrap h2 {{
      font-size: 26px;
      font-weight: 800;
      letter-spacing: -0.02em;
      color: #ffffff;
      word-break: break-all;
    }}

    .single-obj-type-badge {{
      display: inline-block;
      font-family: var(--font-mono);
      font-size: 12px;
      font-weight: 600;
      text-transform: uppercase;
      padding: 3px 10px;
      border-radius: 8px;
      margin-top: 6px;
      background: rgba(56, 189, 248, 0.16);
      color: #38bdf8;
      border: 1px solid rgba(56, 189, 248, 0.35);
    }}

    .single-obj-status-badge {{
      padding: 8px 18px;
      border-radius: 30px;
      font-size: 13px;
      font-weight: 700;
      letter-spacing: 0.02em;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }}

    .status-active {{
      background: rgba(16, 185, 129, 0.16);
      border: 1px solid rgba(16, 185, 129, 0.45);
      color: #34d399;
    }}

    .status-deleted {{
      background: rgba(245, 158, 11, 0.16);
      border: 1px solid rgba(245, 158, 11, 0.45);
      color: #fbbf24;
    }}

    /* Grid de Datos del Objeto */
    .single-obj-grid {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }}

    .single-data-tile {{
      background: rgba(255, 255, 255, 0.04);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 16px;
      padding: 14px 16px;
    }}

    .data-tile-label {{
      font-size: 11px;
      font-weight: 600;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.04em;
      margin-bottom: 4px;
    }}

    .data-tile-value {{
      font-size: 14px;
      color: #ffffff;
      font-weight: 600;
      word-break: break-all;
      font-family: var(--font-mono);
    }}

    /* Banner Historial Sincronización */
    .single-sync-banner {{
      border-radius: 16px;
      padding: 16px 20px;
      margin-bottom: 24px;
      display: flex;
      align-items: flex-start;
      gap: 12px;
      font-size: 13.5px;
      line-height: 1.5;
      background: rgba(0, 122, 255, 0.1);
      border: 1px solid rgba(0, 122, 255, 0.28);
      color: #bfdbfe;
      transition: all 0.25s ease;
    }}

    .single-sync-banner.sync-success {{
      background: rgba(16, 185, 129, 0.12);
      border: 1px solid rgba(16, 185, 129, 0.35);
      color: #a7f3d0;
    }}
    .single-sync-banner.sync-success strong {{
      color: #6ee7b7;
    }}
    .single-sync-banner.sync-success code {{
      background: rgba(16, 185, 129, 0.2);
      color: #ffffff;
      padding: 2px 6px;
      border-radius: 4px;
    }}

    .single-sync-banner.sync-warning {{
      background: rgba(245, 158, 11, 0.15);
      border: 1px solid rgba(245, 158, 11, 0.4);
      color: #fef3c7;
    }}
    .single-sync-banner.sync-warning strong {{
      color: #fde68a;
    }}
    .single-sync-banner.sync-warning code {{
      background: rgba(245, 158, 11, 0.25);
      color: #ffffff;
      padding: 2px 6px;
      border-radius: 4px;
    }}

    /* Clases adaptables para Ficha Exclusiva */
    .single-obj-dates-box {{
      margin-bottom: 20px;
      background: rgba(255, 255, 255, 0.04);
      border: 1.5px solid rgba(255, 255, 255, 0.14);
      border-radius: 18px;
      padding: 18px 22px;
    }}
    .single-obj-primary-date {{
      font-size: 17px;
      font-weight: 700;
      color: #ffffff;
      margin-top: 5px;
    }}
    .single-obj-secondary-date {{
      font-size: 13px;
      color: var(--text-secondary);
      margin-top: 4px;
    }}
    .single-obj-oracle-date-row {{
      margin-top: 12px;
      padding-top: 10px;
      border-top: 1px solid rgba(255, 255, 255, 0.08);
      font-size: 12.5px;
      color: var(--text-muted);
      display: flex;
      align-items: center;
      gap: 6px;
    }}
    .data-tile-value.path-val {{ color: #93c5fd; }}
    .data-tile-value.branch-val {{ color: #38bdf8; }}
    .oracle-date-val {{ color: #93c5fd; }}
    .prim-date-accent-dev {{ color: #38bdf8; font-weight: 700; }}
    .prim-date-accent-prod {{ color: #34d399; font-weight: 700; }}
    .env-badge-item.dev-active {{ color: #38bdf8; font-weight: 600; }}
    .env-badge-item.prod-active {{ color: #34d399; font-weight: 600; }}
    .env-badge-item.inactive {{ color: #64748b; }}
    .single-obj-name-highlight {{ color: #ffffff; }}
    .obj-item-date-text {{ color: rgba(255, 255, 255, 0.65); }}

    /* Botonera de Acciones */
    .single-obj-actions {{
      display: flex;
      gap: 12px;
      flex-wrap: wrap;
      margin-bottom: 12px;
    }}

    /* Visor de Código DDL */
    .obj-ddl-viewer {{
      display: none;
      background: #090b12;
      border: 1.5px solid rgba(255, 255, 255, 0.18);
      border-radius: 18px;
      overflow: hidden;
      margin-top: 20px;
      box-shadow: 0 16px 40px rgba(0, 0, 0, 0.5);
    }}

    .obj-ddl-topbar {{
      background: rgba(255, 255, 255, 0.06);
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
      padding: 12px 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 13px;
      color: var(--text-secondary);
      flex-wrap: wrap;
      gap: 10px;
    }}

    .obj-ddl-code {{
      padding: 20px 24px;
      font-family: var(--font-mono);
      font-size: 13px;
      line-height: 1.65;
      color: #e2e8f0;
      max-height: 480px;
      overflow-y: auto;
      white-space: pre-wrap;
    }}

    /* Lista Múltiple de Resultados */
    .objects-results-list {{
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
      gap: 14px;
    }}

    .object-list-item {{
      background: rgba(255, 255, 255, 0.04);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 18px;
      padding: 14px 18px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      cursor: pointer;
      transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    }}

    .object-list-item:hover {{
      background: rgba(255, 255, 255, 0.1);
      border-color: rgba(255, 255, 255, 0.25);
      transform: translateY(-2px);
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
    }}

    .obj-item-info {{
      display: flex;
      align-items: center;
      gap: 12px;
      overflow: hidden;
    }}

    .obj-item-icon {{
      font-size: 20px;
      width: 38px;
      height: 38px;
      border-radius: 10px;
      background: rgba(255, 255, 255, 0.06);
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }}

    .obj-item-text {{
      overflow: hidden;
    }}

    .obj-item-name {{
      font-size: 14.5px;
      font-weight: 700;
      color: #ffffff;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }}

    .obj-item-sub {{
      font-size: 11.5px;
      color: var(--text-muted);
      margin-top: 2px;
      font-family: var(--font-mono);
      display: flex;
      align-items: center;
      gap: 6px;
      flex-wrap: wrap;
    }}

    .badge-mini {{
      font-size: 10px;
      padding: 1px 6px;
      border-radius: 4px;
      font-weight: 700;
    }}

    .badge-mini.del {{
      background: rgba(245, 158, 11, 0.2);
      color: #fbbf24;
    }}

    .badge-mini.act {{
      background: rgba(16, 185, 129, 0.2);
      color: #34d399;
    }}

    .badge-mini.dev {{
      background: rgba(56, 189, 248, 0.18);
      color: #38bdf8;
    }}

    .badge-mini.prod {{
      background: rgba(16, 185, 129, 0.18);
      color: #10b981;
    }}

    /* Pestaña: Manual de Implementación */
    .manual-container {{
      background: var(--glass-bg);
      backdrop-filter: blur(var(--blur-strength)) saturate(var(--blur-sat));
      -webkit-backdrop-filter: blur(var(--blur-strength)) saturate(var(--blur-sat));
      border: 1px solid var(--glass-border);
      box-shadow: var(--glass-highlight), var(--glass-shadow);
      border-radius: 28px;
      padding: 36px 40px;
      color: var(--text-primary);
    }}

    @media (max-width: 768px) {{
      .manual-container {{
        padding: 24px 20px;
      }}
    }}

    .manual-header {{
      border-bottom: 1px solid rgba(255, 255, 255, 0.12);
      padding-bottom: 24px;
      margin-bottom: 32px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 16px;
    }}

    .manual-header h2 {{
      font-size: 26px;
      font-weight: 800;
      letter-spacing: -0.02em;
    }}

    .manual-nav-pill-group {{
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
    }}

    .manual-quicklink {{
      background: rgba(255, 255, 255, 0.08);
      border: 1px solid rgba(255, 255, 255, 0.14);
      color: var(--text-secondary);
      font-size: 12.5px;
      font-weight: 600;
      padding: 6px 14px;
      border-radius: 20px;
      text-decoration: none;
      transition: all 0.2s;
    }}

    .manual-quicklink:hover {{
      background: rgba(255, 255, 255, 0.16);
      color: #ffffff;
      border-color: var(--glass-border-bright);
    }}

    .manual-section {{
      margin-bottom: 40px;
      scroll-margin-top: 20px;
    }}

    .manual-section h3 {{
      font-size: 20px;
      font-weight: 700;
      margin-bottom: 14px;
      color: #ffffff;
      display: flex;
      align-items: center;
      gap: 10px;
    }}

    .manual-section h3 .section-num {{
      width: 28px;
      height: 28px;
      border-radius: 8px;
      background: linear-gradient(135deg, #007aff, #6366f1);
      color: #ffffff;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      font-size: 13px;
      font-weight: 700;
    }}

    .manual-section p, .manual-section li {{
      font-size: 14.5px;
      line-height: 1.65;
      color: var(--text-secondary);
      margin-bottom: 12px;
    }}

    .manual-section ul, .manual-section ol {{
      padding-left: 24px;
      margin-bottom: 16px;
    }}

    .manual-section strong {{
      color: #ffffff;
    }}

    .manual-callout {{
      background: rgba(0, 122, 255, 0.1);
      border-left: 4px solid #007aff;
      border-radius: 0 16px 16px 0;
      padding: 16px 20px;
      margin: 18px 0;
      font-size: 14px;
      color: #bfdbfe;
    }}

    .manual-callout.tip {{
      background: rgba(16, 185, 129, 0.1);
      border-left-color: #10b981;
      color: #a7f3d0;
    }}

    .manual-callout.warning {{
      background: rgba(245, 158, 11, 0.1);
      border-left-color: #f59e0b;
      color: #fde68a;
    }}

    /* Bloques de Código Terminal estilo macOS / iOS */
    .code-terminal {{
      background: rgba(10, 12, 20, 0.75);
      border: 1px solid rgba(255, 255, 255, 0.14);
      border-radius: 18px;
      overflow: hidden;
      margin: 18px 0 24px;
      box-shadow: 0 12px 30px rgba(0, 0, 0, 0.35);
    }}

    .terminal-topbar {{
      background: rgba(255, 255, 255, 0.04);
      border-bottom: 1px solid rgba(255, 255, 255, 0.08);
      padding: 10px 16px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }}

    .terminal-dots {{
      display: flex;
      gap: 6px;
    }}

    .terminal-dot {{
      width: 11px;
      height: 11px;
      border-radius: 50%;
    }}

    .terminal-dot.red {{ background: #ff5f56; }}
    .terminal-dot.yellow {{ background: #ffbd2e; }}
    .terminal-dot.green {{ background: #27c93f; }}

    .terminal-title {{
      font-family: var(--font-mono);
      font-size: 12px;
      color: var(--text-muted);
    }}

    .btn-copy-code {{
      background: rgba(255, 255, 255, 0.08);
      border: 1px solid rgba(255, 255, 255, 0.15);
      color: var(--text-secondary);
      font-size: 11.5px;
      font-weight: 600;
      padding: 4px 10px;
      border-radius: 8px;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 5px;
      transition: all 0.2s;
    }}

    .btn-copy-code:hover {{
      background: rgba(255, 255, 255, 0.18);
      color: #ffffff;
    }}

    .code-terminal pre {{
      padding: 16px 20px;
      font-family: var(--font-mono);
      font-size: 13px;
      line-height: 1.55;
      color: #e2e8f0;
      overflow-x: auto;
    }}

    /* Pestaña: Visor de Logs */
    .logs-container {{
      background: var(--glass-bg);
      backdrop-filter: blur(var(--blur-strength)) saturate(var(--blur-sat));
      -webkit-backdrop-filter: blur(var(--blur-strength)) saturate(var(--blur-sat));
      border: 1px solid var(--glass-border);
      box-shadow: var(--glass-highlight), var(--glass-shadow);
      border-radius: 28px;
      padding: 30px;
    }}

    .logs-controls {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      flex-wrap: wrap;
      gap: 14px;
    }}

    .log-tabs {{
      display: flex;
      gap: 8px;
    }}

    .log-tab-btn {{
      background: rgba(255, 255, 255, 0.06);
      border: 1px solid rgba(255, 255, 255, 0.12);
      color: var(--text-secondary);
      padding: 8px 16px;
      border-radius: 12px;
      font-size: 13px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }}

    .log-tab-btn.active {{
      background: rgba(0, 122, 255, 0.25);
      border-color: #007aff;
      color: #ffffff;
    }}

    .log-viewer-screen {{
      background: #090a10;
      border: 1px solid rgba(255, 255, 255, 0.12);
      border-radius: 18px;
      padding: 20px;
      font-family: var(--font-mono);
      font-size: 12.5px;
      line-height: 1.6;
      color: #94a3b8;
      max-height: 600px;
      overflow-y: auto;
      white-space: pre-wrap;
      word-break: break-all;
    }}

    .log-line-info {{ color: #38bdf8; }}
    .log-line-success {{ color: #4ade80; font-weight: 600; }}
    .log-line-warn {{ color: #fbbf24; }}
    .log-line-err {{ color: #f87171; font-weight: 700; }}
    .log-line-time {{ color: #64748b; }}

    /* Toast Flotante estilo iOS */
    .ios-toast {{
      position: fixed;
      bottom: 30px;
      left: 50%;
      transform: translateX(-50%) translateY(100px);
      background: rgba(30, 35, 55, 0.85);
      backdrop-filter: blur(30px) saturate(180%);
      -webkit-backdrop-filter: blur(30px) saturate(180%);
      border: 1px solid rgba(255, 255, 255, 0.25);
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5), var(--glass-highlight);
      padding: 12px 24px;
      border-radius: 30px;
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 14px;
      font-weight: 600;
      color: #ffffff;
      z-index: 1000;
      transition: transform 0.35s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.35s;
      opacity: 0;
      pointer-events: none;
    }}

    .ios-toast.show {{
      transform: translateX(-50%) translateY(0);
      opacity: 1;
    }}

    .file-input-hidden {{
      display: none;
    }}

    /* ========================================================
       BOTÓN TOGGLE DE TEMA (CLARO / OSCURO)
       ======================================================== */
    .btn-theme-toggle {{
      background: var(--glass-bg);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
      border: 1px solid var(--glass-border);
      box-shadow: var(--glass-highlight);
      color: var(--text-primary);
      padding: 10px 18px;
      border-radius: 16px;
      font-family: var(--font-system);
      font-size: 13.5px;
      font-weight: 600;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 7px;
      transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
      user-select: none;
    }}

    .btn-theme-toggle:hover {{
      background: var(--glass-bg-hover);
      border-color: var(--glass-border-bright);
      transform: translateY(-1.5px);
    }}

    /* Banner resumen de objetos en tarjetas de ambientes */
    .obj-breakdown-banner {{
      margin: 16px 0 14px 0;
      padding: 12px 18px;
      border-radius: 16px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 13px;
      font-weight: 500;
      transition: all 0.2s;
    }}

    .obj-breakdown-banner .sep {{
      margin: 0 8px;
      opacity: 0.35;
    }}

    .dev-breakdown {{
      background: rgba(56, 189, 248, 0.09);
      border: 1px solid rgba(56, 189, 248, 0.25);
      color: var(--text-primary);
    }}

    .prod-breakdown {{
      background: rgba(16, 185, 129, 0.09);
      border: 1px solid rgba(16, 185, 129, 0.25);
      color: var(--text-primary);
    }}

    /* ========================================================
       MODO CLARO (LIGHT THEME) ESTILO APPLE FROSTED GLASS
       ======================================================== */
    [data-theme="light"] {{
      --bg-body: #f1f5f9;
      --glass-bg: rgba(255, 255, 255, 0.85);
      --glass-bg-hover: rgba(255, 255, 255, 0.95);
      --glass-bg-active: rgba(241, 245, 249, 0.95);
      --glass-border: rgba(0, 0, 0, 0.08);
      --glass-border-bright: rgba(0, 0, 0, 0.16);
      --glass-highlight: inset 0 1px 1px 0 rgba(255, 255, 255, 0.9);
      --glass-shadow: 0 20px 45px -10px rgba(0, 0, 0, 0.07), 0 4px 16px -2px rgba(0, 0, 0, 0.04);
      
      --text-primary: #0f172a;
      --text-secondary: #334155;
      --text-muted: #64748b;
    }}

    [data-theme="light"] body {{
      background-color: #f1f5f9;
      color: #0f172a;
    }}

    [data-theme="light"] .orb {{
      opacity: 0.20;
      filter: blur(140px);
    }}

    [data-theme="light"] .ios-header {{
      background: rgba(255, 255, 255, 0.85);
      border-color: rgba(0, 0, 0, 0.08);
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
    }}

    [data-theme="light"] .brand-text h1 {{
      color: #0f172a !important;
      background: none !important;
      -webkit-text-fill-color: #0f172a !important;
    }}

    [data-theme="light"] .brand-text h1 span {{
      color: #007aff !important;
      -webkit-text-fill-color: #007aff !important;
    }}

    [data-theme="light"] .apple-icon-chip {{
      background: #ffffff;
      border-color: rgba(0, 0, 0, 0.1);
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    }}

    [data-theme="light"] .brand-text p {{
      color: #475569;
    }}

    [data-theme="light"] .btn-glass,
    [data-theme="light"] .btn-theme-toggle {{
      background: #ffffff;
      border-color: rgba(0, 0, 0, 0.12);
      color: #0f172a;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
    }}

    [data-theme="light"] .btn-glass:hover,
    [data-theme="light"] .btn-theme-toggle:hover {{
      background: #f8fafc;
      border-color: rgba(0, 0, 0, 0.22);
      color: #007aff;
    }}

    [data-theme="light"] .btn-glass.primary {{
      background: linear-gradient(135deg, #007aff, #4f46e5);
      color: #ffffff;
      border-color: transparent;
      box-shadow: 0 4px 14px rgba(0, 122, 255, 0.3);
    }}

    [data-theme="light"] .segmented-control {{
      background: rgba(226, 232, 240, 0.85);
      border-color: rgba(0, 0, 0, 0.08);
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
    }}

    [data-theme="light"] .segment-btn {{
      color: #475569;
    }}

    [data-theme="light"] .segment-btn:hover {{
      color: #0f172a;
      background: rgba(255, 255, 255, 0.5);
    }}

    [data-theme="light"] .segment-btn.active {{
      color: #0f172a;
      background: #ffffff;
      border-color: rgba(0, 0, 0, 0.08);
      box-shadow: 0 3px 12px rgba(0, 0, 0, 0.08);
    }}

    [data-theme="light"] .glass-card {{
      background: rgba(255, 255, 255, 0.88);
      border-color: rgba(0, 0, 0, 0.09);
      box-shadow: 0 15px 40px rgba(0, 0, 0, 0.06);
    }}

    [data-theme="light"] .glass-card:hover {{
      background: #ffffff;
      box-shadow: 0 25px 60px rgba(0, 0, 0, 0.1);
    }}

    [data-theme="light"] .env-titles h2 {{
      color: #0f172a;
    }}

    [data-theme="light"] .env-titles .schema-tag {{
      background: #e2e8f0;
      color: #334155;
    }}

    [data-theme="light"] .metric-chip {{
      background: #f8fafc;
      border-color: rgba(0, 0, 0, 0.07);
      box-shadow: 0 1px 4px rgba(0, 0, 0, 0.02);
    }}

    [data-theme="light"] .metric-chip:hover {{
      background: #ffffff;
      border-color: rgba(0, 0, 0, 0.14);
    }}

    [data-theme="light"] .metric-value {{
      color: #0f172a;
    }}

    [data-theme="light"] .metric-label {{
      color: #64748b;
    }}

    [data-theme="light"] .dev-breakdown {{
      background: rgba(56, 189, 248, 0.12);
      border-color: rgba(56, 189, 248, 0.32);
      color: #0369a1;
    }}

    [data-theme="light"] .prod-breakdown {{
      background: rgba(16, 185, 129, 0.12);
      border-color: rgba(16, 185, 129, 0.32);
      color: #047857;
    }}

    [data-theme="light"] .commit-glass-widget {{
      background: #f8fafc;
      border-color: rgba(0, 0, 0, 0.08);
    }}

    [data-theme="light"] .commit-tag {{
      color: #475569;
    }}

    [data-theme="light"] .commit-message {{
      color: #1e293b;
    }}

    [data-theme="light"] .hash-badge {{
      background: #e0f2fe;
      border-color: #bae6fd;
      color: #0284c7;
    }}

    [data-theme="light"] .btn-icon-tiny {{
      background: #e2e8f0;
      color: #334155;
    }}

    [data-theme="light"] .btn-icon-tiny:hover {{
      background: #cbd5e1;
      color: #0f172a;
    }}

    [data-theme="light"] .changed-files-box {{
      border-color: rgba(0, 0, 0, 0.08);
    }}

    [data-theme="light"] .changed-files-toggle {{
      background: #f8fafc;
      color: #334155;
    }}

    [data-theme="light"] .changed-files-toggle:hover {{
      background: #f1f5f9;
      color: #0f172a;
    }}

    [data-theme="light"] .changed-files-list {{
      background: #ffffff;
      border-color: rgba(0, 0, 0, 0.06);
    }}

    [data-theme="light"] .changed-file-item {{
      border-bottom-color: rgba(0, 0, 0, 0.05);
      color: #334155;
    }}

    [data-theme="light"] .card-footer-info {{
      color: #64748b;
    }}

    [data-theme="light"] .search-section-container {{
      background: rgba(255, 255, 255, 0.88);
      border-color: rgba(0, 0, 0, 0.09);
      box-shadow: 0 15px 40px rgba(0, 0, 0, 0.06);
    }}

    [data-theme="light"] .search-section-container h2 {{
      color: #0f172a;
    }}

    [data-theme="light"] .ios-search-input {{
      background: #ffffff;
      color: #0f172a;
      border-color: rgba(0, 0, 0, 0.15);
      box-shadow: 0 4px 18px rgba(0, 0, 0, 0.04);
    }}

    [data-theme="light"] .ios-search-input:focus {{
      background: #ffffff;
      border-color: #007aff;
      box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.15), 0 8px 25px rgba(0, 0, 0, 0.08);
    }}

    [data-theme="light"] .search-icon-left {{
      color: #94a3b8;
    }}

    [data-theme="light"] .search-btn-clear {{
      background: #e2e8f0;
      color: #475569;
    }}

    [data-theme="light"] .search-btn-clear:hover {{
      background: #cbd5e1;
      color: #0f172a;
    }}

    [data-theme="light"] .env-toggle-pill {{
      background: #ffffff;
      border-color: rgba(0, 0, 0, 0.12);
      color: #475569;
    }}

    [data-theme="light"] .env-toggle-pill:hover {{
      background: #f8fafc;
      color: #0f172a;
      border-color: rgba(0, 0, 0, 0.2);
    }}

    [data-theme="light"] .env-toggle-pill.active {{
      background: linear-gradient(135deg, #007aff, #6366f1);
      border-color: #007aff;
      color: #ffffff;
      box-shadow: 0 4px 14px rgba(0, 122, 255, 0.3);
    }}

    [data-theme="light"] .filter-pill {{
      background: #ffffff;
      border-color: rgba(0, 0, 0, 0.12);
      color: #475569;
    }}

    [data-theme="light"] .filter-pill:hover {{
      background: #f8fafc;
      color: #0f172a;
    }}

    [data-theme="light"] .filter-pill.active {{
      background: rgba(0, 122, 255, 0.12);
      border-color: #007aff;
      color: #0284c7;
      box-shadow: 0 2px 8px rgba(0, 122, 255, 0.15);
    }}

    [data-theme="light"] .filter-pill .pill-badge {{
      background: #e2e8f0;
      color: #334155;
    }}

    [data-theme="light"] .search-stats-bar {{
      color: #64748b;
      border-bottom-color: rgba(0, 0, 0, 0.08);
    }}

    [data-theme="light"] .object-list-item {{
      background: #ffffff;
      border-color: rgba(0, 0, 0, 0.08);
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.02);
    }}

    [data-theme="light"] .object-list-item:hover {{
      background: #ffffff;
      border-color: #007aff;
      box-shadow: 0 8px 24px rgba(0, 122, 255, 0.12);
    }}

    [data-theme="light"] .obj-item-name {{
      color: #0f172a;
    }}

    [data-theme="light"] .obj-item-sub {{
      color: #64748b;
    }}

    [data-theme="light"] .obj-item-icon {{
      background: #f1f5f9;
      border-color: rgba(0, 0, 0, 0.08);
    }}

    [data-theme="light"] .single-object-card {{
      background: rgba(255, 255, 255, 0.96);
      border-color: rgba(0, 0, 0, 0.1);
      box-shadow: 0 20px 50px rgba(0, 0, 0, 0.08);
    }}

    [data-theme="light"] .single-obj-name-wrap h2 {{
      color: #0f172a;
    }}

    [data-theme="light"] .single-obj-icon-box {{
      background: #f1f5f9;
      border-color: rgba(0, 0, 0, 0.08);
    }}

    [data-theme="light"] #single-obj-dates-box {{
      background: #f8fafc;
      border-color: rgba(0, 0, 0, 0.08);
    }}

    [data-theme="light"] #single-obj-primary-date {{
      color: #0f172a;
    }}

    [data-theme="light"] #single-obj-secondary-date {{
      color: #475569;
    }}

    [data-theme="light"] #single-obj-oracle-date-row {{
      border-top-color: rgba(0, 0, 0, 0.06);
      color: #64748b;
    }}

    [data-theme="light"] #single-obj-oracle-date {{
      color: #0284c7;
    }}

    [data-theme="light"] .single-data-tile {{
      background: #f8fafc;
      border-color: rgba(0, 0, 0, 0.08);
    }}

    [data-theme="light"] .single-data-tile .data-tile-label {{
      color: #64748b;
    }}

    [data-theme="light"] .single-data-tile .data-tile-value {{
      color: #0f172a;
    }}

    [data-theme="light"] .single-obj-dates-box {{
      background: #f8fafc;
      border: 1.5px solid rgba(0, 0, 0, 0.09);
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.02);
    }}

    [data-theme="light"] .single-obj-primary-date {{
      color: #0f172a;
    }}

    [data-theme="light"] .single-obj-secondary-date {{
      color: #475569;
    }}

    [data-theme="light"] .single-obj-oracle-date-row {{
      border-top-color: rgba(0, 0, 0, 0.08);
      color: #64748b;
    }}

    [data-theme="light"] .data-tile-value.path-val {{
      color: #0284c7;
    }}

    [data-theme="light"] .data-tile-value.branch-val {{
      color: #0284c7;
      font-weight: 700;
    }}

    [data-theme="light"] .oracle-date-val {{
      color: #0284c7;
      font-weight: 700;
    }}

    [data-theme="light"] .prim-date-accent-dev {{
      color: #0284c7;
      font-weight: 700;
    }}

    [data-theme="light"] .prim-date-accent-prod {{
      color: #047857;
      font-weight: 700;
    }}

    [data-theme="light"] .env-badge-item.dev-active {{
      color: #0284c7;
      font-weight: 600;
    }}

    [data-theme="light"] .env-badge-item.prod-active {{
      color: #047857;
      font-weight: 600;
    }}

    [data-theme="light"] .env-badge-item.inactive {{
      color: #64748b;
    }}

    [data-theme="light"] .single-obj-name-highlight {{
      color: #0f172a;
    }}

    [data-theme="light"] .obj-item-date-text {{
      color: #475569;
    }}

    [data-theme="light"] .single-sync-banner {{
      background: #f0fdf4;
      border-color: #86efac;
      color: #166534;
    }}

    /* Banner Sincronización en Modo Claro - MÁXIMO CONTRASTE Y LEGIBILIDAD */
    [data-theme="light"] .single-sync-banner.sync-success {{
      background: #ecfdf5 !important;
      border: 1.5px solid #6ee7b7 !important;
      color: #065f46 !important;
      box-shadow: 0 4px 14px rgba(16, 185, 129, 0.08);
    }}

    [data-theme="light"] .single-sync-banner.sync-success strong,
    [data-theme="light"] .single-sync-banner.sync-success #single-sync-title {{
      color: #064e3b !important;
      font-weight: 700;
    }}

    [data-theme="light"] .single-sync-banner.sync-success p,
    [data-theme="light"] .single-sync-banner.sync-success #single-sync-detail {{
      color: #047857 !important;
      font-weight: 500;
    }}

    [data-theme="light"] .single-sync-banner.sync-success code {{
      background: #d1fae5 !important;
      color: #064e3b !important;
      border: 1px solid #a7f3d0;
      font-weight: 600;
    }}

    [data-theme="light"] .single-sync-banner.sync-warning {{
      background: #fffbeb !important;
      border: 1.5px solid #fcd34d !important;
      color: #92400e !important;
      box-shadow: 0 4px 14px rgba(245, 158, 11, 0.08);
    }}

    [data-theme="light"] .single-sync-banner.sync-warning strong,
    [data-theme="light"] .single-sync-banner.sync-warning #single-sync-title {{
      color: #78350f !important;
      font-weight: 700;
    }}

    [data-theme="light"] .single-sync-banner.sync-warning p,
    [data-theme="light"] .single-sync-banner.sync-warning #single-sync-detail {{
      color: #92400e !important;
      font-weight: 500;
    }}

    [data-theme="light"] .single-sync-banner.sync-warning code {{
      background: #fef3c7 !important;
      color: #78350f !important;
      border: 1px solid #fde68a;
      font-weight: 600;
    }}

    [data-theme="light"] .status-active {{
      background: #dcfce7;
      border-color: #86efac;
      color: #15803d;
    }}

    [data-theme="light"] .status-deleted {{
      background: #fef3c7;
      border-color: #fde68a;
      color: #b45309;
    }}

    [data-theme="light"] .badge-mini.act {{
      background: #dcfce7;
      color: #15803d;
      border: 1px solid #86efac;
    }}

    [data-theme="light"] .badge-mini.mod {{
      background: #e0f2fe;
      color: #0369a1;
      border: 1px solid #7dd3fc;
    }}

    [data-theme="light"] .badge-mini.del {{
      background: #fef3c7;
      color: #b45309;
      border: 1px solid #fde68a;
    }}

    [data-theme="light"] .badge-mini.dev {{
      background: #e0f2fe;
      color: #0369a1;
      border: 1px solid #bae6fd;
    }}

    [data-theme="light"] .badge-mini.prod {{
      background: #dcfce7;
      color: #047857;
      border: 1px solid #a7f3d0;
    }}

    [data-theme="light"] .manual-sidebar {{
      background: rgba(255, 255, 255, 0.88);
      border-color: rgba(0, 0, 0, 0.09);
      box-shadow: 0 10px 30px rgba(0,0,0,0.04);
    }}

    [data-theme="light"] .manual-nav-item {{
      color: #475569;
    }}

    [data-theme="light"] .manual-nav-item:hover {{
      background: #f1f5f9;
      color: #0f172a;
    }}

    [data-theme="light"] .manual-nav-item.active {{
      background: #e0f2fe;
      color: #0284c7;
      font-weight: 700;
    }}

    [data-theme="light"] .manual-content {{
      background: rgba(255, 255, 255, 0.88);
      border-color: rgba(0, 0, 0, 0.09);
      box-shadow: 0 10px 30px rgba(0,0,0,0.04);
      color: #1e293b;
    }}

    [data-theme="light"] .manual-section h3 {{
      color: #0f172a;
      border-bottom-color: rgba(0, 0, 0, 0.08);
    }}

    [data-theme="light"] .manual-section p,
    [data-theme="light"] .manual-section li {{
      color: #334155;
    }}

    [data-theme="light"] .manual-section code {{
      background: #e2e8f0;
      color: #0f172a;
      border-color: #cbd5e1;
    }}

    [data-theme="light"] .logs-container {{
      background: rgba(255, 255, 255, 0.88);
      border-color: rgba(0, 0, 0, 0.09);
      box-shadow: 0 10px 30px rgba(0,0,0,0.04);
    }}

    [data-theme="light"] .logs-controls h2 {{
      color: #0f172a;
    }}

    [data-theme="light"] .log-tab-btn {{
      background: #ffffff;
      border-color: rgba(0, 0, 0, 0.12);
      color: #475569;
    }}

    [data-theme="light"] .log-tab-btn.active {{
      background: #007aff;
      color: #ffffff;
      border-color: #007aff;
    }}

    [data-theme="light"] .ios-toast {{
      background: rgba(255, 255, 255, 0.95);
      color: #0f172a;
      border-color: rgba(0, 0, 0, 0.12);
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.12);
    }}
  </style>
  <script>
    // Inicialización inmediata del tema para evitar parpadeos
    (function() {{
      const saved = localStorage.getItem('oracle_dashboard_theme');
      const prefersLight = window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches;
      const theme = saved || (prefersLight ? 'light' : 'dark');
      document.documentElement.setAttribute('data-theme', theme);
    }})();
  </script>
</head>
<body>

  <!-- Fondo dinámico con orbes iOS -->
  <div class="ios-wallpaper">
    <div class="orb orb-1"></div>
    <div class="orb orb-2"></div>
    <div class="orb orb-3"></div>
    <div class="orb orb-4"></div>
  </div>

  <div class="app-container">

    <!-- Header Principal Vidrio iOS -->
    <header class="ios-header">
      <div class="brand-group">
        <div class="apple-icon-chip">
          <span>⚡</span>
        </div>
        <div class="brand-text">
          <h1>Oracle 23ai <span>Sync & Backup</span></h1>
          <p>Versionamiento continuo hacia GitHub | TEKER_DEV & TEKER_PROD</p>
        </div>
      </div>

      <div class="header-actions">
        <button class="btn-glass" onclick="cambiarPestana('buscador'); document.getElementById('obj-search-input').focus();">
          <span>🔍</span> Buscar Objeto
        </button>
        <button class="btn-glass" id="btn-refresh" onclick="cargarStatus()">
          <span>🔄</span> Sincronizar Estado
        </button>
        <button class="btn-glass" onclick="document.getElementById('file-input-manual').click()" title="Cargar status.json manualmente si usas file:///">
          <span>📂</span> Cargar JSON
        </button>
        <input type="file" id="file-input-manual" class="file-input-hidden" accept=".json" onchange="cargarDesdeArchivoLocal(event)">
        <button class="btn-theme-toggle" id="btn-theme-toggle" onclick="alternarTema()" title="Alternar entre Modo Claro y Oscuro">
          <span id="theme-icon">☀️</span>
          <span id="theme-label">Claro</span>
        </button>
        <a href="https://github.com/vqorlando68/agente_backup" target="_blank" class="btn-glass primary">
          <span>🐙</span> Repositorio Git
        </a>
      </div>
    </header>

    <!-- Segmented Control estilo iPhone / iOS Dock -->
    <div class="segmented-control-wrapper">
      <nav class="segmented-control">
        <button class="segment-btn active" id="btn-tab-ambientes" onclick="cambiarPestana('ambientes')">
          <span>📊</span> Ambientes & Estado
        </button>
        <button class="segment-btn" id="btn-tab-buscador" onclick="cambiarPestana('buscador')">
          <span>🔍</span> Buscador de Objetos
        </button>
        <button class="segment-btn" id="btn-tab-manual" onclick="cambiarPestana('manual')">
          <span>📘</span> Manual de Implementación
        </button>
        <button class="segment-btn" id="btn-tab-logs" onclick="cambiarPestana('logs')">
          <span>📜</span> Visor de Logs
        </button>
      </nav>
    </div>

    <!-- PESTAÑA 1: AMBIENTES & MONITOREO -->
    <main id="tab-ambientes" class="tab-content active">
      
      <div class="environments-grid">

        <!-- Tarjeta Ambiente Desarrollo -->
        <article class="glass-card dev-card">
          <div class="card-header">
            <div class="env-badge-title">
              <div class="env-icon-box">💻</div>
              <div class="env-titles">
                <h2>Desarrollo</h2>
                <span class="schema-tag" id="dev-schema">TEKER_DEV</span>
              </div>
            </div>
            <div class="status-pill success" id="dev-pill">
              <span class="pulse-dot"></span>
              <span id="dev-estado">EXITOSO</span>
            </div>
          </div>

          <!-- Métricas -->
          <div class="metrics-row">
            <div class="metric-chip">
              <div class="metric-value" id="dev-totales">2,328</div>
              <div class="metric-label">Total Obj.</div>
            </div>
            <div class="metric-chip">
              <div class="metric-value" id="dev-actualizados" style="color: #38bdf8;">2</div>
              <div class="metric-label">Actualizados</div>
            </div>
            <div class="metric-chip">
              <div class="metric-value" id="dev-omitidos" style="color: #94a3b8;">2,326</div>
              <div class="metric-label">Sin Cambio</div>
            </div>
            <div class="metric-chip">
              <div class="metric-value" id="dev-borrados" style="color: #f59e0b;">8</div>
              <div class="metric-label">Borrados</div>
            </div>
          </div>

          <!-- Resumen de Objetos por Tipo -->
          <div class="obj-breakdown-banner dev-breakdown">
            <div>
              <span>📊 <strong>457</strong> Tablas</span>
              <span class="sep">|</span>
              <span>📦 <strong>1,003</strong> Packages</span>
              <span class="sep">|</span>
              <span>⏱️ <strong>4</strong> Jobs</span>
            </div>
            <button class="btn-glass" style="padding: 5px 12px; font-size: 12px; border-radius: 10px;" onclick="irABuscadorAmbiente('desarrollo', 'tables')">
              🔍 Explorar Tablas
            </button>
          </div>

          <!-- Commit Widget -->
          <div class="commit-glass-widget">
            <div class="commit-header-line">
              <div class="commit-tag">
                <span>🏷️</span> Commit Git (rama <strong id="dev-rama">desarrollo</strong>):
              </div>
              <div class="commit-actions">
                <span class="hash-badge" id="dev-hash">b3fc1e1</span>
                <button class="btn-icon-tiny" title="Copiar hash del commit" onclick="copiarAlPortapapeles(document.getElementById('dev-hash').innerText)">📋</button>
                <a id="dev-commit-link" href="https://github.com/vqorlando68/agente_backup/commit/b3fc1e1" target="_blank" class="btn-icon-tiny" title="Ver commit en GitHub">🔗</a>
              </div>
            </div>
            <div class="commit-message" id="dev-msg">
              chore(sync): backup objetos desarrollo [2026-10-17 09:33:01]
            </div>
          </div>

          <!-- Lista de Cambios Recientes (Acordeón) -->
          <div class="changed-files-box">
            <button class="changed-files-toggle" onclick="toggleAcordeon('dev-changed-list')">
              <span>📁 Objetos modificados o borrados en el último ciclo (<span id="dev-changed-count">8</span>)</span>
              <span id="dev-toggle-icon">▼</span>
            </button>
            <div id="dev-changed-list" class="changed-files-list">
              <!-- Render dinámico -->
            </div>
          </div>

          <!-- Footer con Timestamp y Duración -->
          <div class="card-footer-info">
            <span>🕒 Ejecutado: <strong id="dev-fecha">2026-10-17 09:33:04</strong></span>
            <span>⏱️ Duración: <strong id="dev-duracion">12s</strong></span>
          </div>
        </article>

        <!-- Tarjeta Ambiente Producción -->
        <article class="glass-card prod-card">
          <div class="card-header">
            <div class="env-badge-title">
              <div class="env-icon-box">🛡️</div>
              <div class="env-titles">
                <h2>Producción</h2>
                <span class="schema-tag" id="prod-schema">TEKER_PROD</span>
              </div>
            </div>
            <div class="status-pill success" id="prod-pill">
              <span class="pulse-dot"></span>
              <span id="prod-estado">EXITOSO</span>
            </div>
          </div>

          <!-- Métricas -->
          <div class="metrics-row">
            <div class="metric-chip">
              <div class="metric-value" id="prod-totales">2,399</div>
              <div class="metric-label">Total Obj.</div>
            </div>
            <div class="metric-chip">
              <div class="metric-value" id="prod-actualizados" style="color: #34d399;">3</div>
              <div class="metric-label">Actualizados</div>
            </div>
            <div class="metric-chip">
              <div class="metric-value" id="prod-omitidos" style="color: #94a3b8;">2,396</div>
              <div class="metric-label">Sin Cambio</div>
            </div>
            <div class="metric-chip">
              <div class="metric-value" id="prod-borrados" style="color: #f59e0b;">0</div>
              <div class="metric-label">Borrados</div>
            </div>
          </div>

          <!-- Resumen de Objetos por Tipo -->
          <div class="obj-breakdown-banner prod-breakdown">
            <div>
              <span>📊 <strong>515</strong> Tablas</span>
              <span class="sep">|</span>
              <span>📦 <strong>942</strong> Packages</span>
              <span class="sep">|</span>
              <span>⏱️ <strong>45</strong> Jobs</span>
            </div>
            <button class="btn-glass" style="padding: 5px 12px; font-size: 12px; border-radius: 10px;" onclick="irABuscadorAmbiente('produccion', 'tables')">
              🔍 Explorar Tablas
            </button>
          </div>

          <!-- Commit Widget -->
          <div class="commit-glass-widget">
            <div class="commit-header-line">
              <div class="commit-tag">
                <span>🏷️</span> Commit Git (rama <strong id="prod-rama">produccion</strong>):
              </div>
              <div class="commit-actions">
                <span class="hash-badge" id="prod-hash">79ad7cc</span>
                <button class="btn-icon-tiny" title="Copiar hash del commit" onclick="copiarAlPortapapeles(document.getElementById('prod-hash').innerText)">📋</button>
                <a id="prod-commit-link" href="https://github.com/vqorlando68/agente_backup/commit/79ad7cc" target="_blank" class="btn-icon-tiny" title="Ver commit en GitHub">🔗</a>
              </div>
            </div>
            <div class="commit-message" id="prod-msg">
              chore(sync): backup objetos produccion [2026-10-17 07:22:20]
            </div>
          </div>

          <!-- Lista de Cambios Recientes (Acordeón) -->
          <div class="changed-files-box">
            <button class="changed-files-toggle" onclick="toggleAcordeon('prod-changed-list')">
              <span>📁 Objetos modificados o borrados en el último ciclo (<span id="prod-changed-count">0</span>)</span>
              <span id="prod-toggle-icon">▼</span>
            </button>
            <div id="prod-changed-list" class="changed-files-list">
              <!-- Render dinámico -->
            </div>
          </div>

          <!-- Footer con Timestamp y Duración -->
          <div class="card-footer-info">
            <span>🕒 Ejecutado: <strong id="prod-fecha">2026-10-17 09:30:04</strong></span>
            <span>⏱️ Duración: <strong id="prod-duracion">18s</strong></span>
          </div>
        </article>

      </div>

    </main>

    <!-- PESTAÑA 2: BUSCADOR DE OBJETOS ORACLE (CON SELECTOR DE AMBIENTE DINÁMICO) -->
    <section id="tab-buscador" class="tab-content">
      <div class="search-section-container">
        
        <div style="margin-bottom: 22px;">
          <h2 style="font-size: 24px; font-weight: 800; letter-spacing: -0.02em;">🔍 Buscador de Objetos Oracle</h2>
          <p style="color: var(--text-secondary); font-size: 13.5px; margin-top: 4px;">
            Consulta el estado, historial y visualiza el código DDL (con comentarios) de cualquier tabla, vista, package, función, procedimiento o job.
          </p>
        </div>

        <!-- Selector de Ambiente: Ambos / Desarrollo / Producción -->
        <div class="env-selector-row">
          <span style="font-size: 13px; font-weight: 700; color: var(--text-muted); margin-right: 4px;">🏢 Ambiente:</span>
          <button class="env-toggle-pill active" id="btn-env-todos" onclick="seleccionarAmbienteBusqueda('todos', this)">
            🌐 Ambos Ambientes (<span id="env-count-todos">0</span>)
          </button>
          <button class="env-toggle-pill" id="btn-env-desarrollo" onclick="seleccionarAmbienteBusqueda('desarrollo', this)">
            💻 Desarrollo (<span id="env-count-desarrollo">0</span>)
          </button>
          <button class="env-toggle-pill" id="btn-env-produccion" onclick="seleccionarAmbienteBusqueda('produccion', this)">
            🛡️ Producción (<span id="env-count-produccion">0</span>)
          </button>
        </div>

        <!-- Barra de Búsqueda iOS Spotlight -->
        <div class="search-box-wrapper">
          <span class="search-icon-left">🔍</span>
          <input type="text" id="obj-search-input" class="ios-search-input" 
                 placeholder="Escribe el nombre del objeto (ej. TKR_PARAMETROS, FHIR_, PKGLN_BIG_QUERY, JOB_)..." 
                 oninput="ejecutarBusqueda(this.value)" autocomplete="off">
          <button class="search-btn-clear" onclick="limpiarBusqueda()" title="Limpiar búsqueda">✕</button>
        </div>

        <!-- Píldoras de Filtro por Tipo (Se actualizan según el ambiente) -->
        <div class="filter-pills-row" id="filter-pills-container">
          <button class="filter-pill active" onclick="filtrarPorTipo('todos', this)">
            Todos <span class="pill-badge" id="badge-count-todos">0</span>
          </button>
          <button class="filter-pill" onclick="filtrarPorTipo('tables', this)">
            📊 Tablas <span class="pill-badge" id="badge-count-tables">0</span>
          </button>
          <button class="filter-pill" onclick="filtrarPorTipo('views', this)">
            👁️ Vistas <span class="pill-badge" id="badge-count-views">0</span>
          </button>
          <button class="filter-pill" onclick="filtrarPorTipo('packages', this)">
            📦 Packages <span class="pill-badge" id="badge-count-packages">0</span>
          </button>
          <button class="filter-pill" onclick="filtrarPorTipo('functions', this)">
            ⚡ Funciones <span class="pill-badge" id="badge-count-functions">0</span>
          </button>
          <button class="filter-pill" onclick="filtrarPorTipo('procedures', this)">
            ⚙️ Procedimientos <span class="pill-badge" id="badge-count-procedures">0</span>
          </button>
          <button class="filter-pill" onclick="filtrarPorTipo('jobs', this)">
            ⏱️ Jobs <span class="pill-badge" id="badge-count-jobs">0</span>
          </button>
          <button class="filter-pill" onclick="filtrarPorTipo('triggers', this)">
            🎯 Triggers <span class="pill-badge" id="badge-count-triggers">0</span>
          </button>
          <button class="filter-pill" onclick="filtrarPorTipo('sequences', this)">
            🔢 Secuencias <span class="pill-badge" id="badge-count-sequences">0</span>
          </button>
          <button class="filter-pill" onclick="filtrarPorTipo('types', this)">
            🧱 Tipos UDT <span class="pill-badge" id="badge-count-types">0</span>
          </button>
          <button class="filter-pill" onclick="filtrarPorTipo('borrados', this)" style="border-color: rgba(245, 158, 11, 0.4);">
            🗑️ Borrados en BD <span class="pill-badge" id="badge-count-borrados" style="color: #fbbf24;">0</span>
          </button>
        </div>

        <!-- Barra de Estadísticas -->
        <div class="search-stats-bar">
          <span id="search-results-count">Cargando catálogo...</span>
          <div id="search-view-mode-buttons">
            <button class="btn-glass" id="btn-back-to-list" style="display: none; padding: 6px 14px; font-size: 12.5px;" onclick="mostrarListaResultados()">
              ← Ver todos los resultados
            </button>
          </div>
        </div>

        <!-- VISTA 1: FICHA EXCLUSIVA PARA UN SOLO OBJETO (ver resultados solo de ese objeto) -->
        <div id="single-object-container" class="single-object-view">
          <div class="single-object-card">
            
            <div class="single-object-header">
              <div class="single-obj-title-group">
                <div class="single-obj-icon-box" id="single-obj-icon">📄</div>
                <div class="single-obj-name-wrap">
                  <h2 id="single-obj-name">NOMBRE_OBJETO</h2>
                  <span class="single-obj-type-badge" id="single-obj-type-badge">TIPO</span>
                </div>
              </div>
              <div id="single-obj-status-container">
                <span class="single-obj-status-badge status-active" id="single-obj-status-badge">
                  <span>🟢</span> <span id="single-obj-status-text">ACTIVO EN BASE DE DATOS</span>
                </span>
              </div>
            </div>

            <!-- Bloque de Fechas del Objeto (Actualización o Subida Inicial) -->
            <div id="single-obj-dates-box" class="single-obj-dates-box">
              <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                  <div class="data-tile-label" style="font-size: 11.5px; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted);">
                    📅 Historial de Versiones en Repositorio Git
                  </div>
                  <div id="single-obj-primary-date" class="single-obj-primary-date">
                    <!-- Fecha de actualizacion o subida inicial -->
                  </div>
                  <div id="single-obj-secondary-date" class="single-obj-secondary-date">
                    <!-- Detalle de subida inicial o versiones -->
                  </div>
                </div>
                <div id="single-obj-date-badge">
                  <!-- Badge dinámico de estado de modificación -->
                </div>
              </div>
              <div id="single-obj-oracle-date-row" class="single-obj-oracle-date-row">
                <span>🕒 Último DDL registrado en Oracle (Base de Datos):</span>
                <strong id="single-obj-oracle-date" class="oracle-date-val">---</strong>
              </div>
            </div>

            <!-- Metadatos del objeto en rejilla -->
            <div class="single-obj-grid">
              <div class="single-data-tile">
                <div class="data-tile-label">📂 Ruta en Repositorio</div>
                <div class="data-tile-value path-val" id="single-obj-path">schema_objects/...</div>
              </div>
              <div class="single-data-tile">
                <div class="data-tile-label">📁 Archivo Plano</div>
                <div class="data-tile-value" id="single-obj-file">archivo.sql</div>
              </div>
              <div class="single-data-tile">
                <div class="data-tile-label">🏢 Presencia por Ambiente</div>
                <div class="data-tile-value" id="single-obj-envs-status" style="font-size: 13px;">
                  <!-- Render dinámico de estado en Dev y Prod -->
                </div>
              </div>
              <div class="single-data-tile">
                <div class="data-tile-label">🌿 Rama Git Consultada</div>
                <div class="data-tile-value branch-val" id="single-obj-branch">desarrollo</div>
              </div>
            </div>

            <!-- Banner Historial Sincronización Reciente -->
            <div class="single-sync-banner sync-success" id="single-sync-banner">
              <span style="font-size: 20px;">⚡</span>
              <div>
                <strong id="single-sync-title">Historial en el último Respaldo:</strong>
                <p id="single-sync-detail" style="margin-top: 2px;">Cargando historial...</p>
              </div>
            </div>

            <!-- Botones de Acción -->
            <div class="single-obj-actions">
              <a id="single-obj-github-link" href="#" target="_blank" class="btn-glass primary" title="Ver archivo directamente en GitHub">
                <span>🐙</span> Ver Objeto en GitHub
              </a>
              <a id="single-obj-github-commits-link" href="#" target="_blank" class="btn-glass" title="Ver historial de commits de este objeto en GitHub">
                <span>📜</span> Historial Commits
              </a>
              <button class="btn-glass" onclick="copiarAlPortapapeles(document.getElementById('single-obj-path').innerText, 'Ruta copiada al portapapeles')">
                <span>📋</span> Copiar Ruta
              </button>
              <button class="btn-glass" id="btn-toggle-ddl" onclick="toggleVisorDDL()">
                <span>💻</span> Ver Código DDL / SQL
              </button>
            </div>

            <div style="font-size: 11.5px; color: var(--text-muted); margin-bottom: 14px;">
              🔒 <em>Nota para GitHub: Si al pulsar "Ver Objeto en GitHub" ves un error 404, asegúrate de haber iniciado sesión con tu cuenta de GitHub (<strong>vqorlando68</strong>) en tu navegador, ya que el repositorio es Privado.</em>
            </div>

            <!-- Visor de Código DDL SQL embebido -->
            <div id="obj-ddl-viewer" class="obj-ddl-viewer">
              <div class="obj-ddl-topbar">
                <div>
                  <span style="font-weight: 700; color: #ffffff;" id="obj-ddl-filename">ddl.sql</span>
                  <span id="obj-ddl-source-note" style="font-size: 11px; margin-left: 8px; color: #94a3b8;"></span>
                </div>
                <div style="display: flex; gap: 8px;">
                  <button class="btn-copy-code" onclick="document.getElementById('ddl-file-picker').click()">📂 Cargar Archivo Local</button>
                  <button class="btn-copy-code" onclick="copiarAlPortapapeles(document.getElementById('obj-ddl-code').innerText, 'Código SQL copiado')">📋 Copiar SQL</button>
                </div>
              </div>
              <input type="file" id="ddl-file-picker" style="display: none;" accept=".sql,.pks,.pkb,.tps" onchange="cargarDDLDesdeInput(event)">
              <pre class="obj-ddl-code" id="obj-ddl-code">Cargando DDL...</pre>
            </div>

          </div>
        </div>

        <!-- VISTA 2: LISTA GENERAL DE COINCIDENCIAS -->
        <div id="objects-results-container" class="objects-results-list">
          <!-- Render dinámico -->
        </div>

      </div>
    </section>

    <!-- PESTAÑA 3: MANUAL DE IMPLEMENTACIÓN -->
    <section id="tab-manual" class="tab-content">
      <div class="manual-container">
        
        <div class="manual-header">
          <div>
            <h2>📖 Manual de Implementación y Operación</h2>
            <p style="color: var(--text-secondary); margin-top: 4px; font-size: 14px;">
              Guía oficial para desplegar y configurar el agente en Windows, Linux, Oracle 23ai y GitHub.
            </p>
          </div>
          <div class="manual-nav-pill-group">
            <a href="#m-pr" class="manual-quicklink">1. Ocultar PR Banner</a>
            <a href="#m-token" class="manual-quicklink">2. Token Git (PAT)</a>
            <a href="#m-oracle" class="manual-quicklink">3. Script Oracle 23ai</a>
            <a href="#m-windows" class="manual-quicklink">4. Windows Setup</a>
            <a href="#m-linux" class="manual-quicklink">5. Linux Setup</a>
            <a href="#m-features" class="manual-quicklink">6. Optimización DDL</a>
          </div>
        </div>

        <!-- Sección 1 -->
        <article class="manual-section" id="m-pr">
          <h3><span class="section-num">1</span> Cómo Ocultar el Mensaje "Compare & Pull Request" en GitHub</h3>
          <p>
            Dado que este repositorio es un espejo de respaldo y las ramas <code>desarrollo</code> y <code>produccion</code> son independientes y nunca deben fusionarse, se puede desactivar la función de Pull Requests para ocultar permanentemente el banner verde de comparación:
          </p>
          <ol>
            <li>Entra a la configuración del repositorio en GitHub: <a href="https://github.com/vqorlando68/agente_backup/settings" target="_blank" style="color: #38bdf8; text-decoration: underline;">https://github.com/vqorlando68/agente_backup/settings</a>.</li>
            <li>En la pestaña <strong>General</strong>, desciende hasta la sección <strong>Features</strong>.</li>
            <li><strong>Desmarca la casilla <code>Pull requests</code></strong>.</li>
            <li>¡Listo! Al no admitir Pull Requests, GitHub no volverá a sugerir fusiones entre ramas.</li>
          </ol>
          <div class="manual-callout tip">
            💡 <strong>Tip:</strong> Si en el futuro necesitas habilitar revisiones de código, puedes volver a marcar la casilla en cualquier momento.
          </div>
        </article>

        <!-- Sección 2 -->
        <article class="manual-section" id="m-token">
          <h3><span class="section-num">2</span> Guía Paso a Paso para Generar el Token de Git (PAT)</h3>
          <p>El agente se autentica mediante un <strong>Personal Access Token (PAT)</strong> seguro, sin exponer contraseñas interactivas:</p>
          <ol>
            <li>Inicia sesión en GitHub y entra en <a href="https://github.com/settings/tokens" target="_blank" style="color: #38bdf8; text-decoration: underline;">Settings &gt; Developer Settings &gt; Personal access tokens &gt; Tokens (classic)</a>.</li>
            <li>Haz clic en <strong>Generate new token</strong> &gt; <strong>Generate new token (classic)</strong>.</li>
            <li>Completa:
              <ul>
                <li><strong>Note:</strong> <code>Agente_Backup_Oracle</code></li>
                <li><strong>Expiration:</strong> <code>No expiration</code> (o según política empresarial).</li>
                <li><strong>Scopes:</strong> Marca la casilla <strong><code>repo</code></strong> (Full control of private repositories).</li>
              </ul>
            </li>
            <li>Haz clic en <strong>Generate token</strong> al final de la página.</li>
            <li><strong>Copia el token generado</strong> (inicia con <code>ghp_...</code>) y guárdalo de inmediato.</li>
          </ol>
        </article>

        <!-- Sección 3 -->
        <article class="manual-section" id="m-oracle">
          <h3><span class="section-num">3</span> Script SQL para el Usuario de Oracle 23ai</h3>
          <p>Ejecutar con el usuario <code>SYS</code> conectado a la PDB <code>orclpdb1</code> en cada base de datos (Desarrollo y Producción):</p>
          
          <div class="code-terminal">
            <div class="terminal-topbar">
              <div class="terminal-dots">
                <span class="terminal-dot red"></span>
                <span class="terminal-dot yellow"></span>
                <span class="terminal-dot green"></span>
              </div>
              <span class="terminal-title">crear_usuario_backup.sql (Oracle 23ai)</span>
              <button class="btn-copy-code" onclick="copiarBloqueCodigo(this)">📋 Copiar</button>
            </div>
            <pre><code>ALTER SESSION SET CONTAINER = orclpdb1;

CREATE USER USUARIO_BACKUP_AGENT IDENTIFIED BY "Backup_Ag3nt3_2026"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA 0 ON USERS
  ACCOUNT UNLOCK;

GRANT CREATE SESSION TO USUARIO_BACKUP_AGENT;
GRANT SELECT_CATALOG_ROLE TO USUARIO_BACKUP_AGENT;
GRANT EXECUTE ON SYS.DBMS_METADATA TO USUARIO_BACKUP_AGENT;</code></pre>
          </div>
        </article>

        <!-- Sección 4 -->
        <article class="manual-section" id="m-windows">
          <h3><span class="section-num">4</span> Implementación en Windows Server / Windows 10/11</h3>
          <p><strong>Requisitos:</strong> Python 3.9+ y Git instalados en el sistema.</p>
          
          <div class="code-terminal">
            <div class="terminal-topbar">
              <div class="terminal-dots">
                <span class="terminal-dot red"></span>
                <span class="terminal-dot yellow"></span>
                <span class="terminal-dot green"></span>
              </div>
              <span class="terminal-title">CMD / PowerShell</span>
              <button class="btn-copy-code" onclick="copiarBloqueCodigo(this)">📋 Copiar</button>
            </div>
            <pre><code>cd C:\\Repositorios
git clone https://github.com/vqorlando68/agente_backup.git Objetos_desarrollo
cd Objetos_desarrollo
py -m pip install -r requirements.txt</code></pre>
          </div>

          <p>Configurar archivos de entorno en la carpeta <code>config/</code>:</p>
          <div class="code-terminal">
            <div class="terminal-topbar">
              <div class="terminal-dots">
                <span class="terminal-dot red"></span>
                <span class="terminal-dot yellow"></span>
                <span class="terminal-dot green"></span>
              </div>
              <span class="terminal-title">config\\.env.desarrollo</span>
              <button class="btn-copy-code" onclick="copiarBloqueCodigo(this)">📋 Copiar</button>
            </div>
            <pre><code>ORACLE_USER=USUARIO_BACKUP_AGENT
ORACLE_PASSWORD=Backup_Ag3nt3_2026
ORACLE_CONNECT_STRING=tekerapp-db.maxapex.net:1521/orclpdb1
TARGET_SCHEMA=TEKER_DEV
GIT_BRANCH=desarrollo
GIT_REMOTE=origin
GIT_REPO_URL=https://github.com/vqorlando68/agente_backup.git
GIT_USERNAME=vqorlando68
GIT_TOKEN=ghp_tu_token_aqui</code></pre>
          </div>

          <p>Para programar las tareas diarias en Windows automáticamente:</p>
          <div class="manual-callout">
            ⚙️ Haz clic derecho sobre <code>scripts\\install_windows_tasks.bat</code> y selecciona <strong>"Ejecutar como administrador"</strong>. Esto creará:
            <br>• <strong>Oracle_Backup_Desarrollo:</strong> Diariamente a las 04:00 AM.
            <br>• <strong>Oracle_Backup_Produccion:</strong> Diariamente a las 04:30 AM.
          </div>
        </article>

        <!-- Sección 5 -->
        <article class="manual-section" id="m-linux">
          <h3><span class="section-num">5</span> Implementación en Linux (RHEL, Rocky, Ubuntu, Debian, Oracle Linux)</h3>
          
          <div class="code-terminal">
            <div class="terminal-topbar">
              <div class="terminal-dots">
                <span class="terminal-dot red"></span>
                <span class="terminal-dot yellow"></span>
                <span class="terminal-dot green"></span>
              </div>
              <span class="terminal-title">Bash Terminal</span>
              <button class="btn-copy-code" onclick="copiarBloqueCodigo(this)">📋 Copiar</button>
            </div>
            <pre><code># Clonar repositorio en /opt
cd /opt
git clone https://github.com/vqorlando68/agente_backup.git
cd agente_backup

# Crear entorno virtual e instalar dependencias
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Asignar permisos de ejecucion
chmod +x scripts/run_backup_desarrollo.sh
chmod +x scripts/run_backup_produccion.sh</code></pre>
          </div>

          <p>Programar en el Cron del sistema con <code>crontab -e</code>:</p>
          <div class="code-terminal">
            <div class="terminal-topbar">
              <div class="terminal-dots">
                <span class="terminal-dot red"></span>
                <span class="terminal-dot yellow"></span>
                <span class="terminal-dot green"></span>
              </div>
              <span class="terminal-title">crontab -e</span>
              <button class="btn-copy-code" onclick="copiarBloqueCodigo(this)">📋 Copiar</button>
            </div>
            <pre><code># Respaldo Desarrollo a las 04:00 AM
0 4 * * * /opt/agente_backup/scripts/run_backup_desarrollo.sh >/dev/null 2>&1

# Respaldo Produccion a las 04:30 AM
30 4 * * * /opt/agente_backup/scripts/run_backup_produccion.sh >/dev/null 2>&1</code></pre>
          </div>
        </article>

        <!-- Sección 6 -->
        <article class="manual-section" id="m-features">
          <h3><span class="section-num">6</span> Características y Optimización del Agente</h3>
          <ul>
            <li><strong>Detección Incremental (<code>LAST_DDL_TIME</code>):</strong> Solo descarga los objetos modificados. La ejecución pasó de 20 minutos a tan solo <strong>~12 a 18 segundos</strong>.</li>
            <li><strong>Gestión de Objetos Eliminados (<code>schema_objects_borrados/</code>):</strong> Si un objeto es eliminado con <code>DROP</code> en Oracle, el agente lo mueve a la carpeta de borrados preservando la misma jerarquía.</li>
            <li><strong>Comentarios Incluidos en Tablas:</strong> Extracción automática de comentarios de tablas y columnas (<code>COMMENT ON TABLE / COLUMN</code>).</li>
            <li><strong>Formato Limpio de DDL:</strong> Sin palabras <code>EDITIONABLE</code>, sin propietario ni comillas en el encabezado <code>CREATE</code>.</li>
            <li><strong>Jobs DBMS_SCHEDULER:</strong> Extraídos con <code>PROCOBJ</code> y resguardados en <code>schema_objects/jobs/</code>.</li>
            <li><strong>Push 100% Desatendido:</strong> Uso de variables <code>GIT_TERMINAL_PROMPT=0</code> y token seguro en memoria para evitar bloqueos interactivos.</li>
          </ul>
        </article>

      </div>
    </section>

    <!-- PESTAÑA 4: VISOR DE LOGS -->
    <section id="tab-logs" class="tab-content">
      <div class="logs-container">
        
        <div class="logs-controls">
          <div>
            <h2 style="font-size: 20px; font-weight: 700;">📜 Visor de Logs de Ejecución</h2>
            <p style="color: var(--text-secondary); font-size: 13px; margin-top: 2px;">
              Inspección detallada de trazas de conexión, extracción y sincronización Git.
            </p>
          </div>

          <div class="log-tabs">
            <button class="log-tab-btn active" id="btn-log-dev" onclick="seleccionarLogAmbiente('desarrollo')">
              💻 Log Desarrollo
            </button>
            <button class="log-tab-btn" id="btn-log-prod" onclick="seleccionarLogAmbiente('produccion')">
              🛡️ Log Producción
            </button>
            <button class="btn-glass" onclick="copiarLogActual()">
              📋 Copiar Log
            </button>
          </div>
        </div>

        <div id="log-screen" class="log-viewer-screen">Cargando registros de log...</div>

      </div>
    </section>

  </div>

  <!-- Toast Notificaciones iOS -->
  <div id="toast" class="ios-toast">
    <span>✅</span>
    <span id="toast-text">Copiado al portapapeles</span>
  </div>

  <script>
    // Catálogo dual compacto embebido (resiliente para file:/// sin CORS)
    // Formato: "ruta/archivo.sql:FLAG" donde FLAG = B (Ambos), D (Desarrollo), P (Producción)
    const EMBEDDED_CATALOG_RAW = "{cat_text}";

    // Estado inicial por defecto
    const DEFAULT_STATUS = {status_content};

    let currentStatusData = DEFAULT_STATUS;
    let logAmbienteSeleccionado = 'desarrollo';
    let allObjectsCatalog = [];
    let currentFilteredObjects = [];
    let activeFilterType = 'todos';
    let selectedSearchEnv = 'todos'; // 'todos', 'desarrollo', 'produccion'
    let currentSelectedObject = null;

    // Iconos y etiquetas por tipo de objeto
    const TYPE_META = {{
      tables: {{ icon: "📊", label: "Tabla", singular: "TABLA" }},
      views: {{ icon: "👁️", label: "Vista", singular: "VISTA" }},
      packages: {{ icon: "📦", label: "Package", singular: "PAQUETE PL/SQL" }},
      functions: {{ icon: "⚡", label: "Función", singular: "FUNCIÓN PL/SQL" }},
      procedures: {{ icon: "⚙️", label: "Procedimiento", singular: "PROCEDIMIENTO" }},
      jobs: {{ icon: "⏱️", label: "Job Scheduler", singular: "JOB DBMS_SCHEDULER" }},
      triggers: {{ icon: "🎯", label: "Trigger", singular: "TRIGGER DML" }},
      sequences: {{ icon: "🔢", label: "Secuencia", singular: "SECUENCIA" }},
      types: {{ icon: "🧱", label: "Tipo / Objeto", singular: "TIPO UDT" }}
    }};

    // Muestra de Logs
    const SAMPLE_LOGS = {{
      desarrollo: `[2026-10-17 09:32:52] [INFO] ============================================================
[2026-10-17 09:32:52] [INFO] INICIANDO AGENTE BACKUP - AMBIENTE: DESARROLLO
[2026-10-17 09:32:52] [INFO] Conectando a tekerapp-db.maxapex.net:1521/orclpdb1 con usuario USUARIO_BACKUP_AGENT...
[2026-10-17 09:32:52] [INFO] Esquema objetivo: TEKER_DEV
[2026-10-17 09:32:53] [INFO] Conexion a Oracle establecida con exito.
[2026-10-17 09:32:53] [INFO] Posicionando repositorio en la rama 'desarrollo'...
[2026-10-17 09:32:57] [INFO] Encontrados 2328 objetos en el esquema TEKER_DEV
[2026-10-17 09:33:00] [INFO] Objeto borrado en BD detectado: functions/indicador_tru.sql -> movido a schema_objects_borrados/
[2026-10-17 09:33:00] [INFO] Objeto borrado en BD detectado: functions/indicador_true.sql -> movido a schema_objects_borrados/
[2026-10-17 09:33:00] [INFO] Objeto borrado en BD detectado: functions/indicador_truefalse.sql -> movido a schema_objects_borrados/
[2026-10-17 09:33:00] [INFO] Objeto borrado en BD detectado: functions/indicador_truef_alse.sql -> movido a schema_objects_borrados/
[2026-10-17 09:33:00] [INFO] Objeto borrado en BD detectado: functions/indicador_truef_a_lse.sql -> movido a schema_objects_borrados/
[2026-10-17 09:33:00] [INFO] Objeto borrado en BD detectado: functions/indicador_tru_false.sql -> movido a schema_objects_borrados/
[2026-10-17 09:33:00] [INFO] Objeto borrado en BD detectado: functions/indicaro_tru_false.sql -> movido a schema_objects_borrados/
[2026-10-17 09:33:00] [INFO] Objeto borrado en BD detectado: functions/indic_ador_truef_a_lse.sql -> movido a schema_objects_borrados/
[2026-10-17 09:33:01] [INFO] Resumen extraccion: 2 extraidos/actualizados, 2326 sin cambios (omitidos), 8 movidos a borrados.
[2026-10-17 09:33:01] [INFO] Conexion a Oracle cerrada.
[2026-10-17 09:33:01] [INFO] Iniciando sincronizacion con Git en la rama 'desarrollo'...
[2026-10-17 09:33:02] [INFO] Commit realizado: chore(sync): backup objetos desarrollo [2026-10-17 09:33:01]
[2026-10-17 09:33:04] [INFO] Push completado exitosamente a https://***@github.com/vqorlando68/agente_backup.git (rama desarrollo).
[2026-10-17 09:33:04] [INFO] FIN DE PROCESO - DESARROLLO
[2026-10-17 09:33:04] [INFO] ============================================================`,
      produccion: `[2026-10-17 09:29:45] [INFO] ============================================================
[2026-10-17 09:29:45] [INFO] INICIANDO AGENTE BACKUP - AMBIENTE: PRODUCCION
[2026-10-17 09:29:45] [INFO] Conectando a tekerapp-db.maxapex.net:1521/orclpdb1 con usuario USUARIO_BACKUP_AGENT...
[2026-10-17 09:29:45] [INFO] Esquema objetivo: TEKER_PROD
[2026-10-17 09:29:46] [INFO] Conexion a Oracle establecida con exito.
[2026-10-17 09:29:47] [INFO] Posicionando repositorio en la rama 'produccion'...
[2026-10-17 09:29:52] [INFO] Encontrados 2399 objetos en el esquema TEKER_PROD (incluyendo 45 Jobs)
[2026-10-17 09:29:58] [INFO] Resumen extraccion: 3 extraidos/actualizados, 2396 sin cambios (omitidos), 0 movidos a borrados.
[2026-10-17 09:29:58] [INFO] Conexion a Oracle cerrada.
[2026-10-17 09:29:58] [INFO] Iniciando sincronizacion con Git en la rama 'produccion'...
[2026-10-17 09:30:01] [INFO] Commit realizado: chore(sync): backup objetos produccion [2026-10-17 07:22:20]
[2026-10-17 09:30:04] [INFO] Push completado exitosamente a https://***@github.com/vqorlando68/agente_backup.git (rama produccion).
[2026-10-17 09:30:04] [INFO] FIN DE PROCESO - PRODUCCION
[2026-10-17 09:30:04] [INFO] ============================================================`
    }};

    // Inicializar aplicación
    document.addEventListener('DOMContentLoaded', () => {{
      inicializarTema();
      inicializarCatalogoObjetos();
      cargarStatus();
      renderizarLog(SAMPLE_LOGS[logAmbienteSeleccionado]);
    }});

    // ========================================================
    // GESTIÓN DE TEMA CLARO / OSCURO (LIGHT & DARK MODE)
    // ========================================================
    function inicializarTema() {{
      const saved = localStorage.getItem('oracle_dashboard_theme');
      const prefersLight = window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches;
      const theme = saved || (prefersLight ? 'light' : 'dark');
      aplicarTema(theme);
    }}

    function alternarTema() {{
      const current = document.documentElement.getAttribute('data-theme') || 'dark';
      const next = current === 'dark' ? 'light' : 'dark';
      aplicarTema(next);
      localStorage.setItem('oracle_dashboard_theme', next);
      mostrarToast(next === 'light' ? '☀️ Modo Claro activado' : '🌙 Modo Oscuro activado');
    }}

    function aplicarTema(theme) {{
      document.documentElement.setAttribute('data-theme', theme);
      const icon = document.getElementById('theme-icon');
      const label = document.getElementById('theme-label');
      if (theme === 'light') {{
        if (icon) icon.innerText = '🌙';
        if (label) label.innerText = 'Oscuro';
      }} else {{
        if (icon) icon.innerText = '☀️';
        if (label) label.innerText = 'Claro';
      }}
    }}

    // Parsear catálogo dual embebido de objetos (instantáneo en file:///)
    function inicializarCatalogoObjetos() {{
      const raw = EMBEDDED_CATALOG_RAW.trim();
      if (!raw) return;

      const pathEntries = raw.split('|');
      let totalDev = 0;
      let totalProd = 0;

      allObjectsCatalog = pathEntries.map(entry => {{
        const parts = entry.includes('~') ? entry.split('~') : entry.split(':');
        const filePath = (parts[0] || '').replace(/\\\\/g, '/');
        const flag = parts[1] || 'B';
        const createdAt = parts[2] || '2026-10-16 22:06';
        const updatedAt = parts[3] ? parts[3] : null;
        const oracleDate = parts[4] || '';
        const hasUpdates = Boolean(updatedAt);

        let envs = [];
        if (flag === 'B') {{
          envs = ['desarrollo', 'produccion'];
          totalDev++;
          totalProd++;
        }} else if (flag === 'D') {{
          envs = ['desarrollo'];
          totalDev++;
        }} else {{
          envs = ['produccion'];
          totalProd++;
        }}

        const segs = filePath.split('/');
        const isDeleted = segs[0] === 'schema_objects_borrados';
        const typeFolder = segs[1] || 'otros';
        const fileName = segs[2] || segs[segs.length - 1];
        const baseName = fileName.replace(/\\.(sql|pks|pkb|tps)$/i, '').toUpperCase();

        return {{
          name: baseName,
          file: fileName,
          type: typeFolder,
          status: isDeleted ? 'deleted' : 'active',
          path: filePath,
          envs: envs,
          created_at: createdAt,
          updated_at: updatedAt,
          has_updates: hasUpdates,
          oracle_date: oracleDate
        }};
      }});

      // Actualizar contadores en botones de ambiente
      document.getElementById('env-count-todos').innerText = allObjectsCatalog.length.toLocaleString();
      document.getElementById('env-count-desarrollo').innerText = totalDev.toLocaleString();
      document.getElementById('env-count-produccion').innerText = totalProd.toLocaleString();

      // Recalcular contadores de píldoras según ambiente activo
      actualizarContadoresPildoras();

      // Intentar enriquecer desde objects_index.json si estamos bajo servidor
      fetch('objects_index.json?t=' + new Date().getTime())
        .then(res => res.ok ? res.json() : null)
        .then(richData => {{
          if (richData && richData.length > 0) {{
            allObjectsCatalog = richData;
            actualizarContadoresPildoras();
            ejecutarBusqueda(document.getElementById('obj-search-input').value);
          }}
        }})
        .catch(() => {{ /* Fallback embebido activo */ }});

      ejecutarBusqueda('');
    }}

    // Recalcula los contadores de cada píldora según el ambiente seleccionado (Desarrollo, Producción o Ambos)
    function actualizarContadoresPildoras() {{
      const counts = {{
        todos: 0, tables: 0, views: 0, packages: 0, functions: 0,
        procedures: 0, jobs: 0, triggers: 0, sequences: 0, types: 0, borrados: 0
      }};

      allObjectsCatalog.forEach(obj => {{
        if (selectedSearchEnv !== 'todos' && !obj.envs.includes(selectedSearchEnv)) {{
          return;
        }}

        counts.todos++;
        if (obj.status === 'deleted') counts.borrados++;
        if (counts[obj.type] !== undefined) counts[obj.type]++;
      }});

      document.getElementById('badge-count-todos').innerText = counts.todos.toLocaleString();
      document.getElementById('badge-count-tables').innerText = counts.tables.toLocaleString();
      document.getElementById('badge-count-views').innerText = counts.views.toLocaleString();
      document.getElementById('badge-count-packages').innerText = counts.packages.toLocaleString();
      document.getElementById('badge-count-functions').innerText = counts.functions.toLocaleString();
      document.getElementById('badge-count-procedures').innerText = counts.procedures.toLocaleString();
      document.getElementById('badge-count-jobs').innerText = counts.jobs.toLocaleString();
      document.getElementById('badge-count-triggers').innerText = counts.triggers.toLocaleString();
      document.getElementById('badge-count-sequences').innerText = counts.sequences.toLocaleString();
      const typeEl = document.getElementById('badge-count-types');
      if (typeEl) typeEl.innerText = counts.types.toLocaleString();
      document.getElementById('badge-count-borrados').innerText = counts.borrados.toLocaleString();
    }}

    // Selector de Ambiente para el Buscador (Todos, Desarrollo, Producción)
    function seleccionarAmbienteBusqueda(env, btnEl) {{
      selectedSearchEnv = env;
      document.querySelectorAll('.env-toggle-pill').forEach(b => b.classList.remove('active'));
      if (btnEl) {{
        btnEl.classList.add('active');
      }} else {{
        const targetBtn = document.getElementById('btn-env-' + env);
        if (targetBtn) targetBtn.classList.add('active');
      }}

      // 1. Recalcular contadores de píldoras para el nuevo ambiente
      actualizarContadoresPildoras();

      // 2. Regresar a la lista de objetos para mostrar de inmediato los objetos del ambiente
      currentSelectedObject = null;
      ejecutarBusqueda(document.getElementById('obj-search-input').value);
    }}

    // Acceso directo desde las tarjetas de ambientes hacia el buscador
    function irABuscadorAmbiente(env, tipo = 'tables') {{
      cambiarPestana('buscador');
      const btn = document.getElementById('btn-env-' + env);
      seleccionarAmbienteBusqueda(env, btn);
      if (tipo) {{
        const pillBtn = document.querySelector(`.filter-pill[onclick*="'${{tipo}}'"]`);
        if (pillBtn) filtrarPorTipo(tipo, pillBtn);
      }}
    }}

    // Motor de búsqueda de objetos
    function ejecutarBusqueda(query) {{
      const q = (query || '').trim().toUpperCase();
      
      currentFilteredObjects = allObjectsCatalog.filter(obj => {{
        // 1. Filtro estricto por ambiente (Desarrollo o Producción)
        if (selectedSearchEnv !== 'todos' && !obj.envs.includes(selectedSearchEnv)) {{
          return false;
        }}

        // 2. Filtro por categoría activa (píldoras de tipo o borrados)
        if (activeFilterType === 'borrados') {{
          if (obj.status !== 'deleted') return false;
        }} else if (activeFilterType !== 'todos') {{
          if (obj.type !== activeFilterType) return false;
        }}

        // 3. Filtro por texto ingresado
        if (!q) return true;
        return obj.name.includes(q) || obj.file.toUpperCase().includes(q) || obj.path.toUpperCase().includes(q);
      }});

      // Si hay exactamente 1 coincidencia directa exacta o coincidencia única, mostrar la ficha aislada
      const exactMatch = q ? currentFilteredObjects.find(o => o.name === q || o.file.toUpperCase() === q) : null;
      if (exactMatch && currentFilteredObjects.length === 1) {{
        mostrarFichaExclusivaObjeto(exactMatch);
        return;
      }}

      // En caso contrario, mostrar lista de resultados
      mostrarListaResultados();
    }}

    // Filtrar por píldora de tipo
    function filtrarPorTipo(tipo, btnEl) {{
      activeFilterType = tipo;
      document.querySelectorAll('.filter-pill').forEach(b => b.classList.remove('active'));
      if (btnEl) btnEl.classList.add('active');
      currentSelectedObject = null;
      ejecutarBusqueda(document.getElementById('obj-search-input').value);
    }}

    function limpiarBusqueda() {{
      const input = document.getElementById('obj-search-input');
      input.value = '';
      input.focus();
      ejecutarBusqueda('');
    }}

    // Muestra la lista de múltiples resultados
    function mostrarListaResultados() {{
      currentSelectedObject = null;
      document.getElementById('single-object-container').style.display = 'none';
      document.getElementById('objects-results-container').style.display = 'grid';
      document.getElementById('btn-back-to-list').style.display = 'none';

      const resultsContainer = document.getElementById('objects-results-container');
      const countEl = document.getElementById('search-results-count');
      const total = currentFilteredObjects.length;

      const envLabel = selectedSearchEnv === 'todos' 
        ? 'Ambos Ambientes' 
        : (selectedSearchEnv === 'desarrollo' ? 'Desarrollo (TEKER_DEV)' : 'Producción (TEKER_PROD)');

      const typePlural = {{
        todos: 'objetos',
        tables: 'tablas',
        views: 'vistas',
        packages: 'paquetes/packages',
        functions: 'funciones',
        procedures: 'procedimientos',
        jobs: 'jobs DBMS_SCHEDULER',
        triggers: 'triggers',
        sequences: 'secuencias',
        types: 'tipos UDT',
        borrados: 'objetos borrados'
      }};
      const catLabel = typePlural[activeFilterType] || 'objetos';

      countEl.innerHTML = `Mostrando <strong>${{total.toLocaleString()}}</strong> ${{catLabel}} en <em>${{envLabel}}</em>:`;

      if (total === 0) {{
        resultsContainer.innerHTML = `
          <div style="grid-column: 1 / -1; padding: 40px; text-align: center; color: var(--text-muted);">
            <div style="font-size: 36px; margin-bottom: 8px;">🔍</div>
            <p>No se encontraron objetos en <strong>${{envLabel}}</strong> que coincidan con la búsqueda.</p>
          </div>
        `;
        return;
      }}

      // Limitar renderizado a los primeros 60 objetos para máxima fluidez
      const sliceLimit = 60;
      const displayList = currentFilteredObjects.slice(0, sliceLimit);

      resultsContainer.innerHTML = displayList.map(obj => {{
        const meta = TYPE_META[obj.type] || {{ icon: "📄", label: obj.type }};
        const isDel = obj.status === 'deleted';
        const badgeStatus = isDel 
          ? '<span class="badge-mini del">BORRADO</span>' 
          : '<span class="badge-mini act">ACTIVO</span>';

        let envBadges = '';
        if (selectedSearchEnv === 'todos') {{
          if (obj.envs.includes('desarrollo')) envBadges += '<span class="badge-mini dev">DEV</span> ';
          if (obj.envs.includes('produccion')) envBadges += '<span class="badge-mini prod">PROD</span> ';
        }} else {{
          const bClass = selectedSearchEnv === 'desarrollo' ? 'dev' : 'prod';
          const bText = selectedSearchEnv === 'desarrollo' ? 'TEKER_DEV' : 'TEKER_PROD';
          envBadges = `<span class="badge-mini ${{bClass}}">${{bText}}</span> `;
        }}

        const dateSnippet = (obj.has_updates && obj.updated_at)
          ? `🔄 Act: ${{obj.updated_at}}`
          : `📦 Creado: ${{obj.created_at || '2026-10-16'}}`;

        return `
          <div class="object-list-item" onclick="seleccionarObjetoPorPath('${{obj.path}}')">
            <div class="obj-item-info">
              <div class="obj-item-icon">${{meta.icon}}</div>
              <div class="obj-item-text">
                <div class="obj-item-name" title="${{obj.name}}">${{obj.name}}</div>
                <div class="obj-item-sub">
                  ${{badgeStatus}}
                  ${{envBadges}}
                  <span>${{meta.label}}</span>
                  <span>•</span>
                  <span>${{obj.file}}</span>
                  <span>•</span>
                  <span class="obj-item-date-text">${{dateSnippet}}</span>
                </div>
              </div>
            </div>
            <span style="color: var(--text-muted); font-size: 13px;">→</span>
          </div>
        `;
      }}).join('');

      if (total > sliceLimit) {{
        resultsContainer.innerHTML += `
          <div style="grid-column: 1 / -1; text-align: center; padding: 12px; color: var(--text-muted); font-size: 12.5px;">
            Mostrando 60 de ${{total.toLocaleString()}} resultados. Escribe más letras en el buscador para filtrar con mayor precisión.
          </div>
        `;
      }}
    }}

    function seleccionarObjetoPorPath(path) {{
      const cleanPath = path.replace(/\\\\/g, '/');
      const obj = allObjectsCatalog.find(o => o.path === cleanPath || o.path === path);
      if (obj) {{
        mostrarFichaExclusivaObjeto(obj);
      }}
    }}

    // ========================================================
    // FICHA EXCLUSIVA: VER RESULTADOS SOLO DE ESE OBJETO
    // ========================================================
    function mostrarFichaExclusivaObjeto(obj) {{
      currentSelectedObject = obj;
      document.getElementById('objects-results-container').style.display = 'none';
      document.getElementById('single-object-container').style.display = 'block';
      document.getElementById('btn-back-to-list').style.display = 'inline-flex';

      const meta = TYPE_META[obj.type] || {{ icon: "📄", label: obj.type, singular: obj.type.toUpperCase() }};
      const isDeleted = obj.status === 'deleted';

      document.getElementById('search-results-count').innerHTML = `Ficha exclusiva del objeto: <strong class="single-obj-name-highlight">${{obj.name}}</strong>`;

      // Header de la Ficha
      document.getElementById('single-obj-icon').innerText = meta.icon;
      document.getElementById('single-obj-name').innerText = obj.name;
      document.getElementById('single-obj-type-badge').innerText = meta.singular;

      const statusBadge = document.getElementById('single-obj-status-badge');
      const statusText = document.getElementById('single-obj-status-text');
      if (isDeleted) {{
        statusBadge.className = 'single-obj-status-badge status-deleted';
        statusBadge.querySelector('span:first-child').innerText = '🗑️';
        statusText.innerText = 'OBJETO BORRADO EN BASE DE DATOS';
      }} else {{
        statusBadge.className = 'single-obj-status-badge status-active';
        statusBadge.querySelector('span:first-child').innerText = '🟢';
        statusText.innerText = 'ACTIVO EN BASE DE DATOS';
      }}

      // Determinar presencia en Desarrollo y Producción
      const inDev = obj.envs.includes('desarrollo');
      const inProd = obj.envs.includes('produccion');

      let devBadge = inDev ? '<span class="env-badge-item dev-active">🟢 Presente en Desarrollo (TEKER_DEV)</span>' : '<span class="env-badge-item inactive">❌ No en Desarrollo</span>';
      let prodBadge = inProd ? '<span class="env-badge-item prod-active">🟢 Presente en Producción (TEKER_PROD)</span>' : '<span class="env-badge-item inactive">❌ No en Producción</span>';
      document.getElementById('single-obj-envs-status').innerHTML = `${{devBadge}}<br>${{prodBadge}}`;

      // Determinar rama activa para el enlace de GitHub
      let targetBranch = 'desarrollo';
      if (selectedSearchEnv === 'produccion') {{
        targetBranch = 'produccion';
      }} else if (selectedSearchEnv === 'desarrollo') {{
        targetBranch = 'desarrollo';
      }} else {{
        targetBranch = inProd ? 'produccion' : 'desarrollo';
      }}

      document.getElementById('single-obj-branch').innerText = targetBranch;
      document.getElementById('single-obj-path').innerText = obj.path;
      document.getElementById('single-obj-file').innerText = obj.file;

      // Bloque de Fechas del Objeto (Actualización vs Subida Inicial)
      const primDateEl = document.getElementById('single-obj-primary-date');
      const secDateEl = document.getElementById('single-obj-secondary-date');
      const dateBadgeEl = document.getElementById('single-obj-date-badge');
      const oracleDateEl = document.getElementById('single-obj-oracle-date');

      if (obj.has_updates && obj.updated_at) {{
        primDateEl.innerHTML = `🔄 Última Actualización: <span class="prim-date-accent-dev">${{obj.updated_at}}</span>`;
        secDateEl.innerHTML = `Subido por primera vez al repositorio: <strong>${{obj.created_at || '---'}}</strong> (${{obj.commits_count || 2}} versiones en historial Git)`;
        dateBadgeEl.innerHTML = `<span class="badge-mini mod" style="font-size: 11.5px; padding: 5px 12px; border-radius: 12px;">ACTUALIZADO</span>`;
      }} else {{
        primDateEl.innerHTML = `📦 Subido al Repositorio por Primera Vez: <span class="prim-date-accent-prod">${{obj.created_at || '2026-10-16 22:06'}}</span>`;
        secDateEl.innerHTML = `Este objeto se encuentra en su versión inicial de carga y no ha tenido actualizaciones posteriores.`;
        dateBadgeEl.innerHTML = `<span class="badge-mini act" style="font-size: 11.5px; padding: 5px 12px; border-radius: 12px;">VERSIÓN ORIGINAL</span>`;
      }}

      oracleDateEl.innerText = obj.oracle_date ? obj.oracle_date : (obj.created_at || 'Sincronizado con BD');

      // Enlaces a GitHub dinámicos según la rama seleccionada
      const repoBaseUrl = 'https://github.com/vqorlando68/agente_backup';
      const encodedPath = encodeURI(obj.path.replace(/\\\\/g, '/'));
      
      document.getElementById('single-obj-github-link').href = `${{repoBaseUrl}}/blob/${{targetBranch}}/${{encodedPath}}`;
      document.getElementById('single-obj-github-commits-link').href = `${{repoBaseUrl}}/commits/${{targetBranch}}/${{encodedPath}}`;

      // Historial en el último Respaldo (cruce con status.json)
      const banner = document.getElementById('single-sync-banner');
      const syncDetail = document.getElementById('single-sync-detail');
      
      let matchInRecentSync = false;
      let syncNote = '';

      ['desarrollo', 'produccion'].forEach(envKey => {{
        const envData = currentStatusData[envKey];
        if (envData && envData.archivos_cambiados) {{
          const found = envData.archivos_cambiados.find(line => line.includes(obj.file) || line.includes(obj.name.toLowerCase()));
          if (found) {{
            matchInRecentSync = true;
            syncNote += `En el último ciclo de <strong>${{envData.ambiente}}</strong> (Commit <code>${{envData.commit_hash}}</code>): ${{found}}<br>`;
          }}
        }}
      }});

      // Limpiar cualquier estilo inline para permitir que las clases CSS de tema gobiernen
      banner.removeAttribute('style');

      if (matchInRecentSync) {{
        banner.className = 'single-sync-banner sync-warning';
        syncDetail.innerHTML = syncNote;
      }} else {{
        banner.className = 'single-sync-banner sync-success';
        syncDetail.innerHTML = `Este objeto se encuentra sincronizado en el repositorio y no tuvo cambios en el último ciclo.`;
      }}

      // Ocultar visor DDL al cambiar de objeto
      document.getElementById('obj-ddl-viewer').style.display = 'none';
      document.getElementById('btn-toggle-ddl').innerText = '💻 Ver Código DDL / SQL';
    }}

    // Visor de Código DDL SQL embebido
    async function toggleVisorDDL() {{
      const viewer = document.getElementById('obj-ddl-viewer');
      const btn = document.getElementById('btn-toggle-ddl');

      if (viewer.style.display === 'block') {{
        viewer.style.display = 'none';
        btn.innerText = '💻 Ver Código DDL / SQL';
        return;
      }}

      if (!currentSelectedObject) return;

      viewer.style.display = 'block';
      btn.innerText = '✕ Ocultar Código DDL';
      document.getElementById('obj-ddl-filename').innerText = currentSelectedObject.path;
      document.getElementById('obj-ddl-source-note').innerText = 'Cargando archivo plano...';
      document.getElementById('obj-ddl-code').innerText = 'Cargando script SQL...';

      const cleanPath = currentSelectedObject.path.replace(/\\\\/g, '/');
      try {{
        const res = await fetch(cleanPath + '?t=' + new Date().getTime());
        if (res.ok) {{
          const sqlText = await res.text();
          document.getElementById('obj-ddl-code').innerText = sqlText;
          document.getElementById('obj-ddl-source-note').innerText = '(Cargado directamente desde disco local)';
        }} else {{
          throw new Error('HTTP ' + res.status);
        }}
      }} catch (err) {{
        // Si fetch falla por CORS (abierto como file:///), dar opciones claras
        document.getElementById('obj-ddl-source-note').innerText = '(Modo Local file:///)';
        document.getElementById('obj-ddl-code').innerHTML = 
`-- ATENCIÓN: El navegador bloquea lecturas locales directas cuando se abre como file:/// (política de seguridad CORS del navegador).

-- OPCIONES PARA VER ESTE CÓDIGO INMEDIATAMENTE:

1. [RECOMENDADO] Inicia el servidor local de 1-clic:
   Doble clic en: iniciar_dashboard.bat
   Esto abre el dashboard en http://localhost:8080/dashboard.html permitiendo ver el código de cualquier objeto con 1 clic.

2. [SELECCIONAR ARCHIVO]:
   Haz clic en el botón superior "📂 Cargar Archivo Local" y selecciona el archivo:
   ${{cleanPath}}

3. [VER EN GITHUB]:
   Haz clic en el botón "🐙 Ver Objeto en GitHub" (recuerda haber iniciado sesión con tu cuenta vqorlando68).`;
      }}
    }}

    function cargarDDLDesdeInput(event) {{
      const file = event.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (e) => {{
        document.getElementById('obj-ddl-code').innerText = e.target.result;
        document.getElementById('obj-ddl-source-note').innerText = `(${{file.name}} cargado manualmente)`;
        mostrarToast('Código DDL cargado en el visor');
      }};
      reader.readAsText(file);
    }}

    // ========================================================
    // LOGICA GENERAL DE STATUS Y PESTAÑAS
    // ========================================================
    async function cargarStatus() {{
      const btn = document.getElementById('btn-refresh');
      btn.style.opacity = '0.6';
      
      try {{
        const response = await fetch('status.json?t=' + new Date().getTime());
        if (!response.ok) throw new Error('Respuesta HTTP no OK: ' + response.status);
        const data = await response.json();
        currentStatusData = data;
        renderizarUI(data);
        mostrarToast('Estado actualizado desde status.json');
      }} catch (err) {{
        console.warn('Fallback local status.json:', err);
        renderizarUI(currentStatusData);
        mostrarToast('Datos cargados (Modo Local Seguro)');
      }} finally {{
        setTimeout(() => {{ btn.style.opacity = '1'; }}, 400);
      }}
    }}

    function cargarDesdeArchivoLocal(event) {{
      const file = event.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (e) => {{
        try {{
          const parsed = JSON.parse(e.target.result);
          currentStatusData = parsed;
          renderizarUI(parsed);
          mostrarToast('status.json cargado exitosamente');
        }} catch (err) {{
          alert('Error al parsear archivo JSON: ' + err.message);
        }}
      }};
      reader.readAsText(file);
    }}

    function renderizarUI(data) {{
      if (!data) return;

      if (data.desarrollo) {{
        const d = data.desarrollo;
        document.getElementById('dev-schema').innerText = d.esquema || 'TEKER_DEV';
        document.getElementById('dev-estado').innerText = d.estado || 'EXITOSO';
        document.getElementById('dev-totales').innerText = (d.objetos_totales || 0).toLocaleString();
        document.getElementById('dev-actualizados').innerText = (d.objetos_actualizados || 0).toLocaleString();
        document.getElementById('dev-omitidos').innerText = (d.objetos_omitidos || 0).toLocaleString();
        document.getElementById('dev-borrados').innerText = (d.objetos_borrados || 0).toLocaleString();
        document.getElementById('dev-rama').innerText = d.rama || 'desarrollo';
        document.getElementById('dev-hash').innerText = d.commit_hash || '---';
        document.getElementById('dev-msg').innerText = d.commit_mensaje || 'Sin mensaje registrado';
        document.getElementById('dev-fecha').innerText = d.ultima_ejecucion || '---';
        document.getElementById('dev-duracion').innerText = (d.duracion_segundos || 0) + 's';
        
        if (d.commit_url) {{
          document.getElementById('dev-commit-link').href = d.commit_url;
        }}
        renderizarArchivosCambiados('dev-changed-list', 'dev-changed-count', d.archivos_cambiados);
      }}

      if (data.produccion) {{
        const p = data.produccion;
        document.getElementById('prod-schema').innerText = p.esquema || 'TEKER_PROD';
        document.getElementById('prod-estado').innerText = p.estado || 'EXITOSO';
        document.getElementById('prod-totales').innerText = (p.objetos_totales || 0).toLocaleString();
        document.getElementById('prod-actualizados').innerText = (p.objetos_actualizados || 0).toLocaleString();
        document.getElementById('prod-omitidos').innerText = (p.objetos_omitidos || 0).toLocaleString();
        document.getElementById('prod-borrados').innerText = (p.objetos_borrados || 0).toLocaleString();
        document.getElementById('prod-rama').innerText = p.rama || 'produccion';
        document.getElementById('prod-hash').innerText = p.commit_hash || '---';
        document.getElementById('prod-msg').innerText = p.commit_mensaje || 'Sin mensaje registrado';
        document.getElementById('prod-fecha').innerText = p.ultima_ejecucion || '---';
        document.getElementById('prod-duracion').innerText = (p.duracion_segundos || 0) + 's';
        
        if (p.commit_url) {{
          document.getElementById('prod-commit-link').href = p.commit_url;
        }}
        renderizarArchivosCambiados('prod-changed-list', 'prod-changed-count', p.archivos_cambiados);
      }}
    }}

    function renderizarArchivosCambiados(listId, countId, items) {{
      const container = document.getElementById(listId);
      const countEl = document.getElementById(countId);
      if (!items || items.length === 0) {{
        countEl.innerText = '0';
        container.innerHTML = '<div style="color: var(--text-muted); padding: 6px 0;">No se registraron cambios de objetos en este ciclo.</div>';
        return;
      }}

      countEl.innerText = items.length;
      container.innerHTML = items.map(item => {{
        let tag = '';
        if (item.includes('[RENOMBRADO]')) {{
          tag = '<span class="tag-rename">[RENOMBRADO]</span>';
        }} else if (item.includes('[NUEVO]') || item.includes('[AGREGADO]')) {{
          tag = '<span class="tag-add">[NUEVO]</span>';
        }} else {{
          tag = '<span class="tag-mod">[MODIFICADO]</span>';
        }}
        const cleanText = item.replace(/\\[.*?\\]/, '').trim();
        return `<div class="changed-file-item">${{tag}} ${{cleanText}}</div>`;
      }}).join('');
    }}

    function toggleAcordeon(id) {{
      const el = document.getElementById(id);
      const icon = el.previousElementSibling.querySelector('span:last-child');
      if (el.classList.contains('open')) {{
        el.classList.remove('open');
        icon.innerText = '▼';
      }} else {{
        el.classList.add('open');
        icon.innerText = '▲';
      }}
    }}

    function cambiarPestana(idTab) {{
      document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
      document.querySelectorAll('.segment-btn').forEach(btn => btn.classList.remove('active'));

      const targetTab = document.getElementById('tab-' + idTab);
      if (targetTab) targetTab.classList.add('active');

      const targetBtn = document.getElementById('btn-tab-' + idTab);
      if (targetBtn) targetBtn.classList.add('active');

      if (idTab === 'logs') {{
        seleccionarLogAmbiente(logAmbienteSeleccionado);
      }}
    }}

    function seleccionarLogAmbiente(env) {{
      logAmbienteSeleccionado = env;
      document.getElementById('btn-log-dev').classList.toggle('active', env === 'desarrollo');
      document.getElementById('btn-log-prod').classList.toggle('active', env === 'produccion');
      
      const logFile = currentStatusData[env]?.archivo_log;
      if (logFile) {{
        fetch(logFile + '?t=' + new Date().getTime())
          .then(res => res.ok ? res.text() : Promise.reject())
          .then(text => renderizarLog(text))
          .catch(() => renderizarLog(SAMPLE_LOGS[env]));
      }} else {{
        renderizarLog(SAMPLE_LOGS[env]);
      }}
    }}

    function renderizarLog(rawText) {{
      const screen = document.getElementById('log-screen');
      if (!rawText) {{
        screen.innerHTML = '<span style="color: var(--text-muted);">Sin logs disponibles.</span>';
        return;
      }}
      
      const lines = rawText.split('\\n').map(line => {{
        let formatted = line
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;');

        formatted = formatted.replace(/^(\\[\\d{{4}}-\\d{{2}}-\\d{{2}} \\d{{2}}:\\d{{2}}:\\d{{2}}\\])/, '<span class="log-line-time">$1</span>');
        
        if (formatted.includes('[INFO]')) {{
          formatted = formatted.replace('[INFO]', '<span class="log-line-info">[INFO]</span>');
        }} else if (formatted.includes('[WARNING]') || formatted.includes('[WARN]')) {{
          formatted = formatted.replace(/\\[WARN(ING)?\\]/, '<span class="log-line-warn">[WARN]</span>');
        }} else if (formatted.includes('[ERROR]')) {{
          formatted = formatted.replace('[ERROR]', '<span class="log-line-err">[ERROR]</span>');
        }}

        if (formatted.includes('exitosamente') || formatted.includes('exito') || formatted.includes('Commit realizado')) {{
          formatted = `<span class="log-line-success">${{formatted}}</span>`;
        }}

        return formatted;
      }});

      screen.innerHTML = lines.join('\\n');
    }}

    function copiarLogActual() {{
      const screen = document.getElementById('log-screen');
      copiarAlPortapapeles(screen.innerText, 'Log completo copiado al portapapeles');
    }}

    function copiarAlPortapapeles(texto, msg = 'Copiado al portapapeles') {{
      if (!texto) return;
      navigator.clipboard.writeText(texto).then(() => {{
        mostrarToast(msg);
      }}).catch(err => {{
        const ta = document.createElement('textarea');
        ta.value = texto;
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
        mostrarToast(msg);
      }});
    }}

    function copiarBloqueCodigo(btn) {{
      const code = btn.closest('.code-terminal').querySelector('pre code').innerText;
      copiarAlPortapapeles(code, 'Código copiado al portapapeles');
      const original = btn.innerText;
      btn.innerText = '✅ ¡Copiado!';
      setTimeout(() => {{ btn.innerText = original; }}, 2000);
    }}

    function mostrarToast(mensaje) {{
      const toast = document.getElementById('toast');
      document.getElementById('toast-text').innerText = mensaje;
      toast.classList.add('show');
      setTimeout(() => {{
        toast.classList.remove('show');
      }}, 2600);
    }}
  </script>
</body>
</html>
"""

(repo_dir / 'dashboard.html').write_text(html_content, encoding='utf-8')
print(f"dashboard.html generado exitosamente ({len(html_content)} bytes).")
