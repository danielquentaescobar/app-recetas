import 'package:flutter/material.dart';
import '../models/spoonacular_models.dart';
import '../services/spoonacular_service.dart';

class SpoonacularProvider with ChangeNotifier {
  final SpoonacularService _spoonacularService = SpoonacularService();
  
  List<SpoonacularRecipe> _searchResults = [];
  List<SpoonacularRecipe> _randomRecipes = [];
  List<SpoonacularRecipe> _recipesByIngredients = [];
  SpoonacularRecipe? _selectedRecipe;
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<SpoonacularRecipe> get searchResults => _searchResults;
  List<SpoonacularRecipe> get randomRecipes => _randomRecipes;
  List<SpoonacularRecipe> get recipesByIngredients => _recipesByIngredients;
  SpoonacularRecipe? get selectedRecipe => _selectedRecipe;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Buscar recetas por texto
  Future<void> searchRecipes({
    required String query,
    String? cuisine,
    String? diet,
    String? intolerances,
    int number = 12,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      _searchResults = await _spoonacularService.searchRecipes(
        query: query,
        cuisine: cuisine,
        diet: diet,
        intolerances: intolerances,
        number: number,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Error al buscar recetas: $e';
      _searchResults = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Buscar recetas por ingredientes
  Future<void> searchRecipesByIngredients({
    required List<String> ingredients,
    int number = 12,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      _recipesByIngredients = await _spoonacularService.searchRecipesByIngredients(
        ingredients: ingredients,
        number: number,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Error al buscar recetas por ingredientes: $e';
      _recipesByIngredients = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Obtener recetas aleatorias
  Future<void> getRandomRecipes({
    String? tags,
    int number = 12,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      _randomRecipes = await _spoonacularService.getRandomRecipes(
        tags: tags,
        number: number,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Error al obtener recetas aleatorias: $e';
      _randomRecipes = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Obtener información detallada de una receta
  Future<void> getRecipeDetails(int recipeId) async {
    _setLoading(true);
    _error = null;
    
    try {
      _selectedRecipe = await _spoonacularService.getRecipeInformation(recipeId);
      notifyListeners();
    } catch (e) {
      _error = 'Error al obtener detalles de la receta: $e';
      _selectedRecipe = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Obtener recetas por región
  Future<void> getRecipesByRegion({
    required String region,
    int number = 12,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      _searchResults = await _spoonacularService.getRecipesByRegion(
        region: region,
        number: number,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Error al obtener recetas por región: $e';
      _searchResults = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Limpiar resultados de búsqueda
  void clearSearchResults() {
    _searchResults = [];
    _recipesByIngredients = [];
    _error = null;
    notifyListeners();
  }

  // Limpiar receta seleccionada
  void clearSelectedRecipe() {
    _selectedRecipe = null;
    notifyListeners();
  }

  // Método privado para manejar loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
