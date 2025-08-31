@echo off
echo ===================================
echo 🚀 INICIANDO APP DE RECETAS FLUTTER
echo ===================================

echo.
echo 📋 1. Verificando dependencias...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Error instalando dependencias Flutter
    pause
    exit /b 1
)

echo.
echo 🖼️ 2. Iniciando servidor de imágenes dinámico...
start "Servidor de Imágenes" cmd /c "dart run bin/dynamic_upload_server.dart && pause"

echo.
echo ⏳ 3. Esperando que el servidor esté listo...
timeout /t 3 /nobreak > nul

echo.
echo 🌐 4. Iniciando aplicación Flutter Web...
echo.
echo 💡 La aplicación se abrirá automáticamente en el navegador
echo 💡 El servidor de imágenes detectará el puerto automáticamente
echo 💡 Presiona Ctrl+C en cualquier ventana para detener todo
echo.

call flutter run -d chrome --web-port 0

echo.
echo 🛑 Aplicación detenida
echo 💡 El servidor de imágenes seguirá ejecutándose en segundo plano
echo 💡 Para detenerlo completamente, cierra todas las ventanas de terminal
pause
