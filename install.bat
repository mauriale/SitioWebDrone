@echo off
setlocal EnableDelayedExpansion

REM Colores para CMD de Windows
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

echo %BLUE%=============================================%NC%
echo %BLUE%      INSTALADOR DE SITIOWEBDRONE            %NC%
echo %BLUE%=============================================%NC%
echo.
echo Este script instalará todas las dependencias necesarias
echo para ejecutar el sistema SitioWebDrone localmente.
echo.

REM Verificar que Python está instalado
echo %YELLOW%Verificando instalación de Python...%NC%
python --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo %RED%✗ Python no está instalado.%NC%
    echo Por favor, instala Python 3.7 o superior e intenta nuevamente.
    echo Puedes descargarlo desde: https://www.python.org/downloads/
    goto :end
) else (
    for /f "tokens=2" %%I in ('python --version 2^>^&1') do set PYTHON_VERSION=%%I
    echo %GREEN%✓ Python %PYTHON_VERSION% encontrado.%NC%
    set PYTHON_CMD=python
)

REM Verificar versión de Python
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set PYTHON_MAJOR=%%a
    set PYTHON_MINOR=%%b
)

if %PYTHON_MAJOR% LSS 3 (
    echo %RED%✗ Se requiere Python 3.7 o superior. Versión actual: %PYTHON_VERSION%%NC%
    echo Por favor, instala una versión compatible de Python e intenta nuevamente.
    goto :end
)

if %PYTHON_MAJOR% EQU 3 (
    if %PYTHON_MINOR% LSS 7 (
        echo %RED%✗ Se requiere Python 3.7 o superior. Versión actual: %PYTHON_VERSION%%NC%
        echo Por favor, instala una versión compatible de Python e intenta nuevamente.
        goto :end
    )
)

REM Verificar que pip está instalado
echo %YELLOW%Verificando instalación de pip...%NC%
pip --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo %RED%✗ pip no está instalado.%NC%
    echo Por favor, instala pip manualmente e intenta nuevamente.
    goto :end
) else (
    echo %GREEN%✓ pip encontrado.%NC%
    set PIP_CMD=pip
)

REM Preguntar si se desea crear un entorno virtual
echo.
echo %YELLOW%¿Deseas crear un entorno virtual para la instalación? (recomendado)%NC%
echo Esto mantiene las dependencias aisladas del sistema. [S/n]
set /p create_venv=

if /i "%create_venv%" == "n" (
    echo %BLUE%Continuando sin entorno virtual...%NC%
    set USE_VENV=false
) else (
    echo %YELLOW%Verificando herramientas para entornos virtuales...%NC%
    
    REM Intentar usar venv
    %PYTHON_CMD% -m venv --help > nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo %GREEN%✓ Módulo venv disponible.%NC%
        set VENV_MODULE=venv
    ) else (
        REM Intentar usar virtualenv
        %PIP_CMD% show virtualenv > nul 2>&1
        if %ERRORLEVEL% EQU 0 (
            echo %GREEN%✓ Módulo virtualenv disponible.%NC%
            set VENV_MODULE=virtualenv
        ) else (
            echo %YELLOW%! Módulos venv/virtualenv no encontrados. Intentando instalar...%NC%
            %PIP_CMD% install virtualenv
            
            if %ERRORLEVEL% NEQ 0 (
                echo %RED%✗ No se pudo instalar virtualenv.%NC%
                echo Continuando sin entorno virtual.
                set USE_VENV=false
            ) else (
                echo %GREEN%✓ virtualenv instalado correctamente.%NC%
                set VENV_MODULE=virtualenv
            )
        )
    )
    
    if defined VENV_MODULE (
        set USE_VENV=true
        REM Crear entorno virtual
        echo %YELLOW%Creando entorno virtual...%NC%
        
        if "%VENV_MODULE%" == "venv" (
            %PYTHON_CMD% -m venv venv
        ) else (
            %PYTHON_CMD% -m virtualenv venv
        )
        
        if %ERRORLEVEL% NEQ 0 (
            echo %RED%✗ Error al crear el entorno virtual.%NC%
            echo Continuando sin entorno virtual.
            set USE_VENV=false
        ) else (
            echo %GREEN%✓ Entorno virtual creado correctamente.%NC%
            
            REM Activar entorno virtual
            echo %YELLOW%Activando entorno virtual...%NC%
            call venv\Scripts\activate.bat
            
            if %ERRORLEVEL% NEQ 0 (
                echo %RED%✗ Error al activar el entorno virtual.%NC%
                echo Continuando sin entorno virtual.
                set USE_VENV=false
            ) else (
                echo %GREEN%✓ Entorno virtual activado.%NC%
                REM Actualizar comandos para el entorno virtual
                set PYTHON_CMD=python
                set PIP_CMD=pip
            )
        )
    )
)

REM Instalar dependencias
echo.
echo %YELLOW%Instalando dependencias desde requirements.txt...%NC%

if exist "requirements.txt" (
    %PIP_CMD% install -r requirements.txt
    
    if %ERRORLEVEL% NEQ 0 (
        echo %RED%✗ Error al instalar dependencias.%NC%
        echo Por favor, verifica el archivo requirements.txt y tu conexión a internet.
        goto :end
    ) else (
        echo %GREEN%✓ Dependencias instaladas correctamente.%NC%
    )
) else (
    echo %RED%✗ No se encontró el archivo requirements.txt%NC%
    echo Creando un archivo requirements.txt básico...
    
    (
        echo flask==2.0.1
        echo flask-cors==3.0.10
        echo requests==2.26.0
        echo python-dotenv==0.19.1
        echo werkzeug==2.0.1
        echo gunicorn==20.1.0
    ) > requirements.txt
    
    echo %GREEN%✓ Archivo requirements.txt creado.%NC%
    
    REM Instalar las dependencias creadas
    %PIP_CMD% install -r requirements.txt
    
    if %ERRORLEVEL% NEQ 0 (
        echo %RED%✗ Error al instalar dependencias.%NC%
        goto :end
    ) else (
        echo %GREEN%✓ Dependencias básicas instaladas correctamente.%NC%
    )
)

REM Crear directorios necesarios
echo.
echo %YELLOW%Creando directorios necesarios...%NC%

if not exist "logs" mkdir logs
if not exist "data" mkdir data
if not exist "config" mkdir config

echo %GREEN%✓ Directorios creados correctamente.%NC%

REM Crear archivo de configuración si no existe
if not exist "config\db_config.json" (
    echo %YELLOW%Creando archivo de configuración predeterminado...%NC%
    
    (
        echo {
        echo     "database": {
        echo         "path": "database/dronevista.db",
        echo         "backup_path": "data/backup"
        echo     },
        echo     "api": {
        echo         "port": 5000,
        echo         "debug": false,
        echo         "cors_origins": ["http://localhost:5001", "http://127.0.0.1:5001"]
        echo     },
        echo     "web": {
        echo         "port": 5001,
        echo         "debug": false
        echo     },
        echo     "maps": {
        echo         "api_key": "YOUR_GOOGLE_MAPS_API_KEY",
        echo         "proxy_enabled": true
        echo     }
        echo }
    ) > config\db_config.json
    
    echo %GREEN%✓ Archivo de configuración creado.%NC%
) else (
    echo %GREEN%✓ Archivo de configuración existente.%NC%
)

REM Inicializar la base de datos
echo.
echo %YELLOW%Verificando base de datos...%NC%

if not exist "database" mkdir database

REM Comprobar si existe el archivo dronevista.db
if not exist "database\dronevista.db" (
    echo %YELLOW%Base de datos no encontrada. Inicializando...%NC%
    
    REM Verificar si existe el script create_db.py
    if exist "database\create_db.py" (
        %PYTHON_CMD% database\create_db.py
        
        if %ERRORLEVEL% NEQ 0 (
            echo %RED%✗ Error al inicializar la base de datos.%NC%
        ) else (
            echo %GREEN%✓ Base de datos inicializada correctamente.%NC%
        )
    ) else (
        echo %RED%✗ No se encontró el script de creación de la base de datos.%NC%
        echo Será necesario crear la base de datos manualmente.
    )
) else (
    echo %GREEN%✓ Base de datos existente encontrada.%NC%
)

REM Mensaje final
echo.
echo %BLUE%=============================================%NC%
echo %GREEN%¡Instalación completada con éxito!%NC%
echo %BLUE%=============================================%NC%
echo.
echo Para iniciar el servidor, ejecuta:
echo %YELLOW%run.bat%NC%
echo.
echo Si quieres activar el modo debug:
echo %YELLOW%run.bat --debug%NC%
echo.

if "%USE_VENV%" == "true" (
    echo Se ha creado un entorno virtual en la carpeta 'venv'.
    echo Para activarlo manualmente en el futuro, ejecuta:
    echo %YELLOW%venv\Scripts\activate.bat%NC%
    echo.
)

echo ¡Gracias por instalar SitioWebDrone!
pause

:end
endlocal