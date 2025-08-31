import 'package:flutter/material.dart';
import '../models/edamam_models.dart';
import '../services/edamam_service.dart';

class EdamamProvider with ChangeNotifier {
  final EdamamService _edamamService = EdamamService();

  // Estados de carga
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Datos de recetas
  List<EdamamRecipe> _recipes = [];
  List<EdamamRecipe> _searchResults = [];
  List<EdamamRecipe> _ingredientResults = [];
  List<EdamamRecipe> _randomRecipes = [];
  
  // Paginación
  int _currentFrom = 0;
  final int _pageSize = 20;
  bool _hasMoreResults = true;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  List<EdamamRecipe> get recipes => _recipes;
  List<EdamamRecipe> get searchResults => _searchResults;
  List<EdamamRecipe> get ingredientResults => _ingredientResults;
  List<EdamamRecipe> get randomRecipes => _randomRecipes;
  bool get hasMoreResults => _hasMoreResults;

  /// Buscar recetas por término
  Future<void> searchRecipes({
    required String query,
    String? diet,
    List<String>? health,
    String? cuisineType,
    String? mealType,
    String? dishType,
    int? calories,
    int? time,
    bool isNewSearch = true,
  }) async {
    if (isNewSearch) {
      _isLoading = true;
      _currentFrom = 0;
      _searchResults.clear();
      _hasMoreResults = true;
      _error = null;
    } else {
      _isLoadingMore = true;
    }
    
    notifyListeners();

    try {
      final response = await _edamamService.searchRecipes(
        query: query,
        diet: diet,
        health: health,
        cuisineType: cuisineType,
        mealType: mealType,
        dishType: dishType,
        calories: calories,
        time: time,
        from: _currentFrom,
        to: _currentFrom + _pageSize,
      );

      if (isNewSearch) {
        _searchResults = response.hits.map((hit) => hit.recipe).toList();
      } else {
        _searchResults.addAll(response.hits.map((hit) => hit.recipe).toList());
      }

      _currentFrom += _pageSize;
      _hasMoreResults = response.hits.length == _pageSize;
      _error = null;

      print('✅ Provider: ${_searchResults.length} recetas cargadas');
    } catch (e) {
      _error = 'Error al buscar recetas: $e';
      print('❌ Provider Error: $_error');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Buscar recetas por ingredientes
  Future<void> searchRecipesByIngredients({
    required List<String> ingredients,
    String? diet,
    List<String>? health,
    String? cuisineType,
    String? mealType,
    bool isNewSearch = true,
  }) async {
    if (isNewSearch) {
      _isLoading = true;
      _currentFrom = 0;
      _ingredientResults.clear();
      _hasMoreResults = true;
      _error = null;
    } else {
      _isLoadingMore = true;
    }
    
    notifyListeners();

    try {
      final response = await _edamamService.searchRecipesByIngredients(
        ingredients: ingredients,
        diet: diet,
        health: health,
        cuisineType: cuisineType,
        mealType: mealType,
        from: _currentFrom,
        to: _currentFrom + _pageSize,
      );

      if (isNewSearch) {
        _ingredientResults = response.hits.map((hit) => hit.recipe).toList();
      } else {
        _ingredientResults.addAll(response.hits.map((hit) => hit.recipe).toList());
      }

      _currentFrom += _pageSize;
      _hasMoreResults = response.hits.length == _pageSize;
      _error = null;

      print('✅ Provider: ${_ingredientResults.length} recetas por ingredientes cargadas');
    } catch (e) {
      _error = 'Error al buscar por ingredientes: $e';
      print('❌ Provider Error: $_error');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Obtener recetas aleatorias
  Future<void> getRandomRecipes({
    String? cuisineType,
    String? mealType,
    String? diet,
    bool isNewSearch = true,
  }) async {
    if (isNewSearch) {
      _isLoading = true;
      _currentFrom = 0;
      _randomRecipes.clear();
      _hasMoreResults = true;
      _error = null;
    } else {
      _isLoadingMore = true;
    }
    
    notifyListeners();

    try {
      final response = await _edamamService.getRandomRecipes(
        cuisineType: cuisineType,
        mealType: mealType,
        diet: diet,
        from: _currentFrom,
        to: _currentFrom + _pageSize,
      );

      if (isNewSearch) {
        _randomRecipes = response.hits.map((hit) => hit.recipe).toList();
      } else {
        _randomRecipes.addAll(response.hits.map((hit) => hit.recipe).toList());
      }

      _currentFrom += _pageSize;
      _hasMoreResults = response.hits.length == _pageSize;
      _error = null;

      print('✅ Provider: ${_randomRecipes.length} recetas aleatorias cargadas');
    } catch (e) {
      _error = 'Error al obtener recetas aleatorias: $e';
      print('❌ Provider Error: $_error');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Obtener recetas saludables
  Future<void> getHealthyRecipes({bool isNewSearch = true}) async {
    if (isNewSearch) {
      _isLoading = true;
      _currentFrom = 0;
      _recipes.clear();
      _hasMoreResults = true;
      _error = null;
    } else {
      _isLoadingMore = true;
    }
    
    notifyListeners();

    try {
      final response = await _edamamService.getHealthyRecipes(
        from: _currentFrom,
        to: _currentFrom + _pageSize,
      );

      if (isNewSearch) {
        _recipes = response.hits.map((hit) => hit.recipe).toList();
      } else {
        _recipes.addAll(response.hits.map((hit) => hit.recipe).toList());
      }

      _currentFrom += _pageSize;
      _hasMoreResults = response.hits.length == _pageSize;
      _error = null;

      print('✅ Provider: ${_recipes.length} recetas saludables cargadas');
    } catch (e) {
      _error = 'Error al obtener recetas saludables: $e';
      print('❌ Provider Error: $_error');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Obtener recetas por tipo de comida
  Future<void> getRecipesByMealType({
    required String mealType,
    String query = '',
    bool isNewSearch = true,
  }) async {
    if (isNewSearch) {
      _isLoading = true;
      _currentFrom = 0;
      _recipes.clear();
      _hasMoreResults = true;
      _error = null;
    } else {
      _isLoadingMore = true;
    }
    
    notifyListeners();

    try {
      final response = await _edamamService.getRecipesByMealType(
        mealType: mealType,
        query: query,
        from: _currentFrom,
        to: _currentFrom + _pageSize,
      );

      if (isNewSearch) {
        _recipes = response.hits.map((hit) => hit.recipe).toList();
      } else {
        _recipes.addAll(response.hits.map((hit) => hit.recipe).toList());
      }

      _currentFrom += _pageSize;
      _hasMoreResults = response.hits.length == _pageSize;
      _error = null;

      print('✅ Provider: ${_recipes.length} recetas de $mealType cargadas');
    } catch (e) {
      _error = 'Error al obtener recetas de $mealType: $e';
      print('❌ Provider Error: $_error');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Cargar más resultados (paginación)
  Future<void> loadMoreResults({
    String? lastQuery,
    List<String>? lastIngredients,
    String? lastMealType,
    String searchType = 'search', // 'search', 'ingredients', 'random', 'healthy', 'mealType'
  }) async {
    if (!_hasMoreResults || _isLoadingMore) return;

    switch (searchType) {
      case 'search':
        if (lastQuery != null) {
          await searchRecipes(query: lastQuery, isNewSearch: false);
        }
        break;
      case 'ingredients':
        if (lastIngredients != null) {
          await searchRecipesByIngredients(ingredients: lastIngredients, isNewSearch: false);
        }
        break;
      case 'random':
        await getRandomRecipes(isNewSearch: false);
        break;
      case 'healthy':
        await getHealthyRecipes(isNewSearch: false);
        break;
      case 'mealType':
        if (lastMealType != null) {
          await getRecipesByMealType(mealType: lastMealType, isNewSearch: false);
        }
        break;
    }
  }

  /// Limpiar resultados
  void clearResults() {
    _recipes.clear();
    _searchResults.clear();
    _ingredientResults.clear();
    _randomRecipes.clear();
    _error = null;
    _currentFrom = 0;
    _hasMoreResults = true;
    notifyListeners();
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
