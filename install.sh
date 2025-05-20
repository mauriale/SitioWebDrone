#!/bin/bash

# Colores para los mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}      INSTALADOR DE SITIOWEBDRONE            ${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""
echo -e "Este script instalará todas las dependencias necesarias"
echo -e "para ejecutar el sistema SitioWebDrone localmente."
echo ""

# Verificar que Python está instalado
echo -e "${YELLOW}Verificando instalación de Python...${NC}"
if command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
    echo -e "${GREEN}✓ Python 3 encontrado.${NC}"
else
    if command -v python &>/dev/null; then
        PYTHON_CMD="python"
        # Verificar versión de Python
        PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')
        PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
        PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)
        
        if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 7 ]); then
            echo -e "${RED}✗ Se requiere Python 3.7 o superior. Versión actual: $PYTHON_VERSION${NC}"
            echo -e "Por favor, instala una versión compatible de Python e intenta nuevamente."
            exit 1
        fi
        
        echo -e "${GREEN}✓ Python $PYTHON_VERSION encontrado.${NC}"
    else
        echo -e "${RED}✗ Python no está instalado.${NC}"
        echo -e "Por favor, instala Python 3.7 o superior e intenta nuevamente."
        echo -e "Puedes descargarlo desde: https://www.python.org/downloads/"
        exit 1
    fi
fi

# Verificar que pip está instalado
echo -e "${YELLOW}Verificando instalación de pip...${NC}"
if command -v pip3 &>/dev/null; then
    PIP_CMD="pip3"
    echo -e "${GREEN}✓ pip3 encontrado.${NC}"
elif command -v pip &>/dev/null; then
    PIP_CMD="pip"
    echo -e "${GREEN}✓ pip encontrado.${NC}"
else
    echo -e "${RED}✗ pip no está instalado.${NC}"
    echo -e "Intentando instalar pip..."
    
    if [ "$PYTHON_CMD" = "python3" ]; then
        # Para sistemas tipo Unix/Linux
        if command -v apt-get &>/dev/null; then
            sudo apt-get update
            sudo apt-get install -y python3-pip
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y python3-pip
        elif command -v yum &>/dev/null; then
            sudo yum install -y python3-pip
        elif command -v brew &>/dev/null; then
            brew install python3 # Homebrew instala pip3 con python3
        else
            echo -e "${RED}No se pudo instalar pip automáticamente.${NC}"
            echo -e "Por favor, instala pip manualmente e intenta nuevamente."
            exit 1
        fi
    else
        echo -e "${RED}No se pudo determinar cómo instalar pip.${NC}"
        echo -e "Por favor, instala pip manualmente e intenta nuevamente."
        exit 1
    fi
    
    # Verificar si la instalación fue exitosa
    if command -v pip3 &>/dev/null; then
        PIP_CMD="pip3"
        echo -e "${GREEN}✓ pip3 instalado correctamente.${NC}"
    elif command -v pip &>/dev/null; then
        PIP_CMD="pip"
        echo -e "${GREEN}✓ pip instalado correctamente.${NC}"
    else
        echo -e "${RED}✗ No se pudo instalar pip.${NC}"
        echo -e "Por favor, instala pip manualmente e intenta nuevamente."
        exit 1
    fi
fi

# Preguntar si se desea crear un entorno virtual
echo ""
echo -e "${YELLOW}¿Deseas crear un entorno virtual para la instalación? (recomendado)${NC}"
echo -e "Esto mantiene las dependencias aisladas del sistema. [S/n]"
read -r create_venv

if [[ $create_venv =~ ^[Nn]$ ]]; then
    echo -e "${BLUE}Continuando sin entorno virtual...${NC}"
    USE_VENV=false
else
    echo -e "${YELLOW}Verificando herramientas para entornos virtuales...${NC}"
    
    # Verificar si venv está disponible
    if $PYTHON_CMD -c "import venv" &>/dev/null; then
        echo -e "${GREEN}✓ Módulo venv disponible.${NC}"
        VENV_MODULE="venv"
    elif $PYTHON_CMD -c "import virtualenv" &>/dev/null; then
        echo -e "${GREEN}✓ Módulo virtualenv disponible.${NC}"
        VENV_MODULE="virtualenv"
    else
        echo -e "${YELLOW}! Módulos venv/virtualenv no encontrados. Intentando instalar...${NC}"
        $PIP_CMD install virtualenv
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ No se pudo instalar virtualenv.${NC}"
            echo -e "Continuando sin entorno virtual."
            USE_VENV=false
        else
            echo -e "${GREEN}✓ virtualenv instalado correctamente.${NC}"
            VENV_MODULE="virtualenv"
        fi
    fi
    
    if [ -n "$VENV_MODULE" ]; then
        USE_VENV=true
        # Crear entorno virtual
        echo -e "${YELLOW}Creando entorno virtual...${NC}"
        
        if [ "$VENV_MODULE" = "venv" ]; then
            $PYTHON_CMD -m venv venv
        else
            $PYTHON_CMD -m virtualenv venv
        fi
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ Error al crear el entorno virtual.${NC}"
            echo -e "Continuando sin entorno virtual."
            USE_VENV=false
        else
            echo -e "${GREEN}✓ Entorno virtual creado correctamente.${NC}"
            
            # Activar entorno virtual
            echo -e "${YELLOW}Activando entorno virtual...${NC}"
            source venv/bin/activate || source venv/Scripts/activate
            
            if [ $? -ne 0 ]; then
                echo -e "${RED}✗ Error al activar el entorno virtual.${NC}"
                echo -e "Continuando sin entorno virtual."
                USE_VENV=false
            else
                echo -e "${GREEN}✓ Entorno virtual activado.${NC}"
                # Actualizar comandos para el entorno virtual
                PYTHON_CMD="python"
                PIP_CMD="pip"
            fi
        fi
    fi
fi

# Instalar dependencias
echo ""
echo -e "${YELLOW}Instalando dependencias desde requirements.txt...${NC}"

if [ -f "requirements.txt" ]; then
    $PIP_CMD install -r requirements.txt
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Error al instalar dependencias.${NC}"
        echo -e "Por favor, verifica el archivo requirements.txt y tu conexión a internet."
        exit 1
    else
        echo -e "${GREEN}✓ Dependencias instaladas correctamente.${NC}"
    fi
else
    echo -e "${RED}✗ No se encontró el archivo requirements.txt${NC}"
    echo -e "Creando un archivo requirements.txt básico..."
    
    cat > requirements.txt << EOF
flask==2.0.1
flask-cors==3.0.10
requests==2.26.0
python-dotenv==0.19.1
werkzeug==2.0.1
gunicorn==20.1.0
EOF
    
    echo -e "${GREEN}✓ Archivo requirements.txt creado.${NC}"
    
    # Instalar las dependencias creadas
    $PIP_CMD install -r requirements.txt
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Error al instalar dependencias.${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ Dependencias básicas instaladas correctamente.${NC}"
    fi
fi

# Crear directorios necesarios
echo ""
echo -e "${YELLOW}Creando directorios necesarios...${NC}"

mkdir -p logs data config

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Error al crear directorios.${NC}"
else
    echo -e "${GREEN}✓ Directorios creados correctamente.${NC}"
fi

# Crear archivo de configuración si no existe
if [ ! -d "config" ]; then
    mkdir -p config
fi

if [ ! -f "config/db_config.json" ]; then
    echo -e "${YELLOW}Creando archivo de configuración predeterminado...${NC}"
    
    cat > config/db_config.json << EOF
{
    "database": {
        "path": "database/dronevista.db",
        "backup_path": "data/backup"
    },
    "api": {
        "port": 5000,
        "debug": false,
        "cors_origins": ["http://localhost:5001", "http://127.0.0.1:5001"]
    },
    "web": {
        "port": 5001,
        "debug": false
    },
    "maps": {
        "api_key": "YOUR_GOOGLE_MAPS_API_KEY",
        "proxy_enabled": true
    }
}
EOF
    
    echo -e "${GREEN}✓ Archivo de configuración creado.${NC}"
else
    echo -e "${GREEN}✓ Archivo de configuración existente.${NC}"
fi

# Inicializar la base de datos
echo ""
echo -e "${YELLOW}Verificando base de datos...${NC}"

if [ ! -d "database" ]; then
    mkdir -p database
fi

# Comprobar si existe el archivo dronevista.db
if [ ! -f "database/dronevista.db" ]; then
    echo -e "${YELLOW}Base de datos no encontrada. Inicializando...${NC}"
    
    # Verificar si existe el script create_db.py
    if [ -f "database/create_db.py" ]; then
        $PYTHON_CMD database/create_db.py
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ Error al inicializar la base de datos.${NC}"
        else
            echo -e "${GREEN}✓ Base de datos inicializada correctamente.${NC}"
        fi
    else
        echo -e "${RED}✗ No se encontró el script de creación de la base de datos.${NC}"
        echo -e "Será necesario crear la base de datos manualmente."
    fi
else
    echo -e "${GREEN}✓ Base de datos existente encontrada.${NC}"
fi

# Crear script de inicio rápido
echo ""
echo -e "${YELLOW}Creando script de inicio rápido...${NC}"

cat > run.sh << 'EOF'
#!/bin/bash

# Colores para los mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar si estamos en un entorno virtual
if [ -d "venv" ]; then
    echo -e "${YELLOW}Activando entorno virtual...${NC}"
    source venv/bin/activate || source venv/Scripts/activate
fi

# Iniciar el servidor
echo -e "${BLUE}Iniciando SitioWebDrone...${NC}"
echo -e "${BLUE}=============================================${NC}"
echo -e "${YELLOW}API:${NC} http://localhost:5000/api"
echo -e "${YELLOW}Web:${NC} http://localhost:5001"
echo -e "${BLUE}=============================================${NC}"
echo -e "Presiona Ctrl+C para detener el servidor"
echo ""

python start_server.py $@

# Si estamos en un entorno virtual, desactivarlo al finalizar
if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
fi
EOF

chmod +x run.sh
echo -e "${GREEN}✓ Script de inicio rápido creado.${NC}"

# Mensaje final
echo ""
echo -e "${BLUE}=============================================${NC}"
echo -e "${GREEN}¡Instalación completada con éxito!${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""
echo -e "Para iniciar el servidor, ejecuta:"
echo -e "${YELLOW}./run.sh${NC}"
echo ""
echo -e "Si quieres activar el modo debug:"
echo -e "${YELLOW}./run.sh --debug${NC}"
echo ""

if [ "$USE_VENV" = true ]; then
    echo -e "Se ha creado un entorno virtual en la carpeta 'venv'."
    echo -e "Para activarlo manualmente en el futuro, ejecuta:"
    echo -e "${YELLOW}source venv/bin/activate${NC}  # En Linux/Mac"
    echo -e "${YELLOW}venv\\Scripts\\activate${NC}       # En Windows"
    echo ""
fi

echo -e "¡Gracias por instalar SitioWebDrone!"
