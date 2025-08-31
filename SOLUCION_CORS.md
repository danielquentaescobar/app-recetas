# 🚨 SOLUCIÓN PROBLEMA CORS - App Recetas

## 📋 Diagnóstico del Problema

### ¿Qué es CORS?
CORS (Cross-Origin Resource Sharing) es una política de seguridad que bloquea requests desde un origen (localhost:6708) hacia otro origen (Firebase Storage) por motivos de seguridad.

### ¿Por qué ocurre este error?
```
Access to XMLHttpRequest at 'https://firebasestorage.googleapis.com/...' 
from origin 'http://localhost:6708' has been blocked by CORS policy
```

Firebase Storage por defecto no permite uploads desde localhost, solo desde dominios autorizados.

## 🔧 SOLUCIONES DISPONIBLES

### ✅ Solución 1: Configurar CORS en Firebase Storage (RECOMENDADA)

#### Opción A: Google Cloud Shell (Más fácil)
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: `app-recetas-11a04`
3. Haz clic en el icono de terminal (Cloud Shell) en la esquina superior derecha
4. Ejecuta estos comandos:

```bash
# Crear archivo de configuración CORS
cat > cors.json << 'EOF'
[
  {
    "origin": ["http://localhost:6708", "http://localhost:*", "https://*.web.app"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin", "x-goog-resumable"]
  }
]
EOF

# Aplicar configuración CORS al bucket
gsutil cors set cors.json gs://app-recetas-11a04.firebasestorage.app

# Verificar que se aplicó correctamente
gsutil cors get gs://app-recetas-11a04.firebasestorage.app
```

#### Opción B: Google Cloud SDK Local
```bash
# 1. Instalar Google Cloud SDK (si no está instalado)
# https://cloud.google.com/sdk/docs/install

# 2. Autenticarse
gcloud auth login

# 3. Configurar proyecto
gcloud config set project app-recetas-11a04

# 4. Crear archivo cors.json
echo '[
  {
    "origin": ["http://localhost:6708", "http://localhost:*", "https://*.web.app"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"], 
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin", "x-goog-resumable"]
  }
]' > cors.json

# 5. Aplicar CORS
gsutil cors set cors.json gs://app-recetas-11a04.firebasestorage.app
```

### ✅ Solución 2: Usar Puerto Estándar (Temporal)

Cambiar el puerto de la aplicación a uno estándar:

```bash
# Parar la aplicación actual y ejecutar en puerto 80
flutter run -d chrome --web-port 80

# O puerto 8080
flutter run -d chrome --web-port 8080
```

### ✅ Solución 3: Testing con Imagen Placeholder

La aplicación ahora maneja automáticamente errores CORS usando imágenes placeholder temporales:

- ✅ Detecta errores CORS automáticamente
- ✅ Usa imagen temporal mientras se configura CORS  
- ✅ Muestra mensajes informativos al usuario
- ✅ Permite guardar la receta sin fallar

## 🔄 COMPORTAMIENTO ACTUAL

### Con Error CORS:
1. Usuario selecciona imagen del dispositivo ✅
2. Sistema intenta subir a Firebase Storage ⚠️
3. CORS bloquea el upload ❌
4. Sistema detecta error CORS automáticamente ✅
5. Usa imagen placeholder temporal ✅
6. Muestra mensaje informativo ✅
7. Receta se guarda correctamente ✅

### Después de Configurar CORS:
1. Usuario selecciona imagen del dispositivo ✅
2. Sistema sube imagen a Firebase Storage ✅
3. Obtiene URL real de Firebase ✅
4. Muestra mensaje de éxito ✅
5. Receta se guarda con imagen real ✅

## ⏱️ Tiempo de Propagación

- **Google Cloud Shell**: 2-5 minutos
- **Google Cloud SDK**: 2-5 minutos  
- **Cambios de DNS**: Hasta 10 minutos

## 🧪 Testing

### Verificar CORS configurado:
```bash
gsutil cors get gs://app-recetas-11a04.firebasestorage.app
```

### Verificar en navegador:
1. Abrir DevTools (F12)
2. Ir a Network tab
3. Crear una receta con imagen del dispositivo
4. Buscar requests a `firebasestorage.googleapis.com`
5. ✅ Status 200 = CORS funcionando
6. ❌ Status 0/Failed = CORS bloqueado

## 📞 SIGUIENTE PASO

**Opción Recomendada**: Configurar CORS usando Google Cloud Shell (Solución 1A)

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Abre Cloud Shell
3. Ejecuta los comandos de CORS
4. Reinicia la aplicación Flutter
5. Prueba subir una imagen del dispositivo

Una vez configurado CORS, las imágenes se subirán correctamente a Firebase Storage y aparecerán en la aplicación.
