class AppConstants {
  // EDAMAM Recipe Search API (Con problemas de plan/límites)
  // 🔑 OBTÉN TUS CREDENCIALES DESDE: https://developer.edamam.com/edamam-recipe-api
  // 📝 Necesitas registrarte y obtener tanto APP_ID como APP_KEY
  // ⚠️ Actualmente con errores 403 - límites excedidos
  static const String edamamAppId = 'd9213b09';
  static const String edamamAppKey = '6f752c8db5f3608f8b73a22097e907c1';
  static const String edamamBaseUrl = 'https://api.edamam.com/search';
  
  // 🌐 Proxy CORS para desarrollo web (solo para testing)
  static const String corsProxyUrl = 'https://cors-anywhere.herokuapp.com/';
  static const bool useCorsPoxy = false; // Deshabilitado por problemas de EDAMAM
  
  // 🆕 TheMealDB API (NUEVA - Gratuita y sin límites)
  // ✅ No requiere credenciales
  // ✅ Completamente gratuita
  // ✅ Sin límites de llamadas
  // ✅ Especializada en recetas
  static const String mealDBBaseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const bool useMealDB = true; // Usar MealDB como API principal
  
  // Regiones Latinoamericanas
  static const List<String> latinAmericanRegions = [
    'Argentina',
    'Bolivia',
    'Brasil',
    'Chile',
    'Colombia',
    'Costa Rica',
    'Cuba',
    'Ecuador',
    'El Salvador',
    'Guatemala',
    'Honduras',
    'México',
    'Nicaragua',
    'Panamá',
    'Paraguay',
    'Perú',
    'República Dominicana',
    'Uruguay',
    'Venezuela',
  ];

  // Dificultades de recetas
  static const List<String> difficultyLevels = [
    'Fácil',
    'Intermedio',
    'Difícil',
  ];

  // Categorías de recetas
  static const List<String> recipeCategories = [
    'Desayuno',
    'Almuerzo',
    'Cena',
    'Postre',
    'Aperitivo',
    'Bebida',
    'Snack',
    'Plato Principal',
    'Acompañamiento',
    'Sopa',
    'Ensalada',
  ];

  // Tipos de dieta
  static const List<String> dietTypes = [
    'Vegetariana',
    'Vegana',
    'Sin Gluten',
    'Keto',
    'Paleo',
    'Baja en Carbohidratos',
    'Baja en Grasa',
    'Sin Lactosa',
  ];

  // Configuración de la app
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const int maxRecipeNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxInstructionLength = 1000;
  
  // Mensajes
  static const String appName = 'Recetas Latinas';
  static const String noInternetMessage = 'No hay conexión a internet';
  static const String genericErrorMessage = 'Ha ocurrido un error inesperado';
}

class AppStrings {
  // Autenticación
  static const String signIn = 'Iniciar Sesión';
  static const String signUp = 'Registrarse';
  static const String signOut = 'Cerrar Sesión';
  static const String email = 'Correo Electrónico';
  static const String password = 'Contraseña';
  static const String confirmPassword = 'Confirmar Contraseña';
  static const String name = 'Nombre';
  static const String forgotPassword = 'Olvidé mi contraseña';
  static const String resetPassword = 'Restablecer contraseña';
  
  // Navegación
  static const String home = 'Inicio';
  static const String search = 'Buscar';
  static const String favorites = 'Favoritos';
  static const String profile = 'Perfil';
  static const String myRecipes = 'Mis Recetas';
  static const String addRecipe = 'Agregar Receta';
  
  // Recetas
  static const String title = 'Título';
  static const String description = 'Descripción';
  static const String ingredients = 'Ingredientes';
  static const String instructions = 'Instrucciones';
  static const String preparationTime = 'Tiempo de Preparación';
  static const String cookingTime = 'Tiempo de Cocción';
  static const String totalTime = 'Tiempo Total';
  static const String servings = 'Porciones';
  static const String difficulty = 'Dificultad';
  static const String region = 'Región';
  static const String category = 'Categoría';
  static const String tags = 'Etiquetas';
  static const String addPhoto = 'Agregar Foto';
  static const String save = 'Guardar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  
  // Reviews
  static const String reviews = 'Reseñas';
  static const String addReview = 'Agregar Reseña';
  static const String rating = 'Calificación';
  static const String comment = 'Comentario';
  static const String submit = 'Enviar';
  
  // Búsqueda
  static const String searchRecipes = 'Buscar Recetas';
  static const String searchByIngredients = 'Buscar por Ingredientes';
  static const String noResults = 'No se encontraron resultados';
  static const String popularRecipes = 'Recetas Populares';
  static const String recentRecipes = 'Recetas Recientes';
  
  // Errores y validaciones
  static const String fieldRequired = 'Este campo es obligatorio';
  static const String invalidEmail = 'Correo electrónico inválido';
  static const String weakPassword = 'La contraseña debe tener al menos 6 caracteres';
  static const String passwordMismatch = 'Las contraseñas no coinciden';
  static const String loginError = 'Error al iniciar sesión';
  static const String signUpError = 'Error al registrarse';
  
  // Tiempo
  static const String minutes = 'minutos';
  static const String hours = 'horas';
}
