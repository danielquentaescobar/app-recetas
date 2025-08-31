# Configuración de CORS para Firebase Storage

## Problema
Error CORS al subir imágenes desde localhost a Firebase Storage:
```
Access to XMLHttpRequest at 'https://firebasestorage.googleapis.com/...' from origin 'http://localhost:6708' has been blocked by CORS policy
```

## Solución 1: Configurar CORS en Firebase Storage (Recomendado)

### Opción A: Usar Google Cloud Shell
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto Firebase
3. Abre Cloud Shell (icono terminal en la esquina superior derecha)
4. Ejecuta estos comandos:

```bash
# Crear archivo cors.json
cat > cors.json << EOF
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin", "x-goog-resumable"]
  }
]
EOF

# Aplicar configuración CORS
gsutil cors set cors.json gs://app-recetas-11a04.firebasestorage.app
```

### Opción B: Usar Google Cloud SDK Local
1. Instala [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
2. Autentícate: `gcloud auth login`
3. Selecciona proyecto: `gcloud config set project app-recetas-11a04`
4. Crea archivo cors.json:

```json
[
  {
    "origin": ["http://localhost:6708", "http://localhost:*", "https://*.web.app"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin", "x-goog-resumable"]
  }
]
```

5. Aplica CORS: `gsutil cors set cors.json gs://app-recetas-11a04.firebasestorage.app`

## Solución 2: Implementar Upload Alternativo (Temporal)

### Usar Firebase Admin o cambiar puerto
- Cambiar a puerto 80/443 (requiere permisos admin)
- Usar Firebase Functions como proxy
- Implementar upload en chunks más pequeños

## Verificación
Después de configurar CORS, verifica con:
```bash
gsutil cors get gs://app-recetas-11a04.firebasestorage.app
```

## Notas
- La configuración CORS puede tardar algunos minutos en propagarse
- Para producción, restringe los origins a dominios específicos
- Reinicia la aplicación después de los cambios
