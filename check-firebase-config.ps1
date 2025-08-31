# Script para verificar configuración de Firebase Storage
# PowerShell Script - App Recetas Latinas

Write-Host "🔧 Verificador de Configuración Firebase Storage" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Verificar que Flutter esté instalado
Write-Host "`n📱 Verificando Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>$null
    if ($flutterVersion) {
        Write-Host "✅ Flutter está instalado correctamente" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Flutter no está instalado o no está en PATH" -ForegroundColor Red
    exit 1
}

# Verificar archivos de configuración Firebase
Write-Host "`n🔥 Verificando archivos de configuración Firebase..." -ForegroundColor Yellow

$webConfig = "web/index.html"
$androidConfig = "android/app/google-services.json"

if (Test-Path $webConfig) {
    Write-Host "✅ Configuración web encontrada: $webConfig" -ForegroundColor Green
} else {
    Write-Host "❌ Configuración web no encontrada: $webConfig" -ForegroundColor Red
}

if (Test-Path $androidConfig) {
    Write-Host "✅ Configuración Android encontrada: $androidConfig" -ForegroundColor Green
} else {
    Write-Host "❌ Configuración Android no encontrada: $androidConfig" -ForegroundColor Red
}

# Verificar dependencias Firebase en pubspec.yaml
Write-Host "`n📦 Verificando dependencias Firebase..." -ForegroundColor Yellow
$pubspec = Get-Content "pubspec.yaml" -Raw
$firebaseDeps = @("firebase_core", "firebase_auth", "cloud_firestore", "firebase_storage")

foreach ($dep in $firebaseDeps) {
    if ($pubspec -match $dep) {
        Write-Host "✅ $dep está en pubspec.yaml" -ForegroundColor Green
    } else {
        Write-Host "❌ $dep NO está en pubspec.yaml" -ForegroundColor Red
    }
}

Write-Host "`n🔧 PASOS PARA SOLUCIONAR PROBLEMA DE STORAGE:" -ForegroundColor Cyan
Write-Host "1. Ve a https://console.firebase.google.com/" -ForegroundColor White
Write-Host "2. Selecciona tu proyecto: app-recetas-11a04" -ForegroundColor White
Write-Host "3. Ve a Storage > Rules" -ForegroundColor White
Write-Host "4. Copia las reglas del archivo: firebase-storage-rules.txt" -ForegroundColor White
Write-Host "5. Haz clic en 'Publicar'" -ForegroundColor White

Write-Host "`n📋 REGLAS RECOMENDADAS PARA FIREBASE STORAGE:" -ForegroundColor Cyan
Write-Host @"
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
    }
    match /recipes/{imageId} {
      allow write: if request.auth != null 
                   && request.auth.uid != null
                   && request.resource.size < 10 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
"@ -ForegroundColor White

Write-Host "`n🚀 COMANDOS ÚTILES:" -ForegroundColor Cyan
Write-Host "flutter clean && flutter pub get" -ForegroundColor Yellow
Write-Host "flutter run -d chrome" -ForegroundColor Yellow
Write-Host "flutter build apk --release" -ForegroundColor Yellow

Write-Host "`n✅ Script completado. Revisa los puntos marcados con ❌" -ForegroundColor Green
