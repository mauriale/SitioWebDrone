#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json
import logging
import requests
from flask import Blueprint, request, jsonify

# Configuración de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('Maps Proxy')

# Crear un Blueprint para la API de mapas
maps_api = Blueprint('maps_api', __name__)

# Intentar cargar la clave API desde la configuración
try:
    config_path = os.path.join('config', 'db_config.json')
    if os.path.exists(config_path):
        with open(config_path, 'r') as f:
            config = json.load(f)
        API_KEY = config.get('maps', {}).get('api_key', 'YOUR_GOOGLE_MAPS_API_KEY')
    else:
        API_KEY = 'YOUR_GOOGLE_MAPS_API_KEY'
        logger.warning(f"Archivo de configuración no encontrado: {config_path}")
except Exception as e:
    API_KEY = 'YOUR_GOOGLE_MAPS_API_KEY'
    logger.error(f"Error al cargar la configuración: {e}")

# Ruta para el proxy de Google Maps
@maps_api.route('/api/maps/proxy', methods=['GET'])
def proxy_route():
    try:
        # Ruta de Google Maps a la que se enviará la solicitud
        maps_endpoint = request.args.get('endpoint', 'geocode/json')
        
        # Construir la URL completa
        url = f"https://maps.googleapis.com/maps/api/{maps_endpoint}"
        
        # Copiar los parámetros de la solicitud original
        params = request.args.to_dict()
        
        # Eliminar el parámetro 'endpoint' que ya usamos
        if 'endpoint' in params:
            del params['endpoint']
        
        # Añadir la clave API
        params['key'] = API_KEY
        
        # Hacer la solicitud a la API de Google Maps
        response = requests.get(url, params=params)
        
        # Devolver la respuesta como JSON
        return jsonify(response.json())
    
    except Exception as e:
        logger.error(f"Error en el proxy de Maps: {e}")
        return jsonify({
            'error': 'Error en el proxy de Maps',
            'message': str(e)
        }), 500

# Ruta para verificar si la API está configurada
@maps_api.route('/api/maps/status', methods=['GET'])
def maps_status():
    # Verificar si tenemos una clave API válida
    is_configured = API_KEY != 'YOUR_GOOGLE_MAPS_API_KEY'
    
    return jsonify({
        'configured': is_configured,
        'message': 'API de Google Maps configurada correctamente' if is_configured else 'Clave API no configurada'
    })