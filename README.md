# DroneVista - Plataforma de Servicios de Drone

DroneVista es una plataforma completa para gestionar servicios de drone y reservas. Incluye un sitio web con un sistema de reservas conectado a una base de datos SQLite, una API REST y un panel de administración.

## Características

- 🌐 Sitio web responsive con video de fondo
- 📅 Sistema de reservas con calendario interactivo
- 🛢️ Base de datos SQLite para almacenamiento de datos
- 🔌 API REST para interacción con la base de datos
- 🔧 Panel de administración para gestionar reservas y servicios
- 📱 Adaptable a dispositivos móviles y de escritorio

## Requisitos del Sistema

- Python 3.7 o superior
- Pip (gestor de paquetes de Python)
- Navegador web moderno

## Instalación

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/mauriale/SitioWebDrone.git
   cd SitioWebDrone
   ```

2. **Instalar dependencias**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Configuración**:
   - Revisa y ajusta el archivo de configuración en `config/db_config.json` según tus necesidades.

## Uso

### Iniciar el Servidor

Para iniciar todos los servicios (API y servidor web) con un solo comando:

```bash
python start_server.py
```

Opciones disponibles:
- `-c, --config`: Especificar ruta al archivo de configuración personalizado
- `-d, --debug`: Iniciar en modo debug

### Inicializar la Base de Datos

La base de datos se inicializa automáticamente al iniciar el servidor. Si necesitas reiniciarla manualmente:

```bash
python database/create_db.py
```

### Acceso a los Servicios

Una vez iniciado el servidor, puedes acceder a:

- **Sitio Web**: http://localhost:5001
- **Panel de Administración**: http://localhost:5001/admin
- **API REST**: http://localhost:5000/api

## Estructura del Proyecto

```
SitioWebDrone/
├── api/
│   └── booking_api.py         # API REST
├── config/
│   └── db_config.json         # Configuración
├── css/
│   └── styles.css             # Estilos del sitio web
├── database/
│   ├── create_db.py           # Script para crear la base de datos
│   └── db_manager.py          # Gestor de la base de datos
├── js/
│   └── booking.js             # Lógica JavaScript para reservas
├── logs/                      # Directorio para logs
├── admin/
│   └── index.html             # Panel de administración
├── index.html                 # Página principal
├── requirements.txt           # Dependencias de Python
├── start_server.py            # Script para iniciar el servidor
└── README.md                  # Documentación
```

## API REST

La API proporciona los siguientes endpoints:

### Servicios

- `GET /api/services` - Obtener todos los servicios
- `GET /api/services/{id}` - Obtener un servicio específico
- `GET /api/services/{id}/available-times?date={date}` - Obtener horarios disponibles para una fecha

### Reservas

- `GET /api/bookings` - Obtener todas las reservas
- `GET /api/bookings/{id}` - Obtener una reserva específica
- `POST /api/bookings` - Crear una nueva reserva
- `PUT /api/bookings/{id}/status` - Actualizar estado de una reserva

## Configuración

El archivo `config/db_config.json` permite configurar:

- Rutas y parámetros de la base de datos
- Configuración del servidor API (host, puerto, CORS)
- Logging
- Notificaciones por correo electrónico
- Seguridad y autenticación

## Personalización

### Servicios

Para añadir o modificar servicios, puedes:

1. Editar la base de datos directamente
2. Modificar el archivo `database/create_db.py` y reinicializar la base de datos

### Diseño

Para personalizar el aspecto visual:

1. Editar el archivo `css/styles.css`
2. Modificar las plantillas HTML en `index.html` y `admin/index.html`
3. Reemplazar el video de fondo `tu-video-drone.mp4`

## Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT. Consulta el archivo LICENSE para más detalles.

## Soporte

Para soporte o informar problemas, por favor crea un issue en el repositorio de GitHub.

---

© 2025 DroneVista. Todos los derechos reservados.