// Modelos para EDAMAM Recipe Search API
// Documentación: https://developer.edamam.com/edamam-docs-recipe-api

class EdamamRecipeSearchResponse {
  final List<EdamamRecipeHit> hits;
  final int from;
  final int to;
  final int count;
  final EdamamLinks? links;

  EdamamRecipeSearchResponse({
    required this.hits,
    required this.from,
    required this.to,
    required this.count,
    this.links,
  });

  factory EdamamRecipeSearchResponse.fromJson(Map<String, dynamic> json) {
    return EdamamRecipeSearchResponse(
      hits: (json['hits'] as List? ?? [])
          .map((hit) => EdamamRecipeHit.fromJson(hit))
          .toList(),
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
      count: json['count'] ?? 0,
      links: json['_links'] != null ? EdamamLinks.fromJson(json['_links']) : null,
    );
  }
}

class EdamamRecipeHit {
  final EdamamRecipe recipe;

  EdamamRecipeHit({required this.recipe});

  factory EdamamRecipeHit.fromJson(Map<String, dynamic> json) {
    return EdamamRecipeHit(
      recipe: EdamamRecipe.fromJson(json['recipe']),
    );
  }
}

class EdamamRecipe {
  final String uri;
  final String label;
  final String image;
  final String source;
  final String url;
  final String shareAs;
  final int yield;
  final List<String> dietLabels;
  final List<String> healthLabels;
  final List<String> cautions;
  final List<String> ingredientLines;
  final List<EdamamIngredient> ingredients;
  final double calories;
  final double totalWeight;
  final int totalTime;
  final List<String> cuisineType;
  final List<String> mealType;
  final List<String> dishType;
  final EdamamNutrients? totalNutrients;
  final EdamamNutrients? totalDaily;

  EdamamRecipe({
    required this.uri,
    required this.label,
    required this.image,
    required this.source,
    required this.url,
    required this.shareAs,
    required this.yield,
    required this.dietLabels,
    required this.healthLabels,
    required this.cautions,
    required this.ingredientLines,
    required this.ingredients,
    required this.calories,
    required this.totalWeight,
    required this.totalTime,
    required this.cuisineType,
    required this.mealType,
    required this.dishType,
    this.totalNutrients,
    this.totalDaily,
  });

  factory EdamamRecipe.fromJson(Map<String, dynamic> json) {
    return EdamamRecipe(
      uri: json['uri'] ?? '',
      label: json['label'] ?? '',
      image: json['image'] ?? '',
      source: json['source'] ?? '',
      url: json['url'] ?? '',
      shareAs: json['shareAs'] ?? '',
      yield: json['yield']?.toInt() ?? 1,
      dietLabels: List<String>.from(json['dietLabels'] ?? []),
      healthLabels: List<String>.from(json['healthLabels'] ?? []),
      cautions: List<String>.from(json['cautions'] ?? []),
      ingredientLines: List<String>.from(json['ingredientLines'] ?? []),
      ingredients: (json['ingredients'] as List? ?? [])
          .map((ing) => EdamamIngredient.fromJson(ing))
          .toList(),
      calories: (json['calories'] ?? 0).toDouble(),
      totalWeight: (json['totalWeight'] ?? 0).toDouble(),
      totalTime: json['totalTime']?.toInt() ?? 0,
      cuisineType: List<String>.from(json['cuisineType'] ?? []),
      mealType: List<String>.from(json['mealType'] ?? []),
      dishType: List<String>.from(json['dishType'] ?? []),
      totalNutrients: json['totalNutrients'] != null 
          ? EdamamNutrients.fromJson(json['totalNutrients']) 
          : null,
      totalDaily: json['totalDaily'] != null 
          ? EdamamNutrients.fromJson(json['totalDaily']) 
          : null,
    );
  }

  // Métodos de conveniencia para compatibilidad con la UI existente
  String get id {
    final parts = uri.split('#recipe_');
    return parts.length > 1 ? parts[1] : uri;
  }
  String get title => label;
  int get readyInMinutes => totalTime;
  int get servings => yield;
  String get summary => ingredientLines.take(3).join(', ');
  String get sourceUrl => url;
  List<String> get extendedIngredients => ingredientLines;
  List<String> get analyzedInstructions => ['Visita $url para ver las instrucciones completas'];
}

class EdamamIngredient {
  final String text;
  final double quantity;
  final String? measure;
  final String food;
  final double weight;
  final String? foodCategory;
  final String? foodId;
  final String image;

  EdamamIngredient({
    required this.text,
    required this.quantity,
    this.measure,
    required this.food,
    required this.weight,
    this.foodCategory,
    this.foodId,
    required this.image,
  });

  factory EdamamIngredient.fromJson(Map<String, dynamic> json) {
    return EdamamIngredient(
      text: json['text'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      measure: json['measure'],
      food: json['food'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      foodCategory: json['foodCategory'],
      foodId: json['foodId'],
      image: json['image'] ?? '',
    );
  }
}

class EdamamNutrients {
  final Map<String, EdamamNutrient> nutrients;

  EdamamNutrients({required this.nutrients});

  factory EdamamNutrients.fromJson(Map<String, dynamic> json) {
    Map<String, EdamamNutrient> nutrients = {};
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        nutrients[key] = EdamamNutrient.fromJson(value);
      }
    });
    return EdamamNutrients(nutrients: nutrients);
  }
}

class EdamamNutrient {
  final String label;
  final double quantity;
  final String unit;

  EdamamNutrient({
    required this.label,
    required this.quantity,
    required this.unit,
  });

  factory EdamamNutrient.fromJson(Map<String, dynamic> json) {
    return EdamamNutrient(
      label: json['label'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }
}

class EdamamLinks {
  final EdamamNextLink? next;

  EdamamLinks({this.next});

  factory EdamamLinks.fromJson(Map<String, dynamic> json) {
    return EdamamLinks(
      next: json['next'] != null ? EdamamNextLink.fromJson(json['next']) : null,
    );
  }
}

class EdamamNextLink {
  final String href;
  final String title;

  EdamamNextLink({required this.href, required this.title});

  factory EdamamNextLink.fromJson(Map<String, dynamic> json) {
    return EdamamNextLink(
      href: json['href'] ?? '',
      title: json['title'] ?? '',
    );
  }
}

// Filtros disponibles en EDAMAM
class EdamamFilters {
  static const List<String> dietTypes = [
    'balanced',
    'high-fiber',
    'high-protein',
    'low-carb',
    'low-fat',
    'low-sodium',
  ];

  static const List<String> healthLabels = [
    'vegan',
    'vegetarian',
    'gluten-free',
    'dairy-free',
    'egg-free',
    'fish-free',
    'shellfish-free',
    'tree-nut-free',
    'peanut-free',
    'soy-free',
    'keto-friendly',
    'paleo',
  ];

  static const List<String> cuisineTypes = [
    'american',
    'asian',
    'british',
    'caribbean',
    'central europe',
    'chinese',
    'eastern europe',
    'french',
    'indian',
    'italian',
    'japanese',
    'kosher',
    'mediterranean',
    'mexican',
    'middle eastern',
    'nordic',
    'south american',
    'south east asian',
  ];

  static const List<String> mealTypes = [
    'breakfast',
    'lunch',
    'dinner',
    'snack',
    'teatime',
  ];

  static const List<String> dishTypes = [
    'alcohol cocktail',
    'biscuits and cookies',
    'bread',
    'cereals',
    'condiments and sauces',
    'desserts',
    'drinks',
    'main course',
    'pancake',
    'preps',
    'preserve',
    'salad',
    'sandwiches',
    'side dish',
    'soup',
    'starter',
    'sweets',
  ];
}
