# Sitio Web Drone - Sistema de Reservas con Maps API Seguro

Este repositorio contiene el código para un sitio web de servicios de drones con sistema de reservas, utilizando un proxy seguro para Google Maps API.

## Características

- Diseño responsivo y moderno
- Sistema de reserva de servicios de drones
- Integración con Google Maps (a través de un proxy seguro)
- Autocompletado de direcciones
- Visualización de ubicaciones en el mapa
- Cálculo de precios basado en servicios y duración
- Sistema de gestión de disponibilidad de horarios
- Procesamiento de pagos (preparado para integración con PayPal)

## Estructura de Archivos

- `index.html` - Página principal
- `css/styles.css` - Estilos del sitio
- `js/booking.js` - Lógica principal del sistema de reservas
- `js/maps-proxy.js` - Proxy seguro para Google Maps API
- `video/drone-background.mp4` - Video de fondo (no incluido en el repositorio)

## Proxy Seguro para Google Maps API

Se implementó un proxy seguro para proteger la clave API de Google Maps, evitando su exposición directa en el frontend. Este enfoque proporciona una capa adicional de seguridad al manejar todas las solicitudes a la API de Google Maps a través de un backend intermedio.

### Cómo funciona el proxy:

1. El frontend nunca ve la API key directamente
2. Todas las solicitudes a Google Maps API se canalizan a través del servidor proxy
3. El servidor proxy añade la API key a las solicitudes
4. Las respuestas se devuelven al cliente sin exponer información sensible

### Implementación:

El módulo `maps-proxy.js` proporciona métodos para interactuar con las diferentes APIs de Google Maps:

- Geocodificación (obtener coordenadas a partir de direcciones)
- Autocompletado de lugares
- Detalles de lugares
- Direcciones entre dos puntos

## Configuración

Para instalar y configurar el proyecto:

1. Clonar el repositorio
2. Configurar la clave API de Google Maps en el archivo `js/maps-proxy.js`
3. Configurar la URL del backend en las constantes `API_BASE_URL` y `MAPS_PROXY_URL` en `js/booking.js`
4. Servir los archivos con un servidor web (por ejemplo, Apache, Nginx o cualquier hosting estático)

### Configuración de la API Key:

En un entorno de producción, la API key debería almacenarse únicamente en el servidor backend y nunca en el código del cliente.

## Consideraciones de Seguridad

- La clave API de Google Maps nunca se expone directamente en el cliente
- Todas las llamadas a la API pasan por el proxy del servidor
- Se implementan restricciones por dominio y referrer en la consola de Google Cloud Platform
- El código incluye mecanismos para prevenir solicitudes excesivas (throttling)

## Desarrollo

Para trabajar en el desarrollo:

1. Modificar los archivos HTML, CSS o JavaScript según sea necesario
2. Para cambiar la configuración del proxy de Maps, editar el archivo `js/maps-proxy.js`
3. Para modificar la lógica de reservas, editar `js/booking.js`

## Licencia

[MIT License](LICENSE)

## Contacto

Para más información o soporte, contactar a [mauriale@gmail.com](mailto:mauriale@gmail.com)