# 🔑 Configuración de EDAMAM Recipe Search API

## 📝 Paso 1: Obtener Credenciales

1. **Visita el sitio de desarrolladores de EDAMAM:**
   ```
   https://developer.edamam.com/edamam-recipe-api
   ```

2. **Registrarte o inicia sesión:**
   - Crea una cuenta gratuita si no tienes una
   - Inicia sesión si ya tienes cuenta

3. **Suscríbete al plan gratuito:**
   - Recipe Search API tiene un plan gratuito generoso
   - Hasta 10,000 requests por mes gratis
   - No requiere tarjeta de crédito

4. **Obtén tus credenciales:**
   - **APP_ID**: Tu identificador de aplicación
   - **APP_KEY**: Tu clave de API secreta

## 🔧 Paso 2: Configurar en la Aplicación

1. **Abre el archivo `lib/utils/constants.dart`**

2. **Reemplaza las credenciales:**
   ```dart
   // EDAMAM Recipe Search API
   static const String edamamAppId = 'TU_APP_ID_AQUI';     // ← Reemplaza con tu APP_ID
   static const String edamamAppKey = 'TU_APP_KEY_AQUI';   // ← Reemplaza con tu APP_KEY
   ```

## 📊 Límites del Plan Gratuito

- **10,000 requests/mes** (aprox. 333 requests/día)
- **Acceso completo** a la base de datos de recetas
- **Información nutricional** detallada
- **Filtros avanzados** de búsqueda
- **Sin límite de tiempo** en el plan gratuito

## 🔍 Funcionalidades Disponibles

### ✅ Búsqueda por:
- Nombre de receta
- Ingredientes
- Tipo de cocina (americana, italiana, mexicana, etc.)
- Tipo de comida (desayuno, almuerzo, cena)
- Dieta (vegetariana, vegana, keto, etc.)
- Restricciones de salud (sin gluten, sin lácteos, etc.)

### ✅ Información incluida:
- **Receta completa** con ingredientes
- **Información nutricional** detallada
- **Imágenes** de alta calidad
- **Fuente original** de la receta
- **URL** para ver instrucciones completas
- **Etiquetas** de dieta y salud
- **Tiempo de cocción** y porciones

## 🆚 Ventajas de EDAMAM vs Spoonacular

| Característica | EDAMAM | Spoonacular |
|----------------|---------|-------------|
| Plan gratuito | 10,000 requests/mes | 150 requests/día |
| Calidad datos | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Nutrición | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Filtros | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Facilidad uso | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

## 🔧 Ejemplo de Configuración Completa

```dart
class AppConstants {
  // EDAMAM Recipe Search API
  static const String edamamAppId = 'a1b2c3d4';           // ← Tu APP_ID real
  static const String edamamAppKey = 'xyz789abc123def456'; // ← Tu APP_KEY real
  static const String edamamBaseUrl = 'https://api.edamam.com/api/recipes/v2';
  
  // ... resto de constantes
}
```

## 🚀 Probar la Configuración

1. **Guarda** los archivos después de configurar las credenciales
2. **Reinicia** la aplicación Flutter
3. **Navega** a la sección de búsqueda EDAMAM (ícono 🌍 en la navegación)
4. **Prueba** buscar alguna receta como "pasta" o "chicken"

## ⚠️ Notas Importantes

- **Nunca** compartas tu APP_KEY públicamente
- **Monitorea** tu uso en el dashboard de EDAMAM
- **Considera** upgradearse a un plan pago si necesitas más requests
- **La aplicación** seguirá funcionando con datos locales aunque EDAMAM falle

## 🆘 Solución de Problemas

### Error: "Invalid credentials"
- Verifica que APP_ID y APP_KEY sean correctos
- Asegúrate de que no hay espacios extra en las credenciales

### Error: "Quota exceeded"
- Has superado el límite de 10,000 requests/mes
- Espera al siguiente mes o considera un plan pago

### Error: "Network error"
- Verifica tu conexión a internet
- EDAMAM podría tener problemas temporales

## 🔄 Migración desde Spoonacular

La aplicación ha sido completamente migrada de Spoonacular a EDAMAM:

- ✅ Nuevos modelos de datos para EDAMAM
- ✅ Servicio actualizado con endpoints de EDAMAM
- ✅ Provider rediseñado para gestión de estado
- ✅ UI actualizada con información específica de EDAMAM
- ✅ Navegación actualizada (/edamam en lugar de /spoonacular)

¡Disfruta explorando recetas con EDAMAM! 🍽️✨
