#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Este es un script básico que gestiona la ejecución de
# un servidor HTTP simple para archivos estáticos.

import os
import sys
import subprocess
import webbrowser
import time
import logging

# Configuración de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger('SitioWebDrone')

def main():
    """Función principal para iniciar el servidor"""
    
    # Obtener el directorio actual
    current_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(current_dir)
    
    # Verificar si se desea el modo debug
    debug_mode = "--debug" in sys.argv
    if debug_mode:
        logger.setLevel(logging.DEBUG)
        logger.debug("Modo debug activado")
    
    # Verificar directorios necesarios
    required_dirs = ["logs", "data", "database", "api", "config"]
    for directory in required_dirs:
        if not os.path.exists(directory):
            os.makedirs(directory, exist_ok=True)
            logger.info(f"Directorio {directory} creado")
    
    # Verificar archivos API necesarios
    if not os.path.exists("api/booking_api.py"):
        logger.warning("Archivo api/booking_api.py no encontrado")
        
    if not os.path.exists("api/maps_proxy.py"):
        logger.warning("Archivo api/maps_proxy.py no encontrado")
    
    # Iniciar servidor web estático
    logger.info("Iniciando servidor web estático en puerto 5001...")
    web_process = subprocess.Popen(
        [sys.executable, "-m", "http.server", "5001"],
        stdout=subprocess.PIPE, 
        stderr=subprocess.PIPE
    )
    
    # Iniciar API
    logger.info("Iniciando API en puerto 5000...")
    if os.path.exists("api/booking_api.py"):
        env = os.environ.copy()
        env["PORT"] = "5000"
        if debug_mode:
            env["FLASK_DEBUG"] = "1"
            
        api_process = subprocess.Popen(
            [sys.executable, "api/booking_api.py"],
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
    else:
        api_process = None
        logger.error("No se puede iniciar la API - archivo booking_api.py no encontrado")
    
    # Abrir navegador
    logger.info("Abriendo navegador...")
    webbrowser.open("http://localhost:5001")
    
    # Mantener el servidor en ejecución
    try:
        logger.info("Servidor iniciado. Presiona Ctrl+C para detener.")
        logger.info("API: http://localhost:5000/api")
        logger.info("Web: http://localhost:5001")
        
        # Mantener el proceso principal en ejecución
        while True:
            time.sleep(1)
            
            # Verificar que los procesos siguen en ejecución
            if api_process and api_process.poll() is not None:
                logger.error("La API se ha detenido inesperadamente")
                break
                
            if web_process.poll() is not None:
                logger.error("El servidor web se ha detenido inesperadamente")
                break
                
    except KeyboardInterrupt:
        logger.info("Deteniendo servidores...")
    finally:
        # Detener procesos
        if api_process:
            api_process.terminate()
        web_process.terminate()
        
        logger.info("Servidores detenidos")

if __name__ == "__main__":
    main()