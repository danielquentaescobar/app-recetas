@echo off
echo ===================================
echo 🚀 APP RECETAS - SISTEMA DINÁMICO
echo ===================================

REM Verificar que estamos en el directorio correcto
if not exist "pubspec.yaml" (
    echo ❌ Error: Ejecuta este script desde la raíz del proyecto
    echo    donde se encuentra pubspec.yaml
    pause
    exit /b 1
)

echo.
echo 📋 1. Preparando entorno...

REM Crear directorio de uploads si no existe
if not exist "web\uploads\recipes" (
    echo 📁 Creando directorio de uploads...
    mkdir "web\uploads\recipes" 2>nul
)

REM Limpiar procesos antiguos de Dart (opcional)
taskkill /f /im dart.exe 2>nul >nul

echo ✅ Entorno preparado

echo.
echo 📦 2. Instalando dependencias Flutter...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Error instalando dependencias
    echo 💡 Intenta ejecutar: flutter clean y flutter pub get
    pause
    exit /b 1
)
echo ✅ Dependencias instaladas

echo.
echo 🖼️ 3. Iniciando servidor de imágenes dinámico...
start "Servidor de Imágenes Dinámico" cmd /c "echo Iniciando servidor dinámico... && dart run bin/dynamic_upload_server.dart && echo Servidor detenido && pause"

echo.
echo ⏳ 4. Esperando inicialización del servidor...
timeout /t 4 /nobreak > nul

REM Verificar que el archivo de puerto se creó
if exist "web\server_port.txt" (
    set /p SERVER_PORT=<web\server_port.txt
    echo ✅ Servidor de imágenes: http://localhost:!SERVER_PORT!
) else (
    echo ⚠️ Servidor iniciando... puerto será detectado automáticamente
)

echo.
echo 🌐 5. Iniciando Flutter Web con detección automática...
echo.
echo 🎯 CONFIGURACIÓN:
echo    📱 Flutter: Puerto automático (Chrome)
echo    🖼️ Imágenes: Puerto dinámico (detectado automáticamente)
echo    🔄 Sincronización: Automática via DynamicImageService
echo.
echo 💡 La aplicación se abrirá automáticamente en Chrome
echo 💡 Las imágenes funcionarán sin configuración adicional
echo 💡 Usa Ctrl+C para detener Flutter (el servidor seguirá corriendo)
echo.

REM Ejecutar Flutter
call flutter run -d chrome --web-port 0 --web-renderer html

echo.
echo 🛑 Flutter detenido
echo.
echo 🧹 ¿Quieres detener también el servidor de imágenes? (S/N)
choice /c SN /m "S=Sí detener todo, N=Mantener servidor corriendo"
if %ERRORLEVEL%==1 (
    echo 🛑 Deteniendo servidor de imágenes...
    taskkill /f /im dart.exe 2>nul >nul
    echo ✅ Todo detenido
) else (
    echo 💡 Servidor de imágenes sigue corriendo en segundo plano
    echo 💡 Para detenerlo manualmente: taskkill /f /im dart.exe
)

echo.
echo 👋 ¡Gracias por usar App Recetas!
pause
