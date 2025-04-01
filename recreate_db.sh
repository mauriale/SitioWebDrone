#!/bin/bash

echo "=== Recreando base de datos de DroneVista con nuevo servicio de Telemetría ==="

# Verificar si Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 no está instalado"
    echo "Por favor, instala Python 3 y vuelve a ejecutar este script"
    exit 1
fi

# Eliminar la base de datos anterior si existe
if [ -f database/dronevista.db ]; then
    echo "Eliminando base de datos existente..."
    rm database/dronevista.db
fi

# Ejecutar el script de creación de base de datos
echo "Creando nueva base de datos con servicio de telemetría..."
python3 database/create_db.py

# Verificar si la creación fue exitosa
if [ $? -eq 0 ]; then
    echo ""
    echo "=== Base de datos recreada exitosamente ==="
    echo "El nuevo servicio de Telemetría y Modelado 3D ha sido añadido."
    echo "Para ver los cambios, reinicia el servidor con: python3 start_server.py"
else
    echo "Error durante la recreación de la base de datos"
    exit 1
fi