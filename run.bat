@echo off
REM Script para iniciar el servidor SitioWebDrone en Windows sin depender de un entorno virtual

REM Colores para CMD de Windows
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RED=[91m"
set "NC=[0m"

REM Verificar que Python está instalado
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo %RED%Error: Python no esta instalado o no esta en el PATH%NC%
    echo Asegurate de tener Python instalado y configurado correctamente.
    pause
    exit /b 1
)

REM Verificar que Flask está instalado
python -c "import flask" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo %YELLOW%Flask no esta instalado. Intentando instalar...%NC%
    pip install flask flask-cors requests python-dotenv werkzeug
    if %ERRORLEVEL% NEQ 0 (
        echo %RED%Error: No se pudo instalar Flask.%NC%
        echo Intenta ejecutar 'pip install flask flask-cors requests python-dotenv werkzeug' manualmente.
        pause
        exit /b 1
    )
    echo %GREEN%+ Flask instalado correctamente.%NC%
)

REM Crear los directorios necesarios si no existen
if not exist "logs" mkdir logs
if not exist "data" mkdir data
if not exist "database" mkdir database
if not exist "img" mkdir img

REM Iniciar servidor web simple usando Python
echo %BLUE%Iniciando SitioWebDrone...%NC%
echo %BLUE%=============================================%NC%
echo %YELLOW%API:%NC% http://localhost:5000/api
echo %YELLOW%Web:%NC% http://localhost:5001
echo %BLUE%=============================================%NC%
echo Presiona Ctrl+C para detener el servidor
echo.

REM Iniciar un servidor HTTP simple en el puerto 5001
start cmd /k "python -m http.server 5001"

REM Iniciar la API en otro proceso
python api/booking_api.py

REM Si llegamos aquí es porque se cerró la API
echo.
echo %YELLOW%El servidor API se ha detenido.%NC%
echo %YELLOW%Cerrando el servidor web...%NC%

REM Intentar cerrar el servidor web
taskkill /f /im python.exe /fi "WINDOWTITLE eq http.server*" >nul 2>&1

echo %BLUE%Gracias por usar SitioWebDrone!%NC%
pause