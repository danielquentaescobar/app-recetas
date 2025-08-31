# 🔥 Guía Completa para Configurar Firebase en App Recetas

## 📋 Resumen
Esta guía te ayudará a configurar Firebase Authentication, Cloud Firestore y Firebase Storage para tu aplicación de recetas latinoamericanas en Flutter.

## 🚀 Paso 1: Crear Proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Crear un proyecto"
3. Nombre del proyecto: `app-recetas-latinas`
4. Habilita Google Analytics (opcional)
5. Selecciona tu cuenta de Analytics
6. Haz clic en "Crear proyecto"

## 📱 Paso 2: Agregar Aplicación Android

1. En el dashboard del proyecto, haz clic en el ícono de Android
2. Nombre del paquete Android: `com.example.app_recetas`
3. Alias de la app: `App Recetas Latinas`
4. Certificado de firma SHA-1 (opcional para desarrollo)
5. Descarga el archivo `google-services.json`
6. Coloca `google-services.json` en `android/app/`

## 🍎 Paso 3: Agregar Aplicación iOS (Opcional)

1. Haz clic en el ícono de iOS
2. Bundle ID: `com.example.appRecetas`
3. Alias de la app: `App Recetas Latinas`
4. Descarga `GoogleService-Info.plist`
5. Coloca el archivo en `ios/Runner/`

## 🔧 Paso 4: Configurar Flutter

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Iniciar sesión en Firebase
firebase login

# Configurar proyecto Flutter con Firebase
flutterfire configure
```

Selecciona:
- ✅ android
- ✅ ios (si aplica)
- Proyecto: `app-recetas-latinas`

## 🔐 Paso 5: Configurar Authentication

### En Firebase Console:
1. Ve a **Authentication** → **Get started**
2. En la pestaña **Sign-in method**, habilita:
   - ✅ **Email/Password**
   - ✅ **Google** (opcional)
3. En **Settings** → **Authorized domains**, verifica que `localhost` esté incluido

### Reglas de Authentication:
```javascript
// Firebase Authentication Rules (automáticas)
// Los usuarios pueden crear cuentas y autenticarse
```

## 🗄️ Paso 6: Configurar Cloud Firestore

### Crear Base de Datos:
1. Ve a **Firestore Database** → **Create database**
2. Selecciona **Start in test mode** (por ahora)
3. Selecciona ubicación: `us-central1` o la más cercana

### Estructura de Colecciones y Documentos:

#### 🧑‍🍳 Colección: `users`
```javascript
// Documento de usuario (ID = uid de Firebase Auth)
{
  "id": "user_uid_here",
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "photoUrl": "https://example.com/photo.jpg", // opcional
  "favoriteRecipes": ["recipe_id_1", "recipe_id_2"], // array de IDs
  "createdAt": "2025-08-24T10:00:00Z", // timestamp
  "updatedAt": "2025-08-24T10:00:00Z", // timestamp
  "isActive": true,
  "preferences": {
    "region": "México",
    "dietaryRestrictions": ["vegetariano"], // array
    "notifications": true
  }
}
```

#### 🍳 Colección: `recipes`
```javascript
// Documento de receta
{
  "id": "recipe_id_auto_generated",
  "title": "Empanadas Argentinas",
  "description": "Deliciosas empanadas tradicionales argentinas con carne",
  "imageUrl": "https://example.com/empanadas.jpg",
  "authorId": "user_uid_here", // referencia al usuario
  "authorName": "Juan Pérez",
  "ingredients": [
    "2 tazas de harina",
    "500g de carne molida",
    "1 cebolla grande"
  ],
  "instructions": [
    "Preparar la masa mezclando harina con agua",
    "Cocinar la carne con cebolla",
    "Armar las empanadas y hornear"
  ],
  "preparationTime": 30, // minutos
  "cookingTime": 45, // minutos
  "servings": 6,
  "difficulty": "Intermedio", // Fácil, Intermedio, Difícil
  "region": "Argentina",
  "tags": ["tradicional", "carne", "horneado"],
  "categories": ["Plato Principal"],
  "rating": 4.5, // promedio de reseñas
  "reviewsCount": 23,
  "likedBy": ["user_id_1", "user_id_2"], // array de user IDs
  "createdAt": "2025-08-24T10:00:00Z",
  "updatedAt": "2025-08-24T10:00:00Z",
  "isPublic": true,
  "nutritionalInfo": { // opcional, de Spoonacular API
    "calories": 320,
    "protein": 15,
    "carbs": 25,
    "fat": 18
  }
}
```

#### ⭐ Colección: `reviews`
```javascript
// Documento de reseña
{
  "id": "review_id_auto_generated",
  "recipeId": "recipe_id_here",
  "userId": "user_uid_here",
  "userName": "María García",
  "userPhotoUrl": "https://example.com/maria.jpg", // opcional
  "rating": 5, // 1-5 estrellas
  "comment": "¡Excelente receta! Quedaron perfectas",
  "createdAt": "2025-08-24T10:00:00Z",
  "updatedAt": "2025-08-24T10:00:00Z",
  "isVisible": true
}
```

#### 📋 Colección: `categories` (opcional)
```javascript
// Documento de categoría
{
  "id": " ",
  "name": "Desayuno",
  "description": "Recetas para el desayuno",
  "imageUrl": "https://example.com/breakfast.jpg",
  "recipeCount": 45,
  "isActive": true
}
```

### Reglas de Seguridad de Firestore:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Reglas para usuarios
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reglas para recetas
    match /recipes/{recipeId} {
      // Cualquiera puede leer recetas públicas
      allow read: if resource.data.isPublic == true;
      
      // Solo el autor puede escribir/editar/eliminar sus recetas
      allow create: if request.auth != null && 
                   request.auth.uid == request.resource.data.authorId;
      
      allow update, delete: if request.auth != null && 
                           request.auth.uid == resource.data.authorId;
    }
    
    // Reglas para reseñas
    match /reviews/{reviewId} {
      // Cualquiera puede leer reseñas visibles
      allow read: if resource.data.isVisible == true;
      
      // Solo usuarios autenticados pueden crear reseñas
      allow create: if request.auth != null && 
                   request.auth.uid == request.resource.data.userId;
      
      // Solo el autor puede editar/eliminar su reseña
      allow update, delete: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
    }
    
    // Reglas para categorías (solo lectura pública)
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if false; // Solo administradores via backend
    }
  }
}
```

## 📦 Paso 7: Configurar Firebase Storage

### Crear Storage:
1. Ve a **Storage** → **Get started**
2. Selecciona **Start in test mode**
3. Selecciona ubicación: misma que Firestore

### Estructura de Carpetas:
```
gs://app-recetas-latinas.appspot.com/
├── users/
│   ├── {userId}/
│   │   └── profile.jpg
├── recipes/
│   ├── {recipeId}/
│   │   ├── main.jpg
│   │   ├── step1.jpg
│   │   └── step2.jpg
└── categories/
    └── {categoryId}/
        └── icon.jpg
```

### Reglas de Storage:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Reglas para fotos de perfil
    match /users/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reglas para imágenes de recetas
    match /recipes/{recipeId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Reglas para imágenes de categorías (solo lectura)
    match /categories/{allPaths=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

## 🔑 Paso 8: Configurar Spoonacular API

1. Ve a [Spoonacular API](https://spoonacular.com/food-api)
2. Crea una cuenta gratuita
3. Obtén tu API key
4. En tu proyecto Flutter, actualiza `lib/utils/constants.dart`:

```dart
static const String spoonacularApiKey = 'TU_API_KEY_AQUÍ';
```

## 🧪 Paso 9: Datos de Prueba

### Crear Usuario de Prueba:
```javascript
// En Authentication → Users → Add user
Email: test@example.com
Password: test123456
```

### Insertar Recetas de Ejemplo:
```javascript
// En Firestore → recipes → Add document
{
  "title": "Tacos al Pastor",
  "description": "Auténticos tacos al pastor mexicanos",
  "imageUrl": "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b",
  "authorId": "USER_ID_DEL_TEST",
  "authorName": "Chef Mexicano",
  "ingredients": [
    "1 kg de carne de cerdo",
    "Tortillas de maíz",
    "Piña natural",
    "Cebolla blanca",
    "Cilantro fresco"
  ],
  "instructions": [
    "Marinar la carne con especias",
    "Cocinar en trompo o sartén",
    "Cortar en trozos pequeños",
    "Servir en tortillas con piña y cebolla"
  ],
  "preparationTime": 20,
  "cookingTime": 30,
  "servings": 4,
  "difficulty": "Intermedio",
  "region": "México",
  "tags": ["tradicional", "mexicana", "street food"],
  "categories": ["Plato Principal"],
  "rating": 0,
  "reviewsCount": 0,
  "likedBy": [],
  "createdAt": "2025-08-24T10:00:00Z",
  "updatedAt": "2025-08-24T10:00:00Z",
  "isPublic": true
}
```

## 🔧 Paso 10: Comandos Finales

```bash
# En el directorio del proyecto
cd app-recetas

# Instalar dependencias
flutter pub get

# Ejecutar la app
flutter run
```

## ✅ Verificación

Tu aplicación debería poder:
- ✅ Registrar nuevos usuarios
- ✅ Iniciar sesión
- ✅ Crear recetas
- ✅ Ver recetas existentes
- ✅ Agregar reseñas
- ✅ Buscar recetas
- ✅ Integrar con Spoonacular API

## 🆘 Solución de Problemas

### Error común 1: "FirebaseOptions not found"
```bash
# Volver a ejecutar
flutterfire configure
```

### Error común 2: "google-services.json not found"
- Verifica que el archivo esté en `android/app/google-services.json`

### Error común 3: Problemas de red
- Verifica las reglas de Firestore
- Asegúrate de que test mode esté habilitado

### Error común 4: API de Spoonacular no funciona
- Verifica que la API key sea correcta
- Revisa el límite de requests (plan gratuito: 150 requests/día)

---

¡Con esta configuración tendrás una base de datos completamente funcional para tu app de recetas! 🎉
