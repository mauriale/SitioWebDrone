#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json
import requests
from flask import Blueprint, request, jsonify
from flask_cors import cross_origin

# Crear blueprint para las rutas de Maps
maps_api = Blueprint('maps_api', __name__)

# Cargar la API key desde una variable de entorno o archivo de configuración
# Esto mantiene la clave fuera del código fuente
API_KEY = os.environ.get('GOOGLE_MAPS_API_KEY', '')

# Si no está en variables de entorno, intentar cargar del archivo de configuración
if not API_KEY:
    try:
        config_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'config/maps_config.json')
        if os.path.exists(config_path):
            with open(config_path, 'r') as f:
                config = json.load(f)
                API_KEY = config.get('api_key', '')
    except Exception as e:
        print(f"Error cargando API key: {e}")

# Endpoint para autocompletado de lugares
@maps_api.route('/places/autocomplete', methods=['GET'])
@cross_origin()
def places_autocomplete():
    # Obtener el texto de búsqueda del parámetro de consulta
    input_text = request.args.get('input', '')
    
    if not input_text:
        return jsonify({"error": "Se requiere un texto de búsqueda"}), 400
    
    # Parámetros para la API de Places de Google
    params = {
        'input': input_text,
        'key': API_KEY,
        'types': request.args.get('types', ''),
        'components': request.args.get('components', ''),
        'language': request.args.get('language', 'es')
    }
    
    # Limpiar parámetros vacíos
    params = {k: v for k, v in params.items() if v}
    
    # Hacer la solicitud a la API de Google
    try:
        response = requests.get(
            'https://maps.googleapis.com/maps/api/place/autocomplete/json',
            params=params
        )
        
        # Devolver los resultados al cliente
        return jsonify(response.json())
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Endpoint para geocodificación (convertir dirección a coordenadas)
@maps_api.route('/geocode', methods=['GET'])
@cross_origin()
def geocode():
    # Obtener la dirección del parámetro de consulta
    address = request.args.get('address', '')
    
    if not address:
        return jsonify({"error": "Se requiere una dirección"}), 400
    
    # Parámetros para la API de Geocodificación de Google
    params = {
        'address': address,
        'key': API_KEY,
        'language': request.args.get('language', 'es')
    }
    
    # Hacer la solicitud a la API de Google
    try:
        response = requests.get(
            'https://maps.googleapis.com/maps/api/geocode/json',
            params=params
        )
        
        # Devolver los resultados al cliente
        return jsonify(response.json())
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Endpoint para geocodificación inversa (convertir coordenadas a dirección)
@maps_api.route('/reverse-geocode', methods=['GET'])
@cross_origin()
def reverse_geocode():
    # Obtener las coordenadas de los parámetros de consulta
    lat = request.args.get('lat', '')
    lng = request.args.get('lng', '')
    
    if not lat or not lng:
        return jsonify({"error": "Se requieren latitud y longitud"}), 400
    
    # Parámetros para la API de Geocodificación de Google
    params = {
        'latlng': f"{lat},{lng}",
        'key': API_KEY,
        'language': request.args.get('language', 'es')
    }
    
    # Hacer la solicitud a la API de Google
    try:
        response = requests.get(
            'https://maps.googleapis.com/maps/api/geocode/json',
            params=params
        )
        
        # Devolver los resultados al cliente
        return jsonify(response.json())
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Endpoint para obtener un mapa estático
@maps_api.route('/static-map', methods=['GET'])
@cross_origin()
def static_map():
    # Obtener los parámetros necesarios
    center = request.args.get('center', '')
    zoom = request.args.get('zoom', '14')
    size = request.args.get('size', '600x300')
    markers = request.args.get('markers', '')
    
    if not center and not markers:
        return jsonify({"error": "Se requiere center o markers"}), 400
    
    # Parámetros para la API de Static Maps de Google
    params = {
        'center': center,
        'zoom': zoom,
        'size': size,
        'markers': markers,
        'key': API_KEY
    }
    
    # Limpiar parámetros vacíos
    params = {k: v for k, v in params.items() if v}
    
    # Hacer la solicitud a la API de Google
    try:
        response = requests.get(
            'https://maps.googleapis.com/maps/api/staticmap',
            params=params,
            stream=True
        )
        
        # Devolver la imagen directamente
        from flask import Response
        return Response(
            response.iter_content(chunk_size=1024),
            content_type=response.headers['Content-Type']
        )
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500