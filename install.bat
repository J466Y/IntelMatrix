@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   Leaky - Windows Installer
echo ============================================
echo.

:: -----------------------------------------------------------
:: 1. Check Python is installed
:: -----------------------------------------------------------
echo [*] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] ERROR: Python no encontrado. Instala Python 3.10+ desde https://www.python.org/downloads/
    echo [!] Asegurate de marcar "Add Python to PATH" durante la instalacion.
    pause
    exit /b 1
)
for /f "tokens=2 delims= " %%v in ('python --version 2^>^&1') do (
    echo %tab%[+] Python %%v detectado.
)
echo.

:: -----------------------------------------------------------
:: 2. Create virtual environment
:: -----------------------------------------------------------
echo [*] Creando entorno virtual (venv)...
if not exist "venv" (
    python -m venv venv
    if %errorlevel% neq 0 (
        echo [!] ERROR: No se pudo crear el entorno virtual.
        pause
        exit /b 1
    )
    echo %tab%[+] Entorno virtual creado en .\venv
) else (
    echo %tab%[+] Entorno virtual ya existe en .\venv
)
echo.

:: -----------------------------------------------------------
:: 3. Activate venv & install dependencies
:: -----------------------------------------------------------
echo [*] Activando entorno virtual e instalando dependencias...
call venv\Scripts\activate.bat

pip install --no-cache-dir -r requirements.txt
if %errorlevel% neq 0 (
    echo [!] ERROR: Fallo al instalar dependencias pip.
    pause
    exit /b 1
)
echo %tab%[+] Dependencias instaladas correctamente.
echo.

:: -----------------------------------------------------------
:: 4. Check & Download Mongosh
:: -----------------------------------------------------------
echo [*] Comprobando Mongosh local...
if not exist "Mongosh\mongosh.exe" (
    echo [-] No se encontro Mongosh\mongosh.exe localmente.
    echo [*] Descargando MongoDB Shell (v2.7.0)...
    
    if not exist "Mongosh" mkdir Mongosh
    
    powershell -Command "Invoke-WebRequest -Uri 'https://downloads.mongodb.com/compass/mongosh-2.7.0-win32-x64.zip' -OutFile 'Mongosh\mongosh.zip'"
    if %errorlevel% neq 0 (
        echo [!] ERROR: Fallo al descargar mongosh.zip. Necesitas conexion a internet.
        pause
        exit /b 1
    )
    
    echo [*] Extrayendo mongosh...
    powershell -Command "Expand-Archive -Path 'Mongosh\mongosh.zip' -DestinationPath 'Mongosh\temp_extract' -Force"
    
    :: Mover archivo
    move /Y "Mongosh\temp_extract\mongosh-2.7.0-win32-x64\bin\mongosh.exe" "Mongosh\mongosh.exe" >nul
    
    :: Limpieza
    rmdir /S /Q "Mongosh\temp_extract"
    del /Q "Mongosh\mongosh.zip"
    
    echo %tab%[+] Mongosh.exe descargado y extraido en la carpeta Mongosh.
) else (
    echo %tab%[+] Mongosh local detectado.
)
echo.

:: -----------------------------------------------------------
:: 5. Check MongoDB
:: -----------------------------------------------------------
echo [*] Comprobando MongoDB...
Mongosh\mongosh.exe --eval "db.adminCommand('ping')" --quiet >nul 2>&1
if %errorlevel% neq 0 (
    echo [-] AVISO: MongoDB no parece estar ejecutandose.
    echo [-] Asegurate de que MongoDB esta instalado y el servicio esta activo.
    echo [-] Descarga MongoDB Community: https://www.mongodb.com/try/download/community
    echo [-] Tambien instala mongosh: https://www.mongodb.com/try/download/shell
    echo.
    set /p SKIP_MONGO="Continuar sin MongoDB? (s/n): "
    if /i "!SKIP_MONGO!" neq "s" (
        echo [!] Instalacion cancelada. Inicia MongoDB y vuelve a ejecutar este script.
        pause
        exit /b 1
    )
    echo.
    goto :skip_mongo
)
echo %tab%[+] MongoDB esta activo.
echo.

:: -----------------------------------------------------------
:: 6. Configure MongoDB indexes and collections
:: -----------------------------------------------------------
set MONGO_URI=mongodb://127.0.0.1:27017/DBleaks

echo [*] Configurando colecciones e indices en MongoDB...

Mongosh\mongosh.exe "%MONGO_URI%" --eval "db.createCollection('leaks')" --quiet 2>nul
Mongosh\mongosh.exe "%MONGO_URI%" --eval "db.createCollection('phone_numbers')" --quiet 2>nul
Mongosh\mongosh.exe "%MONGO_URI%" --eval "db.createCollection('miscfiles')" --quiet 2>nul

Mongosh\mongosh.exe "%MONGO_URI%" --eval "db.credentials.createIndex({\"l\":\"hashed\"})" --quiet 2>nul
Mongosh\mongosh.exe "%MONGO_URI%" --eval "db.credentials.createIndex({\"url\":\"hashed\"})" --quiet 2>nul
Mongosh\mongosh.exe "%MONGO_URI%" --eval "db.credentials.createIndex({\"leakname\":1, \"date\":1})" --quiet 2>nul
Mongosh\mongosh.exe "%MONGO_URI%" --eval "db.phone_numbers.createIndex({\"l\":\"hashed\"})" --quiet 2>nul
Mongosh\mongosh.exe "%MONGO_URI%" --eval "db.phone_numbers.createIndex({\"phone\":1})" --quiet 2>nul
Mongosh\mongosh.exe "%MONGO_URI%" --eval "db.miscfiles.createIndex({\"l\":\"hashed\"})" --quiet 2>nul
Mongosh\mongosh.exe "%MONGO_URI%" --eval "db.miscfiles.createIndex({\"donnee\":1})" --quiet 2>nul

echo %tab%[+] Indices y colecciones configurados.
echo.

:skip_mongo

:: -----------------------------------------------------------
:: 7. Create initial admin user
:: -----------------------------------------------------------
echo [*] Creando usuario administrador...
python init.py
if %errorlevel% neq 0 (
    echo %tab%[-] AVISO: No se pudo crear el usuario admin ^(puede que ya exista o MongoDB no esta activo^).
) else (
    echo %tab%[+] Usuario administrador creado.
)
echo.

:: -----------------------------------------------------------
:: 8. Create uploads directory
:: -----------------------------------------------------------
if not exist "uploads" (
    mkdir uploads
    echo %tab%[+] Carpeta 'uploads' creada.
)
if not exist "scraped_data" (
    mkdir scraped_data
    echo %tab%[+] Carpeta 'scraped_data' creada.
)
echo.

:: -----------------------------------------------------------
:: Done
:: -----------------------------------------------------------
echo ============================================
echo   Instalacion completada!
echo ============================================
echo.
echo Para iniciar Leaky:
echo   1. Asegurate de que MongoDB esta corriendo
echo   2. Activa el entorno virtual:  .\venv\Scripts\activate.bat
echo   3. Ejecuta:  python scraper.py
echo   4. Abre:  http://127.0.0.1:9999
echo   5. Login:  leaky123  (cambia la contrasena en init.py)
echo.
pause
