#!/bin/bash

echo "=== Instalando dependencias para SitioWebDrone ==="

# Verificar si Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 no está instalado"
    echo "Por favor, instala Python 3 y vuelve a ejecutar este script"
    exit 1
fi

# Verificar si pip está instalado
if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
    echo "Error: pip no está instalado"
    echo "Por favor, instala pip y vuelve a ejecutar este script"
    exit 1
fi

# Determinar qué comando de pip usar
if command -v pip3 &> /dev/null; then
    PIP_CMD="pip3"
else
    PIP_CMD="pip"
fi

# Crear entorno virtual (opcional pero recomendado)
echo "¿Deseas crear un entorno virtual para la instalación? (s/n)"
read -r create_venv

if [ "$create_venv" = "s" ] || [ "$create_venv" = "S" ]; then
    echo "Creando entorno virtual..."
    python3 -m venv venv
    
    # Activar entorno virtual
    if [ -d "venv/bin" ]; then
        source venv/bin/activate
    elif [ -d "venv/Scripts" ]; then
        source venv/Scripts/activate
    else
        echo "No se pudo activar el entorno virtual"
        exit 1
    fi
    
    # Actualizar pip en el entorno virtual
    $PIP_CMD install --upgrade pip
    
    echo "Entorno virtual creado y activado"
fi

# Instalar dependencias desde requirements.txt
echo "Instalando dependencias desde requirements.txt..."
$PIP_CMD install -r requirements.txt

# Verificar si la instalación fue exitosa
if [ $? -eq 0 ]; then
    echo "Instalación completada con éxito!"
    
    # Crear directorios necesarios si no existen
    echo "Creando directorios necesarios..."
    mkdir -p logs
    mkdir -p database/backup
    
    # Inicializar la base de datos si no existe
    if [ ! -f database/dronevista.db ]; then
        echo "Inicializando base de datos..."
        python3 database/create_db.py
    fi
    
    echo ""
    echo "=== Instalación completada ==="
    echo "Para iniciar el servidor: python3 start_server.py"
    
    if [ "$create_venv" = "s" ] || [ "$create_venv" = "S" ]; then
        echo ""
        echo "NOTA: Has instalado en un entorno virtual."
        echo "Recuerda activar el entorno virtual antes de ejecutar el servidor:"
        echo "  source venv/bin/activate  # En Linux/Mac"
        echo "  .\\venv\\Scripts\\activate  # En Windows"
    fi
else
    echo "Error durante la instalación de dependencias"
    exit 1
fi