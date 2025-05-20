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
        echo app = Flask^(__name__^)
        echo CORS^(app^)  # Permitir CORS para todas las rutas
        echo.
        echo # Rutas para servir archivos estáticos
        echo @app.route^('/', defaults={'path': 'index.html'}^)
        echo @app.route^('/<path:path>'^)
        echo def serve_static^(path^):
        echo     try:
        echo         return send_from_directory^('.', path^)
        echo     except Exception as e:
        echo         logger.error^(f"Error al servir {path}: {e}"^)
        echo         # Si hay un error sirviendo el archivo solicitado, intentamos servir index.html
        echo         if path != 'index.html':
        echo             return send_from_directory^('.', 'index.html'^)
        echo         else:
        echo             return jsonify^({'error': 'No se pudo cargar la página principal'}^), 500
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
        echo     debug = os.environ.get^('DEBUG', 'false'^).lower^(^) == 'true'
        echo     app.run^(host='0.0.0.0', port=port, debug=debug^)
    ) > app.py
    echo %GREEN%+ Archivo app.py creado.%NC%
)

REM Crear HTML mínimo si no existe
if not exist "index.html" (
    echo %YELLOW%Creando index.html basico...%NC%
    (
        echo ^<!DOCTYPE html^>
        echo ^<html lang="es"^>
        echo ^<head^>
        echo     ^<meta charset="UTF-8"^>
        echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
        echo     ^<title^>DroneVista - Servicios de Drone^</title^>
        echo     ^<style^>
        echo         body {
        echo             font-family: Arial, sans-serif;
        echo             margin: 0;
        echo             padding: 0;
        echo             background-color: #111;
        echo             color: white;
        echo         }
        echo         .container {
        echo             max-width: 1200px;
        echo             margin: 0 auto;
        echo             padding: 20px;
        echo         }
        echo         header {
        echo             display: flex;
        echo             justify-content: space-between;
        echo             align-items: center;
        echo             padding: 20px 0;
        echo             border-bottom: 1px solid #333;
        echo         }
        echo         .logo {
        echo             font-size: 24px;
        echo             font-weight: bold;
        echo         }
        echo         nav ul {
        echo             display: flex;
        echo             list-style: none;
        echo             gap: 20px;
        echo         }
        echo         nav a {
        echo             color: white;
        echo             text-decoration: none;
        echo         }
        echo         .hero {
        echo             text-align: center;
        echo             padding: 60px 0;
        echo         }
        echo         .hero h1 {
        echo             font-size: 48px;
        echo             margin-bottom: 20px;
        echo         }
        echo         .hero p {
        echo             font-size: 18px;
        echo             margin-bottom: 30px;
        echo         }
        echo         .button {
        echo             display: inline-block;
        echo             background-color: #FF6B00;
        echo             color: white;
        echo             padding: 12px 30px;
        echo             border-radius: 30px;
        echo             text-decoration: none;
        echo             font-weight: bold;
        echo             transition: background-color 0.3s;
        echo         }
        echo         .button:hover {
        echo             background-color: #FF8F3F;
        echo         }
        echo         .services {
        echo             display: grid;
        echo             grid-template-columns: repeat^(auto-fit, minmax^(300px, 1fr^)^);
        echo             gap: 20px;
        echo             margin-top: 40px;
        echo         }
        echo         .service {
        echo             background-color: #222;
        echo             border-radius: 10px;
        echo             padding: 20px;
        echo             text-align: center;
        echo         }
        echo         .service-icon {
        echo             font-size: 48px;
        echo             margin-bottom: 15px;
        echo         }
        echo         footer {
        echo             margin-top: 60px;
        echo             text-align: center;
        echo             padding: 20px 0;
        echo             border-top: 1px solid #333;
        echo         }
        echo     ^</style^>
        echo ^</head^>
        echo ^<body^>
        echo     ^<div class="container"^>
        echo         ^<header^>
        echo             ^<div class="logo"^>DroneVista^</div^>
        echo             ^<nav^>
        echo                 ^<ul^>
        echo                     ^<li^>^<a href="#"^>Servicios^</a^>^</li^>
        echo                     ^<li^>^<a href="#"^>Reservas^</a^>^</li^>
        echo                     ^<li^>^<a href="#"^>Contacto^</a^>^</li^>
        echo                 ^</ul^>
        echo             ^</nav^>
        echo         ^</header^>
        echo 
        echo         ^<section class="hero"^>
        echo             ^<h1^>Servicios Profesionales de Drone^</h1^>
        echo             ^<p^>Capturando perspectivas únicas desde el cielo^</p^>
        echo             ^<a href="#" class="button"^>Reservar Ahora^</a^>
        echo         ^</section^>
        echo 
        echo         ^<h2^>Nuestros Servicios^</h2^>
        echo         ^<div class="services" id="services-container"^>
        echo             ^<!-- Los servicios se cargarán dinámicamente desde la API --^>
        echo             ^<div class="service"^>
        echo                 ^<div class="service-icon"^>🏔️^</div^>
        echo                 ^<h3^>Filmación en Montaña^</h3^>
        echo                 ^<p^>Tomas espectaculares de paisajes montañosos y actividades al aire libre.^</p^>
        echo                 ^<p class="price"^>Desde €120/hora^</p^>
        echo             ^</div^>
        echo             ^<div class="service"^>
        echo                 ^<div class="service-icon"^>🏖️^</div^>
        echo                 ^<h3^>Filmación en Playa^</h3^>
        echo                 ^<p^>Imágenes aéreas impresionantes de costas, olas y eventos playeros.^</p^>
        echo                 ^<p class="price"^>Desde €100/hora^</p^>
        echo             ^</div^>
        echo         ^</div^>
        echo 
        echo         ^<footer^>
        echo             ^<p^>© 2025 DroneVista. Todos los derechos reservados.^</p^>
        echo         ^</footer^>
        echo     ^</div^>
        echo 
        echo     ^<script^>
        echo         // Función para cargar servicios desde la API
        echo         async function loadServices^(^) {
        echo             try {
        echo                 const response = await fetch^('/api/services'^);
        echo                 const data = await response.json^(^);
        echo                 
        echo                 if ^(data.success^) {
        echo                     const servicesContainer = document.getElementById^('services-container'^);
        echo                     servicesContainer.innerHTML = '';
        echo                     
        echo                     data.services.forEach^(service => {
        echo                         const serviceElement = document.createElement^('div'^);
        echo                         serviceElement.className = 'service';
        echo                         
        echo                         serviceElement.innerHTML = `
        echo                             <div class="service-icon">${service.icon}</div>
        echo                             <h3>${service.name}</h3>
        echo                             <p>${service.description}</p>
        echo                             <p class="price">Desde €${service.price_per_hour}/hora</p>
        echo                         `;
        echo                         
        echo                         servicesContainer.appendChild^(serviceElement^);
        echo                     }^);
        echo                 } else {
        echo                     console.error^('Error al cargar servicios:', data.error^);
        echo                 }
        echo             } catch ^(error^) {
        echo                 console.error^('Error al conectar con la API:', error^);
        echo             }
        echo         }
        echo         
        echo         // Cargar servicios al cargar la página
        echo         document.addEventListener^('DOMContentLoaded', loadServices^);
        echo     ^</script^>
        echo ^</body^>
        echo ^</html^>
    ) > index.html
    echo %GREEN%+ Archivo index.html creado.%NC%
)

REM Iniciar servidor Flask
echo %BLUE%Iniciando SitioWebDrone...%NC%
echo %BLUE%=============================================%NC%
echo %YELLOW%URL:%NC% http://localhost:5000
echo %YELLOW%URL IP local:%NC% http://192.168.1.14:5000
echo %BLUE%=============================================%NC%
echo Presiona Ctrl+C para detener el servidor
echo.

REM Configurar variables de entorno para Flask
set PORT=5000
set DEBUG=true

REM Iniciar la aplicación Flask
python app.py
