// Configuración
const API_BASE_URL = 'http://localhost:5000/api';

// Variables globales
let services = [];
let selectedService = null;
let flatpickrInstance = null;
let availableTimes = [];
let map = null;
let marker = null;
let autocomplete = null;

document.addEventListener('DOMContentLoaded', function() {
  // Función para simular el efecto de vuelo del drone
  function simulateDroneFlight() {
    const videoBackground = document.querySelector('.video-background');
    let posX = 0;
    let posY = 0;
    let directionX = 1;
    let directionY = 1;
    
    setInterval(() => {
      if (Math.random() > 0.95) directionX *= -1;
      if (Math.random() > 0.95) directionY *= -1;
      
      posX += directionX * 0.1;
      posY += directionY * 0.1;
      
      posX = Math.max(-5, Math.min(5, posX));
      posY = Math.max(-5, Math.min(5, posY));
      
      videoBackground.style.transform = `translate(${posX}px, ${posY}px) scale(1.1)`;
    }, 50);
  }
  
  // Iniciar efecto de vuelo
  simulateDroneFlight();
  
  // Manejar el botón de menú
  const menuBtn = document.getElementById('menuBtn');
  const navLinks = document.getElementById('navLinks');
  
  menuBtn.addEventListener('click', function() {
    navLinks.classList.toggle('active');
  });
  
  // Cargar servicios
  loadServices();
  
  // Inicializar el formulario
  initReservationForm();
  
  // Inicializar Google Maps
  initGoogleMaps();
});

// Función para inicializar Google Maps
function initGoogleMaps() {
  const locationInput = document.getElementById('location');
  const latitudeInput = document.getElementById('latitude');
  const longitudeInput = document.getElementById('longitude');
  const mapContainer = document.getElementById('map-container');
  
  // Posición inicial (centrada en España)
  const defaultPosition = { lat: 40.416775, lng: -3.703790 };
  
  // Inicializar el mapa
  map = new google.maps.Map(mapContainer, {
    center: defaultPosition,
    zoom: 15,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    mapTypeControl: false,
    streetViewControl: false,
    styles: [
      { elementType: 'geometry', stylers: [{ color: '#242f3e' }] },
      { elementType: 'labels.text.stroke', stylers: [{ color: '#242f3e' }] },
      { elementType: 'labels.text.fill', stylers: [{ color: '#746855' }] },
      {
        featureType: 'administrative.locality',
        elementType: 'labels.text.fill',
        stylers: [{ color: '#d59563' }]
      },
      {
        featureType: 'poi',
        elementType: 'labels.text.fill',
        stylers: [{ color: '#d59563' }]
      },
      {
        featureType: 'road',
        elementType: 'geometry',
        stylers: [{ color: '#38414e' }]
      },
      {
        featureType: 'road',
        elementType: 'geometry.stroke',
        stylers: [{ color: '#212a37' }]
      },
      {
        featureType: 'road',
        elementType: 'labels.text.fill',
        stylers: [{ color: '#9ca5b3' }]
      },
      {
        featureType: 'water',
        elementType: 'geometry',
        stylers: [{ color: '#17263c' }]
      },
      {
        featureType: 'water',
        elementType: 'labels.text.fill',
        stylers: [{ color: '#515c6d' }]
      },
      {
        featureType: 'water',
        elementType: 'labels.text.stroke',
        stylers: [{ color: '#17263c' }]
      }
    ]
  });
  
  // Crear el marcador
  marker = new google.maps.Marker({
    position: defaultPosition,
    map: null,
    draggable: true,
    animation: google.maps.Animation.DROP
  });
  
  // Inicializar autocompletado
  autocomplete = new google.maps.places.Autocomplete(locationInput, {
    fields: ['formatted_address', 'geometry', 'name'],
    types: ['address', 'establishment']
  });
  
  // Evento cuando se selecciona un lugar del autocompletado
  autocomplete.addListener('place_changed', function() {
    const place = autocomplete.getPlace();
    
    if (!place.geometry) {
      return;
    }
    
    // Mostrar el mapa
    mapContainer.style.display = 'block';
    
    // Actualizar el mapa y el marcador
    map.setCenter(place.geometry.location);
    marker.setPosition(place.geometry.location);
    marker.setMap(map);
    
    // Guardar coordenadas
    latitudeInput.value = place.geometry.location.lat();
    longitudeInput.value = place.geometry.location.lng();
    
    // Optimizar visualización del mapa
    setTimeout(() => {
      google.maps.event.trigger(map, 'resize');
    }, 100);
  });
  
  // Permitir actualizar la ubicación al arrastrar el marcador
  google.maps.event.addListener(marker, 'dragend', function() {
    const position = marker.getPosition();
    latitudeInput.value = position.lat();
    longitudeInput.value = position.lng();
    
    // Obtener la dirección a partir de las coordenadas
    const geocoder = new google.maps.Geocoder();
    geocoder.geocode({ location: position }, function(results, status) {
      if (status === 'OK' && results[0]) {
        locationInput.value = results[0].formatted_address;
      }
    });
  });
  
  // Mostrar el mapa cuando el campo recibe foco
  locationInput.addEventListener('focus', function() {
    if (latitudeInput.value && longitudeInput.value) {
      mapContainer.style.display = 'block';
      
      // Optimizar visualización del mapa
      setTimeout(() => {
        google.maps.event.trigger(map, 'resize');
      }, 100);
    }
  });
}

// Función para cargar servicios desde la API
async function loadServices() {
  try {
    const response = await fetch(`${API_BASE_URL}/services`);
    const data = await response.json();
    
    if (data.success) {
      services = data.services;
      renderServices();
      populateServiceSelect();
    } else {
      console.error('Error al cargar servicios:', data.error);
    }
  } catch (error) {
    console.error('Error al conectar con la API:', error);
    // Fallback - Mostrar servicios de demostración
    renderDemoServices();
  } finally {
    document.getElementById('servicesSpinner').style.display = 'none';
  }
}

// Función para renderizar servicios en la página
function renderServices() {
  const servicesContainer = document.getElementById('servicios');
  
  // Mantener el spinner si existe
  const spinner = document.getElementById('servicesSpinner');
  
  // Limpiar contenido excepto el spinner
  while (servicesContainer.firstChild) {
    if (servicesContainer.firstChild === spinner) {
      break;
    }
    servicesContainer.removeChild(servicesContainer.firstChild);
  }
  
  // Renderizar cada servicio
  services.forEach(service => {
    const serviceCard = document.createElement('div');
    serviceCard.className = 'service-card animate-in';
    serviceCard.dataset.serviceId = service.id;
    
    serviceCard.innerHTML = `
      <div class="service-icon">${service.icon}</div>
      <h3 class="service-title">${service.name}</h3>
      <p class="service-description">${service.description}</p>
      <p class="service-price">Desde €${service.price_per_hour}/hora</p>
    `;
    
    // Añadir evento click para seleccionar servicio
    serviceCard.addEventListener('click', () => {
      selectService(service.id);
      scrollToReservation();
    });
    
    servicesContainer.appendChild(serviceCard);
  });
}

// Función para renderizar servicios de demostración (fallback)
function renderDemoServices() {
  services = [
    {
      id: 'montaña',
      name: 'Filmación en Montaña',
      description: 'Tomas espectaculares de paisajes montañosos, senderos y actividades al aire libre.',
      icon: '🏔️',
      price_per_hour: 120,
      min_duration: 2,
      max_duration: 8
    },
    {
      id: 'playa',
      name: 'Filmación en Playa',
      description: 'Imágenes aéreas impresionantes de costas, olas y eventos playeros.',
      icon: '🏖️',
      price_per_hour: 100,
      min_duration: 1,
      max_duration: 6
    },
    {
      id: 'produccion',
      name: 'Producción Audiovisual',
      description: 'Servicios completos de filmación, edición y posproducción para crear contenido de alta calidad.',
      icon: '🎬',
      price_per_hour: 150,
      min_duration: 3,
      max_duration: 10
    },
    {
      id: 'corporativo',
      name: 'Servicios Corporativos',
      description: 'Filmación para empresas, publicidad, eventos y proyectos especiales.',
      icon: '🏢',
      price_per_hour: 180,
      min_duration: 4,
      max_duration: 12
    }
  ];
  
  renderServices();
  populateServiceSelect();
}

// Función para llenar el select de servicios
function populateServiceSelect() {
  const serviceSelect = document.getElementById('service');
  
  // Mantener la opción default
  serviceSelect.innerHTML = '<option value="">Selecciona un servicio</option>';
  
  // Añadir servicios
  services.forEach(service => {
    const option = document.createElement('option');
    option.value = service.id;
    option.textContent = `${service.name} - €${service.price_per_hour}/hora`;
    serviceSelect.appendChild(option);
  });
  
  // Añadir evento de cambio
  serviceSelect.addEventListener('change', function() {
    const serviceId = this.value;
    if (serviceId) {
      selectService(serviceId);
    } else {
      // Deseleccionar servicio
      selectedService = null;
      updateDurationOptions();
      updatePriceSummary();
    }
  });
}

// Función para seleccionar un servicio
function selectService(serviceId) {
  // Quitar clase selected de todos los servicios
  document.querySelectorAll('.service-card').forEach(card => {
    card.classList.remove('selected');
  });
  
  // Añadir clase selected al servicio seleccionado
  const selectedCard = document.querySelector(`.service-card[data-service-id="${serviceId}"]`);
  if (selectedCard) {
    selectedCard.classList.add('selected');
  }
  
  // Actualizar el select de servicios
  const serviceSelect = document.getElementById('service');
  serviceSelect.value = serviceId;
  
  // Guardar servicio seleccionado
  selectedService = services.find(service => service.id === serviceId);
  
  // Actualizar opciones de duración
  updateDurationOptions();
  
  // Actualizar fecha si está seleccionada
  const dateInput = document.getElementById('date');
  if (dateInput.value) {
    updateAvailableTimes(new Date(flatpickrInstance.selectedDates[0]));
  }
  
  // Actualizar resumen de precios
  updatePriceSummary();
}

// Función para inicializar el formulario de reserva
function initReservationForm() {
  // Inicializar el selector de fecha con Flatpickr
  const dateInput = document.getElementById('date');
  flatpickrInstance = flatpickr(dateInput, {
    minDate: "today",
    maxDate: new Date().fp_incr(90), // 90 días en el futuro
    disable: [
      function(date) {
        // Deshabilitar domingos
        return date.getDay() === 0;
      }
    ],
    locale: {
      firstDayOfWeek: 1,
      weekdays: {
        shorthand: ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'],
        longhand: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
      },
      months: {
        shorthand: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
        longhand: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
      }
    },
    dateFormat: "d/m/Y",
    onChange: function(selectedDates, dateStr, instance) {
      if (selectedDates.length > 0) {
        updateAvailableTimes(selectedDates[0]);
      }
    }
  });
  
  // Añadir evento change al select de duración
  document.getElementById('duration').addEventListener('change', updatePriceSummary);
  
  // Manejar el envío del formulario
  const reservationForm = document.getElementById('reservationForm');
  reservationForm.addEventListener('submit', handleFormSubmit);
}

// Función para actualizar opciones de duración basadas en el servicio seleccionado
function updateDurationOptions() {
  const durationSelect = document.getElementById('duration');
  durationSelect.innerHTML = '<option value="">Selecciona duración</option>';
  
  if (!selectedService) return;
  
  const { min_duration, max_duration } = selectedService;
  
  for (let i = min_duration; i <= max_duration; i++) {
    const option = document.createElement('option');
    option.value = i;
    option.textContent = `${i} hora${i > 1 ? 's' : ''}`;
    durationSelect.appendChild(option);
  }
}

// Función para actualizar horarios disponibles
async function updateAvailableTimes(selectedDate) {
  const startTimeSelect = document.getElementById('start-time');
  
  // Limpiar opciones existentes
  startTimeSelect.innerHTML = '<option value="">Selecciona la hora</option>';
  
  if (!selectedService) return;
  
  // Formatear fecha para la API (dd/mm/yyyy)
  const formattedDate = `${selectedDate.getDate().toString().padStart(2, '0')}/${(selectedDate.getMonth() + 1).toString().padStart(2, '0')}/${selectedDate.getFullYear()}`;
  
  try {
    // Consultar horarios disponibles a la API
    const response = await fetch(`${API_BASE_URL}/services/${selectedService.id}/available-times?date=${formattedDate}`);
    const data = await response.json();
    
    if (data.success) {
      availableTimes = data.availableTimes || [];
      
      // Si no hay horarios disponibles, mostrar mensaje
      if (availableTimes.length === 0) {
        const emptyOption = document.createElement('option');
        emptyOption.value = '';
        emptyOption.disabled = true;
        emptyOption.textContent = 'No hay horarios disponibles para esta fecha';
        startTimeSelect.appendChild(emptyOption);
      } else {
        // Añadir horarios disponibles
        availableTimes.forEach(time => {
          const option = document.createElement('option');
          option.value = time;
          option.text = time;
          startTimeSelect.appendChild(option);
        });
      }
    } else {
      console.error('Error al obtener horarios disponibles:', data.error);
    }
  } catch (error) {
    console.error('Error al conectar con la API:', error);
    
    // Fallback - Mostrar horarios genéricos
    const defaultTimes = selectedService.available_times || 
      ['08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00'];
    
    defaultTimes.forEach(time => {
      const option = document.createElement('option');
      option.value = time;
      option.text = time;
      startTimeSelect.appendChild(option);
    });
  }
}

// Función para actualizar el resumen de precios
function updatePriceSummary() {
  const priceSummary = document.getElementById('priceSummary');
  
  if (!selectedService) {
    priceSummary.style.display = 'none';
    return;
  }
  
  const duration = parseInt(document.getElementById('duration').value) || 0;
  const pricePerHour = selectedService.price_per_hour;
  const totalPrice = pricePerHour * duration;
  
  // Actualizar elementos del resumen
  document.getElementById('summaryServiceName').textContent = selectedService.name;
  document.getElementById('summaryPricePerHour').textContent = pricePerHour;
  document.getElementById('summaryDuration').textContent = duration;
  document.getElementById('summaryTotal').textContent = totalPrice;
  
  // Mostrar resumen si hay una duración seleccionada
  priceSummary.style.display = duration > 0 ? 'block' : 'none';
}

// Función para manejar el envío del formulario
async function handleFormSubmit(e) {
  e.preventDefault();
  
  // Mostrar spinner y ocultar mensajes
  const spinner = document.getElementById('reservationSpinner');
  const confirmationMessage = document.getElementById('confirmationMessage');
  const errorMessage = document.getElementById('errorMessage');
  const form = document.getElementById('reservationForm');
  
  spinner.style.display = 'block';
  confirmationMessage.style.display = 'none';
  errorMessage.style.display = 'none';
  
  // Validar formulario
  if (!validateForm()) {
    spinner.style.display = 'none';
    return;
  }
  
  // Obtener datos del formulario
  const formData = new FormData(form);
  const bookingData = {};
  
  for (const [key, value] of formData.entries()) {
    bookingData[key] = value;
  }
  
  try {
    // Enviar datos a la API
    const response = await fetch(`${API_BASE_URL}/bookings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(bookingData)
    });
    
    const data = await response.json();
    
    if (data.success) {
      // Mostrar mensaje de confirmación
      document.getElementById('bookingNumber').textContent = data.booking_id;
      confirmationMessage.style.display = 'block';
      form.style.display = 'none';
    } else {
      // Mostrar mensaje de error
      document.getElementById('errorText').textContent = data.error || 'Error al procesar la reserva. Por favor, intenta nuevamente.';
      errorMessage.style.display = 'block';
    }
  } catch (error) {
    console.error('Error al conectar con la API:', error);
    document.getElementById('errorText').textContent = 'Error de conexión. Por favor, intenta nuevamente más tarde.';
    errorMessage.style.display = 'block';
  } finally {
    spinner.style.display = 'none';
  }
}

// Función para validar el formulario
function validateForm() {
  const requiredFields = ['service', 'date', 'start-time', 'duration', 'name', 'email', 'phone', 'location'];
  let isValid = true;
  
  requiredFields.forEach(field => {
    const element = document.getElementById(field);
    if (!element.value) {
      element.classList.add('invalid');
      isValid = false;
    } else {
      element.classList.remove('invalid');
    }
  });
  
  // Validar coordenadas del mapa si la ubicación está completada
  const locationInput = document.getElementById('location');
  const latitudeInput = document.getElementById('latitude');
  const longitudeInput = document.getElementById('longitude');
  
  if (locationInput.value && (!latitudeInput.value || !longitudeInput.value)) {
    // Si hay ubicación pero no coordenadas, intentar obtenerlas
    const geocoder = new google.maps.Geocoder();
    geocoder.geocode({ address: locationInput.value }, function(results, status) {
      if (status === 'OK' && results[0]) {
        const location = results[0].geometry.location;
        latitudeInput.value = location.lat();
        longitudeInput.value = location.lng();
        
        // Actualizar mapa
        const mapContainer = document.getElementById('map-container');
        mapContainer.style.display = 'block';
        map.setCenter(location);
        marker.setPosition(location);
        marker.setMap(map);
      }
    });
  }
  
  if (!isValid) {
    document.getElementById('errorText').textContent = 'Por favor, completa todos los campos requeridos.';
    document.getElementById('errorMessage').style.display = 'block';
  }
  
  return isValid;
}

// Función para desplazarse a la sección de reservas
function scrollToReservation() {
  const reservationSection = document.getElementById('reservas');
  reservationSection.scrollIntoView({ behavior: 'smooth' });
}