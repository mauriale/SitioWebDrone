@echo off
setlocal enabledelayedexpansion

REM Colores para CMD de Windows
set "BLUE=[94m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "NC=[0m"

REM Función para crear un punto de respaldo
:create_backup
    set "version_name=%~1"
    set "desc=%~2"
    
    echo %YELLOW%Creando punto de respaldo: %version_name%%NC%
    
    REM Crear directorio de respaldo si no existe
    if not exist "backups" (
        mkdir backups
    )
    
    REM Crear archivo de descriptor con información
    set "timestamp=%date% %time%"
    set "backup_dir=backups\%version_name%"
    
    REM Crear directorio para este backup
    if not exist "%backup_dir%" (
        mkdir "%backup_dir%"
    )
    
    REM Guardar descriptor
    echo # Punto de respaldo: %version_name%> "%backup_dir%\INFO.md"
    echo.>> "%backup_dir%\INFO.md"
    echo - **Fecha:** %timestamp%>> "%backup_dir%\INFO.md"
    echo - **Descripción:** %desc%>> "%backup_dir%\INFO.md"
    echo.>> "%backup_dir%\INFO.md"
    echo Este punto de respaldo incluye los siguientes archivos modificados desde la versión anterior:>> "%backup_dir%\INFO.md"
    echo.>> "%backup_dir%\INFO.md"
    echo.>> "%backup_dir%\INFO.md"
    echo Para restaurar este punto de respaldo, utiliza:>> "%backup_dir%\INFO.md"
    echo.>> "%backup_dir%\INFO.md"
    echo ```batch>> "%backup_dir%\INFO.md"
    echo backup.bat restore %version_name%>> "%backup_dir%\INFO.md"
    echo ```>> "%backup_dir%\INFO.md"
    
    REM Crear una copia de seguridad de los archivos actuales
    echo Copiando archivos al punto de respaldo...
    robocopy . "%backup_dir%" /E /XD backups .git venv __pycache__ /XF *.pyc database\dronevista.db > nul
    
    REM Crear un archivo zip del respaldo
    set "zip_name=backups\%version_name%.zip"
    echo Creando archivo ZIP...
    
    REM Utilizar PowerShell para comprimir (alternativa a zip en Windows)
    powershell -command "Compress-Archive -Path '%backup_dir%\*' -DestinationPath '%zip_name%' -Force" > nul
    
    echo %GREEN%✓ Punto de respaldo creado: %zip_name%%NC%
    echo %GREEN%✓ Descriptor guardado en: %backup_dir%\INFO.md%NC%
    
    goto :eof

REM Función para listar puntos de respaldo
:list_backups
    echo %BLUE%=============================================%NC%
    echo %BLUE%      PUNTOS DE RESPALDO DISPONIBLES         %NC%
    echo %BLUE%=============================================%NC%
    
    if not exist "backups" (
        echo %YELLOW%No se encontraron puntos de respaldo.%NC%
        goto :eof
    )
    
    echo %YELLOW%Puntos de respaldo:%NC%
    
    REM Listar directorios de respaldo
    for /d %%f in (backups\*) do (
        set "version_name=%%~nxf"
        if exist "%%f\INFO.md" (
            for /f "tokens=2 delims=:" %%d in ('findstr /C:"**Fecha:**" "%%f\INFO.md"') do (
                set "date=%%d"
            )
            for /f "tokens=2 delims=:" %%d in ('findstr /C:"**Descripción:**" "%%f\INFO.md"') do (
                set "desc=%%d"
            )
            
            echo %GREEN%!version_name!%NC% (!date!)
            echo   !desc!
        ) else (
            echo %YELLOW%!version_name!%NC% (Sin información)
        )
    )
    
    echo %BLUE%=============================================%NC%
    echo Para restaurar un punto de respaldo, usa:
    echo %YELLOW%backup.bat restore NOMBRE_VERSION%NC%
    
    goto :eof

REM Función para restaurar un punto de respaldo
:restore_backup
    set "version_name=%~1"
    set "backup_dir=backups\%version_name%"
    set "zip_file=backups\%version_name%.zip"
    
    if not exist "%backup_dir%" (
        if not exist "%zip_file%" (
            echo %RED%✗ Punto de respaldo no encontrado: %version_name%%NC%
            echo Usa 'backup.bat list' para ver los puntos disponibles.
            goto :eof
        )
    )
    
    echo %YELLOW%Restaurando punto de respaldo: %version_name%%NC%
    
    REM Si tenemos solo el zip, extraerlo primero
    if not exist "%backup_dir%" (
        if exist "%zip_file%" (
            echo %YELLOW%Extrayendo archivo zip...%NC%
            powershell -command "Expand-Archive -Path '%zip_file%' -DestinationPath '%backup_dir%' -Force" > nul
            if errorlevel 1 (
                echo %RED%✗ Error al extraer el archivo zip.%NC%
                goto :eof
            )
        )
    )
    
    REM Crear respaldo del estado actual antes de restaurar
    set "current_timestamp=%date:/=%%time::=%"
    set "current_timestamp=!current_timestamp: =!"
    echo %YELLOW%Creando respaldo del estado actual antes de restaurar...%NC%
    mkdir "backups\pre_restore_!current_timestamp!"
    robocopy . "backups\pre_restore_!current_timestamp!" /E /XD backups .git venv __pycache__ /XF *.pyc database\dronevista.db > nul
    
    REM Restaurar archivos
    echo %YELLOW%Restaurando archivos...%NC%
    robocopy "%backup_dir%" . /E /XD backups .git venv __pycache__ /XF *.pyc database\dronevista.db INFO.md > nul
    
    echo %GREEN%✓ Punto de respaldo restaurado: %version_name%%NC%
    echo %YELLOW%Se ha creado un respaldo del estado previo: pre_restore_!current_timestamp!%NC%
    
    REM Mostrar INFO.md
    if exist "%backup_dir%\INFO.md" (
        echo %BLUE%=============================================%NC%
        echo %YELLOW%Información del punto restaurado:%NC%
        type "%backup_dir%\INFO.md"
        echo %BLUE%=============================================%NC%
    )
    
    goto :eof

REM Punto de entrada principal
if "%~1"=="" (
    echo %BLUE%=============================================%NC%
    echo %BLUE%      GESTOR DE PUNTOS DE RESPALDO           %NC%
    echo %BLUE%=============================================%NC%
    echo %YELLOW%Uso:%NC%
    echo   backup.bat create NOMBRE "DESCRIPCIÓN"   - Crear punto de respaldo
    echo   backup.bat list                         - Listar puntos disponibles
    echo   backup.bat restore NOMBRE               - Restaurar punto de respaldo
    echo %BLUE%=============================================%NC%
    goto :end
)

REM Procesar comandos
if "%~1"=="create" (
    if "%~3"=="" (
        echo %RED%✗ Error: Se requiere NOMBRE y DESCRIPCIÓN para crear un punto de respaldo.%NC%
        echo Ejemplo: backup.bat create v1.0 "Versión inicial"
        goto :end
    )
    call :create_backup "%~2" "%~3"
    goto :end
)

if "%~1"=="list" (
    call :list_backups
    goto :end
)

if "%~1"=="restore" (
    if "%~2"=="" (
        echo %RED%✗ Error: Se requiere NOMBRE para restaurar un punto de respaldo.%NC%
        echo Ejemplo: backup.bat restore v1.0
        goto :end
    )
    call :restore_backup "%~2"
    goto :end
)

echo %RED%✗ Comando desconocido: %1%NC%
echo Usa 'backup.bat' sin argumentos para ver la ayuda.

:end
endlocal