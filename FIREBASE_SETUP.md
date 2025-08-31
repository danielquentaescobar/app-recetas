# Índices de Firestore Requeridos

## Para ejecutar las recetas desde Firebase, necesitas crear estos índices:

### 1. Índice para recetas públicas ordenadas por fecha
```
Collection: recipes
Fields: 
- isPublic (Ascending)
- createdAt (Descending)
- __name__ (Descending)
```

### 2. Índice para recetas por autor
```
Collection: recipes
Fields:
- authorId (Ascending) 
- createdAt (Descending)
- __name__ (Descending)
```

### 3. Índice para recetas por región y rating
```
Collection: recipes
Fields:
- region (Ascending)
- isPublic (Ascending) 
- rating (Descending)
- __name__ (Descending)
```

### 4. Índice para reviews por receta
```
Collection: reviews
Fields:
- recipeId (Ascending)
- isVisible (Ascending)
- createdAt (Descending)
- __name__ (Descending)
```

## Cómo crear los índices:

### Opción 1: Desde la consola de Firebase
1. Ve a https://console.firebase.google.com
2. Selecciona tu proyecto: `app-recetas-11a04`
3. Ve a Firestore Database
4. Pestaña "Indexes"
5. Click "Create Index"
6. Agrega los campos según se especifica arriba

### Opción 2: Usando los enlaces de error
Cuando ejecutes la app, aparecerán enlaces en la consola como:
```
https://console.firebase.google.com/v1/r/project/app-recetas-11a04/firestore/indexes?create_composite=...
```
Simplemente haz click en estos enlaces y confirma la creación.

### Opción 3: Archivo firestore.indexes.json
```json
{
  "indexes": [
    {
      "collectionGroup": "recipes",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "isPublic",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        },
        {
          "fieldPath": "__name__",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "recipes", 
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "authorId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt", 
          "order": "DESCENDING"
        },
        {
          "fieldPath": "__name__",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "recipes",
      "queryScope": "COLLECTION", 
      "fields": [
        {
          "fieldPath": "region",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isPublic",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "rating",
          "order": "DESCENDING"
        },
        {
          "fieldPath": "__name__",
          "order": "DESCENDING"
        }
      ]
    }
  ]
}
```

## Reglas de Seguridad de Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reglas para recetas
    match /recipes/{recipeId} {
      allow read: if true; // Todas las recetas públicas se pueden leer
      allow write: if request.auth != null 
        && request.auth.uid == resource.data.authorId; // Solo el autor puede modificar
      allow create: if request.auth != null; // Usuarios autenticados pueden crear
    }
    
    // Reglas para reviews  
    match /reviews/{reviewId} {
      allow read: if true; // Todas las reviews se pueden leer
      allow create: if request.auth != null; // Usuarios autenticados pueden crear
      allow update, delete: if request.auth != null 
        && request.auth.uid == resource.data.authorId; // Solo el autor puede modificar
    }
    
    // Reglas para usuarios
    match /users/{userId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == userId; // Solo el propio usuario puede ver/modificar sus datos
    }
  }
}
```

## Pasos para configurar Firebase:

1. **Crear los índices** (usar cualquiera de las 3 opciones arriba)
2. **Configurar las reglas de seguridad** (copiar las reglas de arriba)
3. **Poblar con datos** (ejecutar el script populate_firebase.dart)
4. **Probar la aplicación**

## Comandos útiles:

```bash
# Ejecutar el script de poblado
cd scripts
dart populate_firebase.dart

# Verificar que Flutter funciona con Firebase
flutter run -d chrome
```
