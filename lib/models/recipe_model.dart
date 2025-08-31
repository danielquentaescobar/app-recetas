import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String authorId;
  final String authorName;
  final List<String> ingredients;
  final List<String> instructions;
  final int preparationTime; // en minutos
  final int cookingTime; // en minutos
  final int servings;
  final String difficulty; // easy, medium, hard
  final String region; // región latinoamericana
  final List<String> tags;
  final List<String> categories;
  final double rating;
  final int reviewsCount;
  final List<String> likedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.ingredients,
    required this.instructions,
    required this.preparationTime,
    required this.cookingTime,
    required this.servings,
    required this.difficulty,
    required this.region,
    this.tags = const [],
    this.categories = const [],
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.likedBy = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = true,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      preparationTime: data['preparationTime'] ?? 0,
      cookingTime: data['cookingTime'] ?? 0,
      servings: data['servings'] ?? 1,
      difficulty: data['difficulty'] ?? 'easy',
      region: data['region'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      isPublic: data['isPublic'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'ingredients': ingredients,
      'instructions': instructions,
      'preparationTime': preparationTime,
      'cookingTime': cookingTime,
      'servings': servings,
      'difficulty': difficulty,
      'region': region,
      'tags': tags,
      'categories': categories,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
    };
  }

  Recipe copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? authorName,
    List<String>? ingredients,
    List<String>? instructions,
    int? preparationTime,
    int? cookingTime,
    int? prepTime,
    int? cookTime,
    int? totalTime,
    int? servings,
    String? difficulty,
    String? region,
    String? category,
    List<String>? tags,
    List<String>? categories,
    double? rating,
    int? reviewsCount,
    List<String>? likedBy,
    DateTime? updatedAt,
    bool? isPublic,
  }) {
    return Recipe(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId,
      authorName: authorName ?? this.authorName,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      preparationTime: prepTime ?? preparationTime ?? this.preparationTime,
      cookingTime: cookTime ?? cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      region: region ?? this.region,
      tags: tags ?? this.tags,
      categories: category != null ? [category] : (categories ?? this.categories),
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPublic: isPublic ?? this.isPublic,
    );
  }

  int get totalTime => preparationTime + cookingTime;
  
  // Getters de compatibilidad
  int get prepTime => preparationTime;
  int get cookTime => cookingTime;
  String get category => categories.isNotEmpty ? categories.first : '';
}
