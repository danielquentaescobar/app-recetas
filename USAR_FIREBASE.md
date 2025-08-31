# 🔥 Guía para Usar Firebase con las Recetas

## 🎯 **Estado Actual**

✅ **Aplicación funcionando** en: http://localhost:6708
✅ **Firebase configurado** e inicializado correctamente
✅ **Funcionalidad para agregar recetas** implementada
✅ **Interfaz lista** para mostrar recetas de Firebase

## 📋 **Pasos para Ver Recetas de Firebase**

### 1. 🔐 **Iniciar Sesión**
- Ve a: http://localhost:6708
- Usa las credenciales de prueba:
  - **Email:** `test@example.com`
  - **Password:** `123456`

### 2. 📦 **Agregar Recetas de Ejemplo**
- En la pantalla principal, busca el botón **📦** en la barra superior
- Haz click en el botón de "Agregar recetas de ejemplo"
- Confirma en el diálogo que aparece
- Espera el mensaje de éxito

### 3. 📊 **Crear Índices de Firebase** (Solo si aparecen errores)

Si ves errores como "The query requires an index", haz click en los enlaces que aparecen en la consola:

```
https://console.firebase.google.com/v1/r/project/app-recetas-11a04/firestore/indexes?create_composite=...
```

O ve manualmente a Firebase Console:
1. https://console.firebase.google.com
2. Proyecto: `app-recetas-11a04`
3. Firestore Database → Indexes
4. Create Index con estos campos:

**Índice 1:**
- Collection: `recipes`
- Fields: `isPublic` (Ascending), `createdAt` (Descending)

**Índice 2:**
- Collection: `recipes`
- Fields: `authorId` (Ascending), `createdAt` (Descending)

### 4. 🔄 **Verificar Funcionamiento**

Después de agregar las recetas, deberías ver:

- ✅ **3 recetas latinoamericanas** en la pantalla principal
- ✅ **Ceviche Peruano Tradicional**
- ✅ **Empanadas Argentinas de Carne**  
- ✅ **Arepa Venezolana Rellena**

## 🛠️ **Solución de Problemas**

### Si no ves recetas:
1. Revisa la consola del navegador (F12)
2. Busca mensajes de error de índices
3. Crea los índices usando los enlaces proporcionados
4. Recarga la página

### Si hay errores de autenticación:
1. Asegúrate de usar las credenciales exactas
2. Ve a Firebase Console → Authentication
3. Verifica que Email/Password está habilitado

### Si la aplicación no carga:
1. Verifica que el puerto 6708 esté libre
2. Ejecuta: `flutter run -d chrome --web-port 6708`
3. Espera a que aparezca "Firebase inicializado correctamente"

## 📱 **Funcionalidades Disponibles**

Una vez que las recetas estén en Firebase:

- 🏠 **Ver recetas** en la pantalla principal
- 🔍 **Buscar recetas** por términos
- ❤️ **Agregar a favoritos**
- 👤 **Ver perfil** del autor
- ➕ **Crear nuevas recetas**
- ⭐ **Calificar y reseñar**

## 🎉 **¡Listo!**

Con estos pasos, tu aplicación debería estar mostrando recetas reales de Firebase en lugar de datos mock.

Las recetas incluyen:
- **Imágenes reales** de Unsplash
- **Ingredientes detallados**
- **Instrucciones paso a paso**
- **Información nutricional**
- **Clasificación por regiones**

¡Disfruta explorando las recetas latinoamericanas! 🌮🥘🍲
