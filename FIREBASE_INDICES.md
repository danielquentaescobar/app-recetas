# 📋 ÍNDICES REQUERIDOS PARA FIREBASE FIRESTORE

## 🔍 **ÍNDICES COMPUESTOS REQUERIDOS**

Debes crear estos índices en la consola de Firebase Firestore para que todas las consultas funcionen correctamente.

### 🍽️ **Colección: `recipes`**

#### 1️⃣ **Índice para recetas públicas ordenadas por fecha**
```
Colección: recipes
Campos:
  - isPublic: Ascendente
  - createdAt: Descendente
```

#### 2️⃣ **Índice para recetas por usuario ordenadas por fecha**
```
Colección: recipes
Campos:
  - authorId: Ascendente
  - createdAt: Descendente
```

#### 3️⃣ **Índice para recetas por región y públicas ordenadas por rating**
```
Colección: recipes
Campos:
  - region: Ascendente
  - isPublic: Ascendente
  - rating: Descendente
```

### 💬 **Colección: `reviews`**

#### 4️⃣ **Índice para reseñas por receta ordenadas por fecha**
```
Colección: reviews
Campos:
  - recipeId: Ascendente
  - isVisible: Ascendente
  - createdAt: Descendente
```

#### 5️⃣ **Índice para cálculo de rating promedio**
```
Colección: reviews
Campos:
  - recipeId: Ascendente
  - isVisible: Ascendente
```

---

## 🚀 **CÓMO CREAR LOS ÍNDICES**

### **Método 1: Desde la Consola de Firebase (RECOMENDADO)**

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Firestore Database**
4. Haz clic en la pestaña **Índices**
5. Haz clic en **Crear índice compuesto**

Para cada índice:

#### **Índice 1: Recetas públicas por fecha**
- Colección: `recipes`
- Campo 1: `isPublic` → **Ascendente**
- Campo 2: `createdAt` → **Descendente**
- Estado de consulta: **Habilitado**

#### **Índice 2: Recetas por usuario y fecha**
- Colección: `recipes`
- Campo 1: `authorId` → **Ascendente**
- Campo 2: `createdAt` → **Descendente**
- Estado de consulta: **Habilitado**

#### **Índice 3: Recetas por región, públicas y rating**
- Colección: `recipes`
- Campo 1: `region` → **Ascendente**
- Campo 2: `isPublic` → **Ascendente**
- Campo 3: `rating` → **Descendente**
- Estado de consulta: **Habilitado**

#### **Índice 4: Reseñas por receta y fecha**
- Colección: `reviews`
- Campo 1: `recipeId` → **Ascendente**
- Campo 2: `isVisible` → **Ascendente**
- Campo 3: `createdAt` → **Descendente**
- Estado de consulta: **Habilitado**

#### **Índice 5: Reseñas para rating promedio**
- Colección: `reviews`
- Campo 1: `recipeId` → **Ascendente**
- Campo 2: `isVisible` → **Ascendente**
- Estado de consulta: **Habilitado**

### **Método 2: Desde los enlaces de error (AUTOMÁTICO)**

Cuando ejecutes la app y aparezcan errores de índices faltantes, Firebase te dará enlaces directos como:
```
https://console.firebase.google.com/v1/r/project/YOUR_PROJECT/firestore/indexes?create_composite=...
```

Simplemente haz clic en estos enlaces para crear automáticamente el índice requerido.

---

## ⏱️ **TIEMPO DE CREACIÓN**

- **Índices simples**: 1-2 minutos
- **Índices compuestos**: 2-5 minutos
- **Proyectos con muchos datos**: Hasta 15 minutos

⚠️ **Importante**: Los índices deben estar en estado "Creado" antes de que las consultas funcionen.

---

## 🔍 **VERIFICAR ÍNDICES CREADOS**

En la consola de Firebase, ve a **Firestore Database > Índices** y verifica que todos los índices aparezcan con estado **"Creado"** (verde).

---

## 🐛 **RESOLUCIÓN DE PROBLEMAS**

### **Error: "The query requires an index"**
- Copia el enlace del error y ábrelo en el navegador
- Firebase creará automáticamente el índice necesario

### **Índices en estado "Creando"**
- Espera a que cambien a "Creado"
- No uses las consultas hasta que estén listos

### **Error de permisos**
- Asegúrate de tener permisos de editor en el proyecto Firebase

---

## 📝 **COMANDO PARA OBTENER ENLACES AUTOMÁTICOS**

Ejecuta la app y revisa la consola de Flutter. Cuando aparezcan errores como:

```
[cloud_firestore/failed-precondition] The query requires an index.
You can create it here: https://console.firebase.google.com/...
```

Copia y pega esos enlaces en tu navegador para crear los índices automáticamente.

---

## ✅ **CHECKLIST DE VERIFICACIÓN**

- [ ] Índice 1: `recipes` → `isPublic` (ASC) + `createdAt` (DESC)
- [ ] Índice 2: `recipes` → `authorId` (ASC) + `createdAt` (DESC)  
- [ ] Índice 3: `recipes` → `region` (ASC) + `isPublic` (ASC) + `rating` (DESC)
- [ ] Índice 4: `reviews` → `recipeId` (ASC) + `isVisible` (ASC) + `createdAt` (DESC)
- [ ] Índice 5: `reviews` → `recipeId` (ASC) + `isVisible` (ASC)
- [ ] Todos los índices en estado "Creado" ✅
- [ ] App ejecutándose sin errores de índices ✅

---

> 💡 **Tip**: Crea los índices en el orden listado arriba, empezando por el más importante (recetas públicas por fecha).
