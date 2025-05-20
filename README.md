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

## 🚁 Servicios Disponibles

El sistema incluye los siguientes servicios de drones:

1. **Filmación en Montaña** - Tomas espectaculares de paisajes montañosos y actividades al aire libre
2. **Filmación en Playa** - Imágenes aéreas de costas, olas y eventos playeros
3. **Producción Audiovisual** - Servicios completos de filmación, edición y posproducción
4. **Servicios Corporativos** - Filmación para empresas, publicidad y eventos
5. **Telemetría y Modelado 3D** - Transformación de edificaciones y espacios en archivos 3D para impresiones o remodelaciones con software como Blender o Sketchup

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

### Recreación de la base de datos (incluyendo el servicio de Telemetría)

Si deseas reinicializar la base de datos con todos los servicios, incluyendo el nuevo servicio de Telemetría:

```bash
chmod +x recreate_db.sh
./recreate_db.sh
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
├── info/                  # Páginas informativas sobre servicios
│   └── telemetria-3d.html # Información sobre servicio de telemetría
├── js/                    # JavaScript del frontend
├── logs/                  # Archivos de log
├── favicon.ico            # Favicon del sitio (icono de drone)
├── favicon.svg            # Versión vectorial del favicon
├── favicon.png            # Versión PNG del favicon
├── donaciones.html        # Página de donaciones
├── drone-website.html     # Plantilla alternativa
├── index.html             # Página principal
├── requirements.txt       # Dependencias de Python
├── recreate_db.sh         # Script para recrear BD con todos los servicios
├── install.sh             # Script de instalación
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

## 🔐 Seguridad

- **Proxy para Google Maps API:** La clave API está protegida en el backend
- **Validación de datos:** Todos los datos enviados por usuarios son validados
- **Seguridad CORS:** Control de acceso mediante CORS configurado
- **Logs detallados:** Sistema de logging para detectar problemas
- **Backups automáticos:** Respaldo de datos en archivos JSON

## 📅 Plan de mejoras (2025)

Se están implementando las siguientes mejoras en el sitio web:

### Fase 1: Optimización y Rendimiento
- ✅ Optimización de imágenes y video
- ✅ Implementación de carga perezosa (lazy loading)
- ✅ Minificación de CSS y JavaScript
- ✅ Implementación de service worker para funcionalidad offline
- ✅ Configuración de HTTPS

### Fase 2: Diseño y Experiencia de Usuario
- ✅ Sistema de diseño con variables CSS
- ✅ Mejora del formulario con validación en tiempo real
- ✅ Navegación mejorada con indicadores de sección activa
- ✅ Botón "volver arriba" para mejor navegación
- ✅ Optimizaciones específicas para dispositivos móviles

### Fase 3: Características Adicionales
- ⏳ Galería de proyectos anteriores
- ⏳ Sistema de reseñas de clientes
- ⏳ Blog con consejos y novedades
- ⏳ Soporte para múltiples idiomas (español/inglés)

### Fase 4: Características Avanzadas
- ⏳ Visualización 3D de modelos para telemetría
- ⏳ Chat en vivo para atención al cliente
- ⏳ Sistema de pagos mejorado (múltiples opciones)
- ⏳ Implementación PWA (Progressive Web App)

## 🔄 Puntos de Respaldo

Para facilitar la continuación del desarrollo en caso de interrupciones, se han establecido los siguientes puntos de respaldo:

1. **Base-v1.0**: Versión original antes de las mejoras
2. **Mejora-v1.1**: Optimización de imágenes y rendimiento básico
3. **Mejora-v1.2**: Implementación de service worker y funcionalidad offline
4. **Mejora-v1.3**: Sistema de diseño y variables CSS
5. **Mejora-v1.4**: Mejoras de formulario y validación
6. **Mejora-v1.5**: Optimizaciones para móviles y navegación mejorada
7. **Mejora-v1.6**: Implementación de galería y portfolio
8. **Mejora-v1.7**: Implementación de testimonios y reseñas

## 📄 Licencia

[MIT License](LICENSE)

## 📞 Contacto

Para más información o soporte, contactar a [mauriale@gmail.com](mailto:mauriale@gmail.com)