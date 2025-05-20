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
echo Este script instalara todas las dependencias necesarias
echo para ejecutar el sistema SitioWebDrone localmente.
echo.

REM Verificar que Python está instalado
echo %YELLOW%Verificando instalacion de Python...%NC%
python --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo %RED%X Python no esta instalado.%NC%
    echo Por favor, instala Python 3.7 o superior e intenta nuevamente.
    echo Puedes descargarlo desde: https://www.python.org/downloads/
    goto :end
) else (
    for /f "tokens=2" %%I in ('python --version 2^>^&1') do set "PYTHON_VERSION=%%I"
    echo %GREEN%+ Python %PYTHON_VERSION% encontrado.%NC%
    set "PYTHON_CMD=python"
)

REM Verificar que pip está instalado
echo %YELLOW%Verificando instalacion de pip...%NC%
pip --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo %RED%X pip no esta instalado.%NC%
    echo Por favor, asegurate de que pip este instalado.
    goto :end
) else (
    echo %GREEN%+ pip encontrado.%NC%
    set "PIP_CMD=pip"
)

REM Crear directorios necesarios primero
echo.
echo %YELLOW%Creando directorios necesarios...%NC%

if not exist "logs" mkdir logs
if not exist "data" mkdir data
if not exist "config" mkdir config
if not exist "database" mkdir database
if not exist "img" mkdir img
if not exist "api" mkdir api
echo %GREEN%+ Directorios creados correctamente.%NC%

REM Crear archivo de requirements.txt corregido
echo.
echo %YELLOW%Creando requirements.txt actualizado...%NC%

(
echo flask==2.0.1
echo flask-cors==3.0.10
echo requests==2.26.0
echo python-dotenv==0.19.1
echo werkzeug==2.0.1
) > requirements.txt

echo %GREEN%+ Archivo requirements.txt actualizado.%NC%

REM Instalar dependencias sin entorno virtual
echo.
echo %YELLOW%Instalando dependencias...%NC%
%PYTHON_CMD% -m pip install -r requirements.txt --no-warn-conflicts

if %ERRORLEVEL% NEQ 0 (
    echo %RED%X Error al instalar dependencias.%NC%
    echo Intentando instalar directamente...
    %PYTHON_CMD% -m pip install flask==2.0.1 flask-cors==3.0.10 requests==2.26.0 python-dotenv==0.19.1 werkzeug==2.0.1
    if %ERRORLEVEL% NEQ 0 (
        echo %RED%X No se pudieron instalar las dependencias.%NC%
        goto :end
    ) else (
        echo %GREEN%+ Dependencias instaladas directamente.%NC%
    )
) else (
    echo %GREEN%+ Dependencias instaladas correctamente.%NC%
)

REM Crear archivo de configuración si no existe
if not exist "config\db_config.json" (
    echo %YELLOW%Creando archivo de configuracion predeterminado...%NC%
    
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
    
    echo %GREEN%+ Archivo de configuracion creado.%NC%
) else (
    echo %GREEN%+ Archivo de configuracion existente.%NC%
)

REM Crear una base de datos simple si no existe
if not exist "database\dronevista.db" (
    echo %YELLOW%Creando una base de datos simple...%NC%
    
    echo. > database\dronevista.db
    echo %GREEN%+ Base de datos creada.%NC%
    
    echo %YELLOW%Nota: Esta es una base de datos vacia. Se poblara cuando inicies el servidor.%NC%
)

REM Descargar archivos esenciales del servidor
echo.
echo %YELLOW%Verificando archivos esenciales...%NC%

if not exist "api\booking_api.py" (
    echo %YELLOW%Creando booking_api.py basico...%NC%
    (
        echo # -*- coding: utf-8 -*-
        echo.
        echo import os
        echo import json
        echo import datetime
        echo import uuid
        echo import sqlite3
        echo import logging
        echo from flask import Flask, request, jsonify
        echo from flask_cors import CORS
        echo.
        echo # Intentar importar maps_proxy
        echo try:
        echo     from maps_proxy import maps_api
        echo except ImportError:
        echo     try:
        echo         # Intenta importar como ruta relativa
        echo         from .maps_proxy import maps_api
        echo     except ImportError:
        echo         # Crea un objeto simulado si no se puede importar
        echo         maps_api = type^('obj', ^(object,^), {
        echo             'proxy_route': lambda: {'message': 'Maps API no disponible'}
        echo         }^)
        echo         print^("ADVERTENCIA: No se pudo importar maps_proxy. Algunas funciones pueden no estar disponibles."^)
        echo.
        echo # Configuracion de logging
        echo logging.basicConfig^(
        echo     level=logging.INFO,
        echo     format='%^(asctime^)s - %^(name^)s - %^(levelname^)s - %^(message^)s'
        echo ^)
        echo logger = logging.getLogger^('Booking API'^)
        echo.
        echo # Inicializar la aplicacion Flask
        echo app = Flask^(__name__^)
        echo CORS^(app^)  # Permitir CORS para todas las rutas
        echo.
        echo # Directorio donde esta la base de datos
        echo DB_PATH = "database/dronevista.db"
        echo.
        echo # Verificar si la base de datos existe
        echo if not os.path.exists^(DB_PATH^):
        echo     logger.warning^(f"Base de datos no encontrada en {DB_PATH}. Creando una basica."^)
        echo     conn = sqlite3.connect^(DB_PATH^)
        echo     c = conn.cursor^(^)
        echo     
        echo     # Crear tablas basicas si la BD no existe
        echo     c.execute^('''
        echo     CREATE TABLE IF NOT EXISTS services ^(
        echo         id TEXT PRIMARY KEY,
        echo         name TEXT NOT NULL,
        echo         description TEXT,
        echo         icon TEXT,
        echo         price_per_hour REAL,
        echo         min_duration INTEGER,
        echo         max_duration INTEGER
        echo     ^)
        echo     '''^^)
        echo     
        echo     # Insertar datos demo
        echo     services = [
        echo         ^('montaña', 'Filmacion en Montaña', 'Tomas espectaculares de paisajes montañosos, senderos y actividades al aire libre.', '🏔️', 120, 2, 8^),
        echo         ^('playa', 'Filmacion en Playa', 'Imagenes aereas impresionantes de costas, olas y eventos playeros.', '🏖️', 100, 1, 6^),
        echo         ^('produccion', 'Produccion Audiovisual', 'Servicios completos de filmacion, edicion y posproduccion para crear contenido de alta calidad.', '🎬', 150, 3, 10^),
        echo         ^('corporativo', 'Servicios Corporativos', 'Filmacion para empresas, publicidad, eventos y proyectos especiales.', '🏢', 180, 4, 12^),
        echo         ^('telemetria', 'Telemetria y Modelado 3D', 'Digitalizacion de espacios y creacion de modelos 3D de alta precision.', '📊', 200, 3, 8^)
        echo     ]
        echo     
        echo     c.executemany^('INSERT OR REPLACE INTO services VALUES ^(?, ?, ?, ?, ?, ?, ?^)', services^)
        echo     conn.commit^(^)
        echo     conn.close^(^)
        echo     
        echo     logger.info^("Base de datos creada con servicios demostrativos."^)
        echo.
        echo # Funcion para conectar a la base de datos
        echo def get_db_connection^(^):
        echo     try:
        echo         conn = sqlite3.connect^(DB_PATH^)
        echo         conn.row_factory = sqlite3.Row
        echo         return conn
        echo     except sqlite3.Error as e:
        echo         logger.error^(f"Error al conectar con la base de datos: {e}"^)
        echo         return None
        echo.
        echo # Ruta de prueba para verificar que la API esta funcionando
        echo @app.route^('/api/test', methods=['GET']^)
        echo def test_api^(^):
        echo     return jsonify^({'success': True, 'message': 'API funcionando correctamente'}^)
        echo.
        echo # Ruta para obtener todos los servicios
        echo @app.route^('/api/services', methods=['GET']^)
        echo def get_services^(^):
        echo     conn = get_db_connection^(^)
        echo     if not conn:
        echo         return jsonify^({'success': False, 'error': 'Error de conexion a la base de datos'}^), 500
        echo     
        echo     try:
        echo         cursor = conn.cursor^(^)
        echo         services = cursor.execute^('SELECT * FROM services'^).fetchall^(^)
        echo         
        echo         # Convertir los resultados a una lista de diccionarios
        echo         services_list = []
        echo         for service in services:
        echo             services_list.append^({
        echo                 'id': service['id'],
        echo                 'name': service['name'],
        echo                 'description': service['description'],
        echo                 'icon': service['icon'],
        echo                 'price_per_hour': service['price_per_hour'],
        echo                 'min_duration': service['min_duration'],
        echo                 'max_duration': service['max_duration']
        echo             }^)
        echo         
        echo         return jsonify^({'success': True, 'services': services_list}^)
        echo     except Exception as e:
        echo         logger.error^(f"Error al obtener servicios: {e}"^)
        echo         return jsonify^({'success': False, 'error': str^(e^)}^), 500
        echo     finally:
        echo         conn.close^(^)
        echo.
        echo # Si se ejecuta este archivo directamente
        echo if __name__ == '__main__':
        echo     port = int^(os.environ.get^('PORT', 5000^)^)
        echo     app.run^(host='0.0.0.0', port=port, debug=True^)
    ) > api\booking_api.py
    echo %GREEN%+ Archivo booking_api.py creado.%NC%
)

if not exist "api\maps_proxy.py" (
    echo %YELLOW%Creando maps_proxy.py basico...%NC%
    (
        echo # -*- coding: utf-8 -*-
        echo.
        echo from flask import Blueprint, request, jsonify
        echo.
        echo # Crear un Blueprint para la API de mapas
        echo maps_api = Blueprint^('maps_api', __name__^)
        echo.
        echo # Ruta para verificar si la API esta configurada
        echo @maps_api.route^('/api/maps/status', methods=['GET']^)
        echo def maps_status^(^):
        echo     return jsonify^({
        echo         'configured': False,
        echo         'message': 'API de mapas en modo simulado'
        echo     }^)
    ) > api\maps_proxy.py
    echo %GREEN%+ Archivo maps_proxy.py creado.%NC%
)

REM Mensaje final
echo.
echo %BLUE%=============================================%NC%
echo %GREEN%Instalacion basica completada%NC%
echo %BLUE%=============================================%NC%
echo.
echo Para iniciar el servidor, ejecuta:
echo %YELLOW%run.bat%NC%
echo.
echo Si quieres activar el modo debug:
echo %YELLOW%run.bat --debug%NC%
echo.
echo %BLUE%Gracias por instalar SitioWebDrone!%NC%
pause

:end
endlocal