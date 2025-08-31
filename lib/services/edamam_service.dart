import 'package:dio/dio.dart';
import '../models/edamam_models.dart';
import '../utils/constants.dart';

class EdamamService {
  static final EdamamService _instance = EdamamService._internal();
  factory EdamamService() => _instance;

  final Dio _dio = Dio();

  EdamamService._internal() {
    // Configurar interceptor para CORS
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.addAll({
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          });
          handler.next(options);
        },
      ),
    );
  }

  /// Verificar si las credenciales están configuradas
  bool get _areCredentialsConfigured {
    return AppConstants.edamamAppId != 'DEMO_APP_ID_NO_FUNCIONA' && 
           AppConstants.edamamAppKey != 'DEMO_APP_KEY_NO_FUNCIONA' &&
           AppConstants.edamamAppId.isNotEmpty && 
           AppConstants.edamamAppKey.isNotEmpty;
  }

  /// Buscar recetas por término de búsqueda
  Future<EdamamRecipeSearchResponse> searchRecipes({
    required String query,
    String? diet,
    List<String>? health,
    String? cuisineType,
    String? mealType,
    String? dishType,
    int? calories,
    int? time,
    int from = 0,
    int to = 20,
  }) async {
    try {
      // Verificar que las credenciales estén configuradas
      if (!_areCredentialsConfigured) {
        throw Exception(
          '🔑 Credenciales de EDAMAM no configuradas. '
          'Por favor configura tu APP_ID y APP_KEY en constants.dart. '
          'Consulta edamam-setup-instructions.md para más información.'
        );
      }

      final Map<String, dynamic> queryParams = {
        'q': query,
        'app_id': AppConstants.edamamAppId,
        'app_key': AppConstants.edamamAppKey,
        'from': from,
        'to': to,
      };

      // Agregar filtros opcionales
      if (diet != null) queryParams['diet'] = diet;
      if (health != null && health.isNotEmpty) {
        queryParams['health'] = health.join(',');
      }
      if (cuisineType != null) queryParams['cuisineType'] = cuisineType;
      if (mealType != null) queryParams['mealType'] = mealType;
      if (dishType != null) queryParams['dishType'] = dishType;
      if (calories != null) queryParams['calories'] = '0-$calories';
      if (time != null) queryParams['time'] = '1-$time';

      print('🔍 Buscando recetas en EDAMAM: $query');
      print('📝 Parámetros: $queryParams');

      // Construir URL con o sin proxy CORS
      String requestUrl = AppConstants.edamamBaseUrl;
      if (AppConstants.useCorsPoxy) {
        requestUrl = '${AppConstants.corsProxyUrl}${AppConstants.edamamBaseUrl}';
        print('🌐 Usando proxy CORS: $requestUrl');
      }

      final response = await _dio.get(
        requestUrl,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, X-Request-With',
          },
        ),
      );

      print('✅ Respuesta EDAMAM recibida: ${response.data['count']} recetas');

      return EdamamRecipeSearchResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Error en búsqueda EDAMAM: $e');
      rethrow;
    }
  }

  /// Buscar recetas por ingredientes
  Future<EdamamRecipeSearchResponse> searchRecipesByIngredients({
    required List<String> ingredients,
    String? diet,
    List<String>? health,
    String? cuisineType,
    String? mealType,
    int from = 0,
    int to = 20,
  }) async {
    try {
      // En EDAMAM, la búsqueda por ingredientes se hace en el query principal
      final query = ingredients.join(' AND ');
      
      print('🥕 Buscando recetas por ingredientes: $ingredients');

      return await searchRecipes(
        query: query,
        diet: diet,
        health: health,
        cuisineType: cuisineType,
        mealType: mealType,
        from: from,
        to: to,
      );
    } catch (e) {
      print('❌ Error en búsqueda por ingredientes: $e');
      rethrow;
    }
  }

  /// Obtener recetas aleatorias (utilizando términos de búsqueda populares)
  Future<EdamamRecipeSearchResponse> getRandomRecipes({
    String? cuisineType,
    String? mealType,
    String? diet,
    int from = 0,
    int to = 20,
  }) async {
    try {
      // Verificar que las credenciales estén configuradas
      if (!_areCredentialsConfigured) {
        throw Exception(
          '🔑 Credenciales de EDAMAM no configuradas. '
          'Por favor configura tu APP_ID y APP_KEY en constants.dart. '
          'Consulta edamam-setup-instructions.md para más información.'
        );
      }

      // Lista de términos populares para obtener recetas "aleatorias"
      final List<String> popularQueries = [
        'chicken',
        'pasta',
        'salad',
        'soup',
        'rice',
        'beef',
        'fish',
        'vegetarian',
        'pizza',
        'cake',
        'bread',
        'curry',
        'sandwich',
        'breakfast',
        'dinner',
      ];

      // Seleccionar un término aleatorio
      final randomQuery = popularQueries[DateTime.now().millisecond % popularQueries.length];
      
      print('🎲 Obteniendo recetas aleatorias con término: $randomQuery');

      return await searchRecipes(
        query: randomQuery,
        cuisineType: cuisineType,
        mealType: mealType,
        diet: diet,
        from: from,
        to: to,
      );
    } catch (e) {
      print('❌ Error obteniendo recetas aleatorias: $e');
      rethrow;
    }
  }

  /// Obtener detalles de una receta específica por URI
  Future<EdamamRecipe> getRecipeDetails(String recipeUri) async {
    try {
      print('📋 Obteniendo detalles de receta: $recipeUri');

      final response = await _dio.get(
        AppConstants.edamamBaseUrl,
        queryParameters: {
          'r': recipeUri,
          'app_id': AppConstants.edamamAppId,
          'app_key': AppConstants.edamamAppKey,
        },
      );

      if (response.data['hits'] != null && response.data['hits'].isNotEmpty) {
        final hit = EdamamRecipeHit.fromJson(response.data['hits'][0]);
        print('✅ Detalles de receta obtenidos: ${hit.recipe.label}');
        return hit.recipe;
      } else {
        throw Exception('Receta no encontrada');
      }
    } catch (e) {
      print('❌ Error obteniendo detalles: $e');
      rethrow;
    }
  }

  /// Buscar recetas saludables
  Future<EdamamRecipeSearchResponse> getHealthyRecipes({
    String query = 'healthy',
    int from = 0,
    int to = 20,
  }) async {
    try {
      print('🥗 Buscando recetas saludables');

      return await searchRecipes(
        query: query,
        health: ['low-sugar', 'low-sodium'],
        diet: 'balanced',
        from: from,
        to: to,
      );
    } catch (e) {
      print('❌ Error buscando recetas saludables: $e');
      rethrow;
    }
  }

  /// Buscar recetas por tipo de comida
  Future<EdamamRecipeSearchResponse> getRecipesByMealType({
    required String mealType,
    String query = '',
    int from = 0,
    int to = 20,
  }) async {
    try {
      print('🍽️ Buscando recetas de $mealType');

      return await searchRecipes(
        query: query.isEmpty ? mealType : query,
        mealType: mealType,
        from: from,
        to: to,
      );
    } catch (e) {
      print('❌ Error buscando recetas de $mealType: $e');
      rethrow;
    }
  }

  /// Buscar recetas vegetarianas/veganas
  Future<EdamamRecipeSearchResponse> getVegetarianRecipes({
    bool isVegan = false,
    String query = 'vegetable',
    int from = 0,
    int to = 20,
  }) async {
    try {
      final healthLabel = isVegan ? 'vegan' : 'vegetarian';
      print('🌱 Buscando recetas ${isVegan ? 'veganas' : 'vegetarianas'}');

      return await searchRecipes(
        query: query,
        health: [healthLabel],
        from: from,
        to: to,
      );
    } catch (e) {
      print('❌ Error buscando recetas vegetarianas: $e');
      rethrow;
    }
  }
}
