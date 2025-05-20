#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import json
import argparse
import logging
import subprocess
import webbrowser
import threading
import time
import socket
from pathlib import Path

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('MCP_Server')

def is_port_in_use(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0

def check_python_modules():
    """Verifica que los módulos necesarios estén instalados"""
    required_modules = ['flask', 'flask_cors', 'requests']
    missing_modules = []
    
    for module in required_modules:
        try:
            __import__(module)
        except ImportError:
            missing_modules.append(module)
    
    if missing_modules:
        logger.warning(f"Faltan módulos: {', '.join(missing_modules)}")
        logger.info("Instalando módulos faltantes...")
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install"] + missing_modules)
            logger.info("Módulos instalados correctamente")
            return True
        except subprocess.CalledProcessError:
            logger.error("Error al instalar módulos")
            return False
    
    return True

def get_config(config_path):
    """Obtiene la configuración del archivo o usa valores por defecto"""
    default_config = {
        "database": {
            "path": "database/dronevista.db",
            "backup_path": "data/backup"
        },
        "api": {
            "port": 5000,
            "debug": False,
            "cors_origins": ["http://localhost:5001", "http://127.0.0.1:5001"]
        },
        "web": {
            "port": 5001,
            "debug": False
        },
        "maps": {
            "api_key": "YOUR_GOOGLE_MAPS_API_KEY",
            "proxy_enabled": True
        }
    }
    
    try:
        if not os.path.exists(config_path):
            # Crear directorios si no existen
            os.makedirs(os.path.dirname(config_path), exist_ok=True)
            
            # Guardar configuración por defecto
            with open(config_path, 'w', encoding='utf-8') as f:
                json.dump(default_config, f, indent=4)
            
            logger.info(f"Archivo de configuración creado en {config_path}")
            return default_config
        
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        logger.info(f"Configuración cargada desde {config_path}")
        return config
    except Exception as e:
        logger.error(f"Error al cargar configuración: {e}")
        return default_config

def start_api_server(config, debug=False):
    """Inicia el servidor API"""
    try:
        # Verificar si el directorio api existe
        if not os.path.exists('api'):
            os.makedirs('api', exist_ok=True)
            logger.info("Directorio api creado")
        
        # Verificar si booking_api.py y maps_proxy.py existen
        api_files = {
            'api/booking_api.py': 'https://raw.githubusercontent.com/mauriale/SitioWebDrone/main/api/booking_api.py',
            'api/maps_proxy.py': 'https://raw.githubusercontent.com/mauriale/SitioWebDrone/main/api/maps_proxy.py'
        }
        
        import_error = False
        for file_path, url in api_files.items():
            if not os.path.exists(file_path):
                logger.warning(f"Archivo {file_path} no encontrado")
                import_error = True
        
        # Si falta algún archivo, mejor no iniciar el API
        if import_error:
            logger.warning("No se iniciará el servidor API debido a archivos faltantes")
            return None
        
        # Verifica si el puerto ya está en uso
        api_port = config.get('api', {}).get('port', 5000)
        if is_port_in_use(api_port):
            logger.warning(f"Puerto {api_port} ya está en uso. Cambiando API a puerto {api_port+10}")
            api_port += 10
        
        # Iniciar la API
        api_cmd = [sys.executable, "api/booking_api.py"]
        if debug:
            os.environ['FLASK_DEBUG'] = '1'
        
        os.environ['PORT'] = str(api_port)
        process = subprocess.Popen(api_cmd)
        
        logger.info(f"API iniciada con PID: {process.pid}")
        return process
    except Exception as e:
        logger.error(f"Error al iniciar la API: {e}")
        return None

def start_static_server(config, debug=False):
    """Inicia el servidor web estático"""
    try:
        # Verificar si el puerto ya está en uso
        web_port = config.get('web', {}).get('port', 5001)
        if is_port_in_use(web_port):
            logger.warning(f"Puerto {web_port} ya está en uso. Cambiando web a puerto {web_port+10}")
            web_port += 10
        
        # Usar el servidor HTTP simple de Python
        os.chdir(os.path.dirname(os.path.abspath(__file__)))
        
        cmd = [sys.executable, "-m", "http.server", str(web_port)]
        process = subprocess.Popen(cmd)
        
        logger.info(f"Servidor estático iniciado con PID: {process.pid}")
        return process
    except Exception as e:
        logger.error(f"Error al iniciar el servidor estático: {e}")
        return None

def open_browser(url, delay=2):
    """Abre el navegador después de un delay"""
    def _open_browser():
        time.sleep(delay)
        webbrowser.open(url)
    
    threading.Thread(target=_open_browser).start()

def main():
    """Función principal"""
    parser = argparse.ArgumentParser(description='Iniciar servidores SitioWebDrone')
    parser.add_argument('-c', '--config', default='config/db_config.json', help='Ruta al archivo de configuración')
    parser.add_argument('-d', '--debug', action='store_true', help='Activar modo debug')
    parser.add_argument('-n', '--no-browser', action='store_true', help='No abrir navegador automáticamente')
    args = parser.parse_args()
    
    # Verificar módulos Python necesarios
    if not check_python_modules():
        logger.error("No se pudieron instalar los módulos necesarios. Abortando.")
        return 1
    
    # Cargar configuración
    config = get_config(args.config)
    
    # Verificar base de datos
    db_path = config.get('database', {}).get('path', 'database/dronevista.db')
    if os.path.exists(db_path):
        logger.info(f"Base de datos encontrada en {db_path}")
    else:
        logger.warning(f"Base de datos no encontrada en {db_path}")
        # La base de datos será creada por booking_api.py
    
    # Iniciar servidores
    logger.info(f"Iniciando API en localhost:{config.get('api', {}).get('port', 5000)}...")
    api_process = start_api_server(config, args.debug)
    
    logger.info(f"Iniciando servidor estático en puerto {config.get('web', {}).get('port', 5001)}...")
    web_process = start_static_server(config, args.debug)
    
    if api_process and web_process:
        logger.info("Servidores iniciados correctamente")
        
        web_port = config.get('web', {}).get('port', 5001)
        api_port = config.get('api', {}).get('port', 5000)
        
        logger.info(f"API disponible en: http://localhost:{api_port}/api")
        logger.info(f"Panel de administración disponible en: http://localhost:{web_port}/admin")
        logger.info(f"Sitio web disponible en: http://localhost:{web_port}")
        
        # Abrir navegador
        if not args.no_browser:
            open_browser(f"http://localhost:{web_port}")
        
        # Mantener procesos en ejecución
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            logger.info("Deteniendo servidores...")
            if api_process:
                api_process.terminate()
            if web_process:
                web_process.terminate()
    else:
        logger.error("Fallo al iniciar uno o más servidores")
        return 1

if __name__ == "__main__":
    sys.exit(main())