@echo off
REM USO: Restaura un archivo SQL en la base de datos configurada en .env.
REM EJECUTAR CON ARCHIVO: bd_restore.bat backups\mysql_YYYYMMDD_HHMMSS.sql
REM EJECUTAR SIN ARGUMENTO: bd_restore.bat y escribir la ruta cuando se solicite.
REM ADVERTENCIA: La restauracion puede sobrescribir datos existentes.
setlocal
pushd "%~dp0"

where docker >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker no esta disponible en el PATH.
    popd
    exit /b 1
)

if not exist ".env" (
    echo ERROR: No existe el archivo .env.
    popd
    exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
    if /I "%%A"=="DB_HOST" set "DB_HOST=%%B"
    if /I "%%A"=="DB_PORT" set "DB_PORT=%%B"
    if /I "%%A"=="DB_DATABASE" set "DB_DATABASE=%%B"
    if /I "%%A"=="DB_USERNAME" set "DB_USERNAME=%%B"
    if /I "%%A"=="DB_PASSWORD" set "DB_PASSWORD=%%B"
)
set "DB_HOST=%DB_HOST:"=%"
set "DB_PORT=%DB_PORT:"=%"
set "DB_DATABASE=%DB_DATABASE:"=%"
set "DB_USERNAME=%DB_USERNAME:"=%"
set "DB_PASSWORD=%DB_PASSWORD:"=%"

if not defined DB_HOST goto :env_error
if not defined DB_PORT goto :env_error
if not defined DB_DATABASE goto :env_error
if not defined DB_USERNAME goto :env_error

docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker Desktop no esta iniciado.
    popd
    exit /b 1
)

set "BACKUP_FILE=%~1"
if not defined BACKUP_FILE (
    echo.
    echo Escribe la ruta del archivo SQL que deseas restaurar.
    set /p "BACKUP_FILE=Archivo: "
)

if not defined BACKUP_FILE (
    echo ERROR: No se indico ningun archivo de respaldo.
    popd
    exit /b 1
)

if not exist "%BACKUP_FILE%" (
    echo ERROR: No existe el archivo "%BACKUP_FILE%".
    popd
    exit /b 1
)

echo Iniciando el servicio MySQL...
docker compose up -d mysql
if errorlevel 1 goto :error

echo Esperando a que MySQL este disponible...
for /l %%I in (1,1,30) do (
    docker compose exec -T mysql mysqladmin ping -h "%DB_HOST%" -P "%DB_PORT%" -u"%DB_USERNAME%" --password="%DB_PASSWORD%" --silent >nul 2>&1
    if not errorlevel 1 goto :mysql_ready
    >nul timeout /t 2
)
echo ERROR: MySQL no estuvo disponible a tiempo.
goto :error

:mysql_ready
echo Restaurando "%BACKUP_FILE%" en la base de datos %DB_DATABASE%...
type "%BACKUP_FILE%" | docker compose exec -T mysql mysql -u"%DB_USERNAME%" --password="%DB_PASSWORD%"
if errorlevel 1 goto :error

echo Base de datos restaurada correctamente.
popd
exit /b 0

:error
echo ERROR: No se pudo restaurar la base de datos.
popd
exit /b 1

:env_error
echo ERROR: Faltan variables DB_HOST, DB_PORT, DB_DATABASE o DB_USERNAME en .env.
popd
exit /b 1
