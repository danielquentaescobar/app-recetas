# 🔥 Script de Configuración para Firebase en Windows PowerShell

Write-Host "🚀 Iniciando configuración de Firebase para App Recetas..." -ForegroundColor Green

# Función para mostrar errores
function Show-Error {
    param([string]$Message)
    Write-Host "❌ Error: $Message" -ForegroundColor Red
    exit 1
}

# Función para mostrar éxito
function Show-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

# Función para mostrar advertencias
function Show-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

# Verificar si Node.js está instalado
try {
    $nodeVersion = node --version
    Show-Success "Node.js encontrado: $nodeVersion"
} catch {
    Show-Error "Node.js no está instalado. Instálalo desde https://nodejs.org/"
}

# Verificar si Flutter está instalado
try {
    $flutterVersion = flutter --version
    Show-Success "Flutter encontrado"
} catch {
    Show-Error "Flutter no está instalado. Instálalo desde https://flutter.dev/"
}

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "pubspec.yaml")) {
    Show-Error "Este script debe ejecutarse desde el directorio raíz del proyecto Flutter"
}

# Instalar Firebase CLI
Write-Host "📦 Instalando Firebase CLI..." -ForegroundColor Cyan
try {
    npm install -g firebase-tools
    Show-Success "Firebase CLI instalado"
} catch {
    Show-Error "No se pudo instalar Firebase CLI"
}

# Instalar FlutterFire CLI
Write-Host "📦 Instalando FlutterFire CLI..." -ForegroundColor Cyan
try {
    dart pub global activate flutterfire_cli
    Show-Success "FlutterFire CLI instalado"
} catch {
    Show-Error "No se pudo instalar FlutterFire CLI"
}

# Obtener dependencias de Flutter
Write-Host "📦 Obteniendo dependencias de Flutter..." -ForegroundColor Cyan
try {
    flutter pub get
    Show-Success "Dependencias de Flutter obtenidas"
} catch {
    Show-Error "No se pudieron obtener las dependencias"
}

# Mensaje final
Write-Host ""
Write-Host "🎉 Configuración inicial completada!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Pasos restantes (debes hacerlos manualmente):" -ForegroundColor Cyan
Write-Host "1. Ve a https://console.firebase.google.com/"
Write-Host "2. Crea un nuevo proyecto llamado 'app-recetas-latinas'"
Write-Host "3. Ejecuta: firebase login"
Write-Host "4. Ejecuta: flutterfire configure"
Write-Host "5. Sigue las instrucciones en firebase-setup-instructions.md"
Write-Host ""
Show-Warning "No olvides configurar tu API key de Spoonacular en lib/utils/constants.dart"
Write-Host ""
Show-Success "¡Listo para configurar Firebase!"

# Pausa para que el usuario pueda leer el mensaje
Write-Host ""
Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
