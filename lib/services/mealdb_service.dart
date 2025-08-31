import 'package:dio/dio.dart';
import '../models/mealdb_models.dart';

class MealDBService {
  static final MealDBService _instance = MealDBService._internal();
  factory MealDBService() => _instance;

  final Dio _dio = Dio();
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  MealDBService._internal() {
    // Configurar timeouts
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// Buscar recetas por nombre
  Future<MealDBResponse> searchByName(String query) async {
    try {
      print('🔍 Buscando recetas en MealDB: $query');
      
      final response = await _dio.get('$_baseUrl/search.php', queryParameters: {
        's': query,
      });

      print('✅ Respuesta MealDB recibida');
      return MealDBResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Error en búsqueda MealDB: $e');
      rethrow;
    }
  }

  /// Buscar recetas por primera letra
  Future<MealDBResponse> searchByFirstLetter(String letter) async {
    try {
      print('🔤 Buscando recetas por letra: $letter');
      
      final response = await _dio.get('$_baseUrl/search.php', queryParameters: {
        'f': letter,
      });

      return MealDBResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Error en búsqueda por letra: $e');
      rethrow;
    }
  }

  /// Obtener receta por ID
  Future<MealDBRecipe?> getRecipeById(String id) async {
    try {
      print('📋 Obteniendo receta por ID: $id');
      
      final response = await _dio.get('$_baseUrl/lookup.php', queryParameters: {
        'i': id,
      });

      final mealResponse = MealDBResponse.fromJson(response.data);
      return mealResponse.meals.isNotEmpty ? mealResponse.meals.first : null;
    } catch (e) {
      print('❌ Error obteniendo receta por ID: $e');
      rethrow;
    }
  }

  /// Obtener receta aleatoria
  Future<MealDBRecipe?> getRandomRecipe() async {
    try {
      print('🎲 Obteniendo receta aleatoria');
      
      final response = await _dio.get('$_baseUrl/random.php');

      final mealResponse = MealDBResponse.fromJson(response.data);
      return mealResponse.meals.isNotEmpty ? mealResponse.meals.first : null;
    } catch (e) {
      print('❌ Error obteniendo receta aleatoria: $e');
      rethrow;
    }
  }

  /// Obtener múltiples recetas aleatorias
  Future<List<MealDBRecipe>> getRandomRecipes({int count = 10}) async {
    try {
      print('🎲 Obteniendo $count recetas aleatorias');
      
      final recipes = <MealDBRecipe>[];
      final futures = <Future<MealDBRecipe?>>[];

      // Crear múltiples peticiones concurrentes
      for (int i = 0; i < count; i++) {
        futures.add(getRandomRecipe());
      }

      // Esperar a que todas las peticiones terminen
      final results = await Future.wait(futures);
      
      // Filtrar recetas válidas y eliminar duplicados
      final seenIds = <String>{};
      for (final recipe in results) {
        if (recipe != null && !seenIds.contains(recipe.id)) {
          recipes.add(recipe);
          seenIds.add(recipe.id);
        }
      }

      print('✅ Obtenidas ${recipes.length} recetas aleatorias únicas');
      return recipes;
    } catch (e) {
      print('❌ Error obteniendo recetas aleatorias: $e');
      rethrow;
    }
  }

  /// Buscar recetas por categoría
  Future<MealDBResponse> searchByCategory(String category) async {
    try {
      print('📂 Buscando recetas por categoría: $category');
      
      final response = await _dio.get('$_baseUrl/filter.php', queryParameters: {
        'c': category,
      });

      return MealDBResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Error en búsqueda por categoría: $e');
      rethrow;
    }
  }

  /// Buscar recetas por área/región
  Future<MealDBResponse> searchByArea(String area) async {
    try {
      print('🌍 Buscando recetas por área: $area');
      
      final response = await _dio.get('$_baseUrl/filter.php', queryParameters: {
        'a': area,
      });

      return MealDBResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Error en búsqueda por área: $e');
      rethrow;
    }
  }

  /// Buscar recetas por ingrediente principal
  Future<MealDBResponse> searchByMainIngredient(String ingredient) async {
    try {
      print('🥘 Buscando recetas por ingrediente: $ingredient');
      
      final response = await _dio.get('$_baseUrl/filter.php', queryParameters: {
        'i': ingredient,
      });

      return MealDBResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Error en búsqueda por ingrediente: $e');
      rethrow;
    }
  }

  /// Obtener todas las categorías
  Future<MealDBCategoriesResponse> getCategories() async {
    try {
      print('📁 Obteniendo categorías disponibles');
      
      final response = await _dio.get('$_baseUrl/categories.php');
      
      return MealDBCategoriesResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Error obteniendo categorías: $e');
      rethrow;
    }
  }

  /// Obtener lista de áreas disponibles
  Future<List<String>> getAreas() async {
    try {
      print('🌍 Obteniendo áreas disponibles');
      
      final response = await _dio.get('$_baseUrl/list.php', queryParameters: {
        'a': 'list',
      });

      final meals = response.data['meals'] as List<dynamic>?;
      return meals?.map((meal) => meal['strArea'] as String).toList() ?? [];
    } catch (e) {
      print('❌ Error obteniendo áreas: $e');
      rethrow;
    }
  }

  /// Obtener lista de ingredientes disponibles
  Future<List<String>> getIngredients() async {
    try {
      print('🥘 Obteniendo ingredientes disponibles');
      
      final response = await _dio.get('$_baseUrl/list.php', queryParameters: {
        'i': 'list',
      });

      final meals = response.data['meals'] as List<dynamic>?;
      return meals?.map((meal) => meal['strIngredient'] as String).toList() ?? [];
    } catch (e) {
      print('❌ Error obteniendo ingredientes: $e');
      rethrow;
    }
  }

  /// Búsqueda inteligente que combina varios métodos
  Future<List<MealDBRecipe>> smartSearch(String query) async {
    try {
      print('🧠 Búsqueda inteligente: $query');
      
      final allResults = <MealDBRecipe>[];
      final seenIds = <String>{};

      // 1. Búsqueda por nombre
      try {
        final nameResults = await searchByName(query);
        for (final recipe in nameResults.meals) {
          if (!seenIds.contains(recipe.id)) {
            allResults.add(recipe);
            seenIds.add(recipe.id);
          }
        }
      } catch (e) {
        print('🔍 Búsqueda por nombre sin resultados');
      }

      // 2. Si no hay muchos resultados, buscar por ingrediente
      if (allResults.length < 5) {
        try {
          final ingredientResults = await searchByMainIngredient(query);
          for (final recipe in ingredientResults.meals) {
            if (!seenIds.contains(recipe.id) && allResults.length < 20) {
              allResults.add(recipe);
              seenIds.add(recipe.id);
            }
          }
        } catch (e) {
          print('🥘 Búsqueda por ingrediente sin resultados');
        }
      }

      // 3. Si aún no hay suficientes, agregar algunas aleatorias
      if (allResults.length < 3) {
        try {
          final randomRecipes = await getRandomRecipes(count: 5);
          for (final recipe in randomRecipes) {
            if (!seenIds.contains(recipe.id) && allResults.length < 10) {
              allResults.add(recipe);
              seenIds.add(recipe.id);
            }
          }
        } catch (e) {
          print('🎲 Error obteniendo recetas aleatorias de respaldo');
        }
      }

      print('✅ Búsqueda inteligente completada: ${allResults.length} recetas');
      return allResults;
    } catch (e) {
      print('❌ Error en búsqueda inteligente: $e');
      rethrow;
    }
  }
}
