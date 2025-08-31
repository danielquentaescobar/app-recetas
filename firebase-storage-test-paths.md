# 🔥 Rutas de Prueba para Firebase Storage

## 📍 **Tu bucket de Firebase Storage:**
```
/b/app-recetas-11a04.firebasestorage.app/o
```

## 🧪 **Rutas de prueba según tus reglas:**

### 1️⃣ **Para imágenes de recetas** (cualquier usuario autenticado puede subir):
```
recipes/imagen_prueba_1.jpg
recipes/receta_pollo_asado.png
recipes/1692982800000_imagen.jpeg
```

### 2️⃣ **Para avatares de perfil** (solo el usuario propietario puede subir):
```
profiles/{tu-user-id}/avatar.jpg
profiles/{tu-user-id}/perfil_2024.png
```

### 3️⃣ **Para lectura pública** (cualquiera puede leer):
```
recipes/cualquier_imagen.jpg
profiles/user123/avatar.png
cualquier/ruta/imagen.jpg
```

---

## 🎯 **Ejemplos específicos para probar:**

### ✅ **GET (Lectura) - Debería funcionar:**
- `recipes/test_image.jpg`
- `profiles/user123/avatar.png`
- `cualquier/carpeta/imagen.jpg`

### ✅ **PUT (Escritura) - Para recetas:**
- `recipes/nueva_receta.jpg`
- `recipes/1692982800000_tacos.png`

### ❌ **PUT (Escritura) - Debería fallar sin autenticación:**
- `recipes/sin_auth.jpg` (sin usuario autenticado)
- `profiles/otro_usuario/hack.jpg` (intentando subir al perfil de otro)

---

## 🧪 **Cómo probar en Firebase Console:**

### Para **GET (lectura)**:
1. Tipo: `get`
2. Ubicación: `/b/app-recetas-11a04.firebasestorage.app/o`
3. **path/to/resource**: `recipes/test_image.jpg`

### Para **PUT (escritura de receta)**:
1. Tipo: `create/update`
2. Ubicación: `/b/app-recetas-11a04.firebasestorage.app/o`
3. **path/to/resource**: `recipes/nueva_receta.jpg`
4. ⚠️ **Importante**: Marca "Authenticated" y configura un usuario

### Para **PUT (escritura de perfil)**:
1. Tipo: `create/update`
2. Ubicación: `/b/app-recetas-11a04.firebasestorage.app/o`
3. **path/to/resource**: `profiles/tu_user_id_aqui/avatar.jpg`
4. ⚠️ **Importante**: Marca "Authenticated" con el mismo `user_id`

---

## 🔧 **Configuración de usuario para pruebas:**

Si necesitas probar con autenticación, configura:
```json
{
  "uid": "user123",
  "email": "test@example.com",
  "auth_time": 1692982800
}
```

---

## 📝 **Notas importantes:**

- ✅ **Lectura**: Completamente pública (sin autenticación)
- 🔐 **Escritura recetas**: Requiere cualquier usuario autenticado
- 🔒 **Escritura perfiles**: Requiere ser el usuario propietario
- 📏 **Límites**: 5MB para recetas, 2MB para avatares
- 🖼️ **Tipos**: Solo imágenes (image/*)
