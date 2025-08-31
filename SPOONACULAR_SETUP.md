# 🔑 Configuración de API Key de Spoonacular

## 📋 **Pasos para obtener tu API Key**

### 1. **Registrarse en Spoonacular**
- Ve a: https://spoonacular.com/food-api
- Haz clic en "Get API Key"
- Regístrate con tu email
- Confirma tu cuenta por email

### 2. **Obtener la API Key**
- Una vez registrado, ve a tu dashboard: https://spoonacular.com/food-api/console
- Copia tu API Key (se ve así: `1234567890abcdef1234567890abcdef`)

### 3. **Configurar en la App**
- Abre el archivo: `lib/utils/constants.dart`
- Busca la línea:
  ```dart
  static const String spoonacularApiKey = 'TU_API_KEY_AQUI';
  ```
- Reemplaza `TU_API_KEY_AQUI` con tu API key real:
  ```dart
  static const String spoonacularApiKey = '1234567890abcdef1234567890abcdef';
  ```

## 🚀 **Funcionalidades Incluidas**

✅ **Búsqueda por texto** - Buscar recetas por nombre o tipo de comida
✅ **Búsqueda por ingredientes** - Encontrar recetas usando ingredientes específicos  
✅ **Filtros avanzados** - Por cocina (mexicana, italiana, etc.) y dieta (vegetariana, keto, etc.)
✅ **Recetas aleatorias** - Descubrir nuevas recetas por categorías
✅ **Información detallada** - Ingredientes, instrucciones paso a paso, información nutricional
✅ **Imágenes de alta calidad** - Fotos profesionales de cada receta

## 🎯 **Límites del Plan Gratuito**

- **150 puntos por día** (equivale a ~150 búsquedas simples)
- **Búsquedas complejas consumen más puntos**
- **Se resetea cada 24 horas**

## 💰 **Planes de Pago** (opcional)

- **Mega Plan**: $49/mes - 50,000 puntos/día
- **Ultra Plan**: $99/mes - 100,000 puntos/día
- **Más información**: https://spoonacular.com/food-api/pricing

## 🔧 **Cómo Acceder a Spoonacular en la App**

1. **Desde el botón principal**: 
   - Abre la app
   - Toca el botón "Crear" (botón flotante)
   - Selecciona "Explorar Spoonacular"

2. **Funciones disponibles**:
   - **Pestaña "Buscar"**: Busca por nombre y aplica filtros
   - **Pestaña "Ingredientes"**: Busca por ingredientes que tienes
   - **Pestaña "Descubrir"**: Recetas aleatorias y por categorías

## ⚠️ **Importante - Seguridad**

- **NUNCA** subas tu API key a repositorios públicos
- Considera usar variables de entorno para producción
- La API key actual en el código es solo un placeholder

## 🐛 **Troubleshooting**

### Error: "Invalid API Key"
- Verifica que copiaste la API key correctamente
- Asegúrate de no tener espacios extras
- Confirma que tu cuenta está activada

### Error: "Quota exceeded"
- Has alcanzado el límite diario de 150 puntos
- Espera 24 horas o considera actualizar tu plan

### No aparecen recetas
- Verifica tu conexión a internet
- Prueba con términos de búsqueda en inglés
- Revisa que la API key esté configurada correctamente

## 🔄 **Próximas Mejoras**

- [ ] Guardar recetas de Spoonacular como favoritas
- [ ] Traducir recetas automáticamente
- [ ] Cache local para reducir consumo de API
- [ ] Sincronización con recetas propias
