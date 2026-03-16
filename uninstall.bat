@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   Leaky - Windows Uninstaller
echo ============================================
echo.
echo ESTA ACCION BORRARA EL ENTORNO VIRTUAL Y LA BASE DE DATOS (DBleaks).
echo.
set /p CONFIRM="Estas seguro de querer continuar? Escribe 'SI' para confirmar: "
if /i "!CONFIRM!" neq "SI" (
    echo [!] Desinstalacion cancelada.
    pause
    exit /b 0
)
echo.

:: -----------------------------------------------------------
:: 1. Eliminate Virtual Environment (venv)
:: -----------------------------------------------------------
echo [*] Borrando el entorno virtual (venv)...
if exist "venv" (
    rmdir /s /q venv
    if exist "venv" (
        echo [-] AVISO: No se pudo borrar 'venv' completamente. Puede que este en uso.
    ) else (
        echo [+] Entorno virtual 'venv' eliminado.
    )
) else (
    echo [+] No se encontro la carpeta 'venv'.
)
echo.

:: -----------------------------------------------------------
:: 2. Drop MongoDB Database (DBleaks)
:: -----------------------------------------------------------
echo [*] Borrando la base de datos MongoDB (DBleaks)...

:: Comprobar si MongoDB y mongosh están disponibles
Mongosh\mongosh.exe --eval "db.adminCommand('ping')" --quiet >nul 2>&1
if %errorlevel% neq 0 (
    echo [-] AVISO: MongoDB no parece estar ejecutandose o Mongosh\mongosh.exe no se encontro.
    echo [-] No se ha podido eliminar la base de datos 'DBleaks' automaticamente.
) else (
    set MONGO_URI=mongodb://127.0.0.1:27017/DBleaks
    Mongosh\mongosh.exe "!MONGO_URI!" --eval "db.dropDatabase()" --quiet >nul 2>&1
    if !errorlevel! equ 0 (
        echo [+] Base de datos 'DBleaks' eliminada en MongoDB.
    ) else (
        echo [-] AVISO: Hubo un problema al intentar borrar 'DBleaks'.
    )
)
echo.

:: -----------------------------------------------------------
:: 3. Optional cleanup of uploads
:: -----------------------------------------------------------
set /p CLEAN_UPLOADS="Quieres borrar las carpetas de subidas ('uploads' y 'scraped_data')? (s/n): "
if /i "!CLEAN_UPLOADS!" equ "s" (
    echo [*] Borrando carpetas de datos...
    
    if exist "uploads" (
        rmdir /s /q uploads
        echo [+] Carpeta 'uploads' eliminada.
    )
    
    if exist "scraped_data" (
        rmdir /s /q scraped_data
        echo [+] Carpeta 'scraped_data' eliminada.
    )
    echo.
)

echo ============================================
echo   Desinstalacion completada.
echo ============================================
echo.
pause
