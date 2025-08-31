// Modelos para TheMealDB API
class MealDBResponse {
  final List<MealDBRecipe> meals;

  MealDBResponse({required this.meals});

  factory MealDBResponse.fromJson(Map<String, dynamic> json) {
    final mealsJson = json['meals'] as List<dynamic>?;
    final meals = mealsJson?.map((meal) => MealDBRecipe.fromJson(meal)).toList() ?? [];
    return MealDBResponse(meals: meals);
  }
}

class MealDBRecipe {
  final String id;
  final String name;
  final String? category;
  final String? area;
  final String? instructions;
  final String? image;
  final String? video;
  final List<MealDBIngredient> ingredients;
  final String? source;

  MealDBRecipe({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    this.image,
    this.video,
    required this.ingredients,
    this.source,
  });

  factory MealDBRecipe.fromJson(Map<String, dynamic> json) {
    final ingredients = <MealDBIngredient>[];
    
    // TheMealDB devuelve ingredientes en campos separados (strIngredient1, strIngredient2, etc.)
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;
      
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add(MealDBIngredient(
          name: ingredient.trim(),
          measure: measure?.trim(),
        ));
      }
    }

    return MealDBRecipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'],
      area: json['strArea'],
      instructions: json['strInstructions'],
      image: json['strMealThumb'],
      video: json['strYoutube'],
      ingredients: ingredients,
      source: json['strSource'],
    );
  }

  // Convertir a formato compatible con la app
  Map<String, dynamic> toAppFormat() {
    return {
      'id': id,
      'title': name,
      'description': instructions?.substring(0, 200) ?? 'Deliciosa receta de $name',
      'imageUrl': image,
      'region': area ?? 'Internacional',
      'category': category ?? 'Plato Principal',
      'ingredients': ingredients.map((ing) => '${ing.measure ?? ''} ${ing.name}'.trim()).toList(),
      'instructions': formatInstructions(instructions ?? ''),
      'servings': 4,
      'preparationTime': 30,
      'cookingTime': 45,
      'difficulty': 'Intermedio',
      'videoUrl': video,
      'sourceUrl': source,
    };
  }

  List<String> formatInstructions(String instructions) {
    // Dividir las instrucciones en pasos
    return instructions
        .split(RegExp(r'\d+\.|\n'))
        .where((step) => step.trim().isNotEmpty)
        .map((step) => step.trim())
        .toList();
  }

  // Getters para compatibilidad con widgets existentes
  String get title => name;
  String get imageUrl => image ?? '';
  int get servings => 4;
  int get preparationTime => 30;
  int get cookingTime => 45;
  String get difficulty => 'Intermedio';
  String get region => area ?? 'Internacional';
}

class MealDBIngredient {
  final String name;
  final String? measure;

  MealDBIngredient({
    required this.name,
    this.measure,
  });

  @override
  String toString() {
    return measure != null ? '$measure $name' : name;
  }
}

// Respuesta para búsqueda por categorías
class MealDBCategoriesResponse {
  final List<MealDBCategory> categories;

  MealDBCategoriesResponse({required this.categories});

  factory MealDBCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'] as List<dynamic>?;
    final categories = categoriesJson?.map((cat) => MealDBCategory.fromJson(cat)).toList() ?? [];
    return MealDBCategoriesResponse(categories: categories);
  }
}

class MealDBCategory {
  final String id;
  final String name;
  final String? image;
  final String? description;

  MealDBCategory({
    required this.id,
    required this.name,
    this.image,
    this.description,
  });

  factory MealDBCategory.fromJson(Map<String, dynamic> json) {
    return MealDBCategory(
      id: json['idCategory'] ?? '',
      name: json['strCategory'] ?? '',
      image: json['strCategoryThumb'],
      description: json['strCategoryDescription'],
    );
  }
}
