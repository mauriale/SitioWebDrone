// service-worker.js - Implementa funcionalidad offline para SitioWebDrone

const CACHE_NAME = 'dronevista-cache-v1';
const OFFLINE_URL = '/offline.html';

// Recursos estáticos para cachear inicialmente
const STATIC_RESOURCES = [
  '/',
  '/index.html',
  '/css/styles.css',
  '/js/booking.js',
  '/favicon.ico',
  '/favicon.svg',
  '/favicon.png',
  '/offline.html',
  'https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css',
  'https://cdn.jsdelivr.net/npm/flatpickr',
  'https://www.paypal.com/sdk/js?client-id=sb&currency=EUR'
];

// Evento de instalación - Precachea recursos estáticos
self.addEventListener('install', event => {
  console.log('[Service Worker] Instalando');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('[Service Worker] Cacheando recursos estáticos');
        return cache.addAll(STATIC_RESOURCES);
      })
      .then(() => {
        console.log('[Service Worker] Instalación completada');
        return self.skipWaiting();
      })
  );
});

// Evento de activación - Limpia caches antiguas
self.addEventListener('activate', event => {
  console.log('[Service Worker] Activando');
  
  event.waitUntil(
    caches.keys()
      .then(keyList => {
        return Promise.all(keyList.map(key => {
          if (key !== CACHE_NAME) {
            console.log('[Service Worker] Eliminando caché antigua:', key);
            return caches.delete(key);
          }
        }));
      })
      .then(() => {
        console.log('[Service Worker] Reclamando control de clientes');
        return self.clients.claim();
      })
  );
});

// Estrategia de caché: Network First con fallback a Cache
self.addEventListener('fetch', event => {
  // No interceptar peticiones a la API
  if (event.request.url.includes('/api/')) {
    return;
  }
  
  // Para las imágenes utilizamos Cache First
  if (
    event.request.destination === 'image' || 
    event.request.url.endsWith('.css') || 
    event.request.url.endsWith('.js')
  ) {
    event.respondWith(
      caches.match(event.request)
        .then(cachedResponse => {
          if (cachedResponse) {
            return cachedResponse;
          }
          
          return fetch(event.request)
            .then(response => {
              // Solo cachear respuestas válidas
              if (!response || response.status !== 200 || response.type !== 'basic') {
                return response;
              }
              
              const responseToCache = response.clone();
              
              caches.open(CACHE_NAME)
                .then(cache => {
                  cache.put(event.request, responseToCache);
                });
              
              return response;
            })
            .catch(error => {
              console.error('[Service Worker] Error en fetch:', error);
              return caches.match(OFFLINE_URL);
            });
        })
    );
    return;
  }
  
  // Para el resto de recursos, usamos Network First
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // Solo cachear respuestas válidas
        if (!response || response.status !== 200 || response.type !== 'basic') {
          return response;
        }
        
        const responseToCache = response.clone();
        
        caches.open(CACHE_NAME)
          .then(cache => {
            cache.put(event.request, responseToCache);
          });
        
        return response;
      })
      .catch(error => {
        console.error('[Service Worker] Error en fetch:', error);
        
        return caches.match(event.request)
          .then(cachedResponse => {
            if (cachedResponse) {
              return cachedResponse;
            }
            
            // Si el recurso no está en cache, mostrar la página offline
            if (event.request.mode === 'navigate') {
              return caches.match(OFFLINE_URL);
            }
            
            // Para recursos que no son HTML, simplemente fallar
            return new Response('Error de conexión', {
              status: 408,
              headers: { 'Content-Type': 'text/plain' }
            });
          });
      })
  );
});

// Evento de sincronización en segundo plano (para guardar reservas offline)
self.addEventListener('sync', event => {
  if (event.tag === 'sync-reservations') {
    event.waitUntil(syncReservations());
  }
});

// Función para sincronizar reservas pendientes
async function syncReservations() {
  try {
    // Obtener reservas pendientes de IndexedDB o localStorage
    const pendingReservations = await getPendingReservations();
    
    // Si hay reservas pendientes, enviarlas a la API
    if (pendingReservations && pendingReservations.length > 0) {
      for (const reservation of pendingReservations) {
        await sendReservationToAPI(reservation);
      }
      
      // Limpiar reservas pendientes después de sincronizar
      await clearPendingReservations();
    }
  } catch (error) {
    console.error('[Service Worker] Error al sincronizar reservas:', error);
  }
}

// Estas funciones serían implementadas para trabajar con IndexedDB
function getPendingReservations() {
  // TODO: Implementar para obtener reservas pendientes de IndexedDB
  return Promise.resolve([]);
}

function sendReservationToAPI(reservation) {
  // TODO: Implementar para enviar una reserva a la API
  return Promise.resolve();
}

function clearPendingReservations() {
  // TODO: Implementar para limpiar reservas pendientes de IndexedDB
  return Promise.resolve();
}
