@echo off
REM USO: Detiene y elimina los contenedores del proyecto.
REM EJECUTAR: docker_stop.bat
REM NOTA: El volumen de MySQL se conserva; los datos no se eliminan.
REM PARA BORRAR DATOS: usar docker compose down -v de forma consciente.
setlocal
pushd "%~dp0"

docker compose down
if errorlevel 1 (
    echo ERROR: No se pudieron detener los contenedores.
    popd
    exit /b 1
)

echo Contenedores detenidos. Los datos de MySQL se conservaron.
popd
exit /b 0
