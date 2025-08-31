import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../models/recipe_model.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';

class RecipeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Recipe> _recipes = [];
  List<Recipe> _userRecipes = [];
  List<Recipe> _favoriteRecipes = [];
  List<Review> _currentRecipeReviews = [];
  
  Recipe? _selectedRecipe;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Recipe> get recipes => _recipes;
  List<Recipe> get userRecipes => _userRecipes;
  List<Recipe> get favoriteRecipes => _favoriteRecipes;
  List<Review> get currentRecipeReviews => _currentRecipeReviews;
  Recipe? get selectedRecipe => _selectedRecipe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Método para limpiar todas las recetas (solo para desarrollo)
  Future<void> clearAllRecipes() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Obtener todas las recetas
      final recipes = await _firestoreService.getAllRecipes();
      
      print('🗑️ Eliminando ${recipes.length} recetas de Firebase...');
      
      // Eliminar cada receta
      for (var recipe in recipes) {
        await _firestoreService.deleteRecipe(recipe.id);
        print('   ❌ Eliminada: ${recipe.title}');
      }
      
      // Limpiar lista local
      _recipes.clear();
      _userRecipes.clear();
      _favoriteRecipes.clear();
      
      print('✅ Todas las recetas han sido eliminadas');
      _setLoading(false);
      notifyListeners();
      
    } catch (e) {
      print('❌ Error al limpiar recetas: $e');
      _setError('Error al limpiar recetas: $e');
      _setLoading(false);
    }
  }

  /// Subir imagen desde bytes a Firebase Storage
  Future<String> uploadImageFromBytes(Uint8List imageBytes, String path, String fileName) async {
    try {
      return await _firestoreService.uploadImageFromBytes(imageBytes, path, fileName);
    } catch (e) {
      print('Error en RecipeProvider.uploadImageFromBytes: $e');
      rethrow;
    }
  }

  // Cargar recetas públicas
  void loadPublicRecipes() {
    _setLoading(true);
    _clearError();
    
    _firestoreService.getAllRecipes().then(
      (recipes) {
        _recipes = recipes;
        print('✅ Cargadas ${recipes.length} recetas de Firebase');
        print('📋 Lista de recetas cargadas:');
        for (var recipe in recipes) {
          print('   - ID: ${recipe.id} | Título: ${recipe.title} | Autor: ${recipe.authorName}');
        }
        _setLoading(false);
        notifyListeners();
      },
    ).catchError((error) {
      print('❌ Error al cargar recetas públicas: $error');
      _setError('Error al cargar recetas: $error');
      _setLoading(false);
    });
  }

  // Cargar recetas del usuario
  void loadUserRecipes(String userId) {
    _setLoading(true);
    _clearError();
    
    _firestoreService.getRecipesByAuthor(userId).then(
      (recipes) {
        _userRecipes = recipes;
        print('✅ Cargadas ${recipes.length} recetas del usuario desde Firebase');
        _setLoading(false);
        notifyListeners();
      },
    ).catchError((error) {
      print('❌ Error al cargar recetas del usuario: $error');
      _setError('Error al cargar tus recetas: $error');
      _setLoading(false);
    });
  }

  // Cargar recetas favoritas
  Future<List<Recipe>> loadFavoriteRecipes(List<String> favoriteRecipeIds) async {
    if (favoriteRecipeIds.isEmpty) {
      _favoriteRecipes = [];
      notifyListeners();
      return _favoriteRecipes;
    }

    try {
      _setLoading(true);
      _clearError();
      
      final recipes = await _firestoreService.getFavoriteRecipes(favoriteRecipeIds);
      _favoriteRecipes = recipes;
      print('✅ Cargadas ${_favoriteRecipes.length} recetas favoritas desde Firebase');
      _setLoading(false);
      notifyListeners();
      
      return _favoriteRecipes;
    } catch (error) {
      print('❌ Error al cargar recetas favoritas: $error');
      _setError('Error al cargar favoritos: $error');
      _setLoading(false);
      return [];
    }
  }

  // Cargar una receta específica
  Future<Recipe?> loadRecipe(String recipeId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final recipe = await _firestoreService.getRecipeById(recipeId);
      _selectedRecipe = recipe;
      
      _setLoading(false);
      notifyListeners();
      
      return recipe;
    } catch (e) {
      print('❌ Error al cargar receta: $e');
      _setError('Error al cargar la receta: $e');
      _setLoading(false);
      return null;
    }
  }

  // Cargar reseñas de una receta
  Future<List<Review>> loadRecipeReviews(String recipeId) async {
    try {
      final reviews = await _firestoreService.getReviewsByRecipe(recipeId);
      _currentRecipeReviews = reviews;
      notifyListeners();
      return reviews;
    } catch (error) {
      print('❌ Error al cargar reseñas: $error');
      _setError('Error al cargar reseñas: $error');
      return [];
    }
  }

  // CRUD de recetas
  Future<bool> createRecipe(Recipe recipe) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestoreService.createRecipe(recipe);
      
      _setLoading(false);
      return true;
    } catch (e) {
      print('❌ Error al crear receta: $e');
      _setError('Error al crear la receta: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateRecipe(Recipe recipe) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestoreService.updateRecipe(recipe);
      
      // Actualizar en las listas locales
      _updateRecipeInLists(recipe);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error al actualizar receta: $e');
      _setError('Error al actualizar la receta: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteRecipe(String recipeId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestoreService.deleteRecipe(recipeId);
      
      // Remover de las listas locales
      _removeRecipeFromLists(recipeId);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error al eliminar receta: $e');
      _setError('Error al eliminar la receta: $e');
      _setLoading(false);
      return false;
    }
  }

  // Búsqueda de recetas
  Future<List<Recipe>> searchRecipes({
    String? query,
    String? region,
    String? difficulty,
    List<String>? tags,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final results = await _firestoreService.searchRecipes(
        query: query,
        region: region,
        difficulty: difficulty,
      );
      
      _setLoading(false);
      return results;
    } catch (e) {
      print('❌ Error en búsqueda: $e');
      _setError('Error en la búsqueda: $e');
      _setLoading(false);
      return [];
    }
  }

  // Buscar recetas por ingredientes
  Future<List<Recipe>> searchRecipesByIngredients(List<String> ingredients) async {
    try {
      _setLoading(true);
      _clearError();
      
      final results = await _firestoreService.searchRecipesByIngredients(ingredients);
      
      _setLoading(false);
      return results;
    } catch (e) {
      print('❌ Error en búsqueda por ingredientes: $e');
      _setError('Error en la búsqueda: $e');
      _setLoading(false);
      return [];
    }
  }

  // Agregar/quitar like a una receta
  Future<void> toggleRecipeLike(String recipeId, String userId) async {
    try {
      // Encontrar la receta en las listas locales
      int index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
      if (index != -1) {
        List<String> likedBy = List.from(_recipes[index].likedBy);
        
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }
        
        _recipes[index] = _recipes[index].copyWith(likedBy: likedBy);
      }
      
      // También en recetas del usuario si aplica
      int userIndex = _userRecipes.indexWhere((recipe) => recipe.id == recipeId);
      if (userIndex != -1) {
        List<String> likedBy = List.from(_userRecipes[userIndex].likedBy);
        
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }
        
        _userRecipes[userIndex] = _userRecipes[userIndex].copyWith(likedBy: likedBy);
      }
      
      notifyListeners();
      
      // Actualizar en Firebase
      await _firestoreService.toggleRecipeLike(recipeId, userId);
      
    } catch (e) {
      print('❌ Error al actualizar like: $e');
      _setError('Error al actualizar reacción: $e');
      // Revertir cambios locales en caso de error
      loadPublicRecipes();
    }
  }

  // Agregar reseña a una receta
  Future<bool> addReview(Review review) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestoreService.createReview(review);
      
      _setLoading(false);
      return true;
    } catch (e) {
      print('❌ Error al agregar reseña: $e');
      _setError('Error al agregar reseña: $e');
      _setLoading(false);
      return false;
    }
  }

  // Crear reseña (alias para compatibilidad)
  Future<bool> createReview(Review review) async {
    return await addReview(review);
  }

  /// Limpiar selección actual
  void clearSelection() {
    _selectedRecipe = null;
    _currentRecipeReviews.clear();
    notifyListeners();
  }

  // FUNCIONES DE FAVORITOS

  /// Verificar si una receta está en favoritos
  bool isRecipeFavorite(String recipeId, List<String> userFavorites) {
    return userFavorites.contains(recipeId);
  }

  /// Toggle favorito de usuario con actualización optimista
  Future<void> toggleUserFavorite(String userId, String recipeId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _firestoreService.toggleUserFavorite(userId, recipeId);
      
      if (success) {
        // Recargar favoritos inmediatamente
        await reloadFavoritesFromUser(userId);
        print('✅ Favorito actualizado y recargado');
      }
      
      _setLoading(false);
      
    } catch (e) {
      print('❌ Error al actualizar favoritos: $e');
      _setError('Error al actualizar favoritos: $e');
      _setLoading(false);
    }
  }

  /// Recargar favoritos desde el usuario actualizado
  Future<void> reloadFavoritesFromUser(String userId) async {
    try {
      final updatedUser = await _firestoreService.getUserById(userId);
      if (updatedUser != null) {
        loadFavoriteRecipes(updatedUser.favoriteRecipes);
      }
    } catch (e) {
      print('❌ Error al recargar favoritos: $e');
    }
  }

  /// Obtener receta por ID (para compatibilidad)
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      return await _firestoreService.getRecipeById(recipeId);
    } catch (e) {
      print('❌ Error al obtener receta: $e');
      return null;
    }
  }

  /// Agregar receta a favoritos
  Future<bool> addToFavorites(String userId, String recipeId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _firestoreService.addToFavorites(userId, recipeId);
      
      if (success) {
        print('✅ Receta agregada a favoritos');
        // Recargar favoritos
        await reloadFavoritesFromUser(userId);
      }
      
      _setLoading(false);
      return success;
      
    } catch (e) {
      print('❌ Error al agregar a favoritos: $e');
      _setError('Error al agregar a favoritos: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Remover receta de favoritos
  Future<bool> removeFromFavorites(String userId, String recipeId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _firestoreService.removeFromFavorites(userId, recipeId);
      
      if (success) {
        print('✅ Receta removida de favoritos');
        // Remover de la lista local inmediatamente
        _favoriteRecipes.removeWhere((recipe) => recipe.id == recipeId);
        notifyListeners();
      }
      
      _setLoading(false);
      return success;
      
    } catch (e) {
      print('❌ Error al remover de favoritos: $e');
      _setError('Error al remover de favoritos: $e');
      _setLoading(false);
      return false;
    }
  }

  // FUNCIONES AUXILIARES

  void _updateRecipeInLists(Recipe updatedRecipe) {
    // Actualizar en recetas públicas
    int publicIndex = _recipes.indexWhere((r) => r.id == updatedRecipe.id);
    if (publicIndex != -1) {
      _recipes[publicIndex] = updatedRecipe;
    }
    
    // Actualizar en recetas del usuario
    int userIndex = _userRecipes.indexWhere((r) => r.id == updatedRecipe.id);
    if (userIndex != -1) {
      _userRecipes[userIndex] = updatedRecipe;
    }
    
    // Actualizar en favoritos
    int favIndex = _favoriteRecipes.indexWhere((r) => r.id == updatedRecipe.id);
    if (favIndex != -1) {
      _favoriteRecipes[favIndex] = updatedRecipe;
    }
    
    // Actualizar receta seleccionada
    if (_selectedRecipe?.id == updatedRecipe.id) {
      _selectedRecipe = updatedRecipe;
    }
  }

  void _removeRecipeFromLists(String recipeId) {
    _recipes.removeWhere((r) => r.id == recipeId);
    _userRecipes.removeWhere((r) => r.id == recipeId);
    _favoriteRecipes.removeWhere((r) => r.id == recipeId);
    
    if (_selectedRecipe?.id == recipeId) {
      _selectedRecipe = null;
    }
  }

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
}
