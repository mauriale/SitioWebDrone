#!/bin/bash

# Colores para los mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para crear un punto de respaldo
create_backup() {
    local version_name=$1
    local desc=$2
    
    echo -e "${YELLOW}Creando punto de respaldo: ${version_name}${NC}"
    
    # Crear directorio de respaldo si no existe
    if [ ! -d "backups" ]; then
        mkdir -p backups
    fi
    
    # Crear archivo de descriptor con información
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local backup_dir="backups/${version_name}"
    
    # Crear directorio para este backup
    mkdir -p "${backup_dir}"
    
    # Guardar descriptor
    cat > "${backup_dir}/INFO.md" << EOF
# Punto de respaldo: ${version_name}

- **Fecha:** ${timestamp}
- **Descripción:** ${desc}

Este punto de respaldo incluye los siguientes archivos modificados desde la versión anterior:

\`\`\`
$(git diff --name-status HEAD~1 | sed 's/^M/Modificado: /g' | sed 's/^A/Añadido: /g' | sed 's/^D/Eliminado: /g')
\`\`\`

Para restaurar este punto de respaldo, utiliza:

\`\`\`bash
./backup.sh restore ${version_name}
\`\`\`
EOF
    
    # Crear una copia de seguridad de los archivos actuales
    rsync -av --exclude="backups" --exclude=".git" --exclude="venv" --exclude="__pycache__" \
          --exclude="*.pyc" --exclude="database/dronevista.db" . "${backup_dir}/" >/dev/null
    
    # Crear un archivo zip del respaldo
    local zip_name="backups/${version_name}.zip"
    zip -r "${zip_name}" "${backup_dir}" > /dev/null
    
    echo -e "${GREEN}✓ Punto de respaldo creado: ${zip_name}${NC}"
    echo -e "${GREEN}✓ Descriptor guardado en: ${backup_dir}/INFO.md${NC}"
    
    # Opcional: Guardar como tag en git
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo -e "${YELLOW}Creando tag de git para este punto...${NC}"
        git tag -a "${version_name}" -m "${desc}" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Tag de git creado: ${version_name}${NC}"
        else
            echo -e "${RED}✗ No se pudo crear el tag de git.${NC}"
        fi
    fi
}

# Función para listar puntos de respaldo
list_backups() {
    echo -e "${BLUE}=============================================${NC}"
    echo -e "${BLUE}      PUNTOS DE RESPALDO DISPONIBLES         ${NC}"
    echo -e "${BLUE}=============================================${NC}"
    
    if [ ! -d "backups" ] || [ -z "$(ls -A backups 2>/dev/null)" ]; then
        echo -e "${YELLOW}No se encontraron puntos de respaldo.${NC}"
        return
    fi
    
    echo -e "${YELLOW}Puntos de respaldo:${NC}"
    
    # Listar directorios de respaldo
    local backups=$(find backups -maxdepth 1 -type d | grep -v "^backups$" | sort)
    
    if [ -z "$backups" ]; then
        echo -e "${YELLOW}No se encontraron puntos de respaldo.${NC}"
        return
    fi
    
    for backup in $backups; do
        local version_name=$(basename "$backup")
        local info_file="${backup}/INFO.md"
        
        if [ -f "$info_file" ]; then
            local date=$(grep -oP "(?<=\*\*Fecha:\*\* ).*" "$info_file")
            local desc=$(grep -oP "(?<=\*\*Descripción:\*\* ).*" "$info_file")
            
            echo -e "${GREEN}${version_name}${NC} (${date})"
            echo -e "  ${desc}"
        else
            echo -e "${YELLOW}${version_name}${NC} (Sin información)"
        fi
    done
    
    echo -e "${BLUE}=============================================${NC}"
    echo -e "Para restaurar un punto de respaldo, usa:"
    echo -e "${YELLOW}./backup.sh restore NOMBRE_VERSION${NC}"
}

# Función para restaurar un punto de respaldo
restore_backup() {
    local version_name=$1
    local backup_dir="backups/${version_name}"
    local zip_file="backups/${version_name}.zip"
    
    if [ ! -d "$backup_dir" ] && [ ! -f "$zip_file" ]; then
        echo -e "${RED}✗ Punto de respaldo no encontrado: ${version_name}${NC}"
        echo -e "Usa './backup.sh list' para ver los puntos disponibles."
        return 1
    fi
    
    echo -e "${YELLOW}Restaurando punto de respaldo: ${version_name}${NC}"
    
    # Si tenemos solo el zip, extraerlo primero
    if [ ! -d "$backup_dir" ] && [ -f "$zip_file" ]; then
        echo -e "${YELLOW}Extrayendo archivo zip...${NC}"
        unzip -o "$zip_file" -d "backups/" > /dev/null
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ Error al extraer el archivo zip.${NC}"
            return 1
        fi
    fi
    
    # Crear respaldo del estado actual antes de restaurar
    local current_timestamp=$(date +"%Y%m%d%H%M%S")
    echo -e "${YELLOW}Creando respaldo del estado actual antes de restaurar...${NC}"
    mkdir -p "backups/pre_restore_${current_timestamp}"
    rsync -av --exclude="backups" --exclude=".git" --exclude="venv" --exclude="__pycache__" \
          --exclude="*.pyc" --exclude="database/dronevista.db" . "backups/pre_restore_${current_timestamp}/" >/dev/null
    
    # Restaurar archivos
    echo -e "${YELLOW}Restaurando archivos...${NC}"
    rsync -av --exclude="backups" --exclude=".git" --exclude="venv" --exclude="__pycache__" \
          --exclude="*.pyc" --exclude="database/dronevista.db" "${backup_dir}/" . >/dev/null
    
    echo -e "${GREEN}✓ Punto de respaldo restaurado: ${version_name}${NC}"
    echo -e "${YELLOW}Se ha creado un respaldo del estado previo: pre_restore_${current_timestamp}${NC}"
    
    # Mostrar INFO.md
    if [ -f "${backup_dir}/INFO.md" ]; then
        echo -e "${BLUE}=============================================${NC}"
        echo -e "${YELLOW}Información del punto restaurado:${NC}"
        cat "${backup_dir}/INFO.md"
        echo -e "${BLUE}=============================================${NC}"
    fi
}

# Punto de entrada principal
if [ $# -eq 0 ]; then
    echo -e "${BLUE}=============================================${NC}"
    echo -e "${BLUE}      GESTOR DE PUNTOS DE RESPALDO           ${NC}"
    echo -e "${BLUE}=============================================${NC}"
    echo -e "${YELLOW}Uso:${NC}"
    echo -e "  ./backup.sh create NOMBRE \"DESCRIPCIÓN\"   - Crear punto de respaldo"
    echo -e "  ./backup.sh list                         - Listar puntos disponibles"
    echo -e "  ./backup.sh restore NOMBRE               - Restaurar punto de respaldo"
    echo -e "${BLUE}=============================================${NC}"
    exit 0
fi

# Procesar comandos
case "$1" in
    create)
        if [ $# -lt 3 ]; then
            echo -e "${RED}✗ Error: Se requiere NOMBRE y DESCRIPCIÓN para crear un punto de respaldo.${NC}"
            echo -e "Ejemplo: ./backup.sh create v1.0 \"Versión inicial\""
            exit 1
        fi
        create_backup "$2" "$3"
        ;;
    list)
        list_backups
        ;;
    restore)
        if [ $# -lt 2 ]; then
            echo -e "${RED}✗ Error: Se requiere NOMBRE para restaurar un punto de respaldo.${NC}"
            echo -e "Ejemplo: ./backup.sh restore v1.0"
            exit 1
        fi
        restore_backup "$2"
        ;;
    *)
        echo -e "${RED}✗ Comando desconocido: $1${NC}"
        echo -e "Usa './backup.sh' sin argumentos para ver la ayuda."
        exit 1
        ;;
esac

exit 0