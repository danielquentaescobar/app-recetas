@echo off
echo 🚀 Iniciando sistema de archivos físicos para App Recetas...
echo.

REM Verificar que estamos en el directorio correcto
if not exist "pubspec.yaml" (
    echo ❌ Error: Ejecuta este script desde la raíz del proyecto app-recetas
    echo    donde se encuentra el archivo pubspec.yaml
    pause
    exit /b 1
)

REM Crear directorio de uploads si no existe
if not exist "web\uploads\recipes" (
    echo 📁 Creando directorio de uploads...
    mkdir "web\uploads\recipes"
    echo ✅ Directorio creado: web\uploads\recipes\
)

REM Mostrar configuración actual
echo 📋 CONFIGURACIÓN ACTUAL:
echo    🔧 Método: Archivos físicos
echo    📁 Directorio: web\uploads\recipes\
echo    🌐 URLs: http://localhost:6708/uploads/recipes/
echo    🚀 Servidor uploads: http://localhost:8081/upload-image
echo.

REM Función para limpiar procesos al salir
echo 🎯 Iniciando servicios...
echo.

REM Iniciar servidor de uploads en background
echo 🚀 Iniciando servidor de uploads (puerto 8080)...
start "Servidor de Uploads" /min dart bin/upload_server.dart

REM Esperar un momento para que el servidor se inicie
timeout /t 3 /nobreak >nul

REM Verificar que el servidor se inició
echo 🔍 Verificando servidor de uploads...

REM Iniciar aplicación Flutter
echo 🎨 Iniciando aplicación Flutter (puerto 6708)...
echo.
echo 💡 La aplicación se abrirá en: http://localhost:6708
echo.
echo ⚡ IMPORTANTE:
echo    - Mantén ambas ventanas abiertas
echo    - El servidor de uploads debe estar corriendo para guardar imágenes
echo    - Presiona Ctrl+C en cualquier ventana para detener todo
echo.

flutter run -d web-server --web-port 6708

REM Si Flutter termina, intentar cerrar el servidor
echo.
echo 🛑 Cerrando servidor de uploads...
taskkill /f /im dart.exe 2>nul

echo.
echo 👋 Aplicación terminada. ¡Gracias por usar App Recetas!
pause
