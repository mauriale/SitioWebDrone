#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask, request, jsonify
from flask_cors import CORS
import sys
import os
import json

# Añadir el directorio padre al path de Python para poder importar el módulo de la base de datos
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database.db_manager import DroneVistaDB

app = Flask(__name__)
CORS(app)  # Habilitar CORS para todas las rutas

# Configuración
DATABASE_PATH = '../database/dronevista.db'

# Instanciar el gestor de base de datos
db = DroneVistaDB(DATABASE_PATH)

@app.route('/api/services', methods=['GET'])
def get_services():
    """Obtiene todos los servicios disponibles."""
    try:
        services = db.get_all_services()
        return jsonify({'success': True, 'services': services})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/services/<service_id>', methods=['GET'])
def get_service(service_id):
    """Obtiene un servicio específico por su ID."""
    try:
        service = db.get_service(service_id)
        if service:
            return jsonify({'success': True, 'service': service})
        else:
            return jsonify({'success': False, 'error': 'Servicio no encontrado'}), 404
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/services/<service_id>/available-times', methods=['GET'])
def get_available_times(service_id):
    """Obtiene horarios disponibles para un servicio en una fecha específica."""
    try:
        date = request.args.get('date')
        if not date:
            return jsonify({'success': False, 'error': 'Se requiere fecha'}), 400
            
        times = db.get_available_times_for_date(service_id, date)
        return jsonify({'success': True, 'availableTimes': times})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/bookings', methods=['GET'])
def get_bookings():
    """Obtiene todas las reservas."""
    try:
        bookings = db.get_all_bookings()
        return jsonify({'success': True, 'bookings': bookings})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/bookings/<booking_id>', methods=['GET'])
def get_booking(booking_id):
    """Obtiene una reserva específica por su ID."""
    try:
        booking = db.get_booking(booking_id)
        if booking:
            return jsonify({'success': True, 'booking': booking})
        else:
            return jsonify({'success': False, 'error': 'Reserva no encontrada'}), 404
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/bookings', methods=['POST'])
def create_booking():
    """Crea una nueva reserva."""
    try:
        data = request.json
        if not data:
            return jsonify({'success': False, 'error': 'No se recibieron datos'}), 400
            
        required_fields = ['service_id', 'booking_date', 'start_time', 'duration', 
                          'client_name', 'client_email', 'client_phone']
        
        # Verificar campos requeridos
        for field in required_fields:
            if field not in data:
                return jsonify({'success': False, 'error': f'Campo requerido ausente: {field}'}), 400
        
        # Crear reserva en la base de datos
        booking_id = db.create_booking(data)
        
        # Exportar datos actualizados a JSON para respaldo
        db.export_bookings_to_json()
        
        return jsonify({'success': True, 'booking_id': booking_id})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/bookings/<booking_id>/status', methods=['PUT'])
def update_booking_status(booking_id):
    """Actualiza el estado de una reserva."""
    try:
        data = request.json
        if not data or 'status' not in data:
            return jsonify({'success': False, 'error': 'Se requiere estado'}), 400
            
        status = data['status']
        if status not in ['pendiente', 'confirmado', 'cancelado']:
            return jsonify({'success': False, 'error': 'Estado no válido'}), 400
            
        success = db.update_booking_status(booking_id, status)
        
        if success:
            # Exportar datos actualizados a JSON para respaldo
            db.export_bookings_to_json()
            return jsonify({'success': True})
        else:
            return jsonify({'success': False, 'error': 'Reserva no encontrada'}), 404
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)
