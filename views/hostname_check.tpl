% include("header")
<style>
    @import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=JetBrains+Mono:wght@400;700&display=swap");

    * { font-family: 'Inter', sans-serif; }

    body {
        background-color: #050505;
        color: #e0e0e0;
    }

    .search-card {
        background: #0f0f0f;
        border: 1px solid #1e1e1e;
        border-radius: 20px;
        padding: 30px;
        margin-bottom: 30px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.4);
    }

    .search {
        background-color: #121212 !important;
        border: 1px solid #2a2a2a !important;
        border-radius: 10px !important;
        color: white !important;
        padding: 14px !important;
        font-family: 'JetBrains Mono', monospace !important;
        width: 100%;
        transition: all 0.3s ease;
    }

    .search:focus {
        border-color: #7F0000 !important;
        box-shadow: 0 0 0 4px rgba(127, 0, 0, 0.15);
        outline: none;
    }

    .btn-lookup {
        background: linear-gradient(135deg, #7F0000 0%, #4d0000 100%) !important;
        border: none !important;
        border-radius: 10px !important;
        padding: 14px 30px !important;
        font-weight: 600 !important;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: white;
        transition: all 0.3s ease !important;
    }

    .btn-lookup:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(127, 0, 0, 0.4);
    }

    .text-red-500 { color: #ff4d4d !important; }

    /* Risk badges */
    .risk-badge {
        display: inline-block;
        padding: 5px 16px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .risk-alto { background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.3); }
    .risk-medio { background: rgba(245, 158, 11, 0.15); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.3); }
    .risk-bajo { background: rgba(34, 197, 94, 0.15); color: #4ade80; border: 1px solid rgba(34, 197, 94, 0.3); }
    .risk-unknown { background: rgba(107, 114, 128, 0.15); color: #9ca3af; border: 1px solid rgba(107, 114, 128, 0.3); }

    /* Service cards */
    .service-card {
        background: #0a0a0a;
        border: 1px solid #1a1a1a;
        border-radius: 16px;
        padding: 25px;
        margin-bottom: 20px;
        transition: all 0.3s ease;
    }

    .service-card:hover {
        border-color: rgba(127, 0, 0, 0.3);
        box-shadow: 0 5px 20px rgba(0,0,0,0.3);
    }

    .service-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 18px;
        padding-bottom: 12px;
        border-bottom: 1px solid #1e1e1e;
    }

    .service-name {
        font-size: 1.1rem;
        font-weight: 700;
        color: #fff;
    }

    .service-link {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 14px;
        background: #1a1a1a;
        border: 1px solid #333;
        border-radius: 8px;
        color: #ff4d4d;
        font-size: 0.8rem;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s ease;
    }

    .service-link:hover {
        background: rgba(255, 77, 77, 0.1);
        border-color: #7F0000;
        color: #ff6b6b;
    }

    /* Info grid */
    .info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap: 12px;
    }

    .info-item {
        background: #111;
        border: 1px solid #1e1e1e;
        border-radius: 10px;
        padding: 14px 18px;
    }

    .info-label {
        font-size: 0.7rem;
        color: #666;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 4px;
    }

    .info-value {
        font-family: 'JetBrains Mono', monospace;
        font-size: 0.88rem;
        color: #ccc;
        word-break: break-all;
    }

    /* Warning items */
    .warning-item {
        padding: 10px 14px;
        background: rgba(245, 158, 11, 0.06);
        border: 1px solid rgba(245, 158, 11, 0.15);
        border-radius: 8px;
        margin-bottom: 8px;
        font-size: 0.88rem;
        color: #fbbf24;
    }

    .warning-item .warning-type {
        display: inline-block;
        padding: 2px 8px;
        background: rgba(245, 158, 11, 0.15);
        border-radius: 4px;
        font-size: 0.7rem;
        font-weight: 700;
        text-transform: uppercase;
        margin-right: 8px;
    }

    /* Blacklist grid */
    .blacklist-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 8px;
        margin-top: 10px;
    }

    .bl-item {
        padding: 10px 14px;
        border-radius: 8px;
        font-size: 0.82rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .bl-clean { background: rgba(34, 197, 94, 0.06); border: 1px solid rgba(34, 197, 94, 0.15); }
    .bl-flagged { background: rgba(239, 68, 68, 0.06); border: 1px solid rgba(239, 68, 68, 0.15); }

    .bl-name { color: #aaa; }
    .bl-status-clean { color: #4ade80; font-weight: 600; }
    .bl-status-flagged { color: #f87171; font-weight: 600; }

    /* Pulse list */
    .pulse-item {
        background: #111;
        border: 1px solid #1e1e1e;
        border-radius: 10px;
        padding: 14px 18px;
        margin-bottom: 10px;
        transition: all 0.3s ease;
    }

    .pulse-item:hover { border-color: #333; }

    .pulse-name {
        font-weight: 600;
        color: #fff;
        margin-bottom: 6px;
    }

    .pulse-desc {
        font-size: 0.85rem;
        color: #888;
        margin-bottom: 6px;
        line-height: 1.4;
    }

    .pulse-meta {
        display: flex;
        gap: 12px;
        flex-wrap: wrap;
        font-size: 0.75rem;
        color: #555;
    }

    .pulse-tag {
        display: inline-block;
        padding: 2px 8px;
        background: rgba(127, 0, 0, 0.15);
        border: 1px solid rgba(127, 0, 0, 0.3);
        border-radius: 4px;
        color: #ff6b6b;
        font-size: 0.7rem;
        margin-right: 4px;
        margin-bottom: 4px;
    }

    /* Link-only card (Quttera fallback / AbuseIPDB) */
    .link-card-action {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 12px;
        padding: 30px;
        background: #111;
        border: 1px dashed #333;
        border-radius: 12px;
        transition: all 0.3s ease;
    }

    .link-card-action:hover {
        border-color: #7F0000;
        background: rgba(127, 0, 0, 0.05);
    }

    .link-card-action a {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 12px 24px;
        background: linear-gradient(135deg, #7F0000 0%, #4d0000 100%);
        border-radius: 10px;
        color: #fff;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s ease;
    }

    .link-card-action a:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(127, 0, 0, 0.4);
    }

    /* Spinner */
    .spinner-overlay {
        display: none;
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(5, 5, 5, 0.85);
        z-index: 9999;
        justify-content: center;
        align-items: center;
        flex-direction: column;
    }
    .spinner-overlay.active { display: flex; }
    .spinner {
        width: 50px; height: 50px;
        border: 3px solid #222;
        border-top-color: #ff4d4d;
        border-radius: 50%;
        animation: spin 0.8s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
    .spinner-text { color: #888; margin-top: 15px; font-size: 0.9rem; }

    /* Quttera partial data table */
    .quttera-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    .quttera-table td { padding: 8px 12px; border-bottom: 1px solid #1a1a1a; font-size: 0.85rem; }
    .quttera-table td:first-child { color: #888; width: 40%; }
    .quttera-table td:last-child { color: #ccc; font-family: 'JetBrains Mono', monospace; }
</style>

<div id="loadingOverlay" class="spinner-overlay">
    <div class="spinner"></div>
    <div class="spinner-text">Analizando reputación del hostname...</div>
</div>

<div class="container-fluid py-5 px-4">
    <div class="mb-4">
        <h4 class="text-4xl font-bold m-0">Hostname Checker</h4>
        <p class="text-gray-500 mt-2">Analiza la reputación de un dominio/hostname en <b class="text-red-500">Sucuri</b>, <b class="text-red-500">OTX AlienVault</b>, <b class="text-red-500">Quttera</b> y <b class="text-red-500">AbuseIPDB</b></p>
    </div>

    <div class="search-card">
        <form id="searchForm" method="GET" action="/hostname-check" class="row align-items-end" onsubmit="showLoading()">
            <div class="col-md-10 mb-3 mb-md-0">
                <label for="hostnameInput" class="small text-uppercase tracking-wider text-gray-500 mb-2 d-block">Hostname / Dominio</label>
                <input id="hostnameInput" type="text" name="hostname" value="{{ hostname if defined('hostname') and hostname else '' }}" placeholder="example.com" class="search" required />
            </div>
            <div class="col-md-2">
                <input type="submit" value="Analizar" class="btn-lookup w-100" />
            </div>
        </form>
    </div>

    % if defined('results') and results:
    % for res in results:
    <div class="service-card">
        <div class="service-header">
            <span class="service-name">
                % if res['service'] == 'Sucuri SiteCheck':
                🛡️
                % elif res['service'] == 'OTX AlienVault':
                🔮
                % elif res['service'] == 'Quttera':
                🔬
                % elif res['service'] == 'AbuseIPDB':
                ⚡
                % end
                {{ res['service'] }}
            </span>
            <div style="display: flex; gap: 10px; align-items: center;">
                % if res['status'] == 'ok' and res['data'].get('risk_level'):
                    % risk = res['data']['risk_level']
                    <span class="risk-badge risk-{{ risk.lower() }}">{{ risk }}</span>
                % end
                <a href="{{ res['url'] }}" target="_blank" class="service-link">
                    Ver en sitio ↗
                </a>
            </div>
        </div>

        % if res['status'] == 'error':
            <p style="color: #f87171; font-size: 0.9rem;">{{ res['data'].get('error', 'Error al conectar con el servicio.') }}</p>

        % elif res['status'] == 'link_only':
            <div class="link-card-action">
                % if res['data'].get('message'):
                <p style="color: #888; margin: 0;">{{ res['data']['message'] }}</p>
                % end
                <a href="{{ res['url'] }}" target="_blank">
                    Abrir {{ res['service'] }} ↗
                </a>
            </div>

        % elif res['service'] == 'Sucuri SiteCheck':
            <!-- Sucuri: Site Info -->
            % data = res['data']
            % if data.get('site_info'):
            <h6 style="color: #888; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px;">Información del Sitio</h6>
            <div class="info-grid" style="margin-bottom: 20px;">
                % for key, val in data['site_info'].items():
                <div class="info-item">
                    <div class="info-label">{{ key.replace('_', ' ').title() }}</div>
                    <div class="info-value">{{ val }}</div>
                </div>
                % end
            </div>
            % end

            <!-- Sucuri: Blacklist Status -->
            % if data.get('blacklists'):
            <h6 style="color: #888; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px;">Blacklist Status</h6>
            <div class="blacklist-grid" style="margin-bottom: 20px;">
                % for bl_name, bl_status in data['blacklists'].items():
                    % is_clean = str(bl_status).lower() in ('clean', 'ok', '0', 'false', '')
                    <div class="bl-item {{ 'bl-clean' if is_clean else 'bl-flagged' }}">
                        <span class="bl-name">{{ bl_name }}</span>
                        <span class="{{ 'bl-status-clean' if is_clean else 'bl-status-flagged' }}">
                            {{ 'Clean' if is_clean else bl_status }}
                        </span>
                    </div>
                % end
            </div>
            % end

            <!-- Sucuri: Warnings -->
            % if data.get('warnings'):
            <h6 style="color: #fbbf24; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px;">⚠ Avisos ({{ len(data['warnings']) }})</h6>
            % for w in data['warnings'][:15]:
            <div class="warning-item">
                <span class="warning-type">{{ w.get('type', 'info') }}</span>
                {{ w.get('message', '') }}
            </div>
            % end
            % if len(data['warnings']) > 15:
            <p style="color: #666; font-size: 0.8rem;">... y {{ len(data['warnings']) - 15 }} más.</p>
            % end
            % end

            <!-- Sucuri: Recommendations -->
            % if data.get('recommendations'):
            <h6 style="color: #60a5fa; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 1px; margin: 15px 0 12px;">💡 Recomendaciones</h6>
            % for r in data['recommendations'][:10]:
            <div style="padding: 8px 14px; background: rgba(59, 130, 246, 0.06); border: 1px solid rgba(59, 130, 246, 0.15); border-radius: 8px; margin-bottom: 8px; font-size: 0.85rem; color: #93c5fd;">
                {{ r.get('message', '') }}
            </div>
            % end
            % end

        % elif res['service'] == 'OTX AlienVault':
            % data = res['data']
            <!-- OTX: Basic info -->
            <div class="info-grid" style="margin-bottom: 20px;">
                <div class="info-item">
                    <div class="info-label">Indicador</div>
                    <div class="info-value">{{ data.get('indicator', hostname) }}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Pulsos de Amenaza</div>
                    <div class="info-value" style="color: {{ '#f87171' if data.get('pulse_count', 0) > 0 else '#4ade80' }}; font-weight: 700;">{{ data.get('pulse_count', 0) }}</div>
                </div>
                % if data.get('alexa'):
                <div class="info-item">
                    <div class="info-label">Alexa Rank</div>
                    <div class="info-value">{{ data['alexa'] }}</div>
                </div>
                % end
            </div>

            <!-- OTX: Validation messages -->
            % if data.get('validation'):
            <h6 style="color: #fbbf24; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px;">Validaciones</h6>
            % for v in data['validation']:
            <div class="warning-item">{{ v }}</div>
            % end
            % end

            <!-- OTX: Pulses -->
            % if data.get('pulses'):
            <h6 style="color: #888; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 1px; margin: 15px 0 12px;">Pulsos de Inteligencia de Amenazas ({{ data['pulse_count'] }})</h6>
            % for p in data['pulses'][:10]:
            <div class="pulse-item">
                <div class="pulse-name">{{ p.get('name', 'N/A') }}</div>
                % if p.get('description'):
                <div class="pulse-desc">{{ p['description'] }}</div>
                % end
                <div class="pulse-meta">
                    % if p.get('created'):
                    <span>📅 {{ p['created'][:10] if len(p['created']) >= 10 else p['created'] }}</span>
                    % end
                    % if p.get('adversary'):
                    <span>🎯 {{ p['adversary'] }}</span>
                    % end
                </div>
                % if p.get('tags'):
                <div style="margin-top: 8px;">
                    % for tag in p['tags'][:6]:
                    <span class="pulse-tag">{{ tag }}</span>
                    % end
                </div>
                % end
            </div>
            % end
            % if data['pulse_count'] > 10:
            <p style="color: #666; font-size: 0.8rem;">... y {{ data['pulse_count'] - 10 }} pulsos más. Visita OTX para ver todos.</p>
            % end
            % end

            % if not data.get('pulses') and data.get('pulse_count', 0) == 0:
            <p style="color: #4ade80; font-size: 0.9rem;">✓ No se encontraron pulsos de amenazas para este dominio.</p>
            % end

        % elif res['service'] == 'Quttera' and res['status'] == 'partial':
            % data = res['data']
            % if data.get('scan_status'):
            <div class="info-grid" style="margin-bottom: 15px;">
                <div class="info-item">
                    <div class="info-label">Estado del Escaneo</div>
                    <div class="info-value">{{ data['scan_status'] }}</div>
                </div>
            </div>
            % end
            % if data.get('verdict'):
            <div class="info-grid" style="margin-bottom: 15px;">
                <div class="info-item">
                    <div class="info-label">Veredicto</div>
                    <div class="info-value">{{ data['verdict'] }}</div>
                </div>
            </div>
            % end
            % if data.get('indicators'):
            <div style="margin-bottom: 15px;">
                <h6 style="color: #888; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 8px;">Indicadores Detectados</h6>
                % for ind in data['indicators']:
                <span class="pulse-tag" style="font-size: 0.8rem; padding: 4px 10px;">{{ ind }}</span>
                % end
            </div>
            % end
            % if data.get('details'):
            <table class="quttera-table">
                % for d in data['details'][:15]:
                <tr><td>{{ d['key'] }}</td><td>{{ d['value'] }}</td></tr>
                % end
            </table>
            % end
            <div style="margin-top: 15px;">
                <a href="{{ res['url'] }}" target="_blank" class="service-link" style="font-size: 0.85rem;">
                    Ver reporte completo en Quttera ↗
                </a>
            </div>
        % end
    </div>
    % end
    % end
</div>

<script>
    function showLoading() {
        document.getElementById('loadingOverlay').classList.add('active');
    }
</script>

% include("footer")
