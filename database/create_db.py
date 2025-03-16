#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sqlite3
import os
import datetime

# Asegurar que el directorio de base de datos existe
if not os.path.exists('database'):
    os.makedirs('database')

# Conectar a la base de datos (se creará si no existe)
conn = sqlite3.connect('database/dronevista.db')
cursor = conn.cursor()

# Crear tabla de servicios
cursor.execute('''
CREATE TABLE IF NOT EXISTS services (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    price_per_hour REAL NOT NULL,
    min_duration INTEGER NOT NULL,
    max_duration INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
''')

# Crear tabla para horarios disponibles por servicio
cursor.execute('''
CREATE TABLE IF NOT EXISTS available_times (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id TEXT NOT NULL,
    time TEXT NOT NULL,
    FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE
)
''')

# Crear tabla para equipamiento por servicio
cursor.execute('''
CREATE TABLE IF NOT EXISTS equipment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id TEXT NOT NULL,
    name TEXT NOT NULL,
    FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE
)
''')

# Crear tabla para características por servicio
cursor.execute('''
CREATE TABLE IF NOT EXISTS features (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id TEXT NOT NULL,
    description TEXT NOT NULL,
    FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE
)
''')

# Crear tabla para requisitos por servicio
cursor.execute('''
CREATE TABLE IF NOT EXISTS requirements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id TEXT NOT NULL,
    description TEXT NOT NULL,
    FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE
)
''')

# Crear tabla de bookings (reservas)
cursor.execute('''
CREATE TABLE IF NOT EXISTS bookings (
    id TEXT PRIMARY KEY,
    service_id TEXT NOT NULL,
    booking_date TEXT NOT NULL,
    start_time TEXT NOT NULL,
    duration INTEGER NOT NULL,
    client_name TEXT NOT NULL,
    client_email TEXT NOT NULL,
    client_phone TEXT NOT NULL,
    location TEXT,
    comments TEXT,
    status TEXT DEFAULT 'pendiente',
    total_price REAL NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services (id)
)
''')

# Insertar algunos servicios de ejemplo
services = [
    ('montaña', 'Filmación en Montaña', 'Tomas espectaculares de paisajes montañosos, senderos y actividades al aire libre desde ángulos imposibles.', '🏔️', 120, 2, 8),
    ('playa', 'Filmación en Playa', 'Imágenes aéreas impresionantes de costas, olas y eventos playeros con perspectivas únicas.', '🏖️', 100, 1, 6),
    ('produccion', 'Producción Audiovisual', 'Servicios completos de filmación, edición y posproducción para crear contenido de alta calidad.', '🎬', 150, 3, 10),
    ('corporativo', 'Servicios Corporativos', 'Filmación para empresas, publicidad, eventos y proyectos especiales con tecnología de punta.', '🏢', 180, 4, 12)
]

cursor.executemany('''
INSERT OR REPLACE INTO services 
(id, name, description, icon, price_per_hour, min_duration, max_duration) 
VALUES (?, ?, ?, ?, ?, ?, ?)
''', services)

# Insertar horarios disponibles
available_times = [
    # Montaña
    ('montaña', '08:00'),
    ('montaña', '09:00'),
    ('montaña', '10:00'),
    ('montaña', '11:00'),
    ('montaña', '12:00'),
    ('montaña', '13:00'),
    ('montaña', '14:00'),
    ('montaña', '15:00'),
    ('montaña', '16:00'),
    # Playa
    ('playa', '07:00'),
    ('playa', '08:00'),
    ('playa', '09:00'),
    ('playa', '10:00'),
    ('playa', '11:00'),
    ('playa', '15:00'),
    ('playa', '16:00'),
    ('playa', '17:00'),
    ('playa', '18:00'),
    # Producción
    ('produccion', '08:00'),
    ('produccion', '09:00'),
    ('produccion', '10:00'),
    ('produccion', '11:00'),
    ('produccion', '12:00'),
    ('produccion', '13:00'),
    ('produccion', '14:00'),
    # Corporativo
    ('corporativo', '08:00'),
    ('corporativo', '09:00'),
    ('corporativo', '10:00'),
    ('corporativo', '11:00'),
    ('corporativo', '12:00'),
    ('corporativo', '13:00'),
    ('corporativo', '14:00'),
    ('corporativo', '15:00')
]

# Borrar horarios existentes antes de insertar
cursor.execute('DELETE FROM available_times')
cursor.executemany('INSERT INTO available_times (service_id, time) VALUES (?, ?)', available_times)

# Equipamiento por servicio
equipment = [
    # Montaña
    ('montaña', 'Drone DJI Mavic 3 Pro'),
    ('montaña', 'Cámaras 4K'),
    ('montaña', 'Estabilizadores'),
    # Playa
    ('playa', 'Drone DJI Air 2S'),
    ('playa', 'Cámaras de alta resolución resistentes al agua'),
    # Producción
    ('produccion', 'Múltiples drones especializados'),
    ('produccion', 'Equipo de edición profesional'),
    ('produccion', 'Software de posproducción'),
    # Corporativo
    ('corporativo', 'Fleet de drones profesionales'),
    ('corporativo', 'Cámaras térmicas'),
    ('corporativo', 'Drones para interiores')
]

# Borrar equipamiento existente antes de insertar
cursor.execute('DELETE FROM equipment')
cursor.executemany('INSERT INTO equipment (service_id, name) VALUES (?, ?)', equipment)

# Características por servicio
features = [
    # Montaña
    ('montaña', 'Filmación aérea en terrenos elevados'),
    ('montaña', 'Seguimiento de senderistas o deportistas'),
    ('montaña', 'Vistas panorámicas de montañas y valles'),
    ('montaña', 'Filmación en condiciones climáticas variables'),
    # Playa
    ('playa', 'Tomas aéreas de playas y costas'),
    ('playa', 'Seguimiento de surfistas y deportes acuáticos'),
    ('playa', 'Filmación de eventos en la playa'),
    ('playa', 'Vuelos al amanecer y atardecer para capturas espectaculares'),
    # Producción
    ('produccion', 'Filmación aérea profesional'),
    ('produccion', 'Edición de video avanzada'),
    ('produccion', 'Corrección de color'),
    ('produccion', 'Efectos visuales y gráficos animados'),
    ('produccion', 'Música y efectos de sonido'),
    ('produccion', 'Entrega en múltiples formatos'),
    # Corporativo
    ('corporativo', 'Filmación aérea de instalaciones'),
    ('corporativo', 'Tours virtuales'),
    ('corporativo', 'Inspección de infraestructuras'),
    ('corporativo', 'Cobertura de eventos corporativos'),
    ('corporativo', 'Material para marketing y publicidad')
]

# Borrar características existentes antes de insertar
cursor.execute('DELETE FROM features')
cursor.executemany('INSERT INTO features (service_id, description) VALUES (?, ?)', features)

# Requisitos por servicio
requirements = [
    # Montaña
    ('montaña', 'Ubicación accesible para el equipo'),
    ('montaña', 'Permisos locales para vuelo de drones en zonas montañosas'),
    ('montaña', 'Clima adecuado (sin fuertes vientos o lluvia)'),
    # Playa
    ('playa', 'Condiciones de viento moderadas'),
    ('playa', 'Permisos para operar drones en zonas costeras'),
    ('playa', 'Sin alta concentración de personas (por seguridad)'),
    # Producción
    ('produccion', 'Brief detallado del proyecto'),
    ('produccion', 'Reunión de planificación previa'),
    ('produccion', 'Definición clara de entregables'),
    # Corporativo
    ('corporativo', 'Contrato formal'),
    ('corporativo', 'Permisos de acceso a instalaciones'),
    ('corporativo', 'Identificación de áreas restringidas'),
    ('corporativo', 'Acuerdos de confidencialidad si es necesario')
]

# Borrar requisitos existentes antes de insertar
cursor.execute('DELETE FROM requirements')
cursor.executemany('INSERT INTO requirements (service_id, description) VALUES (?, ?)', requirements)

# Añadir algunas reservas de ejemplo
bookings = [
    ('B001', 'montaña', '20/03/2025', '09:00', 4, 'Juan Pérez', 'juan.perez@ejemplo.com', '+34 612 345 678', 'Sierra de Guadarrama, Madrid', 'Filmación para documental sobre senderismo', 'confirmado', 480),
    ('B002', 'playa', '25/03/2025', '17:00', 2, 'María Rodríguez', 'maria.r@ejemplo.com', '+34 623 456 789', 'Playa de la Concha, San Sebastián', 'Grabación para vídeo promocional de hotel', 'pendiente', 200)
]

cursor.executemany('''
INSERT OR REPLACE INTO bookings
(id, service_id, booking_date, start_time, duration, client_name, client_email, client_phone, location, comments, status, total_price)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''', bookings)

# Guardar cambios y cerrar conexión
conn.commit()
conn.close()

print("Base de datos creada e inicializada correctamente.")
