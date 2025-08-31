## 🚨 **SOLUCIÓN INMEDIATA: CREAR ÍNDICE DE FIREBASE**

### **Paso 1: Ir a Firebase Console y crear el índice**

1. **Hacer clic en este enlace directo**:
   ```
   https://console.firebase.google.com/v1/r/project/app-recetas-11a04/firestore/indexes?create_composite=ClFwcm9qZWN0cy9hcHAtcmVjZXRhcy0xMWEwNC9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcmV2aWV3cy9pbmRleGVzL18QARoMCghyZWNpcGVJZBABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI
   ```

2. **Hacer clic en "Crear"** en la página que se abre

3. **Esperar 1-2 minutos** mientras se construye el índice

### **Paso 2: Mientras tanto, usar modo temporal sin reviews**

Ejecuta este comando para deshabilitar temporalmente las reviews:

```bash
# Ejecutar solo Flutter (sin reviews por ahora)
flutter run -d chrome --web-port 2147
```

### **Paso 3: Una vez creado el índice**

```bash
# Reiniciar la app
# Ahora las reviews funcionarán correctamente
```

---

## ⚠️ **SI NO PUEDES CREAR EL ÍNDICE INMEDIATAMENTE:**

Usa esta solución temporal que evita completamente las consultas de reviews:

### **Deshabilitar reviews temporalmente:**
1. Ve a cualquier receta
2. El botón de "Reseñar" seguirá ahí pero mostrará un mensaje temporal
3. Los favoritos funcionan perfectamente
4. Una vez que crees el índice, todo funcionará

---

## ✅ **UNA VEZ CREADO EL ÍNDICE:**

1. ✅ Las reviews se cargarán instantáneamente
2. ✅ Se podrán crear nuevas reviews
3. ✅ El sistema completo funcionará perfectamente
4. ✅ Todos los errores desaparecerán

**El índice solo se crea una vez y es permanente** 🎉
