@echo off
REM USO: Inicia el entorno Laravel y MySQL con Docker.
REM REQUISITOS: Docker Desktop iniciado y archivo .env configurado.
REM EJECUTAR: docker_start.bat
REM RESULTADO: La aplicacion queda disponible en http://localhost:8000.
setlocal
pushd "%~dp0"

where docker >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker no esta disponible en el PATH.
    popd
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker Desktop no esta iniciado.
    popd
    exit /b 1
)

echo [1/6] Construyendo la imagen de Laravel...
docker compose build
if errorlevel 1 goto :error

echo [2/6] Iniciando MySQL...
docker compose up -d mysql
if errorlevel 1 goto :error

echo [3/6] Instalando dependencias PHP...
docker compose run --rm app composer install --no-interaction
if errorlevel 1 goto :error

echo [4/6] Generando la clave de Laravel si es necesario...
findstr /b /c:"APP_KEY=base64:" .env >nul 2>&1
if errorlevel 1 (
    docker compose run --rm app php artisan key:generate --force
    if errorlevel 1 goto :error
) else (
    echo La clave de Laravel ya existe; se conserva.
)

echo [5/6] Ejecutando migraciones...
docker compose run --rm app php artisan migrate --force
if errorlevel 1 goto :error

echo [6/6] Iniciando la aplicacion...
docker compose up -d app
if errorlevel 1 goto :error

echo.
echo Entorno listo: http://localhost:8000
popd
exit /b 0

:error
echo.
echo ERROR: La preparacion del entorno fallo.
popd
exit /b 1
