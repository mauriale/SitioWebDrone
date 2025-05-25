# -*- coding: utf-8 -*-

import os
import json
import datetime
import uuid
import sqlite3
import logging
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS

# Configuracion de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('SitioWebDrone')

# Inicializar la aplicacion Flask
app = Flask(__name__)
CORS(app)  # Permitir CORS para todas las rutas

# Rutas para servir archivos estáticos
@app.route('/', defaults={'path': 'index.html'})
@app.route('/<path:path>')
def serve_static(path):
    try:
        return send_from_directory('.', path)
    except Exception as e:
        logger.error(f"Error al servir {path}: {e}")
        # Si hay un error sirviendo el archivo solicitado, intentamos servir index.html
        if path != 'index.html':
            return send_from_directory('.', 'index.html')
        else:
            return jsonify({'error': 'No se pudo cargar la página principal'}), 500

# Ruta de prueba para verificar que la API está funcionando
@app.route('/api/test', methods=['GET'])
def test_api():
    return jsonify({'success': True, 'message': 'API funcionando correctamente'})

# Ruta para obtener todos los servicios
@app.route('/api/services', methods=['GET'])
def get_services():
    # Servicios de demostración (en una implementación real, estos vendrían de una base de datos)
    services = [
        {
            'id': 'montaña',
            'name': 'Filmacion en Montaña',
            'description': 'Tomas espectaculares de paisajes montañosos, senderos y actividades al aire libre.',
            'icon': '🏔️',
            'price_per_hour': 120,
            'min_duration': 2,
            'max_duration': 8
        },
        {
            'id': 'playa',
            'name': 'Filmacion en Playa',
            'description': 'Imagenes aereas impresionantes de costas, olas y eventos playeros.',
            'icon': '🏖️',
            'price_per_hour': 100,
            'min_duration': 1,
            'max_duration': 6
        },
        {
            'id': 'produccion',
            'name': 'Produccion Audiovisual',
            'description': 'Servicios completos de filmacion, edicion y posproduccion para crear contenido de alta calidad.',
            'icon': '🎬',
            'price_per_hour': 150,
            'min_duration': 3,
            'max_duration': 10
        },
        {
            'id': 'corporativo',
            'name': 'Servicios Corporativos',
            'description': 'Filmacion para empresas, publicidad, eventos y proyectos especiales.',
            'icon': '🏢',
            'price_per_hour': 180,
            'min_duration': 4,
            'max_duration': 12
        },
        {
            'id': 'telemetria',
            'name': 'Telemetria y Modelado 3D',
            'description': 'Digitalizacion de espacios y creacion de modelos 3D de alta precision.',
            'icon': '📊',
            'price_per_hour': 200,
            'min_duration': 3,
            'max_duration': 8
        }
    ]
    return jsonify({'success': True, 'services': services})

# Ruta para obtener los detalles de un servicio específico
@app.route('/api/services/<service_id>', methods=['GET'])
def get_service(service_id):
    # En una implementación real, esto vendría de una base de datos
    services = {
        'montaña': {
            'id': 'montaña',
            'name': 'Filmacion en Montaña',
            'description': 'Tomas espectaculares de paisajes montañosos, senderos y actividades al aire libre.',
            'icon': '🏔️',
            'price_per_hour': 120,
            'min_duration': 2,
            'max_duration': 8
        },
        'playa': {
            'id': 'playa',
            'name': 'Filmacion en Playa',
            'description': 'Imagenes aereas impresionantes de costas, olas y eventos playeros.',
            'icon': '🏖️',
            'price_per_hour': 100,
            'min_duration': 1,
            'max_duration': 6
        },
        'produccion': {
            'id': 'produccion',
            'name': 'Produccion Audiovisual',
            'description': 'Servicios completos de filmacion, edicion y posproduccion para crear contenido de alta calidad.',
            'icon': '🎬',
            'price_per_hour': 150,
            'min_duration': 3,
            'max_duration': 10
        },
        'corporativo': {
            'id': 'corporativo',
            'name': 'Servicios Corporativos',
            'description': 'Filmacion para empresas, publicidad, eventos y proyectos especiales.',
            'icon': '🏢',
            'price_per_hour': 180,
            'min_duration': 4,
            'max_duration': 12
        },
        'telemetria': {
            'id': 'telemetria',
            'name': 'Telemetria y Modelado 3D',
            'description': 'Digitalizacion de espacios y creacion de modelos 3D de alta precision.',
            'icon': '📊',
            'price_per_hour': 200,
            'min_duration': 3,
            'max_duration': 8
        }
    }
    
    service = services.get(service_id)
    if service:
        return jsonify({'success': True, 'service': service})
    else:
        return jsonify({'success': False, 'error': 'Servicio no encontrado'}), 404

# Ruta para obtener horarios disponibles para un servicio en una fecha específica
@app.route('/api/services/<service_id>/available-times', methods=['GET'])
def get_available_times(service_id):
    date_str = request.args.get('date')
    
    if not date_str:
        return jsonify({'success': False, 'error': 'Fecha no especificada'}), 400
    
    # Generar horarios disponibles (simulados)
    available_times = [
        "08:00", "09:00", "10:00", "11:00", "12:00", 
        "13:00", "14:00", "15:00", "16:00", "17:00", "18:00"
    ]
    
    # Simulamos algunos horarios no disponibles
    # En una implementación real, esto se verificaría en la base de datos
    if date_str.endswith('01/') or date_str.endswith('/15/'):
        available_times = available_times[::2]  # Solo cada segundo horario
    
    return jsonify({
        'success': True,
        'service_id': service_id,
        'date': date_str,
        'availableTimes': available_times
    })

# Ruta para crear una nueva reserva
@app.route('/api/bookings', methods=['POST'])
def create_booking():
    data = request.json
    
    # Validación básica de datos
    required_fields = ['service_id', 'booking_date', 'start_time', 'duration', 
                      'client_name', 'client_email', 'client_phone', 'location']
    
    for field in required_fields:
        if field not in data or not data[field]:
            return jsonify({
                'success': False, 
                'error': f'Campo obligatorio faltante: {field}'
            }), 400
    
    # Generar ID de reserva único
    booking_id = str(uuid.uuid4())[:8].upper()
    
    # En una implementación real, aquí se verificaría la disponibilidad
    # y se guardaría la reserva en la base de datos
    
    # Para este ejemplo, simplemente devolvemos el ID de reserva
    return jsonify({
        'success': True,
        'message': 'Reserva creada correctamente',
        'booking_id': booking_id
    })

# Si se ejecuta este archivo directamente
if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('DEBUG', 'false').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)
