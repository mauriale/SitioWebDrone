// Configuración
const API_BASE_URL = 'http://localhost:5000/api';

// Variables globales
let services = [];
let selectedService = null;
let flatpickrInstance = null;
let availableTimes = [];

document.addEventListener('DOMContentLoaded', function() {
  // Registrar Service Worker para funcionalidad offline
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('/service-worker.js')
        .then(registration => {
          console.log('Service Worker registrado con éxito:', registration.scope);
        })
        .catch(error => {
          console.error('Error al registrar el Service Worker:', error);
        });
    });
  }

  // Función para simular el efecto de vuelo del drone
  function simulateDroneFlight() {
    const videoBackground = document.querySelector('.video-background');
    if (!videoBackground) return;
    
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
  
  if (menuBtn && navLinks) {
    menuBtn.addEventListener('click', function() {
      navLinks.classList.toggle('active');
      menuBtn.classList.toggle('active');
    });
  }
  
  // Cargar servicios
  loadServices();
  
  // Inicializar el formulario
  initReservationForm();
  
  // Botón de volver arriba
  initBackToTopButton();
});

// Inicializar botón de volver arriba
function initBackToTopButton() {
  // Crear el botón y añadirlo al DOM
  const backToTopBtn = document.createElement('button');
  backToTopBtn.id = 'backToTop';
  backToTopBtn.className = 'back-to-top-btn';
  backToTopBtn.setAttribute('aria-label', 'Volver arriba');
  backToTopBtn.textContent = '↑';
  document.body.appendChild(backToTopBtn);
  
  // Manejar visibilidad del botón
  window.addEventListener('scroll', function() {
    if (window.scrollY > 300) {
      backToTopBtn.classList.add('visible');
    } else {
      backToTopBtn.classList.remove('visible');
    }
  });
  
  // Manejar clic en el botón
  backToTopBtn.addEventListener('click', function() {
    window.scrollTo({top: 0, behavior: 'smooth'});
  });
}

// Función para cargar servicios desde la API
async function loadServices() {
  const servicesSpinner = document.getElementById('servicesSpinner');
  if (servicesSpinner) {
    servicesSpinner.style.display = 'block';
  }
  
  try {
    const response = await fetch(`${API_BASE_URL}/services`);
    const data = await response.json();
    
    if (data.success) {
      services = data.services;
      renderServices();
      populateServiceSelect();
    } else {
      console.error('Error al cargar servicios:', data.error);
      // Intentar cargar desde el caché si está disponible
      loadCachedServices();
    }
  } catch (error) {
    console.error('Error al conectar con la API:', error);
    // Fallback - Comprobar caché o mostrar servicios de demostración
    loadCachedServices();
  } finally {
    if (servicesSpinner) {
      servicesSpinner.style.display = 'none';
    }
  }
}

// Función para cargar servicios desde caché
async function loadCachedServices() {
  try {
    // Intentar obtener servicios de IndexedDB o localStorage
    const cachedServices = localStorage.getItem('cachedServices');
    
    if (cachedServices) {
      services = JSON.parse(cachedServices);
      renderServices();
      populateServiceSelect();
    } else {
      // Si no hay caché, usar servicios de demostración
      renderDemoServices();
    }
  } catch (error) {
    console.error('Error al cargar servicios en caché:', error);
    // Mostrar servicios de demostración como último recurso
    renderDemoServices();
  }
}

// Función para renderizar servicios en la página
function renderServices() {
  const servicesContainer = document.getElementById('servicios');
  if (!servicesContainer) return;
  
  // Mantener el spinner si existe
  const spinner = document.getElementById('servicesSpinner');
  
  // Limpiar contenido excepto el spinner
  while (servicesContainer.firstChild) {
    if (spinner && servicesContainer.firstChild === spinner) {
      break;
    }
    servicesContainer.removeChild(servicesContainer.firstChild);
  }
  
  // Renderizar cada servicio con carga perezosa para las imágenes
  services.forEach((service, index) => {
    const serviceCard = document.createElement('div');
    serviceCard.className = 'service-card animate-in';
    serviceCard.classList.add(`delay-${index % 3}`); // Escalonar animaciones
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
  
  // Guardar servicios en caché para uso offline
  try {
    localStorage.setItem('cachedServices', JSON.stringify(services));
  } catch (error) {
    console.error('Error al guardar servicios en caché:', error);
  }
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
    },
    {
      id: 'telemetria',
      name: 'Telemetría y Modelado 3D',
      description: 'Digitalización de espacios y creación de modelos 3D de alta precisión.',
      icon: '📊',
      price_per_hour: 200,
      min_duration: 3,
      max_duration: 8
    }
  ];
  
  renderServices();
  populateServiceSelect();
}

// Función para llenar el select de servicios
function populateServiceSelect() {
  const serviceSelect = document.getElementById('service');
  if (!serviceSelect) return;
  
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
  if (serviceSelect) {
    serviceSelect.value = serviceId;
  }
  
  // Guardar servicio seleccionado
  selectedService = services.find(service => service.id === serviceId);
  
  // Actualizar opciones de duración
  updateDurationOptions();
  
  // Actualizar fecha si está seleccionada
  const dateInput = document.getElementById('date');
  if (dateInput && dateInput.value && flatpickrInstance && flatpickrInstance.selectedDates.length > 0) {
    updateAvailableTimes(new Date(flatpickrInstance.selectedDates[0]));
  }
  
  // Actualizar resumen de precios
  updatePriceSummary();
}

// Función para inicializar el formulario de reserva
function initReservationForm() {
  const dateInput = document.getElementById('date');
  if (!dateInput) return;
  
  // Inicializar el selector de fecha con Flatpickr
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
  const durationSelect = document.getElementById('duration');
  if (durationSelect) {
    durationSelect.addEventListener('change', updatePriceSummary);
  }
  
  // Implementar validación en tiempo real
  implementRealTimeValidation();
  
  // Manejar el envío del formulario
  const reservationForm = document.getElementById('reservationForm');
  if (reservationForm) {
    reservationForm.addEventListener('submit', handleFormSubmit);
  }
}

// Función para implementar validación en tiempo real
function implementRealTimeValidation() {
  const requiredFields = ['service', 'date', 'start-time', 'duration', 'name', 'email', 'phone', 'location'];
  
  requiredFields.forEach(fieldId => {
    const field = document.getElementById(fieldId);
    if (!field) return;
    
    field.addEventListener('blur', function() {
      validateField(this);
    });
    
    field.addEventListener('input', function() {
      // Quitar clase de error si el usuario está escribiendo
      this.classList.remove('invalid');
      
      // Para campos específicos, validar mientras se escribe
      if (fieldId === 'email') {
        validateField(this);
      }
    });
  });
  
  // Validación especial para el campo de email
  const emailField = document.getElementById('email');
  if (emailField) {
    emailField.addEventListener('input', function() {
      const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (this.value && !emailPattern.test(this.value)) {
        this.classList.add('invalid');
      } else {
        this.classList.remove('invalid');
      }
    });
  }
  
  // Añadir sugerencias para ubicación
  const locationField = document.getElementById('location');
  if (locationField) {
    const locationDatalist = document.createElement('datalist');
    locationDatalist.id = 'common-locations';
    
    // Añadir algunas ubicaciones comunes como ejemplo
    const commonLocations = [
      'Madrid - Centro',
      'Barcelona - Playa',
      'Valencia - Ciudad de las Artes',
      'Sevilla - Plaza de España',
      'Bilbao - Guggenheim'
    ];
    
    commonLocations.forEach(location => {
      const option = document.createElement('option');
      option.value = location;
      locationDatalist.appendChild(option);
    });
    
    document.body.appendChild(locationDatalist);
    locationField.setAttribute('list', 'common-locations');
  }
}

// Función para validar un campo individual
function validateField(field) {
  if (!field.value) {
    field.classList.add('invalid');
    return false;
  } else {
    field.classList.remove('invalid');
    return true;
  }
}

// Función para actualizar opciones de duración basadas en el servicio seleccionado
function updateDurationOptions() {
  const durationSelect = document.getElementById('duration');
  if (!durationSelect) return;
  
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
  if (!startTimeSelect) return;
  
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
      // Usar horarios en caché o fallback
      loadCachedAvailableTimes(selectedService.id, formattedDate);
    }
  } catch (error) {
    console.error('Error al conectar con la API:', error);
    
    // Intentar cargar horarios desde caché
    loadCachedAvailableTimes(selectedService.id, formattedDate);
  }
}

// Función para cargar horarios disponibles desde caché
function loadCachedAvailableTimes(serviceId, date) {
  const startTimeSelect = document.getElementById('start-time');
  if (!startTimeSelect) return;
  
  // Intentar obtener horarios de localStorage
  try {
    const cachedTimesKey = `availableTimes_${serviceId}_${date}`;
    const cachedTimes = localStorage.getItem(cachedTimesKey);
    
    if (cachedTimes) {
      availableTimes = JSON.parse(cachedTimes);
      
      // Añadir horarios disponibles
      availableTimes.forEach(time => {
        const option = document.createElement('option');
        option.value = time;
        option.text = time;
        startTimeSelect.appendChild(option);
      });
    } else {
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
  } catch (error) {
    console.error('Error al cargar horarios desde caché:', error);
    
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
  if (!priceSummary) return;
  
  if (!selectedService) {
    priceSummary.style.display = 'none';
    return;
  }
  
  const durationSelect = document.getElementById('duration');
  const duration = durationSelect ? parseInt(durationSelect.value) || 0 : 0;
  const pricePerHour = selectedService.price_per_hour;
  const totalPrice = pricePerHour * duration;
  
  // Actualizar elementos del resumen
  const summaryServiceName = document.getElementById('summaryServiceName');
  const summaryPricePerHour = document.getElementById('summaryPricePerHour');
  const summaryDuration = document.getElementById('summaryDuration');
  const summaryTotal = document.getElementById('summaryTotal');
  
  if (summaryServiceName) summaryServiceName.textContent = selectedService.name;
  if (summaryPricePerHour) summaryPricePerHour.textContent = pricePerHour;
  if (summaryDuration) summaryDuration.textContent = duration;
  if (summaryTotal) summaryTotal.textContent = totalPrice;
  
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
  
  if (!spinner || !confirmationMessage || !errorMessage || !form) return;
  
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
      const bookingNumber = document.getElementById('bookingNumber');
      if (bookingNumber) bookingNumber.textContent = data.booking_id;
      confirmationMessage.style.display = 'block';
      form.style.display = 'none';
      
      // Guardar una copia local de la reserva
      saveBookingLocally(bookingData, data.booking_id);
    } else {
      // Verificar si estamos offline
      if (!navigator.onLine) {
        // Guardar reserva localmente para sincronizar cuando haya conexión
        saveBookingLocally(bookingData);
        
        // Mostrar mensaje de confirmación con información de sincronización
        const bookingNumber = document.getElementById('bookingNumber');
        if (bookingNumber) bookingNumber.textContent = 'Pendiente de sincronización';
        confirmationMessage.style.display = 'block';
        form.style.display = 'none';
        
        // Programar sincronización cuando haya conexión
        if ('serviceWorker' in navigator && 'SyncManager' in window) {
          const registration = await navigator.serviceWorker.ready;
          await registration.sync.register('sync-reservations');
        }
      } else {
        // Mostrar mensaje de error
        const errorText = document.getElementById('errorText');
        if (errorText) errorText.textContent = data.error || 'Error al procesar la reserva. Por favor, intenta nuevamente.';
        errorMessage.style.display = 'block';
      }
    }
  } catch (error) {
    console.error('Error al conectar con la API:', error);
    
    // Verificar si estamos offline
    if (!navigator.onLine) {
      // Guardar reserva localmente para sincronizar cuando haya conexión
      saveBookingLocally(bookingData);
      
      // Mostrar mensaje de confirmación con información de sincronización
      const bookingNumber = document.getElementById('bookingNumber');
      if (bookingNumber) bookingNumber.textContent = 'Pendiente de sincronización';
      confirmationMessage.style.display = 'block';
      form.style.display = 'none';
      
      // Programar sincronización cuando haya conexión
      if ('serviceWorker' in navigator && 'SyncManager' in window) {
        const registration = await navigator.serviceWorker.ready;
        await registration.sync.register('sync-reservations');
      }
    } else {
      // Mostrar mensaje de error
      const errorText = document.getElementById('errorText');
      if (errorText) errorText.textContent = 'Error de conexión. Por favor, intenta nuevamente más tarde.';
      errorMessage.style.display = 'block';
    }
  } finally {
    if (spinner) spinner.style.display = 'none';
  }
}

// Función para guardar reserva localmente
function saveBookingLocally(bookingData, bookingId) {
  try {
    // Obtener reservas existentes o inicializar un array vacío
    const existingBookings = JSON.parse(localStorage.getItem('pendingBookings') || '[]');
    
    // Añadir nueva reserva con timestamp
    existingBookings.push({
      ...bookingData,
      booking_id: bookingId || `local_${Date.now()}`,
      timestamp: Date.now(),
      synced: !!bookingId
    });
    
    // Guardar en localStorage
    localStorage.setItem('pendingBookings', JSON.stringify(existingBookings));
    
    console.log('Reserva guardada localmente');
  } catch (error) {
    console.error('Error al guardar reserva localmente:', error);
  }
}

// Función para validar el formulario
function validateForm() {
  const requiredFields = ['service', 'date', 'start-time', 'duration', 'name', 'email', 'phone', 'location'];
  let isValid = true;
  
  requiredFields.forEach(field => {
    const element = document.getElementById(field);
    if (!element || !element.value) {
      if (element) element.classList.add('invalid');
      isValid = false;
    } else {
      if (element) element.classList.remove('invalid');
    }
  });
  
  // Validación de email
  const emailField = document.getElementById('email');
  if (emailField && emailField.value) {
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailPattern.test(emailField.value)) {
      emailField.classList.add('invalid');
      isValid = false;
    }
  }
  
  if (!isValid) {
    const errorText = document.getElementById('errorText');
    const errorMessage = document.getElementById('errorMessage');
    
    if (errorText) errorText.textContent = 'Por favor, completa todos los campos requeridos correctamente.';
    if (errorMessage) errorMessage.style.display = 'block';
  }
  
  return isValid;
}

// Función para desplazarse a la sección de reservas
function scrollToReservation() {
  const reservationSection = document.getElementById('reservas');
  if (reservationSection) {
    reservationSection.scrollIntoView({ behavior: 'smooth' });
  }
}