@echo off
REM Script para iniciar el servidor SitioWebDrone en Windows

REM Colores para CMD de Windows
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM Verificar si estamos en un entorno virtual
if exist "venv" (
    echo %YELLOW%Activando entorno virtual...%NC%
    call venv\Scripts\activate.bat
)

REM Iniciar el servidor
echo %BLUE%Iniciando SitioWebDrone...%NC%
echo %BLUE%=============================================%NC%
echo %YELLOW%API:%NC% http://localhost:5000/api
echo %YELLOW%Web:%NC% http://localhost:5001
echo %BLUE%=============================================%NC%
echo Presiona Ctrl+C para detener el servidor
echo.

REM Pasar argumentos al script Python
python start_server.py %*

REM Si estamos en un entorno virtual, desactivarlo al finalizar
if defined VIRTUAL_ENV (
    deactivate
)