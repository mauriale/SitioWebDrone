@echo off
REM Script simplificado para iniciar el servidor SitioWebDrone

echo.
echo ====================================
echo   SitioWebDrone - Iniciando servidor
echo ====================================
echo.

REM Verificar que Python está instalado
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python no esta instalado o no esta en el PATH
    echo Por favor instala Python desde https://www.python.org/
    pause
    exit /b 1
)

REM Instalar dependencias si es necesario
echo Verificando dependencias...
pip install flask flask-cors requests python-dotenv werkzeug --quiet 2>nul

REM Crear directorios necesarios
if not exist "logs" mkdir logs
if not exist "data" mkdir data
if not exist "database" mkdir database
if not exist "img" mkdir img
if not exist "api" mkdir api

REM Iniciar servidor
echo.
echo Servidor iniciando...
echo.
echo URL local: http://localhost:5000
echo URL red: http://192.168.1.14:5000
echo.
echo Presiona Ctrl+C para detener el servidor
echo ====================================
echo.

REM Configurar variables de entorno
set PORT=5000
set DEBUG=true

REM Iniciar Flask
python app.py
