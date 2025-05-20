#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json
import datetime
import uuid
import sqlite3
import logging
from flask import Flask, request, jsonify
from flask_cors import CORS

# Modificar esta línea para usar una importación relativa
# Esta línea debería funcionar si maps_proxy.py está en el mismo directorio
try:
    from maps_proxy import maps_api
except ImportError:
    try:
        # Intenta importar como ruta relativa
        from .maps_proxy import maps_api
    except ImportError:
        # Crea un objeto simulado si no se puede importar
        maps_api = type('obj', (object,), {
            'proxy_route': lambda: {'message': 'Maps API no disponible'}
        })
        print("ADVERTENCIA: No se pudo importar maps_proxy. Algunas funciones pueden no estar disponibles.")

# Configuración de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('Booking API')

# Inicializar la aplicación Flask
app = Flask(__name__)
CORS(app)  # Permitir CORS para todas las rutas

# Directorio donde está la base de datos
DB_PATH = "database/dronevista.db"

# Verificar si la base de datos existe
if not os.path.exists(DB_PATH):
    logger.warning(f"Base de datos no encontrada en {DB_PATH}. Creando una básica.")
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    # Crear tablas básicas si la BD no existe
    c.execute('''
    CREATE TABLE IF NOT EXISTS services (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        price_per_hour REAL,
        min_duration INTEGER,
        max_duration INTEGER
    )
    ''')
    
    # Insertar datos demo
    services = [
        ('montaña', 'Filmación en Montaña', 'Tomas espectaculares de paisajes montañosos, senderos y actividades al aire libre.', '🏔️', 120, 2, 8),
        ('playa', 'Filmación en Playa', 'Imágenes aéreas impresionantes de costas, olas y eventos playeros.', '🏖️', 100, 1, 6),
        ('produccion', 'Producción Audiovisual', 'Servicios completos de filmación, edición y posproducción para crear contenido de alta calidad.', '🎬', 150, 3, 10),
        ('corporativo', 'Servicios Corporativos', 'Filmación para empresas, publicidad, eventos y proyectos especiales.', '🏢', 180, 4, 12),
        ('telemetria', 'Telemetría y Modelado 3D', 'Digitalización de espacios y creación de modelos 3D de alta precisión.', '📊', 200, 3, 8)
    ]
    
    c.executemany('INSERT OR REPLACE INTO services VALUES (?, ?, ?, ?, ?, ?, ?)', services)
    conn.commit()
    conn.close()
    
    logger.info("Base de datos creada con servicios demostrativos.")

# Función para conectar a la base de datos
def get_db_connection():
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        return conn
    except sqlite3.Error as e:
        logger.error(f"Error al conectar con la base de datos: {e}")
        return None

# Registra la API de mapas como submodulo
app.register_blueprint(maps_api)

# Ruta de prueba para verificar que la API está funcionando
@app.route('/api/test', methods=['GET'])
def test_api():
    return jsonify({'success': True, 'message': 'API funcionando correctamente'})

# Ruta para obtener todos los servicios
@app.route('/api/services', methods=['GET'])
def get_services():
    conn = get_db_connection()
    if not conn:
        return jsonify({'success': False, 'error': 'Error de conexión a la base de datos'}), 500
    
    try:
        cursor = conn.cursor()
        services = cursor.execute('SELECT * FROM services').fetchall()
        
        # Convertir los resultados a una lista de diccionarios
        services_list = []
        for service in services:
            services_list.append({
                'id': service['id'],
                'name': service['name'],
                'description': service['description'],
                'icon': service['icon'],
                'price_per_hour': service['price_per_hour'],
                'min_duration': service['min_duration'],
                'max_duration': service['max_duration']
            })
        
        return jsonify({'success': True, 'services': services_list})
    except Exception as e:
        logger.error(f"Error al obtener servicios: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500
    finally:
        conn.close()

# Ruta para obtener los detalles de un servicio específico
@app.route('/api/services/<service_id>', methods=['GET'])
def get_service(service_id):
    conn = get_db_connection()
    if not conn:
        return jsonify({'success': False, 'error': 'Error de conexión a la base de datos'}), 500
    
    try:
        cursor = conn.cursor()
        service = cursor.execute('SELECT * FROM services WHERE id = ?', (service_id,)).fetchone()
        
        if service:
            service_dict = {
                'id': service['id'],
                'name': service['name'],
                'description': service['description'],
                'icon': service['icon'],
                'price_per_hour': service['price_per_hour'],
                'min_duration': service['min_duration'],
                'max_duration': service['max_duration']
            }
            return jsonify({'success': True, 'service': service_dict})
        else:
            return jsonify({'success': False, 'error': 'Servicio no encontrado'}), 404
    except Exception as e:
        logger.error(f"Error al obtener el servicio {service_id}: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500
    finally:
        conn.close()

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
    app.run(host='0.0.0.0', port=port, debug=True)