% include("header")
<style>
    @import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=JetBrains+Mono:wght@400;700&display=swap");

    * { font-family: 'Inter', sans-serif; }

    body {
        background-color: #050505;
        color: #e0e0e0;
    }

    /* Card de formulaire identique à la search-card de index */
    .upload-card {
        background: #0f0f0f;
        border: 1px solid #1e1e1e;
        border-radius: 20px;
        padding: 40px;
        margin: 0 auto;
        max-width: 800px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.4);
    }

    .form-group-custom {
        margin-bottom: 20px;
    }

    .label-custom {
        font-size: 0.75rem;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        color: #666;
        font-weight: 700;
        margin-bottom: 8px;
        display: block;
    }

    /* Style des champs identique à la classe .search de index */
    .form-select, .upload-input, .file-input-custom {
        background-color: #121212 !important;
        border: 1px solid #2a2a2a !important;
        border-radius: 12px !important;
        color: #ffffff !important;
        padding: 14px 18px !important;
        font-family: 'JetBrains Mono', monospace !important;
        font-size: 15px;
        width: 100%;
        transition: all 0.3s ease;
        outline: none;
    }

    .form-select:focus, .upload-input:focus {
        border-color: #7F0000 !important;
        box-shadow: 0 0 0 4px rgba(127, 0, 0, 0.15);
    }

    /* Bouton identique au bouton Lookup de index */
    .btn-upload {
        background: linear-gradient(135deg, #7F0000 0%, #4d0000 100%) !important;
        border: none !important;
        border-radius: 12px !important;
        padding: 16px 30px !important;
        font-weight: 600 !important;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: white;
        transition: all 0.3s ease !important;
        cursor: pointer;
        width: 100%;
        margin-top: 10px;
    }

    .btn-upload:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(127, 0, 0, 0.4);
    }

    #messageArea {
        margin-top: 10px;
        font-size: 13px;
        color: #888;
        font-style: italic;
        padding: 12px;
        background: rgba(255, 255, 255, 0.02);
        border-radius: 10px;
        border-left: 3px solid #7F0000;
        display: block;
    }

    h4 {
        color: #ffffff;
        font-weight: 700;
        letter-spacing: -1px;
    }
</style>

<div class="container-fluid py-5">
    <div class="text-center mb-5">
        <h4 class="text-4xl m-0">Data Ingestion</h4>
        <p class="text-gray-500 mt-2">Upload and index new leak files into the database</p>
    </div>

    <div class="upload-card">
        <form method="POST" action="/upload" enctype="multipart/form-data">
            
            <div class="form-group-custom">
                <label class="label-custom"><i class="fas fa-layer-group mr-2"></i> Data Category</label>
                <select name="dataType" id="dataType" class="form-select" required>
                    <option value="credentials">Credentials (User/Pass)</option>
                    <option value="passwords">Passwords Only (Wordlist)</option>
                    <option value="phone_numbers">Phone Numbers</option>
                    <option value="misc_file">Misc (SQL/CSV/JSON)</option>
                    <option value="api_feed">API Feed (Website/URL)</option>
                </select>
                <div id="messageArea"></div>
            </div>

            <div class="form-group-custom" id="fileGroup">
                <label class="label-custom"><i class="fas fa-file-upload mr-2"></i> Source File</label>
                <input class="file-input-custom" id="fileInput" type="file" name="file" accept=".txt,.sql,.json,.csv" required />
            </div>

            <div class="form-group-custom" id="apiGroup" style="display: none;">
                <label class="label-custom"><i class="fas fa-link mr-2"></i> API URL Base</label>
                <input class="upload-input" id="apiInput" type="text" name="apiUrl" placeholder="e.g. https://www.abuseipdb.com/check/" />
                <small class="d-block mt-2" style="color: #888; font-size: 0.8rem;">El hostname a comprobar se anadira automaticamente al final de la URL.</small>
            </div>

            <div class="row">
                <div class="col-md-8 form-group-custom">
                    <label class="label-custom"><i class="fas fa-tag mr-2"></i> Leak/Feed Name</label>
                    <input class="upload-input" type="text" name="leakName" placeholder="e.g. LinkedIn 2024 or AbuseIPDB" required />
                </div>
                <div class="col-md-4 form-group-custom" id="dateGroup">
                    <label class="label-custom"><i class="fas fa-calendar-alt mr-2"></i> Year</label>
                    <input class="upload-input" id="dateInput" type="text" name="leakDate" placeholder="YYYY" required />
                </div>
            </div>

            <button type="submit" class="btn-upload" id="submitBtn">
                <i class="fas fa-cloud-upload-alt mr-2"></i> Start Import Process
            </button>
        </form>
    </div>
</div>

<!-- Progress Overlay -->
<div id="progressOverlay" class="spinner-overlay">
    <div class="spinner"></div>
    <div class="spinner-text" id="statusText">Uploading file...</div>
    <div style="margin-top: 20px; font-size: 0.8rem; color: #555;" id="debugStatus">Preparing...</div>
</div>

<script>
    function showMessage() {
        var dataType = document.getElementById('dataType').value;
        var messageArea = document.getElementById('messageArea');
        var fileGroup = document.getElementById('fileGroup');
        var apiGroup = document.getElementById('apiGroup');
        var dateGroup = document.getElementById('dateGroup');
        
        var fileInput = document.getElementById('fileInput');
        var apiInput = document.getElementById('apiInput');
        var dateInput = document.getElementById('dateInput');

        messageArea.innerHTML = '';
        
        if (dataType === 'api_feed') {
            fileGroup.style.display = 'none';
            dateGroup.style.display = 'none';
            apiGroup.style.display = 'block';
            
            fileInput.required = false;
            dateInput.required = false;
            apiInput.required = true;
        } else {
            fileGroup.style.display = 'block';
            dateGroup.style.display = 'block';
            apiGroup.style.display = 'none';
            
            fileInput.required = true;
            dateInput.required = true;
            apiInput.required = false;
        }

        switch (dataType) {
            case 'credentials':
                messageArea.innerHTML = 'Format: password OR email:password OR url:user:password';
                break;
            case 'passwords':
                messageArea.innerHTML = 'Format: One password per line (Wordlist mode)';
                break;
            case 'phone_numbers':
                messageArea.innerHTML = 'Format: One phone number per line';
                break;
            case 'misc_file':
                messageArea.innerHTML = 'Format: Raw SQL, CSV, or JSON structure';
                break;
            case 'api_feed':
                messageArea.innerHTML = 'Guarda una nueva fuente externa para Hostname Checker';
                break;
            default:
                messageArea.innerHTML = '';
                break;
        }
    }
    document.getElementById('dataType').addEventListener('change', showMessage);
    showMessage();

    // Handling form with AJAX for better UX and preventing timeout
    document.querySelector('form').onsubmit = async function(e) {
        e.preventDefault();
        
        const formData = new FormData(this);
        const overlay = document.getElementById('progressOverlay');
        const statusText = document.getElementById('statusText');
        const debugStatus = document.getElementById('debugStatus');
        
        overlay.classList.add('active');
        statusText.innerText = "Uploading file to server...";
        
        try {
            const response = await fetch('/upload', {
                method: 'POST',
                body: formData
            });
            
            if (!response.ok) throw new Error("Upload failed");
            
            const result = await response.json();
            const leakName = result.leakName;
            
            if (result.status === "started") {
                statusText.innerText = "Processing large file...";
                
                // Polling for status
                const poll = setInterval(async () => {
                    const statusResp = await fetch('/upload/status');
                    const statuses = await statusResp.json();
                    const currentStatus = statuses[leakName];
                    
                    if (currentStatus) {
                        debugStatus.innerText = "Status: " + currentStatus;
                        if (currentStatus === "Completed successfully") {
                            clearInterval(poll);
                            statusText.innerText = "Import Finished!";
                            setTimeout(() => { overlay.classList.remove('active'); location.reload(); }, 2000);
                        } else if (currentStatus.startsWith("Error") || currentStatus.startsWith("Exception")) {
                            clearInterval(poll);
                            statusText.innerText = "Error during import";
                            statusText.style.color = "#ff4d4d";
                            setTimeout(() => overlay.classList.remove('active'), 5000);
                        }
                    }
                }, 2000);
            } else {
                overlay.classList.remove('active');
                alert("Settings saved.");
            }
            
        } catch (err) {
            alert("Error: " + err.message);
            overlay.classList.remove('active');
        }
    };
</script>

% include("footer")