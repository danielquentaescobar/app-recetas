import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/recipe_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // CRUD para Recetas
  
  // Crear nueva receta
  Future<String> createRecipe(Recipe recipe) async {
    try {
      DocumentReference docRef = await _firestore.collection('recipes').add({
        'title': recipe.title,
        'description': recipe.description,
        'imageUrl': recipe.imageUrl,
        'authorId': recipe.authorId,
        'authorName': recipe.authorName,
        'ingredients': recipe.ingredients,
        'instructions': recipe.instructions,
        'preparationTime': recipe.preparationTime,
        'cookingTime': recipe.cookingTime,
        'servings': recipe.servings,
        'difficulty': recipe.difficulty,
        'region': recipe.region,
        'tags': recipe.tags,
        'categories': recipe.categories,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'rating': 0.0,
        'reviewsCount': 0,
      });
      
      print('Receta creada con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error al crear receta: $e');
      rethrow;
    }
  }

  // Obtener todas las recetas
  Future<List<Recipe>> getAllRecipes() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('recipes')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Recipe.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error al obtener recetas: $e');
      rethrow;
    }
  }

  // Obtener receta por ID
  Future<Recipe?> getRecipeById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('recipes').doc(id).get();
      
      if (doc.exists) {
        return Recipe.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error al obtener receta: $e');
      rethrow;
    }
  }

  // Actualizar receta
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _firestore.collection('recipes').doc(recipe.id).update({
        'title': recipe.title,
        'description': recipe.description,
        'imageUrl': recipe.imageUrl,
        'ingredients': recipe.ingredients,
        'instructions': recipe.instructions,
        'preparationTime': recipe.preparationTime,
        'cookingTime': recipe.cookingTime,
        'servings': recipe.servings,
        'difficulty': recipe.difficulty,
        'region': recipe.region,
        'tags': recipe.tags,
        'categories': recipe.categories,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('Receta actualizada: ${recipe.id}');
    } catch (e) {
      print('Error al actualizar receta: $e');
      rethrow;
    }
  }

  // Eliminar receta
  Future<void> deleteRecipe(String id) async {
    try {
      await _firestore.collection('recipes').doc(id).delete();
      print('Receta eliminada: $id');
    } catch (e) {
      print('Error al eliminar receta: $e');
      rethrow;
    }
  }

  // Buscar recetas
  Future<List<Recipe>> searchRecipes({
    String? query,
    String? region,
    String? difficulty,
    List<String>? categories,
  }) async {
    try {
      Query queryRef = _firestore.collection('recipes');

      // Filtros por región
      if (region != null && region.isNotEmpty) {
        queryRef = queryRef.where('region', isEqualTo: region);
      }

      // Filtros por dificultad
      if (difficulty != null && difficulty.isNotEmpty) {
        queryRef = queryRef.where('difficulty', isEqualTo: difficulty);
      }

      // Filtros por categorías
      if (categories != null && categories.isNotEmpty) {
        queryRef = queryRef.where('categories', arrayContainsAny: categories);
      }

      queryRef = queryRef.orderBy('createdAt', descending: true);

      QuerySnapshot querySnapshot = await queryRef.get();
      List<Recipe> recipes = querySnapshot.docs.map((doc) {
        return Recipe.fromFirestore(doc);
      }).toList();

      // Filtro de texto (búsqueda local para mayor flexibilidad)
      if (query != null && query.isNotEmpty) {
        recipes = recipes.where((recipe) {
          return recipe.title.toLowerCase().contains(query.toLowerCase()) ||
                 recipe.ingredients.any((ingredient) =>
                     ingredient.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }

      return recipes;
    } catch (e) {
      print('Error al buscar recetas: $e');
      rethrow;
    }
  }

  // Obtener recetas por autor
  Future<List<Recipe>> getRecipesByAuthor(String authorId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('recipes')
          .where('authorId', isEqualTo: authorId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Recipe.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error al obtener recetas del autor: $e');
      rethrow;
    }
  }

  // Obtener recetas públicas (stream)
  Stream<List<Recipe>> getPublicRecipes() {
    return _firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Recipe.fromFirestore(doc);
        } catch (e) {
          print('❌ Error procesando receta ${doc.id}: $e');
          return null;
        }
      }).where((recipe) => recipe != null).cast<Recipe>().toList();
    });
  }

  // Obtener recetas por usuario (stream)
  Stream<List<Recipe>> getRecipesByUser(String userId) {
    return _firestore
        .collection('recipes')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Recipe.fromFirestore(doc);
        } catch (e) {
          print('❌ Error procesando receta ${doc.id}: $e');
          return null;
        }
      }).where((recipe) => recipe != null).cast<Recipe>().toList();
    });
  }

  // Obtener recetas favoritas
  Future<List<Recipe>> getFavoriteRecipes(List<String> favoriteIds) async {
    try {
      if (favoriteIds.isEmpty) return [];
      
      QuerySnapshot querySnapshot = await _firestore
          .collection('recipes')
          .where(FieldPath.documentId, whereIn: favoriteIds)
          .get();

      return querySnapshot.docs.map((doc) {
        return Recipe.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error al obtener recetas favoritas: $e');
      rethrow;
    }
  }

  // Obtener recetas por región (stream)
  Stream<List<Recipe>> getRecipesByRegion(String region) {
    return _firestore
        .collection('recipes')
        .where('region', isEqualTo: region)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Recipe.fromFirestore(doc);
        } catch (e) {
          print('❌ Error procesando receta ${doc.id}: $e');
          return null;
        }
      }).where((recipe) => recipe != null).cast<Recipe>().toList();
    });
  }

  // Buscar recetas por ingredientes
  Future<List<Recipe>> searchRecipesByIngredients(List<String> ingredients) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('recipes')
          .where('ingredients', arrayContainsAny: ingredients)
          .get();

      return querySnapshot.docs.map((doc) {
        return Recipe.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error al buscar recetas por ingredientes: $e');
      rethrow;
    }
  }

  // CRUD para Reviews
  
  // Crear nueva review
  Future<String> createReview(Review review) async {
    try {
      DocumentReference docRef = await _firestore.collection('reviews').add({
        'recipeId': review.recipeId,
        'userId': review.userId,
        'userName': review.userName,
        'rating': review.rating,
        'comment': review.comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Actualizar estadísticas de la receta
      await updateRecipeRating(review.recipeId);
      
      print('Review creada con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error al crear review: $e');
      rethrow;
    }
  }

  // Obtener reviews por receta
  Future<List<Review>> getReviewsByRecipe(String recipeId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('reviews')
          .where('recipeId', isEqualTo: recipeId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Review.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error al obtener reviews: $e');
      rethrow;
    }
  }

  // Actualizar rating promedio de una receta
  Future<void> updateRecipeRating(String recipeId) async {
    try {
      QuerySnapshot reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('recipeId', isEqualTo: recipeId)
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviewsSnapshot.docs) {
          totalRating += (doc.data() as Map<String, dynamic>)['rating'];
        }
        
        double averageRating = totalRating / reviewsSnapshot.docs.length;
        
        await _firestore.collection('recipes').doc(recipeId).update({
          'rating': averageRating,
          'reviewsCount': reviewsSnapshot.docs.length,
        });
      }
    } catch (e) {
      print('Error al actualizar rating: $e');
      rethrow;
    }
  }

  // Guardar imagen - Firebase Storage para todas las plataformas
  Future<String> uploadImageFromBytes(Uint8List imageBytes, String path, String fileName) async {
    try {
      print('Procesando imagen para guardado: $fileName');
      
      // Verificar que tenemos bytes válidos
      if (imageBytes.isEmpty) {
        throw Exception('Los bytes de la imagen están vacíos');
      }
      
      // Usar Firebase Storage para todas las plataformas (web y móvil)
      print('🔄 Subiendo imagen a Firebase Storage...');
      String firebaseFileName = '${DateTime.now().millisecondsSinceEpoch}_recipe_image.jpg';
      Reference ref = _storage.ref().child('recipes/$firebaseFileName');
      
      // Configurar metadata para la imagen
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_by': 'flutter_app',
          'upload_time': DateTime.now().toIso8601String(),
        },
      );
      
      UploadTask uploadTask = ref.putData(imageBytes, metadata);
      
      // Monitorear el progreso (opcional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('🔄 Progreso de subida: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ Imagen subida a Firebase Storage: $downloadUrl');
      return downloadUrl;
      
    } catch (e) {
      print('❌ Error al subir a Firebase Storage: $e');
      
      // Proporcionar información más detallada del error
      if (e.toString().contains('unauthorized')) {
        print('❌ Error de autorización: Verifica las reglas de Firebase Storage');
        print('❌ Asegúrate de que el usuario esté autenticado y las reglas permitan escritura');
      } else if (e.toString().contains('quota-exceeded')) {
        print('❌ Error de cuota: Se ha excedido el límite de almacenamiento');
      } else if (e.toString().contains('invalid-argument')) {
        print('❌ Error de argumento: Verifica el formato de la imagen');
      }
      
      // Fallback: usar imagen por defecto de Unsplash
      print('🔄 Usando imagen por defecto...');
      return 'https://images.unsplash.com/photo-1546548970-71785318a17b?w=500';
    }
  }

  // Subir imagen a Firebase Storage (método original - mantenido por compatibilidad)
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('$path/$fileName');
      
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      rethrow;
    }
  }

  // Métodos para usuarios y favoritos
  
  // Toggle like de receta
  Future<void> toggleRecipeLike(String recipeId, String userId) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();
      
      List<String> favoriteRecipes = [];
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        favoriteRecipes = List<String>.from(userData['favoriteRecipes'] ?? []);
      }
      
      if (favoriteRecipes.contains(recipeId)) {
        favoriteRecipes.remove(recipeId);
      } else {
        favoriteRecipes.add(recipeId);
      }
      
      await userRef.set({
        'favoriteRecipes': favoriteRecipes,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
    } catch (e) {
      print('Error al toggle like: $e');
      rethrow;
    }
  }

  // Toggle favorito de usuario
  Future<bool> toggleUserFavorite(String userId, String recipeId) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();
      
      List<String> favoriteRecipes = [];
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        favoriteRecipes = List<String>.from(userData['favoriteRecipes'] ?? []);
      }
      
      bool wasAdded;
      if (favoriteRecipes.contains(recipeId)) {
        favoriteRecipes.remove(recipeId);
        wasAdded = false;
      } else {
        favoriteRecipes.add(recipeId);
        wasAdded = true;
      }
      
      await userRef.set({
        'favoriteRecipes': favoriteRecipes,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      return wasAdded;
    } catch (e) {
      print('Error al toggle favorito: $e');
      return false;
    }
  }

  // Obtener usuario por ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario: $e');
      return null;
    }
  }

  // Agregar a favoritos
  Future<bool> addToFavorites(String userId, String recipeId) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      
      // Verificar si el documento existe, si no, crearlo
      DocumentSnapshot userDoc = await userRef.get();
      if (!userDoc.exists) {
        await userRef.set({
          'favoriteRecipes': [recipeId],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userRef.update({
          'favoriteRecipes': FieldValue.arrayUnion([recipeId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      return true;
    } catch (e) {
      print('Error al agregar favorito: $e');
      return false;
    }
  }

  // Remover de favoritos
  Future<bool> removeFromFavorites(String userId, String recipeId) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      
      // Verificar si el documento existe
      DocumentSnapshot userDoc = await userRef.get();
      if (!userDoc.exists) {
        print('Usuario no tiene documento de favoritos');
        return false;
      }
      
      await userRef.update({
        'favoriteRecipes': FieldValue.arrayRemove([recipeId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Error al remover favorito: $e');
      return false;
    }
  }
}
