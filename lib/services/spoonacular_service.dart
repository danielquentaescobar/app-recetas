import 'package:dio/dio.dart';
import '../models/spoonacular_models.dart';
import '../utils/constants.dart';

class SpoonacularService {
  final Dio _dio = Dio();
  static const String baseUrl = 'https://api.spoonacular.com/recipes';
  
  // Usar la API Key desde constants.dart
  static String get apiKey => AppConstants.spoonacularApiKey;

  SpoonacularService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  // Buscar recetas por ingredientes
  Future<List<SpoonacularRecipe>> searchRecipesByIngredients({
    required List<String> ingredients,
    int number = 10,
    bool ignorePantry = true,
    String ranking = '1', // 1: maximize used ingredients, 2: minimize missing ingredients
  }) async {
    try {
      final response = await _dio.get('/findByIngredients', queryParameters: {
        'apiKey': apiKey,
        'ingredients': ingredients.join(','),
        'number': number,
        'ignorePantry': ignorePantry,
        'ranking': ranking,
      });

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => SpoonacularRecipe.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error al buscar recetas por ingredientes: ${e.message}');
      rethrow;
    }
  }

  // Buscar recetas por texto
  Future<List<SpoonacularRecipe>> searchRecipes({
    required String query,
    String? cuisine,
    String? diet,
    String? intolerances,
    int number = 10,
    int offset = 0,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'apiKey': apiKey,
        'query': query,
        'number': number,
        'offset': offset,
      };

      if (cuisine != null) queryParams['cuisine'] = cuisine;
      if (diet != null) queryParams['diet'] = diet;
      if (intolerances != null) queryParams['intolerances'] = intolerances;

      final response = await _dio.get('/complexSearch', queryParameters: queryParams);

      if (response.statusCode == 200) {
        List<dynamic> results = response.data['results'];
        return results.map((json) => SpoonacularRecipe.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error al buscar recetas: ${e.message}');
      rethrow;
    }
  }

  // Obtener información detallada de una receta
  Future<SpoonacularRecipe?> getRecipeInformation(int id) async {
    try {
      final response = await _dio.get('/$id/information', queryParameters: {
        'apiKey': apiKey,
        'includeNutrition': true,
      });

      if (response.statusCode == 200) {
        return SpoonacularRecipe.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('Error al obtener información de receta: ${e.message}');
      rethrow;
    }
  }

  // Buscar recetas por región (usando cuisines de Spoonacular)
  Future<List<SpoonacularRecipe>> getRecipesByRegion({
    required String region,
    int number = 10,
    int offset = 0,
  }) async {
    try {
      // Mapear regiones latinoamericanas a cuisines de Spoonacular
      String cuisine = _mapRegionToCuisine(region);
      
      final response = await _dio.get('/complexSearch', queryParameters: {
        'apiKey': apiKey,
        'cuisine': cuisine,
        'number': number,
        'offset': offset,
      });

      if (response.statusCode == 200) {
        List<dynamic> results = response.data['results'];
        return results.map((json) => SpoonacularRecipe.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error al buscar recetas por región: ${e.message}');
      rethrow;
    }
  }

  // Obtener recetas aleatorias
  Future<List<SpoonacularRecipe>> getRandomRecipes({
    String? tags,
    int number = 10,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'apiKey': apiKey,
        'number': number,
      };

      if (tags != null) queryParams['tags'] = tags;

      final response = await _dio.get('/random', queryParameters: queryParams);

      if (response.statusCode == 200) {
        List<dynamic> recipes = response.data['recipes'];
        return recipes.map((json) => SpoonacularRecipe.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error al obtener recetas aleatorias: ${e.message}');
      rethrow;
    }
  }

  // Analizar información nutricional de ingredientes
  Future<Map<String, dynamic>> analyzeNutrition(List<String> ingredients) async {
    try {
      final response = await _dio.post(
        '/analyzeIngredients',
        queryParameters: {'apiKey': apiKey},
        data: {
          'ingredients': ingredients,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } on DioException catch (e) {
      print('Error al analizar nutrición: ${e.message}');
      rethrow;
    }
  }

  // Generar lista de compras a partir de una receta
  Future<Map<String, dynamic>> generateShoppingList(List<int> recipeIds) async {
    try {
      final response = await _dio.post(
        '/shoppingList',
        queryParameters: {'apiKey': apiKey},
        data: {
          'recipeIds': recipeIds.join(','),
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } on DioException catch (e) {
      print('Error al generar lista de compras: ${e.message}');
      rethrow;
    }
  }

  // Mapear regiones latinoamericanas a cuisines de Spoonacular
  String _mapRegionToCuisine(String region) {
    switch (region.toLowerCase()) {
      case 'méxico':
      case 'mexico':
        return 'Mexican';
      case 'argentina':
      case 'uruguay':
        return 'Latin American';
      case 'perú':
      case 'peru':
        return 'Latin American';
      case 'colombia':
        return 'Latin American';
      case 'venezuela':
        return 'Latin American';
      case 'chile':
        return 'Latin American';
      case 'brasil':
      case 'brazil':
        return 'Latin American';
      case 'ecuador':
        return 'Latin American';
      case 'bolivia':
        return 'Latin American';
      case 'paraguay':
        return 'Latin American';
      case 'centroamérica':
      case 'centroamerica':
        return 'Latin American';
      default:
        return 'Latin American';
    }
  }

  // Obtener ingredientes sustitutos
  Future<List<Map<String, dynamic>>> getIngredientSubstitutes(String ingredient) async {
    try {
      final response = await _dio.get('/food/ingredients/substitutes', queryParameters: {
        'apiKey': apiKey,
        'ingredientName': ingredient,
      });

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['substitutes'] ?? []);
      }
      return [];
    } on DioException catch (e) {
      print('Error al obtener sustitutos: ${e.message}');
      rethrow;
    }
  }
}
