#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask, request, jsonify
from flask_cors import CORS
import sys
import os
import json
import logging
from logging.handlers import RotatingFileHandler
import datetime

# Añadir el directorio padre al path de Python para poder importar el módulo de la base de datos
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database.db_manager import DroneVistaDB

# Cargar configuración
config_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'config/db_config.json')
try:
    with open(config_path, 'r') as config_file:
        config = json.load(config_file)
except Exception as e:
    print(f"Error al cargar la configuración: {e}")
    # Configuración por defecto si no se puede cargar el archivo
    config = {
        "database": {"path": "../database/dronevista.db"},
        "api": {"host": "localhost", "port": 5000, "debug": True, "cors_enabled": True},
        "logging": {"level": "info", "file": "logs/api.log"}
    }

# Configurar logging
log_level = getattr(logging, config['logging']['level'].upper(), logging.INFO)
log_file = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), config['logging']['file'])

# Asegurar que el directorio de logs existe
os.makedirs(os.path.dirname(log_file), exist_ok=True)

logging.basicConfig(
    level=log_level,
    format=config['logging']['format'],
    handlers=[
        RotatingFileHandler(
            log_file,
            maxBytes=config['logging']['max_size'],
            backupCount=config['logging']['backup_count']
        ),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)
logger.info("Iniciando API de DroneVista")

app = Flask(__name__)

# Configurar CORS
if config['api']['cors_enabled']:
    CORS(app)
    allowed_origins = config['api']['allowed_origins']
    logger.info(f"CORS habilitado para: {allowed_origins}")

# Configuración de la base de datos
DATABASE_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), config['database']['path'])

# Instanciar el gestor de base de datos
db = DroneVistaDB(DATABASE_PATH)

@app.route('/api/services', methods=['GET'])
def get_services():
    """Obtiene todos los servicios disponibles."""
    try:
        services = db.get_all_services()
        logger.info(f"Obtenidos {len(services)} servicios")
        return jsonify({'success': True, 'services': services})
    except Exception as e:
        logger.error(f"Error al obtener servicios: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/services/<service_id>', methods=['GET'])
def get_service(service_id):
    """Obtiene un servicio específico por su ID."""
    try:
        service = db.get_service(service_id)
        if service:
            logger.info(f"Obtenido servicio: {service_id}")
            return jsonify({'success': True, 'service': service})
        else:
            logger.warning(f"Servicio no encontrado: {service_id}")
            return jsonify({'success': False, 'error': 'Servicio no encontrado'}), 404
    except Exception as e:
        logger.error(f"Error al obtener servicio {service_id}: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/services/<service_id>/available-times', methods=['GET'])
def get_available_times(service_id):
    """Obtiene horarios disponibles para un servicio en una fecha específica."""
    try:
        date = request.args.get('date')
        if not date:
            logger.warning("Solicitud de horarios sin fecha")
            return jsonify({'success': False, 'error': 'Se requiere fecha'}), 400
            
        times = db.get_available_times_for_date(service_id, date)
        logger.info(f"Obtenidos {len(times)} horarios disponibles para {service_id} en {date}")
        return jsonify({'success': True, 'availableTimes': times})
    except Exception as e:
        logger.error(f"Error al obtener horarios disponibles: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/bookings', methods=['GET'])
def get_bookings():
    """Obtiene todas las reservas."""
    try:
        bookings = db.get_all_bookings()
        logger.info(f"Obtenidas {len(bookings)} reservas")
        return jsonify({'success': True, 'bookings': bookings})
    except Exception as e:
        logger.error(f"Error al obtener reservas: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/bookings/<booking_id>', methods=['GET'])
def get_booking(booking_id):
    """Obtiene una reserva específica por su ID."""
    try:
        booking = db.get_booking(booking_id)
        if booking:
            logger.info(f"Obtenida reserva: {booking_id}")
            return jsonify({'success': True, 'booking': booking})
        else:
            logger.warning(f"Reserva no encontrada: {booking_id}")
            return jsonify({'success': False, 'error': 'Reserva no encontrada'}), 404
    except Exception as e:
        logger.error(f"Error al obtener reserva {booking_id}: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/bookings', methods=['POST'])
def create_booking():
    """Crea una nueva reserva."""
    try:
        data = request.json
        if not data:
            logger.warning("Intento de crear reserva sin datos")
            return jsonify({'success': False, 'error': 'No se recibieron datos'}), 400
            
        required_fields = ['service_id', 'booking_date', 'start_time', 'duration', 
                          'client_name', 'client_email', 'client_phone']
        
        # Verificar campos requeridos
        missing_fields = []
        for field in required_fields:
            if field not in data:
                missing_fields.append(field)
        
        if missing_fields:
            logger.warning(f"Campos requeridos ausentes en solicitud de reserva: {missing_fields}")
            return jsonify({'success': False, 'error': f'Campos requeridos ausentes: {", ".join(missing_fields)}'}), 400
        
        # Crear reserva en la base de datos
        booking_id = db.create_booking(data)
        
        # Exportar datos actualizados a JSON para respaldo
        if config['database'].get('auto_backup', False):
            db.export_bookings_to_json()
        
        # Enviar notificación por correo electrónico si está configurado
        if config['email']['enabled'] and config['notifications']['send_on_new_booking']:
            # Aquí iría el código para enviar el correo electrónico
            logger.info(f"Enviando notificación de nueva reserva: {booking_id}")
        
        logger.info(f"Reserva creada: {booking_id}")
        return jsonify({'success': True, 'booking_id': booking_id})
    except Exception as e:
        logger.error(f"Error al crear reserva: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/bookings/<booking_id>/status', methods=['PUT'])
def update_booking_status(booking_id):
    """Actualiza el estado de una reserva."""
    try:
        data = request.json
        if not data or 'status' not in data:
            logger.warning(f"Intento de actualizar estado de reserva {booking_id} sin estado")
            return jsonify({'success': False, 'error': 'Se requiere estado'}), 400
            
        status = data['status']
        if status not in ['pendiente', 'confirmado', 'cancelado']:
            logger.warning(f"Estado no válido para reserva {booking_id}: {status}")
            return jsonify({'success': False, 'error': 'Estado no válido'}), 400
            
        success = db.update_booking_status(booking_id, status)
        
        if success:
            # Exportar datos actualizados a JSON para respaldo
            if config['database'].get('auto_backup', False):
                db.export_bookings_to_json()
            
            # Enviar notificación por correo electrónico si está configurado
            if config['email']['enabled'] and config['notifications']['send_on_status_change']:
                # Aquí iría el código para enviar el correo electrónico
                logger.info(f"Enviando notificación de cambio de estado: {booking_id} -> {status}")
            
            logger.info(f"Estado de reserva actualizado: {booking_id} -> {status}")
            return jsonify({'success': True})
        else:
            logger.warning(f"Reserva no encontrada al actualizar estado: {booking_id}")
            return jsonify({'success': False, 'error': 'Reserva no encontrada'}), 404
    except Exception as e:
        logger.error(f"Error al actualizar estado de reserva {booking_id}: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

if __name__ == '__main__':
    host = config['api']['host']
    port = config['api']['port']
    debug = config['api']['debug']
    
    logger.info(f"Iniciando servidor en {host}:{port} (debug={debug})")
    app.run(host=host, port=port, debug=debug)
