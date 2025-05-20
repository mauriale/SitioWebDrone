@echo off
REM Script para iniciar el servidor SitioWebDrone en Windows sin depender de un entorno virtual

REM Colores para CMD de Windows
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RED=[91m"
set "NC=[0m"

REM Verificar que Python está instalado
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo %RED%Error: Python no está instalado o no está en el PATH%NC%
    echo Asegúrate de tener Python instalado y configurado correctamente.
    pause
    exit /b 1
)

REM Verificar que Flask está instalado
python -c "import flask" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo %YELLOW%Flask no está instalado. Intentando instalar...%NC%
    pip install flask flask-cors requests python-dotenv werkzeug
    if %ERRORLEVEL% NEQ 0 (
        echo %RED%Error: No se pudo instalar Flask.%NC%
        echo Intenta ejecutar 'pip install flask flask-cors requests python-dotenv werkzeug' manualmente.
        pause
        exit /b 1
    )
    echo %GREEN%✓ Flask instalado correctamente.%NC%
)

REM Crear los directorios necesarios si no existen
if not exist "logs" mkdir logs
if not exist "data" mkdir data
if not exist "database" mkdir database
if not exist "img" mkdir img

REM Verificar si existe el archivo start_server.py
if not exist "start_server.py" (
    echo %YELLOW%Creando archivo start_server.py básico...%NC%
    (
        echo import os
        echo import sys
        echo import json
        echo import argparse
        echo from flask import Flask, send_from_directory
        echo.
        echo app = Flask^(__name__, static_folder='.'^)
        echo.
        echo @app.route^('/'^)
        echo @app.route^('/<path:path>'^)
        echo def serve_static^(path='index.html'^):
        echo     return send_from_directory^('.', path^)
        echo.
        echo if __name__ == '__main__':
        echo     parser = argparse.ArgumentParser^(^)
        echo     parser.add_argument^('-d', '--debug', action='store_true', help='Enable debug mode'^)
        echo     parser.add_argument^('-c', '--config', default='config/db_config.json', help='Path to config file'^)
        echo     args = parser.parse_args^(^)
        echo.
        echo     try:
        echo         with open^(args.config, 'r'^) as f:
        echo             config = json.load^(f^)
        echo     except:
        echo         config = {"web": {"port": 5001, "debug": False}}
        echo.
        echo     port = config.get^('web', {}).get^('port', 5001^)
        echo     debug = args.debug or config.get^('web', {}).get^('debug', False^)
        echo     app.run^(host='0.0.0.0', port=port, debug=debug^)
    ) > start_server.py
    echo %GREEN%✓ Archivo start_server.py creado.%NC%
)

REM Iniciar el servidor
echo %BLUE%Iniciando SitioWebDrone...%NC%
echo %BLUE%=============================================%NC%
echo %YELLOW%Web:%NC% http://localhost:5001
echo %BLUE%=============================================%NC%
echo Presiona Ctrl+C para detener el servidor
echo.

REM Pasar argumentos al script Python
python start_server.py %*

if %ERRORLEVEL% NEQ 0 (
    echo %RED%Error: No se pudo iniciar el servidor.%NC%
    echo Verifica que todas las dependencias estén instaladas y que no hay otro servicio usando el puerto 5001.
    pause
    exit /b 1
)