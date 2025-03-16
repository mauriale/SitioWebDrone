#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sqlite3
import json
import os
from datetime import datetime

class DroneVistaDB:
    def __init__(self, db_path='database/dronevista.db'):
        """Inicializa la conexión a la base de datos."""
        self.db_path = db_path
        self.conn = None
        self.cursor = None

    def connect(self):
        """Establece la conexión a la base de datos."""
        if not os.path.exists(self.db_path):
            raise FileNotFoundError(f"La base de datos no existe en {self.db_path}")
        
        self.conn = sqlite3.connect(self.db_path)
        # Configurar para recibir diccionarios en lugar de tuplas
        self.conn.row_factory = sqlite3.Row
        self.cursor = self.conn.cursor()
        return self.conn
    
    def close(self):
        """Cierra la conexión a la base de datos."""
        if self.conn:
            self.conn.close()
            self.conn = None
            self.cursor = None
    
    def commit(self):
        """Guarda los cambios en la base de datos."""
        if self.conn:
            self.conn.commit()
    
    def get_all_services(self):
        """Obtiene todos los servicios con sus detalles completos."""
        try:
            self.connect()
            
            # Obtener servicios base
            self.cursor.execute('''
                SELECT * FROM services ORDER BY name
            ''')
            services_rows = self.cursor.fetchall()
            
            services = []
            for service_row in services_rows:
                service = dict(service_row)
                service_id = service['id']
                
                # Obtener horarios disponibles
                self.cursor.execute('SELECT time FROM available_times WHERE service_id = ?', (service_id,))
                available_times = [row['time'] for row in self.cursor.fetchall()]
                service['available_times'] = available_times
                
                # Obtener equipamiento
                self.cursor.execute('SELECT name FROM equipment WHERE service_id = ?', (service_id,))
                equipment = [row['name'] for row in self.cursor.fetchall()]
                service['equipment'] = equipment
                
                # Obtener características
                self.cursor.execute('SELECT description FROM features WHERE service_id = ?', (service_id,))
                features = [row['description'] for row in self.cursor.fetchall()]
                service['features'] = features
                
                # Obtener requisitos
                self.cursor.execute('SELECT description FROM requirements WHERE service_id = ?', (service_id,))
                requirements = [row['description'] for row in self.cursor.fetchall()]
                service['requirements'] = requirements
                
                services.append(service)
            
            return services
        finally:
            self.close()
    
    def get_service(self, service_id):
        """Obtiene un servicio específico por su ID."""
        try:
            self.connect()
            
            # Obtener servicio base
            self.cursor.execute('SELECT * FROM services WHERE id = ?', (service_id,))
            service_row = self.cursor.fetchone()
            
            if not service_row:
                return None
            
            service = dict(service_row)
            
            # Obtener horarios disponibles
            self.cursor.execute('SELECT time FROM available_times WHERE service_id = ?', (service_id,))
            available_times = [row['time'] for row in self.cursor.fetchall()]
            service['available_times'] = available_times
            
            # Obtener equipamiento
            self.cursor.execute('SELECT name FROM equipment WHERE service_id = ?', (service_id,))
            equipment = [row['name'] for row in self.cursor.fetchall()]
            service['equipment'] = equipment
            
            # Obtener características
            self.cursor.execute('SELECT description FROM features WHERE service_id = ?', (service_id,))
            features = [row['description'] for row in self.cursor.fetchall()]
            service['features'] = features
            
            # Obtener requisitos
            self.cursor.execute('SELECT description FROM requirements WHERE service_id = ?', (service_id,))
            requirements = [row['description'] for row in self.cursor.fetchall()]
            service['requirements'] = requirements
            
            return service
        finally:
            self.close()
    
    def get_all_bookings(self):
        """Obtiene todas las reservas."""
        try:
            self.connect()
            self.cursor.execute('''
                SELECT b.*, s.name as service_name, s.icon as service_icon 
                FROM bookings b
                JOIN services s ON b.service_id = s.id
                ORDER BY b.booking_date, b.start_time
            ''')
            return [dict(row) for row in self.cursor.fetchall()]
        finally:
            self.close()
    
    def get_booking(self, booking_id):
        """Obtiene una reserva específica por su ID."""
        try:
            self.connect()
            self.cursor.execute('''
                SELECT b.*, s.name as service_name, s.icon as service_icon 
                FROM bookings b
                JOIN services s ON b.service_id = s.id
                WHERE b.id = ?
            ''', (booking_id,))
            booking = self.cursor.fetchone()
            return dict(booking) if booking else None
        finally:
            self.close()
    
    def create_booking(self, booking_data):
        """
        Crea una nueva reserva.
        
        Args:
            booking_data: Diccionario con los datos de la reserva.
                Debe contener: service_id, booking_date, start_time, duration,
                client_name, client_email, client_phone, location, comments
        
        Returns:
            El ID de la reserva creada.
        """
        try:
            self.connect()
            
            # Obtener el precio por hora del servicio
            self.cursor.execute('SELECT price_per_hour FROM services WHERE id = ?', (booking_data['service_id'],))
            service = self.cursor.fetchone()
            if not service:
                raise ValueError(f"Servicio no encontrado: {booking_data['service_id']}")
            
            # Calcular precio total
            price_per_hour = service['price_per_hour']
            total_price = price_per_hour * int(booking_data['duration'])
            
            # Generar ID para la nueva reserva
            self.cursor.execute('SELECT MAX(CAST(SUBSTR(id, 2) AS INTEGER)) FROM bookings')
            result = self.cursor.fetchone()
            max_id = result[0] if result[0] is not None else 0
            new_id = f"B{str(max_id + 1).zfill(3)}"
            
            # Insertar nueva reserva
            self.cursor.execute('''
                INSERT INTO bookings (
                    id, service_id, booking_date, start_time, duration,
                    client_name, client_email, client_phone, location, comments,
                    status, total_price
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                new_id,
                booking_data['service_id'],
                booking_data['booking_date'],
                booking_data['start_time'],
                booking_data['duration'],
                booking_data['client_name'],
                booking_data['client_email'],
                booking_data['client_phone'],
                booking_data.get('location', ''),
                booking_data.get('comments', ''),
                'pendiente',
                total_price
            ))
            
            self.conn.commit()
            return new_id
        finally:
            self.close()
    
    def update_booking_status(self, booking_id, status):
        """Actualiza el estado de una reserva."""
        try:
            self.connect()
            self.cursor.execute('''
                UPDATE bookings SET status = ? WHERE id = ?
            ''', (status, booking_id))
            self.conn.commit()
            return self.cursor.rowcount > 0
        finally:
            self.close()
    
    def get_available_times_for_date(self, service_id, date):
        """
        Obtiene los horarios disponibles para un servicio en una fecha específica,
        excluyendo los que ya están reservados.
        """
        try:
            self.connect()
            
            # Obtener todos los horarios disponibles para este servicio
            self.cursor.execute('''
                SELECT time FROM available_times 
                WHERE service_id = ?
                ORDER BY time
            ''', (service_id,))
            
            all_times = [row['time'] for row in self.cursor.fetchall()]
            
            # Obtener las reservas existentes para esta fecha y servicio
            self.cursor.execute('''
                SELECT start_time, duration FROM bookings
                WHERE service_id = ? AND booking_date = ? AND status != 'cancelado'
            ''', (service_id, date))
            
            booked_times = []
            for booking in self.cursor.fetchall():
                start_time = booking['start_time']
                duration = booking['duration']
                
                # Convertir la hora de inicio a un índice en la lista de todos los horarios
                if start_time in all_times:
                    start_index = all_times.index(start_time)
                    # Marcar los bloques ocupados por esta reserva
                    for i in range(duration):
                        if start_index + i < len(all_times):
                            booked_times.append(all_times[start_index + i])
            
            # Excluir los horarios ya reservados
            available_times = [time for time in all_times if time not in booked_times]
            
            return available_times
        finally:
            self.close()

    def export_services_to_json(self, output_file='data/services.json'):
        """Exporta todos los servicios a un archivo JSON."""
        try:
            services = self.get_all_services()
            
            # Crear directorio si no existe
            os.makedirs(os.path.dirname(output_file), exist_ok=True)
            
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump({'services': services}, f, ensure_ascii=False, indent=2)
            
            return len(services)
        except Exception as e:
            print(f"Error al exportar servicios: {e}")
            return 0
    
    def export_bookings_to_json(self, output_file='data/bookings.json'):
        """Exporta todas las reservas a un archivo JSON."""
        try:
            bookings = self.get_all_bookings()
            
            # Crear directorio si no existe
            os.makedirs(os.path.dirname(output_file), exist_ok=True)
            
            # Crear estructura con contador para siguiente ID
            data = {
                'bookings': bookings,
                'nextBookingId': self._get_next_booking_id()
            }
            
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            
            return len(bookings)
        except Exception as e:
            print(f"Error al exportar reservas: {e}")
            return 0
    
    def _get_next_booking_id(self):
        """Obtiene el siguiente ID para las reservas."""
        try:
            self.connect()
            self.cursor.execute('SELECT MAX(CAST(SUBSTR(id, 2) AS INTEGER)) FROM bookings')
            result = self.cursor.fetchone()
            max_id = result[0] if result[0] is not None else 0
            return f"B{str(max_id + 1).zfill(3)}"
        finally:
            self.close()

# Ejemplo de uso
if __name__ == "__main__":
    db = DroneVistaDB()
    services = db.get_all_services()
    print(f"Se encontraron {len(services)} servicios")
    
    # Exportar datos a JSON
    num_services = db.export_services_to_json()
    num_bookings = db.export_bookings_to_json()
    
    print(f"Exportados {num_services} servicios y {num_bookings} reservas a archivos JSON")
