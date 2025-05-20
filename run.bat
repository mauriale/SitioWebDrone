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
    echo %RED%Error: Python no esta instalado o no esta en el PATH%NC%
    echo Asegurate de tener Python instalado y configurado correctamente.
    pause
    exit /b 1
)

REM Verificar que Flask está instalado
python -c "import flask" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo %YELLOW%Flask no esta instalado. Intentando instalar...%NC%
    pip install flask flask-cors requests python-dotenv werkzeug
    if %ERRORLEVEL% NEQ 0 (
        echo %RED%Error: No se pudo instalar Flask.%NC%
        echo Intenta ejecutar 'pip install flask flask-cors requests python-dotenv werkzeug' manualmente.
        pause
        exit /b 1
    )
    echo %GREEN%+ Flask instalado correctamente.%NC%
)

REM Crear los directorios necesarios si no existen
if not exist "logs" mkdir logs
if not exist "data" mkdir data
if not exist "database" mkdir database
if not exist "img" mkdir img
if not exist "api" mkdir api

REM Crear archivo app.py en el directorio raíz si no existe
if not exist "app.py" (
    echo %YELLOW%Creando app.py basico...%NC%
    (
        echo # -*- coding: utf-8 -*-
        echo.
        echo import os
        echo import json
        echo import datetime
        echo import uuid
        echo import sqlite3
        echo import logging
        echo from flask import Flask, request, jsonify, send_from_directory
        echo from flask_cors import CORS
        echo.
        echo # Configuracion de logging
        echo logging.basicConfig^(
        echo     level=logging.INFO,
        echo     format='%^(asctime^)s - %^(name^)s - %^(levelname^)s - %^(message^)s'
        echo ^)
        echo logger = logging.getLogger^('SitioWebDrone'^)
        echo.
        echo # Inicializar la aplicacion Flask
        echo app = Flask^(__name__, static_folder='.'^)
        echo CORS^(app^)  # Permitir CORS para todas las rutas
        echo.
        echo # Rutas para servir archivos estáticos
        echo @app.route^('/'^)
        echo @app.route^('/<path:path>'^)
        echo def serve_static^(path='index.html'^):
        echo     return send_from_directory^('.', path^)
        echo.
        echo # Ruta de prueba para verificar que la API está funcionando
        echo @app.route^('/api/test', methods=['GET']^)
        echo def test_api^(^):
        echo     return jsonify^({'success': True, 'message': 'API funcionando correctamente'}^)
        echo.
        echo # Ruta para obtener todos los servicios
        echo @app.route^('/api/services', methods=['GET']^)
        echo def get_services^(^):
        echo     # Servicios de demostración (en una implementación real, estos vendrían de una base de datos)
        echo     services = [
        echo         {
        echo             'id': 'montaña',
        echo             'name': 'Filmacion en Montaña',
        echo             'description': 'Tomas espectaculares de paisajes montañosos, senderos y actividades al aire libre.',
        echo             'icon': '🏔️',
        echo             'price_per_hour': 120,
        echo             'min_duration': 2,
        echo             'max_duration': 8
        echo         },
        echo         {
        echo             'id': 'playa',
        echo             'name': 'Filmacion en Playa',
        echo             'description': 'Imagenes aereas impresionantes de costas, olas y eventos playeros.',
        echo             'icon': '🏖️',
        echo             'price_per_hour': 100,
        echo             'min_duration': 1,
        echo             'max_duration': 6
        echo         },
        echo         {
        echo             'id': 'produccion',
        echo             'name': 'Produccion Audiovisual',
        echo             'description': 'Servicios completos de filmacion, edicion y posproduccion para crear contenido de alta calidad.',
        echo             'icon': '🎬',
        echo             'price_per_hour': 150,
        echo             'min_duration': 3,
        echo             'max_duration': 10
        echo         },
        echo         {
        echo             'id': 'corporativo',
        echo             'name': 'Servicios Corporativos',
        echo             'description': 'Filmacion para empresas, publicidad, eventos y proyectos especiales.',
        echo             'icon': '🏢',
        echo             'price_per_hour': 180,
        echo             'min_duration': 4,
        echo             'max_duration': 12
        echo         },
        echo         {
        echo             'id': 'telemetria',
        echo             'name': 'Telemetria y Modelado 3D',
        echo             'description': 'Digitalizacion de espacios y creacion de modelos 3D de alta precision.',
        echo             'icon': '📊',
        echo             'price_per_hour': 200,
        echo             'min_duration': 3,
        echo             'max_duration': 8
        echo         }
        echo     ]
        echo     return jsonify^({'success': True, 'services': services}^)
        echo.
        echo # Ruta para obtener los detalles de un servicio específico
        echo @app.route^('/api/services/<service_id>', methods=['GET']^)
        echo def get_service^(service_id^):
        echo     # En una implementación real, esto vendría de una base de datos
        echo     services = {
        echo         'montaña': {
        echo             'id': 'montaña',
        echo             'name': 'Filmacion en Montaña',
        echo             'description': 'Tomas espectaculares de paisajes montañosos, senderos y actividades al aire libre.',
        echo             'icon': '🏔️',
        echo             'price_per_hour': 120,
        echo             'min_duration': 2,
        echo             'max_duration': 8
        echo         },
        echo         'playa': {
        echo             'id': 'playa',
        echo             'name': 'Filmacion en Playa',
        echo             'description': 'Imagenes aereas impresionantes de costas, olas y eventos playeros.',
        echo             'icon': '🏖️',
        echo             'price_per_hour': 100,
        echo             'min_duration': 1,
        echo             'max_duration': 6
        echo         }
        echo     }
        echo     
        echo     service = services.get^(service_id^)
        echo     if service:
        echo         return jsonify^({'success': True, 'service': service}^)
        echo     else:
        echo         return jsonify^({'success': False, 'error': 'Servicio no encontrado'}^), 404
        echo.
        echo # Ruta para obtener horarios disponibles para un servicio en una fecha específica
        echo @app.route^('/api/services/<service_id>/available-times', methods=['GET']^)
        echo def get_available_times^(service_id^):
        echo     date_str = request.args.get^('date'^)
        echo     
        echo     if not date_str:
        echo         return jsonify^({'success': False, 'error': 'Fecha no especificada'}^), 400
        echo     
        echo     # Generar horarios disponibles (simulados)
        echo     available_times = [
        echo         "08:00", "09:00", "10:00", "11:00", "12:00", 
        echo         "13:00", "14:00", "15:00", "16:00", "17:00", "18:00"
        echo     ]
        echo     
        echo     # Simulamos algunos horarios no disponibles
        echo     # En una implementación real, esto se verificaría en la base de datos
        echo     if date_str.endswith^('01/'^) or date_str.endswith^('/15/'^):
        echo         available_times = available_times[::2]  # Solo cada segundo horario
        echo     
        echo     return jsonify^({
        echo         'success': True,
        echo         'service_id': service_id,
        echo         'date': date_str,
        echo         'availableTimes': available_times
        echo     }^)
        echo.
        echo # Ruta para crear una nueva reserva
        echo @app.route^('/api/bookings', methods=['POST']^)
        echo def create_booking^(^):
        echo     data = request.json
        echo     
        echo     # Validación básica de datos
        echo     required_fields = ['service_id', 'booking_date', 'start_time', 'duration', 
        echo                       'client_name', 'client_email', 'client_phone', 'location']
        echo     
        echo     for field in required_fields:
        echo         if field not in data or not data[field]:
        echo             return jsonify^({
        echo                 'success': False, 
        echo                 'error': f'Campo obligatorio faltante: {field}'
        echo             }^), 400
        echo     
        echo     # Generar ID de reserva único
        echo     booking_id = str^(uuid.uuid4^(^)^)[:8].upper^(^)
        echo     
        echo     # En una implementación real, aquí se verificaría la disponibilidad
        echo     # y se guardaría la reserva en la base de datos
        echo     
        echo     # Para este ejemplo, simplemente devolvemos el ID de reserva
        echo     return jsonify^({
        echo         'success': True,
        echo         'message': 'Reserva creada correctamente',
        echo         'booking_id': booking_id
        echo     }^)
        echo.
        echo # Si se ejecuta este archivo directamente
        echo if __name__ == '__main__':
        echo     port = int^(os.environ.get^('PORT', 5000^)^)
        echo     app.run^(host='0.0.0.0', port=port, debug=True^)
    ) > app.py
    echo %GREEN%+ Archivo app.py creado.%NC%
)

REM Iniciar servidor web simple usando Python
echo %BLUE%Iniciando SitioWebDrone...%NC%
echo %BLUE%=============================================%NC%
echo %YELLOW%URL:%NC% http://0.0.0.0:5000
echo %YELLOW%URL IP local:%NC% http://localhost:5000
echo %BLUE%=============================================%NC%
echo Presiona Ctrl+C para detener el servidor
echo.

REM Iniciar la aplicación Flask
python app.py
