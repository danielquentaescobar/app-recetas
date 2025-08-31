# 🔧 Configuración de Firebase Storage - App Recetas Latinas

## 🚨 PROBLEMA IDENTIFICADO
Error: `[firebase_storage/unauthorized] User is not authorized to perform the desired action.`

## 📋 SOLUCIÓN PASO A PASO

### 1. Configurar Reglas de Firebase Storage

1. **Ir a la Consola de Firebase:**
   - Abre https://console.firebase.google.com/
   - Selecciona tu proyecto: `app-recetas-11a04`

2. **Navegar a Storage:**
   - En el menú lateral, haz clic en "Storage"
   - Ve a la pestaña "Rules"

3. **Actualizar las Reglas:**
   - Reemplaza las reglas existentes con:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Permitir lectura pública de todas las imágenes
    match /{allPaths=**} {
      allow read: if true;
    }
    
    // Permitir subida de imágenes de recetas a usuarios autenticados
    match /recipes/{imageId} {
      allow write: if request.auth != null 
                   && request.auth.uid != null
                   && request.resource.size < 10 * 1024 * 1024  // Máximo 10MB
                   && request.resource.contentType.matches('image/.*');
    }
    
    // Permitir subida de avatares de usuario
    match /users/{userId}/{imageId} {
      allow write: if request.auth != null 
                   && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024  // Máximo 5MB
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

4. **Publicar las Reglas:**
   - Haz clic en el botón "Publicar"

### 2. Verificar Configuración de Autenticación

1. **Asegúrate de que el usuario esté autenticado:**
   - Ve a Authentication > Users
   - Verifica que hay usuarios registrados
   - Confirma que el usuario actual tiene un UID válido

### 3. Verificar Configuración del Proyecto

1. **Configuración Web:**
   - Ve a Project Settings > General
   - Asegúrate de que la configuración web esté correcta
   - Verifica que el Storage bucket esté habilitado

### 4. Configuración Alternativa (Si persiste el problema)

Si las reglas no funcionan, puedes usar temporalmente:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;  // ⚠️ TEMPORAL - Solo para desarrollo
    }
  }
}
```

⚠️ **IMPORTANTE:** Esta configuración permite acceso completo. Úsala solo para pruebas.

## 🔍 CAMBIOS REALIZADOS EN EL CÓDIGO

### FirestoreService.dart - Método uploadImageFromBytes():
- ✅ Agregado manejo mejorado de errores
- ✅ Metadata específica para imágenes JPEG
- ✅ Monitoreo de progreso de subida
- ✅ Diagnósticos detallados de errores
- ✅ Fallback a imagen por defecto si falla

### Pantalla AddRecipe:
- ✅ Uso de Image.memory() compatible con Web
- ✅ Manejo de bytes para previsualización
- ✅ Integración mejorada con uploadImageFromBytes()

## 🧪 CÓMO PROBAR

1. **Configurar las reglas en Firebase Console**
2. **Reiniciar la aplicación Flutter**
3. **Iniciar sesión con un usuario válido**
4. **Intentar agregar una receta con imagen**
5. **Verificar en los logs que no aparezca el error de autorización**

## 📞 SI PERSISTE EL PROBLEMA

1. Verifica que el proyecto Firebase esté correctamente configurado
2. Confirma que el usuario esté autenticado antes de subir
3. Revisa que el bucket de Storage esté habilitado
4. Prueba con las reglas temporales más permisivas

## 🎯 RESULTADO ESPERADO

Después de aplicar estos cambios:
- ✅ Las imágenes se subirán correctamente a Firebase Storage
- ✅ Se mostrará progreso de subida en los logs
- ✅ Si hay error, se usará imagen por defecto automáticamente
- ✅ Los usuarios podrán agregar recetas con imágenes personalizadas
