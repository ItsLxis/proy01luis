@echo off
REM USO: Crea un respaldo SQL de la base de datos configurada en .env.
REM REQUISITOS: Docker Desktop iniciado, .env configurado y servicio MySQL.
REM EJECUTAR: bd_backup.bat
REM RESULTADO: El archivo se guarda en backups\mysql_YYYYMMDD_HHMMSS.sql.
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

if not exist "backups" mkdir "backups"

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
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "BACKUP_FILE=backups\mysql_%%I.sql"

echo Creando respaldo: %BACKUP_FILE%
docker compose exec -T mysql mysqldump -u"%DB_USERNAME%" --password="%DB_PASSWORD%" --no-tablespaces --single-transaction --routines --triggers --databases "%DB_DATABASE%" > "%BACKUP_FILE%"
if errorlevel 1 goto :error

for %%I in ("%BACKUP_FILE%") do if %%~zI==0 goto :error

echo Respaldo creado correctamente.
popd
exit /b 0

:error
echo ERROR: No se pudo crear el respaldo.
if exist "%BACKUP_FILE%" del "%BACKUP_FILE%"
popd
exit /b 1

:env_error
echo ERROR: Faltan variables DB_HOST, DB_PORT, DB_DATABASE o DB_USERNAME en .env.
popd
exit /b 1
