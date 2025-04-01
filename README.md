# SitioWebDrone - Sistema de Reservas de Servicios de Drones

Este repositorio contiene un sistema completo de gestión de reservas para servicios de drones, con un backend en Flask y un frontend responsivo. El sistema permite a los clientes reservar diferentes tipos de servicios de filmación con drones, gestionar la disponibilidad y procesar pagos.

## 📋 Características

- **Diseño responsivo y moderno**
- **Sistema de reserva de servicios de drones**
- **Integración con Google Maps** (a través de un proxy seguro)
- **Autocompletado de direcciones**
- **Visualización de ubicaciones en el mapa**
- **Cálculo de precios** basado en servicios y duración
- **Sistema de gestión de disponibilidad** de horarios
- **API REST** para gestión de servicios y reservas
- **Panel de administración** para gestionar reservas
- **Base de datos SQLite** para almacenamiento de datos
- **Exportación de datos** a archivos JSON

## 🔧 Instalación

### Requisitos previos

- Python 3.7 o superior
- pip (administrador de paquetes de Python)

### Instalación automatizada

1. Clona el repositorio:
   ```bash
   git clone https://github.com/mauriale/SitioWebDrone.git
   cd SitioWebDrone
   ```

2. Ejecuta el script de instalación:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
   
   Este script:
   - Verifica la instalación de Python y pip
   - Ofrece crear un entorno virtual (recomendado)
   - Instala todas las dependencias desde requirements.txt
   - Crea los directorios necesarios
   - Inicializa la base de datos (si no existe)

### Instalación manual

1. Clona el repositorio:
   ```bash
   git clone https://github.com/mauriale/SitioWebDrone.git
   cd SitioWebDrone
   ```

2. Crea un entorno virtual (opcional pero recomendado):
   ```bash
   python -m venv venv
   source venv/bin/activate  # En Linux/Mac
   venv\\Scripts\\activate  # En Windows
   ```

3. Instala las dependencias:
   ```bash
   pip install -r requirements.txt
   ```

4. Crea los directorios necesarios:
   ```bash
   mkdir -p logs
   mkdir -p database/backup
   ```

5. Inicializa la base de datos:
   ```bash
   python database/create_db.py
   ```

## 🚀 Uso

### Iniciar el servidor

Para iniciar el servidor web y la API:

```bash
python start_server.py
```

Por defecto, el servidor se inicia en:
- API REST: http://localhost:5000/api
- Sitio web: http://localhost:5001

### Opciones de inicio

El script `start_server.py` acepta los siguientes parámetros:

- `-c, --config`: Ruta al archivo de configuración (por defecto: config/db_config.json)
- `-d, --debug`: Activa el modo debug

Ejemplo:
```bash
python start_server.py --debug
```

## 🗂️ Estructura del proyecto

```
SitioWebDrone/
├── admin/                 # Panel de administración
├── api/                   # API REST y proxy de Maps
│   ├── booking_api.py     # API para reservas
│   ├── maps_proxy.py      # Proxy seguro para Google Maps API
├── config/                # Archivos de configuración
│   └── db_config.json     # Configuración principal
├── css/                   # Estilos CSS
├── data/                  # Exportaciones de datos en JSON
├── database/              # Scripts y archivos de la base de datos
│   ├── create_db.py       # Script para crear la BD
│   ├── db_manager.py      # Clase para gestionar la BD
│   └── dronevista.db      # Base de datos SQLite
├── js/                    # JavaScript del frontend
├── logs/                  # Archivos de log
├── donaciones.html        # Página de donaciones
├── drone-website.html     # Plantilla alternativa
├── index.html             # Página principal
├── requirements.txt       # Dependencias de Python
├── start_server.py        # Script de inicio
└── tu-video-drone.mp4     # Video de fondo
```

## 🔍 Funcionalidades principales

### Sistema de reservas

El sistema permite a los usuarios:
- Seleccionar un tipo de servicio de drone
- Elegir fecha y hora disponibles
- Indicar duración del servicio
- Especificar ubicación (con integración de mapas)
- Ingresar información de contacto
- Ver precios en tiempo real
- Confirmar y procesar la reserva

### API REST

La API proporciona endpoints para:
- Obtener todos los servicios disponibles
- Consultar información detallada de servicios
- Verificar disponibilidad de horarios por fecha
- Crear nuevas reservas
- Gestionar estado de reservas existentes

### Base de datos

La estructura de la base de datos incluye:
- Tabla de servicios (tipos de servicio de drones)
- Horarios disponibles por servicio
- Equipamiento asociado a cada servicio
- Características y requisitos de servicios
- Tabla de reservas con toda la información del cliente

### Proxy seguro para Google Maps API

Se implementó un proxy seguro para proteger la clave API de Google Maps, evitando su exposición directa en el frontend. Este enfoque proporciona una capa adicional de seguridad al manejar todas las solicitudes a la API de Google Maps a través de un backend intermedio.

## ⚙️ Configuración

El archivo de configuración principal está en `config/db_config.json` y contiene:

```json
{
  "database": {
    "type": "sqlite",
    "path": "database/dronevista.db",
    "backup_path": "database/backup/",
    "auto_backup": true,
    "backup_frequency": "daily"
  },
  "api": {
    "host": "localhost",
    "port": 5000,
    "base_url": "/api",
    "debug": true,
    "cors_enabled": true,
    "allowed_origins": ["http://localhost", "https://dronevista.com"],
    "timeout": 30,
    "rate_limit": {
      "enabled": true,
      "requests_per_minute": 60
    }
  },
  "logging": {
    "level": "info",
    "file": "logs/api.log",
    "max_size": 10485760,
    "backup_count": 5,
    "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
  },
  "email": {
    "enabled": false,
    "smtp_server": "smtp.example.com",
    "smtp_port": 587,
    "use_tls": true,
    "username": "notifications@example.com",
    "password": "your-email-password",
    "from_email": "notifications@example.com",
    "admin_email": "admin@example.com"
  }
}
```

## 🔐 Seguridad

- **Proxy para Google Maps API:** La clave API está protegida en el backend
- **Validación de datos:** Todos los datos enviados por usuarios son validados
- **Seguridad CORS:** Control de acceso mediante CORS configurado
- **Logs detallados:** Sistema de logging para detectar problemas
- **Backups automáticos:** Respaldo de datos en archivos JSON

## 📊 Detalles técnicos

### Backend (API)

- Framework: Flask
- Base de datos: SQLite
- Middlewares: Flask-CORS

### Frontend

- HTML5, CSS3, JavaScript moderno
- Diseño responsive adaptable a todos los dispositivos
- Integración con Google Maps (a través de proxy)
- Validación de formularios en cliente y servidor

## 📝 Flujo de reservas

1. **Selección de servicio:** El usuario elige el tipo de servicio de drones
2. **Selección de fecha/hora:** Se muestran fechas y horarios disponibles
3. **Duración y ubicación:** El usuario especifica estos detalles
4. **Información personal:** Ingreso de datos de contacto
5. **Confirmación:** Resumen de la reserva y precio total
6. **Procesamiento:** El sistema registra la reserva y envía confirmación

## 🌐 Integración con Google Maps

El sistema incluye:
- Geocodificación (conversión de direcciones a coordenadas)
- Autocompletado de direcciones
- Visualización de ubicaciones en el mapa
- Cálculo de rutas y distancias

Todo se gestiona a través del proxy seguro en `api/maps_proxy.py`.

## 👨‍💻 Desarrollo

Para contribuir al desarrollo:

1. Crear una rama para nuevas características:
   ```bash
   git checkout -b nueva-caracteristica
   ```

2. Realizar cambios y probar localmente
3. Enviar pull request con descripción detallada de los cambios

## 📄 Licencia

[MIT License](LICENSE)

## 📞 Contacto

Para más información o soporte, contactar a [mauriale@gmail.com](mailto:mauriale@gmail.com)
