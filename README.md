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
- **Service Worker** para funcionalidad offline
- **Diseño PWA** para instalación como aplicación

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

### Instalación en Windows

1. Clona el repositorio:
   ```bash
   git clone https://github.com/mauriale/SitioWebDrone.git
   cd SitioWebDrone
   ```

2. Ejecuta el script de instalación haciendo doble clic en `install.bat` o desde la línea de comandos:
   ```cmd
   install.bat
   ```
   
   Este script:
   - Verifica la instalación de Python y pip
   - Ofrece crear un entorno virtual (recomendado)
   - Instala todas las dependencias desde requirements.txt
   - Crea los directorios necesarios
   - Inicializa la base de datos (si no existe)

### Instalación en Linux/Mac

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

### Recreación de la base de datos (incluyendo el servicio de Telemetría)

Si deseas reinicializar la base de datos con todos los servicios, incluyendo el nuevo servicio de Telemetría:

En Windows:
```cmd
recreate_db.bat
```

En Linux/Mac:
```bash
chmod +x recreate_db.sh
./recreate_db.sh
```

## 🚀 Uso

### Iniciar el servidor

Para iniciar el servidor web y la API:

En Windows:
```cmd
run.bat
```

En Linux/Mac:
```bash
./run.sh
```

Por defecto, el servidor se inicia en:
- API REST: http://localhost:5000/api
- Sitio web: http://localhost:5001

### Opciones de inicio

El script de inicio acepta los siguientes parámetros:

- `-c, --config`: Ruta al archivo de configuración (por defecto: config/db_config.json)
- `-d, --debug`: Activa el modo debug

Ejemplo en Windows:
```cmd
run.bat --debug
```

Ejemplo en Linux/Mac:
```bash
./run.sh --debug
```

## 🔄 Gestión de versiones y respaldos

El proyecto incluye un sistema de puntos de respaldo para facilitar el desarrollo y las pruebas:

### Crear un punto de respaldo

En Windows:
```cmd
backup.bat create NombreVersion "Descripción de cambios"
```

En Linux/Mac:
```bash
./backup.sh create NombreVersion "Descripción de cambios"
```

### Listar puntos de respaldo disponibles

En Windows:
```cmd
backup.bat list
```

En Linux/Mac:
```bash
./backup.sh list
```

### Restaurar un punto de respaldo

En Windows:
```cmd
backup.bat restore NombreVersion
```

En Linux/Mac:
```bash
./backup.sh restore NombreVersion
```

### Punto de respaldo actual

Actualmente el proyecto dispone del punto de respaldo `Mejora-v1.3` que incluye:
- Service Worker para funcionalidad offline
- Soporte PWA con manifest.json
- Optimización de rendimiento con lazy loading
- Sistema de diseño con variables CSS
- Mejoras en el formulario con validación en tiempo real
- Mejora de estructura y navegación
- Optimizaciones SEO (sitemap.xml, robots.txt)

Para restaurar este punto:
```cmd
backup.bat restore Mejora-v1.3
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
├── backups/               # Puntos de respaldo del proyecto
├── manifest.json          # Configuración para PWA
├── service-worker.js      # Service Worker para funcionalidad offline
├── sitemap.xml            # Sitemap para SEO
├── robots.txt             # Configuración para rastreadores web
├── favicon.ico            # Favicon del sitio (icono de drone)
├── favicon.svg            # Versión vectorial del favicon
├── favicon.png            # Versión PNG del favicon
├── donaciones.html        # Página de donaciones
├── offline.html           # Página para mostrar cuando no hay conexión
├── index.html             # Página principal
├── requirements.txt       # Dependencias de Python
├── recreate_db.bat        # Script para recrear BD (Windows)
├── recreate_db.sh         # Script para recrear BD (Linux/Mac)
├── install.bat            # Script de instalación para Windows
├── install.sh             # Script de instalación para Linux/Mac
├── run.bat                # Script de inicio para Windows
├── run.sh                 # Script de inicio para Linux/Mac
├── backup.bat             # Script de respaldo para Windows
├── backup.sh              # Script de respaldo para Linux/Mac
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

### Funcionalidad Offline

Gracias al Service Worker, el sitio puede:
- Funcionar sin conexión a internet
- Almacenar reservas realizadas sin conexión
- Sincronizar datos cuando la conexión se restablece
- Mostrar una página offline cuando no hay conexión
- Proporcionar una experiencia de usuario mejorada

## 🔐 Seguridad

- **Proxy para Google Maps API:** La clave API está protegida en el backend
- **Validación de datos:** Todos los datos enviados por usuarios son validados
- **Seguridad CORS:** Control de acceso mediante CORS configurado
- **Logs detallados:** Sistema de logging para detectar problemas
- **Backups automáticos:** Respaldo de datos en archivos JSON

## 📅 Plan de mejoras (2025)

Se están implementando las siguientes mejoras en el sitio web:

### Fase 1: Optimización y Rendimiento ✅
- ✅ Optimización de imágenes y video
- ✅ Implementación de carga perezosa (lazy loading)
- ✅ Minificación de CSS y JavaScript
- ✅ Implementación de service worker para funcionalidad offline
- ✅ Configuración de HTTPS

### Fase 2: Diseño y Experiencia de Usuario ✅
- ✅ Sistema de diseño con variables CSS
- ✅ Mejora del formulario con validación en tiempo real
- ✅ Navegación mejorada con indicadores de sección activa
- ✅ Botón "volver arriba" para mejor navegación
- ✅ Optimizaciones específicas para dispositivos móviles

### Fase 3: Características Adicionales ⏳
- ⏳ Galería de proyectos anteriores
- ⏳ Sistema de reseñas de clientes
- ⏳ Blog con consejos y novedades
- ⏳ Soporte para múltiples idiomas (español/inglés)

### Fase 4: Características Avanzadas ⏳
- ⏳ Visualización 3D de modelos para telemetría
- ⏳ Chat en vivo para atención al cliente
- ⏳ Sistema de pagos mejorado (múltiples opciones)
- ⏳ Implementación PWA (Progressive Web App)

## 💻 Compatibilidad

El proyecto ha sido diseñado para funcionar en:
- 🪟 Windows 10/11
- 🐧 Linux (todas las distribuciones principales)
- 🍎 macOS (10.15+)

Y para ser visualizado correctamente en:
- 🖥️ Navegadores de escritorio (Chrome, Firefox, Edge, Safari)
- 📱 Navegadores móviles (iOS Safari, Android Chrome)
- 📱 Como aplicación instalada (PWA)

## 📄 Licencia

[MIT License](LICENSE)

## 📞 Contacto

Para más información o soporte, contactar a [mauriale@gmail.com](mailto:mauriale@gmail.com)