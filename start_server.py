#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import json
import subprocess
import argparse
import logging
from logging.handlers import RotatingFileHandler

# Configurar logging básico
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler()
    ]
)

logger = logging.getLogger("MCP_Server")

def load_config(config_path=None):
    """Carga la configuración desde un archivo JSON."""
    if not config_path:
        config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'config/db_config.json')
    
    try:
        with open(config_path, 'r') as config_file:
            return json.load(config_file)
    except Exception as e:
        logger.error(f"Error al cargar configuración: {e}")
        return None

def setup_logging(config):
    """Configura el logging basado en la configuración."""
    try:
        log_level = getattr(logging, config['logging']['level'].upper(), logging.INFO)
        log_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), config['logging']['file'])
        
        # Asegurar que el directorio de logs existe
        os.makedirs(os.path.dirname(log_file), exist_ok=True)
        
        # Configurar el logger
        file_handler = RotatingFileHandler(
            log_file,
            maxBytes=config['logging']['max_size'],
            backupCount=config['logging']['backup_count']
        )
        file_handler.setFormatter(logging.Formatter(config['logging']['format']))
        
        logger.setLevel(log_level)
        logger.addHandler(file_handler)
        
        logger.info("Logging configurado correctamente")
    except Exception as e:
        logger.error(f"Error al configurar logging: {e}")

def setup_database(config):
    """Inicializa la base de datos si es necesario."""
    try:
        db_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), config['database']['path'])
        if not os.path.exists(db_path):
            logger.info("Inicializando base de datos...")
            create_db_script = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'database/create_db.py')
            
            if os.path.exists(create_db_script):
                result = subprocess.run([sys.executable, create_db_script], capture_output=True, text=True)
                if result.returncode == 0:
                    logger.info("Base de datos inicializada correctamente")
                else:
                    logger.error(f"Error al inicializar base de datos: {result.stderr}")
            else:
                logger.error(f"Script de inicialización no encontrado: {create_db_script}")
        else:
            logger.info(f"Base de datos encontrada en {db_path}")
    except Exception as e:
        logger.error(f"Error al configurar base de datos: {e}")

def start_api_server(config):
    """Inicia el servidor API."""
    try:
        api_script = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'api/booking_api.py')
        
        if os.path.exists(api_script):
            logger.info(f"Iniciando API en {config['api']['host']}:{config['api']['port']}...")
            
            # Ejecutar en un subproceso
            process = subprocess.Popen([sys.executable, api_script])
            logger.info(f"API iniciada con PID: {process.pid}")
            
            return process
        else:
            logger.error(f"Script de API no encontrado: {api_script}")
            return None
    except Exception as e:
        logger.error(f"Error al iniciar servidor API: {e}")
        return None

def start_static_server(config):
    """Inicia un servidor estático para los archivos HTML/CSS/JS."""
    try:
        port = config['api']['port'] + 1  # Puerto para el servidor estático
        static_dir = os.path.dirname(os.path.abspath(__file__))
        
        logger.info(f"Iniciando servidor estático en puerto {port}...")
        
        # Verificar si tenemos http.server disponible (Python 3)
        server_command = [sys.executable, "-m", "http.server", str(port)]
        
        # Ejecutar en un subproceso
        process = subprocess.Popen(server_command, cwd=static_dir)
        logger.info(f"Servidor estático iniciado con PID: {process.pid}")
        
        logger.info(f"Sitio web disponible en: http://localhost:{port}")
        
        return process
    except Exception as e:
        logger.error(f"Error al iniciar servidor estático: {e}")
        return None

def main():
    """Función principal."""
    parser = argparse.ArgumentParser(description="Iniciar servidor MCP para DroneVista")
    parser.add_argument("-c", "--config", help="Ruta al archivo de configuración", default=None)
    parser.add_argument("-d", "--debug", help="Modo debug", action="store_true")
    args = parser.parse_args()
    
    # Cargar configuración
    config = load_config(args.config)
    if not config:
        logger.error("No se pudo cargar la configuración. Abortando.")
        sys.exit(1)
    
    # Si se especificó modo debug, sobreescribir la configuración
    if args.debug:
        config['api']['debug'] = True
    
    # Configurar logging
    setup_logging(config)
    
    # Inicializar base de datos si es necesario
    setup_database(config)
    
    # Iniciar servidores
    api_process = start_api_server(config)
    static_process = start_static_server(config)
    
    if api_process and static_process:
        logger.info("Servidores iniciados correctamente")
        logger.info(f"API disponible en: http://{config['api']['host']}:{config['api']['port']}/api")
        logger.info(f"Panel de administración disponible en: http://localhost:{config['api']['port'] + 1}/admin")
        
        try:
            # Mantener el script en ejecución
            api_process.wait()
        except KeyboardInterrupt:
            logger.info("Cerrando servidores...")
            api_process.terminate()
            static_process.terminate()
            logger.info("Servidores detenidos")
    else:
        logger.error("No se pudieron iniciar todos los servidores. Abortando.")
        sys.exit(1)

if __name__ == "__main__":
    main()
