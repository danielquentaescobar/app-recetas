#!/bin/bash
# 🔥 Script de Configuración Automatizada para Firebase

echo "🚀 Iniciando configuración de Firebase para App Recetas..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar errores
error() {
    echo -e "${RED}❌ Error: $1${NC}"
    exit 1
}

# Función para mostrar éxito
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Función para mostrar advertencias
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    error "Node.js no está instalado. Instálalo desde https://nodejs.org/"
fi

# Verificar si Flutter está instalado
if ! command -v flutter &> /dev/null; then
    error "Flutter no está instalado. Instálalo desde https://flutter.dev/"
fi

# Instalar Firebase CLI
echo "📦 Instalando Firebase CLI..."
npm install -g firebase-tools || error "No se pudo instalar Firebase CLI"
success "Firebase CLI instalado"

# Instalar FlutterFire CLI
echo "📦 Instalando FlutterFire CLI..."
dart pub global activate flutterfire_cli || error "No se pudo instalar FlutterFire CLI"
success "FlutterFire CLI instalado"

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    error "Este script debe ejecutarse desde el directorio raíz del proyecto Flutter"
fi

# Obtener dependencias de Flutter
echo "📦 Obteniendo dependencias de Flutter..."
flutter pub get || error "No se pudieron obtener las dependencias"
success "Dependencias de Flutter obtenidas"

# Mensaje para el usuario
echo ""
echo "🎉 Configuración inicial completada!"
echo ""
echo "📋 Pasos restantes (debes hacerlos manualmente):"
echo "1. Ve a https://console.firebase.google.com/"
echo "2. Crea un nuevo proyecto llamado 'app-recetas-latinas'"
echo "3. Ejecuta: firebase login"
echo "4. Ejecuta: flutterfire configure"
echo "5. Sigue las instrucciones en firebase-setup-instructions.md"
echo ""
warning "No olvides configurar tu API key de Spoonacular en lib/utils/constants.dart"
echo ""
success "¡Listo para configurar Firebase!"
