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

    /* Target type badges */
    .type-badge {
        display: inline-block;
        padding: 4px 14px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .type-badge.email { background: rgba(59, 130, 246, 0.15); color: #60a5fa; border: 1px solid rgba(59, 130, 246, 0.3); }
    .type-badge.domain { background: rgba(168, 85, 247, 0.15); color: #c084fc; border: 1px solid rgba(168, 85, 247, 0.3); }
    .type-badge.username { background: rgba(34, 197, 94, 0.15); color: #4ade80; border: 1px solid rgba(34, 197, 94, 0.3); }

    /* Source section cards */
    .source-card {
        background: #0a0a0a;
        border: 1px solid #1a1a1a;
        border-radius: 16px;
        padding: 25px;
        margin-bottom: 20px;
        transition: all 0.3s ease;
    }

    .source-card:hover {
        border-color: rgba(127, 0, 0, 0.3);
        box-shadow: 0 5px 20px rgba(0,0,0,0.3);
    }

    .source-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 18px;
        padding-bottom: 12px;
        border-bottom: 1px solid #1e1e1e;
    }

    .source-name {
        font-size: 1.1rem;
        font-weight: 700;
        color: #fff;
    }

    .source-count {
        font-size: 0.85rem;
        padding: 4px 12px;
        border-radius: 20px;
        font-weight: 600;
    }

    .count-danger { background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.3); }
    .count-warning { background: rgba(245, 158, 11, 0.15); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.3); }
    .count-safe { background: rgba(34, 197, 94, 0.15); color: #4ade80; border: 1px solid rgba(34, 197, 94, 0.3); }

    /* Stealer entries */
    .stealer-entry {
        background: #111;
        border: 1px solid #1e1e1e;
        border-radius: 12px;
        padding: 18px;
        margin-bottom: 12px;
    }

    .stealer-entry:hover { border-color: #333; }

    .stealer-field {
        display: flex;
        padding: 4px 0;
        font-size: 0.88rem;
    }

    .stealer-label {
        min-width: 180px;
        color: #666;
        font-weight: 500;
    }

    .stealer-value {
        color: #ccc;
        font-family: 'JetBrains Mono', monospace;
        word-break: break-all;
    }

    /* COMB entries */
    .comb-entry {
        padding: 8px 14px;
        background: #111;
        border: 1px solid #1a1a1a;
        border-radius: 8px;
        margin-bottom: 6px;
        font-family: 'JetBrains Mono', monospace;
        font-size: 0.85rem;
        color: #ffaa00;
        word-break: break-all;
    }

    /* LC sources */
    .lc-source {
        display: flex;
        justify-content: space-between;
        padding: 8px 14px;
        background: #111;
        border: 1px solid #1a1a1a;
        border-radius: 8px;
        margin-bottom: 6px;
        font-size: 0.88rem;
    }

    .lc-source-name { color: #ccc; font-weight: 500; }
    .lc-source-date { color: #666; font-family: 'JetBrains Mono', monospace; }

    /* Summary card */
    .summary-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 15px;
        margin-top: 10px;
    }

    .summary-stat {
        background: #111;
        border: 1px solid #1e1e1e;
        border-radius: 12px;
        padding: 18px;
        text-align: center;
    }

    .summary-stat-value {
        font-size: 2rem;
        font-weight: 800;
        background: linear-gradient(135deg, #ff4d4d, #ff8c00);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }

    .summary-stat-label {
        font-size: 0.75rem;
        color: #666;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-top: 4px;
    }

    /* Export button */
    .action-control-btn {
        background: #1a1a1a;
        border: 1px solid #333;
        color: #eee;
        padding: 10px 18px;
        border-radius: 10px;
        cursor: pointer;
        font-size: 0.85rem;
        font-weight: 600;
        transition: all 0.3s ease;
        display: inline-flex;
        align-items: center;
        text-decoration: none !important;
        height: 42px;
    }

    .action-control-btn:hover { background: #252525; border-color: #444; color: #fff; }

    .export-variant { color: #ff4d4d; }
    .export-variant:hover { background: rgba(255, 77, 77, 0.1); border-color: #7F0000; }

    /* Employees/Users table */
    .emp-table { width: 100%; border-collapse: collapse; }
    .emp-table th { text-align: left; padding: 10px; color: #666; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; border-bottom: 1px solid #222; }
    .emp-table td { padding: 10px; font-family: 'JetBrains Mono', monospace; font-size: 0.85rem; color: #ccc; border-bottom: 1px solid #161616; }
    .emp-table tr:hover td { background: rgba(255,255,255,0.02); }

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
</style>

<div id="loadingOverlay" class="spinner-overlay">
    <div class="spinner"></div>
    <div class="spinner-text">Buscando leaks en múltiples fuentes...</div>
</div>

<div class="container-fluid py-5 px-4">
    <div class="mb-4 d-flex justify-content-between align-items-center">
        <div>
            <h4 class="text-4xl font-bold m-0">Leak Search <span style="color: #666; font-weight:400; font-size: 0.9rem;">(API)</span></h4>
            <p class="text-gray-500 mt-2">Busca exposiciones de credenciales y leaks en <b class="text-red-500">Hudson Rock</b>, <b class="text-red-500">ProxyNova COMB</b> y <b class="text-red-500">LeakCheck</b></p>
        </div>
        % if defined('report') and report:
        <a href="/leaksearch/export?target={{ report.target }}" class="action-control-btn export-variant">
            ⬇ Export CSV
        </a>
        % end
    </div>

    <div class="search-card">
        <form id="searchForm" method="GET" action="/leaksearch" class="row align-items-end" onsubmit="showLoading()">
            <div class="col-md-8 mb-3 mb-md-0">
                <label for="targetInput" class="small text-uppercase tracking-wider text-gray-500 mb-2 d-block">Target (email / domain / username)</label>
                <input id="targetInput" type="text" name="target" value="{{ target if defined('target') and target else '' }}" placeholder="user@example.com, example.com, username" class="search" required />
            </div>
            <div class="col-md-2 mb-3 mb-md-0">
                % if defined('target_type') and target_type:
                <span class="type-badge {{ target_type }}">{{ target_type }}</span>
                % end
            </div>
            <div class="col-md-2">
                <input type="submit" value="Search" class="btn-lookup w-100" />
            </div>
        </form>
    </div>

    % if defined('report') and report:
    <!-- Summary Stats -->
    <div class="source-card" style="border-color: rgba(127, 0, 0, 0.2);">
        <div class="source-header">
            <span class="source-name">📊 Resumen</span>
            <span class="type-badge {{ report.target_type }}">{{ report.target_type }}</span>
        </div>
        <div class="summary-grid">
            <div class="summary-stat">
                <div class="summary-stat-value">{{ len(report.hr_stealers) }}</div>
                <div class="summary-stat-label">Stealers (HR)</div>
            </div>
            % if report.target_type == "domain":
            <div class="summary-stat">
                <div class="summary-stat-value">{{ len(report.hr_employees) }}</div>
                <div class="summary-stat-label">Empleados (HR)</div>
            </div>
            <div class="summary-stat">
                <div class="summary-stat-value">{{ len(report.hr_users) }}</div>
                <div class="summary-stat-label">Usuarios (HR)</div>
            </div>
            % end
            % if report.target_type == "email":
            <div class="summary-stat">
                <div class="summary-stat-value">{{ report.comb_count }}</div>
                <div class="summary-stat-label">COMB Hits</div>
            </div>
            <div class="summary-stat">
                <div class="summary-stat-value">{{ len(report.lc_sources) }}</div>
                <div class="summary-stat-label">LC Sources</div>
            </div>
            <div class="summary-stat">
                <div class="summary-stat-value">{{ report.lc_found }}</div>
                <div class="summary-stat-label">LC Found</div>
            </div>
            % end
        </div>
    </div>

    <!-- Hudson Rock Section -->
    <div class="source-card">
        <div class="source-header">
            <span class="source-name">🛡️ Hudson Rock Cavalier</span>
            % if len(report.hr_stealers) > 0:
            <span class="source-count count-danger">{{ len(report.hr_stealers) }} stealer(s)</span>
            % elif len(report.hr_employees) > 0 or len(report.hr_users) > 0:
            <span class="source-count count-warning">{{ len(report.hr_employees) }} emp / {{ len(report.hr_users) }} users</span>
            % else:
            <span class="source-count count-safe">Sin resultados</span>
            % end
        </div>

        % if report.hr_message:
        <div style="padding: 10px 14px; background: rgba(245, 158, 11, 0.1); border: 1px solid rgba(245, 158, 11, 0.3); border-radius: 10px; margin-bottom: 15px; color: #fbbf24; font-size: 0.88rem;">
            ⚠ {{ report.hr_message }}
        </div>
        % end

        % if report.hr_stealers:
            % for i, s in enumerate(report.hr_stealers):
            <div class="stealer-entry">
                <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                    <span style="color: #ff4d4d; font-weight: 700;">Entry {{ i + 1 }}/{{ len(report.hr_stealers) }}</span>
                    <span style="color: #555; font-size: 0.8rem;">{{ s.date_compromised or 'N/A' }}</span>
                </div>
                <div class="stealer-field"><span class="stealer-label">Stealer Family</span><span class="stealer-value">{{ s.stealer_family or 'N/A' }}</span></div>
                <div class="stealer-field"><span class="stealer-label">Computer</span><span class="stealer-value">{{ s.computer_name or 'N/A' }}</span></div>
                <div class="stealer-field"><span class="stealer-label">OS</span><span class="stealer-value">{{ s.operating_system or 'N/A' }}</span></div>
                <div class="stealer-field"><span class="stealer-label">IP</span><span class="stealer-value">{{ s.ip or 'N/A' }}</span></div>
                <div class="stealer-field"><span class="stealer-label">Malware Path</span><span class="stealer-value">{{ s.malware_path or 'N/A' }}</span></div>
                <div class="stealer-field"><span class="stealer-label">Corporate Services</span><span class="stealer-value">{{ s.total_corporate_services }}</span></div>
                <div class="stealer-field"><span class="stealer-label">User Services</span><span class="stealer-value">{{ s.total_user_services }}</span></div>
                % if s.top_logins:
                <div class="stealer-field"><span class="stealer-label">Top Logins</span><span class="stealer-value">{{ ', '.join(s.top_logins) }}</span></div>
                % end
                % if s.top_passwords:
                <div class="stealer-field"><span class="stealer-label">Top Passwords</span><span class="stealer-value" style="color: #ffaa00;">{{ ', '.join(s.top_passwords) }}</span></div>
                % end
            </div>
            % end
        % elif report.hr_employees or report.hr_users:
            % if report.hr_employees:
            <h6 style="color: #888; margin-bottom: 10px; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px;">Empleados ({{ len(report.hr_employees) }})</h6>
            <table class="emp-table">
                <thead><tr><th>URL</th><th>Occurrences</th></tr></thead>
                <tbody>
                % for emp in report.hr_employees[:20]:
                <tr><td>{{ emp.get('url', 'N/A') }}</td><td>{{ emp.get('occurrence', 'N/A') }}</td></tr>
                % end
                </tbody>
            </table>
            % if len(report.hr_employees) > 20:
            <p style="color: #666; font-size: 0.8rem; margin-top: 8px;">... y {{ len(report.hr_employees) - 20 }} más. Exporta a CSV para ver todos.</p>
            % end
            % end

            % if report.hr_users:
            <h6 style="color: #888; margin: 15px 0 10px 0; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px;">Usuarios ({{ len(report.hr_users) }})</h6>
            <table class="emp-table">
                <thead><tr><th>URL</th><th>Occurrences</th></tr></thead>
                <tbody>
                % for usr in report.hr_users[:20]:
                <tr><td>{{ usr.get('url', 'N/A') }}</td><td>{{ usr.get('occurrence', 'N/A') }}</td></tr>
                % end
                </tbody>
            </table>
            % if len(report.hr_users) > 20:
            <p style="color: #666; font-size: 0.8rem; margin-top: 8px;">... y {{ len(report.hr_users) - 20 }} más.</p>
            % end
            % end
        % else:
        <p style="color: #666; font-size: 0.9rem;">No se encontraron registros de stealers para este target en Hudson Rock.</p>
        % end
    </div>

    <!-- COMB Section (email only) -->
    % if report.target_type == "email":
    <div class="source-card">
        <div class="source-header">
            <span class="source-name">📂 ProxyNova COMB</span>
            % if report.comb_count > 0:
            <span class="source-count count-danger">{{ "{:,}".format(report.comb_count) }} hit(s)</span>
            % else:
            <span class="source-count count-safe">Sin hits</span>
            % end
        </div>
        % if report.comb_entries:
            % for entry in report.comb_entries[:25]:
            <div class="comb-entry">{{ entry.line }}</div>
            % end
            % if len(report.comb_entries) > 25:
            <p style="color: #666; font-size: 0.8rem; margin-top: 8px;">... y {{ len(report.comb_entries) - 25 }} más. Exporta a CSV para ver todos.</p>
            % end
        % else:
        <p style="color: #666; font-size: 0.9rem;">No se encontraron entradas en la base de datos COMB.</p>
        % end
    </div>

    <!-- LeakCheck Section -->
    <div class="source-card">
        <div class="source-header">
            <span class="source-name">🔍 LeakCheck</span>
            % if len(report.lc_sources) > 0:
            <span class="source-count count-warning">{{ len(report.lc_sources) }} source(s)</span>
            % else:
            <span class="source-count count-safe">Sin sources</span>
            % end
        </div>
        % if report.lc_sources:
            % for src in report.lc_sources[:30]:
            <div class="lc-source">
                <span class="lc-source-name">{{ src.name }}</span>
                <span class="lc-source-date">{{ src.date or 'N/A' }}</span>
            </div>
            % end
            % if len(report.lc_sources) > 30:
            <p style="color: #666; font-size: 0.8rem; margin-top: 8px;">... y {{ len(report.lc_sources) - 30 }} más.</p>
            % end
        % else:
        <p style="color: #666; font-size: 0.9rem;">No se encontraron fuentes de leaks en LeakCheck.</p>
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
