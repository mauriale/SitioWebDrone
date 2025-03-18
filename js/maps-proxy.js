/**
 * Proxy seguro para Google Maps API
 * Este módulo actúa como intermediario entre la aplicación y la API de Google Maps
 * para evitar exponer la clave API directamente en el frontend.
 */

// Configuración del proxy
const MAPS_PROXY = {
    // Clave API encapsulada (no accesible directamente desde el exterior)
    _apiKey: 'YOUR_GOOGLE_MAPS_API_KEY', // Reemplazar con tu clave real en el servidor
    
    // URL base para todas las APIs de Google Maps
    baseUrl: 'https://maps.googleapis.com',
    
    // Rutas disponibles para las diferentes APIs de Google Maps
    routes: {
        geocode: '/maps/api/geocode/json',
        places: '/maps/api/place/autocomplete/json',
        placeDetails: '/maps/api/place/details/json',
        directions: '/maps/api/directions/json'
    },
    
    /**
     * Método para realizar solicitudes a la API de Google Maps a través del proxy
     * @param {string} endpoint - El punto final de la API (debe estar en routes)
     * @param {Object} params - Parámetros de consulta para la solicitud
     * @returns {Promise} - Promesa que resuelve con los datos de la respuesta
     */
    request: async function(endpoint, params = {}) {
        // Verificar que el endpoint solicitado esté disponible
        if (!this.routes[endpoint]) {
            throw new Error(`Endpoint ${endpoint} no soportado`);
        }
        
        // Construir la URL con los parámetros y la clave API
        const url = this._buildUrl(this.routes[endpoint], params);
        
        try {
            // Realizar la solicitud
            const response = await fetch(url);
            
            // Verificar si la respuesta es correcta
            if (!response.ok) {
                throw new Error(`Error en la solicitud: ${response.status}`);
            }
            
            // Convertir la respuesta a JSON
            const data = await response.json();
            
            // Verificar si la API devolvió un error
            if (data.status && data.status !== 'OK' && data.status !== 'ZERO_RESULTS') {
                throw new Error(`Error de la API: ${data.status}, ${data.error_message || 'Sin mensaje de error'}`);
            }
            
            return data;
        } catch (error) {
            console.error('Error en el proxy de Maps:', error);
            throw error;
        }
    },
    
    /**
     * Método para construir la URL completa con parámetros y clave API
     * @private
     * @param {string} path - Ruta de la API
     * @param {Object} params - Parámetros de consulta
     * @returns {string} - URL completa para la solicitud
     */
    _buildUrl: function(path, params) {
        // Crear una nueva instancia de URLSearchParams
        const searchParams = new URLSearchParams();
        
        // Añadir todos los parámetros recibidos
        for (const [key, value] of Object.entries(params)) {
            searchParams.append(key, value);
        }
        
        // Añadir la clave API
        searchParams.append('key', this._apiKey);
        
        // Construir la URL completa
        return `${this.baseUrl}${path}?${searchParams.toString()}`;
    },
    
    /**
     * Método simplificado para realizar geocodificación de direcciones
     * @param {string} address - Dirección a geocodificar
     * @param {Object} options - Opciones adicionales como región, idioma, etc.
     * @returns {Promise} - Promesa que resuelve con los datos de geocodificación
     */
    geocode: function(address, options = {}) {
        return this.request('geocode', { 
            address: address,
            ...options
        });
    },
    
    /**
     * Método para obtener sugerencias de autocompletado de lugares
     * @param {string} input - Texto de entrada para autocompletar
     * @param {Object} options - Opciones como tipos, ubicación, radio, etc.
     * @returns {Promise} - Promesa que resuelve con las sugerencias
     */
    getPlaceSuggestions: function(input, options = {}) {
        return this.request('places', {
            input: input,
            ...options
        });
    },
    
    /**
     * Método para obtener detalles de un lugar específico
     * @param {string} placeId - ID del lugar de Google
     * @param {Object} options - Opciones adicionales
     * @returns {Promise} - Promesa que resuelve con los detalles del lugar
     */
    getPlaceDetails: function(placeId, options = {}) {
        return this.request('placeDetails', {
            place_id: placeId,
            ...options
        });
    },
    
    /**
     * Método para obtener direcciones entre dos puntos
     * @param {Object} origin - Punto de origen (objeto con lat/lng o string)
     * @param {Object} destination - Punto de destino (objeto con lat/lng o string)
     * @param {Object} options - Opciones adicionales
     * @returns {Promise} - Promesa que resuelve con las direcciones
     */
    getDirections: function(origin, destination, options = {}) {
        // Convertir coordenadas a formato de texto si es necesario
        const originParam = typeof origin === 'object' 
            ? `${origin.lat},${origin.lng}` 
            : origin;
            
        const destinationParam = typeof destination === 'object'
            ? `${destination.lat},${destination.lng}`
            : destination;
            
        return this.request('directions', {
            origin: originParam,
            destination: destinationParam,
            ...options
        });
    }
};

// Exponer el objeto MAPS_PROXY para uso en otros scripts
window.MAPS_PROXY = MAPS_PROXY;