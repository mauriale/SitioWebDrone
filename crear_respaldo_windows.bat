@echo off
REM Crear punto de respaldo con arreglos de errores de sintaxis

echo =====================================
echo  CREANDO PUNTO DE RESPALDO FINAL 
echo =====================================
echo.

REM Crear directorio de respaldos si no existe
if not exist "backups" mkdir backups

REM Crear directorio para este punto de respaldo específico
if not exist "backups\Arreglo-Windows-v1.0" mkdir backups\Arreglo-Windows-v1.0

REM Crear archivo INFO.md
echo # Punto de respaldo: Arreglo-Windows-v1.0 > backups\Arreglo-Windows-v1.0\INFO.md
echo. >> backups\Arreglo-Windows-v1.0\INFO.md
echo - **Fecha:** %date% %time% >> backups\Arreglo-Windows-v1.0\INFO.md
echo - **Descripcion:** Correccion de errores de sintaxis en scripts Windows >> backups\Arreglo-Windows-v1.0\INFO.md
echo. >> backups\Arreglo-Windows-v1.0\INFO.md
echo Este punto de respaldo corrige los errores de sintaxis en los scripts batch y Python. >> backups\Arreglo-Windows-v1.0\INFO.md
echo. >> backups\Arreglo-Windows-v1.0\INFO.md
echo Archivos corregidos: >> backups\Arreglo-Windows-v1.0\INFO.md
echo - install.bat >> backups\Arreglo-Windows-v1.0\INFO.md
echo - run.bat >> backups\Arreglo-Windows-v1.0\INFO.md
echo - start_server.py >> backups\Arreglo-Windows-v1.0\INFO.md
echo - api/booking_api.py >> backups\Arreglo-Windows-v1.0\INFO.md
echo - api/maps_proxy.py >> backups\Arreglo-Windows-v1.0\INFO.md
echo. >> backups\Arreglo-Windows-v1.0\INFO.md
echo Para restaurar este punto de respaldo, simplemente copia los archivos de esta carpeta a la raiz del proyecto. >> backups\Arreglo-Windows-v1.0\INFO.md

REM Copiar archivos al punto de respaldo
copy install.bat backups\Arreglo-Windows-v1.0\
copy run.bat backups\Arreglo-Windows-v1.0\
copy start_server.py backups\Arreglo-Windows-v1.0\

REM Crear directorios api en el respaldo si no existe
if not exist "backups\Arreglo-Windows-v1.0\api" mkdir backups\Arreglo-Windows-v1.0\api

REM Copiar archivos de api
if exist "api\booking_api.py" copy api\booking_api.py backups\Arreglo-Windows-v1.0\api\
if exist "api\maps_proxy.py" copy api\maps_proxy.py backups\Arreglo-Windows-v1.0\api\

echo.
echo Punto de respaldo "Arreglo-Windows-v1.0" creado exitosamente en la carpeta backups\Arreglo-Windows-v1.0
echo.
echo Este punto de respaldo incluye:
echo - Scripts batch corregidos para Windows
echo - Versiones simplificadas de los scripts Python
echo - Manejo mejorado de errores
echo.
echo Para continuar con el desarrollo, simplemente ejecuta:
echo 1. install.bat   (instala las dependencias)
echo 2. run.bat       (inicia el servidor)
echo.
echo Si necesitas restaurar este punto en el futuro, copia los archivos de backups\Arreglo-Windows-v1.0 
echo a la carpeta raiz del proyecto.
echo.
pause