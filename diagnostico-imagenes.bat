@echo off
echo ===================================
echo   DIAGNOSTICO SISTEMA DE IMAGENES
echo ===================================
echo.

echo 1. Verificando directorio de uploads...
if exist "web\uploads\recipes\" (
    echo ✅ Directorio existe: web\uploads\recipes\
    dir "web\uploads\recipes\" /b
) else (
    echo ❌ Directorio NO existe: web\uploads\recipes\
)
echo.

echo 2. Verificando servidor de uploads...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8085/health' -TimeoutSec 5; Write-Host '✅ Servidor de uploads OK (Puerto 8085)' } catch { Write-Host '❌ Servidor de uploads NO responde' }"
echo.

echo 3. Verificando aplicación Flutter...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:6708' -TimeoutSec 5; Write-Host '✅ Aplicación Flutter OK (Puerto 6708)' } catch { Write-Host '❌ Aplicación Flutter NO responde' }"
echo.

echo 4. URLs importantes:
echo 📱 Aplicación: http://localhost:6708
echo 🔧 Servidor uploads: http://localhost:8085/health
echo 📁 Imágenes: http://localhost:8085/uploads/recipes/
echo.

echo 5. Para subir imágenes:
echo - Ir a la aplicación
echo - Crear/editar receta
echo - Seleccionar imagen
echo - El sistema intentará subirla automáticamente
echo.

pause
