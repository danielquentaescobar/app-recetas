import 'package:flutter/foundation.dart';
import '../models/mealdb_models.dart';
import '../services/mealdb_service.dart';

class MealDBProvider with ChangeNotifier {
  final MealDBService _mealDBService = MealDBService();

  // Estados
  List<MealDBRecipe> _recipes = [];
  List<MealDBRecipe> _searchResults = [];
  List<MealDBRecipe> _randomRecipes = [];
  List<MealDBCategory> _categories = [];
  
  MealDBRecipe? _selectedRecipe;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<MealDBRecipe> get recipes => _recipes;
  List<MealDBRecipe> get searchResults => _searchResults;
  List<MealDBRecipe> get randomRecipes => _randomRecipes;
  List<MealDBCategory> get categories => _categories;
  MealDBRecipe? get selectedRecipe => _selectedRecipe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Métodos de utilidad
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Cargar recetas aleatorias al inicio
  Future<void> loadRandomRecipes({int count = 10}) async {
    try {
      _setLoading(true);
      _clearError();

      final recipes = await _mealDBService.getRandomRecipes(count: count);
      _randomRecipes = recipes;
      
      print('✅ Cargadas ${_randomRecipes.length} recetas aleatorias de MealDB');
      _setLoading(false);
    } catch (e) {
      print('❌ Error cargando recetas aleatorias: $e');
      _setError('Error al cargar recetas sugeridas: $e');
      _setLoading(false);
    }
  }

  /// Buscar recetas por nombre
  Future<void> searchRecipes({required String query}) async {
    try {
      _setLoading(true);
      _clearError();

      if (query.trim().isEmpty) {
        _searchResults = [];
        _setLoading(false);
        return;
      }

      final results = await _mealDBService.smartSearch(query);
      _searchResults = results;
      
      print('✅ Búsqueda completada: ${_searchResults.length} recetas encontradas');
      _setLoading(false);
    } catch (e) {
      print('❌ Error en búsqueda: $e');
      _setError('Error al buscar recetas: $e');
      _setLoading(false);
    }
  }

  /// Buscar recetas por ingrediente
  Future<void> searchByIngredient(String ingredient) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _mealDBService.searchByMainIngredient(ingredient);
      _searchResults = response.meals;
      
      print('✅ Búsqueda por ingrediente completada: ${_searchResults.length} recetas');
      _setLoading(false);
    } catch (e) {
      print('❌ Error en búsqueda por ingrediente: $e');
      _setError('Error al buscar por ingrediente: $e');
      _setLoading(false);
    }
  }

  /// Buscar recetas por múltiples ingredientes
  Future<void> searchByIngredients(List<String> ingredients) async {
    try {
      _setLoading(true);
      _clearError();

      if (ingredients.isEmpty) {
        _searchResults = [];
        _setLoading(false);
        return;
      }

      final allResults = <MealDBRecipe>[];
      final seenIds = <String>{};

      // Buscar por cada ingrediente y combinar resultados
      for (final ingredient in ingredients) {
        try {
          final response = await _mealDBService.searchByMainIngredient(ingredient);
          for (final recipe in response.meals) {
            if (!seenIds.contains(recipe.id)) {
              allResults.add(recipe);
              seenIds.add(recipe.id);
            }
          }
        } catch (e) {
          print('❌ Error buscando ingrediente $ingredient: $e');
        }
      }

      _searchResults = allResults;
      print('✅ Búsqueda por múltiples ingredientes completada: ${_searchResults.length} recetas');
      _setLoading(false);
    } catch (e) {
      print('❌ Error en búsqueda por múltiples ingredientes: $e');
      _setError('Error al buscar por ingredientes: $e');
      _setLoading(false);
    }
  }

  /// Buscar recetas por categoría
  Future<void> searchByCategory(String category) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _mealDBService.searchByCategory(category);
      _searchResults = response.meals;
      
      print('✅ Búsqueda por categoría completada: ${_searchResults.length} recetas');
      _setLoading(false);
    } catch (e) {
      print('❌ Error en búsqueda por categoría: $e');
      _setError('Error al buscar por categoría: $e');
      _setLoading(false);
    }
  }

  /// Buscar recetas por área/región
  Future<void> searchByArea(String area) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _mealDBService.searchByArea(area);
      _searchResults = response.meals;
      
      print('✅ Búsqueda por área completada: ${_searchResults.length} recetas');
      _setLoading(false);
    } catch (e) {
      print('❌ Error en búsqueda por área: $e');
      _setError('Error al buscar por área: $e');
      _setLoading(false);
    }
  }

  /// Obtener detalles de una receta específica
  Future<void> loadRecipeDetails(String recipeId) async {
    try {
      _setLoading(true);
      _clearError();

      final recipe = await _mealDBService.getRecipeById(recipeId);
      _selectedRecipe = recipe;
      
      print('✅ Detalles de receta cargados: ${recipe?.name}');
      _setLoading(false);
    } catch (e) {
      print('❌ Error cargando detalles de receta: $e');
      _setError('Error al cargar detalles de la receta: $e');
      _setLoading(false);
    }
  }

  /// Cargar categorías disponibles
  Future<void> loadCategories() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _mealDBService.getCategories();
      _categories = response.categories;
      
      print('✅ Categorías cargadas: ${_categories.length}');
      _setLoading(false);
    } catch (e) {
      print('❌ Error cargando categorías: $e');
      _setError('Error al cargar categorías: $e');
      _setLoading(false);
    }
  }

  /// Obtener una receta aleatoria
  Future<void> getRandomRecipe() async {
    try {
      _setLoading(true);
      _clearError();

      final recipe = await _mealDBService.getRandomRecipe();
      if (recipe != null) {
        _selectedRecipe = recipe;
      }
      
      print('✅ Receta aleatoria obtenida: ${recipe?.name}');
      _setLoading(false);
    } catch (e) {
      print('❌ Error obteniendo receta aleatoria: $e');
      _setError('Error al obtener receta aleatoria: $e');
      _setLoading(false);
    }
  }

  /// Limpiar resultados de búsqueda
  void clearSearchResults() {
    _searchResults = [];
    _clearError();
    notifyListeners();
  }

  /// Limpiar receta seleccionada
  void clearSelectedRecipe() {
    _selectedRecipe = null;
    _clearError();
    notifyListeners();
  }

  /// Refrescar datos
  Future<void> refresh() async {
    await loadRandomRecipes();
    if (_categories.isEmpty) {
      await loadCategories();
    }
  }

  /// Cargar receta individual por ID
  Future<void> loadRecipeById(String id) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final recipe = await _mealDBService.getRecipeById(id);
      _selectedRecipe = recipe;
      
    } catch (e) {
      _setError('Error al cargar la receta: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Convertir recetas de MealDB al formato de la app
  List<Map<String, dynamic>> get recipesAsAppFormat {
    return _randomRecipes.map((recipe) => recipe.toAppFormat()).toList();
  }

  /// Convertir resultados de búsqueda al formato de la app
  List<Map<String, dynamic>> get searchResultsAsAppFormat {
    return _searchResults.map((recipe) => recipe.toAppFormat()).toList();
  }
}
