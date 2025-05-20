#!/bin/bash

# Colores para los mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}    CREANDO PUNTO DE RESPALDO INICIAL         ${NC}"
echo -e "${BLUE}=============================================${NC}"

# Verificar que el script backup.sh existe
if [ ! -f "backup.sh" ]; then
    echo -e "${RED}✗ Script backup.sh no encontrado.${NC}"
    exit 1
fi

# Hacer el script ejecutable si no lo es
if [ ! -x "backup.sh" ]; then
    echo -e "${YELLOW}Haciendo backup.sh ejecutable...${NC}"
    chmod +x backup.sh
fi

# Crear un punto de respaldo inicial
./backup.sh create Base-v1.0 "Versión original antes de las mejoras"

echo -e "${GREEN}✓ Punto de respaldo inicial creado.${NC}"
echo -e "Ahora puedes continuar con las implementaciones de mejoras."
echo -e "Para restaurar este punto en cualquier momento, ejecuta:"
echo -e "${YELLOW}./backup.sh restore Base-v1.0${NC}"
