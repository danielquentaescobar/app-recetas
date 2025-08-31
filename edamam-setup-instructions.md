# 🍳 Configuración de EDAMAM Recipe Search API

## 📋 Pasos para obtener credenciales de EDAMAM

### 1. Crear cuenta en EDAMAM Developer Portal

1. Visita [EDAMAM Developer Portal](https://developer.edamam.com/)
2. Haz clic en **"Get Started"** o **"Sign Up"**
3. Completa el formulario de registro con:
   - Nombre completo
   - Email válido
   - Contraseña segura
   - Acepta términos y condiciones

### 2. Crear una aplicación Recipe Search

1. Una vez registrado y con sesión iniciada:
   - Ve a **"My Account"** → **"Applications"**
   - Haz clic en **"Create a new application"**

2. Completa la información de la aplicación:
   - **Application Name**: "App Recetas Latinas" 
   - **Description**: "Flutter app for Latin American recipe sharing"
   - **Application Type**: Selecciona **"Recipe Search API"**
   - **Plan**: Selecciona **"Developer"** (gratuito)

3. Acepta los términos de uso de la API

### 3. Obtener credenciales

Después de crear la aplicación, verás:
- **Application ID** (APP_ID): Un código alfanumérico
- **Application Key** (APP_KEY): Un código más largo alfanumérico

### 4. Configurar credenciales en la app

1. Abre el archivo `lib/utils/constants.dart`
2. Reemplaza los valores:

```dart
static const String edamamAppId = 'TU_APP_ID_AQUI';
static const String edamamAppKey = 'TU_APP_KEY_AQUI';
```

### 5. Límites del plan gratuito Developer

- **10,000 calls/month** (suficiente para desarrollo y pruebas)
- **10 calls/minute** (rate limiting)
- Acceso a todas las funcionalidades de búsqueda

## 🚀 Ejemplo de configuración

```dart
// Ejemplo de como quedarían las credenciales reales
static const String edamamAppId = 'a1b2c3d4';
static const String edamamAppKey = 'abc123def456ghi789jkl012mno345pqr678stu901';
```

## 🔧 Verificar configuración

Una vez configuradas las credenciales:

1. Reinicia la aplicación Flutter
2. Ve a la sección **"Búsqueda Externa"** en el menú
3. Busca cualquier receta (ej: "pasta", "chicken", "tacos")
4. Deberías ver resultados de recetas con información nutricional

## ❌ Solución de problemas

### Error 401 - Unauthorized
- Verificar que el APP_ID y APP_KEY sean correctos
- Verificar que no haya espacios extra en las credenciales
- Verificar que la aplicación esté activa en el portal

### Error 403 - Forbidden
- Has excedido el límite de llamadas (10,000/mes o 10/minuto)
- Espera unos minutos y prueba de nuevo

### Error 404 - Not Found
- Verificar que la URL base sea correcta
- Verificar que el endpoint de la API sea válido

## 📱 Funcionalidades disponibles con EDAMAM

✅ **Búsqueda por nombre** - "chicken pasta", "tacos", etc.
✅ **Búsqueda por ingredientes** - "tomato, onion, garlic"  
✅ **Filtros de dieta** - vegetarian, vegan, keto, paleo
✅ **Filtros de salud** - gluten-free, dairy-free, nut-free
✅ **Tipo de comida** - breakfast, lunch, dinner, snack
✅ **Tipo de cocina** - italian, mexican, asian, indian
✅ **Información nutricional** - calorías, proteínas, grasas, carbohidratos
✅ **Tiempo de cocción** - filtrar por tiempo máximo
✅ **Enlaces a recetas completas** - redirección a sitios web originales

## 🔗 Enlaces útiles

- [EDAMAM Developer Portal](https://developer.edamam.com/)
- [Documentación Recipe Search API](https://developer.edamam.com/edamam-docs-recipe-api)
- [Ejemplos de filtros y parámetros](https://developer.edamam.com/edamam-recipe-api-demo)
- [Soporte técnico](https://developer.edamam.com/admin/contact)

---

⚠️ **Importante**: Las credenciales son privadas. No las compartas en repositorios públicos o código fuente visible.
