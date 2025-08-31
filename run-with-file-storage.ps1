# Script de PowerShell para iniciar App Recetas con almacenamiento de archivos físicos
param(
    [switch]$SkipChecks,
    [int]$UploadPort = 8081,
    [int]$FlutterPort = 6708
)

Write-Host "🚀 Iniciando App Recetas con archivos físicos..." -ForegroundColor Green
Write-Host ""

# Verificar directorio del proyecto
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: Ejecuta este script desde la raíz del proyecto app-recetas" -ForegroundColor Red
    Write-Host "   donde se encuentra el archivo pubspec.yaml" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Crear directorio de uploads
$uploadDir = "web\uploads\recipes"
if (-not (Test-Path $uploadDir)) {
    Write-Host "📁 Creando directorio de uploads..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $uploadDir -Force | Out-Null
    Write-Host "✅ Directorio creado: $uploadDir" -ForegroundColor Green
}

# Mostrar configuración
Write-Host "📋 CONFIGURACIÓN:" -ForegroundColor Cyan
Write-Host "   🔧 Método: Archivos físicos" -ForegroundColor White
Write-Host "   📁 Directorio: $uploadDir" -ForegroundColor White
Write-Host "   🌐 URLs: http://localhost:$FlutterPort/uploads/recipes/" -ForegroundColor White
Write-Host "   🚀 Servidor uploads: http://localhost:$UploadPort/upload-image" -ForegroundColor White
Write-Host ""

# Función para limpiar procesos
function Stop-Services {
    Write-Host "🛑 Deteniendo servicios..." -ForegroundColor Yellow
    
    # Buscar y terminar procesos dart relacionados con el servidor
    Get-Process -Name "dart" -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandLine -like "*upload_server.dart*"
    } | Stop-Process -Force -ErrorAction SilentlyContinue
    
    Write-Host "✅ Servicios detenidos" -ForegroundColor Green
}

# Configurar limpieza al salir
$null = Register-EngineEvent PowerShell.Exiting -Action { Stop-Services }

try {
    # Iniciar servidor de uploads
    Write-Host "🚀 Iniciando servidor de uploads en puerto $UploadPort..." -ForegroundColor Green
    
    $uploadServerJob = Start-Job -ScriptBlock {
        param($UploadPort)
        Set-Location $using:PWD
        dart bin/upload_server.dart
    } -ArgumentList $UploadPort
    
    # Esperar un momento
    Start-Sleep -Seconds 2
    
    # Verificar que el job está corriendo
    if ($uploadServerJob.State -eq "Running") {
        Write-Host "✅ Servidor de uploads iniciado correctamente" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Advertencia: El servidor de uploads podría no haberse iniciado correctamente" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "🎨 Iniciando aplicación Flutter en puerto $FlutterPort..." -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 La aplicación se abrirá en: http://localhost:$FlutterPort" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "⚡ IMPORTANTE:" -ForegroundColor Yellow
    Write-Host "   - Mantén esta ventana abierta mientras uses la app" -ForegroundColor White
    Write-Host "   - El servidor de uploads debe estar corriendo para guardar imágenes" -ForegroundColor White
    Write-Host "   - Presiona Ctrl+C para detener todo" -ForegroundColor White
    Write-Host ""
    
    # Iniciar Flutter
    & flutter run -d web-server --web-port $FlutterPort
    
} catch {
    Write-Host "❌ Error iniciando servicios: $_" -ForegroundColor Red
} finally {
    # Limpiar
    Write-Host ""
    Write-Host "🛑 Deteniendo servidor de uploads..." -ForegroundColor Yellow
    
    if ($uploadServerJob) {
        Stop-Job $uploadServerJob -ErrorAction SilentlyContinue
        Remove-Job $uploadServerJob -Force -ErrorAction SilentlyContinue
    }
    
    Stop-Services
    
    Write-Host ""
    Write-Host "👋 Aplicación terminada. ¡Gracias por usar App Recetas!" -ForegroundColor Green
}

Read-Host "Presiona Enter para salir"
